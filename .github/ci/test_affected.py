#!/usr/bin/env python3
"""Unit tests of affected.py: `python3 -m unittest .github/ci/test_affected.py`."""

import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import affected as a  # noqa: E402

# Two independent packages, as the workspace is today.
TWO = {"packages/quest": set(), "packages/achievement": set()}
# Three packages: app -> quest -> core (an arrow reads "depends on"); other is independent.
THREE = {
    "packages/core": set(),
    "packages/quest": {"packages/core"},
    "packages/app": {"packages/quest"},
    "packages/other": set(),
}


def member(name, directory, deps=()):
    return {
        "id": f"{name} 0.1.0 (path+file:///w/{directory}/Scarb.toml)",
        "name": name,
        "manifest_path": f"/w/{directory}/Scarb.toml",
        "dependencies": [{"name": d} for d in ("core", "starknet", *deps)],
    }


class Affected(unittest.TestCase):
    def test_one_package_only(self):
        self.assertEqual(a.affected(["packages/quest/src/lib.cairo"], TWO), {"packages/quest"})

    def test_two_packages(self):
        changed = ["packages/quest/README.md", "packages/achievement/tests/t.cairo"]
        self.assertEqual(a.affected(changed, TWO), set(TWO))

    def test_dependents_run(self):
        self.assertEqual(
            a.affected(["packages/core/src/lib.cairo"], THREE),
            {"packages/core", "packages/quest", "packages/app"},
        )

    def test_middle_of_the_chain(self):
        self.assertEqual(
            a.affected(["packages/quest/Scarb.toml"], THREE), {"packages/quest", "packages/app"}
        )

    def test_leaf_runs_alone(self):
        self.assertEqual(a.affected(["packages/app/src/lib.cairo"], THREE), {"packages/app"})

    def test_dependencies_do_not_run(self):
        self.assertNotIn("packages/core", a.affected(["packages/app/src/lib.cairo"], THREE))

    def test_shared_files_run_all(self):
        for path in [
            "Scarb.toml", "Scarb.lock", ".tool-versions", ".github/workflows/cairo.yml",
            ".github/ci/affected.py", ".github/ci/new.sh", "scripts/gas.py",
        ]:
            self.assertEqual(a.affected([path], THREE), set(THREE), path)

    def test_documentation_only_runs_none(self):
        changed = ["README.md", "docs/WORKSPACE.md", "STATUS.md", "scripts/lock.sh",
                   ".github/workflows/tooling.yml", "PLAN.md"]
        self.assertEqual(a.affected(changed, TWO), set())

    def test_no_change(self):
        self.assertEqual(a.affected([], TWO), set())

    def test_prefix_is_a_directory_not_a_name_prefix(self):
        graph = {"packages/quest": set(), "packages/quest_extra": set()}
        self.assertEqual(a.affected(["packages/quest_extra/x"], graph), {"packages/quest_extra"})

    def test_cycle_terminates(self):
        graph = {"packages/a": {"packages/b"}, "packages/b": {"packages/a"}}
        self.assertEqual(a.affected(["packages/a/x"], graph), set(graph))


# Git's own variables (GIT_DIR, GIT_INDEX_FILE...) point at a repository: a hook exports them. The
# test builds a repository of its own and must never reach the real one, whatever runs it.


class Renames(unittest.TestCase):
    def setUp(self):
        clean = {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}
        patcher = mock.patch.dict(os.environ, clean, clear=True)
        patcher.start()
        self.addCleanup(patcher.stop)

    def git(self, cwd, *args):
        subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)

    def test_moving_a_file_out_of_a_package_still_affects_it(self):
        with tempfile.TemporaryDirectory() as root:
            root = pathlib.Path(root)
            (root / "packages/quest").mkdir(parents=True)
            (root / "docs").mkdir()
            (root / "packages/quest/notes.md").write_text("some notes\n" * 20)
            self.git(root, "init", "-q", "-b", "main")
            self.git(root, "-c", "user.name=t", "-c", "user.email=t@t", "add", "-A")
            self.git(root, "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "-m", "a")
            self.git(root, "update-ref", "refs/remotes/origin/main", "HEAD")
            self.git(root, "mv", "packages/quest/notes.md", "docs/notes.md")
            self.git(root, "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "-m", "b")
            changed = a.changed_files("main", cwd=root)
            self.assertEqual(sorted(changed), ["docs/notes.md", "packages/quest/notes.md"])
            self.assertEqual(a.affected(changed, TWO), {"packages/quest"})


class Graph(unittest.TestCase):
    def test_from_metadata(self):
        packages = [
            member("base", "packages/base"),
            member("quest", "packages/quest", ["base"]),
            member("app", "packages/app", ["quest", "serde_json"]),
        ]
        metadata = {"packages": packages, "workspace": {"members": [p["id"] for p in packages]}}
        graph = a.package_graph(metadata, "/w")
        self.assertEqual(graph["packages/app"], {"packages/quest"})
        self.assertEqual(graph["packages/quest"], {"packages/base"})
        self.assertEqual(graph["packages/base"], set())

    def test_external_dependencies_are_ignored(self):
        metadata = {
            "packages": [member("quiver_quest", "packages/quest")],
            "workspace": {"members": [member("quiver_quest", "packages/quest")["id"]]},
        }
        self.assertEqual(a.package_graph(metadata, "/w"), {"packages/quest": set()})


class Validation(unittest.TestCase):
    def test_matrix(self):
        self.assertEqual(
            json.loads(a.matrix({"packages/b", "packages/a"})),
            {"include": [{"dir": "packages/a"}, {"dir": "packages/b"}]},
        )
        self.assertEqual(json.loads(a.matrix(set())), {"include": []})

    def test_matrix_refuses_a_bad_directory(self):
        for bad in ["../x", "packages/a b", "packages/a;rm", "packages/", "/packages/a", "x"]:
            with self.assertRaises(ValueError, msg=bad):
                a.matrix({bad})

    def test_tool_versions(self):
        text = "scarb 2.19.4\nstarknet-foundry 0.61.0  # snforge\n\n"
        self.assertEqual(a.parse_tool_versions(text),
                         {"scarb": "2.19.4", "starknet-foundry": "0.61.0"})

    def test_tool_versions_refuses_inexact(self):
        for bad in ["scarb latest", "scarb 2.19", "scarb 2.19.4 extra", "scarb 2.19.4; id"]:
            with self.assertRaises(ValueError, msg=bad):
                a.parse_tool_versions(bad)

    def test_branch_names(self):
        self.assertFalse(a.BRANCH_RE.match("--output=x"))
        self.assertFalse(a.BRANCH_RE.match("a b"))
        self.assertTrue(a.BRANCH_RE.match("main"))


if __name__ == "__main__":
    unittest.main()
