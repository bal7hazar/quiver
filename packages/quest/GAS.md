# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest_integrationtest::test_batch::batch_count_of_present_and_absent` | 47260 | 49623 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_first_position_at_the_bound` | 152110 | 159716 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_first_position_is_the_smallest_position` | 36930 | 38777 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_drops_zero_counts` | 83525 | 87702 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_empty` | 20710 | 21746 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 192526 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 56425 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 96994 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8929614 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::batch_merge_saturates_duplicates` | 271214 | 284775 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_above_bound_reverts` | 74260 | 77973 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_bound_accepted` | 225086 | 236341 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicate_entries_merged` | 55829 | 58621 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 68397 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 89680 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 32886 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero` | 31036 | 32588 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 40375 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 77973 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_baseline_empty` | 14120 | 14826 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_baseline_fifteen_then_one` | 52410 | 55031 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_distinct` | 62900 | 66045 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 79275 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_count_of_absent` | 90590 | 95120 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_first_position_absent` | 110490 | 116015 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 749113 | 786569 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 790675 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 190991 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 573218 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_claim` | 17940 | 18837 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_conditions_span_seven` | 19540 | 20517 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_definition_new_three_tasks_seven_conditions` | 150760 | 158298 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_held_contains_absent` | 41270 | 43334 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_held_position_absent` | 38570 | 40499 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_held_remove_first` | 46400 | 48720 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_held_slot_last` | 28450 | 29873 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_conditions` | 35620 | 37401 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_definition` | 40560 | 42588 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_held_slot` | 35920 | 37716 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_progress` | 29130 | 30587 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_record` | 23750 | 24938 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_tasks` | 31390 | 32960 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_prerequisites_met_seven` | 29700 | 31185 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 164252 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_progress_is_complete_three_tasks` | 21680 | 22764 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_record_complete` | 16140 | 16947 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_schedule_interval_id` | 20130 | 21137 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_schedule_is_active` | 19230 | 20192 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_schedule_validate` | 17480 | 18354 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_tasks_index_of_absent` | 20850 | 21893 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_bench::bench_tasks_span_three` | 20050 | 21053 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_completed_reverts` | 15757576 | 16545455 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5405360 | 5675628 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 8604318 | 9034534 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6260390 | 6573410 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_removes_from_list` | 17754170 | 18641879 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10251446 | 10764019 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11139986 | 11696986 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14387262 | 15106626 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_list_full_reverts` | 16132680 | 16939314 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 11562110 | 12140216 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 6842292 | 7184407 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5410170 | 5680679 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 8931188 | 9377748 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_numbers_are_new_on_renewal` | 13661370 | 14344439 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_completed_leaves_list` | 21463886 | 22537081 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10335916 | 10852712 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_expired_acceptance_pruned` | 15731090 | 16517645 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_held_list_layout` | 12766500 | 13404825 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5590800 | 5870340 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_accept::quest_retired_pruned_at_accept` | 15251380 | 16013949 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5536720 | 5813556 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 4649480 | 4881954 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14427296 | 15148661 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 5891196 | 6185756 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 2978730 | 3127667 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2020890 | 2121935 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4433950 | 4655648 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7376862 | 7745706 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2892300 | 3036915 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5857810 | 6150701 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 5305140 | 5570397 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 4961580 | 5209659 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 2969550 | 3118028 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 2940440 | 3087462 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_growth` | 28438902 | 29860848 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_mixed` | 33553222 | 35230884 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_completed` | 38512026 | 40437628 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_expired` | 33481632 | 35155714 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 2835460 | 2977233 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 552229890 | 579841385 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 4217686 | 4428571 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 22509382 | 23634852 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 864930 | 908177 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_full_list` | 8793910 | 9233606 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2074140 | 2177847 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 38512026 | 40437628 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4` | 9897390 | 10392260 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_hook` | 9897390 | 10392260 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8` | 16439050 | 17261003 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_hook` | 16439050 | 17261003 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 25100202 | 26355213 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::baseline_two_held` | 4500290 | 4725305 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 4910020 | 5155521 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_worst` | 9332780 | 9799419 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_growth` | 30328862 | 31845306 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_mixed` | 35201612 | 36961693 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_plain` | 2835460 | 2977233 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_completed` | 39834526 | 41826253 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_expired` | 34642372 | 36374491 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4581706 | 4810792 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 25099822 | 26354814 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1078096 | 1132001 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_all_complete` | 13958934 | 14656881 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_none_counts` | 9726576 | 10212905 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_completes` | 10884796 | 11429036 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_counts` | 10187286 | 10696651 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2697553 | 2832431 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2639933 | 2771930 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2126226 | 2232538 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4` | 16084843 | 16889086 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_hook` | 17899763 | 18794752 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8` | 27815963 | 29206762 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_hook` | 31445803 | 33018094 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_nothing_held` | 2300376 | 2415395 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3672586 | 3856216 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 4217686 | 4428571 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 26103442 | 27408615 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1473140 | 1546797 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 38672656 | 40606289 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 38816426 | 40757248 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_held_full` | 38800256 | 40740269 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 38833816 | 40775507 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 38636716 | 40568552 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 39004516 | 40954742 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 38800316 | 40740332 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 557835126 | 585726883 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 13107936 | 13763333 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 13103146 | 13758304 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11396636 | 11966468 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 22486472 | 23610796 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13365176 | 14033435 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 6936736 | 7283573 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 10053176 | 10555835 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 8958486 | 9406411 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 8031610 | 8433191 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 47647470 | 50029844 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4385400 | 4604670 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3894240 | 4088952 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 4842530 | 5084657 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 2986660 | 3135993 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 14087740 | 14792127 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3038930 | 3190877 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 6346680 | 6664014 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4369300 | 4587765 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2742420 | 2879541 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 7929740 | 8326227 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 9028620 | 9480051 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 11286530 | 11850857 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5643239 | 5925401 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 5351916 | 5619512 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5833446 | 6125119 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5578606 | 5857537 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3167018 | 3325369 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 6344072 | 6661276 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 5387190 | 5656550 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 4982370 | 5231489 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 15866472 | 16659796 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 77147642 | 81005025 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 54329242 | 57045705 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 81675438 | 85759210 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 58857038 | 61799890 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h0` | 905870 | 951164 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_complete` | 2168330 | 2276747 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_count` | 2168330 | 2276747 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_done` | 2590400 | 2719920 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_expired` | 2168330 | 2276747 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_miss` | 2168330 | 2276747 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_complete` | 3009540 | 3160017 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_count` | 3009540 | 3160017 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_done` | 3853580 | 4046259 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_expired` | 3009540 | 3160017 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_miss` | 3009540 | 3160017 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_complete` | 5118510 | 5374436 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_count` | 5118510 | 5374436 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_done` | 6806490 | 7146815 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_expired` | 5118510 | 5374436 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_miss` | 5118510 | 5374436 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_complete` | 9336450 | 9803273 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_count` | 9336450 | 9803273 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_done` | 12712310 | 13347926 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_expired` | 9336450 | 9803273 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_miss` | 9336450 | 9803273 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h0` | 1909043 | 2004496 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_complete` | 4404283 | 4624498 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_count` | 3859923 | 4052920 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_done` | 3690453 | 3874976 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_expired` | 3224693 | 3385928 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_miss` | 3406663 | 3576997 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_complete` | 6579043 | 6907996 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_count` | 5439553 | 5711531 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_done` | 5100513 | 5355539 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_expired` | 4169093 | 4377548 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_miss` | 4533033 | 4759685 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_complete` | 11307183 | 11872543 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_count` | 8977333 | 9426200 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_done` | 8299153 | 8714111 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_expired` | 6436413 | 6758234 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_miss` | 7164293 | 7522508 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_complete` | 20715703 | 21751489 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_count` | 16005133 | 16805390 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_done` | 14648673 | 15381107 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_expired` | 10923293 | 11469458 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_miss` | 12379053 | 12998006 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 15109418 | 15864889 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12227546 | 12838924 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12040476 | 12642500 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 13990322 | 14689839 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 15055602 | 15808383 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 21588298 | 22667713 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 22985558 | 24134836 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 22543158 | 23670316 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 14068632 | 14772064 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 22401598 | 23521678 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_accept` | 14854302 | 15597018 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4046690 | 4249025 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 453720 | 476406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5307920 | 5573316 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 3474220 | 3647931 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_store_baseline` | 42618190 | 44749100 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_store_then_change_100` | 48328090 | 50744495 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_empty` | 725230 | 761492 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_set` | 46635830 | 48967622 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_changed_then_restored` | 57965130 | 60863387 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_other` | 52346430 | 54963752 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_zero` | 12146430 | 12753752 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_unchanged` | 52346430 | 54963752 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_set_then_restored` | 12054530 | 12657257 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_to_value` | 46635830 | 48967622 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_unchanged` | 6435830 | 6757622 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2316990 | 2432840 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_held_100` | 2128790 | 2235230 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1161190 | 1219250 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1716190 | 1802000 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 46363620 | 48681801 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 52345030 | 54962282 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 52345030 | 54962282 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 48966887 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5137000 | 5393850 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5011760 | 5262348 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3326260 | 3492573 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 6015349 | 6316117 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 3019570 | 3170549 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8855952 | 9298750 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3120322 | 3276339 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10084992 | 10589242 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6028812 | 6330253 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10446732 | 10969069 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10573732 | 11102419 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 8139682 | 8546667 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 7966792 | 8365132 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_held_by_one_player_not_progressed_by_another` | 10035222 | 10536984 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 8398456 | 8818379 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 6217616 | 6528497 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_not_held_not_progressed` | 6516352 | 6842170 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10422732 | 10943869 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 6128726 | 6435163 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 21548094 | 22625499 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 66870256 | 70213769 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | 20184886 | 21194131 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | 58755484 | 61693259 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_then_accept_not_progressed` | 17707772 | 18593161 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_abandon_accept_not_progressed` | 12519606 | 13145587 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7558806 | 7936747 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | 16916482 | 17762307 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 59529614 | 62506095 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 61320964 | 64387013 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11941716 | 12538802 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17903812 | 18799003 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 63213140 | 66373797 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10981912 | 11531008 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewed_not_progressed_others_are` | 19537396 | 20514266 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 58179754 | 61088742 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 13623366 | 14304535 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 4787050 | 5026403 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 6101570 | 6406649 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7288990 | 7653440 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 15089400 | 15843870 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 6489420 | 6813891 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 4996020 | 5245821 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 4863290 | 5106455 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 13307926 | 13973323 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4552580 | 4780209 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 6024520 | 6325746 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 8667166 | 9100525 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_completing_writes_p_and_r` | 6306746 | 6622084 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicate_entries_write_p_once` | 5751959 | 6039557 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_not_completing_writes_p_only` | 5711176 | 5996735 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_write_p_and_r_once` | 6270212 | 6583723 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_component_writes::write_costs_58_820_sierra_gas` | 1363000 | 1431150 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::conditions_span_has_count_entries` | 104530 | 109757 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::definition_new_one_task` | 26210 | 27521 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::definition_new_round_trips_through_the_spans` | 70630 | 74162 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::definition_new_three_tasks_seven_conditions` | 160010 | 168011 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::definition_new_unused_slots_are_zero` | 37390 | 39260 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_condition_zero` | 26860 | 28203 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition` | 32830 | 34472 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125380 | 131649 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_half_recurring` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_id` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_window` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_no_task` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task` | 20420 | 21441 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_first_and_last` | 21420 | 22491 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_second_and_last` | 20220 | 21231 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_self_condition` | 21390 | 22460 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_task_zero` | 19020 | 19971 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_too_many_conditions` | 18530 | 19457 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_total_zero` | 20020 | 21021 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43210 | 45371 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_held::held_contains_needs_the_same_interval` | 47370 | 49739 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_held::held_position_finds_the_quest` | 38840 | 40782 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_held::held_remove_keeps_the_order` | 129170 | 135629 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_held::held_slot_pairs_entries_and_pads_with_empty` | 20640 | 21672 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_empty_slot_reads_undefined` | 35300 | 37065 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_accepts_the_bounds` | 4354780 | 4572519 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_presence_bits_at_their_positions` | 1110290 | 1165805 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_16` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_8` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_255` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_4` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_conditions` | 19269540 | 20233017 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_max` | 23754800 | 24942540 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_mixed` | 7136390 | 7493210 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_zero` | 2388570 | 2507999 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_held_slot` | 23615000 | 24795750 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_progress` | 11909220 | 12504681 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_record` | 7143570 | 7500749 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_tasks` | 15134650 | 15891383 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 724049 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_conditions_bit_224` | 377250 | 396113 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_bit_215` | 425120 | 446376 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 31580 | 33159 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_240` | 391530 | 411107 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_251` | 420690 | 441725 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 360234 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 373884 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_record_bit_129` | 356040 | 373842 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 377202 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_add_ignores_other_tasks` | 46840 | 49182 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_add_keeps_claimed` | 16790 | 17630 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9848097 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 66612 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_add_touches_only_task_count_slots` | 24310 | 25526 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::progress_is_complete_per_task_count` | 15940 | 16737 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 61771 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 52513 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value` | 34610 | 36341 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value_below_total` | 22160 | 23268 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_count_saturates_at_total` | 45750 | 48038 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_progress::quest_one_off_completes_once` | 31000 | 32550 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::claim_marks_claimed_and_counts` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::prerequisites_met_when_each_completed_once` | 37080 | 38934 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_claim_index_counts_claims` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_claim_twice_reverts` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_prerequisites_all_required_logic` | 27020 | 28371 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_record_counters_past_u32` | 22940 | 24087 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_record_counters_saturate` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::quest_recurring_completes_each_interval_logic` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::quest_interval_id_is_u64` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_recurring` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_one_off_window` | 15940 | 16737 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_recurring` | 16240 | 17052 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 14406 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_empty_window` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 16296 | 2026-09-29 | 94b6d5d |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 16296 | 2026-09-29 | 94b6d5d |

## Cost model of `quiver_quest` 0.1.0 (ARC-03c, D-135)

This section is written by hand below the generated table. `scripts/gas.py --write` rewrites
this file and drops the section; `--check` reads only the rows above. Figures are L2 gas as
snforge 0.61 reports it, from the full run of this commit. Reads, writes and events come from
`snforge test --detailed-resources`. A call's cost is its test minus its baseline (the same
fixture without the call), through a dispatcher. Hooks do nothing (`MockBench`) unless the row
says so.

### The cost of a write, by the transition of its cell (`test_component_probe`)

Starknet charges **402 000 L2 gas for each storage cell allocated by a transaction**: a cell
that is zero at the start of the transaction and non-zero at its end. It is the allocation cost
of the versioned constants (blockifier 0.14.2, `allocation_cost`), counted from the final state
diff. Every write also costs its execution, 57 106. snforge applies the same rule, with a whole
test as the transaction. ARC-03b's "402 000 per changed slot" was wrong: fix loop 1 of ARC-03c
corrects it.

Each transition is measured in its own test, 100 cells per test:

- a first call sets the cells to 1 where the transition starts from a value;
- the tests are compared with a baseline that makes the same first call, or none;
- so the setup's allocations are equal on both sides.

| Transition of the cell, in the measured call | Test | L2 gas per write | Allocation |
|---|---|---|---|
| 0 → 1 | `probe_transition_zero_to_value` | 459 106 | yes |
| 0 → 0 | `probe_transition_zero_unchanged` | 57 106 | no |
| 0 → 1 → 0 in one call | `probe_transition_zero_set_then_restored` | 113 293 (two writes) | no |
| 1 → 2 | `probe_transition_value_to_other` | 57 106 | no |
| 1 → 1 | `probe_transition_value_unchanged` | 57 106 | no |
| 1 → 2 → 1 in one call | `probe_transition_value_changed_then_restored` | 113 293 (two writes) | no |
| 1 → 0 | `probe_transition_value_to_zero` | −344 894 in the test | no: the clear costs 57 106, and it also removes the allocation the test's first call had made (−402 000), since the cell ends where the test started |

**In a transaction of its own**, a cell that is non-zero at the start costs 57 106 to update, to
clear or to rewrite unchanged, and pays no allocation. There is no refund for a clear.

**Consequence for the benchmarks.**

- A call that updates a cell its setup allocated is measured right: 57 106 per write, as in a
  transaction of its own.
- A call that **clears** a cell its setup allocated reads 402 000 low in snforge. Only the rows
  marked "(clear)" below need the correction; the others are the transaction's figure as
  measured.

Other unit costs, unchanged:

| Operation | L2 gas |
|---|---|
| Storage read | 30 205 |
| Event of 3 keys and 1 data felt | 48 542 |
| Unpack `QuestDefinition` / `QuestTasks` / `QuestRecord` / `QuestHeldSlot` | 18 633 / 12 625 / 7 075 / 16 751 |

### The held list

`Quest_held: Map<(player_id, slot), QuestHeldSlot>`, slots 0 to 3, two entries per slot:

| Bits of a slot | Field |
|---|---|
| [0, 32) | `e0.quest_id` (0 = empty) |
| [32, 96) | `e0.interval_id`, the interval of the acceptance |
| [96, 112) | `e0.acceptance`, the player's acceptance number |
| [112, 128) | `counter`: the number of the player's last acceptance, in slot 0 only (zero elsewhere) |
| [128, 160) | `e1.quest_id` |
| [160, 224) | `e1.interval_id` |
| [224, 240) | `e1.acceptance` |
| [240, 252) | reserved (zero) |

The entries are contiguous and in the order of acceptance. A slot whose `e1` is empty ends the
list, so `progress_many` reads 1 slot for 0 or 1 held quests, 2 for 2 or 3, and 3 for 4.
`MAX_HELD = 4` bounds only `accept`. The walk reads up to 4 slots (8 entries, `MAX_HELD_LIMIT`),
whatever `MAX_HELD` is, and that is how the H = 8 case is measured with the same code.

**Acceptance numbers** (fix loop 1, point 2). Each `accept` stamps its entry with
`counter + 1` (wrapping at 2^16) and stores that number as the new counter. A quest abandoned
and accepted again in the same interval is therefore a different entry. A progress call compares
whole entries after a hook has run, so a renewed entry is excluded from the call that was
running, like a new one.

A collision would need 65 536 acceptances by one player inside one progress call, which no
transaction can afford.

The counter keeps slot 0 non-zero once the player has accepted anything: later accepts update
slot 0 rather than allocate it. Its cost on the common path of progress is the wider unpack:
+21 030 Sierra gas per call with two entries (`test_component_writes`). `accept` updates slot 0
for the counter when the new entry lands in slot 1, which is one more write (57 106, never an
allocation).

**Acceptance lives in the list alone.** The record has no `active` or `accepted_interval` bit.
Progress needs no record to know an acceptance and never writes the list. `accept` and `abandon`
write the list's slots and, for `accept`, the record only when it caches an unlock.

**Pruning is lazy, at `accept`** (the comparison is redone with the corrected cost in fix loop 1):

- **Lazy.** A dead entry costs each later progress call its reads: 0.05–0.08 M when expired (A)
  and 0.10–0.12 M when completed (A and P); see the grid below.
- **Pruning at progress.** It would rewrite a list slot in the call that meets the dead entries.
  Removing entries never allocates, so that is one update, 57 106, plus the rewrite, about
  0.07–0.09 M per call that prunes. Before the correction it looked like 0.46 M.
- **Break-even.** Pruning at progress pays when a dead entry would be walked by **two or more**
  later progress calls before the player's next `accept`, and costs more when the next action is
  an `accept`. That is the case after a completion (claim at a board, take a new quest), and for
  a daily quest renewed the next day.
- **The worst call.** The worst call has no dead entry either way. Pruning at progress would add
  up to 2 slot updates (0.11 M) to a call where every held quest completes.
- **Why lazy stays.** Pruning at progress would also have to write the list after hooks that may
  have changed it in the same call (point 2). The difference is small either way and depends on
  the consumer's pattern. Lazy pruning is kept, and the choice is left open for the orchestrator.

### The worst call (`test_component_bench`)

The worst call is 16 entries `[1..=15, 129]`. The last one collides modulo 128, so
`batch_merge`'s plain merge runs in full. Every held quest completes. Each held quest has 3
tasks at the batch's last three positions and a daily schedule. H = 4 is built by `accept`. For
H = 8, entries 5 to 8 are seeded into slots 2 and 3 with `store`.

**It is allocation-heavy, and the figures stand as measured.** Each quest's progress P is
allocated (the first count of the interval) and its record R is allocated (the first
completion), and so are the hook's slots. That is the worst case: when R is already non-zero (the
quest was completed or claimed before, or an unlock was cached), the completion updates R, which
costs 402 000 less.

| Case | Benchmark | Call (L2 gas) | Writes | Allocations | Reads / events | Against 20 M | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|
| H = 4, hooks empty | `bench_progress_many_worst_held4` | 6 187 453 | 8 | 8 | 23 / 4 | 31 % | 0.56 % |
| H = 8, hooks empty | `bench_progress_many_worst_held8` | 11 376 913 | 16 | 16 | 44 / 8 | 57 % | 1.03 % |
| H = 4, hook writes one slot | `bench_progress_many_worst_held4_hook` | 8 002 373 | 12 | 12 | 23 / 4 | 40 % | 0.73 % |
| H = 8, hook writes one slot | `bench_progress_many_worst_held8_hook` | 15 006 753 | 24 | 24 | 44 / 8 | 75 % | 1.36 % |

Reads include the reporter check (1). The network's limit is 1.1 × 10⁹ L2 gas per transaction
("Max L2 gas per transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read
2026-09-28).

### The grid (`test_component_grid`): H held quests, each in one state

The call is `progress_many(PLAYER, [1..=15, 129], Storage)` against a seeded list; P and R are
allocated where written. Each row gives the call's L2 gas:

| H | all complete | all count (no completion) | none in the batch | all completed earlier (dead) | all expired (dead) |
|---|---|---|---|---|---|
| 0 | 1 003 173 | | | | |
| 1 | 2 235 953 | 1 691 593 | 1 238 333 | 1 100 053 | 1 056 363 |
| 2 | 3 569 503 | 2 430 013 | 1 523 493 | 1 246 933 | 1 159 553 |
| 4 | 6 188 673 | 3 858 823 | 2 045 783 | 1 492 663 | 1 317 903 |
| 8 | 11 379 253 | 6 668 683 | 3 042 603 | 1 936 363 | 1 586 843 |

Per entry, (call − call at H = 0) / H:

| Entry | H = 1 | H = 2 | H = 4 | H = 8 | What it pays for |
|---|---|---|---|---|---|
| completing | 1 232 780 | 1 283 165 | 1 296 375 | 1 297 010 | A, P, B, R read; P and R allocated (2 × 459 106); the event; from the second entry on, one slot read after the previous hook |
| counting | 688 420 | 713 420 | 713 912 | 708 188 | A, P, B read; P allocated (459 106). An update instead (a later count in the interval) costs 402 000 less |
| missed (none of its tasks in the batch) | 235 160 | 260 160 | 260 652 | 254 928 | A, P, B read; the batch scanned for its 3 tasks |
| done (completed earlier in the interval) | 96 880 | 121 880 | 122 372 | 116 648 | A, P read |
| expired (accepted in an earlier interval) | 53 190 | 78 190 | 78 682 | 72 958 | A read |

So `call(H) ≤ 1 003 173 + 1 298 000 × H` with every write an allocation: 1 003 173 for the
reporter check, the list's first slot and the merge of 16 entries, and at most 1.30 M per held
quest. The quests defined on a task but not held cost nothing.

### Grim World's case (`test_component_game`)

16 task entries; 3 held quests and one daily contract, all accepted and all completing;
prerequisites 0 to 2, checked and cached by `accept`; every task shared by 2 or 3 quests in all,
the others not accepted.

| Case | Call (L2 gas) | Writes | Allocations | Reads / events |
|---|---|---|---|---|
| 3 quests per task (48) | 4 527 796 | 8 | 6 | 23 / 4 |
| 2 quests per task (32) | 4 527 796 | 8 | 6 | 23 / 4 |

The two are equal because the quests not held are not read. The four P and the records of
quests 1 and 4 are allocated. The records of quests 2 and 3 are updates: their unlock was cached
by `accept`, so they were non-zero. That holds in the benchmark and in a transaction of its own,
so **4 527 796 is the transaction's figure**. The correction of +804 000 given in the first
version of this section was wrong. ARC-03b measured this case at 10.1 M.

### Writes, changed slots and allocations per entrypoint

A **write** is a storage write syscall. A **changed slot** is a slot whose value the call
changes. An **allocation** is a slot that goes from zero to non-zero, and costs 402 000 more
than any other write.

| Entrypoint | Writes | Changed slots | Allocations |
|---|---|---|---|
| `progress`, `progress_many`, `Mode::Event` | 0 | 0 | 0 |
| `progress`, `progress_many`, `Mode::Storage` | 1 per quest that counts (P); + 1 per completion (R). The list: never | = writes | P: on a quest's first count in an interval (later counts update it). R: on its first completion when R is zero (no completion, claim or cached unlock before). Worst: 2H (8 at H = 4, 16 at H = 8), plus the hooks' own |
| `accept` | 1 or 2 list slots (slot 0 always changes: the counter); + R when an unlock is cached | = writes | 0, 1 or 2. Slot 0 only at the player's first accept ever (the counter keeps it non-zero afterwards). Slot 1 when the list grows into it from zero (the third live entry). R when caching an unlock of a quest whose record is zero. Worst: 2 (`bench_accept_growth`) |
| `abandon` | 1 or 2 list slots | = writes (slot 1 may be cleared) | 0 |
| `claim` | 2 (P, R) | 2; **1 (P) when `claims` is saturated at 2^64 − 1** (R is rewritten unchanged) | 0 (both are non-zero after a completion) |
| `define` | 2 + K without conditions (A, B); **3 + K with K > 0 conditions** (A, B, C, and K prerequisites' `live_dependents`) | = writes | A, B, and C when K > 0: 2 or 3. The K prerequisites' A are updates |
| `retire` | 1 + K (A and K prerequisites) | = writes | 0 |
| `set_reporter` | 1 | 1; **0 when the reporter already has that value** | 1 when a new reporter is registered (0 → 1); 0 otherwise (a revocation clears) |
| Views | 0 | 0 | 0 |

### Every entrypoint, measured

"(clear)" marks a call that clears a cell its setup had allocated. For those, the transaction's
figure adds 402 000 per clear; for every other row it equals the measure.

| Entrypoint | Case | Benchmark (baseline) | Call, measured | Writes / allocations | Transaction's figure | Reads / events |
|---|---|---|---|---|---|---|
| `progress_many` | the worst, H = 4 | `bench_progress_many_worst_held4` | 6 187 453 | 8 / 8 | 6 187 453 | 23 / 4 |
| `progress_many` | the worst, H = 8 | `bench_progress_many_worst_held8` | 11 376 913 | 16 / 16 | 11 376 913 | 44 / 8 |
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 5 605 236 | 8 / 8 | 5 605 236 | 23 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` (`baseline_full_list`) | 5 165 024 | 8 / 8 | 5 165 024 | 23 / 4 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` (`baseline_full_list`) | 1 393 376 | 1 / 1 | 1 393 376 | 16 / 0 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` (`baseline_full_list`) | 2 090 886 | 2 / 2 | 2 090 886 | 20 / 1 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` (`baseline_full_list`) | 932 666 | 0 / 0 | 932 666 | 16 / 0 |
| `progress` | 1 held, counts | `bench_progress_plain` (`baseline_accepted`) | 837 126 | 1 / 1 | 837 126 | 5 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` (`baseline_accepted`) | 1 382 226 | 2 / 2 | 1 382 226 | 6 / 1 |
| `progress` | nothing held | `bench_progress_nothing_held` (`baseline_plain`) | 226 236 | 0 / 0 | 226 236 | 2 / 0 |
| `accept` | **the worst**: grows into slot 1 (allocated), K = 7 not cached (R allocated), 2 live weekly entries read | `bench_accept_growth` | 1 889 960 | 3 / 2 | **1 889 960** | 17 / 0 |
| `accept` | mixed list: 2 live weekly and 2 stale daily entries, K = 7 not cached | `bench_accept_mixed` | 1 648 390 | 3 / 1 | 1 648 390 | 20 / 0 |
| `accept` | 4 dead entries completed now, all pruned, K = 7 (clear) | `bench_accept_worst_completed` | 1 322 500 | 3 / 1 | 1 724 500 | 22 / 0 |
| `accept` | 4 entries expired at rollover, all pruned, K = 7 (clear) | `bench_accept_worst_expired` | 1 160 740 | 3 / 1 | 1 562 740 | 18 / 0 |
| `accept` | common: no prerequisite, empty list, first accept | `bench_accept_plain` (`baseline_plain`) | 761 320 | 1 / 1 | 761 320 | 3 / 0 |
| `abandon` | the first of 4, the others move up | `bench_abandon_worst` (`baseline_full_list`) | 538 870 | 2 / 0 | 538 870 | 5 / 0 |
| `abandon` | the second of 2 | `bench_abandon` (`baseline_two_held`) | 409 730 | 1 / 0 | 409 730 | 4 / 0 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 364 020 | 2 / 0 | 364 020 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 2 590 440 | 10 / 3 | 2 590 440 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 1 003 240 | 8 / 0 | 1 003 240 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` (`baseline_deployed`) | 608 210 | 1 / 1 | 608 210 | 0 / 1 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 213 166 | 0 / 0 | 213 166 | 1 / 1 |
| `progress_many`, event mode | 16 entries, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 1 832 623 | 0 / 0 | 1 832 623 | 1 / 16 |

Reads of `progress` and `progress_many` include the reporter check (1). The audit's derivations
are confirmed by measurement: `claim` 0.36 M, `abandon` 0.54 M at its worst (0.50 M before the
acceptance numbers), the game 4.53 M (4.47 M before), and `accept` with pruning 1.72 M (1.69 M
before). The worst `accept` is the one that allocates two slots: 1.89 M.
