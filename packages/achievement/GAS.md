# Gas of `quiver_achievement`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
set at `ceil(1.05 x measured)` and never above it; a budget kept tighter, between the
measure and that ceiling, also passes (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_achievement::constants::tests::achievement_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-10-01 | 340b085 |
| `quiver_achievement::errors::tests::achievement_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_define_rejects_id_zero` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_empty_slot_unpacks_undefined` | 31350 | 32634 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_points_at_their_position` | 873150 | 916808 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_presence_bits_at_their_positions` | 700910 | 735956 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_rejects_task_count_above_max` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_round_trip_definition` | 8636290 | 9068105 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_round_trip_extra_tasks` | 3616100 | 3796905 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_packing_widths` | 699760 | 719019 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_extra_rejects_bit_128` | 341400 | 358470 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_rejects_bit_212` | 392860 | 396701 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::achievement_unpacking_rejects_bit_251` | 29630 | 30933 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::bench_definition_new_three_tasks` | 20120 | 21126 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::bench_pack_unpack_definition` | 34790 | 35826 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::bench_pack_unpack_extra_tasks` | 24930 | 26177 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_is_active_inside_and_outside_its_window` | 25640 | 26922 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_checks_id_first` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_checks_window_before_tasks` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_one_task_inline` | 23760 | 24003 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_empty_window` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_end_before_start` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_four_tasks` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_no_task` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_repeated_second_task` | 19120 | 19971 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_repeated_task` | 20120 | 21126 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_task_id_zero` | 16420 | 17241 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_rejects_total_zero` | 17520 | 18396 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_new_three_tasks` | 38630 | 40562 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::definition_points_stored_and_read_back` | 52490 | 55115 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::definition::tests::tasks_span_has_task_count_entries` | 44250 | 45623 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::status::tests::status_cannot_retire_twice` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::status::tests::status_cannot_retire_undefined` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::status::tests::status_defined_refuses_define` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement::models::status::tests::status_retire_keeps_the_definition_bits` | 27080 | 28434 | 2026-10-01 | 340b085 |
| `quiver_achievement::store::tests::tracking_choices_are_all_or_none` | 15040 | 15792 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::achievement_batch_merges_duplicates` | 170289 | 178804 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_count_of_first_entry_or_zero` | 26290 | 27605 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_above_bound_reverts` | 74260 | 77973 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_bound_accepted` | 228416 | 239837 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_distinct_keeps_order_and_drops_zeros` | 51568 | 54147 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_duplicates_count_toward_bound` | 62140 | 65247 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_late_duplicate` | 1756663 | 1844497 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_modulo_collision_not_merged` | 1821523 | 1912600 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_rejects_task_zero` | 38452 | 40375 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_rejects_task_zero_after_collision` | 62209 | 65320 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_saturates` | 80115 | 84121 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::batch_merge_zero_sum_duplicate_dropped` | 79555 | 83533 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::bench_baseline_sixteen_entries` | 49990 | 52490 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_late_duplicate` | 747613 | 784994 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_late_modulo_collision` | 751523 | 789100 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::batch::tests::bench_batch_merge_sixteen_distinct` | 180396 | 189416 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::window::tests::window_is_active_bounds` | 15640 | 16422 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::window::tests::window_validate_accepts_open_and_ordered_windows` | 13720 | 14406 | 2026-10-01 | 340b085 |
| `quiver_achievement::types::window::tests::window_validate_rejects_empty_window` | 15520 | 16296 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_consumer_calls_the_internal_layer` | 3038506 | 3190432 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_define_admin_only` | 2323390 | 2435979 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_internal_layer_not_reachable_from_abi` | 1730160 | 1816668 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_accepts_registered_reporter` | 3008982 | 3159432 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_many_rejects_unregistered_caller` | 2123860 | 2230053 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_rejects_unregistered_caller` | 1962320 | 2060436 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_reporter_revoked` | 2341876 | 2458970 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_retire_admin_only` | 3102180 | 3252291 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_admin_only` | 2398750 | 2518688 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_event_fields` | 1833500 | 1925175 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_defined` | 1987950 | 2086151 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_deployed` | 789600 | 829080 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_game_defined` | 19200090 | 20160095 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_reporter_registered` | 1397010 | 1466861 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::baseline_sixteen_tasks_defined` | 58493900 | 61361139 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_one_task` | 1492870 | 1567514 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_worst` | 1988240 | 2085962 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_define_titles` | 19201710 | 20161796 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call` | 20029818 | 21031309 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call_sixteen` | 20445376 | 21467645 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress` | 998836 | 1048778 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision` | 2606413 | 2736734 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision_with_definitions` | 60310513 | 63268583 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_duplicate` | 2549593 | 2677073 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_sixteen_distinct` | 2035086 | 2136841 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_retire` | 2231280 | 2338949 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter` | 1397010 | 1466861 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_revoke` | 1201740 | 1261827 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_unchanged` | 1603540 | 1683717 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_definition_worst` | 2205690 | 2310987 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_is_reporter` | 914290 | 960005 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_one_task_writes_a_only` | 2588120 | 2716718 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_empty_window` | 1817350 | 1906517 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_invalid_id_and_tasks` | 2307150 | 2422508 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_no_task` | 1713440 | 1799112 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_three_tasks_writes_a_and_b` | 3031440 | 3177920 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_twice_reverts` | 2874960 | 3018708 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_defined_event_fields` | 2836590 | 2978420 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_empty_slot_reads_undefined` | 1594230 | 1673763 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_many_on_one_task` | 22792860 | 23932503 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_define::achievement_redefine_retired_reverts` | 3112330 | 3267947 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_above_bound_reverts` | 1865070 | 1958324 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_bound_accepted` | 3135596 | 3292376 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_duplicates_count_toward_bound` | 1853550 | 1946228 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_one_event_per_merged_task` | 1983799 | 2082989 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_rejects_task_zero` | 1898532 | 1993459 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_event_mode_emits_only_progressed` | 3082436 | 3232495 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progress_writes_nothing` | 2481676 | 2605760 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progressed_event_fields` | 1822486 | 1913611 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_retired_progress_still_emits` | 3584402 | 3763623 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_tiers_share_task_one_event` | 4484176 | 4708385 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_progress::achievement_zero_count_emits_nothing` | 2363248 | 2481411 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_one_tier_only` | 3760910 | 3948956 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_sets_retired_and_keeps_the_rest` | 3694240 | 3869061 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_twice_reverts` | 3071340 | 3224088 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_undefined_reverts` | 1780420 | 1866732 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_track_none::track_none_component_emits_action_events_only` | 3705985 | 3891285 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_track_own::own_impl_tracks_the_definition_only` | 1516920 | 1592766 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_component_track_own::own_impl_tracks_the_reporter_only` | 1469300 | 1542765 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::get_definition_reads_the_model_back` | 2658150 | 2791058 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::status_never_emits` | 2276220 | 2390031 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::track_all_definition_emits_once_per_write` | 2119200 | 2225160 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::track_all_reporter_emits_once_per_write` | 994320 | 1044036 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::track_none_definition_emits_nothing_and_writes_the_same` | 3629480 | 3810954 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_store_models::track_none_reporter_emits_nothing_and_writes_the_same` | 1826410 | 1917731 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_one_task` | 292760 | 307398 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_reporter` | 279050 | 293003 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_all_three_tasks` | 304400 | 319620 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_one_task` | 292760 | 307398 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_reporter` | 279050 | 293003 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::baseline_track_none_three_tasks` | 304400 | 319620 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_one_task_hand` | 830850 | 872393 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_one_task_store` | 830850 | 872393 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_three_tasks_hand` | 1325750 | 1392038 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_definition_three_tasks_store` | 1325750 | 1392038 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_reporter_hand` | 774880 | 813624 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_all_reporter_store` | 774880 | 813624 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_one_task_hand` | 760670 | 798704 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_one_task_store` | 760670 | 798704 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_three_tasks_hand` | 1230990 | 1292540 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_definition_three_tasks_store` | 1230990 | 1292540 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_reporter_hand` | 733680 | 770364 | 2026-10-01 | 340b085 |
| `quiver_achievement_integrationtest::test_tracking::bench_track_none_reporter_store` | 733680 | 770364 | 2026-10-01 | 340b085 |

## `quiver_achievement` 0.2.0 (ARC-07b)

This section and the ones below are written by hand under the generated table.
`scripts/gas.py --write` rewrites this file and drops them; `--check` reads only the rows above.
Figures are L2 gas as snforge 0.61 reports it; a call's cost is its benchmark minus its baseline.
0.1.0's figures were measured on this branch before any change (`dd503a4`).

### Optional tracking

`tests/test_tracking.cairo`: the package's own models, created, on `MockStoreNone` (`TrackNone`)
and `MockStoreAll` (`TrackAll`). In each contract the store's `set_x` is set against the
hand-written write of the same model (`DefinitionTrait::new`, its slots written by hand, then the
component's `emit` under `TrackAll`, nothing under `TrackNone`): the only difference is the
tracking path.

| Model | Choice | Store (`bench_track_*_store`) | By hand (`bench_track_*_hand`) | Store − hand | Call (minus `baseline_track_*`) |
|---|---|---|---|---|---|
| Definition, 1 task: A | `TrackNone` | 760 670 | 760 670, the write with no event code | **0** | 467 910 |
| Definition, 1 task: A | `TrackAll` | 830 850 | 830 850, the write then `emit` | **0** | 538 090 |
| Definition, 3 tasks: A and B | `TrackNone` | 1 230 990 | 1 230 990 | **0** | 926 590 |
| Definition, 3 tasks: A and B | `TrackAll` | 1 325 750 | 1 325 750 | **0** | 1 021 350 |
| Reporter, created | `TrackNone` | 733 680 | 733 680 | **0** | 454 630 |
| Reporter, created | `TrackAll` | 774 880 | 774 880 | **0** | 495 830 |

The compiler folds the constant: under `TrackNone` a write costs exactly the write with no event
code, under `TrackAll` the write plus the event, to the unit, as ARC-07a measured on
`quiver_quest`. What a consumer saves by not tracking: 70 180 per `define` of 1 task, 94 760 of 3
tasks (`AchievementDefined`), 41 200 per `set_reporter` (`AchievementReporterSet`). The action
events (`AchievementRetired`, `AchievementProgressed`) are emitted whatever the choice
(`test_component_track_none`).

### Every entrypoint, before and after

`test_component_bench` runs under `TrackAll`, as 0.1.0 behaves (`MockBench`).

| Call | Benchmark (baseline) | 0.1.0 | 0.2.0 | Difference |
|---|---|---|---|---|
| **The worst `progress_many`** | `bench_progress_many_late_collision` (`baseline_deployed`) | 1 816 813 | 1 816 813 | 0 |
| `progress_many`, late duplicate | `bench_progress_many_late_duplicate` (`baseline_deployed`) | 1 759 993 | 1 759 993 | 0 |
| `progress_many`, 16 distinct | `bench_progress_many_sixteen_distinct` (`baseline_deployed`) | 1 245 486 | 1 245 486 | 0 |
| The worst, with 48 definitions | `bench_progress_many_late_collision_with_definitions` (`baseline_sixteen_tasks_defined`) | 1 816 613 | 1 816 613 | 0 |
| `progress` | `bench_progress` (`baseline_deployed`) | 209 236 | 209 236 | 0 |
| **The worst `define`**: 3 tasks | `bench_define_worst` (`baseline_deployed`) | 1 197 030 | 1 198 640 | +1 610 (+0.13 %), `points` stored |
| `define`, 1 task | `bench_define_one_task` (`baseline_deployed`) | 707 640 | 703 270 | −4 370 |
| `retire` | `bench_retire` (`baseline_defined`) | 240 760 | 243 330 | +2 570 (+1.1 %), `points` in A's unpack and pack |
| `set_reporter`, new | `bench_set_reporter` (`baseline_deployed`) | 607 410 | 607 410 | 0 |
| `set_reporter`, revoked | `bench_set_reporter_revoke` (`baseline_reporter_registered`) | −195 270 | −195 270 | 0 |
| `set_reporter`, unchanged | `bench_set_reporter_unchanged` (`baseline_reporter_registered`) | 206 530 | 206 530 | 0 |
| `achievement_definition`, 3 tasks | `bench_view_definition_worst` (`baseline_defined`) | 214 130 | 217 740 | +3 610 (+1.7 %), `points` unpacked and returned |
| `achievement_is_reporter` | `bench_view_is_reporter` (`baseline_deployed`) | 124 690 | 124 690 | 0 |
| The game's results call | `bench_game_results_call` (`baseline_game_defined`) | 829 728 | 829 728 | 0 |
| The game's bound, 16 tasks | `bench_game_results_call_sixteen` (`baseline_game_defined`) | 1 245 286 | 1 245 286 | 0 |
| The game's 26 tiers defined | `bench_game_define_titles` (`baseline_deployed`) | 18 525 730 | 18 412 110 | −113 620 (−4 370 per `define` of 1 task) |

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

The worst call the package allows is unchanged: `progress_many` on the slowest merge, 1 816 813,
9.1 % of the 20 M cap of A-G1. The worst `define` is 1 198 640 (6.0 %); 26 tiers defined in one
transaction 18 412 110 (92.1 %, 92.6 % in 0.1.0).

### Where the tests went (D-167), and their budgets

The unit tests are in their module's file, under `#[cfg(test)] mod tests`
(`quiver_achievement::<module>::tests::<test>` above): the batch and its benchmarks in
`types/batch.cairo`, the window in `types/window.cairo`, the definition's constructor, slots,
packing and benchmarks in `models/definition.cairo`, the status in `models/status.cairo`, the
tracking choices in `store.cairo`, the bounds and the error strings in `constants.cairo` and
`errors.cairo`. `tests/` holds what deploys a contract.

Every test of 0.1.0 is kept (102), one renamed; 36 are new (33, then 3 in fix loop 1). **A moved test whose code did not
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
