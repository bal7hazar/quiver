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
Running 1 test(s) from tests/
[PASS] quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones (l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~13720)
Running 0 test(s) from src/
Tests: 1 passed, 0 failed, 0 ignored, 0 filtered out
"""

# Real output of the same test with `#[available_gas(l2_gas: 1)]`.
SNFORGE_FAIL = """\
Collected 1 test(s) from quiver_quest package
Running 1 test(s) from tests/
[FAIL] quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones

Failure data:
\tTest cost exceeded the available gas. Consumed l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~13720
Running 0 test(s) from src/
Tests: 0 passed, 1 failed, 0 ignored, 0 filtered out

Failures:
    quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones
"""

PATH = "quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones"
NAME = "test_constants::quest_bounds_are_the_accepted_ones"


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


class ParseBudgets(unittest.TestCase):
    def test_budget_after_test(self):
        src = "#[test]\n#[available_gas(l2_gas: 14406)]\nfn a() {}\n"
        self.assertEqual(gas.parse_budgets(src), {"a": 14406})

    def test_budget_before_test(self):
        src = "#[available_gas(l2_gas: 5)]\n#[test]\nfn a() {}\n"
        self.assertEqual(gas.parse_budgets(src), {"a": 5})

    def test_no_budget(self):
        self.assertEqual(gas.parse_budgets("#[test]\nfn a() {}\n"), {"a": None})

    def test_not_a_test(self):
        self.assertEqual(gas.parse_budgets("#[inline]\nfn helper() {}\nfn other() {}\n"), {})

    def test_budget_does_not_leak_to_next_test(self):
        src = "#[test]\n#[available_gas(l2_gas: 7)]\nfn a() {}\n\n#[test]\nfn b() {}\n"
        self.assertEqual(gas.parse_budgets(src), {"a": 7, "b": None})


class Check(unittest.TestCase):
    def run_check(self, measured, budget, table=None):
        table = [(NAME, measured, budget)] if table is None else table
        return gas.check("quest", {PATH: measured}, {"quest_bounds_are_the_accepted_ones": budget}, table)

    def test_ceil_margin(self):
        self.assertEqual(gas.ceil_margin(13720), 14406)
        self.assertEqual(gas.ceil_margin(100), 105)
        self.assertEqual(gas.ceil_margin(1), 2)

    def test_within_budget(self):
        self.assertEqual(self.run_check(13720, 14406), [])
        self.assertEqual(self.run_check(13720, 13720), [])

    def test_below_measured(self):
        problems = self.run_check(13720, 13719)
        self.assertEqual(len(problems), 1)
        self.assertIn("below", problems[0])
        self.assertIn("quest_bounds_are_the_accepted_ones", problems[0])

    def test_above_margin(self):
        problems = self.run_check(13720, 14407)
        self.assertEqual(len(problems), 1)
        self.assertIn("above", problems[0])

    def test_no_budget(self):
        problems = gas.check("quest", {PATH: 10}, {}, [(NAME, 10, 11)])
        self.assertTrue(any("no #[available_gas" in p for p in problems))

    def test_gas_md_disagrees(self):
        self.assertTrue(any("GAS.md says" in p for p in self.run_check(13720, 14406, [(NAME, 1, 2)])))

    def test_gas_md_missing_row(self):
        self.assertTrue(any("missing from GAS.md" in p for p in self.run_check(13720, 14406, [])))

    def test_gas_md_stale_row(self):
        table = [(NAME, 13720, 14406), ("old::gone", 1, 2)]
        self.assertTrue(any("no longer measured" in p for p in self.run_check(13720, 14406, table)))


class GasMd(unittest.TestCase):
    def test_render_then_parse(self):
        md = gas.render("quiver_quest", {PATH: 13720}, {"quest_bounds_are_the_accepted_ones": 14406},
                        "2026-09-28", "abc1234")
        self.assertEqual(gas.parse_table(md), [(NAME, 13720, 14406)])
        self.assertIn("2026-09-28", md)
        self.assertIn("abc1234", md)

    def test_short_name(self):
        self.assertEqual(gas.short_name(PATH), NAME)


if __name__ == "__main__":
    unittest.main()
