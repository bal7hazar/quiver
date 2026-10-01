# [fable] Review — ARC-07b achievement 0.2.0

## Verdict
PASS WITH FINDINGS

## Revision
`ef4e3a8259b1a961a64022a2357080e34a2c073f`, compared with `origin/main` (`git diff origin/main...HEAD`)

## Findings

| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | minor | `packages/achievement/src/store.cairo:125` and `:164`; `README.md`, "Tracking: the consumer's choice", third row; `tests/` | No test tells `DEFINITION` from `REPORTER`, and the documented "impl of its own" is never compiled. | `TrackAll` sets both constants true and `TrackNone` both false, and those are the only impls of `AchievementTracking` in the repository. If `set_definition` tested `Tracking::REPORTER` and `set_reporter` tested `Tracking::DEFINITION`, all 135 tests and the six tracking benchmarks would still pass. The code is correct as written; the gap is in the tests. Found by reading, not by running the mutation. `quiver_quest` 0.2.0 has the same gap. | Add a mock with its own impl (`DEFINITION = true, REPORTER = false`) and its mirror, and assert that `define` emits `AchievementDefined` while `set_reporter` emits nothing, and the reverse. |
| 2 | note | `packages/achievement/src/models/definition.cairo:90` | `DefinitionTrait::is_active` is new and public, and no test calls it. | The only `is_active` calls in the package are on `AchievementWindow` (`types/window.cairo`, `window_is_active_bounds`). It is a one-line delegate to the window. | Add one assertion in `models::definition::tests`. |

Nothing else found. The points I checked against the brief:

- **Behaviour kept.** `define` checks id, window, tasks, then "already defined", in 0.1.0's order; `retire` and the view keep their order and strings; the merge code is 0.1.0's, moved into `BatchTrait`.
- **Events kept.** The four structs and the `Event` enum variants are unchanged and still exported from `AchievementComponent`. `AchievementDefined` is built from the model.
- **Layout.** `points` sits in slot A [196, 212). Unpacking rejects any bit in [212, 252) (`achievement_unpacking_rejects_bit_212`, `_bit_251`). A slot written by 0.1.0 reads `points` 0, and the CHANGELOG says so, along with the view's extra felt.
- **Status shares slot A.** `retire` reads A once and writes it back whole. `status_retire_keeps_the_definition_bits` and `status_never_emits` cover it with `points` 25.
- **Tests kept.** All 102 test names of 0.1.0 are present in the new `GAS.md` table (one renamed, bit 196 → 212), plus 33 new: 54 in `src/`, 81 in `tests/`.
- **Budgets.** One budget is raised, `achievement_packing_round_trip_definition`, with its `// gas: raised` note. Every other budget is equal or lower.
- **Figures.** Every call figure in `GAS.md`, `README.md`, `CHANGELOG.md`, `docs/BUDGETS.md`, ARC-01 and ARC-06 §8 recomputes from the table rows, including the network estimates and the 92.1 %.
- **No free function** in `src/` outside traits; the constant tables in `helpers::bits` carry their written reason.

## Coverage

**Read:**
- the brief;
- the whole diff of `packages/achievement/src/` and `tests/`;
- the 0.1.0 `logic/` files on `origin/main`, for comparison;
- `GAS.md` at both revisions;
- the diffs of `README.md`, `CHANGELOG.md`, `docs/BUDGETS.md`, ARC-01 and ARC-06;
- `scripts/gas.py` (its parser handles `mod tests` in `src/`);
- `docs/CAIRO.md` §2, §7, §8;
- `quiver_quest`'s models, store and tests, for shape and names;
- the pull request's description.

**Ran:** nothing from the package locally. `scripts/lock.sh` fails on this machine (`nice: flock: No such file or directory`), and plain `scarb` and `snforge` commands were refused by my permissions. I did not work around either.

**Relied on instead:** the pull request's CI at this same head, where all six checks succeeded. `cairo.yml` runs `scarb fmt --check`, `snforge test` and `scripts/gas.py --check` for the package. I could not read the job log (`gh run view --log` returned nothing), so the 135-test count comes from `GAS.md` and the sources, not from snforge's summary line.

**Could not check:**
- finding 1 by mutation;
- the store-equals-hand tracking figures by my own run;
- the build and test times and the `gas.py` demonstration that AC-5 asks for, since `REPORT.md` is not in the diff.
