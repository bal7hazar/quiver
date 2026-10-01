# [fable] Review — ARC-07b achievement 0.2.0 (second review, after fix loop 1)

## Verdict
PASS

## Revision
`66ae1c890417bdd70bc869b08b772c29d9edfbfe`, compared with `origin/main`

## Findings
No findings. Both findings of the first review are closed, and the fix-loop changes introduce nothing new.

| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| — | — | — | None | — | — |

**Finding 1 of the first review (minor, no test told `DEFINITION` from `REPORTER`): closed.**
- `tests/test_component_track_own.cairo` runs the component under two consumer-written impls, `MockTrackDefinitionOnly` and `MockTrackReporterOnly` (`tests/mocks.cairo`).
- I reproduced the claim of `GAS.md` ("Fix loop 1"): with the two constants swapped in `src/store.cairo`, the package run gives `136 passed, 2 failed`.
- The two failures are exactly `own_impl_tracks_the_definition_only` and `own_impl_tracks_the_reporter_only`, both on `spy.get_events().events.len() == 0`.

**Finding 2 of the first review (note, `DefinitionTrait::is_active` untested): closed.**
- `models::definition::tests::definition_is_active_inside_and_outside_its_window` checks both bounds of a closed window (99, 100, 199, 200) and an open-ended one (99, `u64` max).
- It passes at 25 640 against a budget of 26 922.

## Coverage

**Read**
- The brief, and the fix-loop diff `ef4e3a8..HEAD` in full: `models/definition.cairo`, `tests/mocks.cairo`, `tests/test_component_track_own.cairo`, `GAS.md`.
- With a fresh eye, the sources of the whole pull request: `store.cairo`, `component.cairo`, `models/{index,definition,status,reporter}.cairo`, `events/{index,defined}.cairo`, `types/{window,batch}.cairo`, `helpers/bits.cairo`.
- The diffs of `interface.cairo`, `errors.cairo` and `constants.cairo`.
- Tests and documents: `tests/mock_tracking.cairo`, `tests/test_tracking.cairo`, `tests/test_store_models.cairo`, `tests/test_component_track_none.cairo`, `README.md`, `CHANGELOG.md` `[0.2.0]`, and the hand-written sections of `GAS.md`.
- Compared with 0.1.0 (`origin/main:packages/achievement/src/logic/{batch,types}.cairo`): the batch merge, the packing and the entrypoints' order of checks are unchanged, apart from `points` in bits [196, 212) of slot A; bits from 212 up are still rejected on unpacking.

**Ran**
- `scripts/lock.sh snforge test` at the workspace root: `648 passed, 0 failed`.
- `scripts/lock.sh snforge test --package quiver_achievement`: `138 passed, 0 failed` (83 in `tests/`, 55 in `src/`), which is 102 + 36 as `GAS.md` states.
- The three new tests measure 1 516 920, 1 469 300 and 25 640; their budgets (1 592 766, 1 542 765, 26 922) are the 1.05 ceiling, and their rows are in `GAS.md`, which has 138 generated rows.
- The store-against-hand tracking benchmarks are equal to the unit in my run, for the six pairs of `GAS.md`.
- `scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check`: no output.
- The mutation check above was a temporary edit of `src/store.cairo` in my worktree, reverted; `git status --short` and `git diff --stat` are empty afterwards.
- `gh pr checks feat/ARC-07b-achievement-0.2.0`: `affected`, `cairo`, `links`, `package (packages/achievement)`, `package (packages/quest)` and `scripts` all pass.

**Could not check**
- `scripts/gas.py packages/achievement --check` and `python3 .github/ci/check-links.py` were refused by my permission profile. The pull request's own checks pass; I did not confirm which job runs the gas check, nor that the run is on `66ae1c8`.
- `docs/BUDGETS.md` and the ARC-01 and ARC-06 research amendments were not re-read line by line; fix loop 1 did not touch them.
- The build and test times asked by AC-5 are in the task's report, not in the diff; not re-measured.
