"""Tests of the pre-push hook (ARC-17): `python3 -m unittest scripts/test_hook.py`.

The hook runs scripts/prepush.sh, which runs the Python tests, so this file is NOT among the tests
prepush.sh discovers (.github/ci/test_*.py, scripts/test_gas.py): it would run itself again.

Safety: everything is built in a fresh temporary directory, every git call gets an environment with
all GIT_* variables removed, and nothing here runs `git config` outside the temporary repositories.
The real repository is only read (`git archive HEAD`). The case this guards against: a hook runs
with git's own GIT_* variables, and a test that inherits them can re-initialise the real repository
(core.bare = true, core.worktree set).
"""

import os
import pathlib
import subprocess
import tarfile
import io
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parent.parent
ZERO = "0" * 40
IDENT = ["-c", "user.name=hook-test", "-c", "user.email=hook-test@example.invalid"]


def clean_env():
    return {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}


ENV = clean_env()


def run(cwd, *cmd, check=True, stdin=None):
    return subprocess.run(
        list(cmd), cwd=cwd, env=ENV, check=check, input=stdin,
        capture_output=True, text=True,
    )


def git(cwd, *args, check=True, stdin=None):
    return run(cwd, "git", *IDENT, *args, check=check, stdin=stdin)


PROBE = '''import os
import unittest


class HookEnv(unittest.TestCase):
    def test_no_git_variable_reaches_the_tests(self):
        local = ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR", "GIT_OBJECT_DIRECTORY")
        leaked = sorted(k for k in local if k in os.environ)
        self.assertEqual(leaked, [])
'''


class HookTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(prefix="hook-test-")
        root = pathlib.Path(cls.tmp.name)
        cls.origin = root / "origin.git"
        cls.clone = root / "clone"
        cls.wt = root / "wt"
        run(root, "git", "init", "-q", "--bare", "-b", "main", str(cls.origin))
        # The tracked files of this repository at HEAD (a read), as a first commit.
        archive = subprocess.run(
            ["git", "archive", "HEAD"], cwd=REPO, env=ENV, check=True, capture_output=True
        ).stdout
        cls.clone.mkdir()
        with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
            tar.extractall(cls.clone, filter="fully_trusted")
        git(cls.clone, "init", "-q", "-b", "main")
        git(cls.clone, "remote", "add", "origin", str(cls.origin))
        git(cls.clone, "add", "-A")
        git(cls.clone, "commit", "-q", "-m", "seed")
        git(cls.clone, "push", "-q", "-u", "origin", "main")  # no hook yet
        git(cls.clone, "config", "core.hooksPath", ".githooks")
        git(cls.clone, "worktree", "add", "-q", "-b", "feature", str(cls.wt))
        cls.base = git(cls.wt, "rev-parse", "HEAD").stdout.strip()

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    # --- helpers -------------------------------------------------------------------------------

    @property
    def config_path(self):
        return self.clone / ".git" / "config"

    def assert_repo_intact(self, before):
        self.assertEqual(self.config_path.read_bytes(), before, ".git/config changed")
        self.assertEqual(git(self.clone, "config", "--get", "core.bare").stdout.strip(), "false")
        unset = git(self.clone, "config", "--get", "core.worktree", check=False)
        self.assertNotEqual(unset.returncode, 0, "core.worktree is set")
        for cwd in (self.clone, self.wt):
            git(cwd, "status", "--porcelain")  # raises when git status fails there

    def hook(self, stdin):
        return run(self.wt, ".githooks/pre-push", "origin", str(self.origin), check=False, stdin=stdin)

    def line(self, ref, sha):
        return f"{ref} {sha} {ref} {ZERO}\n"

    def head(self):
        return git(self.wt, "rev-parse", "HEAD").stdout.strip()

    def setUp(self):
        self.before = self.config_path.read_bytes()
        git(self.wt, "reset", "-q", "--hard", self.base)
        git(self.wt, "clean", "-fdq")

    def tearDown(self):
        self.assert_repo_intact(self.before)

    # --- the main case ---------------------------------------------------------------------------

    def test_push_from_linked_worktree_runs_the_real_hook(self):
        probe = self.wt / "scripts" / "hook_probe.txt"
        probe.write_text("a scripts-only change\n")
        # A test of the temporary clone that prepush.sh discovers: it fails when git's repository-local
        # variables (GIT_DIR...) reach the tests, as they do when prepush.sh stops clearing them.
        # (Renames clears them itself, so on its own it would not notice.)
        (self.wt / ".github" / "ci" / "test_zz_hook_env.py").write_text(PROBE)
        git(self.wt, "add", "scripts/hook_probe.txt", ".github/ci/test_zz_hook_env.py")
        git(self.wt, "commit", "-q", "-m", "probe")
        out = git(self.wt, "push", "origin", "feature", check=False)
        self.assertEqual(out.returncode, 0, out.stdout + out.stderr)
        # The hook really ran prepush.sh.
        self.assertIn("prepush: OK", out.stdout + out.stderr)
        remote = git(self.origin, "rev-parse", "refs/heads/feature").stdout.strip()
        self.assertEqual(remote, self.head())

    # --- refusals and the deletion --------------------------------------------------------------------

    def test_dirty_tracked_file_is_refused(self):
        (self.wt / "README.md").write_text("dirty\n")
        out = git(self.wt, "push", "origin", "feature:dirty", check=False)
        self.assertNotEqual(out.returncode, 0)
        self.assertIn("uncommitted changes", out.stderr)
        self.assertNotEqual(git(self.origin, "rev-parse", "--verify", "-q", "refs/heads/dirty",
                                check=False).returncode, 0)

    def test_untracked_file_is_refused(self):
        (self.wt / "stray.txt").write_text("x\n")
        res = self.hook(self.line("refs/heads/feature", self.head()))
        self.assertEqual(res.returncode, 1)
        self.assertIn("untracked files", res.stderr)
        self.assertIn("stray.txt", res.stderr)

    def test_a_ref_that_is_not_head_is_refused(self):
        main = git(self.wt, "rev-parse", "main").stdout.strip()
        git(self.wt, "commit", "-q", "--allow-empty", "-m", "ahead")
        self.assertNotEqual(main, self.head())
        res = self.hook(self.line("refs/heads/main", main))
        self.assertEqual(res.returncode, 1)
        self.assertIn("not the checked-out commit", res.stderr)

    def test_deletion_only_push_is_allowed(self):
        (self.wt / "stray.txt").write_text("not even checked\n")
        res = self.hook(f"(delete) {ZERO} refs/heads/gone abc\n")
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertEqual(res.stderr, "")


if __name__ == "__main__":
    unittest.main()
