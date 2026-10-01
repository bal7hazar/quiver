# [fable] Review — ARC-07b achievement 0.2.0 (third review, fix loop 2)

## Verdict
PASS WITH FINDINGS

## Revision
`cbd420da693b50b6bf47523a49db0a47de36ff64`, compared with `origin/main` (fix loop 2 read as `66ae1c8..HEAD`)

## Findings
| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | minor | `packages/achievement/GAS.md:272-277` (table "Fix loop 2") | The two `define` columns are not "the call minus its baseline" as the heading says. They subtract `baseline_reporter_registered` instead of `baseline_deployed`, so they contradict the same file's entrypoint table and `docs/BUDGETS.md`. The deltas (+100 by `@`) and the conclusion are unaffected. | My run: `bench_define_worst` 1 988 240, `bench_define_one_task` 1 492 870, `baseline_deployed` 789 600, `baseline_reporter_registered` 1 397 010. Both benchmarks call `deploy()` only (`tests/test_component_bench.cairo:122-135`), so the calls are 1 198 640 and 703 270, as `GAS.md:196-197` and `BUDGETS.md:200-201` state. The table gives 591 230 and 95 860, which are 1 988 240 − 1 397 010 and 1 492 870 − 1 397 010. `docs/CAIRO.md` §6.6 asks that the gas table match a re-run. | Write 1 198 640 / 1 198 740 for 3 tasks and 703 270 / 703 370 for 1 task in the four rows. |
| 2 | note | `packages/achievement/src/models/status.cairo:66-67`; `GAS.md:280` | "By value costs the same (measured)" holds on the entrypoints but not everywhere: the unit test of the same file costs 400 more with `StatusStorage` by `@`. The fix loop 2 section does not mention it. The budget is still valid (28 434, between 27 480 and its ceiling 28 854). | `status_retire_keeps_the_definition_bits`: 27 080 at `66ae1c8` (`GAS.md:44` there), 27 480 at HEAD (`GAS.md:49` and my run). Its body is unchanged; only the two signatures changed. Entrypoints confirmed unchanged by my run: `retire` 243 330, `define` 1 198 640, view 217 740. | Say "costs the same on every entrypoint" in the comment and name the +400 of the unit test in the section. |
| 3 | note | `packages/achievement/src/helpers/bits.cairo:91-166` | The new tests cover every constant of the module, but not `BitsTrait::split`, its only function. It is exercised only through the definition's packing tests in `models/definition.cairo`. | The `tests` module imports the 15 constants and nothing else; no test calls `BitsTrait::split`. | One test of `split` on a felt with both limbs set, in this module. |

No defect found in the code of fix loop 2 itself:
- **Status signatures:** `status(self: @HeadSlot, ..)` and `into_slot(self: @AchievementStatus, ..)` match `quiver_quest`, and every call site (`store.cairo:135,145`, `component.cairo:103,156`) compiles and behaves as before.
- **Bits tests:** they compare all 128 entries of `POW2`, the 9 `TWO_POW_*` and the 5 `NZ_*` against independently computed values.
- **Reporter tests:** they cover the allowed case and the refusal with `'Achievement: not reporter'`.
- **Doc comment:** `tests/helpers.cairo` now names `BatchTrait::merge`.

## Coverage
**Read:**
- the brief;
- `git diff 66ae1c8..HEAD` for `src/` and `tests/` in full;
- `models/status.cairo`, `models/reporter.cairo` and `helpers/bits.cairo` whole;
- the call sites in `store.cairo` and `component.cairo`;
- `quiver_quest`'s `models/status.cairo` for the comparison;
- the hand-written sections of `GAS.md`, the changed rows of its generated table, and the achievement tables of `docs/BUDGETS.md`;
- `tests/test_component_bench.cairo` (setups and baselines).

**Ran:**
- `scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build`: finished in 7 seconds.
- `scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml test`: 143 passed, 0 failed (83 in `tests/`, 60 in `src/`). The five new tests measure 947 720, 2 000 390, 523 180, 13 720 and 15 520, as `GAS.md` states. Every entrypoint figure I recomputed from this run matches `GAS.md` and `BUDGETS.md`.
- `scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check`: no output.
- `gh pr checks`: `affected`, `cairo`, `links`, `package (packages/achievement)`, `package (packages/quest)` and `scripts` all pass.

**Could not check:**
- `scripts/gas.py packages/achievement --check` and `python3 .github/ci/check-links.py` were refused by this session's permissions. In their place I checked by hand that the five new budgets equal `ceil(1.05 × measured)` and that the moved status test stays within its ceiling; the PR's `links` and `package` checks are green.
- The by-value against by-snapshot variants of `StatusAssert` (+100 / +200) were not re-measured, because that needs editing the source and a reviewer changes nothing. Only the committed variant was measured.
