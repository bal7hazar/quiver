# Gas of `quiver_achievement`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
set at `ceil(1.05 x measured)` and never above it; a budget kept tighter, between the
measure and that ceiling, also passes (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_achievement::constants::tests::achievement_bounds_are_the_accepted_ones` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_achievement::errors::tests::achievement_error_strings_are_the_accepted_ones` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_achievement::helpers::bits::tests::nz_constants_are_their_powers` | 515350 | 541118 | 2026-10-02 | 1126423 |
| `quiver_achievement::helpers::bits::tests::pow2_table_is_two_to_the_index` | 939890 | 986885 | 2026-10-02 | 1126423 |
| `quiver_achievement::helpers::bits::tests::split_both_limbs` | 9620 | 10101 | 2026-10-02 | 1126423 |
| `quiver_achievement::helpers::bits::tests::split_high_limb_zero` | 9650 | 10133 | 2026-10-02 | 1126423 |
| `quiver_achievement::helpers::bits::tests::two_pow_constants_are_their_powers` | 1992560 | 2092188 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_define_rejects_id_zero` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_empty_slot_unpacks_undefined` | 23520 | 24696 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_points_at_their_position` | 865320 | 908586 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_presence_bits_at_their_positions` | 693080 | 727734 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_rejects_task_count_above_max` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_round_trip_definition` | 8628460 | 9059883 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_round_trip_extra_tasks` | 3608270 | 3788684 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_packing_widths` | 691930 | 719019 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_extra_rejects_bit_128` | 333690 | 350375 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_rejects_bit_212` | 385150 | 396701 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_rejects_bit_251` | 21920 | 23016 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_slot_of_0_1_0_reads_zero_points` | 26060 | 27000 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::bench_definition_new_three_tasks` | 12410 | 13031 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::bench_pack_unpack_definition` | 26960 | 28308 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::bench_pack_unpack_extra_tasks` | 17100 | 17955 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_is_active_inside_and_outside_its_window` | 17810 | 18701 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_checks_id_first` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_checks_window_before_tasks` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_one_task_inline` | 15930 | 16727 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_empty_window` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_end_before_start` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_four_tasks` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_no_task` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_repeated_second_task` | 11410 | 11981 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_repeated_task` | 12410 | 13031 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_task_id_zero` | 8710 | 9146 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_total_zero` | 9810 | 10301 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_new_three_tasks` | 30800 | 32340 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::definition_points_stored_and_read_back` | 44660 | 46893 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::definition::tests::tasks_span_has_task_count_entries` | 36420 | 38241 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::reporter::tests::reporter_allowed_passes` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::reporter::tests::reporter_refused_reverts_not_reporter` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::status::tests::status_cannot_retire_twice` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::status::tests::status_cannot_retire_undefined` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::status::tests::status_defined_refuses_define` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::models::status::tests::status_retire_keeps_the_definition_bits` | 19650 | 20633 | 2026-10-02 | 1126423 |
| `quiver_achievement::store::tests::tracking_choices_are_all_or_none` | 7210 | 7571 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::achievement_batch_merges_duplicates` | 162559 | 170687 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_count_of_first_entry_or_zero` | 18460 | 19383 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_above_bound_reverts` | 66530 | 69857 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_bound_accepted` | 220686 | 231721 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_distinct_keeps_order_and_drops_zeros` | 43838 | 46030 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_duplicates_count_toward_bound` | 54410 | 57131 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_late_duplicate` | 1748933 | 1836380 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_modulo_collision_not_merged` | 1813793 | 1904483 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_rejects_task_zero` | 30722 | 32259 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_rejects_task_zero_after_collision` | 54479 | 57203 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_saturates` | 72385 | 76005 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::batch_merge_zero_sum_duplicate_dropped` | 71825 | 75417 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::bench_baseline_sixteen_entries` | 42280 | 44394 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_late_duplicate` | 739883 | 776878 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_late_modulo_collision` | 743793 | 780983 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_sixteen_distinct` | 172666 | 181300 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::window::tests::window_is_active_bounds` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::window::tests::window_validate_accepts_open_and_ordered_windows` | 6010 | 6311 | 2026-10-02 | 1126423 |
| `quiver_achievement::types::window::tests::window_validate_rejects_empty_window` | 7810 | 8201 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_consumer_calls_the_internal_layer` | 3105076 | 3190432 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_define_admin_only` | 2340710 | 2435979 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_internal_layer_not_reachable_from_abi` | 1751330 | 1816668 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_accepts_registered_reporter` | 3070482 | 3159432 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_many_rejects_unregistered_caller` | 2163630 | 2230053 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_rejects_unregistered_caller` | 1997690 | 2060436 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_reporter_revoked` | 2406846 | 2458970 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_retire_admin_only` | 3168750 | 3252291 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_admin_only` | 2450120 | 2518688 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_event_fields` | 1879470 | 1925175 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_defined` | 2028040 | 2086151 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_deployed` | 795290 | 829080 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_game_defined` | 19710180 | 20160095 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_reporter_registered` | 1416100 | 1466861 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_sixteen_tasks_defined` | 60150790 | 61361139 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_one_task` | 1517840 | 1567514 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_worst` | 2028210 | 2085962 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_define_titles` | 19711680 | 20161796 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call` | 20548588 | 21031309 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call_sixteen` | 20959746 | 21467645 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress` | 1008926 | 1048778 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision` | 2616383 | 2736734 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision_with_definitions` | 61971683 | 63268583 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_duplicate` | 2559563 | 2677073 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_sixteen_distinct` | 2045056 | 2136841 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_retire` | 2290770 | 2338949 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter` | 1416100 | 1466861 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_revoke` | 1234110 | 1261827 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_unchanged` | 1635910 | 1683717 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_definition_worst` | 2257460 | 2310987 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_is_reporter` | 925660 | 960005 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_one_task_writes_a_only` | 2646820 | 2716718 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_empty_window` | 1848320 | 1906517 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_invalid_id_and_tasks` | 2351320 | 2422508 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_no_task` | 1744410 | 1799112 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_three_tasks_writes_a_and_b` | 3110210 | 3177920 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_twice_reverts` | 2943130 | 3018708 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_defined_event_fields` | 2903560 | 2978420 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_empty_slot_reads_undefined` | 1602880 | 1673763 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_many_on_one_task` | 23561830 | 23932503 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_define::achievement_redefine_retired_reverts` | 3200100 | 3267947 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_above_bound_reverts` | 1896040 | 1958324 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_bound_accepted` | 3166566 | 3292376 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_duplicates_count_toward_bound` | 1884520 | 1946228 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_one_event_per_merged_task` | 2014769 | 2082989 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_rejects_task_zero` | 1933902 | 1993459 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_event_mode_emits_only_progressed` | 3151336 | 3232495 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progress_writes_nothing` | 2508246 | 2605760 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progressed_event_fields` | 1853456 | 1913611 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_retired_progress_still_emits` | 3672282 | 3763623 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_tiers_share_task_one_event` | 4592276 | 4708385 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_zero_count_emits_nothing` | 2403018 | 2481411 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_one_tier_only` | 3869480 | 3948956 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_sets_retired_and_keeps_the_rest` | 3811140 | 3869061 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_twice_reverts` | 3159110 | 3224088 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_undefined_reverts` | 1817390 | 1866732 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_track_none::track_none_component_emits_action_events_only` | 3818555 | 3891285 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_track_none::track_none_refuses_with_the_packages_errors` | 872570 | 900000 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_track_own::own_impl_tracks_the_definition_only` | 1541890 | 1592766 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_component_track_own::own_impl_tracks_the_reporter_only` | 1494270 | 1542765 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::get_definition_reads_the_model_back` | 2724120 | 2791058 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::status_never_emits` | 2345390 | 2390031 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::track_all_definition_emits_once_per_write` | 2185770 | 2225160 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::track_all_reporter_emits_once_per_write` | 1036690 | 1044036 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::track_none_definition_emits_nothing_and_writes_the_same` | 3770450 | 3810954 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_store_models::track_none_reporter_emits_nothing_and_writes_the_same` | 1868780 | 1917731 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_one_task` | 284730 | 298967 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_reporter` | 271020 | 284571 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_three_tasks` | 296370 | 311189 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_one_task` | 284730 | 298967 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_reporter` | 271020 | 284571 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_three_tasks` | 296370 | 311189 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_one_task_hand` | 837820 | 872393 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_one_task_store` | 837820 | 872393 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_three_tasks_hand` | 1347720 | 1392038 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_three_tasks_store` | 1347720 | 1392038 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_reporter_hand` | 781850 | 813624 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_reporter_store` | 781850 | 813624 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_one_task_hand` | 767640 | 798704 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_one_task_store` | 767640 | 798704 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_three_tasks_hand` | 1252960 | 1292540 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_three_tasks_store` | 1252960 | 1292540 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_reporter_hand` | 740650 | 770364 | 2026-10-02 | 1126423 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_reporter_store` | 740650 | 770364 | 2026-10-02 | 1126423 |

## Scarb 2.20.1 and snforge 0.64.0 (ARC-10, D-180)

**The table above is measured on Scarb 2.20.1 (Cairo 2.20.0) and snforge 0.64.0**, single-threaded
(`RAYON_NUM_THREADS=1`, D-176, kept). The sections below are written by hand; those that give the
package's *current* figures were re-derived from this table: "Optional tracking", "Every
entrypoint, before and after" (the *0.1.0* column is Scarb 2.19.4, so the difference now holds the
compiler's effect too) and "Against the cap". The others are records of the step they describe,
measured on Scarb 2.19.4 and snforge 0.61, and are left as they were (the table of moved tests,
the fix loops, 0.1.0's cost model).

What moved against `a74f2f1` (Scarb 2.19.4, snforge 0.61.0), 145 tests in both:

- **Every test moved** (77 up, 68 down), by the same two causes as in `quiver_quest`: snforge 0.64
  charges 15 000 more per storage write and 6 000 more per read, and the fixed overhead of every
  test is 8 030 lower.
- **Largest rises, in L2 gas**: `bench_progress_many_late_collision_with_definitions` +1 661 170
  (60 310 513 → 61 971 683, the 48 definitions of its setup), `baseline_sixteen_tasks_defined`
  +1 656 890, `achievement_many_on_one_task` +768 970, `bench_game_results_call` +518 770. The
  largest in proportion is +4.3 % (`track_all_reporter_emits_once_per_write`).
- **Largest falls**: 8 030 at most (the baselines), up to 56 % on the smallest tests (13 720 →
  6 010).
- **Budgets: none raised, 66 lowered** to `ceil(1.05 × measured)`: no test exceeded its budget.
- **The worst calls stay under the 20 M cap**: `progress_many` 1 821 093 (9.1 %), the worst
  `define` 1 232 920 (6.2 %), the 26 tiers in one transaction 18 916 390 (94.6 %, was 92.1 %).
- **The guard "progress writes nothing"** (`achievement_progress_writes_nothing`) passes within its
  tolerance: a write is 73 820 Sierra gas now, not 58 820.

## `quiver_achievement` 0.2.0 (ARC-07b)

This section and the ones below are written by hand under the generated table.
`scripts/gas.py --write` rewrites this file and drops them; `--check` reads only the rows above.
Figures are L2 gas as snforge 0.64 reports it (ARC-10); a call's cost is its benchmark minus its baseline.
0.1.0's figures were measured on this branch before any change (`dd503a4`).

### Optional tracking

`tests/test_tracking.cairo`: the package's own models, created, on `MockStoreNone` (`TrackNone`)
and `MockStoreAll` (`TrackAll`). In each contract the store's `set_x` is set against the
hand-written write of the same model (`DefinitionTrait::new`, its slots written by hand, then the
component's `emit` under `TrackAll`, nothing under `TrackNone`): the only difference is the
tracking path.

| Model | Choice | Store (`bench_track_*_store`) | By hand (`bench_track_*_hand`) | Store − hand | Call (minus `baseline_track_*`) |
|---|---|---|---|---|---|
| Definition, 1 task: A | `TrackNone` | 767 640 | 767 640, the write with no event code | **0** | 482 910 |
| Definition, 1 task: A | `TrackAll` | 837 820 | 837 820, the write then `emit` | **0** | 553 090 |
| Definition, 3 tasks: A and B | `TrackNone` | 1 252 960 | 1 252 960 | **0** | 956 590 |
| Definition, 3 tasks: A and B | `TrackAll` | 1 347 720 | 1 347 720 | **0** | 1 051 350 |
| Reporter, created | `TrackNone` | 740 650 | 740 650 | **0** | 469 630 |
| Reporter, created | `TrackAll` | 781 850 | 781 850 | **0** | 510 830 |

The compiler folds the constant: under `TrackNone` a write costs exactly the write with no event
code, under `TrackAll` the write plus the event, to the unit, as ARC-07a measured on
`quiver_quest`. What a consumer saves by not tracking: 70 180 per `define` of 1 task, 94 760 of 3
tasks (`AchievementDefined`), 41 200 per `set_reporter` (`AchievementReporterSet`). The action
events (`AchievementRetired`, `AchievementProgressed`) are emitted whatever the choice
(`test_component_track_none`).

### Every entrypoint, before and after

`test_component_bench` runs under `TrackAll`, as 0.1.0 behaves (`MockBench`).

| Call | Benchmark (baseline) | 0.1.0 | 0.2.0 on Scarb 2.20.1 | Difference |
|---|---|---|---|---|
| **The worst `progress_many`** | `bench_progress_many_late_collision` (`baseline_deployed`) | 1 816 813 | 1 821 093 | +4 280 |
| `progress_many`, late duplicate | `bench_progress_many_late_duplicate` (`baseline_deployed`) | 1 759 993 | 1 764 273 | +4 280 |
| `progress_many`, 16 distinct | `bench_progress_many_sixteen_distinct` (`baseline_deployed`) | 1 245 486 | 1 249 766 | +4 280 |
| The worst, with 48 definitions | `bench_progress_many_late_collision_with_definitions` (`baseline_sixteen_tasks_defined`) | 1 816 613 | 1 820 893 | +4 280 |
| `progress` | `bench_progress` (`baseline_deployed`) | 209 236 | 213 636 | +4 400 |
| **The worst `define`**: 3 tasks | `bench_define_worst` (`baseline_deployed`) | 1 197 030 | 1 232 920 | +35 890 (+3.00 %), `points` stored; most of it is the compiler's dearer writes (below) |
| `define`, 1 task | `bench_define_one_task` (`baseline_deployed`) | 707 640 | 722 550 | +14 910 |
| `retire` | `bench_retire` (`baseline_defined`) | 240 760 | 262 730 | +21 970 (+9.13 %), `points` in A's unpack and pack, and the dearer writes |
| `set_reporter`, new | `bench_set_reporter` (`baseline_deployed`) | 607 410 | 620 810 | +13 400 |
| `set_reporter`, revoked | `bench_set_reporter_revoke` (`baseline_reporter_registered`) | −195 270 | −181 990 | +13 280 |
| `set_reporter`, unchanged | `bench_set_reporter_unchanged` (`baseline_reporter_registered`) | 206 530 | 219 810 | +13 280 |
| `achievement_definition`, 3 tasks | `bench_view_definition_worst` (`baseline_defined`) | 214 130 | 229 420 | +15 290 (+7.14 %), `points` unpacked and returned, and the compiler's |
| `achievement_is_reporter` | `bench_view_is_reporter` (`baseline_deployed`) | 124 690 | 130 370 | +5 680 |
| The game's results call | `bench_game_results_call` (`baseline_game_defined`) | 829 728 | 838 408 | +8 680 |
| The game's bound, 16 tasks | `bench_game_results_call_sixteen` (`baseline_game_defined`) | 1 245 286 | 1 249 566 | +4 280 |
| The game's 26 tiers defined | `bench_game_define_titles` (`baseline_deployed`) | 18 525 730 | 18 916 390 | +390 660 (+2.11 %) |

**Progress, the worst call, is 0.1.0 to the unit.** A first draft measured +500 on every
progress call: the reporter check took the model by snapshot (`assert_is_allowed(self: @..)`).
By value, it is 0.1.0's code to the unit; the status's checks take their model by value too.

**`points` stored** (ARC-06 §6, rule 1). One more field in slot A, [196, 212), in a felt `define`
writes anyway: no new slot. Its price, measured by removing it alone: about 2 100 per pack of A,
about 470 per unpack (`retire` reads and writes A: +2 570; `define` writes it: +1 610 on 3 tasks,
where `DefinitionTrait::new` saves the rest). ARC-06 estimated +200 on an equivalent model in
isolation; in the library alone, pack and unpack together cost 670 more
(`bench_pack_unpack_definition`, 34 120 → 34 790). Folding `points` into `t0.total`'s term costs
the same. The view also returns one more felt. `define` of 1 task is 4 370 cheaper than 0.1.0
with `points`: `DefinitionTrait::new` validates and builds the slots for less than 0.1.0's
`definition_new`.

### Against the cap

On Scarb 2.20.1 the worst `progress_many`, the slowest merge, is 1 821 093 (+4 280), 9.1 % of the 20 M
cap of A-G1. The worst `define` is 1 232 920 (6.2 %); 26 tiers defined in one transaction
18 916 390 (94.6 %, 92.6 % in 0.1.0): under the cap, with 5.4 % to spare.

### Where the tests went (D-167), and their budgets

The unit tests are in their module's file, under `#[cfg(test)] mod tests`
(`quiver_achievement::<module>::tests::<test>` above): the batch and its benchmarks in
`types/batch.cairo`, the window in `types/window.cairo`, the definition's constructor, slots,
packing and benchmarks in `models/definition.cairo`, the status in `models/status.cairo`, the
reporter's check in `models/reporter.cairo`, the tables in `helpers/bits.cairo` (fix loop 2), the
tracking choices in `store.cairo`, the bounds and the error strings in `constants.cairo` and
`errors.cairo`. `tests/` holds what deploys a contract.

Every test of 0.1.0 is kept (102), one renamed; 43 are new (33, then 3 in fix loop 1, 5 in fix loop 2 and 2 in fix loop 3). **A moved test whose code did not
change costs in `src/` what it cost in `tests/`, to the unit** (the batch's 12 and its 4 benchmarks, the
window's 2, the bounds, the error strings, 9 of the constructor's refusals and 5 of the packing
tests). Those whose code changed, by the model or by `points`:

| Test (now in `models::definition::tests`) | 0.1.0 | 0.2.0 | Why |
|---|---|---|---|
| `definition_new_three_tasks`, `definition_new_rejects_repeated_task`, `bench_definition_new_three_tasks` | 39 430, 20 920, 20 920 | 38 630, 20 120, 20 120 | `DefinitionTrait::new` then `into_slots`, for less than `definition_new` |
| `definition_new_one_task_inline`, `tasks_span_has_task_count_entries`, `definition_new_rejects_repeated_second_task` | 22 860, 43 450, 19 020 | 23 760, 44 250, 19 120 | The same, and `HeadSlot` has one more field to compare |
| `bench_pack_unpack_definition`, `achievement_empty_slot_unpacks_undefined`, `achievement_unpacking_rejects_bit_251` | 34 120, 31 080, 29 460 | 34 790, 31 350, 29 630 | `points` packed and unpacked |
| `achievement_packing_round_trip_definition` | 7 504 240 | 8 636 290 | The `u256` oracle packs `points`: **budget raised**, 7 879 452 → 9 068 105, with its `// gas: raised` note |
| `achievement_packing_widths` | 684 780 | 699 760 | The oracle's widest A is 2^212 − 1; within its budget |
| `achievement_unpacking_rejects_bit_196` → `achievement_unpacking_rejects_bit_212` | 377 810 | 392 860 | Bit 196 is `points`' first: the first reserved bit is 212; within the budget |

In `tests/`, the component's tests are unchanged in what they do; their figures move with the
calls above (`define` −4 370 on 1 task, +1 610 on 3; `retire` +2 570; the view +3 610). A refused
`define` is now much cheaper (`achievement_define_rejects_invalid_id_and_tasks` 2 590 460 →
2 307 150, `achievement_define_rejects_no_task` 1 809 910 → 1 713 440): budgets lowered.

### Fix loop 1

Three tests, each with its budget; no other figure moved. `test_component_track_own` runs the
component under two impls of the consumer's own: `MockTrackDefinitionOnly` (`DEFINITION = true,
REPORTER = false`; `own_impl_tracks_the_definition_only`, 1 516 920) and its mirror
`MockTrackReporterOnly` (`own_impl_tracks_the_reporter_only`, 1 469 300). With the two constants
swapped in the store, these two tests fail and every other test passes: they are the ones that
tell `DEFINITION` from `REPORTER`. `models::definition::tests::definition_is_active_inside_and_outside_its_window`
(25 640) covers `DefinitionTrait::is_active`.

### Fix loop 2

**The status's methods, by value or by snapshot**, measured on the paths that use them (the call
minus its baseline, `test_component_bench`: `define` minus `baseline_deployed`, `retire` and the
view minus `baseline_defined`, as in the rest of this file; corrected in fix loop 3, where the
`define` columns had subtracted `baseline_reporter_registered`):

| Variant | `define`, 3 tasks | `define`, 1 task | `retire` | `achievement_definition` |
|---|---|---|---|---|
| Both by value (fix loop 1) | 1 198 640 | 703 270 | 243 330 | 217 740 |
| `StatusAssert` by `@` | 1 198 740 | 703 370 | 243 530 | 217 840 |
| `StatusStorage` by `@` | 1 198 640 | 703 270 | 243 330 | 217 740 |
| Both by `@` (as `quiver_quest`) | 1 198 740 | 703 370 | 243 530 | 217 840 |

`StatusAssert` stays by value: by snapshot it costs 1 step more per check, +100 on `define` and the
view, +200 on `retire`, which makes two checks. `StatusStorage` costs the same on every entrypoint
either way, so it now takes `@` as `quiver_quest` does. The reason is written above each impl.
Every entrypoint figure is unchanged. One unit test is dearer with `StatusStorage` by `@`:
`models::status::tests::status_retire_keeps_the_definition_bits`, 27 080 → 27 480 (+400), within
its budget (28 434).

Five unit tests, each with its budget: `helpers::bits::tests` (`POW2[i] == 2^i` for each `i`,
947 720; each `TWO_POW_*` against 2^n computed by doubling, 2 000 390; each `NZ_*`, 523 180) and
`models::reporter::tests` (`assert_is_allowed` allowed, 13 720; refused with
`'Achievement: not reporter'`, 15 520).

### Fix loop 3

The table of fix loop 2 is corrected above: its `define` columns now subtract `baseline_deployed`,
as the rest of this file does. Its `retire` and view columns were already right against
`baseline_defined`. Two unit tests of `BitsTrait::split`, each with its budget:
`helpers::bits::tests::split_both_limbs` (17 450) and `split_high_limb_zero` (17 480). No other
figure moved.

## Cost model of `quiver_achievement` 0.1.0 (ARC-04, event mode only)

This section is written by hand below the generated table. `scripts/gas.py --write` rewrites
this file and drops the section; `--check` reads only the rows above.

- Figures are L2 gas as snforge 0.61 reports it, from the full run of this commit.
- Reads, writes and events come from `snforge test --detailed-resources`.
- A call's cost is its test minus its baseline (the same fixture without the call), through a
  dispatcher (`test_component_bench`). The consumer is `MockBench`, whose `authorize_admin`
  accepts every caller; the reads of `progress` and `progress_many` include the reporter check
  of the external ABI (1 read).

**Event mode only** ([decision of 2026-09-29](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-29-achievement-event-only.md)):
progress reads nothing but the reporter, writes nothing and emits one event per merged, non-zero
entry. Its cost depends on the entries of the call only, not on the achievements defined: the
worst call with 48 achievements of 3 tasks on its 16 tasks costs what it costs without them
(`bench_progress_many_late_collision_with_definitions`: 1 816 613 against 1 816 813).

### The price of a storage slot: snforge and the network

As measured by `quiver_quest` ([its GAS.md](https://github.com/bal7hazar/quiver/blob/main/packages/quest/GAS.md#the-price-of-a-storage-slot-snforge-and-the-network)):

| Written slot | snforge 0.61 | The network: FND-04 of the game, the state diffs of 149 Sepolia transactions |
|---|---|---|
| Created (zero → non-zero) | 459 106: the write 57 106 + the allocation 402 000 | about 453 500 |
| Overwritten, zeroed or unchanged | 57 106 | about 32 000 |

The **network estimate** is the measure with each slot the call writes repriced at the network's
price: −5 606 per created slot and −25 106 per overwritten one. Progress writes no slot, so its
estimate is its measure.

### The worst call against the cap

The cap of the [A-G1 amendment](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-28-A-G1-amendment-cost-cap.md) is 20 M L2 gas for the worst call the
package allows; Starknet's limit is 1.1 × 10⁹ L2 gas per transaction ("Max L2 gas per
transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).

| Case | Benchmark (baseline) | Call, snforge | Created / overwritten | Network estimate | Reads / events | Against 20 M | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|
| **The worst `progress_many`**: 16 entries `[1..=15, 129]`, a collision modulo 128 at the 16th, the plain merge in full | `bench_progress_many_late_collision` (`baseline_deployed`) | **1 816 813** | 0 / 0 | 1 816 813 | 1 / 16 | 9.1 % | 0.17 % |
| `progress_many`, 16 entries `[1..=15, 15]`, a late duplicate | `bench_progress_many_late_duplicate` (`baseline_deployed`) | 1 759 993 | 0 / 0 | 1 759 993 | 1 / 15 | 8.8 % | 0.16 % |
| `progress_many`, 16 distinct entries (the fast path) | `bench_progress_many_sixteen_distinct` (`baseline_deployed`) | 1 245 486 | 0 / 0 | 1 245 486 | 1 / 16 | 6.2 % | 0.11 % |
| The worst, with 48 achievements of 3 tasks on its 16 tasks | `bench_progress_many_late_collision_with_definitions` (`baseline_sixteen_tasks_defined`) | 1 816 613 | 0 / 0 | 1 816 613 | 1 / 16 | 9.1 % | 0.17 % |
| `progress`, 1 entry | `bench_progress` (`baseline_deployed`) | 209 236 | 0 / 0 | 209 236 | 1 / 1 | 1.0 % | 0.02 % |
| **The worst `define`**: 3 tasks, A and B created | `bench_define_worst` (`baseline_deployed`) | **1 197 030** | 2 / 0 | 1 185 818 | 1 / 1 | 6.0 % | 0.11 % |
| `define`, 1 task: A only | `bench_define_one_task` (`baseline_deployed`) | 707 640 | 1 / 0 | 702 034 | 1 / 1 | 3.5 % | 0.06 % |
| `retire` (3 tasks: B is not read) | `bench_retire` (`baseline_defined`) | 240 760 | 0 / 1 | 215 654 | 1 / 1 | 1.2 % | 0.02 % |
| `set_reporter`, a new reporter | `bench_set_reporter` (`baseline_deployed`) | 607 410 | 1 / 0 | 601 804 | 0 / 1 | 3.0 % | 0.06 % |
| `set_reporter`, a registered reporter revoked (zeroed) | `bench_set_reporter_revoke` (`baseline_reporter_registered`) | −195 270 in the test; **206 730** in a transaction of its own | 0 / 1 | 181 624 | 0 / 1 | 1.0 % | 0.02 % |
| `set_reporter`, a registered reporter set again (unchanged) | `bench_set_reporter_unchanged` (`baseline_reporter_registered`) | 206 530 | 0 / 1 | 181 424 | 0 / 1 | 1.0 % | 0.02 % |
| `achievement_definition`, 3 tasks | `bench_view_definition_worst` (`baseline_defined`) | 214 130 | — | — | 2 / 0 | — | — |
| `achievement_is_reporter` | `bench_view_is_reporter` (`baseline_deployed`) | 124 690 | — | — | 1 / 0 | — | — |

snforge counts a whole test as one transaction, so the revocation, which zeroes the slot its
setup created, reads 402 000 low; in a transaction of its own it costs 206 730, as `quiver_quest`
found for its own.

**Every figure is under 20 M**, by snforge's prices and by the network's. The worst call the
package allows is `progress_many` on the slowest merge, at 1.82 M: nothing a consumer defines can
make a progress call dearer, since progress reads no definition. Each distinct entry adds about
69 000 (one event); the plain merge, taken when a task id repeats or two ids are equal modulo 128,
adds about 570 000 at 16 entries.

### The game's use (design/13, the MVP's titles)

Eight titles: Pathfinder, Warden, Nestbreaker, Unbroken, Flawless and Grimoire keeper of Region 1
(character), Veteran and Scavenger (account). Each tier is an achievement of one task, and the
tiers of a title share its task (A-7): 3 + 3 + 4 + 3 + 3 + 2 + 3 + 5 = **26 achievements on 8
tasks**. The thresholds are design/13's; where it gives a share, the denominator is illustrative
(it changes the stored totals only, not the cost).

| Case | Benchmark (baseline) | Call, snforge | Created / overwritten | Network estimate | Reads / events | Against 20 M |
|---|---|---|---|---|---|---|
| A typical results transaction: the adventurer's 6 character tasks, then the account's 2, one `progress_many` per player id | `bench_game_results_call` (`baseline_game_defined`) | **829 728** | 0 / 0 | 829 728 | 2 / 8 | 4.1 % |
| The game's bound (A-10): 16 distinct tasks in one call | `bench_game_results_call_sixteen` (`baseline_game_defined`) | 1 245 286 | 0 / 0 | 1 245 286 | 1 / 16 | 6.2 % |
| Defining the 26 tiers **in one transaction** (an admin's setup, once) | `bench_game_define_titles` (`baseline_deployed`) | **18 525 730** | 26 / 0 | 18 379 974 | 26 / 26 | **92.6 %** |

Defining is done once, by the admin; each `define` is at most 1.20 M. **Twenty-six definitions in
one transaction come to 92.6 % of the cap**, 712 528 each on average; a consumer defines its
achievements over several transactions, at most about 25 single-task achievements or 16 of three
tasks per transaction, to stay under 20 M. The package cannot bound this: it is the consumer's
batching of admin calls, not one call of the package.

### Slots created and overwritten, per entrypoint

| Entrypoint | Best case | Worst case |
|---|---|---|
| `progress`, `progress_many` | nothing written | nothing written |
| `define` | 1 created (A) | 2 created (A, B) |
| `retire` | 1 overwritten (A) | 1 overwritten (A) |
| `set_reporter` | 1 write, nothing changed (the value is already set) | 1 created (a new reporter); 1 zeroed (a registered reporter revoked) |
| Views | nothing written | nothing written |

No slot is keyed by a player. The one zeroing is a reporter's revocation.

### Progress writes nothing, guarded

`achievement_progress_writes_nothing` (`test_component_progress`) measures the Sierra gas of a
16-entry `progress_many` through the consumer's results entrypoint (the internal layer) with
`core::testing::get_available_gas()`, and requires it within 20 000 of its reference (603 146).
One storage write is about 58 820, so a write added to the path fails the guard. The writes of
every benchmark above are counted exactly with `snforge test --detailed-resources`.

### The library (`test_bench`)

A figure includes its setup; the function's own cost is the benchmark minus
`bench_baseline_sixteen_entries` (49 990, building the 16 entries).

| Algorithm | Worst case | Benchmark | Measured | Own |
|---|---|---|---|---|
| `batch_merge` | 16 entries, a modulo-128 collision at the 16th | `bench_batch_merge_late_modulo_collision` | 751 523 | 701 533 |
| `batch_merge` | 16 entries, a repeat at the 16th | `bench_batch_merge_late_duplicate` | 747 613 | 697 623 |
| `batch_merge` | 16 distinct entries (the fast path) | `bench_batch_merge_sixteen_distinct` | 180 396 | about 130 000 |
| `definition_new` | 3 tasks | `bench_definition_new_three_tasks` | 20 920 | — |
| `AchievementDefinition` pack and unpack | every field at its maximum | `bench_pack_unpack_definition` | 34 120 | — |
| `AchievementExtraTasks` pack and unpack | every field at its maximum | `bench_pack_unpack_extra_tasks` | 24 930 | — |

## Single-threaded builds (ARC-09, D-176)

No figure moves. On 2026-10-01, from a clean `target/` each time, `snforge test` measured the
145 tests three times with the default thread count and three times with `RAYON_NUM_THREADS=1`:
the six runs give the same l2_gas for every test, and it equals the table above. The tables are
therefore the single-threaded measures, unchanged. CI pins the variable (`.github/workflows/cairo.yml`),
and `scripts/gas.py` pins it unless the caller set it.
