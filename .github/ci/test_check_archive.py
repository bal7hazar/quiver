import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import check_archive as c  # noqa: E402

LISTING = "q-1.0.0/\nq-1.0.0/Scarb.toml\nq-1.0.0/LICENSE\nq-1.0.0/src/lib.cairo\n"


class MissingLicense(unittest.TestCase):
    def test_present(self):
        self.assertFalse(c.missing_license(LISTING, "q", "1.0.0"))

    def test_absent(self):
        self.assertTrue(c.missing_license(LISTING.replace("LICENSE", "README.md"), "q", "1.0.0"))

    def test_other_version_or_path_does_not_count(self):
        self.assertTrue(c.missing_license(LISTING, "q", "1.0.1"))
        self.assertTrue(c.missing_license("q-1.0.0/docs/LICENSE\nq-1.0.0/LICENSE.md\n", "q", "1.0.0"))

    def test_empty_listing(self):
        self.assertTrue(c.missing_license("", "q", "1.0.0"))


if __name__ == "__main__":
    unittest.main()
