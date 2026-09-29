# [Opus 5.5] ARC-04 — `quiver_achievement` 0.1.0, event mode only

## Summary

`quiver_achievement` is now complete for 0.1.0 **in event mode only**, as the decision of
2026-09-29 requires. The model that ran this task is Opus 5.5 (`claude-opus-5-5`), as the brief
names.

- **Library** (`src/logic/`):
  - The types `AchievementWindow`, `AchievementTask`, `AchievementDefinition` (slot A),
    `AchievementExtraTasks` (slot B) and `TaskProgress`.
  - Packing into the fewest slots: one slot for a single-task achievement, two for 2 or 3 tasks.
    Field widths are checked, reserved bits are rejected, and an empty slot reads as undefined.
  - `definition_new`, which validates the id, the window and the tasks the same way whatever the
    use (D-11).
  - `window_validate` and `window_is_active`, and `tasks_span`.
  - `batch_merge`: at most `MAX_ENTRIES` = 16 entries counted before merging, duplicates merged
    with saturation, zeros dropped, task 0 rejected. Also `batch_count_of`.
  - `src/errors.cairo`.
- **Component**:
  - Storage holds only the definitions and the reporter registry: no member is keyed by a player,
    and there are no task pages.
  - Events: `AchievementDefined` (with `points`), `AchievementProgressed` (keys player and task,
    one per merged non-zero entry), `AchievementRetired`, `AchievementReporterSet`.
  - The internal layer is trusted and documented as such.
  - Two optional external impls: `IAchievement` (`define`, `retire` and `set_reporter` through
    `authorize_admin`; `progress` and `progress_many` through the reporter registry) and
    `IAchievementView`.
  - The hook trait has `authorize_admin` only.
- **Event mode is enforced by absence.** There is no `Mode` type, no mode parameter, no
  per-player record, no completion and no claim. Both the doc comments and the README say so.
- **Tests**: 102, each with a budget; `scripts/gas.py --check` passes. The benchmarks have
  baselines and include the game's use (8 titles as 26 tiers on 8 tasks).
- **Documents**:
  - ARC-01 amended: §2 (the `achievement_` rows), §3.10, §3.11 and §5.2.
  - README, with the indexer's rule and the planned storage design whose layout 0.1.0 does not
    reserve.
  - CHANGELOG 0.1.0, GAS.md with its cost model, and the achievement sections of
    `docs/BUDGETS.md`.

Pull request: https://github.com/bal7hazar/quiver/pull/17. CI is green; it was not merged.

**Storage layout.**

| Member | Key | Bits |
|---|---|---|
| `Achievement_definitions` (slot A) | `achievement_id: u32` | `start` [0, 64) · `end` [64, 128) · `task_count` [128, 130) · `defined` [130] · `retired` [131] · `t0.task_id` [132, 164) · `t0.total` [164, 196); [196, 252) reserved |
| `Achievement_extra_tasks` (slot B, only when `task_count > 1`) | `achievement_id: u32` | `t1` [0, 64) · `t2` [64, 128); [128, 252) reserved |
| `Achievement_reporters` | `ContractAddress` | `bool` |

## Files changed

- `packages/achievement/src/lib.cairo`: declares the modules.
- `packages/achievement/src/constants.cairo`: `MAX_TASKS`, `MAX_ENTRIES`. `ACHIEVEMENTS_PER_PAGE` and `MAX_PAGES` are removed.
- `packages/achievement/src/errors.cairo`: the 10 error strings.
- `packages/achievement/src/logic.cairo` and `logic/{bits,types,definition,window,batch}.cairo`: the library.
- `packages/achievement/src/interface.cairo`: `IAchievement`, `IAchievementView`.
- `packages/achievement/src/component.cairo`: `AchievementComponent`.
- `packages/achievement/tests/{helpers,mocks,setup}.cairo`: builders, `MockAchievement`, `MockConsumer` (views only, calls the internals) and `MockBench`.
- `packages/achievement/tests/test_{constants,errors,packing,definition,batch}.cairo`: library tests.
- `packages/achievement/tests/test_component_{define,retire,progress,access}.cairo`: component tests.
- `packages/achievement/tests/test_{bench,component_bench}.cairo`: the library's and the component's benchmarks, including the game's use.
- `packages/achievement/README.md`, `CHANGELOG.md`, `GAS.md`: rewritten.
- `docs/BUDGETS.md`: two achievement sections appended (component, library).
- `docs/research/ARC-01-quest-achievement.md`: §3.10 and §3.11 replaced, with an amendment note; amendment notes on the `achievement_` rows of §2 and on §5.2, with the measured figures.

## Commands run

```
$ scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build
    Finished `dev` profile target(s) in 1 second

$ cd packages/achievement && snforge test
Tests: 102 passed, 0 failed, 0 ignored, 0 filtered out

$ python3 scripts/gas.py packages/achievement --check
quiver_achievement: 102 tests within budget, GAS.md up to date

$ scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check
(no output, exit 0)

$ python3 .github/ci/check-links.py
check-links: 0 broken link(s)

$ snforge test bench --detailed-resources      (reads, writes, events of each benchmark)
bench_progress_many_late_collision  l2_gas ~2606413  (EmitEvent: 17, StorageRead: 1, StorageWrite: 1, ...)
baseline_deployed                   l2_gas ~789600   (EmitEvent: 1, StorageWrite: 1, ...)
bench_define_worst                  l2_gas ~1986630  (StorageWrite: 3, StorageRead: 1, EmitEvent: 2, ...)
bench_game_results_call             l2_gas ~20143438 (EmitEvent: 35, StorageRead: 28, StorageWrite: 27)
baseline_game_defined               l2_gas ~19313710 (EmitEvent: 27, StorageRead: 26, StorageWrite: 27)

$ gh pr checks 17 --watch --interval 30
affected pass · cairo pass · package (packages/achievement) pass · scripts pass · links pass
```

Budgets were set to `ceil(1.05 × measured)` from a full run by a scratch script in
`target/arc04/` (not committed). GAS.md was then generated with `scripts/gas.py --write` and the
hand-written cost model appended.

## Cost

The package is new, so "Before" is "—", except for the skeleton's constants test. **Call** is
the benchmark minus its baseline, through a dispatcher, snforge 0.61. **Network** reprices each
written slot at about 453 500 when created and about 32 000 when overwritten (the prices in
`quiver_quest`'s GAS.md).

| Entrypoint or algorithm | Before | After (call; network) | Budget (of the test) | Note |
|---|---|---|---|---|
| **`progress_many`, worst**: 16 entries, late collision | — | **1 816 813**; 1 816 813 | 2 736 734 | 1 read (the reporter), 0 writes, 16 events; **9.1 % of 20 M** |
| `progress_many`, worst, 48 achievements of 3 tasks on its tasks | — | 1 816 613; same | 63 268 583 | Progress reads no definition, so what is defined costs it nothing |
| `progress_many`, late duplicate | — | 1 759 993; same | 2 677 073 | 15 events |
| `progress_many`, 16 distinct | — | 1 245 486; same | 2 136 841 | Fast path |
| `progress`, 1 entry | — | 209 236; same | 1 048 778 | |
| **`define`, worst** (3 tasks) | — | **1 197 030**; 1 185 818 | 2 085 962 | 2 slots created |
| `define`, 1 task | — | 707 640; 702 034 | 1 572 102 | 1 slot created |
| `retire` | — | 240 760; 215 654 | 2 338 949 | 1 slot overwritten |
| `set_reporter`, new / revoked / unchanged | — | 607 410 / 206 730 in its own transaction (−195 270 in the test) / 206 530 | 1 466 861 / 1 261 827 / 1 683 717 | |
| `achievement_definition` (3 tasks) / `achievement_is_reporter` | — | 214 130 / 124 690 | 2 310 987 / 960 005 | |
| **Game: results transaction** (6 character tasks and 2 account tasks, two calls) | — | **829 728**; same | 21 150 610 | 4.1 % |
| Game: 16 tasks in one call (A-10) | — | 1 245 286; same | 21 586 946 | 6.2 % |
| **Game: 26 tiers defined in one transaction** | — | **18 525 730**; 18 379 974 | 20 281 097 | **92.6 % of the cap**: the admin's batching; see Escalations |
| `batch_merge`, late collision / late duplicate / 16 distinct (with setup) | — | 751 523 / 747 613 / 180 396 | 789 100 / 784 994 / 189 416 | |
| `definition_new` (3 tasks) | — | 20 920 | 21 966 | |
| Pack and unpack A / B | — | 34 120 / 24 930 | 35 826 / 26 177 | |
| `achievement_bounds_are_the_accepted_ones` | 13 720 | 13 720 | 14 406 | Now asserts only the two constants left |
| Other tests (82) | — | In `packages/achievement/GAS.md` | ceil(1.05 × measured) | |

## Acceptance criteria

- **AC-1: no storage mode is reachable.** There is no `Mode` type anywhere in the package, the
  storage has no member keyed by a player, and there is no claim or completion: see
  `src/interface.cairo` and `src/component.cairo`.
  - `achievement_internal_layer_not_reachable_from_abi` shows that the consumer's ABI has no
    `IAchievement` selector unless it embeds one.
  - `achievement_progress_writes_nothing` is a Sierra-gas guard, with a reference of 603 146 and a
    tolerance of ±20 000. The benchmarks' `--detailed-resources` counts show 0 writes on progress.
- **AC-2: every `IAchievement` entrypoint refuses an unauthorised caller.** The tests are
  `achievement_define_admin_only`, `achievement_retire_admin_only`,
  `achievement_set_reporter_admin_only`, `achievement_progress_rejects_unregistered_caller` and
  `achievement_progress_many_rejects_unregistered_caller`. `achievement_reporter_revoked` shows a
  revoked reporter refused in the very next call.
- **AC-3: under 20 M, with network estimates.** The worst call is 1 816 813. The game's results
  transaction is 829 728, and every entrypoint is at most 1.2 M. Figures are in the Cost table,
  GAS.md, BUDGETS and README.
- **AC-4: every test has a budget.** `scripts/gas.py packages/achievement --check` reports 102
  tests within budget.
- **AC-5: documents written.**
  - ARC-01 §2, §3.10, §3.11 and §5.2 are amended "by the decision of 2026-09-29".
  - The README section "Event mode only" has the planned per-task-counter design and says its
    layout is not reserved.
  - CHANGELOG `## [0.1.0]`, GAS.md, and `docs/BUDGETS.md` (two sections) are written.
- **AC-6: CI green.** `gh pr checks 17`: affected, cairo, package (packages/achievement),
  scripts and links all pass.

**Named cases of ARC-01 §2.**

- **Kept:**
  - `achievement_event_mode_emits_only_progressed`, without a mode argument.
  - `achievement_define_twice_reverts`.
  - `achievement_define_rejects_no_task` and `achievement_define_rejects_empty_window`.
  - `achievement_batch_above_bound_reverts`.
  - `achievement_empty_slot_reads_undefined`.
  - `achievement_define_admin_only`, `achievement_set_reporter_admin_only`,
    `achievement_progress_rejects_unregistered_caller`,
    `achievement_progress_accepts_registered_reporter` and `achievement_reporter_revoked`.
- **Added:**
  - Access: `achievement_retire_admin_only`,
    `achievement_progress_many_rejects_unregistered_caller`,
    `achievement_internal_layer_not_reachable_from_abi` and
    `achievement_consumer_calls_the_internal_layer`.
  - Batches: `achievement_batch_merges_duplicates`,
    `achievement_batch_duplicates_count_toward_bound` and `achievement_batch_rejects_task_zero`.
  - Retirement: `achievement_retire_twice_reverts`, `achievement_redefine_retired_reverts` and
    `achievement_retired_progress_still_emits`.
  - Tiers and writes: `achievement_tiers_share_task_one_event`, `achievement_many_on_one_task`
    (29 on one task) and `achievement_progress_writes_nothing`.
  - Packing: the round trips, presence bits, widths and reserved-bit tests.
- **Dropped, by the decision of 2026-09-29.** Each assumes storage mode or something that no
  longer exists:
  - `achievement_event_mode_calls_no_hook`: there is no completion hook, so it holds by
    construction.
  - `achievement_event_mode_cannot_be_claimed`: there is no claim.
  - `achievement_modes_do_not_mix`: there is one mode.
  - `achievement_progress_writes_one_slot`: there is no per-player record; replaced by
    `achievement_progress_writes_nothing`.
  - `achievement_claim_requires_player_authorization`: there is no claim and no `authorize_player`.
  - `achievement_tiers_share_task`: tiers completing.
  - `achievement_tier_kept`: a tier kept.
  - `achievement_batch_two_tasks_one_write`: one write.
  - `achievement_retired_completed_kept`: completion and claim.
  - `achievement_retire_frees_slot`: no task pages and no per-task cap.

  All of these are listed in the ARC-01 §2 amendment notes.

## Deviations from the brief

- **I did not read design/13 at `origin/main`.** Both `cd /home/claude/projects/grimworld && git
  show …` and `git -C … show …` were refused by the permission layer. I read the main checkout's
  working copy, `/home/claude/projects/grimworld/docs/design/13-titles.md` (Draft v0.1), with the
  Read tool. If it differs from `origin/main`, only the illustrative thresholds of the game
  benchmark are affected, not the costs.
- **The definition views return more than A-G1 did.** `definition` and `achievement_definition`
  return `(AchievementDefinition, Span<AchievementTask>)` instead of A-G1's
  `(AchievementWindow, Span<AchievementTask>)`, so that `retired` is readable on chain. This is how
  quest's views work, and ARC-01 §3.11 is amended to say so.
- **Removed the skeleton's unused bounds.** `ACHIEVEMENTS_PER_PAGE` and `MAX_PAGES` are gone (no
  pages), and `achievement_bounds_are_the_accepted_ones` now asserts the two constants left. The
  CHANGELOG records it under 0.1.0 "Removed"; they were never released.
- **Kept `window_is_active` although the component never calls it.** It is in the library as the
  stated rule for the indexer, which A-G1 also listed.
- **Some of the game benchmark's thresholds are illustrative.** Where design/13 gives a share
  ("half", "50 %", "all"), I picked the denominator: 6 zones, 10 quests, 8 dungeons, 5 trials, 20
  recipes, and 10 000 experience for "level 20 worth". These change the stored totals only, not
  the cost.
- **I measured the game's results transaction as two `progress_many` calls:** one for the
  adventurer (6 character titles) and one for the account (Veteran, Scavenger), since the two are
  different player ids.
- **The CHANGELOG `## [0.1.0]` heading is undated.** `quiver_quest`'s was dated when it was
  published, and this package is not published here.

## Escalations

- **ARC-01 outside my allowlist is now stale for achievements.**
  - §3.1: the Bounds row ("`quiver_achievement`: `MAX_ACHIEVEMENTS_PER_TASK = 28`"), the "Mode per
    call" row, and "One write per record", which names `AchievementProgress`.
  - §4: A-6 ("`mode: Mode` on `progress` and `progress_many`") and A-7 ("up to 28 live
    achievements per task … Test `achievement_tiers_share_task`").
  - The note in §3.10 points to the package as the reference, but those rows should get the same
    amendment note.
- **Defining in bulk comes near the cap.** The 26 tiers of the game's titles defined in one
  transaction cost 18.5 M (92.6 % of 20 M). No single call of the package is involved: each
  `define` is at most 1.2 M, and the total is the admin's batching. The README advises spreading
  definitions over transactions (at most about 25 single-task or 16 three-task definitions per
  transaction). A decision is needed on whether the cap should also bind an admin's multicall,
  and whether the game's deployment script must split definitions.
- **The audit is still to schedule.** The decision makes an audit of reporter access control by
  `[GPT-6-Astra]` a condition, and that is the orchestrator's to schedule.
- Publication is not requested (D-132).

## Open questions

- **Progress on a task no achievement uses, or only retired ones, still emits.** Progress reads
  no definition, and that is what keeps its cost flat. The indexer must ignore such events. Is
  that acceptable to the game's indexer, or should the game filter its entries?
- **Retirement stops the indexer's counting from the `AchievementRetired` event onward, and keeps
  tiers already reached.** This is my reading of "retired", stated in the README and in ARC-01
  §3.11. It needs confirming with the game's indexer design.

## Fix loop 1

Scope: the two minor findings of the `[GPT-6-Astra]` audit (PASS WITH FINDINGS, no blocker or
major). Nothing else was changed. Commits `36b8a3c` (the fixes) and `ffacba6` (GAS.md), pushed
to PR #17.

### Finding 1: `achievement_unpacking_rejects_bit_251` did not test bit 251

- **Before:** the test supplied `to_felt(pow2(251) - 1)`. That value has bit 251 clear, and bits
  [196, 251) set. The lower reserved bits caused the rejection, so the test passed without ever
  exercising bit 251.
- **After:** it supplies exactly 2^251, as a felt literal `TWO_POW_251 =
  0x800…0` (`tests/test_packing.cairo`). This bypasses `to_felt`, which requires values below
  2^251. 2^251 is below the field prime, so it is a valid felt. With bit 251 alone set and every
  other reserved bit clear, only a decoder that checks bit 251 rejects it.
- **Shown against a decoder that ignores bit 251**, in a scratch build that was not committed. I
  added `let high = high % 2^123;` (bit 251 is bit 123 of the high limb) to
  `AchievementDefinitionPacking::unpack` and ran the packing tests:

  ```
  $ snforge test test_packing          (scratch decoder)
  [FAIL] quiver_achievement_integrationtest::test_packing::achievement_unpacking_rejects_bit_251
      Expected to panic, but no panic occurred
      Expected panic data:  [0x5061…] (Packing: reserved bits set)
  Tests: 8 passed, 1 failed, 0 ignored, 93 filtered out
  ```

  I then restored `src/logic/types.cairo` with `git checkout`, and it is unchanged in the pull
  request. On the real decoder the test passes:

  ```
  [PASS] …::test_packing::achievement_unpacking_rejects_bit_251 (… l2_gas: ~29460)
  ```

- **Budget refreshed:** measured 438 200 → 29 460 (the u256 oracle is no longer run), budget
  460 110 → **30 933** = ceil(1.05 × 29 460).

### Finding 2: `Scarb.toml` description

`packages/achievement/Scarb.toml` line 8 changes from "Achievements for Starknet games: tasks,
tiers, claim. No Dojo." to "Achievements for Starknet games: definitions on chain, progress
reported as events, tiers derived by an indexer. No Dojo."

### Commands run

```
$ scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check
FMT_OK
$ python3 scripts/gas.py packages/achievement --write     (then the hand-written cost section re-appended, unchanged)
quiver_achievement: wrote packages/achievement/GAS.md (102 tests)
$ python3 scripts/gas.py packages/achievement --check
quiver_achievement: 102 tests within budget, GAS.md up to date
$ gh pr checks 17 --watch --interval 30
affected pass · cairo pass · package (packages/achievement) pass · scripts pass · links pass
```

In GAS.md, only the table rows changed: the commit column of every row, and the bit-251 row's
figures. No other test's measured value changed. The cost-model section is identical.

### Cost

| Test | Before | After | Budget | Note |
|---|---|---|---|---|
| `achievement_unpacking_rejects_bit_251` | 438 200 | 29 460 | 460 110 → 30 933 | The input is a felt literal instead of the u256 oracle's `pow2(251) - 1` |
| Every other test | unchanged | unchanged | unchanged | `gas.py --check` passes on 102 tests |

### Deviations and escalations

None. `docs/BUDGETS.md`, README, CHANGELOG and ARC-01 are untouched: none of them names this
test or the description.
