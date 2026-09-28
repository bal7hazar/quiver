#!/usr/bin/env python3
"""Unit tests of release_check.py: `python3 -m unittest discover -s .github/ci`."""

import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import release_check as r  # noqa: E402

MANIFEST = '[package]\nname = "quiver_quest"\nversion = "0.1.0"\n\n[dependencies]\nversion = "9"\n'


class Tag(unittest.TestCase):
    def test_good(self):
        self.assertEqual(r.parse_tag("quiver_quest-v0.1.0"), ("quiver_quest", "quest", "0.1.0"))
        self.assertEqual(r.parse_tag("quiver_a_b-v10.20.30")[1], "a_b")

    def test_bad(self):
        for bad in ["quest-v0.1.0", "quiver_quest-0.1.0", "quiver_quest-v0.1", "quiver_-v0.1.0",
                    "quiver_quest-v0.1.0-rc1", "quiver_../x-v0.1.0", "quiver_Quest-v0.1.0"]:
            with self.assertRaises(ValueError, msg=bad):
                r.parse_tag(bad)


class Check(unittest.TestCase):
    def package(self, root, manifest=MANIFEST, changelog="## [Unreleased]\n\n## [0.1.0] - 2026-10-01\n"):
        directory = pathlib.Path(root) / "packages" / "quest"
        directory.mkdir(parents=True)
        (directory / "Scarb.toml").write_text(manifest)
        if changelog is not None:
            (directory / "CHANGELOG.md").write_text(changelog)

    def test_consistent(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root)
            self.assertEqual(r.check("quiver_quest-v0.1.0", root), ("packages/quest", "0.1.0"))

    def test_version_differs(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root)
            with self.assertRaisesRegex(ValueError, "manifest says version 0.1.0"):
                r.check("quiver_quest-v0.2.0", root)

    def test_version_of_another_table_is_not_read(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root, manifest=MANIFEST.replace('version = "0.1.0"', 'version = "0.3.0"'))
            with self.assertRaises(ValueError):
                r.check("quiver_quest-v9", root)

    def test_no_changelog_section(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root, changelog="## [Unreleased]\n")
            with self.assertRaisesRegex(ValueError, "no section"):
                r.check("quiver_quest-v0.1.0", root)

    def test_no_changelog_file(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root, changelog=None)
            with self.assertRaisesRegex(ValueError, "no section"):
                r.check("quiver_quest-v0.1.0", root)

    def test_no_such_package(self):
        with tempfile.TemporaryDirectory() as root:
            with self.assertRaisesRegex(ValueError, "no package"):
                r.check("quiver_quest-v0.1.0", root)

    def test_name_mismatch(self):
        with tempfile.TemporaryDirectory() as root:
            self.package(root, manifest=MANIFEST.replace("quiver_quest", "other"))
            with self.assertRaisesRegex(ValueError, "not the package"):
                r.check("quiver_quest-v0.1.0", root)


if __name__ == "__main__":
    unittest.main()
