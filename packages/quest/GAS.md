# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
set at `ceil(1.05 x measured)` and never above it; a budget kept tighter, between the
measure and that ceiling, also passes (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest::constants::tests::quest_bounds_are_the_accepted_ones` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::errors::tests::quest_error_strings_are_the_accepted_ones` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_conditions_span_seven` | 11710 | 12296 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_definition_new_three_tasks_seven_conditions` | 141470 | 148544 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_pack_unpack_conditions` | 27790 | 29180 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_pack_unpack_definition` | 32730 | 34367 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_pack_unpack_tasks` | 23560 | 24738 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_tasks_index_of_absent` | 13020 | 13671 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::bench_tasks_span_three` | 12220 | 12831 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::conditions_span_has_count_entries` | 96700 | 101535 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_defined_already_exists` | 11860 | 12453 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_errors_are_those_of_0_1_0` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_event_carries_its_key_and_values` | 32250 | 33863 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_exists_with_its_tasks` | 12230 | 12842 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_new_keeps_its_inputs` | 163500 | 171675 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_new_one_task` | 19280 | 20244 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_new_round_trips_through_the_spans` | 63600 | 66780 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_new_three_tasks_seven_conditions` | 152980 | 160629 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_new_unused_slots_are_zero` | 30360 | 31878 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_reads_the_same_whatever_the_status` | 45100 | 47355 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_condition_zero` | 16850 | 17693 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_duration_above_interval` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_eight_conditions` | 8320 | 8736 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_four_tasks` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_half_recurring` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_id_zero_first` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_no_task` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_repeated_condition` | 113870 | 119564 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_repeated_task` | 10410 | 10931 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_self_condition` | 16940 | 17787 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_task_zero` | 8710 | 9146 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_total_zero` | 9810 | 10301 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_rejects_window_second` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_schedule_matches_the_oracle` | 1672260 | 1755873 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_storage_is_the_layout_of_0_1_0` | 4198990 | 4408940 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_undefined_does_not_exist` | 8380 | 8799 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::definition_undefined_reads_with_no_task` | 8480 | 8904 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_condition_zero` | 19950 | 20948 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_duplicate_condition` | 25920 | 27216 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_duplicate_condition_far_apart` | 118470 | 124394 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_duration_above_interval` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_half_recurring` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_invalid_id` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_invalid_window` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_more_than_three_tasks` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_no_task` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_repeated_task` | 12680 | 13314 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_repeated_task_first_and_last` | 13580 | 14259 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_repeated_task_second_and_last` | 12510 | 13136 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_self_condition` | 14280 | 14994 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_task_zero` | 11310 | 11876 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_too_many_conditions` | 10820 | 11361 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_define_rejects_total_zero` | 12310 | 12926 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_empty_slot_reads_undefined` | 27470 | 28844 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_accepts_the_bounds` | 4858280 | 5101194 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_presence_bits_at_their_positions` | 1102460 | 1157583 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_rejects_condition_count_16` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_rejects_condition_count_8` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_rejects_task_count_255` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_rejects_task_count_4` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_round_trip_conditions` | 19261710 | 20224796 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_round_trip_definition_max` | 23746970 | 24934319 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_round_trip_definition_mixed` | 7128560 | 7484988 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_round_trip_definition_zero` | 2380740 | 2499777 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_packing_round_trip_tasks` | 15126820 | 15883161 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_unpacking_rejects_conditions_bit_224` | 369540 | 388017 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_unpacking_rejects_definition_bit_215` | 417410 | 438281 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_unpacking_rejects_definition_felt_minus_one` | 23870 | 25064 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::quest_unpacking_rejects_tasks_bit_192` | 351530 | 369107 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::tasks_index_of_finds_used_slots_only` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::definition::tests::tasks_span_has_task_count_entries` | 35380 | 37149 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::bench_held_slot_last` | 22870 | 24014 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::bench_pack_unpack_held_slot` | 37900 | 39795 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::held_slot_pairs_entries_and_pads_with_empty` | 12410 | 13031 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_packing_rejects_held_acceptance_2_30` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_packing_rejects_held_counter_2_30` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_packing_rejects_held_interval_2_48` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_packing_round_trip_held_slot` | 40065100 | 42068355 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_unpacking_reads_held_bit_250_as_kept` | 420850 | 441893 | 2026-10-02 | 1126423 |
| `quiver_quest::models::held::tests::quest_unpacking_rejects_held_bit_251` | 27340 | 28707 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::bench_pack_unpack_progress` | 21300 | 22365 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::bench_progress_add_three_tasks_sixteen_entries` | 148160 | 155568 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::bench_progress_is_complete_three_tasks` | 13650 | 14333 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_add_ignores_other_tasks` | 39610 | 41591 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_add_keeps_claimed` | 9080 | 9534 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_add_matches_the_plain_formula` | 9266710 | 9730046 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_add_three_tasks_partial_then_complete` | 55840 | 58632 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_add_touches_only_task_count_slots` | 16700 | 17535 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::progress_is_complete_per_task_count` | 8110 | 8516 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_batch_duplicate_entries_merged_progress` | 51319 | 53885 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_batch_two_tasks_one_quest_one_write_logic` | 42502 | 44628 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_count_max_value` | 26900 | 28245 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_count_max_value_below_total` | 14450 | 15173 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_count_saturates_at_total` | 38140 | 40047 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_one_off_completes_once` | 22160 | 23268 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_packing_round_trip_progress` | 11901390 | 12496460 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_unpacking_progress_reads_bit_97_alone` | 681740 | 715827 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_unpacking_rejects_progress_bit_128` | 335370 | 352139 | 2026-10-02 | 1126423 |
| `quiver_quest::models::progress::tests::quest_unpacking_rejects_progress_bit_98` | 348370 | 365789 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::bench_claim` | 10110 | 10616 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::bench_pack_unpack_record` | 15920 | 16716 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::bench_prerequisites_met_seven` | 26970 | 28319 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::bench_record_complete` | 8310 | 8726 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::claim_marks_claimed_and_counts` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::prerequisites_met_when_each_completed_once` | 35850 | 37643 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_claim_index_counts_claims` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_claim_twice_reverts` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_claim_uncompleted_reverts` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_claim_uncompleted_reverts_before_claimed` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_packing_round_trip_record` | 7135740 | 7492527 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_prerequisites_all_required_logic` | 22890 | 24035 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_record_counters_past_u32` | 15210 | 15971 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_record_counters_saturate` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_recurring_completes_each_interval_logic` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::quest_unpacking_rejects_record_bit_129` | 348330 | 365747 | 2026-10-02 | 1126423 |
| `quiver_quest::models::record::tests::record_complete_keeps_unlocked_and_claims` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_count_of_present_and_absent` | 39430 | 41402 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_first_position_at_the_bound` | 144280 | 151494 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_first_position_is_the_smallest_position` | 29100 | 30555 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_drops_zero_counts` | 75795 | 79585 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_empty` | 12880 | 13524 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_ids_equal_modulo_128_are_distinct` | 175628 | 184410 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_keeps_distinct_entries_in_order` | 46008 | 48309 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_keeps_the_position_of_first_occurrence` | 84645 | 88878 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_matches_the_plain_merge` | 8496664 | 8921498 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::batch_merge_saturates_duplicates` | 263484 | 276659 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_baseline_empty` | 6410 | 6731 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_baseline_fifteen_then_one` | 44580 | 46809 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_baseline_sixteen_distinct` | 55070 | 57824 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_baseline_sixteen_with_duplicates` | 67670 | 71054 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_count_of_absent` | 82760 | 86898 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_first_position_absent` | 102660 | 107793 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_merge_late_duplicate` | 741383 | 778453 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_merge_late_modulo_collision` | 745293 | 782558 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_merge_sixteen_distinct` | 174166 | 182875 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::bench_batch_merge_sixteen_with_duplicates` | 538191 | 565101 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_above_bound_reverts` | 66530 | 69857 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_bound_accepted` | 217356 | 228224 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_duplicate_entries_merged` | 48099 | 50504 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_duplicates_count_toward_bound` | 57410 | 60281 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_event_mode_one_event_per_task_merge` | 77679 | 81563 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_first_position_uses_zero_sentinel` | 23490 | 24665 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_rejects_task_zero` | 23306 | 24472 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_rejects_task_zero_with_zero_count` | 30722 | 32259 | 2026-10-02 | 1126423 |
| `quiver_quest::types::batch::tests::quest_batch_zero_counts_count_toward_bound` | 66530 | 69857 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::bench_held_contains_absent` | 33440 | 35112 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::bench_held_position_absent` | 30740 | 32277 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::bench_held_remove_first` | 38570 | 40499 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::held_contains_needs_the_same_interval` | 39540 | 41517 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::held_position_finds_the_quest` | 31010 | 32561 | 2026-10-02 | 1126423 |
| `quiver_quest::types::held::tests::held_remove_keeps_the_order` | 121340 | 127407 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::bench_schedule_interval_id` | 12300 | 12915 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::bench_schedule_is_active` | 11400 | 11970 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::bench_schedule_validate` | 9650 | 10133 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::quest_daily_interval_aligned_on_utc_midnight` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::quest_interval_id_is_u64` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_interval_id_never_panics_at_the_bounds` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_interval_id_none_when_inactive` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_interval_id_one_off_is_zero` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_interval_id_recurring` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_is_active_duration_equal_to_interval_is_always_active` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_is_active_never_ends_when_end_is_zero` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_is_active_one_off_window` | 8110 | 8516 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_is_active_recurring` | 8410 | 8831 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_accepts_valid_schedules` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_duration_above_interval` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_duration_above_interval_at_max` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_empty_window` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_end_before_start` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_half_recurring_duration_only` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest::types::schedule::tests::schedule_validate_rejects_half_recurring_interval_only` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_completed_reverts` | 16240656 | 16504411 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5557210 | 5680122 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 8940828 | 9046231 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6424200 | 6565472 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_removes_from_list` | 19196930 | 19240368 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10617156 | 10769416 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11566736 | 11711455 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14948702 | 15100819 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_list_full_reverts` | 16902170 | 17041710 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 11951110 | 12123405 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 7052662 | 7183147 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5569690 | 5686926 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 9243748 | 9383617 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_numbers_are_new_on_renewal` | 14144300 | 14341457 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_completed_leaves_list` | 22571266 | 22640201 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10701246 | 10850360 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_expired_acceptance_pruned` | 16936140 | 17038529 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_interval_id_boundary_2_48` | 9468132 | 9647361 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_list_layout` | 13218980 | 13423211 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_pruning` | 36836974 | 36867605 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_shrink` | 17453310 | 17579877 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5748640 | 5868944 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_accept::quest_retired_pruned_at_accept` | 15967950 | 16062669 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5695290 | 5819016 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 4759750 | 4880684 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14969186 | 15147317 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 6067296 | 6139063 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 3030840 | 3118784 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2041460 | 2121935 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4532800 | 4653422 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7619582 | 7739290 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2911680 | 2993666 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5886240 | 6021404 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 5424450 | 5525394 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 5061610 | 5199212 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 3035920 | 3118028 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 3016010 | 3087462 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_growth` | 29718112 | 29819394 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_mixed` | 35160852 | 35238591 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_regrow` | 8786330 | 8883042 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_completed` | 40387346 | 40463489 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_expired` | 35077562 | 35162266 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 2903080 | 2974640 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 563315790 | 574873341 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 4347376 | 4425127 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 23452132 | 23606775 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 870620 | 908177 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_full_list` | 9189950 | 9253293 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2103590 | 2166675 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 40387346 | 40463489 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4` | 10360770 | 10439730 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing` | 13728070 | 13975395 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing_hook` | 13728070 | 13975395 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_hook` | 10360770 | 10439730 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8` | 17054840 | 17293364 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing` | 23787610 | 24362772 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing_hook` | 23787610 | 24362772 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_hook` | 17054840 | 17293364 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_reporter_registered` | 1492230 | 1546797 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 26232192 | 26319618 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_three_held` | 7065540 | 7150133 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::baseline_two_held` | 4641830 | 4720107 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 5100200 | 5163596 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_shrink` | 7552280 | 7623536 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_worst` | 9810980 | 9845651 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_growth` | 31779282 | 31832422 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_mixed` | 37003132 | 38853289 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_plain` | 2903080 | 2974640 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_regrow` | 9565310 | 9622221 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_completed` | 42317036 | 44432888 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_expired` | 36821492 | 36835893 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4752296 | 4807873 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 26231692 | 26319219 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1087766 | 1131161 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_all_complete` | 14628244 | 14695878 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_none_counts` | 10213456 | 10230451 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_completes` | 11441896 | 11463613 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_counts` | 10689976 | 10715047 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2706423 | 2831276 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2648803 | 2770775 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2135096 | 2231383 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4` | 16821613 | 16955866 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing` | 16972913 | 17114731 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing_hook` | 18847833 | 19020397 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_hook` | 18696533 | 18861532 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8` | 28971913 | 29280241 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing` | 29272683 | 29596049 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing_hook` | 33022523 | 33407381 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_hook` | 32721753 | 33091573 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_nothing_held` | 2339846 | 2405294 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3780416 | 3851869 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 4347376 | 4425127 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 27408132 | 28778539 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1492230 | 1546797 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter_revoke` | 1311040 | 1342604 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter_unchanged` | 1712840 | 1764494 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 40552256 | 40632151 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 40710726 | 40783214 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_held_full` | 40703716 | 40777114 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 40742976 | 40813507 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 40517716 | 40594414 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 40943816 | 40985119 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 40687916 | 40767034 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 569194416 | 580778149 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 13648786 | 13761254 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 13677936 | 13755385 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11845826 | 11964389 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 23549972 | 23615973 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13909266 | 14031041 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 7140966 | 7280276 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 10437066 | 10552391 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 9320416 | 9407419 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 8262730 | 8399780 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 49001380 | 49792092 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4463930 | 4581108 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3801840 | 3919094 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 4960560 | 5063300 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 3035430 | 3123603 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 14374590 | 14690361 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3101590 | 3180471 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 6522230 | 6645450 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4455630 | 4566093 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2747520 | 2879541 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 8152200 | 8293026 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 9240870 | 9436476 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 11694890 | 11807114 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5785279 | 5922178 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 5491916 | 5616604 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5984546 | 6122735 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5726466 | 5855468 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3230588 | 3323689 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 6524902 | 6657139 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 5559160 | 5660120 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 5091700 | 5220317 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 16518072 | 16647648 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 79554262 | 80571217 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 56139702 | 56790649 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 84355448 | 85344712 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 60940888 | 61564144 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h0` | 911440 | 951164 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_complete` | 2175550 | 2278479 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_count` | 2175550 | 2278479 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_done` | 2597620 | 2721653 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_expired` | 2175550 | 2278479 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_miss` | 2175550 | 2278479 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_complete` | 3017730 | 3162768 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_count` | 3017730 | 3162768 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_done` | 3861770 | 4049010 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_expired` | 3017730 | 3162768 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_miss` | 3017730 | 3162768 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_complete` | 5129610 | 5380242 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_count` | 5129610 | 5380242 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_done` | 6817590 | 7152621 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_expired` | 5129610 | 5380242 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_miss` | 5129610 | 5380242 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_complete` | 9353370 | 9815190 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_count` | 9353370 | 9815190 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_done` | 12729230 | 13359843 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_expired` | 9353370 | 9815190 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_miss` | 9353370 | 9815190 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h0` | 1923833 | 2004727 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_complete` | 4472893 | 4624540 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_count` | 3906673 | 4052059 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_done` | 3719473 | 3877150 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_expired` | 3247253 | 3388018 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_miss` | 3437603 | 3575285 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_complete` | 6723163 | 6918023 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_count` | 5529103 | 5714660 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_done` | 5154603 | 5364422 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_expired` | 4210263 | 4386431 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_miss` | 4590963 | 4761113 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_complete` | 11591673 | 11897659 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_count` | 9141833 | 9432427 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_done` | 8392733 | 8731531 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_expired` | 6504153 | 6775654 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_miss` | 7265553 | 7525333 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_complete` | 21272783 | 21804524 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_count` | 16311383 | 16815554 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_done` | 14813083 | 15413342 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_expired` | 11036023 | 11501693 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_miss` | 12558823 | 13001366 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 15685648 | 15860332 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12683496 | 12824833 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12473126 | 12628934 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 14528342 | 14682751 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 15658932 | 15796581 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 22568428 | 22679641 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 23957948 | 24136957 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 23520768 | 23671618 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 14606652 | 14764977 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 23340368 | 23523148 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_accept` | 15440742 | 15600241 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4138520 | 4237958 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 445690 | 467975 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5299890 | 5564885 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 4066190 | 4269500 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_baseline` | 42610160 | 44740668 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_then_change_100` | 49820060 | 50744495 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_empty` | 717000 | 752850 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_set` | 48127600 | 48967622 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_changed_then_restored` | 62456900 | 65579745 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_other` | 55338200 | 58105110 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_zero` | 15138200 | 15895110 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_unchanged` | 55338200 | 58105110 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_set_then_restored` | 15046300 | 15798615 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_to_value` | 48127600 | 48967622 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_unchanged` | 7927600 | 8323980 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2308960 | 2424408 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_held_100` | 2675760 | 2809548 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1153160 | 1210818 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1708160 | 1793568 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 47855590 | 48681801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 55336800 | 58103640 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 55336800 | 58103640 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 48126900 | 48966887 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5281050 | 5393724 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5150010 | 5262222 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3308650 | 3405864 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 6191279 | 6311455 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 3038850 | 3127194 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 9167782 | 9296923 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3103512 | 3190260 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10435692 | 10587426 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6206592 | 6327534 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10818022 | 10968145 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10962452 | 11097747 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 8415562 | 8549722 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 8240172 | 8368713 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_held_by_one_player_not_progressed_by_another` | 10357712 | 10531440 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 8685046 | 8818400 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 6398746 | 6524675 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_not_held_not_progressed` | 6709402 | 6839944 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10793522 | 10942420 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 6311756 | 6431866 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 22543744 | 22638393 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 69111406 | 70000178 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_acceptance_counter_wraps_at_2_30` | 26781338 | 28120405 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_counter_wrap_without_renewal_progresses_both` | 14755536 | 14801605 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_hook_accepting_another_quest_keeps_counts_after_16_bit_wrap` | 16912922 | 17758569 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | 21818786 | 22909726 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | 62070234 | 65173746 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_then_accept_not_progressed` | 18714662 | 19650396 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_abandon_accept_not_progressed` | 13219226 | 13880188 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 8138036 | 8544938 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | 17799102 | 18689058 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 62998574 | 66148503 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 64803154 | 68043312 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 12735296 | 13372061 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 18906062 | 19851366 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 66783670 | 70122854 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 11536602 | 12113433 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewal_after_counter_wrap_not_progressed` | 18837812 | 19779703 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewed_not_progressed_others_are` | 21145046 | 22202299 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 61412044 | 64480788 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 14362346 | 15078605 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 4899080 | 5005046 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 6311260 | 6410975 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7546420 | 7631936 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 15802030 | 15893220 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 6665480 | 6791967 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 5129050 | 5235374 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 4993840 | 5104533 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 13867116 | 13971244 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4677880 | 4769457 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 6209390 | 6330891 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 8979366 | 9100766 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_track_none::track_none_component_emits_action_events_only` | 7014712 | 7089781 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_track_none::track_none_component_revoked_reporter_emits_nothing` | 842940 | 845009 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_track_none::track_none_refuses_with_the_packages_errors` | 908390 | 940000 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_track_own::own_impl_tracks_the_definition_only` | 2059420 | 2120423 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_track_own::own_impl_tracks_the_reporter_only` | 1991090 | 2048676 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::baseline_writes_setup` | 4585280 | 4660730 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::baseline_writes_setup_totals_two` | 4585280 | 4660730 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_completing_writes_p_and_r` | 6554576 | 6624877 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicate_entries_write_p_once` | 5967079 | 6036355 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicates_several_counts_write_each_p_once` | 6633295 | 6714042 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_not_completing_writes_p_only` | 5926296 | 5993533 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_not_completing_write_p_once` | 5941502 | 6009499 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_write_p_and_r_once` | 6507192 | 6581424 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_component_writes::write_costs_73_820_sierra_gas` | 1399770 | 1431150 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::baseline_models` | 272230 | 285842 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::baseline_models_existing` | 1107190 | 1162550 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::baseline_models_get` | 1110240 | 1165752 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::baseline_models_wide` | 273470 | 287144 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_hand_get` | 1145660 | 1202943 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_tracked_created` | 786780 | 818801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_tracked_overwritten` | 1219740 | 1273283 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_untracked_created` | 741760 | 771530 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_untracked_overwritten` | 1174720 | 1226012 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_get` | 1145660 | 1202943 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_set_tracked_created` | 786780 | 818801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_set_tracked_overwritten` | 1219740 | 1273283 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_set_untracked_created` | 741760 | 771530 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_set_untracked_overwritten` | 1174720 | 1226012 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::bench_store_set_wide_created` | 743200 | 773042 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::store_tracked_set_emits_its_event_on_every_write` | 2556790 | 2624601 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::store_untracked_set_emits_nothing` | 2054560 | 2112800 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store::store_writes_what_the_hand_writes` | 3006230 | 3084333 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::baseline_definition` | 332780 | 349419 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::baseline_definition_read` | 2133440 | 2201504 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::bench_hand_get_definition_worst` | 2281870 | 2338455 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::bench_hand_set_definition_worst` | 2035230 | 2098173 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::bench_store_get_definition_worst` | 2281840 | 2338424 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::bench_store_set_definition_worst` | 2030270 | 2092965 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::store_focused_reads_return_the_slots` | 3204000 | 3276242 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::store_get_definition_reads_the_model_back` | 4604540 | 4701722 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::store_set_definition_emits_quest_defined_once` | 3167180 | 3255431 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::store_set_definition_writes_the_slots_of_0_1_0` | 6438750 | 6612249 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_definition::store_status_write_emits_nothing_and_keeps_the_definition` | 3397310 | 3441543 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::baseline_model_definition` | 332780 | 349419 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::baseline_reporter` | 271020 | 284571 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::baseline_silent_definition` | 332780 | 349419 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::baseline_silent_reporter` | 271020 | 284571 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_hand_set_definition_silent_worst` | 1880130 | 1935318 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_hand_set_model_definition_silent_worst` | 1875170 | 1930110 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_hand_set_model_definition_worst` | 2030270 | 2092965 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_hand_set_reporter` | 784250 | 816144 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_hand_set_reporter_silent` | 740650 | 770364 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_store_set_definition_silent_worst` | 1875170 | 1930110 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_store_set_model_definition_worst` | 2030270 | 2092965 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_store_set_reporter` | 784250 | 816144 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::bench_store_set_reporter_silent` | 740650 | 770364 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::store_held_list_writes_only_the_slots_that_change` | 2941810 | 2972802 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::store_prerequisites_met_reads_each_record` | 4085630 | 4136013 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::track_all_definition_rewritten_emits_once_per_write` | 3191710 | 3215625 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::track_all_reporter_emits_once_per_write` | 1043890 | 1051596 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::track_none_definition_emits_nothing` | 6448990 | 6623001 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::track_none_reporter_emits_nothing` | 1225750 | 1242549 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::untracked_held_slot_emits_nothing` | 1160630 | 1189713 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::untracked_progress_emits_nothing` | 1480530 | 1503978 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::untracked_record_emits_nothing` | 1099180 | 1125191 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_store_models::untracked_status_emits_nothing` | 3016170 | 3050460 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::baseline_track_all` | 272230 | 285842 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::baseline_track_none` | 272230 | 285842 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_all_by_constant` | 786780 | 818801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_all_by_emitter` | 786780 | 818801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_all_hand_emitted` | 786780 | 818801 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_none_by_constant` | 741760 | 771530 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_none_by_emitter` | 741760 | 771530 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::bench_track_none_hand_silent` | 741760 | 771530 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::track_all_emits_once_per_write` | 2049700 | 2098247 | 2026-10-02 | 1126423 |
| `quiver_quest_integrationtest::test_tracking::track_none_emits_nothing` | 1683810 | 1714062 | 2026-10-02 | 1126423 |

## Scarb 2.20.1 and snforge 0.64.0 (ARC-10, D-180)

**The table above is measured on Scarb 2.20.1 (Cairo 2.20.0) and snforge 0.64.0**, single-threaded
(`RAYON_NUM_THREADS=1`, D-176, kept). The sections below are written by hand; those that give the
package's *current* figures were re-derived from this table: "Optional tracking", "Every
entrypoint, before and after" (the *Before* column is Scarb 2.19.4, so the difference now holds the
compiler's effect too), "The grid", "Against the cap" and Grim World's case. The others are records
of the step they describe, measured on Scarb 2.19.4 and snforge 0.61, and are left as they were
(ARC-07c's table of moved tests, ARC-06's mechanism, 0.1.0's cost model, the fix loops).

What moved against `a74f2f1` (Scarb 2.19.4, snforge 0.61.0), 511 tests in both (one renamed):

- **Every test moved** (319 up, 192 down). Two causes. snforge 0.64 charges **15 000 more per
  storage write** (a created slot 474 106, was 459 106; an overwritten one 72 106, was 57 106) and
  **6 000 more per storage read** (36 205, was 30 205): the probes of `test_component_probe`. And a
  fixed overhead of every test is 8 030 lower (the empty benchmark baselines).
- **The smallest tests** (no storage) are cheaper by the overhead: the 13 720 of the guard tests of
  the bounds and the error strings become 6 010.
- **The calls that write move most**: +24.8 % on `probe_transition_zero_set_then_restored`
  (12 054 530 → 15 046 300), +24.6 % on `probe_transition_value_to_zero`.
- **Largest rises, in L2 gas**: `quest_batch_bound_accepted` +16 072 370 (553 122 046 → 569 194 416,
  the §5.1 witness with its 28 quests per task not held), `baseline_batch_bound_accepted` +15 817 370,
  `probe_transition_value_changed_then_restored` +4 491 770.
- **Largest falls, in L2 gas**: 8 230 at most (`probe_transition_baseline_empty`), the overhead
  above.
- **Budgets**: 30 tests exceeded theirs and **were raised**, each with the note
  `// gas: raised, D-180 Scarb 2.20.1` (9 in `test_component_probe`, 18 in
  `test_component_reentry`, 3 in `test_component_bench`; the rise is at most 5 % over the new
  measure, as for every budget). 192 budgets were far above their new measure and were
  **lowered**, to `ceil(1.05 × measured)`. The six `test_component_writes` guards are on Sierra
  gas, not on the budget: their references moved with the writes (below).
- **The guard of the writes** (`test_component_writes`): a second write in a call now costs
  **73 820** Sierra gas, not 58 820 (the test is `write_costs_73_820_sierra_gas`); the six
  references moved by +59 710 to +87 570 and are set to the new measures, the tolerance of 20 000
  is kept (a write added to a call still moves it by 73 820).
- **The worst calls stay under the 20 M cap** (against the cap, above): the worst, `progress_many`
  with H = 8, created, a hook writing one slot, is 15 666 913 (78 % of the cap; 15 045 913 and 75 % on 2.19.4).

## Where the tests went (ARC-07c, D-167)

The unit tests of a module are in its file, under `#[cfg(test)] mod tests`
(`quiver_quest::<module>::tests::<test>` in the table above); `tests/` keeps what deploys a
contract. **A move, not a rewrite: the 171 tests that moved cost the same, to the unit, as in
`tests/`, and keep their budgets** (checked test by test against the table of `5fb465a`). Their
sections below name the files they came from: read `test_x::` as the module that follows.

| From (`tests/`) | To | Tests |
|---|---|---|
| `test_batch` | `types::batch` | 19 |
| `test_bench` (batch baselines, merge, count, first position) | `types::batch` | 10 |
| `test_bench` (schedule) | `types::schedule` | 3 |
| `test_schedule` | `types::schedule` | 17 |
| `test_bench` (held list's position, contains, remove) | `types::held` | 3 |
| `test_held` | `types::held` 3, `models::held` 1 | 4 |
| `test_bench` (held slot, pack and unpack of the held slot) | `models::held` | 2 |
| `test_packing` (held slot) | `models::held` | 6 |
| `test_definition`, `test_model_definition` | `models::definition` | 46 |
| `test_bench` (definition, tasks, conditions, their packing) | `models::definition` | 7 |
| `test_packing` (slots A, B and C) | `models::definition` | 16 |
| `test_progress` | `models::progress` | 12 |
| `test_bench` (progress, its packing) | `models::progress` | 3 |
| `test_packing` (progress) | `models::progress` | 4 |
| `test_record` | `models::record` | 11 |
| `test_bench` (record, claim, its packing) | `models::record` | 4 |
| `test_packing` (record) | `models::record` | 2 |
| `test_constants`, `test_errors` | `constants`, `errors` | 1 + 1 |

By module: `constants` 1, `errors` 1, `models::definition` 69, `models::held` 9,
`models::progress` 19, `models::record` 17, `types::batch` 29, `types::held` 6,
`types::schedule` 20: 171. The files `test_batch`, `test_bench`, `test_constants`,
`test_definition`, `test_errors`, `test_held`, `test_model_definition`, `test_packing`,
`test_progress`, `test_record` and `test_schedule` are gone. `test_tracking`, `test_store*` and
`test_component_*` deploy a contract and stay (339 tests, unchanged).

What the moved tests share is in `src/testing/` (`#[cfg(test)]`, not compiled in the library):
`helpers` (the builders of `tests/helpers.cairo` the unit tests use, and `recurring`,
`eight_held`, `three_tasks`, shared by the benchmarks of several modules), `oracle` (0.1.0's
functions as oracles, for `models::definition`) and `packing` (the `u256` oracle of the packed
types, shared by four models). `tests/helpers.cairo` and `tests/oracle.cairo` keep the part the
integration tests use; `tests/` cannot reach `src/testing/`, so a few builders exist in both.

**The only new tests**: `own_impl_tracks_the_definition_only` and `own_impl_tracks_the_reporter_only`
(`test_component_track_own`, with `MockTrackDefinitionOnly` and `MockTrackReporterOnly` in
`tests/mocks.cairo`): 1 951 120 and 2 019 450, budgets 2 048 676 and 2 120 423.

## `quiver_quest` 0.2.0 (ARC-07a)

Written by hand, like the sections below; figures from the table above. A cost is the benchmark
minus its baseline, both through a dispatcher. "Before" is the table of `6f4d93a` (ARC-06, on
`main`), which is 0.1.0's for every entrypoint but `define` (0.1.0: 2 590 440). The layout, the
models and the mechanism are in [docs/research/ARC-06-model-store.md](../../docs/research/ARC-06-model-store.md) §7.

### Optional tracking

`tests/test_tracking.cairo` (`MockTrackAll`, `MockTrackNone`: one model of one slot, created, each
choice with its hand-written twins in the same contract; baseline 272 230):

| Choice | The constant (`if Tracking::X`) | An emitter impl per model | By hand | Store − hand |
|---|---|---|---|---|
| `TrackNone` | 469 530 | 469 530 | 469 530, the write with no event code (`bench_track_none_hand_silent`) | **0** |
| `TrackAll` | 514 550 | 514 550 | 514 550, the write then `emit` (`bench_track_all_hand_emitted`) | **0** |

The constant is folded: the untracked choice is ARC-06's hand-written untracked write to the unit
(469 530, `test_store`), the tracked one ARC-06's tracked write (514 550). The constant is adopted.

`tests/test_store_models.cairo`, the package's tracked models (`MockDefinitionStore` under
`TrackAll`, `MockSilentStore` under `TrackNone`):

| Model | Choice | Benchmarks (baseline) | Store | 0.1.0 by hand | Store − hand |
|---|---|---|---|---|---|
| `QuestReporter`, created | `TrackNone` | `bench_store_set_reporter_silent`, `bench_hand_set_reporter_silent` (`baseline_silent_reporter`) | 469 630 | 469 630 | **0** |
| `QuestReporter`, created | `TrackAll` | `bench_store_set_reporter`, `bench_hand_set_reporter` (`baseline_reporter`) | 513 230 | 513 230 | **0** |
| `QuestDefinition`, 3 tasks, 7 conditions, both arms from one model | `TrackNone` | `bench_store_set_definition_silent_worst`, `bench_hand_set_model_definition_silent_worst` (`baseline_silent_definition`) | 1 542 390 | 1 542 390, the model's slots written, no event code | **0** |
| `QuestDefinition`, the same | `TrackAll` | `bench_store_set_model_definition_worst`, `bench_hand_set_model_definition_worst` (`baseline_model_definition`) | 1 697 490 | 1 697 490, the same writes, then `emit` | **0** |

**The definition, to the unit** (fix loop 1). Both arms build the model with `DefinitionTrait::new`
and write its slots; the hand arm writes them itself, then (tracked) emits `QuestDefined` built
from the model's fields through the component's emit, as 0.1.0's `define` did. The only
difference is the tracking path: untracked, the store is the write with no event code; tracked,
the write plus the event, 155 100, which is also 0.1.0's event (1 657 450 − 1 502 350). Before
fix loop 1 the tracked store measured 1 697 890 (1 652 890 on Scarb 2.19.4), 400 more: `DefinedTrait::new` desnapped each field
of the model (`*definition.tasks`, …); it now desnaps the model once, and every `define` is 400
cheaper.

Against 0.1.0's own code (`definition_new`, kept in `tests/oracle.cairo`), the store is 4 960
cheaper under both choices (`bench_hand_set_definition_silent_worst` 1 547 350,
`bench_hand_set_definition_worst` 1 702 450): `DefinitionTrait::new` validates for less.

The component's tests run under `TrackAll`, as 0.1.0 behaves: `define` and `set_reporter` cost
what they cost before, to the unit (below).

### Every entrypoint, before and after

| Entrypoint | Benchmark (baseline) | Before | 0.2.0 on Scarb 2.20.1 | Difference |
|---|---|---|---|---|
| `progress_many`, **the worst**, H = 4, created | `bench_progress_many_worst_held4` (`baseline_progress_many_worst_held4`) | 6 213 063 | **6 460 843** | +247 780 |
| `progress_many`, H = 4, existing | `bench_progress_many_worst_held4_existing` | 2 997 063 | 3 244 843 | +247 780 |
| `progress_many`, H = 4, created, hook writes one slot | `bench_progress_many_worst_held4_hook` | 8 027 983 | 8 335 763 | +307 780 |
| `progress_many`, H = 4, existing, hook writes one slot | `bench_progress_many_worst_held4_existing_hook` | 4 811 983 | 5 119 763 | +307 780 |
| `progress_many`, H = 8, created | `bench_progress_many_worst_held8` | 11 430 213 | **11 917 073** | +486 860 |
| `progress_many`, H = 8, existing | `bench_progress_many_worst_held8_existing` | 4 998 213 | 5 485 073 | +486 860 |
| `progress_many`, H = 8, created, hook writes one slot | `bench_progress_many_worst_held8_hook` | 15 060 053 | **15 666 913** | +606 860 |
| `progress_many`, H = 8, existing, hook writes one slot | `bench_progress_many_worst_held8_existing_hook` | 8 628 053 | 9 234 913 | +606 860 |
| `progress_many`, §5.1 witness adapted | `quest_batch_bound_accepted` (`baseline_batch_bound_accepted`) | 5 630 846 | 5 878 626 | +247 780 |
| `progress_many`, 4 held all completing, 4 entries | `bench_progress_full_list_all_complete` (`baseline_full_list`) | 5 190 634 | 5 438 294 | +247 660 |
| `progress`, 4 held, one completes | `bench_progress_full_list_one_completes` (`baseline_full_list`) | 2 116 496 | 2 251 946 | +135 450 |
| `progress`, 4 held, one counts | `bench_progress_full_list_one_counts` (`baseline_full_list`) | 1 404 436 | 1 500 026 | +95 590 |
| `progress`, 4 held, none in the batch | `bench_progress_full_list_none_counts` (`baseline_full_list`) | 943 726 | 1 023 506 | +79 780 |
| `progress`, 1 held, counts | `bench_progress_plain` (`baseline_accepted`) | 837 546 | 877 336 | +39 790 |
| `progress`, 1 held, completes | `bench_progress_plain_completing` (`baseline_accepted`) | 1 382 646 | 1 444 296 | +61 650 |
| `progress`, nothing held | `bench_progress_nothing_held` (`baseline_plain`) | 226 756 | 236 256 | +9 500 |
| `accept`, **the worst**: grows into a slot never used, K = 7 | `bench_accept_growth` (`baseline_accept_growth`) | 1 921 540 | **2 061 170** | +139 630 |
| `accept`, grows back into a slot used before | `bench_accept_regrow` (`baseline_accept_regrow`) | 712 750 | 778 980 | +66 230 |
| `accept`, mixed list, K = 7 | `bench_accept_mixed` (`baseline_accept_mixed`) | 1 684 750 | 1 842 280 | +157 530 |
| `accept`, 4 dead entries completed, K = 7 | `bench_accept_worst_completed` (`baseline_accept_worst_completed`) | 1 760 960 | 1 929 690 | +168 730 |
| `accept`, 4 entries expired, K = 7 | `bench_accept_worst_expired` (`baseline_accept_worst_expired`) | 1 599 200 | 1 743 930 | +144 730 |
| `accept`, a player's first | `bench_accept_plain` (`baseline_plain`) | 778 830 | 799 490 | +20 660 |
| `abandon`, **the worst**: the first of 4 | `bench_abandon_worst` (`baseline_full_list`) | 574 060 | **621 030** | +46 970 |
| `abandon`, the third of 3 | `bench_abandon_shrink` (`baseline_three_held`) | 459 470 | 486 740 | +27 270 |
| `abandon`, the second of 2 | `bench_abandon` (`baseline_two_held`) | 430 750 | 458 370 | +27 620 |
| `claim` | `bench_claim` (`baseline_completed`) | 364 020 | 404 920 | +40 900 |
| `define`, **the worst**: 3 tasks, 7 conditions | `bench_define_worst` (`baseline_define_worst`) | 2 583 680 | **2 779 560** | +195 880 |
| `retire`, **the worst**: 7 conditions | `bench_retire_worst` (`baseline_retire_worst`) | 1 003 240 | **1 175 940** | +172 700 |
| `set_reporter`, a new reporter | `bench_set_reporter` (`baseline_deployed`) | 608 210 | 621 610 | +13 400 |
| `set_reporter`, set again, unchanged | `bench_set_reporter_unchanged` (`baseline_reporter_registered`) | 207 330 | 220 610 | +13 280 |
| `progress`, event mode, 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 212 366 | 217 146 | +4 780 |
| `progress_many`, event mode, 16 entries, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 1 831 823 | 1 835 803 | +3 980 |
| `quest_definition`, 3 tasks, 7 conditions | `bench_view_definition_worst` (`baseline_prerequisites`) | 304 400 | 322 180 | +17 780 |
| `quest_is_unlocked`, K = 7, not cached | `bench_view_is_unlocked_worst` (`baseline_prerequisites`) | 492 490 | 556 470 | +63 980 |
| `quest_is_accepted`, full list | `bench_view_is_accepted` (`baseline_prerequisites`) | 332 950 | 355 630 | +22 680 |
| `quest_held`, full list | `bench_view_held_full` (`baseline_prerequisites`) | 298 690 | 316 370 | +17 680 |
| `quest_progress` + `quest_record` | `bench_view_progress_and_record` (`baseline_prerequisites`) | 288 290 | 300 570 | +12 280 |
| `quest_current_interval` | `bench_view_current_interval` (`baseline_prerequisites`) | 160 630 | 164 910 | +4 280 |
| `quest_is_reporter` | `bench_view_is_reporter` (`baseline_prerequisites`) | 124 690 | 130 370 | +5 680 |

Grim World's case (`game_case_three_per_task`, `game_case_two_per_task`): 4 553 406 → 4 801 186
(+247 780, Scarb 2.20.1).

**The worst calls are not raised**: `progress_many` is 7 220 cheaper at H = 4 and 14 140 at H = 8,
`accept` 4 370, `abandon` 9 910, `define` 400; `retire` is 300 more (3 steps, 0.03 %). The walk of the held list is cheaper because `ProgressTrait::add` is inlined (`#[inline]`);
not inlined, the model's `add`, which takes the model with its keys, cost about 800 more per held
quest than 0.1.0's `progress_add` (measured: +4 900 at H = 4 before the attribute).

**Where 0.2.0 costs more**, all within noise of the call:

- **+300 to +500**, 3 to 5 steps, on `claim`, `retire`, `progress` with nothing held, and one
  event-mode entry: a model is built with its keys where 0.1.0 had the bare slot.
- **`quest_is_unlocked`, +4 300** (0.9 % of the view): seven records are read as models, each
  with its two keys. It is a view; on `accept`, which runs the same walk, the savings elsewhere
  win (−4 370 to −9 340).
- **The grid's dead entries** (below): +640 per held quest completed earlier, +180 per expired
  one, read and skipped, against −1 700 to −3 500 per quest that counts or is missed.

### The grid (`test_component_grid`), before and after

The call `progress_many(PLAYER, [1..=15, 129], Storage)` minus its seeded baseline, on Scarb 2.20.1
(the difference is against the same cell on Scarb 2.19.4, `5fb465a`):

| H | all complete | all count | none in the batch | all completed earlier | all expired |
|---|---|---|---|---|---|
| 1 | 2 297 343 (+63 000) | 1 731 123 (+42 000) | 1 262 053 (+27 000) | 1 121 853 (+21 000) | 1 071 703 (+15 000) |
| 2 | 3 705 433 (+129 000) | 2 511 373 (+81 000) | 1 573 233 (+51 000) | 1 292 833 (+39 000) | 1 192 533 (+27 000) |
| 4 | 6 462 063 (+255 000) | 4 012 223 (+153 000) | 2 135 943 (+93 000) | 1 575 143 (+69 000) | 1 374 543 (+45 000) |
| 8 | 11 919 413 (+501 000) | 6 958 013 (+291 000) | 3 205 453 (+171 000) | 2 083 853 (+123 000) | 1 682 653 (+75 000) |

### Against the cap

| Worst call | Call, snforge | Created / overwritten | Network estimate | Against 20 M (snforge / network) | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|
| H = 4, created, hooks empty | **6 460 843** | 8 / 0 | 6 295 995 | 32 % / 31 % | 0.59 % |
| H = 4, created, hook writes one slot | **8 335 763** | 12 / 0 | 8 088 491 | 42 % / 40 % | 0.76 % |
| H = 8, created, hooks empty | **11 917 073** | 16 / 0 | 11 587 377 | 60 % / 58 % | 1.08 % |
| H = 8, created, hook writes one slot | **15 666 913** | 24 / 0 | 15 172 369 | 78 % / 76 % | 1.42 % |
| Grim World's use | 4 801 186 | 6 / 2 | 4 597 338 | 24 % / 23 % | 0.44 % |

Snforge figures are measured on Scarb 2.20.1 / snforge 0.64.0 (ARC-10). The network estimate is the snforge figure with each written slot repriced at the network's
price: −20 606 per created slot and −40 106 per overwritten one.

The reads, writes and events of each call are those of 0.1.0: the store reads and writes the same
slots, in the same order, and emits the same events under `TrackAll`.

### Budgets

Every budget lies between the measured value and `ceil(1.05 × measured)`, which is what
`scripts/gas.py --check` checks. It is not always equal to `ceil(1.05 × measured)`, whatever the
generated header says: a budget is set to that figure when it is written, and a later
measurement that drops by less than 5 % leaves it valid and tighter. After fix loop 1, 34 of 510
budgets are tighter than `ceil(1.05 × measured)` (for example `bench_held_slot_last`: 30 700
measured, budget 31 458); none was raised to match. In the first pass of ARC-07a, the 26 new tests
(`test_tracking`, `test_store_models`) got their budgets, 193 were lowered, and three were raised,
each with its `// gas: raised` note: `test_record::prerequisites_met_when_each_completed_once`
(37 080 → 43 680), `test_record::quest_prerequisites_all_required_logic` (27 020 → 30 720) and
`test_bench::bench_prerequisites_met_seven` (29 700 → 34 800). They build spans of record models,
each with its two keys, for `RecordTrait::all_completed`, which the component does not call (it
reads one record at a time; its walk is the one of `quest_is_unlocked` above). The tests of 0.1.0's
pure functions run the models' code on 0.1.0's slot values through `tests/helpers.cairo`
(`add_counts`, `is_complete`, `complete`, `claim_both`, `definition_slots`, `held_slot_of`); the
conversions cost a few steps, within their budgets.

### Fix loop 1

- **The held list and the prerequisites moved to the store** (`get_held`, `get_held_list`,
  `set_held_list`, `is_still_held`, `is_held_live`, `prerequisites_met`), with their bodies and
  attributes unchanged. Every test that existed before costs the same to the unit, but those that
  call `define`.
- **`define` is 400 cheaper** (`bench_define_worst` 2 583 280): the definition's event is built
  from the model desnapped once (above). Tests that define quests in their setup are 400 cheaper per
  definition; their budgets were lowered where they left the 5 % range. No budget was raised.
- New tests: `test_component_track_none` (the component under `TrackNone`: action events only),
  `track_all_definition_rewritten_emits_once_per_write`, `store_held_list_writes_only_the_slots_that_change`,
  `store_prerequisites_met_reads_each_record`, and the definition's matched benchmarks above.

## The store and the definition model (ARC-06)

Written by hand, like the section below; figures of commit `852f546` (fix loop 1). In 0.2.0 the figures of the mechanism and of the
quest definition are the same to the unit (the table above); the component's are in the section
above. A cost is
the benchmark minus its baseline, both through a dispatcher (docs/research/ARC-06-model-store.md).

### The mechanism, on one slot (`test_store`, `MockModels`)

Two models of one felt each, `Plain` untracked and `Logged` tracked, set against the same code by
hand: the storage member's `write` and `read`, and `emit` for the tracked one. A slot is created
when zero before the test, overwritten when set by the `store` cheatcode before it.

| Operation | Slot | By hand | Through the store | Store − hand | Benchmarks (baseline) |
|---|---|---|---|---|---|
| `set`, untracked | created | 454 530 | 454 530 | **0** | `bench_hand_set_untracked_created`, `bench_store_set_untracked_created` (`baseline_models`) |
| `set`, untracked | overwritten | 52 530 | 52 530 | **0** | `bench_*_set_untracked_overwritten` (`baseline_models_existing`) |
| `set`, tracked (write + event) | created | 499 550 | 499 550 | **0** | `bench_*_set_tracked_created` (`baseline_models`) |
| `set`, tracked (write + event) | overwritten | 97 550 | 97 550 | **0** | `bench_*_set_tracked_overwritten` (`baseline_models_existing`) |
| `get` | existing | 29 420 | 29 420 | **0** | `bench_hand_get`, `bench_store_get` (`baseline_models_get`: an id in, a value out, asserted) |

Tracked minus untracked is 45 020 in both cases: the event (1 key besides the selector, 2 data
felts), and nothing else. The model is passed to `set_x` **by value**: by snapshot (`@Plain`,
then `*plain.a`), the same `set` measured 300 more, created or overwritten, tracked or not (3
steps).

Before fix loop 1 the reads were measured against the write-shaped `noop(id, a, b)`, which gave
32 590 for both; `baseline_models_get` has the reads' shape.

**One more field in the free bits of a slot written anyway** (the achievement's `points`, fix
loop 1): `bench_store_set_wide_created` − `baseline_models_wide` = 454 730, against 454 530 for
two fields (`set` untracked, created): **+200** (2 steps of packing), no slot more.

### The quest definition (`test_store_definition`, `MockDefinitionStore`)

| Operation | Case | 0.1.0 by hand | Through the model and store | Difference | Benchmarks (baseline) |
|---|---|---|---|---|---|
| write a new definition, and `QuestDefined` | 3 tasks, 7 conditions: A, B, C created | 1 657 450 (`definition_new`, 3 writes, `emit`) | 1 652 890 (`DefinitionTrait::new`, `set_definition`) | −4 560 | `bench_hand_set_definition_worst`, `bench_store_set_definition_worst` (`baseline_definition`) |
| read a definition | 3 tasks, 7 conditions: A, B, C read | 130 430 (the reads of the view, `tasks_span`, `conditions_span`) | 130 400 (`get_definition`) | −30 | `bench_hand_get_definition_worst`, `bench_store_get_definition_worst` (`baseline_definition_read`: an id in, a number out, asserted) |

Before fix loop 1 the reads were measured against `baseline_definition_defined`, a write-shaped
`noop` with the whole definition as calldata, which gave 69 240 and 69 210: the baseline paid for
decoding a calldata the reads do not have.

### The component, before and after

Since fix loop 1 the component reads and writes no definition slot by hand: `get_definition_head`
(A), `get_definition_tasks` (B), `get_definition_conditions` (C), `set_definition_status` (A's
status), `has_definition`, `set_definition`. Every benchmark of the component is the same to the
unit as at `0227486`; no test is more expensive but `store_set_definition_emits_quest_defined_once`,
which now writes twice (`// gas: raised`).

| Entrypoint | Benchmark | 0.1.0 (`21f3066`) | Now | |
|---|---|---|---|---|
| `define`, 3 tasks, 7 conditions | `bench_define_worst` | 2 590 440 | 2 583 680 | −6 760: the presence check reads A alone (`Store::has_definition`); the write is the store's |
| `retire`, 7 conditions | `bench_retire_worst` | 1 003 240 | 1 003 240 | unchanged (not reworked) |
| `progress_many`, the worst, H = 4, created | `bench_progress_many_worst_held4` | 6 213 063 | 6 213 063 | unchanged |
| `progress_many`, H = 4, existing | `bench_progress_many_worst_held4_existing` | 2 997 063 | 2 997 063 | unchanged |
| `progress_many`, H = 8, created | `bench_progress_many_worst_held8` | 11 430 213 | 11 430 213 | unchanged |
| `progress_many`, H = 8, existing | `bench_progress_many_worst_held8_existing` | 4 998 213 | 4 998 213 | unchanged |

Every test that defines a quest is cheaper, and no test is more expensive (against the table of
`21f3066`). Their budgets were lowered to `ceil(1.05 × measured)`; none
was raised.

**A finding on revert paths.** A first version checked presence with `get_definition` (A, then B
and C for a defined quest) and rebuilt the spans: successful calls were cheaper, but the tests
whose `define` reverts, at the admin check included, cost 30 000 to 60 000 more
(`quest_define_admin_only` +60 570). Without `#[inline]` it was worse on every path. The check
that reads A alone is cheaper on every path; the tests of its revert paths are 8 060 to 160 970
cheaper than in 0.1.0.

## Cost model of `quiver_quest` 0.1.0 (ARC-03c, D-135)

This section is written by hand below the generated table. `scripts/gas.py --write` rewrites
this file and drops the section; `--check` reads only the rows above.

- Figures are L2 gas as snforge 0.64 reports it, from the full run of this commit.
- Reads, writes and events come from `snforge test --detailed-resources`.
- A call's cost is its test minus its baseline (the same fixture without the call), through a
  dispatcher.
- Hooks do nothing (`MockBench`) unless the row says so.

### The price of a storage slot: snforge and the network

A written slot is priced by whether it is **created** (zero before the transaction, non-zero
after) or **overwritten** (non-zero before; this includes a slot zeroed or rewritten unchanged).

| Written slot | snforge 0.64, measured here (`test_component_probe`; 0.61: 459 106 and 57 106) | The network: FND-04 of the game, the state diffs of 149 Sepolia transactions (decision of 2026-09-28, correction of 2026-09-29) |
|---|---|---|
| Created (zero → non-zero) | 474 106: the write 72 106 + the allocation 402 000 | about 453 500 |
| Overwritten, zeroed or unchanged | 72 106 | about 32 000 |

**The figures of this file are snforge's**, measured. Where a figure is set against the 20 M cap,
the **network's estimate** is given beside it. That estimate is the measure with each slot the
call writes repriced at the network's price: −20 606 per created slot and −40 106 per
overwritten one (−5 606 and −25 106 on snforge 0.61). snforge is within 4.5 % of the network on a
created slot and overcharges an overwritten one by 40 000.

The probes of fix loop 1, each transition in its own test, 100 cells per test:

| Transition in the measured call | Test | L2 gas per write |
|---|---|---|
| 0 → 1 (created) | `probe_transition_zero_to_value` | 474 106 |
| 0 → 0 | `probe_transition_zero_unchanged` | 72 106 |
| 0 → 1 → 0 in one call | `probe_transition_zero_set_then_restored` | 143 293 (two writes, nothing created) |
| 1 → 2 (overwritten) | `probe_transition_value_to_other` | 72 106 |
| 1 → 1 | `probe_transition_value_unchanged` | 72 106 |
| 1 → 2 → 1 in one call | `probe_transition_value_changed_then_restored` | 143 293 |
| 1 → 0 (zeroed) | `probe_transition_value_to_zero` | −314 894 in the test: the write, minus the allocation the test's first call made and the clear undid |

snforge counts a whole test as one transaction, so a call that zeroes a slot its setup created
reads 402 000 low. Since fix loop 2 **the held list is never zeroed** (below). The one
entrypoint that zeroes a slot is `set_reporter(reporter, false)` on a registered reporter: its
benchmark reads −181 190, and it costs 220 810 in a transaction of its own (−194 470 and 207 530 on
Scarb 2.19.4). Every other figure is
the call in a transaction of its own.

Other unit costs (storage read 36 205 on snforge 0.64; the rest of this line is 0.61's, not re-measured): storage read 30 205; event of 3 keys and 1 data felt 48 542; unpack
`QuestDefinition` / `QuestTasks` / `QuestRecord` / `QuestHeldSlot` 18 633 / 12 625 / 7 075 /
22 301 (17 221 at the 16-bit widths; the counter now straddles bit 128).

### The held list

`Quest_held: Map<(player_id, slot), QuestHeldSlot>`, slots 0 to 3, two entries per slot:

| Bits of a slot | Field |
|---|---|
| [0, 32) | `e0.quest_id` (0 = empty) |
| [32, 80) | `e0.interval_id`, the interval of the acceptance: 48 bits (fix loop 4) |
| [80, 110) | `e0.acceptance`, the player's acceptance number: 30 bits (fix loop 4) |
| [110, 140) | `counter`: the number of the player's last acceptance, 30 bits, in slot 0 only (zero elsewhere); the one field that straddles bit 128 |
| [140, 172) | `e1.quest_id` |
| [172, 220) | `e1.interval_id` |
| [220, 250) | `e1.acceptance` |
| [250] | `kept`: set once the slot has held an entry, never cleared (fix loop 2) |
| [251] | reserved: a felt with bit 251 set is rejected; every value the package writes is below 2^251 |

Fix loop 4 (an exception to the rule of three loops, decided by the project manager) took these
widths. The interval id went from 64 bits to 48, and the acceptance number and the counter from 16
to 30, in the same 251 bits and the same two entries per slot. Among the splits that fit, 30 bits
is the widest number: two entries of 32 + 48 + A bits, a counter of A bits and the kept bit need
3A + 161 ≤ 251 bits, so A ≤ 30. That is wider than the 29 the decision named, at no cost.

The entries are contiguous and in the order of acceptance. A slot whose `e1` is empty ends the
list, so `progress_many` reads 1 slot for 0 or 1 held quests, 2 for 2 or 3, and 3 for 4.
`MAX_HELD = 4` bounds only `accept`. The walk reads up to 4 slots (8 entries, `MAX_HELD_LIMIT`),
whatever `MAX_HELD` is, and that is how the H = 8 case is measured with the same code.

**Acceptance numbers** (fix loop 1).

- Each `accept` stamps its entry with `counter + 1`, 30 bits, wrapping to 0 after 2^30 − 1, and
  stores that number as the counter.
- A quest abandoned and accepted again in the same interval is a different entry. A progress call
  compares whole entries after a hook has run, so a renewed entry is excluded from the call that
  was running.
- **An acceptance is identified by its whole entry**: quest, interval and number (fix loop 4).
  Fix loop 3 used 16-bit numbers and a window of the numbers issued during a call. After a lifetime
  wrap at 16 bits, which is 65 536 acceptances by one player over any number of transactions, a
  number alone could not tell a renewed entry from an unchanged one that carried a reissued
  number. A hook that accepted another quest then made an unchanged held quest lose a batch's
  counts (finding 6 of the third audit pass).

  With 30 bits the window is gone. A wrap needs 2^30 ≈ 1.07 × 10⁹ acceptances by one player: at
  least 0.7 M L2 gas each, so about 7.5 × 10¹⁴ L2 gas of their own.
- **At the counter's boundary** (`quest_acceptance_counter_wraps_at_2_30`, seeded), the number
  after 2^30 − 1 is 0. From then on, an acceptance can get the number of an entry accepted 2^30
  acceptances earlier. If that entry is still held and a hook renews that same quest within a
  progress call, the renewal is not told apart. That is the one way left, after about 10⁹
  acceptances.
- **At the interval id's boundary** (`quest_held_interval_id_boundary_2_48`), a held entry stores
  interval ids below 2^48, which is 8.9 million years of one-second intervals. At an interval id
  of 2^48 or more, `accept` refuses the quest as not active (`'Quest: not active'`), and entries
  of earlier intervals have expired as at any rollover. Packing refuses a wider id
  (`'Packing: field out of range'`); the component never packs one.
- **Cost.** Removing the window removed its read of slot 0 after each hook. The wider fields cost
  about 5 000 more per slot unpacked (`probe_unpack_held_100`: 22 301 against 17 221). The worst calls are 6 213 063 at H = 4 (6 292 283 with the window of
  fix loop 3, 6 182 583 before it) and 11 430 213 at H = 8.

**Kept slots** (fix loop 2, (c)). The decision asked whether a player's slots should be kept and
reused instead of being zeroed.

- **Where slots were zeroed.** Only the held list's slot 1 (slots 1 to 3 at H = 8): when the list
  shrank out of it at an `abandon`, or at an `accept` that pruned expired, completed or retired
  entries. Then it was created again the next time the list grew into it.
- **The change.** Every slot now keeps its `kept` bit once it has held an entry. A slot the list
  stops using is overwritten with the bit alone, and the next growth into it overwrites again.
  Slot 0 is never zeroed either: the counter already kept it non-zero.
- **What else was considered.** Progress P and the record R are never zeroed by any entrypoint.
  R is created once per player and quest and overwritten afterwards.

  P is keyed by interval, so a recurring quest creates a new P in each interval where it counts.
  Reusing one P per player and quest would save about 421 500 per quest per interval. But it
  would overwrite a completed interval that `claim(player, quest, interval)` may still claim,
  which the API of A-G1 allows for any completed interval. That is not adopted here, and is an
  open question.

Measured against the zeroing design (the code of fix loop 1, `94b6d5d`, 16-bit acceptance numbers), L2 gas; the kept design's figures and network estimates are those of the current layout (fix loop 4, 30-bit numbers), whose wider unpack adds about 22 000 to 26 000 to `accept` and `abandon`:

| Event of a player's life | Benchmark | Zeroing design | Kept design | Network, zeroing → kept |
|---|---|---|---|---|
| The list grows back into slot 1 (`accept`, 2 other entries held) | `bench_accept_regrow` | 1 084 240 (slot 1 created) | **712 750** (slot 1 overwritten) | ≈ 1 053 500 → ≈ 662 538 |
| The list shrinks out of slot 1 (`abandon` of the third of three) | `bench_abandon_shrink` | 435 600 in a transaction of its own (33 600 in the test, a zeroing) | 459 470 (slot 1 overwritten with the bit) | ≈ 410 500 → ≈ 434 364 |
| `accept` pruning 4 dead entries, K = 7 | `bench_accept_worst_completed` | 1 724 500 in a transaction | 1 760 960 | — |
| The worst `accept`: the list grows into a slot never used, K = 7 | `bench_accept_growth` | 1 889 960 | 1 921 540 | ≈ 1 853 600 → ≈ 1 885 222 |
| **The worst progress call**, H = 4 / H = 8 (fix loop 2, before the fix of loop 3) | `bench_progress_many_worst_held{4,8}` | 6 187 453 / 11 376 913 | **6 182 583 / 11 374 333** | not worse |

**Why the kept design is adopted.**

- **It saves** 371 490 measured (about 391 000 at the network's prices; 393 820 before the
  widening of fix loop 4) each time the list grows
  back into a slot it used before, which happens whenever a player's held count rises again
  past 2.
- **It costs** about 8 000 to 9 000 per `accept` or `abandon` that writes the list: the bit is
  read, compared and carried. At that rate, one regrowth pays for about 45 list operations.
- **The worst call is not worse.** The walk of progress, the views and the still-held check read
  the entries without the bits (`held_entries`), so the worst progress calls are cheaper by
  2 600 to 4 900.
- **What stays the same.** The worst `accept` rises by 9 250 (0.5 %): it grows into a slot never
  used, which it must create in both designs. Nothing is zeroed any more, so no benchmark needs a
  correction.

**Acceptance lives in the list alone**, and **pruning is lazy, at `accept`** (fix loop 1).

- A dead entry costs each later progress call 0.05–0.08 M (expired: A read) or 0.10–0.12 M
  (completed: A and P).
- Pruning at progress would overwrite a list slot, about 0.07–0.09 M, in the call that meets it.
- It would pay when a dead entry is walked by two or more later calls before the next accept.
  The choice is kept, and it is an open question.

### The worst call (`test_component_bench`), created and existing slots

**The case.**

- 16 entries `[1..=15, 129]`: the last one collides modulo 128, so `batch_merge`'s plain merge
  runs in full.
- Every held quest completes. Each has 3 tasks at the batch's last three positions and a daily
  schedule.
- H = 4 is built by `accept`. For H = 8, entries 5 to 8 are seeded into slots 2 and 3 with
  `store`.

**Created**: each quest's progress P and record R are new, a first count in the interval and a
first completion. **Existing**: P already counts 1 of 2 on each task in this interval (seeded),
and R already has a completion (seeded); the call overwrites both.

The hook's slot (`MockBenchHook`, `completions[quest_id]`) is new in both cases, the consumer's
worst. The list is never written by progress.

| Case | Benchmark | Call, snforge | Slots created / overwritten | Network estimate | Against 20 M (snforge / network) | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|
| H = 4, created, hooks empty | `bench_progress_many_worst_held4` | **6 213 063** | 8 / 0 | 6 168 215 | 31 % / 31 % | 0.56 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 2 997 063 | 0 / 8 | 2 796 215 | 15 % / 14 % | 0.27 % |
| H = 4, created, hook writes one slot | `bench_progress_many_worst_held4_hook` | **8 027 983** | 12 / 0 | 7 960 711 | 40 % / 40 % | 0.73 % |
| H = 4, existing, hook writes one slot | `bench_progress_many_worst_held4_existing_hook` | 4 811 983 | 4 / 8 | 4 588 711 | 24 % / 23 % | 0.44 % |
| H = 8, created, hooks empty | `bench_progress_many_worst_held8` | **11 430 213** | 16 / 0 | 11 340 517 | 57 % / 57 % | 1.04 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 4 998 213 | 0 / 16 | 4 596 517 | 25 % / 23 % | 0.45 % |
| H = 8, created, hook writes one slot | `bench_progress_many_worst_held8_hook` | **15 060 053** | 24 / 0 | 14 925 509 | 75 % / 75 % | 1.37 % |
| H = 8, existing, hook writes one slot | `bench_progress_many_worst_held8_existing_hook` | 8 628 053 | 8 / 16 | 8 181 509 | 43 % / 41 % | 0.78 % |

Reads are 23 at H = 4 and 44 at H = 8, events 4 and 8, in every case. The reporter check (1) is
included. **The figures stated against the cap are the created ones**, the worst the package
allows: 6.29 M at `MAX_HELD = 4` and 15.31 M at the layout's limit of 8 with a hook writing one
new slot. With existing slots, a completing quest costs about 0.80 M less.

### The grid (`test_component_grid`): H held quests, each in one state, P and R created

The call is `progress_many(PLAYER, [1..=15, 129], Storage)` against a seeded list. Each row gives
the call's L2 gas:

| H | all complete | all count (no completion) | none in the batch | all completed earlier (dead) | all expired (dead) |
|---|---|---|---|---|---|
| 0 | 1 003 693 | | | | |
| 1 | 2 236 373 | 1 692 013 | 1 238 753 | 1 100 473 | 1 056 783 |
| 2 | 3 580 193 | 2 435 853 | 1 529 333 | 1 252 773 | 1 165 393 |
| 4 | 6 214 283 | 3 869 883 | 2 056 843 | 1 503 723 | 1 328 963 |
| 8 | 11 432 553 | 6 688 033 | 3 061 953 | 1 955 713 | 1 606 193 |

Per entry, (call − call at H = 0) / H: completing 1.23–1.30 M (A, P, B, R read; P and R
created, 2 × 459 106; the event; after the previous hook, the entry's slot read); counting 0.69–0.71 M
(P created); none in the batch 0.24–0.26 M; completed earlier 0.10–0.12 M; expired
0.05–0.08 M.

So `call(H) ≤ 1.004 M + 1.31 M × H` with every slot created. The quests defined on a task but not
held cost nothing.

### Grim World's case (`test_component_game`)

The call has 16 task entries. The player holds 3 quests and one daily contract, all accepted and
all completing, with 0 to 2 prerequisites, checked and cached by `accept`. Every task is shared
by 2 or 3 quests in all; the others are not accepted.

| Case | Call, snforge | Slots created / overwritten | Network estimate |
|---|---|---|---|
| 3 quests per task (48), or 2 (32) | 4 801 186 (4 553 406 on Scarb 2.19.4) | 6 / 2 | 4 597 338 (4 469 558 on 2.19.4) |

- **Created**: the four P and the records of quests 1 and 4.
- **Overwritten**: the records of quests 2 and 3, whose unlock `accept` cached.

### Slots created and overwritten, per entrypoint

A **write** is a storage write syscall. It **creates** a slot that was zero before the
transaction, and **overwrites** a non-zero one: an update, a rewrite of the same value, or a
**zeroing**. Since fix loop 2 the held list is never zeroed. The one zeroing left is a reporter's
revocation.

| Entrypoint | Best case | Common case | Worst case |
|---|---|---|---|
| `progress`, `progress_many`, event mode | nothing written | nothing written | nothing written |
| `progress_many`, storage mode | nothing written: nothing held counts | per held quest that counts: P created on its first count in the interval, overwritten on later ones; per completion, R created on the quest's first completion, overwritten afterwards (and after a cached unlock or a claim) | 2H created (P, R of every held quest); plus the hooks' own. The held list: never written |
| `accept` | 1 overwritten: slot 0, the entry lands there and the counter changes | 1 or 2 overwritten (slot 0 for the counter, the slot of the entry); + R created when it caches an unlock of a quest the player never completed | 2 created and 1 overwritten: the list grows into a slot never used, R created by the unlock; slot 0 overwritten. The first accept of a player creates slot 0 |
| `abandon` | 1 overwritten | 1 or 2 overwritten | 2 overwritten (the later entries move up); a slot the list stops using is overwritten with its `kept` bit, never zeroed |
| `claim` | 2 writes, 2 overwritten, 1 changed slot when `claims` is saturated at 2^64 − 1: only P changes, R is rewritten unchanged | 2 overwritten (P, R) | 2 overwritten |
| `define` | 2 created (A, B) | 3 created (A, B, C) and K overwritten (the prerequisites' `live_dependents`) | 3 created, 7 overwritten |
| `retire` | 1 overwritten (A) | 1 + K overwritten | 8 overwritten |
| `set_reporter` | 1 write, nothing changed (the value is already set) | 1 created (a new reporter); 1 **zeroed** (a registered reporter revoked) | 1 created |
| Views | nothing written | nothing written | nothing written |

### Every entrypoint, measured

| Entrypoint | Case | Benchmark (baseline) | Call, snforge | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|
| `progress_many` | the worst, H = 4, created | `bench_progress_many_worst_held4` | 6 213 063 | 8 / 0 | 6 168 215 | 25 / 4 |
| `progress_many` | the worst, H = 4, existing | `bench_progress_many_worst_held4_existing` | 2 997 063 | 0 / 8 | 2 796 215 | 25 / 4 |
| `progress_many` | the worst, H = 8, created | `bench_progress_many_worst_held8` | 11 430 213 | 16 / 0 | 11 340 517 | 50 / 8 |
| `progress_many` | the worst, H = 8, existing | `bench_progress_many_worst_held8_existing` | 4 998 213 | 0 / 16 | 4 596 517 | 50 / 8 |
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 5 630 846 | 8 / 0 | 5 585 998 | 25 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` (`baseline_full_list`) | 5 190 634 | 8 / 0 | 5 145 786 | 25 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` (`baseline_full_list`) | 2 116 496 | 2 / 0 | 2 105 284 | 22 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` (`baseline_full_list`) | 1 404 436 | 1 / 0 | 1 398 830 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` (`baseline_full_list`) | 943 726 | 0 / 0 | 943 726 | 16 / 0 |
| `progress` | 1 held, counts | `bench_progress_plain` (`baseline_accepted`) | 837 546 | 1 / 0 | 831 940 | 5 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` (`baseline_accepted`) | 1 382 646 | 2 / 0 | 1 371 434 | 6 / 1 |
| `progress` | nothing held | `bench_progress_nothing_held` (`baseline_plain`) | 226 756 | 0 / 0 | 226 756 | 2 / 0 |
| `accept` | **the worst**: grows into a slot never used, K = 7 not cached | `bench_accept_growth` | 1 921 540 | 2 / 1 | 1 885 222 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 712 750 | 0 / 2 | 662 538 | 8 / 0 |
| `accept` | mixed list: 2 live weekly and 2 stale daily entries, K = 7 | `bench_accept_mixed` | 1 684 750 | 1 / 2 | 1 628 932 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned, K = 7 | `bench_accept_worst_completed` | 1 760 960 | 1 / 2 | 1 705 142 | 22 / 0 |
| `accept` | 4 entries expired, pruned, K = 7 | `bench_accept_worst_expired` | 1 599 200 | 1 / 2 | 1 543 382 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` (`baseline_plain`) | 778 830 | 1 / 0 | 773 224 | 3 / 0 |
| `abandon` | the first of 4, the others move up | `bench_abandon_worst` (`baseline_full_list`) | 574 060 | 0 / 2 | 523 848 | 5 / 0 |
| `abandon` | the third of 3: the list stops using slot 1 | `bench_abandon_shrink` (`baseline_three_held`) | 459 470 | 0 / 1 | 434 364 | 4 / 0 |
| `abandon` | the second of 2 | `bench_abandon` (`baseline_two_held`) | 430 750 | 0 / 1 | 405 644 | 4 / 0 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 364 020 | 0 / 2 | 313 808 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 2 590 440 | 3 / 7 | 2 397 880 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 1 003 240 | 0 / 8 | 802 392 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` (`baseline_deployed`) | 608 210 | 1 / 0 | 602 604 | 0 / 1 |
| `set_reporter` | a registered reporter revoked (zeroed) | `bench_set_reporter_revoke` (`baseline_reporter_registered`) | −194 470 in the test; **207 530** in a transaction of its own | 0 / 1 | 182 424 | 0 / 1 |
| `set_reporter` | a registered reporter set again (unchanged) | `bench_set_reporter_unchanged` (`baseline_reporter_registered`) | 207 330 | 0 / 1 | 182 224 | 0 / 1 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 212 366 | 0 / 0 | 212 366 | 1 / 1 |
| `progress_many`, event mode | 16 entries, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 1 831 823 | 0 / 0 | 1 831 823 | 1 / 16 |

Reads of `progress` and `progress_many` include the reporter check (1).

### The gas guards of the writes, and the writes counted (`test_component_writes`)

The rule "each held quest's progress and record written at most once per call" is guarded by gas.

- **The guard.** Each test measures the Sierra gas of one `progress_many` call with
  `core::testing::get_available_gas()` and requires it within 20 000 of its reference. One write
  is 58 820 (`write_costs_58_820_sierra_gas`). A write injected in a scratch build failed every
  guard, by 61 030 (fix loop 1).
- **What it bounds.** The guards bound the cost, not the count of writes. An extra write paid for
  by a saving of as much elsewhere would pass them.
- **The exact writes.** They are counted outside the test with snforge's resource report, and
  recorded here. snforge exposes no syscall count to a test.

```
snforge test test_component_writes --detailed-resources
```

The call's writes are the test's `StorageWrite` syscalls minus those of its setup baseline
(`baseline_writes_setup`, `baseline_writes_setup_totals_two`: 7 each). The consumer is
`MockBench`, whose hooks write nothing.

| Test | Guard reference (Sierra gas) | `StorageWrite` of the test | Of the call | Which |
|---|---|---|---|---|
| `quest_progress_completing_writes_p_and_r` | 802 776 | 9 | 2 | P, R |
| `quest_progress_not_completing_writes_p_only` | 639 896 | 8 | 1 | P |
| `quest_progress_duplicate_entries_write_p_once` | 680 079 | 8 | 1 | P |
| `quest_progress_two_tasks_write_p_and_r_once` | 760 992 | 9 | 2 | P, R |
| `quest_progress_two_tasks_not_completing_write_p_once` | 654 102 | 8 | 1 | P |
| `quest_progress_duplicates_several_counts_write_each_p_once` | 772 245 | 9 | 2 | P of quest 1, P of quest 2 |

## Single-threaded builds (ARC-09, D-176)

No figure moves. On 2026-10-01, from a clean `target/` each time, `snforge test` measured the
512 tests three times with the default thread count and three times with `RAYON_NUM_THREADS=1`:
the six runs give the same l2_gas for every test, and it equals the table above. The tables are
therefore the single-threaded measures, unchanged. CI pins the variable (`.github/workflows/cairo.yml`),
and `scripts/gas.py` pins it unless the caller set it.
