# [Opus 5.5] Audit — ARC-07b — cost and access control

Revision read: `970cff18687d8b197309839d29e780648ceb4a23` (PR #25 head, confirmed by `gh pr view 25`). Baseline: tag `quiver_achievement-v0.1.0` (its `GAS.md`, `component.cairo`, `logic/types.cairo`) and `docs/reports/ARC-04-audit-gpt-6-astra-1.md`. Run under the design lens.

## Verdict
**PASS WITH FINDINGS.** All four checks hold, by my own run where a run was possible. The findings are notes only and block nothing.

**(1) AC-3, tracking costs exactly the write or the write plus the event.** In `scripts/lock.sh snforge test --package quiver_achievement`, each store write and its hand-written twin cost the same, to the unit:

| Pair (`tests/test_tracking.cairo`) | store | hand | minus baseline |
|---|---|---|---|
| TrackNone, definition 1 task | 760 670 | 760 670 | 467 910 |
| TrackNone, definition 3 tasks | 1 230 990 | 1 230 990 | 926 590 |
| TrackNone, reporter | 733 680 | 733 680 | 454 630 |
| TrackAll, definition 1 task | 830 850 | 830 850 | 538 090 (event +70 180) |
| TrackAll, definition 3 tasks | 1 325 750 | 1 325 750 | 1 021 350 (event +94 760) |
| TrackAll, reporter | 774 880 | 774 880 | 495 830 (event +41 200) |

The twins in `tests/mock_tracking.cairo` use the store's own shape:
- **Same slots:** both write `Achievement_definitions` (A) and `Achievement_extra_tasks` (B), with `into_slots()`. B is written only when `task_count > 1`, as in `store.cairo:121-124`.
- **No folded constant:** the `MockStoreNone` twins contain no event code (`:234-240`, `:264-266`). The `MockStoreAll` twins `emit` with no condition (`:127-135`, `:162-164`). Neither contains an `if true` or `if false`.

The tracking constant is read in only two places: `store.cairo:125` and `store.cairo:164`, each around an `emit`.

**(2) No worst call raised.** Each figure is the call minus its baseline, measured in my run, against 0.1.0's `GAS.md`:

| Call | 0.1.0 | 0.2.0 | Change |
|---|---|---|---|
| `progress_many`, worst (2 606 413 − 789 600) | 1 816 813 | 1 816 813 | 0 |
| `progress_many`, late duplicate, 16 distinct, with 48 definitions | — | — | 0 for each |
| `progress` | — | — | 0 |
| `set_reporter` (all three cases), `achievement_is_reporter` | — | — | 0 for each |
| `define`, 3 tasks | 1 197 030 | 1 198 640 | **+1 610** |
| `retire` | 240 760 | 243 330 | **+2 570** |
| `achievement_definition`, 3 tasks | 214 130 | 217 740 | **+3 610** |
| `define`, 1 task | 707 640 | 703 270 | −4 370 |

All of these agree with `GAS.md:193-207` and `CHANGELOG.md:58-63`.

Budgets:
- All 40 rows of `test_component_bench` and `test_tracking` in `GAS.md` equal my run exactly.
- The budgets of `bench_retire`, `bench_view_definition_worst`, `bench_define_worst` and `baseline_sixteen_tasks_defined` are 0.1.0's, kept. Each is at or above the measure and below `ceil(1.05 × measured)`. For example, `bench_retire`: 2 338 949 against 2 231 280, ceiling 2 342 844.
- The one raise, `achievement_packing_round_trip_definition`, carries its `// gas: raised` note (`definition.cairo:540`).

**(3) Access control is kept.**
- `define`, `retire` and `set_reporter` each assert `authorize_admin` → `'Achievement: not admin'` (`component.cairo:183, :189, :197`).
- `progress` and `progress_many` each call `assert_reporter` first (`:205, :215`). It reads the reporter and asserts by value (`reporter.cairo:24-27`); the string is unchanged.
- `InternalImpl` is a `#[generate_trait]` impl with no caller check, as in 0.1.0. `achievement_internal_layer_not_reachable_from_abi` passed.
- The order of checks in `define` is unchanged: validate, then "already defined".

**(4) Storage layout.**
- Slot A's pack (`definition.cairo:212-223`) is 0.1.0's term for term, plus `points * TWO_POW_196`.
- On unpacking, the quotient above bit 196 goes through `u16::try_into().expect(PACKING_RESERVED_BITS_SET)` (`:244`), which rejects bits [212, 252). Tests: `achievement_unpacking_rejects_bit_212`, and `_bit_251` with exactly 2^251 (ARC-04's minor finding is fixed).
- Slot B is unchanged.
- 0.1.0 could never write a bit at or above 196: its widest `t0.total` stops below 2^196, and its unpack asserted `rest == 0`. So a 0.1.0 slot reads `points` 0.

## Findings
| # | Severity | Location | Finding | Evidence or failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | note | `packages/achievement/CHANGELOG.md:53` | The CHANGELOG says "A slot A written by 0.1.0 reads with `points` 0" but not what follows on a contract upgraded in place. For achievements defined under 0.1.0, the view and `get_definition` return `points: 0`, while the `AchievementDefined` already emitted carried the real value. Nothing re-emits it. | Define an achievement with `points: 10` on 0.1.0, upgrade the class to 0.2.0, then call `achievement_definition`: `head.points == 0`. This follows from `definition.cairo:244`, since 0.1.0 never wrote bits ≥ 196. | Add one sentence: for an upgraded consumer, the event stays the source of `points` for achievements defined before 0.2.0. |
| 2 | note | `packages/achievement/src/models/definition.cairo:690` (test module) | No test unpacks a felt as 0.1.0 packed it for a defined achievement and asserts `points == 0`. The property holds by construction: the round trip with `points` 0 (`:550`) and the empty slot (`achievement_empty_slot_unpacks_undefined`) cover the formula, not a 0.1.0 value. | — | Optionally, a unit test that unpacks 0.1.0's packing of `head(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX)` (below 2^196) and checks `points == 0` and the other fields. |
| 3 | note | `packages/achievement/tests/test_component_access.cairo:27-100` | The refusal tests (`not admin`, `not reporter`) run only on TrackAll mocks. `MockBenchSilent` (TrackNone) and the two custom mocks accept every admin, and no refusal is tested on them. | By construction, `Tracking` is read only in `store.cairo:125` and `:164`, around the `emit`, and no check reads it. So nothing fails today. A future edit that gated a check on tracking would not be caught. | Optionally, one refusal test on a TrackNone mock whose `authorize_admin` refuses. |

## Coverage
**Read:**
- The brief `docs/briefs/ARC-07b-achievement-0.2.0.md`.
- `src/store.cairo`, `src/component.cairo`, `src/interface.cairo`.
- `src/models/{index,definition,status,reporter}.cairo` and `src/helpers/bits.cairo` (constants and `split`).
- `tests/mock_tracking.cairo`, `tests/test_tracking.cairo`, `tests/test_component_bench.cairo` (and its diff against 0.1.0), `tests/test_component_track_none.cairo`, `tests/mocks.cairo` (the tracking choice of each mock, `MockBenchSilent`), and the names of the tests in `tests/test_component_access.cairo`.
- `GAS.md` (the tables and the sections on points, fix loops 2 and 3), `CHANGELOG.md` [0.2.0].
- From 0.1.0: `component.cairo`, `logic/types.cairo`, and the bench rows of `GAS.md`.
- The ARC-04 audit (its verdict and findings).

**Ran:**
- `scripts/lock.sh snforge test --package quiver_achievement`: **145 passed, 0 failed, 0 ignored**, 18.8 s wall clock (the build was likely partly cached).
- `gh pr checks 25`: all six jobs pass. The `package (packages/achievement)` job runs `scripts/gas.py "$DIR" --check` (`.github/workflows/cairo.yml:137`).

**Could not check:**
- I could not compare all 145 measured values against `GAS.md` and the `ceil(1.05 ×)` rule with my own script: the sandbox refused `python3` and `awk`. I compared the 40 benchmark and tracking rows by hand. For the rest, I rely on CI's `gas.py --check` at this head, which passed.
- I did not run `snforge test --detailed-resources`, so the read and write counts are inferred from code, not measured.
- I did not run 0.1.0 again: its figures come from its committed `GAS.md`.
