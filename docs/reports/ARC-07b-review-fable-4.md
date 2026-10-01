# [fable] Review — ARC-07b, `quiver_achievement` 0.2.0 (after fix loop 3)

## Verdict
PASS

## Revision
`970cff18687d8b197309839d29e780648ceb4a23`, compared with `origin/main` (`bc506856693612e8ad69fb8f46180316f20451cd`, which is also the merge base)

## Findings
None. The three findings of the previous review (`cbd420d`) are closed and the new changes hold.

| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

How each previous finding is closed:

1. **(was minor) `GAS.md`, "Fix loop 2" table.** The `define` columns now subtract `baseline_deployed`, as the rest of the file does.
   - Against this run: `bench_define_worst` 1 988 240 − `baseline_deployed` 789 600 = 1 198 640, and `bench_define_one_task` 1 492 870 − 789 600 = 703 270.
   - Both equal the "0.2.0" column of "Every entrypoint, before and after".
   - Each of the eight corrected cells moved by exactly 607 410, which is `baseline_reporter_registered` − `baseline_deployed`, so the by-`@` deltas (+100) are intact.
   - The `retire` (243 330) and view (217 740) columns are unchanged and correct against `baseline_defined` 1 987 950.
2. **(was note) `models/status.cairo:66-67`.** The comment now reads "by value costs the same on every entrypoint", and `GAS.md` records the one unit test that is dearer (`status_retire_keeps_the_definition_bits`, 27 080 → 27 480, budget 28 434). This run measures 27 480.
3. **(was note) `BitsTrait::split` had no unit test.** `helpers/bits.cairo:167-185` adds two.
   - `split_both_limbs` uses distinct limbs, so a swapped `(high, low)` would fail. Its high limb is `0x7` followed by 30 `f`, which is 2^123 − 1, so the value stays below 2^251 and the comment is accurate.
   - `split_high_limb_zero` covers a full low limb of 2^128 − 1 with high 0, and the value 0.
   - Their budgets are `ceil(1.05 × measured)`: 17 450 → 18 323 and 17 480 → 18 354.

## Coverage
**Read**
- `git diff cbd420d..HEAD` in full: `helpers/bits.cairo`, `models/status.cairo`, `GAS.md`, and the `PLAN.md` / `STATUS.md` changes of the merge.
- The whole of `bits.cairo`, `status.cairo` and `GAS.md` at HEAD, and the allowlist and done-criteria lines of the brief.
- `git diff --stat e93874f..970cff1` confirms the merge of main touches only `PLAN.md` and `STATUS.md`.
- A word-level diff of `GAS.md` shows that, in the generated table, only the Commit column (`00d6923` → `e32dc39`) and the two new `split_*` rows changed; no measure or budget moved.
- The table has 145 rows, matching 102 kept + 43 new.

**Ran**
- `snforge test --package quiver_achievement`: `Tests: 145 passed, 0 failed, 0 ignored, 0 filtered out` (83 from `tests/`, 62 from `src/`). I compared every measure in that output with the generated table of `GAS.md` by hand: all 145 match.
- `scarb fmt --check --package quiver_achievement`: no output, clean.
- `git status --short` afterwards: clean.

**Could not check**
- `scripts/gas.py packages/achievement --check` was refused by the permission system of this session, so I did not run it. The hand comparison covers the measures, and every test passed under its `#[available_gas]`. The "never above `ceil(1.05 × measured)`" rule I verified by hand only for the two new tests.
- The by-`@` variant rows of the fix-loop-2 table (+100 / +200) cannot be re-measured without changing the code. I checked their arithmetic only.
- Everything outside fix loop 3 was not re-reviewed, as instructed.
