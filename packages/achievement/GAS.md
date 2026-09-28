# Gas of `quiver_achievement`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_achievement_integrationtest::test_constants::achievement_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-28 | 13f6efb |
