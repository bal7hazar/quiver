# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest_integrationtest::test_batch::batch_count_of_present_and_absent` | 47260 | 49623 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_at_the_bound` | 152110 | 159716 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_is_the_smallest_position` | 36930 | 38777 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_drops_zero_counts` | 83525 | 87702 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_empty` | 20710 | 21746 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 192526 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 56425 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 96994 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8929614 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::batch_merge_saturates_duplicates` | 271214 | 284775 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_above_bound_reverts` | 74260 | 77973 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_bound_accepted` | 225086 | 236341 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicate_entries_merged` | 55829 | 58621 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 68397 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 89680 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 32886 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero` | 31036 | 32588 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 40375 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 77973 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_empty` | 14120 | 14826 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_fifteen_then_one` | 52410 | 55031 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_distinct` | 62900 | 66045 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 79275 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_count_of_absent` | 90590 | 95120 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_first_position_absent` | 110490 | 116015 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 749113 | 786569 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 790675 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 190991 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 573218 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_claim` | 17940 | 18837 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_conditions_span_seven` | 19540 | 20517 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_definition_new_three_tasks_seven_conditions` | 150760 | 158298 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_held_contains_absent` | 38210 | 40121 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_held_position_absent` | 36970 | 38819 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_held_remove_first` | 43390 | 45560 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_held_slot_last` | 25350 | 26618 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_conditions` | 35620 | 37401 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_definition` | 40560 | 42588 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_held_slot` | 26090 | 27395 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_progress` | 29130 | 30587 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_record` | 23750 | 24938 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_tasks` | 31390 | 32960 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_prerequisites_met_seven` | 29700 | 31185 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 164252 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_progress_is_complete_three_tasks` | 21680 | 22764 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_record_complete` | 16140 | 16947 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_interval_id` | 20130 | 21137 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_is_active` | 19230 | 20192 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_validate` | 17480 | 18354 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_index_of_absent` | 20850 | 21893 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_span_three` | 20050 | 21053 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_completed_reverts` | 15716396 | 16502216 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5377150 | 5646008 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 8507098 | 8932453 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6206530 | 6516857 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_removes_from_list` | 16809520 | 17649996 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10209366 | 10719835 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11068316 | 11621732 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14316292 | 15032107 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_list_full_reverts` | 15774080 | 16562784 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 11420800 | 11991840 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 6787382 | 7126752 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5381060 | 5650113 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 8827098 | 9268453 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_completed_leaves_list` | 21023346 | 22074514 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10271956 | 10785554 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_expired_acceptance_pruned` | 15324140 | 16090347 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_list_layout` | 12574200 | 13202910 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5539790 | 5816780 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_accept::quest_retired_pruned_at_accept` | 14960290 | 15708305 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5466250 | 5739563 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 4594630 | 4824362 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14398976 | 15118925 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 5820686 | 6111721 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 2978730 | 3127667 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2020890 | 2121935 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4392060 | 4611663 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7335572 | 7702351 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2851310 | 2993876 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5719490 | 6005465 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 5248800 | 5511240 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 4961580 | 5209659 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 2969550 | 3118028 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 2940440 | 3087462 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_completed` | 37982436 | 39881558 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_expired` | 33015562 | 34666341 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 2820110 | 2961116 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 552029690 | 579631175 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 4189366 | 4398835 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 22308742 | 23424180 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 864930 | 908177 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_full_list` | 8593710 | 9023396 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2074140 | 2177847 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 37982436 | 39881558 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4` | 9654860 | 10137603 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_hook` | 9654860 | 10137603 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8` | 16177590 | 16986470 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_hook` | 16177590 | 16986470 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 24899562 | 26144541 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::baseline_two_held` | 4468800 | 4692240 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 4855220 | 5097981 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_worst` | 9098170 | 9553079 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_plain` | 2820110 | 2961116 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_completed` | 39269736 | 41233223 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_expired` | 34141102 | 35848158 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4553386 | 4781056 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 24899182 | 26144142 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1077296 | 1131161 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_all_complete` | 13702654 | 14387787 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_none_counts` | 9496786 | 9971626 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_completes` | 10628516 | 11159942 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_counts` | 9957496 | 10455371 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2696753 | 2831591 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2639133 | 2771090 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2125426 | 2231698 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4` | 15786233 | 16575545 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_hook` | 17601153 | 18481211 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8` | 27457013 | 28829864 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_hook` | 31086853 | 32641196 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_nothing_held` | 2287716 | 2402102 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3644266 | 3826480 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 4189366 | 4398835 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 25902802 | 27197943 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1473140 | 1546797 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 38143066 | 40050220 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 38286836 | 40201178 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_held_full` | 38228346 | 40139764 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 38275526 | 40189303 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 38107126 | 40012483 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 38474926 | 40398673 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 38270726 | 40184263 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 557578846 | 585457789 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 13079616 | 13733597 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 13074826 | 13728568 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11368316 | 11936732 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 22429522 | 23550999 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13336856 | 14003699 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 6908416 | 7253837 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 10024856 | 10526099 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 8906166 | 9351475 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 8031610 | 8433191 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 47416290 | 49787105 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4385400 | 4604670 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3894240 | 4088952 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 4842530 | 5084657 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 2986660 | 3135993 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 14087740 | 14792127 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3038930 | 3190877 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 6346680 | 6664014 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4369300 | 4587765 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2742420 | 2879541 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 7929740 | 8326227 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 9028620 | 9480051 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 11286530 | 11850857 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5627089 | 5908444 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 5335766 | 5602555 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5817296 | 6108161 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5562456 | 5840579 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3165418 | 3323689 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 6314952 | 6630700 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 4954880 | 5202624 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 4982370 | 5231489 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 15837352 | 16629220 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 76877632 | 80721514 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 54059232 | 56762194 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 81349348 | 85416816 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 58530948 | 61457496 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h0` | 905870 | 951164 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_complete` | 2167700 | 2276085 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_count` | 2167700 | 2276085 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_done` | 2589770 | 2719259 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_expired` | 2167700 | 2276085 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_miss` | 2167700 | 2276085 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_complete` | 3008040 | 3158442 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_count` | 3008040 | 3158442 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_done` | 3852080 | 4044684 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_expired` | 3008040 | 3158442 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_miss` | 3008040 | 3158442 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_complete` | 5114570 | 5370299 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_count` | 5114570 | 5370299 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_done` | 6802550 | 7142678 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_expired` | 5114570 | 5370299 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_miss` | 5114570 | 5370299 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_complete` | 9327630 | 9794012 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_count` | 9327630 | 9794012 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_done` | 12703490 | 13338665 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_expired` | 9327630 | 9794012 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_miss` | 9327630 | 9794012 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h0` | 1896383 | 1991203 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_complete` | 4390683 | 4610218 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_count` | 3846323 | 4038640 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_done` | 3676853 | 3860696 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_expired` | 3211093 | 3371648 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_miss` | 3393063 | 3562717 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_complete` | 6547683 | 6875068 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_count` | 5417023 | 5687875 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_done` | 5077983 | 5331883 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_expired` | 4146563 | 4353892 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_miss` | 4510503 | 4736029 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_complete` | 11247163 | 11809522 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_count` | 8943803 | 9390994 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_done` | 8265623 | 8678905 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_expired` | 6402883 | 6723028 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_miss` | 7130763 | 7487302 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_complete` | 20609393 | 21639863 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_count` | 15960633 | 16758665 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_done` | 14604173 | 15334382 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_expired` | 10878793 | 11422733 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_miss` | 12334553 | 12951281 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 15039398 | 15791368 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12199226 | 12809188 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12012156 | 12612764 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 13933282 | 14629947 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 14972422 | 15721044 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 21469138 | 22542595 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 22899888 | 24044883 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 22457398 | 23580268 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 14011592 | 14712172 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 22316018 | 23431819 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_accept` | 14755372 | 15493141 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4046690 | 4249025 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 453720 | 476406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5307920 | 5573316 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 3474220 | 3647931 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_baseline` | 42618190 | 44749100 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_then_change_100` | 48328090 | 50744495 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2316990 | 2432840 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_held_100` | 1365790 | 1434080 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1161190 | 1219250 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1716190 | 1802000 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 46363620 | 48681801 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 52345030 | 54962282 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 52345030 | 54962282 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 48966887 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5121650 | 5377733 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 4996410 | 5246231 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3244280 | 3406494 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 5987029 | 6286381 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 2978580 | 3127509 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8803432 | 9243604 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3038342 | 3190260 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10056672 | 10559506 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6000492 | 6300517 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10405442 | 10925715 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10532442 | 11059065 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 8082732 | 8486869 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 7909842 | 8305335 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_held_by_one_player_not_progressed_by_another` | 9978582 | 10477512 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 8345936 | 8763233 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 6189296 | 6498761 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_not_held_not_progressed` | 6475372 | 6799141 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10381442 | 10900515 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 6100406 | 6405427 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 21449544 | 22522022 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 66613976 | 69944675 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | 19927736 | 20924123 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | 57955694 | 60853479 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7502496 | 7877621 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | 16823202 | 17664363 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 58696954 | 61631802 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 60637724 | 63669611 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11596606 | 12176437 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17820932 | 18711979 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 62492180 | 65616789 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10940322 | 11487339 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 57497014 | 60371865 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 13561206 | 14239267 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 4787050 | 5026403 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 5653610 | 5936291 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7288990 | 7653440 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 14741210 | 15478271 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 6489420 | 6813891 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 4996020 | 5245821 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 4821400 | 5062470 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 13279606 | 13943587 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4552580 | 4780209 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 5946250 | 6243563 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 8614646 | 9045379 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::conditions_span_has_count_entries` | 104530 | 109757 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::definition_new_one_task` | 26210 | 27521 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::definition_new_round_trips_through_the_spans` | 70630 | 74162 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::definition_new_three_tasks_seven_conditions` | 160010 | 168011 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::definition_new_unused_slots_are_zero` | 37390 | 39260 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_condition_zero` | 26860 | 28203 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition` | 32830 | 34472 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125380 | 131649 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_half_recurring` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_id` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_window` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_no_task` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task` | 20420 | 21441 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_first_and_last` | 21420 | 22491 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_second_and_last` | 20220 | 21231 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_self_condition` | 21390 | 22460 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_task_zero` | 19020 | 19971 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_too_many_conditions` | 18530 | 19457 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_total_zero` | 20020 | 21021 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43210 | 45371 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_held::held_contains_needs_the_same_interval` | 37620 | 39501 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_held::held_position_finds_the_quest` | 38240 | 40152 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_held::held_remove_keeps_the_order` | 118150 | 124058 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_held::held_slot_pairs_entries_and_pads_with_empty` | 19040 | 19992 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_empty_slot_reads_undefined` | 35300 | 37065 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_accepts_the_bounds` | 3702550 | 3887678 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_presence_bits_at_their_positions` | 1110290 | 1165805 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_16` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_8` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_255` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_4` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_conditions` | 19269540 | 20233017 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_max` | 23754800 | 24942540 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_mixed` | 7136390 | 7493210 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_zero` | 2388570 | 2507999 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_held_slot` | 9215370 | 9676139 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_progress` | 11909220 | 12504681 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_record` | 7143570 | 7500749 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_tasks` | 15134650 | 15891383 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 724049 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_conditions_bit_224` | 377250 | 396113 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_bit_215` | 425120 | 446376 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 31580 | 33159 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_224` | 369620 | 388101 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_96` | 339180 | 356139 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 360234 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 373884 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_record_bit_129` | 356040 | 373842 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 377202 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_add_ignores_other_tasks` | 46840 | 49182 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_add_keeps_claimed` | 16790 | 17630 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9848097 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 66612 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_add_touches_only_task_count_slots` | 24310 | 25526 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::progress_is_complete_per_task_count` | 15940 | 16737 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 61771 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 52513 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value` | 34610 | 36341 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value_below_total` | 22160 | 23268 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_count_saturates_at_total` | 45750 | 48038 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_progress::quest_one_off_completes_once` | 31000 | 32550 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::claim_marks_claimed_and_counts` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::prerequisites_met_when_each_completed_once` | 37080 | 38934 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_claim_index_counts_claims` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_claim_twice_reverts` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_prerequisites_all_required_logic` | 27020 | 28371 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_past_u32` | 22940 | 24087 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_saturate` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::quest_recurring_completes_each_interval_logic` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::quest_interval_id_is_u64` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_recurring` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_one_off_window` | 15940 | 16737 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_recurring` | 16240 | 17052 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 14406 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_empty_window` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 16296 | 2026-09-29 | 556d2c5 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 16296 | 2026-09-29 | 556d2c5 |

## Cost model of `quiver_quest` 0.1.0 (ARC-03c, D-135)

This section is written by hand below the generated table. `scripts/gas.py --write` rewrites
this file and drops the section; `--check` reads only the rows above. Figures are L2 gas as
snforge 0.61 reports it, from the full run of this commit. Reads, writes and events come from
`snforge test --detailed-resources`. A call's cost is its test minus its baseline (the same
fixture without the call), through a dispatcher. Hooks do nothing (`MockBench`) unless the row
says so.

### The cost of a changed slot (`test_component_probe`, 100 operations per test)

| Operation | L2 gas | of which Sierra gas |
|---|---|---|
| Storage read, `Map` with a tuple key | 30 205 | 30 205 |
| **Storage write to a slot whose value changes in the transaction** | **459 099** | 57 099 |
| Storage write of a slot already changed in the transaction, or unchanged | 57 099 | 57 099 |
| Event of 3 keys and 1 data felt (`QuestCompleted`'s shape) | 48 542 | 12 742 |
| Unpack `QuestDefinition` / `QuestTasks` / `QuestRecord` / `QuestHeldSlot` | 18 633 / 12 625 / 7 075 / 9 121 | same |

The figures are the same as ARC-03b's (the probes were re-run): **a slot changed by a transaction
costs 402 000 L2 gas beyond its write's computation**, once per slot per transaction. That is the
state diff. snforge counts a whole test as one transaction. A slot the setup of a test already
changed, whether by a call or by the `store` cheatcode (`probe_store_then_change_100`: 57 099
per write), costs a benchmark only 57 099 to change again. The benchmarks below say where that
happens and give the transaction's figure, which adds 402 000 per such slot.

### The held list

`Quest_held: Map<(player_id, slot), QuestHeldSlot>`, slots 0 to 3, two entries per slot:

| Bits of a slot | Field |
|---|---|
| [0, 32) | `e0.quest_id` (0 = empty) |
| [32, 96) | `e0.interval_id`, the interval of the acceptance |
| [96, 128) | reserved (zero) |
| [128, 160) | `e1.quest_id` |
| [160, 224) | `e1.interval_id` |
| [224, 252) | reserved (zero) |

The entries are contiguous and in the order of acceptance. A slot whose `e1` is empty ends the
list, so `progress_many` reads 1 slot for 0 or 1 held quests, 2 for 2 or 3, and 3 for 4. `MAX_HELD
= 4` bounds only `accept`. The walk reads up to 4 slots (8 entries, `MAX_HELD_LIMIT`), whatever
`MAX_HELD` is, and that is how the H = 8 case is measured with the same code.

**Why this layout.** Acceptance lives in the list alone. The record lost `active` and
`accepted_interval`, and each entry carries the interval of its acceptance. As a result:

- **progress never writes the list.** A completed, expired or retired entry stays in place
  (dead) until the next `accept` prunes it. The slots a progress call changes are only those it
  cannot avoid: each counted quest's progress P, and each completed quest's record R.
- **`accept` and `abandon` change the list slot alone** in the common case (1 slot), not the list
  and the record.
- The layout was chosen to minimise the changed slots of progress, then of `accept` and `abandon`.

**Why pruning happens at `accept`, not at progress.** Measured in the grid below:

- A dead entry costs a later progress call 0.07 M (expired: one read of A) to 0.12 M (completed:
  A and P). Pruning it at progress would change a list slot, 0.46 M, in the call that meets it.
- So pruning at progress pays only when four or more progress calls follow before the player's
  next `accept`.
- It would also add up to 2 (H = 4) or 4 (H = 8) changed slots, 0.9 M or 1.8 M, to the worst
  call.
- `accept` already reads the list to find room, so pruning there costs the dead entries' reads
  and no extra slot in the common case.

### The worst call (`test_component_bench`)

The worst call is 16 entries `[1..=15, 129]`. The last one collides modulo 128, so
`batch_merge`'s plain merge runs in full. Every held quest completes. Each held quest has 3
tasks at the batch's last three positions (the longest lookups) and a daily schedule (a
division). H = 4 is built by `accept`. For H = 8, entries 5 to 8 are seeded into slots 2 and 3
with `store`. P, R and the hook's slots are untouched by the setup, so every changed slot is
counted in full.

| Case | Benchmark | Call (L2 gas) | Reads | Writes | Events | Against 20 M | Against 1.1 × 10⁹ |
|---|---|---|---|---|---|---|---|
| H = 4, hooks empty | `bench_progress_many_worst_held4` | 6 131 373 | 23 | 8 | 4 | 31 % | 0.56 % |
| H = 8, hooks empty | `bench_progress_many_worst_held8` | 11 279 423 | 44 | 16 | 8 | 56 % | 1.03 % |
| H = 4, hook writes one slot | `bench_progress_many_worst_held4_hook` | 7 946 293 | 23 | 12 | 4 | 40 % | 0.72 % |
| H = 8, hook writes one slot | `bench_progress_many_worst_held8_hook` | 14 909 263 | 44 | 24 | 8 | 75 % | 1.36 % |

Reads include the reporter check (1). At H = 4 the 23 reads are: the reporter, the list (3
slots), then A, P, B and R per quest (16), and one slot per later quest to check that it is still
held after the previous quest's hook (3). A hook that writes one fresh slot adds about 0.45 M per
completion. The network's limit is 1.1 × 10⁹ L2 gas per transaction ("Max L2 gas per
transaction", docs.starknet.io, Learn > Cheatsheets > Chain info, read 2026-09-28).

### The grid (`test_component_grid`): H held quests, each in one state

The call is `progress_many(PLAYER, [1..=15, 129], Storage)` against a seeded list. Each row gives
the call's L2 gas:

| H | all complete | all count (no completion) | none in the batch | all completed earlier (dead) | all expired (dead) |
|---|---|---|---|---|---|
| 0 | 990 513 | | | | |
| 1 | 2 222 983 | 1 678 623 | 1 225 363 | 1 087 083 | 1 043 393 |
| 2 | 3 539 643 | 2 408 983 | 1 502 463 | 1 225 903 | 1 138 523 |
| 4 | 6 132 593 | 3 829 233 | 2 016 193 | 1 463 073 | 1 288 313 |
| 8 | 11 281 763 | 6 633 003 | 3 006 923 | 1 900 683 | 1 551 163 |

Per entry, (call − call at H = 0) / H, and what it pays for:

| Entry | H = 1 | H = 2 | H = 4 | H = 8 | What it pays for |
|---|---|---|---|---|---|
| completing | 1 232 470 | 1 274 565 | 1 285 520 | 1 286 406 | A, P, B, R read; P and R changed (918 000); the event; from the second entry on, one slot read to check that it is still held after the previous hook |
| counting | 688 110 | 709 235 | 709 680 | 705 311 | A, P, B read; P changed (459 000) |
| missed (none of its tasks in the batch) | 234 850 | 255 975 | 256 420 | 252 051 | A, P, B read; the batch scanned for its 3 tasks |
| done (completed earlier in the interval) | 96 570 | 117 695 | 118 140 | 113 771 | A, P read |
| expired (accepted in an earlier interval) | 52 880 | 74 005 | 74 450 | 70 081 | A read |

So `call(H) ≤ 990 513 + 1 287 000 × H`: 990 513 for the reporter check, the list's first slot
and the merge of 16 entries, and at most 1.29 M per held quest.

The quests defined on a task but not held cost nothing. At H = 4 the worst call is 6.1 M. For
comparison, the 20.6 M of ARC-03b's smallest 16-entry configuration came from 16 quests
completing. The package now allows at most H.

### Grim World's case (`test_component_game`)

16 task entries; 3 held quests and one daily contract, all accepted and all completing;
prerequisites 0 to 2, checked and cached by `accept`; every task shared by 2 or 3 quests in all,
the others not accepted.

| Case | Call (L2 gas), measured | Transaction's figure | Reads | Writes | Events |
|---|---|---|---|---|---|
| 3 quests per task (48) | 4 471 716 | 5 275 716 | 23 | 8 | 4 |
| 2 quests per task (32) | 4 471 716 | 5 275 716 | 23 | 8 | 4 |

The two are equal: the quests not held are not read. The transaction's figure adds 2 × 402 000.
The records of quests 2 and 3 were changed in the same test by `accept`, which cached their
unlock, so the benchmark counts their completion write as a second change. In a real
transaction, where the accept came earlier, it is a first change. ARC-03b measured this case at
10.1 M.

### Slots changed per entrypoint

| Entrypoint | Best | Common | Worst |
|---|---|---|---|
| `progress`, `progress_many`, `Mode::Event` | 0 | 0 | 0 |
| `progress`, `progress_many`, `Mode::Storage` | 0 (nothing held counts) | 1 per quest that counts (P); 2 per quest that completes (P, R) | 2H: 8 at H = 4, 16 at H = 8; plus the hooks' own. The list: never |
| `accept` | 1 (the list slot of the new entry) | 1; 2 when the quest has conditions and its unlock is cached now (R) | 3 at H = 4: both list slots (pruning moves the entries up) and R |
| `abandon` | 1 (the entry's slot, when it is in the last slot) | 1 or 2 | 2 at H = 4: both list slots (the later entries move up) |
| `claim` | 2 (P, R) | 2 | 2 |
| `define` | 2 (A, B) | 2 + K (C and the K prerequisites' `live_dependents`) | 10 (A, B, C and 7 prerequisites) |
| `retire` | 1 (A) | 1 + K | 8 (A and 7 prerequisites) |
| `set_reporter` | 1 (its flag) | 1 | 1 |
| Views | 0 | 0 | 0 |

### Every entrypoint, measured

The transaction's figure adds 402 000 per slot that the call changes and its setup had already
changed in the same test (see the first section). Where that count is 0, the two figures are the
same.

| Entrypoint | Case | Benchmark (baseline) | Call, measured | Changed slots | Of them already changed by the setup | Transaction's figure | Reads / writes / events |
|---|---|---|---|---|---|---|---|
| `progress_many` | the worst, H = 4 | `bench_progress_many_worst_held4` | 6 131 373 | 8 | 0 | 6 131 373 | 23 / 8 / 4 |
| `progress_many` | the worst, H = 8 | `bench_progress_many_worst_held8` | 11 279 423 | 16 | 0 | 11 279 423 | 44 / 16 / 8 |
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests on each task not held | `quest_batch_bound_accepted` | 5 549 156 | 8 | 0 | 5 549 156 | 23 / 8 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` (`baseline_full_list`) | 5 108 944 | 8 | 0 | 5 108 944 | 23 / 8 / 4 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` (`baseline_full_list`) | 1 363 786 | 1 | 0 | 1 363 786 | 16 / 1 / 0 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` (`baseline_full_list`) | 2 034 806 | 2 | 0 | 2 034 806 | 20 / 2 / 1 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` (`baseline_full_list`) | 903 076 | 0 | 0 | 903 076 | 16 / 0 / 0 |
| `progress` | 1 held, counts | `bench_progress_plain` (`baseline_accepted`) | 824 156 | 1 | 0 | 824 156 | 5 / 1 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` (`baseline_accepted`) | 1 369 256 | 2 | 0 | 1 369 256 | 6 / 2 / 1 |
| `progress` | nothing held | `bench_progress_nothing_held` (`baseline_plain`) | 213 576 | 0 | 0 | 213 576 | 2 / 0 / 0 |
| `accept` | the worst: 7 prerequisites not cached, 4 dead entries completed now, all pruned | `bench_accept_worst_completed` | 1 287 300 | 3 | 2 | 2 091 300 | 22 / 3 / 0 |
| `accept` | same, 4 entries expired at rollover | `bench_accept_worst_expired` | 1 125 540 | 3 | 2 | 1 929 540 | 18 / 3 / 0 |
| `accept` | no prerequisite, empty list | `bench_accept_plain` (`baseline_plain`) | 745 970 | 1 | 0 | 745 970 | 3 / 1 / 0 |
| `abandon` | the worst: first of 4, the others move up | `bench_abandon_worst` (`baseline_full_list`) | 504 460 | 2 | 2 | 1 308 460 | 5 / 2 / 0 |
| `abandon` | second of 2 | `bench_abandon` (`baseline_two_held`) | 386 420 | 1 | 1 | 788 420 | 4 / 1 / 0 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 364 020 | 2 | 2 | 1 168 020 | 2 / 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 2 590 440 | 10 | 7 | 5 404 440 | 8 / 10 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 1 003 240 | 8 | 8 | 4 219 240 | 9 / 8 / 1 |
| `set_reporter` | — | `bench_set_reporter` (`baseline_deployed`) | 608 210 | 1 | 0 | 608 210 | 0 / 1 / 1 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 212 366 | 0 | 0 | 212 366 | 1 / 0 / 1 |
| `progress_many`, event mode | 16 entries, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 1 831 823 | 0 | 0 | 1 831 823 | 1 / 0 / 16 |

Reads of `progress` and `progress_many` include the reporter check (1). ARC-03b's `claim`
benchmark had the same setup, so its 369 300 was a second change of P and R too.
