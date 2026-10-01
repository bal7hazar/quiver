#!/usr/bin/env python3
"""Unit tests of scripts/gas.py: `python3 -m unittest scripts/test_gas.py`."""

import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import gas  # noqa: E402

# Real output of `snforge test` 0.61.0 (packages/quest, 2026-09-28), a passing run.
SNFORGE_PASS = """\
   Compiling test(quiver_quest_unittest) quiver_quest v0.1.0 (/x/packages/quest/Scarb.toml)
   Compiling test(quiver_quest_integrationtest) quiver_quest_integrationtest v0.1.0 (/x/packages/quest/Scarb.toml)
warn: external contracts not found for selectors: `quiver_quest::*`
    Finished `dev` profile target(s) in 1 second


Collected 1 test(s) from quiver_quest package
Running 1 test(s) from src/
[PASS] quiver_quest::constants::tests::quest_bounds_are_the_accepted_ones (l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~13720)
Running 0 test(s) from tests/
Tests: 1 passed, 0 failed, 0 ignored, 0 filtered out
"""

# Real output of the same test with `#[available_gas(l2_gas: 1)]`.
SNFORGE_FAIL = """\
Collected 1 test(s) from quiver_quest package
Running 1 test(s) from src/
[FAIL] quiver_quest::constants::tests::quest_bounds_are_the_accepted_ones

Failure data:
\tTest cost exceeded the available gas. Consumed l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~13720
Running 0 test(s) from tests/
Tests: 0 passed, 1 failed, 0 ignored, 0 filtered out

Failures:
    quiver_quest::constants::tests::quest_bounds_are_the_accepted_ones
"""

PKG = "quiver_quest"
IT = "quiver_quest_integrationtest"
PATH = PKG + "::constants::tests::quest_bounds_are_the_accepted_ones"
SUMMARY_OK = (1, 0, 0, 0)


class ParseSnforge(unittest.TestCase):
    def test_passing_run(self):
        self.assertEqual(gas.parse_snforge_output(SNFORGE_PASS), ({PATH: 13720}, []))

    def test_failing_run(self):
        self.assertEqual(gas.parse_snforge_output(SNFORGE_FAIL), ({}, [PATH]))

    def test_several_tests(self):
        text = (
            "[PASS] p::a::one (l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~10)\n"
            "[PASS] p::a::two (l1_gas: ~0, l1_data_gas: ~64, l2_gas: ~2000000)\n"
        )
        self.assertEqual(gas.parse_snforge_output(text)[0], {"p::a::one": 10, "p::a::two": 2000000})

    def test_no_test(self):
        self.assertEqual(gas.parse_snforge_output("Tests: 0 passed"), ({}, []))


class Summary(unittest.TestCase):
    def test_real_output(self):
        self.assertEqual(gas.parse_summary(SNFORGE_PASS), (1, 0, 0, 0))
        self.assertEqual(gas.parse_summary(SNFORGE_FAIL), (0, 1, 0, 0))

    def test_ignored_and_filtered(self):
        line = "Tests: 3 passed, 0 failed, 2 ignored, 4 filtered out"
        self.assertEqual(gas.parse_summary(line), (3, 0, 2, 4))

    def test_missing(self):
        self.assertIsNone(gas.parse_summary("nothing"))


class ParseTests(unittest.TestCase):
    def test_budget_after_test(self):
        src = "#[test]\n#[available_gas(l2_gas: 14406)]\nfn a() {}\n"
        self.assertEqual(gas.parse_tests(src, IT + "::m"), {IT + "::m::a": (14406, False)})

    def test_budget_before_test(self):
        src = "#[available_gas(l2_gas: 5)]\n#[test]\nfn a() {}\n"
        self.assertEqual(gas.parse_tests(src, "p"), {"p::a": (5, False)})

    def test_no_budget(self):
        self.assertEqual(gas.parse_tests("#[test]\nfn a() {}\n", "p"), {"p::a": (None, False)})

    def test_ignored(self):
        src = "#[test]\n#[ignore]\n#[available_gas(l2_gas: 5)]\nfn a() {}\n"
        self.assertEqual(gas.parse_tests(src, "p"), {"p::a": (5, True)})

    def test_not_a_test(self):
        self.assertEqual(gas.parse_tests("#[inline]\nfn helper() {}\nfn other() {}\n", "p"), {})

    def test_budget_does_not_leak_to_next_test(self):
        src = "#[test]\n#[available_gas(l2_gas: 7)]\nfn a() {}\n\n#[test]\nfn b() {}\n"
        self.assertEqual(gas.parse_tests(src, "p"), {"p::a": (7, False), "p::b": (None, False)})

    def test_inline_modules_extend_the_path(self):
        src = (
            "fn helper() { if true { } }\n"
            "#[cfg(test)]\nmod tests {\n    #[test]\n    #[available_gas(l2_gas: 9)]\n"
            "    fn a() { if true { } }\n}\n#[test]\nfn top() {}\n"
        )
        self.assertEqual(
            gas.parse_tests(src, PKG),
            {PKG + "::tests::a": (9, False), PKG + "::top": (None, False)},
        )

    def test_file_prefix(self):
        d = pathlib.Path("packages/quest")
        self.assertEqual(gas.file_prefix(PKG, d, d / "src/lib.cairo"), PKG)
        self.assertEqual(gas.file_prefix(PKG, d, d / "src/logic/page.cairo"), PKG + "::logic::page")
        self.assertEqual(gas.file_prefix(PKG, d, d / "tests/test_x.cairo"), IT + "::test_x")

    def test_the_real_test_matches_snforge_name(self):
        src = pathlib.Path(__file__).resolve().parent.parent / "packages/quest"
        tests = gas.read_tests(PKG, src)
        self.assertIn(PATH, tests)


class Check(unittest.TestCase):
    def run_check(self, measured, budget, table=None, summary=SUMMARY_OK):
        table = [(PATH, measured, budget)] if table is None else table
        return gas.check("quest", {PATH: measured}, {PATH: (budget, False)}, table, summary)

    def test_ceil_margin(self):
        self.assertEqual(gas.ceil_margin(13720), 14406)
        self.assertEqual(gas.ceil_margin(100), 105)
        self.assertEqual(gas.ceil_margin(1), 2)

    def test_within_budget(self):
        self.assertEqual(self.run_check(13720, 14406), [])
        self.assertEqual(self.run_check(13720, 13720), [])

    def test_below_measured(self):
        problems = self.run_check(13720, 13719)
        self.assertIn("below", problems[0])
        self.assertIn("quest_bounds_are_the_accepted_ones", problems[0])

    def test_above_margin(self):
        self.assertIn("above", self.run_check(13720, 14407)[0])

    def test_no_budget(self):
        tests = {PATH: (None, False)}
        problems = gas.check("quest", {PATH: 10}, tests, [(PATH, 10, 11)], SUMMARY_OK)
        self.assertTrue(any("no #[available_gas" in p for p in problems))

    def test_gas_md_disagrees(self):
        problems = self.run_check(13720, 14406, [(PATH, 1, 2)])
        self.assertTrue(any("GAS.md says" in p for p in problems))

    def test_gas_md_missing_row(self):
        self.assertTrue(any("missing from GAS.md" in p for p in self.run_check(13720, 14406, [])))

    def test_gas_md_stale_row(self):
        table = [(PATH, 13720, 14406), ("old::gone", 1, 2)]
        self.assertTrue(any("no longer measured" in p for p in self.run_check(13720, 14406, table)))

    def test_same_name_in_two_modules_one_without_budget_fails(self):
        a, b = IT + "::a::same", IT + "::b::same"
        tests = {a: (105, False), b: (None, False)}
        table = [(a, 100, 105), (b, 100, 105)]
        problems = gas.check("quest", {a: 100, b: 100}, tests, table, (2, 0, 0, 0))
        self.assertTrue(any(b in p and "no #[available_gas" in p for p in problems))
        self.assertFalse(any(a in p and "no #[available_gas" in p for p in problems))

    def test_ignored_test_fails_and_is_named(self):
        ignored = IT + "::m::skipped"
        tests = {PATH: (14406, False), ignored: (14406, True)}
        table = [(PATH, 13720, 14406)]
        problems = gas.check("quest", {PATH: 13720}, tests, table, (1, 0, 1, 0))
        self.assertTrue(any(ignored in p and "#[ignore]d" in p for p in problems))
        self.assertTrue(any("ignored 1" in p for p in problems))

    def test_test_without_a_measure_fails_and_is_named(self):
        missing = IT + "::m::filtered"
        tests = {PATH: (14406, False), missing: (14406, False)}
        table = [(PATH, 13720, 14406)]
        problems = gas.check("quest", {PATH: 13720}, tests, table, (1, 0, 0, 1))
        self.assertTrue(any(missing in p and "no measured result" in p for p in problems))
        self.assertTrue(any("filtered out 1" in p for p in problems))

    def test_measured_test_absent_from_sources_fails(self):
        problems = gas.check("quest", {PATH: 13720}, {}, [(PATH, 13720, 14406)], SUMMARY_OK)
        self.assertTrue(any("not found in the sources" in p for p in problems))

    def test_no_summary_fails(self):
        self.assertTrue(any("summary" in p for p in self.run_check(13720, 14406, summary=None)))


class GasMd(unittest.TestCase):
    def test_render_then_parse(self):
        md = gas.render("quiver_quest", {PATH: 13720}, {PATH: (14406, False)}, "2026-09-28", "abc1234")
        self.assertEqual(gas.parse_table(md), [(PATH, 13720, 14406)])
        self.assertIn("2026-09-28", md)
        self.assertIn("abc1234", md)


if __name__ == "__main__":
    unittest.main()
