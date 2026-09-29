# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest_integrationtest::test_batch::batch_count_of_present_and_absent` | 47260 | 49623 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_at_the_bound` | 152110 | 159716 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_is_the_smallest_position` | 36930 | 38777 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_drops_zero_counts` | 83525 | 87702 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_empty` | 20710 | 21746 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 192526 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 56425 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 96994 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8929614 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::batch_merge_saturates_duplicates` | 271214 | 284775 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_above_bound_reverts` | 74260 | 77973 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_bound_accepted` | 225086 | 236341 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicate_entries_merged` | 55829 | 58621 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 68397 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 89680 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 32886 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero` | 31036 | 32588 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 40375 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 77973 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_empty` | 14120 | 14826 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_fifteen_then_one` | 52410 | 55031 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_distinct` | 62900 | 66045 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 79275 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_count_of_absent` | 90590 | 95120 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_first_position_absent` | 110490 | 116015 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 749113 | 786569 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 790675 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 190991 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 573218 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_claim` | 17940 | 18837 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_conditions_span_seven` | 19540 | 20517 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_definition_new_three_tasks_seven_conditions` | 150760 | 158298 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_held_contains_absent` | 41270 | 43334 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_held_position_absent` | 38570 | 40499 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_held_remove_first` | 46400 | 48720 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_held_slot_last` | 29960 | 31458 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_conditions` | 35620 | 37401 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_definition` | 40560 | 42588 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_held_slot` | 37500 | 39375 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_progress` | 29130 | 30587 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_record` | 23750 | 24938 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_tasks` | 31390 | 32960 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_prerequisites_met_seven` | 29700 | 31185 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 164252 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_progress_is_complete_three_tasks` | 21680 | 22764 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_record_complete` | 16140 | 16947 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_interval_id` | 20130 | 21137 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_is_active` | 19230 | 20192 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_validate` | 17480 | 18354 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_index_of_absent` | 20850 | 21893 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_span_three` | 20050 | 21053 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_completed_reverts` | 15760396 | 16548416 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5412840 | 5683482 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 8600968 | 9031017 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6264050 | 6577253 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_removes_from_list` | 18225370 | 19136639 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10254466 | 10767190 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11143086 | 11700241 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14383732 | 15102919 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_list_full_reverts` | 16168440 | 16976862 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 11562580 | 12140709 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 6834222 | 7175934 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5417850 | 5688743 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 8917738 | 9363625 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_numbers_are_new_on_renewal` | 13677100 | 14360955 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_completed_leaves_list` | 21485846 | 22560139 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10327146 | 10843504 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_expired_acceptance_pruned` | 16158840 | 16966782 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_list_layout` | 12787090 | 13426445 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_pruning` | 35038454 | 36790377 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_held_slot_kept_after_shrink` | 16711730 | 17547317 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5586690 | 5866025 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_accept::quest_retired_pruned_at_accept` | 15283230 | 16047392 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5539740 | 5816727 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 4646890 | 4879235 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14428346 | 15149764 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 5850056 | 6142559 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 2978730 | 3127667 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2020890 | 2121935 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4435820 | 4657611 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7373252 | 7741915 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2851310 | 2993876 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5740550 | 6027578 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 5269860 | 5533353 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 4961580 | 5209659 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 2969550 | 3118028 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 2940440 | 3087462 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_growth` | 28449012 | 29871463 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_mixed` | 33572502 | 35251128 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_regrow` | 8475960 | 8899758 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_completed` | 38525736 | 40452023 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accept_worst_expired` | 33500212 | 35175223 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 2841170 | 2983229 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 552257470 | 579870344 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 4218736 | 4429673 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 22510312 | 23635828 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 864930 | 908177 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_full_list` | 8821490 | 9262565 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2074140 | 2177847 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 38525736 | 40452023 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4` | 9920190 | 10416200 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing` | 13287490 | 13951865 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_existing_hook` | 13287490 | 13951865 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held4_hook` | 9920190 | 10416200 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8` | 16466260 | 17289573 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing` | 23199030 | 24358982 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_existing_hook` | 23199030 | 24358982 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_worst_held8_hook` | 16466260 | 17289573 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 25101132 | 26356189 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_three_held` | 6821930 | 7163027 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::baseline_two_held` | 4510540 | 4736067 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 4925680 | 5171964 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_shrink` | 7265790 | 7629080 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon_worst` | 9369410 | 9837881 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_growth` | 30348222 | 31865634 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_mixed` | 35229842 | 36991335 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_plain` | 2841170 | 2983229 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_regrow` | 9166380 | 9624699 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_completed` | 40259286 | 42272251 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst_expired` | 35072002 | 36825603 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4582756 | 4811894 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 25100752 | 26355790 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1077296 | 1131161 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_all_complete` | 13981644 | 14680727 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_none_counts` | 9749976 | 10237475 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_completes` | 10907506 | 11452882 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_full_list_one_counts` | 10210686 | 10721221 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2696753 | 2831591 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2639133 | 2771090 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2125426 | 2231698 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4` | 16102773 | 16907912 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing` | 16254073 | 17066777 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_existing_hook` | 18068993 | 18972443 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held4_hook` | 17917693 | 18813578 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8` | 27840593 | 29232623 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing` | 28141363 | 29548432 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_existing_hook` | 31771203 | 33359764 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_held8_hook` | 31470433 | 33043955 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_nothing_held` | 2295816 | 2410607 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3673636 | 3857318 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 4218736 | 4429673 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 26104372 | 27409591 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1473140 | 1546797 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 38686366 | 40620685 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 38830136 | 40771643 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_held_full` | 38809186 | 40749646 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 38843446 | 40785619 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 38650426 | 40582948 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 39018226 | 40969138 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 38814026 | 40754728 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 557857836 | 585750728 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 13108986 | 13764436 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 13104196 | 13759406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11397686 | 11967571 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 22487502 | 23611878 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13366226 | 14034538 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 6937786 | 7284676 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 10054226 | 10556938 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 8964416 | 9412637 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 8031610 | 8433191 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 47678760 | 50062698 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4385400 | 4604670 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3894240 | 4088952 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 4842530 | 5084657 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 2986660 | 3135993 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 14087740 | 14792127 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3038930 | 3190877 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 6346680 | 6664014 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4369300 | 4587765 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2742420 | 2879541 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 7929740 | 8326227 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 9028620 | 9480051 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 11286530 | 11850857 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5648149 | 5930557 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 5356826 | 5624668 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5838356 | 6130274 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5583516 | 5862692 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3165418 | 3323689 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 6344322 | 6661539 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 5397540 | 5667417 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 4982370 | 5231489 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 15866722 | 16660059 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 77180722 | 81039759 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 54362322 | 57080439 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 81703648 | 85788831 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 58885248 | 61829511 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h0` | 905870 | 951164 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_complete` | 2168640 | 2277072 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_count` | 2168640 | 2277072 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_done` | 2590710 | 2720246 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_expired` | 2168640 | 2277072 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h1_miss` | 2168640 | 2277072 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_complete` | 3009850 | 3160343 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_count` | 3009850 | 3160343 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_done` | 3853890 | 4046585 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_expired` | 3009850 | 3160343 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h2_miss` | 3009850 | 3160343 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_complete` | 5119120 | 5375076 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_count` | 5119120 | 5375076 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_done` | 6807100 | 7147455 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_expired` | 5119120 | 5375076 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h4_miss` | 5119120 | 5375076 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_complete` | 9337660 | 9804543 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_count` | 9337660 | 9804543 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_done` | 12713520 | 13349196 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_expired` | 9337660 | 9804543 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_h8_miss` | 9337660 | 9804543 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h0` | 1904483 | 1999708 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_complete` | 4399933 | 4619930 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_count` | 3855573 | 4048352 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_done` | 3686103 | 3870409 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_expired` | 3220343 | 3381361 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h1_miss` | 3402313 | 3572429 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_complete` | 6574803 | 6903544 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_count` | 5435543 | 5707321 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_done` | 5096503 | 5351329 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_expired` | 4165083 | 4373338 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h2_miss` | 4529023 | 4755475 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_complete` | 11302923 | 11868070 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_count` | 8973763 | 9422452 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_done` | 8295583 | 8710363 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_expired` | 6432843 | 6754486 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h4_miss` | 7160723 | 7518760 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_complete` | 20714333 | 21750050 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_count` | 16005373 | 16805642 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_done` | 14648913 | 15381359 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_expired` | 10923533 | 11469710 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_grid::grid_h8_miss` | 12379293 | 12998258 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 15105808 | 15861099 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12228596 | 12840026 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12041526 | 12643603 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 13991352 | 14690920 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 15053862 | 15806556 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 21590528 | 22670055 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 22986568 | 24135897 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 22544168 | 23671377 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 14069662 | 14773146 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 22402608 | 23522739 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_accept` | 14857202 | 15600063 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4046690 | 4249025 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 453720 | 476406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5307920 | 5573316 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 3474220 | 3647931 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_baseline` | 42618190 | 44749100 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_store_then_change_100` | 48328090 | 50744495 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_empty` | 725230 | 761492 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_baseline_set` | 46635830 | 48967622 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_changed_then_restored` | 57965130 | 60863387 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_other` | 52346430 | 54963752 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_to_zero` | 12146430 | 12753752 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_value_unchanged` | 52346430 | 54963752 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_set_then_restored` | 12054530 | 12657257 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_to_value` | 46635830 | 48967622 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_transition_zero_unchanged` | 6435830 | 6757622 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2316990 | 2432840 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_held_100` | 2175790 | 2284580 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1161190 | 1219250 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1716190 | 1802000 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 46363620 | 48681801 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 52345030 | 54962282 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 52345030 | 54962282 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 48966887 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5142710 | 5399846 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5017470 | 5268344 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3244280 | 3406494 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 6016399 | 6317219 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 2978580 | 3127509 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8861882 | 9304977 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3038342 | 3190260 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10086042 | 10590345 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6029862 | 6331356 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10443122 | 10965279 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10570122 | 11098629 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 8140712 | 8547748 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 7967822 | 8366214 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_held_by_one_player_not_progressed_by_another` | 10037322 | 10539189 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 8404386 | 8824606 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 6218666 | 6529600 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_not_held_not_progressed` | 6512842 | 6838485 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10419122 | 10940079 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 6129776 | 6436265 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 21544444 | 22621667 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 66892966 | 70237615 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_later_quest_not_progressed` | 20597626 | 21627508 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_other_quest_leaves_outer_unchanged` | 58787374 | 61726743 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_abandon_then_accept_not_progressed` | 17710442 | 18595965 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_abandon_accept_not_progressed` | 12530016 | 13156517 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7557266 | 7935130 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_not_progressed_by_the_call` | 16907692 | 17753077 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 59560264 | 62538278 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 61356784 | 64424624 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11948376 | 12545795 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17905292 | 18800557 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 63244650 | 66406883 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10978402 | 11527323 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_renewed_not_progressed_others_are` | 19956346 | 20954164 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 58215574 | 61126353 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 13629066 | 14310520 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 4787050 | 5026403 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 6106760 | 6412098 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7288990 | 7653440 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 15121250 | 15877313 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 6489420 | 6813891 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 4996020 | 5245821 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 4865160 | 5108418 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 13308976 | 13974425 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4552580 | 4780209 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 6026840 | 6328182 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 8673096 | 9106751 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_completing_writes_p_and_r` | 6312446 | 6628069 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_duplicate_entries_write_p_once` | 5757889 | 6045784 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_not_completing_writes_p_only` | 5717106 | 6002962 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_writes::quest_progress_two_tasks_write_p_and_r_once` | 6276142 | 6589950 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_component_writes::write_costs_58_820_sierra_gas` | 1363000 | 1431150 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::conditions_span_has_count_entries` | 104530 | 109757 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::definition_new_one_task` | 26210 | 27521 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::definition_new_round_trips_through_the_spans` | 70630 | 74162 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::definition_new_three_tasks_seven_conditions` | 160010 | 168011 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::definition_new_unused_slots_are_zero` | 37390 | 39260 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_condition_zero` | 26860 | 28203 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition` | 32830 | 34472 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125380 | 131649 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_half_recurring` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_id` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_window` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_no_task` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task` | 20420 | 21441 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_first_and_last` | 21420 | 22491 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_second_and_last` | 20220 | 21231 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_self_condition` | 21390 | 22460 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_task_zero` | 19020 | 19971 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_too_many_conditions` | 18530 | 19457 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_total_zero` | 20020 | 21021 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43210 | 45371 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_held::held_contains_needs_the_same_interval` | 47370 | 49739 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_held::held_position_finds_the_quest` | 38840 | 40782 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_held::held_remove_keeps_the_order` | 129170 | 135629 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_held::held_slot_pairs_entries_and_pads_with_empty` | 22260 | 23373 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_empty_slot_reads_undefined` | 35300 | 37065 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_accepts_the_bounds` | 4557830 | 4785722 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_presence_bits_at_their_positions` | 1110290 | 1165805 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_16` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_8` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_255` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_4` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_conditions` | 19269540 | 20233017 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_max` | 23754800 | 24942540 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_mixed` | 7136390 | 7493210 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_zero` | 2388570 | 2507999 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_held_slot` | 30394130 | 31913837 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_progress` | 11909220 | 12504681 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_record` | 7143570 | 7500749 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_tasks` | 15134650 | 15891383 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 724049 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_conditions_bit_224` | 377250 | 396113 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_bit_215` | 425120 | 446376 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 31580 | 33159 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_241` | 408630 | 429062 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_held_bit_251` | 421160 | 442218 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 360234 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 373884 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_record_bit_129` | 356040 | 373842 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 377202 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_add_ignores_other_tasks` | 46840 | 49182 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_add_keeps_claimed` | 16790 | 17630 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9848097 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 66612 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_add_touches_only_task_count_slots` | 24310 | 25526 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::progress_is_complete_per_task_count` | 15940 | 16737 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 61771 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 52513 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value` | 34610 | 36341 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value_below_total` | 22160 | 23268 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_count_saturates_at_total` | 45750 | 48038 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_progress::quest_one_off_completes_once` | 31000 | 32550 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::claim_marks_claimed_and_counts` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::prerequisites_met_when_each_completed_once` | 37080 | 38934 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_claim_index_counts_claims` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_claim_twice_reverts` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_prerequisites_all_required_logic` | 27020 | 28371 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_past_u32` | 22940 | 24087 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_saturate` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::quest_recurring_completes_each_interval_logic` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::quest_interval_id_is_u64` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_recurring` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_one_off_window` | 15940 | 16737 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_recurring` | 16240 | 17052 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 14406 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_empty_window` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 16296 | 2026-09-29 | b2260a2 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 16296 | 2026-09-29 | b2260a2 |

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
reads 402 000 low. Since fix loop 2 **no entrypoint zeroes a slot**: the held list keeps its
slots (below). Every other figure is the call in a transaction of its own.

Other unit costs: storage read 30 205; event of 3 keys and 1 data felt 48 542; unpack
`QuestDefinition` / `QuestTasks` / `QuestRecord` / `QuestHeldSlot` 18 633 / 12 625 / 7 075 /
17 221.

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
| [240] | `kept`: set once the slot has held an entry, never cleared (fix loop 2) |
| [241, 252) | reserved (zero) |

The entries are contiguous and in the order of acceptance. A slot whose `e1` is empty ends the
list, so `progress_many` reads 1 slot for 0 or 1 held quests, 2 for 2 or 3, and 3 for 4.
`MAX_HELD = 4` bounds only `accept`. The walk reads up to 4 slots (8 entries, `MAX_HELD_LIMIT`),
whatever `MAX_HELD` is, and that is how the H = 8 case is measured with the same code.

**Acceptance numbers** (fix loop 1).

- Each `accept` stamps its entry with `counter + 1` (wrapping at 2^16) and stores that number as
  the counter.
- A quest abandoned and accepted again in the same interval is a different entry. A progress call
  compares whole entries after a hook has run, so a renewed entry is excluded from the call that
  was running.

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

Measured against the zeroing design (the code of fix loop 1, `94b6d5d`), L2 gas:

| Event of a player's life | Benchmark | Zeroing design | Kept design | Network, zeroing → kept |
|---|---|---|---|---|
| The list grows back into slot 1 (`accept`, 2 other entries held) | `bench_accept_regrow` | 1 084 240 (slot 1 created) | **690 420** (slot 1 overwritten) | ≈ 1 053 500 → ≈ 640 200 |
| The list shrinks out of slot 1 (`abandon` of the third of three) | `bench_abandon_shrink` | 435 600 in a transaction of its own (33 600 in the test, a zeroing) | 443 860 (slot 1 overwritten with the bit) | ≈ 410 500 → ≈ 418 800 |
| `accept` pruning 4 dead entries, K = 7 | `bench_accept_worst_completed` | 1 724 500 in a transaction | 1 733 550 | — |
| The worst `accept`: the list grows into a slot never used, K = 7 | `bench_accept_growth` | 1 889 960 | 1 899 210 | ≈ 1 853 600 → ≈ 1 862 900 |
| **The worst progress call**, H = 4 / H = 8 | `bench_progress_many_worst_held{4,8}` | 6 187 453 / 11 376 913 | **6 182 583 / 11 374 333** | not worse |

**Why the kept design is adopted.**

- **It saves** 393 820 measured (about 421 500 at the network's prices) each time the list grows
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
| H = 4, created, hooks empty | `bench_progress_many_worst_held4` | **6 182 583** | 8 / 0 | 6 137 735 | 31 % / 31 % | 0.56 % |
| H = 4, existing, hooks empty | `bench_progress_many_worst_held4_existing` | 2 966 583 | 0 / 8 | 2 765 735 | 15 % / 14 % | 0.27 % |
| H = 4, created, hook writes one slot | `bench_progress_many_worst_held4_hook` | **7 997 503** | 12 / 0 | 7 930 231 | 40 % / 40 % | 0.73 % |
| H = 4, existing, hook writes one slot | `bench_progress_many_worst_held4_existing_hook` | 4 781 503 | 4 / 8 | 4 558 231 | 24 % / 23 % | 0.43 % |
| H = 8, created, hooks empty | `bench_progress_many_worst_held8` | **11 374 333** | 16 / 0 | 11 284 637 | 57 % / 56 % | 1.03 % |
| H = 8, existing, hooks empty | `bench_progress_many_worst_held8_existing` | 4 942 333 | 0 / 16 | 4 540 637 | 25 % / 23 % | 0.45 % |
| H = 8, created, hook writes one slot | `bench_progress_many_worst_held8_hook` | **15 004 173** | 24 / 0 | 14 869 629 | 75 % / 74 % | 1.36 % |
| H = 8, existing, hook writes one slot | `bench_progress_many_worst_held8_existing_hook` | 8 572 173 | 8 / 16 | 8 125 629 | 43 % / 41 % | 0.78 % |

Reads are 23 at H = 4 and 44 at H = 8, events 4 and 8, in every case. The reporter check (1) is
included. **The figures stated against the cap are the created ones**, the worst the package
allows: 6.18 M at `MAX_HELD = 4` and 15.00 M at the layout's limit of 8 with a hook writing one
new slot. With existing slots, a completing quest costs about 0.80 M less.

### The grid (`test_component_grid`): H held quests, each in one state, P and R created

The call is `progress_many(PLAYER, [1..=15, 129], Storage)` against a seeded list. Each row gives
the call's L2 gas:

| H | all complete | all count (no completion) | none in the batch | all completed earlier (dead) | all expired (dead) |
|---|---|---|---|---|---|
| 0 | 998 613 | | | | |
| 1 | 2 231 293 | 1 686 933 | 1 233 673 | 1 095 393 | 1 051 703 |
| 2 | 3 564 953 | 2 425 693 | 1 519 173 | 1 242 613 | 1 155 233 |
| 4 | 6 183 803 | 3 854 643 | 2 041 603 | 1 488 483 | 1 313 723 |
| 8 | 11 376 673 | 6 667 713 | 3 041 633 | 1 935 393 | 1 585 873 |

Per entry, (call − call at H = 0) / H: completing 1.23–1.30 M (A, P, B, R read; P and R
created, 2 × 459 106; the event; one slot read after the previous hook); counting 0.69–0.71 M
(P created); none in the batch 0.24–0.26 M; completed earlier 0.10–0.12 M; expired
0.05–0.08 M.

So `call(H) ≤ 0.999 M + 1.30 M × H` with every slot created. The quests defined on a task but not
held cost nothing.

### Grim World's case (`test_component_game`)

The call has 16 task entries. The player holds 3 quests and one daily contract, all accepted and
all completing, with 0 to 2 prerequisites, checked and cached by `accept`. Every task is shared
by 2 or 3 quests in all; the others are not accepted.

| Case | Call, snforge | Slots created / overwritten | Network estimate |
|---|---|---|---|
| 3 quests per task (48), or 2 (32) | 4 522 926 | 6 / 2 | 4 439 078 |

- **Created**: the four P and the records of quests 1 and 4.
- **Overwritten**: the records of quests 2 and 3, whose unlock `accept` cached.

### Slots created and overwritten, per entrypoint

A **write** is a storage write syscall. It **creates** a slot that was zero before the
transaction, and **overwrites** a non-zero one: an update, or a rewrite of the same value. Since
fix loop 2 no entrypoint **zeroes** a slot.

| Entrypoint | Best case | Common case | Worst case |
|---|---|---|---|
| `progress`, `progress_many`, event mode | nothing written | nothing written | nothing written |
| `progress_many`, storage mode | nothing written: nothing held counts | per held quest that counts: P created on its first count in the interval, overwritten on later ones; per completion, R created on the quest's first completion, overwritten afterwards (and after a cached unlock or a claim) | 2H created (P, R of every held quest); plus the hooks' own. The held list: never written |
| `accept` | 1 overwritten: slot 0, the entry lands there and the counter changes | 1 or 2 overwritten (slot 0 for the counter, the slot of the entry); + R created when it caches an unlock of a quest the player never completed | 2 created and 1 overwritten: the list grows into a slot never used, R created by the unlock; slot 0 overwritten. The first accept of a player creates slot 0 |
| `abandon` | 1 overwritten | 1 or 2 overwritten | 2 overwritten (the later entries move up); a slot the list stops using is overwritten with its `kept` bit, never zeroed |
| `claim` | 1 overwritten (P) when `claims` is saturated at 2^64 − 1: R is rewritten unchanged | 2 overwritten (P, R) | 2 overwritten |
| `define` | 2 created (A, B) | 3 created (A, B, C) and K overwritten (the prerequisites' `live_dependents`) | 3 created, 7 overwritten |
| `retire` | 1 overwritten (A) | 1 + K overwritten | 8 overwritten |
| `set_reporter` | 1 write, nothing changed (the value is already set) | 1 created (a new reporter) | 1 created |
| Views | nothing written | nothing written | nothing written |

### Every entrypoint, measured

| Entrypoint | Case | Benchmark (baseline) | Call, snforge | Created / overwritten | Network estimate | Reads / events |
|---|---|---|---|---|---|---|
| `progress_many` | the worst, H = 4, created | `bench_progress_many_worst_held4` | 6 182 583 | 8 / 0 | 6 137 735 | 23 / 4 |
| `progress_many` | the worst, H = 4, existing | `bench_progress_many_worst_held4_existing` | 2 966 583 | 0 / 8 | 2 765 735 | 23 / 4 |
| `progress_many` | the worst, H = 8, created | `bench_progress_many_worst_held8` | 11 374 333 | 16 / 0 | 11 284 637 | 44 / 8 |
| `progress_many` | the worst, H = 8, existing | `bench_progress_many_worst_held8_existing` | 4 942 333 | 0 / 16 | 4 540 637 | 44 / 8 |
| `progress_many` | §5.1 witness adapted: 16 distinct tasks, 4 held completing, 28 quests per task not held | `quest_batch_bound_accepted` | 5 600 366 | 8 / 0 | 5 555 518 | 23 / 4 |
| `progress_many` | 4 held, all completing, 4 entries | `bench_progress_full_list_all_complete` (`baseline_full_list`) | 5 160 154 | 8 / 0 | 5 115 306 | 23 / 4 |
| `progress` | 4 held, one completes | `bench_progress_full_list_one_completes` (`baseline_full_list`) | 2 086 016 | 2 / 0 | 2 074 804 | 20 / 1 |
| `progress` | 4 held, one counts | `bench_progress_full_list_one_counts` (`baseline_full_list`) | 1 389 196 | 1 / 0 | 1 383 590 | 16 / 0 |
| `progress` | 4 held, none in the batch | `bench_progress_full_list_none_counts` (`baseline_full_list`) | 928 486 | 0 / 0 | 928 486 | 16 / 0 |
| `progress` | 1 held, counts | `bench_progress_plain` (`baseline_accepted`) | 832 466 | 1 / 0 | 826 860 | 5 / 0 |
| `progress` | 1 held, completes | `bench_progress_plain_completing` (`baseline_accepted`) | 1 377 566 | 2 / 0 | 1 366 354 | 6 / 1 |
| `progress` | nothing held | `bench_progress_nothing_held` (`baseline_plain`) | 221 676 | 0 / 0 | 221 676 | 2 / 0 |
| `accept` | **the worst**: grows into a slot never used, K = 7 not cached | `bench_accept_growth` | 1 899 210 | 2 / 1 | 1 862 892 | 17 / 0 |
| `accept` | grows back into a slot used before | `bench_accept_regrow` | 690 420 | 0 / 2 | 640 208 | 8 / 0 |
| `accept` | mixed list: 2 live weekly and 2 stale daily entries, K = 7 | `bench_accept_mixed` | 1 657 340 | 1 / 2 | 1 601 522 | 20 / 0 |
| `accept` | 4 dead entries completed now, pruned, K = 7 | `bench_accept_worst_completed` | 1 733 550 | 1 / 2 | 1 677 732 | 22 / 0 |
| `accept` | 4 entries expired, pruned, K = 7 | `bench_accept_worst_expired` | 1 571 790 | 1 / 2 | 1 515 972 | 18 / 0 |
| `accept` | a player's first accept, no prerequisite | `bench_accept_plain` (`baseline_plain`) | 767 030 | 1 / 0 | 761 424 | 3 / 0 |
| `abandon` | the first of 4, the others move up | `bench_abandon_worst` (`baseline_full_list`) | 547 920 | 0 / 2 | 497 708 | 5 / 0 |
| `abandon` | the third of 3: the list stops using slot 1 | `bench_abandon_shrink` (`baseline_three_held`) | 443 860 | 0 / 1 | 418 754 | 4 / 0 |
| `abandon` | the second of 2 | `bench_abandon` (`baseline_two_held`) | 415 140 | 0 / 1 | 390 034 | 4 / 0 |
| `claim` | — | `bench_claim` (`baseline_completed`) | 364 020 | 0 / 2 | 313 808 | 2 / 1 |
| `define` | 3 tasks, 7 conditions | `bench_define_worst` | 2 590 440 | 3 / 7 | 2 397 880 | 8 / 1 |
| `retire` | 7 conditions | `bench_retire_worst` | 1 003 240 | 0 / 8 | 802 392 | 9 / 1 |
| `set_reporter` | a new reporter | `bench_set_reporter` (`baseline_deployed`) | 608 210 | 1 / 0 | 602 604 | 0 / 1 |
| `progress`, event mode | 1 entry | `bench_progress_event_mode` (`baseline_deployed`) | 213 166 | 0 / 0 | 213 166 | 1 / 1 |
| `progress_many`, event mode | 16 entries, late collision | `bench_progress_many_event_mode_late_collision` (`baseline_deployed`) | 1 832 623 | 0 / 0 | 1 832 623 | 1 / 16 |

Reads of `progress` and `progress_many` include the reporter check (1).
