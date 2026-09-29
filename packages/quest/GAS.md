# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest_integrationtest::test_batch::batch_count_of_present_and_absent` | 47260 | 49623 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_at_the_bound` | 152110 | 159716 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_is_the_smallest_position` | 36930 | 38777 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_drops_zero_counts` | 83525 | 87702 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_empty` | 20710 | 21746 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 192526 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 56425 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 96994 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8929614 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::batch_merge_saturates_duplicates` | 271214 | 284775 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_above_bound_reverts` | 74260 | 77973 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_bound_accepted` | 225086 | 236341 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicate_entries_merged` | 55829 | 58621 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 68397 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 89680 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 32886 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero` | 31036 | 32588 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 40375 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 77973 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_empty` | 14120 | 14826 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_fifteen_then_one` | 52410 | 55031 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_distinct` | 62900 | 66045 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 79275 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_count_of_absent` | 90590 | 95120 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_first_position_absent` | 110490 | 116015 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 749113 | 786569 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 790675 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 190991 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 573218 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_claim` | 17940 | 18837 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_conditions_span_seven` | 19540 | 20517 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_definition_new_three_tasks_seven_conditions` | 150760 | 158298 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_held_contains_absent` | 41270 | 43334 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_held_position_absent` | 38570 | 40499 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_held_remove_first` | 46400 | 48720 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_held_slot_last` | 29960 | 31458 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_conditions` | 35620 | 37401 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_definition` | 40560 | 42588 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_held_slot` | 45730 | 48017 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_progress` | 29130 | 30587 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_record` | 23750 | 24938 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_tasks` | 31390 | 32960 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_prerequisites_met_seven` | 29700 | 31185 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 164252 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_progress_is_complete_three_tasks` | 21680 | 22764 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_record_complete` | 16140 | 16947 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_interval_id` | 20130 | 21137 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_is_active` | 19230 | 20192 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_validate` | 17480 | 18354 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_index_of_absent` | 20850 | 21893 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_span_three` | 20050 | 21053 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_completed_reverts` | 15732606 | 16519237 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5419770 | 5690759 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 8645468 | 9077742 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6254310 | 6567026 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_removes_from_list` | 18416120 | 19336926 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10267646 | 10781029 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11173146 | 11731804 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14402382 | 15122502 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_list_full_reverts` | 16276120 | 17089926 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 11546100 | 12123405 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 6851312 | 7193878 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5425950 | 5697248 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 8956788 | 9404628 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_numbers_are_new_on_renewal` | 13705400 | 14390670 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_completed_leaves_list` | 21619296 | 22700261 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10344236 | 10861448 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_expired_acceptance_pruned` | 16282600 | 17096730 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_interval_id_boundary_2_48` | 9198212 | 9658123 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_list_layout` | 12813750 | 13454438 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_pruning` | 35180894 | 36939939 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_shrink` | 16818450 | 17659373 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5598700 | 5878635 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_accept::quest_retired_pruned_at_accept` | 15344390 | 16111610 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5551750 | 5829338 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 4648270 | 4880684 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14435276 | 15157040 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 5856986 | 6149836 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 2970670 | 3119204 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2020890 | 2121935 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4432120 | 4653726 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7385262 | 7754526 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2851310 | 2993876 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5742400 | 6029520 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 5271710 | 5535296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 4951630 | 5199212 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 2969550 | 3118028 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 2940440 | 3087462 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_growth` | 28494462 | 29919186 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_mixed` | 33673192 | 35356852 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_regrow` | 8497700 | 8922585 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_completed` | 38656906 | 40589752 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_expired` | 33600902 | 35280948 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 2843020 | 2985171 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 547842330 | 575234447 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 4225666 | 4436950 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 22558822 | 23686764 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 864930 | 908177 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_full_list` | 8849950 | 9292448 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2064190 | 2167400 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 38656906 | 40589752 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4` | 9977890 | 10476785 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing` | 13345190 | 14012450 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing_hook` | 13345190 | 14012450 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_hook` | 9977890 | 10476785 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8` | 16505920 | 17331216 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing` | 23238690 | 24400625 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing_hook` | 23238690 | 24400625 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_hook` | 16505920 | 17331216 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_reporter_registered` | 1473140 | 1546797 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 25142882 | 26400027 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_three_held` | 6838010 | 7179911 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::baseline_two_held` | 4514240 | 4739952 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 4944990 | 5192240 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_shrink` | 7297480 | 7662354 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_worst` | 9424010 | 9895211 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_growth` | 30416002 | 31936803 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_mixed` | 35357942 | 37125840 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_plain` | 2843020 | 2985171 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_regrow` | 9210450 | 9670973 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_completed` | 40417866 | 42438760 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_expired` | 35200102 | 36960108 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4589686 | 4819171 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 25142502 | 26399628 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1077296 | 1131161 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_all_complete` | 14040584 | 14742614 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_none_counts` | 9793676 | 10283360 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_completes` | 10966446 | 11514769 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_counts` | 10254386 | 10767106 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2696753 | 2831591 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2639133 | 2771090 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2125426 | 2231698 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4` | 16190953 | 17000501 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing` | 16342253 | 17159366 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing_hook` | 18157173 | 19065032 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_hook` | 18005873 | 18906167 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8` | 27936133 | 29332940 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing` | 28236903 | 29648749 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing_hook` | 31866743 | 33460081 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_hook` | 31565973 | 33144272 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_nothing_held` | 2290946 | 2405494 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3680566 | 3864595 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 4225666 | 4436950 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 26146122 | 27453429 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1473140 | 1546797 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter_revoke` | 1278670 | 1342604 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter_unchanged` | 1680470 | 1764494 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 38817536 | 40758413 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 38961306 | 40909372 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_held_full` | 38955596 | 40903376 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 38989856 | 40939349 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 38781596 | 40720676 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 39149396 | 41106866 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 38945196 | 40892456 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 553473176 | 581146835 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 13115916 | 13771712 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 13111126 | 13766683 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11404616 | 11974847 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 22511312 | 23636878 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13373156 | 14041814 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 6944716 | 7291952 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 10061156 | 10564214 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 8978276 | 9427190 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 8001180 | 8401239 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 47474880 | 49848624 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4364050 | 4582253 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3733270 | 3919934 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 4822980 | 5064129 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 2975260 | 3124023 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 13996740 | 14696577 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3029330 | 3180797 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 6329990 | 6646490 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4349750 | 4567238 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2742420 | 2879541 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 7899600 | 8294580 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 8988800 | 9438240 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 11246150 | 11808458 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5649999 | 5932499 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 5358676 | 5626610 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5840206 | 6132217 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5585366 | 5864635 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3165418 | 3323689 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 6351252 | 6668815 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 5409920 | 5680416 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 4972420 | 5221041 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 15865262 | 16658526 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 76814362 | 80655081 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 54156902 | 56864748 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 81367768 | 85436157 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 58710308 | 61645824 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h0` | 905870 | 951164 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_complete` | 2169980 | 2278479 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_count` | 2169980 | 2278479 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_done` | 2592050 | 2721653 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_expired` | 2169980 | 2278479 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_miss` | 2169980 | 2278479 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_complete` | 3012160 | 3162768 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_count` | 3012160 | 3162768 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_done` | 3856200 | 4049010 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_expired` | 3012160 | 3162768 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_miss` | 3012160 | 3162768 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_complete` | 5124040 | 5380242 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_count` | 5124040 | 5380242 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_done` | 6812020 | 7152621 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_expired` | 5124040 | 5380242 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_miss` | 5124040 | 5380242 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_complete` | 9347800 | 9815190 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_count` | 9347800 | 9815190 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_done` | 12723660 | 13359843 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_expired` | 9347800 | 9815190 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_miss` | 9347800 | 9815190 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h0` | 1909563 | 2005042 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_complete` | 4406353 | 4626671 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_count` | 3861993 | 4055093 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_done` | 3692523 | 3877150 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_expired` | 3226763 | 3388102 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_miss` | 3408733 | 3579170 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_complete` | 6592353 | 6921971 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_count` | 5448013 | 5720414 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_done` | 5108973 | 5364422 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_expired` | 4177553 | 4386431 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_miss` | 4541493 | 4768568 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_complete` | 11338323 | 11905240 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_count` | 8993923 | 9443620 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_done` | 8315743 | 8731531 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_expired` | 6453003 | 6775654 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_miss` | 7180883 | 7539928 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_complete` | 20780353 | 21819371 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_count` | 16035833 | 16837625 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_done` | 14679373 | 15413342 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_expired` | 10953993 | 11501693 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_miss` | 12409753 | 13030241 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 15124528 | 15880755 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12225286 | 12836551 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12038216 | 12640127 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 14004922 | 14705169 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 15051932 | 15804529 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 21631348 | 22712916 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 23017018 | 24167869 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 22574618 | 23703349 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 14083232 | 14787394 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 22433058 | 23554711 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_accept` | 14877022 | 15620874 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4036740 | 4238577 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 453720 | 476406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5307920 | 5573316 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 3474220 | 3647931 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_baseline` | 42618190 | 44749100 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_then_change_100` | 48328090 | 50744495 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_empty` | 725230 | 761492 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_set` | 46635830 | 48967622 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_changed_then_restored` | 57965130 | 60863387 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_other` | 52346430 | 54963752 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_zero` | 12146430 | 12753752 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_unchanged` | 52346430 | 54963752 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_set_then_restored` | 12054530 | 12657257 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_to_value` | 46635830 | 48967622 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_unchanged` | 6435830 | 6757622 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2316990 | 2432840 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_held_100` | 2683790 | 2817980 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1161190 | 1219250 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1716190 | 1802000 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 46363620 | 48681801 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 52345030 | 54962282 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 52345030 | 54962282 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 48966887 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5146410 | 5403731 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5021170 | 5272229 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3244280 | 3406494 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 6023329 | 6324496 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 2978580 | 3127509 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8877592 | 9321472 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3038342 | 3190260 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10094822 | 10599564 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6038642 | 6340575 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10455132 | 10977889 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10582132 | 11111239 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 8164522 | 8572749 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 7991632 | 8391214 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_held_by_one_player_not_progressed_by_another` | 10051182 | 10553742 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 8418246 | 8839159 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 6225596 | 6536876 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_not_held_not_progressed` | 6524852 | 6851095 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10431132 | 10952689 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 6136706 | 6443542 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 21590214 | 22669725 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 66713106 | 70048762 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_acceptance_counter_wraps_at_2_30` | 25447898 | 26720293 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_counter_wrap_without_renewal_progresses_both` | 14118426 | 14824348 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_hook_accepting_another_quest_keeps_counts_after_16_bit_wrap` | 16068492 | 16871917 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | 20685566 | 21719845 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | 58980864 | 61929908 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_then_accept_not_progressed` | 17772032 | 18660634 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_abandon_accept_not_progressed` | 12566206 | 13194517 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7575526 | 7954303 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | 16931712 | 17778298 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 59790954 | 62780502 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 61499104 | 64574060 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11972886 | 12571531 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17934392 | 18831112 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 63407290 | 66577655 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10990412 | 11539933 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewal_after_counter_wrap_not_progressed` | 17894382 | 18789102 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewed_not_progressed_others_are` | 20061166 | 21064225 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 58357894 | 61275789 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 13648006 | 14330407 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 4767500 | 5005875 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 6124220 | 6430431 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7268800 | 7632240 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 15182410 | 15941531 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 6469230 | 6792692 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 4986070 | 5235374 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 4861460 | 5104533 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 13315906 | 13981702 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4542630 | 4769762 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 6038850 | 6340793 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 8686956 | 9121304 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::baseline_writes_setup` | 4457690 | 4680575 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::baseline_writes_setup_totals_two` | 4457690 | 4680575 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_completing_writes_p_and_r` | 6333236 | 6649898 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicate_entries_write_p_once` | 5773599 | 6062279 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicates_several_counts_write_each_p_once` | 6417705 | 6738591 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_not_completing_writes_p_only` | 5732816 | 6019457 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_not_completing_write_p_once` | 5748022 | 6035424 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_write_p_and_r_once` | 6291852 | 6606445 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_component_writes::write_costs_58_820_sierra_gas` | 1363000 | 1431150 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::conditions_span_has_count_entries` | 104530 | 109757 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::definition_new_one_task` | 26210 | 27521 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::definition_new_round_trips_through_the_spans` | 70630 | 74162 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::definition_new_three_tasks_seven_conditions` | 160010 | 168011 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::definition_new_unused_slots_are_zero` | 37390 | 39260 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_condition_zero` | 26860 | 28203 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition` | 32830 | 34472 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125380 | 131649 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_half_recurring` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_id` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_window` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_no_task` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task` | 20420 | 21441 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_first_and_last` | 21420 | 22491 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_second_and_last` | 20220 | 21231 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_self_condition` | 21390 | 22460 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_task_zero` | 19020 | 19971 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_too_many_conditions` | 18530 | 19457 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_total_zero` | 20020 | 21021 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43210 | 45371 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_held::held_contains_needs_the_same_interval` | 47370 | 49739 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_held::held_position_finds_the_quest` | 38840 | 40782 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_held::held_remove_keeps_the_order` | 129170 | 135629 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_held::held_slot_pairs_entries_and_pads_with_empty` | 22260 | 23373 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_defined_already_exists` | 19570 | 20549 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_errors_are_those_of_0_1_0` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_event_carries_its_key_and_values` | 40080 | 42084 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_exists_with_its_tasks` | 19940 | 20937 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_new_keeps_its_inputs` | 171330 | 179897 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_reads_the_same_whatever_the_status` | 52930 | 55577 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_condition_zero` | 24560 | 25788 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_eight_conditions` | 16030 | 16832 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_four_tasks` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_half_recurring` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_id_zero_first` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_no_task` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_repeated_condition` | 121580 | 127659 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_repeated_task` | 18120 | 19026 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_self_condition` | 24650 | 25883 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_task_zero` | 16420 | 17241 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_total_zero` | 17520 | 18396 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_rejects_window_second` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_schedule_matches_the_oracle` | 1680090 | 1764095 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_storage_is_the_layout_of_0_1_0` | 4206700 | 4417035 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_undefined_does_not_exist` | 16090 | 16895 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_model_definition::definition_undefined_reads_with_no_task` | 16310 | 17126 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_empty_slot_reads_undefined` | 35300 | 37065 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_accepts_the_bounds` | 4865980 | 5109279 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_presence_bits_at_their_positions` | 1110290 | 1165805 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_16` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_8` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_held_acceptance_2_30` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_held_counter_2_30` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_held_interval_2_48` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_255` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_4` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_conditions` | 19269540 | 20233017 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_max` | 23754800 | 24942540 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_mixed` | 7136390 | 7493210 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_zero` | 2388570 | 2507999 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_held_slot` | 40072930 | 42076577 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_progress` | 11909220 | 12504681 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_record` | 7143570 | 7500749 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_tasks` | 15134650 | 15891383 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 724049 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_reads_held_bit_250_as_kept` | 428680 | 450114 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_conditions_bit_224` | 377250 | 396113 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_bit_215` | 425120 | 446376 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 31580 | 33159 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_251` | 35050 | 36803 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 360234 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 373884 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_record_bit_129` | 356040 | 373842 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 377202 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_add_ignores_other_tasks` | 46840 | 49182 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_add_keeps_claimed` | 16790 | 17630 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9848097 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 66612 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_add_touches_only_task_count_slots` | 24310 | 25526 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::progress_is_complete_per_task_count` | 15940 | 16737 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 61771 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 52513 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value` | 34610 | 36341 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value_below_total` | 22160 | 23268 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_count_saturates_at_total` | 45750 | 48038 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_progress::quest_one_off_completes_once` | 31000 | 32550 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::claim_marks_claimed_and_counts` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::prerequisites_met_when_each_completed_once` | 37080 | 38934 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_claim_index_counts_claims` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_claim_twice_reverts` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_prerequisites_all_required_logic` | 27020 | 28371 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_past_u32` | 22940 | 24087 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_saturate` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::quest_recurring_completes_each_interval_logic` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::quest_interval_id_is_u64` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_recurring` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_one_off_window` | 15940 | 16737 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_recurring` | 16240 | 17052 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 14406 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_empty_window` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 16296 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::baseline_models` | 280260 | 294273 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::baseline_models_existing` | 1115100 | 1170855 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_hand_get` | 1147690 | 1205075 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_tracked_created` | 779810 | 818801 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_tracked_overwritten` | 1212650 | 1273283 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_untracked_created` | 734790 | 771530 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_hand_set_untracked_overwritten` | 1167630 | 1226012 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_store_get` | 1147690 | 1205075 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_store_set_tracked_created` | 779810 | 818801 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_store_set_tracked_overwritten` | 1212650 | 1273283 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_store_set_untracked_created` | 734790 | 771530 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::bench_store_set_untracked_overwritten` | 1167630 | 1226012 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::store_tracked_set_emits_its_event_on_every_write` | 2499620 | 2624601 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::store_untracked_set_emits_nothing` | 2012190 | 2112800 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store::store_writes_what_the_hand_writes` | 2937460 | 3084333 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::baseline_definition` | 340810 | 357851 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::baseline_definition_defined` | 2157860 | 2265753 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::bench_hand_get_definition_worst` | 2227100 | 2338455 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::bench_hand_set_definition_worst` | 1998260 | 2098173 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::bench_store_get_definition_worst` | 2227070 | 2338424 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::bench_store_set_definition_worst` | 1993700 | 2093385 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::store_get_definition_reads_the_model_back` | 4478920 | 4702866 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::store_set_definition_emits_quest_defined_once` | 1891240 | 1985802 | 2026-09-29 | 0227486 |
| `quiver_quest_integrationtest::test_store_definition::store_set_definition_writes_the_slots_of_0_1_0` | 6298470 | 6613394 | 2026-09-29 | 0227486 |

## The store and the definition model (ARC-06, Unreleased)

Written by hand, like the section below; figures from the table above, commit `0227486`. A cost is
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
| `get` | existing | 32 590 | 32 590 | **0** | `bench_hand_get`, `bench_store_get` (`baseline_models_existing`) |

Tracked minus untracked is 45 020 in both cases: the event (1 key besides the selector, 2 data
felts), and nothing else. The model is passed to `set_x` **by value**: by snapshot (`@Plain`,
then `*plain.a`), the same `set` measured 300 more, created or overwritten, tracked or not (3
steps).

### The quest definition (`test_store_definition`, `MockDefinitionStore`)

| Operation | Case | 0.1.0 by hand | Through the model and store | Difference | Benchmarks (baseline) |
|---|---|---|---|---|---|
| write a new definition, and `QuestDefined` | 3 tasks, 7 conditions: A, B, C created | 1 657 450 (`definition_new`, 3 writes, `emit`) | 1 652 890 (`DefinitionTrait::new`, `set_definition`) | −4 560 | `bench_hand_set_definition_worst`, `bench_store_set_definition_worst` (`baseline_definition`) |
| read a definition | 3 tasks, 7 conditions: A, B, C read | 69 240 (the reads of the view, `tasks_span`, `conditions_span`) | 69 210 (`get_definition`) | −30 | `bench_hand_get_definition_worst`, `bench_store_get_definition_worst` (`baseline_definition_defined`) |

### The component, before and after

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

- Figures are L2 gas as snforge 0.61 reports it, from the full run of this commit.
- Reads, writes and events come from `snforge test --detailed-resources`.
- A call's cost is its test minus its baseline (the same fixture without the call), through a
  dispatcher.
- Hooks do nothing (`MockBench`) unless the row says so.

### The price of a storage slot: snforge and the network

A written slot is priced by whether it is **created** (zero before the transaction, non-zero
after) or **overwritten** (non-zero before; this includes a slot zeroed or rewritten unchanged).

| Written slot | snforge 0.61, measured here (`test_component_probe`) | The network: FND-04 of the game, the state diffs of 149 Sepolia transactions (decision of 2026-09-28, correction of 2026-09-29) |
|---|---|---|
| Created (zero → non-zero) | 459 106: the write 57 106 + the allocation 402 000 | about 453 500 |
| Overwritten, zeroed or unchanged | 57 106 | about 32 000 |

**The figures of this file are snforge's**, measured. Where a figure is set against the 20 M cap,
the **network's estimate** is given beside it. That estimate is the measure with each slot the
call writes repriced at the network's price: −5 606 per created slot and −25 106 per
overwritten one. snforge is within 1.3 % of the network on a created slot and overcharges an
overwritten one by 25 000.

The probes of fix loop 1, each transition in its own test, 100 cells per test:

| Transition in the measured call | Test | L2 gas per write |
|---|---|---|
| 0 → 1 (created) | `probe_transition_zero_to_value` | 459 106 |
| 0 → 0 | `probe_transition_zero_unchanged` | 57 106 |
| 0 → 1 → 0 in one call | `probe_transition_zero_set_then_restored` | 113 293 (two writes, nothing created) |
| 1 → 2 (overwritten) | `probe_transition_value_to_other` | 57 106 |
| 1 → 1 | `probe_transition_value_unchanged` | 57 106 |
| 1 → 2 → 1 in one call | `probe_transition_value_changed_then_restored` | 113 293 |
| 1 → 0 (zeroed) | `probe_transition_value_to_zero` | −344 894 in the test: the write, minus the allocation the test's first call made and the clear undid |

snforge counts a whole test as one transaction, so a call that zeroes a slot its setup created
reads 402 000 low. Since fix loop 2 **the held list is never zeroed** (below). The one
entrypoint that zeroes a slot is `set_reporter(reporter, false)` on a registered reporter: its
benchmark reads −194 470, and it costs 207 530 in a transaction of its own. Every other figure is
the call in a transaction of its own.

Other unit costs: storage read 30 205; event of 3 keys and 1 data felt 48 542; unpack
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
| 3 quests per task (48), or 2 (32) | 4 553 406 | 6 / 2 | 4 469 558 |

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
