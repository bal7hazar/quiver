# [Opus 5.5] ARC-03a — `quiver_quest::logic`: types, packing and pure functions

## Summary

Running as Opus 5.5 (`claude-opus-5-5`), as the brief names.

`quiver_quest` now has its pure library `quiver_quest::logic` and its error module
`quiver_quest::errors`:

- every type of ARC-01 §3.2 (`Mode`, `QuestSchedule`, `QuestTask`, `QuestDefinition`, `QuestTasks`,
  `QuestConditions`, `QuestIdPage`, `QuestProgress`, `QuestRecord`, `TaskProgress`), all
  `Drop, Copy, Serde, PartialEq, Debug`, and `Mode` also `starknet::Store` with `#[default] Storage`;
- `StorePacking<T, felt252>` for the six packed types with the bit ranges of §3.3 and the
  presence bits `defined` [198] and `retired` [199]. An empty slot unpacks to all fields zero with
  `defined == false`. Packing is felt arithmetic with the power-of-two constants in
  `logic/bits.cairo`. Unpacking splits the felt once into two `u128` limbs, then uses `u128`
  `DivRem` by constant non-zero divisors. No field straddles bit 128, and `QuestProgress` (98 bits)
  needs no split;
- every pure function of §3.2 with its signature and panics: schedule (3), definition (4),
  batch (3), progress (2), record (5), claim, pages (5);
- the 25 error strings of §3.5 as constants;
- 146 snforge tests written before the code, each with its budget. They include 33 benchmarks on
  the worst cases, 3 of which are baselines that measure the benchmarks' own setup;
- one optimisation, measured: a one-pass mask fast path for `batch_merge`.

Pull request: https://github.com/bal7hazar/quiver/pull/6. CI is green: `cairo`, `package
(packages/quest)`, `affected`, `links`, `scripts`.

## Files changed

- `packages/quest/src/lib.cairo`: `pub mod errors; pub mod logic;`
- `packages/quest/src/errors.cairo`: the 25 error strings of §3.5.
- `packages/quest/src/logic.cairo`: module tree, re-exports (types, packing impls, functions, bounds).
- `packages/quest/src/logic/types.cairo`: the types and the six `StorePacking` impls.
- `packages/quest/src/logic/bits.cairo`: power-of-two tables (felt multipliers, `u128` divisors,
  `POW2[128]` for the merge mask) and `split` (felt → two `u128` limbs).
- `packages/quest/src/logic/schedule.cairo`: `schedule_validate`, `schedule_is_active`, `schedule_interval_id`.
- `packages/quest/src/logic/definition.cairo`: `definition_new`, `tasks_index_of`, `tasks_span`, `conditions_span`.
- `packages/quest/src/logic/batch.cairo`: `batch_merge` (mask fast path + plain merge), `batch_count_of`, `batch_first_position`.
- `packages/quest/src/logic/progress.cairo`: `progress_add`, `progress_is_complete`.
- `packages/quest/src/logic/record.cairo`: `prerequisites_met`, `record_is_accepted`, `record_complete`, `record_accept`, `record_abandon`, `claim`.
- `packages/quest/src/logic/pages.cairo`: `page_push`, `page_span`, `page_position`, `page_set`, `page_pop`.
- `packages/quest/tests/helpers.cairo`: builders and `opaque` (a non-inlined identity for benchmark inputs).
- `packages/quest/tests/test_{schedule,definition,batch,progress,record,pages,packing,errors,bench}.cairo`: the tests.
- `packages/quest/GAS.md`: regenerated (146 tests).
- `packages/quest/CHANGELOG.md`: `Unreleased`, the library and the errors added.
- `packages/quest/README.md`: a "Library" section (bounds of every loop).

## Commands run

```
$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build
   Compiling quiver_quest v0.1.0 (.../packages/quest/Scarb.toml)
    Finished `dev` profile target(s) in 1 second

$ cd packages/quest && snforge test
Collected 146 test(s) from quiver_quest package
Running 146 test(s) from tests/
Running 0 test(s) from src/
Tests: 146 passed, 0 failed, 0 ignored, 0 filtered out

$ scripts/gas.py packages/quest --write
quiver_quest: wrote packages/quest/GAS.md (146 tests)
$ scripts/gas.py packages/quest --check
quiver_quest: 146 tests within budget, GAS.md up to date
$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check
(no output, exit 0)

$ gh pr checks 6 --watch --interval 30
affected                  pass  10s
cairo                     pass   2s
links                     pass   7s
package (packages/quest)  pass  24s
scripts                   pass  14s
```

Along the way:

- The first run of the packing tests failed with "Test cost exceeded the available gas", at
  118M–435M l2_gas. The cause was an oracle `pow2` written as a loop of `u256` doublings. It now
  uses `Pow::pow(2_u256, n)`.
- A `tests/lib.cairo` renamed the test crate to `quiver_quest_tests`, which `scripts/gas.py` does
  not expect (it expects `quiver_quest_integrationtest`). I removed it; `super::helpers` works
  without it.

Optimisation measurements, l2_gas, the full benchmark minus nothing:

| Change | Before | After | Kept |
|---|---|---|---|
| `batch_merge` indexed loops → `pop_front` spans (16 distinct) | 844 350 | 649 440 | yes |
| `batch_merge` + mask fast path (16 distinct) | 649 440 | 181 896 | yes |
| `batch_merge` + mask fast path (16 with duplicates: the fast pass is abandoned at the first repeat) | 480 960 | 545 921 | yes (the consumer's contract is to aggregate; the defensive path pays 65k) |
| `progress_add`: one pass over the batch for the 3 slots instead of 3 `batch_count_of` | 156 430 | 173 980 | **no**, reverted: the loop carries more state than three tight scans cost |

The first measurement of `batch_merge` (844 350) was taken before inputs went through `opaque`.
The later figures were taken with it.

## Cost

"Before" is "—": every test is new. A benchmark's net cost is its figure minus the matching
baseline: `bench_baseline_empty` (14 120), `bench_baseline_sixteen_distinct` (62 900) or
`bench_baseline_sixteen_with_duplicates` (75 500). For example, `batch_merge` of 16 distinct
entries costs 181 896 − 62 900 = 118 996, and `progress_add` with 3 tasks and 16 entries costs
156 430 − 62 900 = 93 530.

Many behaviour tests measure 13 720, the cost of an empty test. Their inputs are constants, so the
compiler evaluated the assertions at compile time. A failing assertion would still have panicked.
The benchmarks avoid this through `opaque`.

| Entrypoint or algorithm | Before | After | Budget | Note |
|---|---|---|---|---|
| `test_batch::batch_count_of_present_and_absent` | — | 47260 | 49623 |  |
| `test_batch::batch_first_position_at_the_bound` | — | 152110 | 159716 |  |
| `test_batch::batch_first_position_is_the_smallest_position` | — | 36930 | 38777 |  |
| `test_batch::batch_merge_drops_zero_counts` | — | 83525 | 87702 |  |
| `test_batch::batch_merge_empty` | — | 20710 | 21746 |  |
| `test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | — | 183358 | 192526 |  |
| `test_batch::batch_merge_keeps_distinct_entries_in_order` | — | 53738 | 56425 |  |
| `test_batch::batch_merge_keeps_the_position_of_first_occurrence` | — | 92375 | 96994 |  |
| `test_batch::batch_merge_matches_the_plain_merge` | — | 8504394 | 8929614 |  |
| `test_batch::batch_merge_saturates_duplicates` | — | 271214 | 284775 |  |
| `test_batch::quest_batch_above_bound_reverts` | — | 74260 | 77973 |  |
| `test_batch::quest_batch_bound_accepted` | — | 225086 | 236341 |  |
| `test_batch::quest_batch_duplicate_entries_merged` | — | 55829 | 58621 |  |
| `test_batch::quest_batch_duplicates_count_toward_bound` | — | 65140 | 68397 |  |
| `test_batch::quest_batch_event_mode_one_event_per_task_merge` | — | 85409 | 89680 |  |
| `test_batch::quest_batch_first_position_uses_zero_sentinel` | — | 31320 | 32886 |  |
| `test_batch::quest_batch_rejects_task_zero` | — | 31036 | 32588 |  |
| `test_batch::quest_batch_rejects_task_zero_with_zero_count` | — | 38452 | 40375 |  |
| `test_batch::quest_batch_zero_counts_count_toward_bound` | — | 74260 | 77973 |  |
| `test_bench::bench_baseline_empty` | — | 14120 | 14826 | benchmark |
| `test_bench::bench_baseline_sixteen_distinct` | — | 62900 | 66045 | benchmark |
| `test_bench::bench_baseline_sixteen_with_duplicates` | — | 75500 | 79275 | benchmark |
| `test_bench::bench_batch_count_of_absent` | — | 90590 | 95120 | benchmark |
| `test_bench::bench_batch_first_position_absent` | — | 110490 | 116015 | benchmark |
| `test_bench::bench_batch_merge_sixteen_distinct` | — | 181896 | 190991 | benchmark |
| `test_bench::bench_batch_merge_sixteen_with_duplicates` | — | 545921 | 573218 | benchmark |
| `test_bench::bench_claim` | — | 18340 | 19257 | benchmark |
| `test_bench::bench_conditions_span_seven` | — | 19540 | 20517 | benchmark |
| `test_bench::bench_definition_new_three_tasks_seven_conditions` | — | 151360 | 158928 | benchmark |
| `test_bench::bench_pack_unpack_conditions` | — | 35520 | 37296 | benchmark |
| `test_bench::bench_pack_unpack_definition` | — | 42710 | 44846 | benchmark |
| `test_bench::bench_pack_unpack_page` | — | 36690 | 38525 | benchmark |
| `test_bench::bench_pack_unpack_progress` | — | 28660 | 30093 | benchmark |
| `test_bench::bench_pack_unpack_record` | — | 29220 | 30681 | benchmark |
| `test_bench::bench_pack_unpack_tasks` | — | 31590 | 33170 | benchmark |
| `test_bench::bench_page_pop_full` | — | 24910 | 26156 | benchmark |
| `test_bench::bench_page_position_absent` | — | 25830 | 27122 | benchmark |
| `test_bench::bench_page_push_seventh` | — | 21680 | 22764 | benchmark |
| `test_bench::bench_page_set_last` | — | 21680 | 22764 | benchmark |
| `test_bench::bench_page_span_full` | — | 19340 | 20307 | benchmark |
| `test_bench::bench_prerequisites_met_seven` | — | 31400 | 32970 | benchmark |
| `test_bench::bench_progress_add_three_tasks_sixteen_entries` | — | 156430 | 164252 | benchmark |
| `test_bench::bench_progress_is_complete_three_tasks` | — | 21680 | 22764 | benchmark |
| `test_bench::bench_record_abandon` | — | 17140 | 17997 | benchmark |
| `test_bench::bench_record_accept` | — | 17040 | 17892 | benchmark |
| `test_bench::bench_record_complete` | — | 16640 | 17472 | benchmark |
| `test_bench::bench_record_is_accepted` | — | 17140 | 17997 | benchmark |
| `test_bench::bench_schedule_interval_id` | — | 20130 | 21137 | benchmark |
| `test_bench::bench_schedule_is_active` | — | 19230 | 20192 | benchmark |
| `test_bench::bench_schedule_validate` | — | 17480 | 18354 | benchmark |
| `test_bench::bench_tasks_index_of_absent` | — | 20850 | 21893 | benchmark |
| `test_bench::bench_tasks_span_three` | — | 20050 | 21053 | benchmark |
| `test_constants::quest_bounds_are_the_accepted_ones` | — | 13720 | 14406 |  |
| `test_definition::conditions_span_has_count_entries` | — | 104530 | 109757 |  |
| `test_definition::definition_new_one_task` | — | 27110 | 28466 |  |
| `test_definition::definition_new_round_trips_through_the_spans` | — | 70830 | 74372 |  |
| `test_definition::definition_new_three_tasks_seven_conditions` | — | 160730 | 168767 |  |
| `test_definition::definition_new_unused_slots_are_zero` | — | 37590 | 39470 |  |
| `test_definition::quest_define_rejects_condition_zero` | — | 27060 | 28413 |  |
| `test_definition::quest_define_rejects_duplicate_condition` | — | 33030 | 34682 |  |
| `test_definition::quest_define_rejects_duplicate_condition_far_apart` | — | 125580 | 131859 |  |
| `test_definition::quest_define_rejects_duration_above_interval` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_half_recurring` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_invalid_id` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_invalid_window` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_more_than_three_tasks` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_no_task` | — | 15520 | 16296 |  |
| `test_definition::quest_define_rejects_repeated_task` | — | 20530 | 21557 |  |
| `test_definition::quest_define_rejects_repeated_task_first_and_last` | — | 21530 | 22607 |  |
| `test_definition::quest_define_rejects_repeated_task_second_and_last` | — | 20320 | 21336 |  |
| `test_definition::quest_define_rejects_self_condition` | — | 21590 | 22670 |  |
| `test_definition::quest_define_rejects_task_zero` | — | 19120 | 20076 |  |
| `test_definition::quest_define_rejects_too_many_conditions` | — | 18630 | 19562 |  |
| `test_definition::quest_define_rejects_total_zero` | — | 20120 | 21126 |  |
| `test_definition::tasks_index_of_finds_used_slots_only` | — | 13720 | 14406 |  |
| `test_definition::tasks_span_has_task_count_entries` | — | 43210 | 45371 |  |
| `test_errors::quest_error_strings_are_the_accepted_ones` | — | 13720 | 14406 |  |
| `test_packing::quest_empty_slot_reads_undefined` | — | 38180 | 40089 |  |
| `test_packing::quest_packing_presence_bits_at_their_positions` | — | 1138250 | 1195163 |  |
| `test_packing::quest_packing_round_trip_conditions` | — | 19268540 | 20231967 |  |
| `test_packing::quest_packing_round_trip_definition_max` | — | 27678040 | 29061942 |  |
| `test_packing::quest_packing_round_trip_definition_mixed` | — | 7558750 | 7936688 |  |
| `test_packing::quest_packing_round_trip_definition_zero` | — | 2529620 | 2656101 |  |
| `test_packing::quest_packing_round_trip_page` | — | 12916840 | 13562682 |  |
| `test_packing::quest_packing_round_trip_progress` | — | 11904990 | 12500240 |  |
| `test_packing::quest_packing_round_trip_record` | — | 12949140 | 13596597 |  |
| `test_packing::quest_packing_round_trip_tasks` | — | 15136450 | 15893273 |  |
| `test_pages::page_pop_empty_panics` | — | 15520 | 16296 |  |
| `test_pages::page_pop_removes_the_last_id` | — | 13720 | 14406 |  |
| `test_pages::page_position_among_len_ids` | — | 13720 | 14406 |  |
| `test_pages::page_push_appends_until_full` | — | 87110 | 91466 |  |
| `test_pages::page_push_full_panics` | — | 15520 | 16296 |  |
| `test_pages::page_set_beyond_len_panics` | — | 15520 | 16296 |  |
| `test_pages::page_set_replaces_one_id` | — | 13720 | 14406 |  |
| `test_pages::page_span_has_len_entries` | — | 31900 | 33495 |  |
| `test_pages::pages_removal_keeps_pages_contiguous` | — | 810930 | 851477 |  |
| `test_pages::pages_removal_of_the_only_id` | — | 172240 | 180852 |  |
| `test_pages::quest_retire_frees_slot_pages` | — | 566680 | 595014 |  |
| `test_progress::progress_add_ignores_other_tasks` | — | 46840 | 49182 |  |
| `test_progress::progress_add_keeps_claimed` | — | 16790 | 17630 |  |
| `test_progress::progress_add_matches_the_plain_formula` | — | 6398420 | 6718341 |  |
| `test_progress::progress_add_three_tasks_partial_then_complete` | — | 63440 | 66612 |  |
| `test_progress::progress_add_touches_only_task_count_slots` | — | 24310 | 25526 |  |
| `test_progress::progress_is_complete_per_task_count` | — | 15940 | 16737 |  |
| `test_progress::quest_batch_duplicate_entries_merged_progress` | — | 58829 | 61771 |  |
| `test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | — | 50012 | 52513 |  |
| `test_progress::quest_count_max_value` | — | 34610 | 36341 |  |
| `test_progress::quest_count_max_value_below_total` | — | 22160 | 23268 |  |
| `test_progress::quest_count_saturates_at_total` | — | 45750 | 48038 |  |
| `test_progress::quest_one_off_completes_once` | — | 31000 | 32550 |  |
| `test_record::claim_marks_claimed_and_counts` | — | 13720 | 14406 |  |
| `test_record::prerequisites_met_when_each_completed_once` | — | 40180 | 42189 |  |
| `test_record::quest_abandon_expired_reverts` | — | 15520 | 16296 |  |
| `test_record::quest_accept_twice_same_interval_reverts` | — | 15520 | 16296 |  |
| `test_record::quest_acceptance_expires_at_rollover_logic` | — | 13720 | 14406 |  |
| `test_record::quest_claim_index_counts_claims` | — | 13720 | 14406 |  |
| `test_record::quest_claim_twice_reverts` | — | 15520 | 16296 |  |
| `test_record::quest_claim_uncompleted_reverts` | — | 15520 | 16296 |  |
| `test_record::quest_claim_uncompleted_reverts_before_claimed` | — | 15520 | 16296 |  |
| `test_record::quest_completion_releases_acceptance` | — | 13720 | 14406 |  |
| `test_record::quest_prerequisites_all_required_logic` | — | 28420 | 29841 |  |
| `test_record::quest_record_counters_past_u32` | — | 28100 | 29505 |  |
| `test_record::quest_record_counters_saturate` | — | 13720 | 14406 |  |
| `test_record::quest_recurring_completes_each_interval_logic` | — | 13720 | 14406 |  |
| `test_record::record_abandon_clears_active` | — | 13720 | 14406 |  |
| `test_record::record_abandon_not_accepted_reverts` | — | 15520 | 16296 |  |
| `test_record::record_accept_sets_active_and_interval` | — | 13720 | 14406 |  |
| `test_record::record_complete_keeps_unlocked_and_claims` | — | 13720 | 14406 |  |
| `test_record::record_is_accepted_in_its_interval_only` | — | 15940 | 16737 |  |
| `test_schedule::quest_daily_interval_aligned_on_utc_midnight` | — | 13720 | 14406 |  |
| `test_schedule::quest_interval_id_is_u64` | — | 13720 | 14406 |  |
| `test_schedule::schedule_interval_id_never_panics_at_the_bounds` | — | 13720 | 14406 |  |
| `test_schedule::schedule_interval_id_none_when_inactive` | — | 13720 | 14406 |  |
| `test_schedule::schedule_interval_id_one_off_is_zero` | — | 13720 | 14406 |  |
| `test_schedule::schedule_interval_id_recurring` | — | 13720 | 14406 |  |
| `test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | — | 13720 | 14406 |  |
| `test_schedule::schedule_is_active_never_ends_when_end_is_zero` | — | 13720 | 14406 |  |
| `test_schedule::schedule_is_active_one_off_window` | — | 15940 | 16737 |  |
| `test_schedule::schedule_is_active_recurring` | — | 16240 | 17052 |  |
| `test_schedule::schedule_validate_accepts_valid_schedules` | — | 13720 | 14406 |  |
| `test_schedule::schedule_validate_rejects_duration_above_interval` | — | 15520 | 16296 |  |
| `test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | — | 15520 | 16296 |  |
| `test_schedule::schedule_validate_rejects_empty_window` | — | 15520 | 16296 |  |
| `test_schedule::schedule_validate_rejects_end_before_start` | — | 15520 | 16296 |  |
| `test_schedule::schedule_validate_rejects_half_recurring_duration_only` | — | 15520 | 16296 |  |
| `test_schedule::schedule_validate_rejects_half_recurring_interval_only` | — | 15520 | 16296 |  |

## Acceptance criteria

- **AC-1** Every type and pure function of §3.2 exists, with the signatures and panics of the
  report; `quiver_quest::logic` re-exports them. The deviations are named below. Shown by
  `snforge test` (146 passed) and by `tests/test_bench.cairo`, which calls every function.
- **AC-2** `test_packing`: `quest_packing_round_trip_{definition_zero,definition_max,definition_mixed,tasks,conditions,page,progress,record}`.
  Each type is checked at zero, with every field at its maximum (alone and all together) and on
  mixed values. `check_*` asserts `pack == oracle` (a `u256` field-by-field packing with the
  offsets and widths of §3.3, which also asserts each field fits its width and the value its total
  width), `pack < 2^251` and `unpack(pack(v)) == v`. `quest_packing_presence_bits_at_their_positions`
  asserts that `defined` alone packs to 2^198 and `retired` alone to 2^199.
  `quest_empty_slot_reads_undefined` asserts that `unpack(0)` gives `defined == false` and every
  field zero.
- **AC-3** Named test cases whose pure part is covered, each under its name or a name containing
  it:
  - schedule: `quest_daily_interval_aligned_on_utc_midnight`, `quest_interval_id_is_u64`;
  - definition: `quest_define_rejects_self_condition`, `quest_define_rejects_duplicate_condition`,
    `quest_define_rejects_too_many_conditions`, `quest_define_rejects_duration_above_interval`,
    `quest_define_rejects_half_recurring`, plus `quest_define_rejects_{invalid_id,invalid_window,no_task,more_than_three_tasks,task_zero,total_zero,repeated_task*,condition_zero,duplicate_condition_far_apart}`;
  - progress: `quest_count_saturates_at_total`, `quest_count_max_value`,
    `quest_one_off_completes_once`, `quest_batch_two_tasks_one_quest_one_write_logic`,
    `quest_batch_duplicate_entries_merged_progress`;
  - batch: `quest_batch_duplicate_entries_merged`, `quest_batch_event_mode_one_event_per_task_merge`,
    `quest_batch_above_bound_reverts`, `quest_batch_bound_accepted`,
    `quest_batch_duplicates_count_toward_bound`, `quest_batch_first_position_uses_zero_sentinel`,
    `quest_batch_rejects_task_zero`;
  - records: `quest_prerequisites_all_required_logic`, `quest_completion_releases_acceptance`,
    `quest_acceptance_expires_at_rollover_logic`, `quest_accept_twice_same_interval_reverts`,
    `quest_abandon_expired_reverts`, `quest_recurring_completes_each_interval_logic`,
    `quest_claim_index_counts_claims`, `quest_claim_twice_reverts`,
    `quest_claim_uncompleted_reverts`, `quest_record_counters_past_u32`,
    `quest_record_counters_saturate`;
  - pages: `quest_retire_frees_slot_pages`, `pages_removal_keeps_pages_contiguous` (the retire
    algorithm of §3.5 on 4 pages in memory, with contiguity asserted after each removal);
  - packing: `quest_packing_round_trip_*`, `quest_empty_slot_reads_undefined`.

  The cases that need storage are left to ARC-03b: `quest_define_rejects_undefined_condition`,
  `_retired_condition`, `_association_overflow`, `quest_define_twice_reverts`,
  `quest_define_counts_dependents`, the retirement lifecycle, access control, events and hooks.
- **AC-4** Every one of the 146 tests has `#[available_gas(l2_gas: N)]` with
  `N = ceil(1.05 × measured)`. `scripts/gas.py packages/quest --check` passes locally and in CI.
  The benchmarks cover 3 tasks (`tasks_*`, `progress_*`), 7 conditions (`definition_new`,
  `conditions_span`, `prerequisites_met`), a full page (`page_*`), and 16 entries with and without
  duplicates (`batch_*`, `progress_add`). Every packing is benchmarked with every field at its
  maximum.
- **AC-5**
  - `u256`: none in the library except the felt → limbs conversion in `logic/bits.cairo::split`
    (see the deviations), which does no `u256` arithmetic. The tests use `u256` only in the oracles
    of `test_packing`.
  - Loops: tasks, pages and the conditions' spans are unrolled.
  - `batch_merge` checks `len <= MAX_ENTRIES` before any loop. Its fast path is a mask, and it
    falls back to comparisons only on a collision.
  - `definition_new` checks `len <= MAX_CONDITIONS` before its duplicate loop.
  - The loops of `batch_count_of`, `batch_first_position` and `prerequisites_met` run over the
    span they are given. That span is bounded by `MAX_ENTRIES` (a merged batch) or `MAX_CONDITIONS`
    (one record per condition), as stated in their doc comments, in `logic.cairo` and in the
    README. See the open questions.
- **AC-6** CI is green on PR #6: `cairo` pass, `package (packages/quest)` pass.

## Deviations from the brief

1. **A `u256` value in `split`, with its reason.** §3.3 says "no `u256` is needed … with one `u128`
   split at most". The only public way in the corelib to split a felt into two `u128` is
   `Into<felt252, u256>`: the `u128s_from_felt252` libfunc wrapped in a struct. The private
   libfunc and `bounded_int` are behind a feature flag. The code destructures
   `let u256 { low, high } = value.into();` and never does `u256` arithmetic. The reason is written
   next to the code. If AC-5 is read as "no `u256` token at all", this is a deviation.
2. **`definition_new` also calls `schedule_validate`**, after the id check and before the tasks.
   §3.2 lists the panics of `definition_new` without the schedule's. The brief, though, asks for
   `quest_define_rejects_duration_above_interval` and `_half_recurring` as pure parts of
   `quest_define_rejects_*`, and `define` "validates (§3.2)". The order of the panics is: id,
   window, interval, tasks, too many conditions, condition. §3 does not give this order.
3. **The panics of `page_set` and `page_pop`.** §3.2 says "panics when len == 0" for `page_pop` and
   gives no string; it says nothing for `page_set` out of range. Both panic with
   `'Index out of bounds'`, the corelib's string for a span. It is a private constant in
   `pages.cairo`, not in `errors`, so no error is added to the API. `page_set` requires
   `position < len`. `page_push` on a full page panics `'Quest: task full'`, the §3.5 string that
   `define` uses for a full task.
4. **`batch_merge` panics `'Quest: invalid task'` on a task id 0 even with a count of 0.** §3.2
   lists the two rules without an order. Checking the id first is the stricter reading
   (`quest_batch_rejects_task_zero_with_zero_count`).
5. **The types also export their packing impls** (`QuestDefinitionPacking`, …) from `logic`, so
   that tests and the component can name them. This adds to the API and changes nothing of §3.
6. **Budgets:** the benchmarks include their setup. The baselines are measured so the net cost can
   be read, as described under Cost.

## Escalations

None blocking.

- `packages/quest/README.md` still opens with "Not implemented yet … The logic and the component
  are written by ARC-03". The brief allows only a "Library" section, so I left that paragraph
  unchanged. The orchestrator (or ARC-03b) may update it.
- `scripts/gas.py` names tests `…_integrationtest::<file>::<fn>`. A `tests/lib.cairo` makes snforge
  name the crate `<package>_tests`, and every test would then show as unmeasured. This is not a
  defect today, since no package has a `tests/lib.cairo`. It is worth a line in
  `docs/WORKSPACE.md` §5 ("do not add `tests/lib.cairo`"), a shared file I did not edit.

## Open questions

- **Bound of the loops over a caller's span.** `batch_count_of`, `batch_first_position` and
  `prerequisites_met` take any `Span`. §3.2 bounds them through the component (a merged batch, one
  record per condition) and gives them no panic. I added none, since a new panic would be an API
  change. Should they assert `len <= MAX_ENTRIES` / `MAX_CONDITIONS` so that AC-5 holds for
  arbitrary callers? The cost is one comparison per call.
- **`page_pop` / `page_set` error strings**: keep the corelib-like `'Index out of bounds'`, or add
  named strings to §3.5 (API)?
- **`progress_is_complete` with `task_count == 0`** returns true (vacuous). `definition_new` never
  builds such a quest, so the case cannot arise from the component.

## Fix loop 1

Audit by [GPT-6-Astra], FAIL; the orchestrator accepted every point. The work was test-first: the
16 new packing tests and the new oracle were written and run before the fix, and they failed as
expected (`Tests: 150 passed, 16 failed`). Commits `df0a781` (fix and tests) and `5f297ed`
(GAS.md, changelog, README), pushed to PR #6. CI is green: `affected`, `cairo`,
`package (packages/quest)`, `links`, `scripts` all pass.

```
$ cd packages/quest && snforge test
Tests: 166 passed, 0 failed, 0 ignored, 0 filtered out
$ scripts/gas.py packages/quest --write
quiver_quest: wrote packages/quest/GAS.md (166 tests)
$ scripts/gas.py packages/quest --check
quiver_quest: 166 tests within budget, GAS.md up to date
$ scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml fmt --check
(no output, exit 0)
```

### Point 1 (major): narrow fields spill into their neighbours — fixed

`packages/quest/src/logic/types.cairo`:
- `:134` adds a private constant `'Packing: field out of range'`. Like the page panics, it is not
  added to `errors` and is not an API error.
- `:139–142`: `QuestDefinitionPacking::pack` asserts `task_count <= MAX_TASKS` (3, the maximum of
  its 2 bits) and `condition_count <= MAX_CONDITIONS` (7, the maximum of its 3 bits).
- `:259`: `QuestIdPagePacking::pack` asserts `len <= QUESTS_PER_PAGE` (point 2).

These three are the only narrow fields of any packed type. Every other field fills its packed
width exactly (`u64` in 64 bits, `u32` in 32, `u16` in 16, `bool` in 1), so it cannot spill.

Regression tests, at the first out-of-range value of each field, in
`tests/test_packing.cairo:339` onwards: `quest_packing_rejects_task_count_4`, `_task_count_255`,
`_condition_count_8`, `_condition_count_16` (the value that set `defined`), `_page_len_8`,
`_page_len_255`. `quest_packing_accepts_the_bounds` checks 3, 7 and 7.

On the question of a contradiction: the first report never claimed that the types round-trip for
every value of their Cairo type. The round trips were "every field at its maximum", meaning the
maximum of its packed width, and the oracle's `put` already asserted that width. So there is no
contradiction to escalate; the layout of §3.3 holds.

### Point 2 (major): a page `len` above 7 — fixed

- `types.cairo:259`: `pack` asserts `len <= QUESTS_PER_PAGE`.
- `types.cairo:267`: `unpack` rejects a decoded `len` above 7 with `'Packing: reserved bits set'`.
  That covers 2^227 (len 8) and any higher bit.

Tests: `quest_packing_rejects_page_len_8`, `quest_packing_rejects_page_len_255`,
`quest_unpacking_rejects_page_len_8` (the malformed felt 2^227), and
`quest_unpacking_rejects_page_bit_230`.

### Point 3 (minor): reserved bits read as values — fixed for every type

`types.cairo:135` adds a private constant `'Packing: reserved bits set'`. Each unpacking now
rejects a bit above its encoding:
- `QuestDefinition` at `:179`: `live_dependents` must fit `u16`, so no bit at or above 216.
- `QuestTasks` at `:206`: `t2.total` must fit `u32`, so no bit at or above 192.
- `QuestConditions` at `:252`: nothing may remain above bit 224.
- `QuestIdPage` at `:267`: `len` at most 7, so no bit at or above 227 (point 2).
- `QuestProgress` at `:283`: the felt must fit one `u128`. At `:289`, bit 97 alone is `claimed`,
  and any bit from 98 to 127 panics.
- `QuestRecord` at `:320`: `accepted_interval` must fit `u64`, so no bit at or above 194.

The layouts of §3.3 have no gaps, so every reserved bit is above the top field. One test per type
sets the first reserved bit: `quest_unpacking_rejects_definition_bit_216`, `_tasks_bit_192`,
`_conditions_bit_224`, `_page_len_8`, `_progress_bit_98`, `_record_bit_194`. Two more set a higher
bit: `_progress_bit_128`, `_page_bit_230`. `quest_unpacking_rejects_definition_felt_minus_one`
unpacks the felt P − 1. `quest_unpacking_progress_reads_bit_97_alone` asserts that 2^97 unpacks to
`claimed` only and 2^96 to `completed` only.

### Point 4 (minor): the late worst cases of `batch_merge` — added

`tests/test_bench.cairo`:
- `:56` `fifteen_then(last)` builds tasks 1..=15 (counts 1..=15), then `last` with count 1.
- `:71` `bench_baseline_fifteen_then_one` measures that setup alone.
- `:162` `bench_batch_merge_late_duplicate` merges `[1..15, 15]`.
- `:169` `bench_batch_merge_late_modulo_collision` merges `[1..15, 129]`.

| Benchmark | Measured | Budget | Setup baseline | Net |
|---|---|---|---|---|
| `bench_batch_merge_sixteen_distinct` (fast path) | 181 896 | 190 991 | 62 900 | 118 996 |
| `bench_batch_merge_sixteen_with_duplicates` (earlier "worst") | 545 921 | 573 218 | 75 500 | 470 421 |
| `bench_batch_merge_late_duplicate` [1..15, 15] | 749 113 | 786 569 | 52 410 | 696 703 |
| `bench_batch_merge_late_modulo_collision` [1..15, 129] | **753 023** | **790 675** | 52 410 | **700 613** |

The worst case of `batch_merge` is now the late modulo collision: 753 023 measured, budget
790 675. The fast pass runs 15 entries and fails at the 16th, then the plain merge runs over 16
entries that all survive, which is the most comparisons it can make. That is the figure ARC-03b
should carry for the merge step of `progress_many`.

### Point 5 (minor): the progress oracle uses production code — fixed

`tests/test_progress.cairo:133` adds `plain_lookup`, an indexed scan that returns the first
matching count. `plain_add` now uses it instead of `batch_count_of`, and the test imports nothing
from the library but the types and the functions under test.

### Doc comments — done

- `src/logic/batch.cairo:76`: `batch_count_of` expects a merged batch (call `batch_merge` first).
  On an unmerged batch it returns the count of the first matching entry only.
- `src/logic/progress.cairo:21`: `progress_add` expects a merged batch. It applies only the first
  matching entry per task.

Also updated: `README.md` (the merge falls back to comparisons when two ids are equal modulo 128)
and `CHANGELOG.md` `Unreleased` (the two packing panics, which are not API errors).

### Budgets changed in this loop

A lowered budget needs no reason. Each raised budget and its reason:

| Test | Measured before | Measured after | Budget before | Budget after | Reason |
|---|---|---|---|---|---|
| `bench_pack_unpack_definition` | 42 710 | 43 450 | 44 846 | 45 623 | the two width asserts in `pack` |
| `bench_pack_unpack_page` | 36 690 | 37 630 | 38 525 | 39 512 | the width assert in `pack` and the `len` check in `unpack` |
| `bench_pack_unpack_progress` | 28 660 | 29 130 | 30 093 | 30 587 | the `claimed <= 1` check |
| `quest_packing_round_trip_definition_{zero,max,mixed}` | 2 529 620 / 27 678 040 / 7 558 750 | 2 530 360 / 27 686 180 / 7 560 970 | 2 656 101 / 29 061 942 / 7 936 688 | 2 656 878 / 29 070 489 / 7 939 019 | same asserts, on each call |
| `quest_packing_round_trip_page` / `_progress` | 12 916 840 / 11 904 990 | 12 922 480 / 11 909 220 | 13 562 682 / 12 500 240 | 13 568 604 / 12 504 681 | same |
| `progress_add_matches_the_plain_formula` | 6 398 420 | 9 379 140 | 6 718 341 | 9 848 097 | the oracle's own indexed lookup (test code only) |

Lowered, because `expect` replaced `unwrap` with no extra check:
- `bench_pack_unpack_tasks`: 31 590 → 31 390.
- `bench_pack_unpack_record`: 29 220 → 29 020.
- `quest_packing_round_trip_tasks` and `_record`.
- `quest_empty_slot_reads_undefined`.
- `quest_record_counters_past_u32`.

All other benchmarks are unchanged. The 20 new tests have budgets at `ceil(1.05 × measured)`, as
recorded in `packages/quest/GAS.md`, which now lists 166 tests.
