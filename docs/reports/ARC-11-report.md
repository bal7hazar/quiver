# [Sonnet 5.5] ARC-11 — gas.py keeps GAS.md sections

## Summary
`scripts/gas.py <pkg> --write` now regenerates only the generated part of `GAS.md` (header and table) and keeps, byte for byte, everything after the table. No file under `packages/` is changed.

How the boundary is found (`gas.hand_written`): the generated table starts at the line beginning `| Test |` (the header `render()` writes) and runs over the consecutive lines that start with `|`. Everything from the line after the last table row is the hand-written part. In both packages that is a blank line then `## Scarb 2.20.1 and snforge 0.64.0 (ARC-10, D-180)` and the later sections. No `| Test |` line, an empty file, or a missing file gives "" (as before). A `| Test |` table inside the hand-written part is not mistaken for the generated one, since only the first table counts.

## Files changed
- `scripts/gas.py`: `hand_written()`, `TABLE_HEAD`, `--write` appends the kept tail; docstring.
- `scripts/test_gas.py`: class `KeepsHandWrittenSections` (5 tests).
- `docs/WORKSPACE.md`: describes `--write`'s behaviour.
- `docs/reports/ARC-11-report.md`: this report.

## Commands run
- `python3 -m unittest scripts/test_gas.py`: `Ran 38 tests ... OK`.
- `python3 scripts/gas.py packages/quest --write`: `quiver_quest: wrote packages/quest/GAS.md (512 tests)`.
- `python3 scripts/gas.py packages/achievement --write`: `quiver_achievement: wrote packages/achievement/GAS.md (145 tests)`.
- `git diff --stat packages/` afterwards: quest 1024 lines (512+/512-), achievement 290 lines (145+/145-), see Deviations. Then `git checkout -- packages/`; `git status` clean.
- `python3 scripts/gas.py packages/quest --check`: `512 tests within budget, GAS.md up to date`; achievement: `145 tests within budget, GAS.md up to date`.

## Cost
—

## Acceptance criteria
- AC-1: met; boundary above; hand-written sections survived the real `--write` of both packages (the diff touched only table rows).
- AC-2: met; tests for sections kept, only-generated file, missing file / no table, table updated when figures change, and a table inside the sections. 38 tests pass.
- AC-3: partly. No figure, budget, test name or hand-written line moved. But `git diff --stat packages/` was not empty: the `Commit` column of every table row changed, because `--write` records `git rev-parse --short HEAD`, and HEAD on this branch is the ARC-11 commit, not the `04091f9` the pins carry (a run on the commit that produced the pins would be empty). I reverted, nothing committed. `--check` passes for both.
- AC-4: met; `--check` code is untouched.
- AC-5: met; `gh pr checks 41`: all pass (package quest, package achievement, scripts, affected, cairo, links) at 3701d12.

## Deviations from the task
The AC-3 diff is not empty for the reason above (commit column only, an artefact of running on a branch with a new commit).

## Escalations
None. Consider whether `--write` should keep a row's Commit column when its figures are unchanged; out of scope here.
