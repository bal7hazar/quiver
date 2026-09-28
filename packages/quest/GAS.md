# Gas of `quiver_quest`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_quest_integrationtest::test_batch::batch_count_of_present_and_absent` | 47260 | 49623 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_at_the_bound` | 152110 | 159716 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_first_position_is_the_smallest_position` | 36930 | 38777 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_drops_zero_counts` | 83525 | 87702 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_empty` | 20710 | 21746 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_ids_equal_modulo_128_are_distinct` | 183358 | 192526 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_distinct_entries_in_order` | 53738 | 56425 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_keeps_the_position_of_first_occurrence` | 92375 | 96994 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_matches_the_plain_merge` | 8504394 | 8929614 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::batch_merge_saturates_duplicates` | 271214 | 284775 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_above_bound_reverts` | 74260 | 77973 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_bound_accepted` | 225086 | 236341 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicate_entries_merged` | 55829 | 58621 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_duplicates_count_toward_bound` | 65140 | 68397 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_event_mode_one_event_per_task_merge` | 85409 | 89680 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_first_position_uses_zero_sentinel` | 31320 | 32886 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero` | 31036 | 32588 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_rejects_task_zero_with_zero_count` | 38452 | 40375 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_batch::quest_batch_zero_counts_count_toward_bound` | 74260 | 77973 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_empty` | 14120 | 14826 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_fifteen_then_one` | 52410 | 55031 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_distinct` | 62900 | 66045 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_baseline_sixteen_with_duplicates` | 75500 | 79275 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_count_of_absent` | 90590 | 95120 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_first_position_absent` | 110490 | 116015 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 749113 | 786569 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 753023 | 790675 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 181896 | 190991 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_batch_merge_sixteen_with_duplicates` | 545921 | 573218 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_claim` | 18340 | 19257 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_conditions_span_seven` | 19540 | 20517 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_definition_new_three_tasks_seven_conditions` | 151360 | 158928 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_conditions` | 35520 | 37296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_definition` | 43450 | 45623 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_page` | 37630 | 39512 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_progress` | 29130 | 30587 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_record` | 29020 | 30471 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_pack_unpack_tasks` | 31390 | 32960 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_page_pop_full` | 24910 | 26156 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_page_position_absent` | 25830 | 27122 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_page_push_seventh` | 21680 | 22764 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_page_set_last` | 21680 | 22764 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_page_span_full` | 19340 | 20307 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_prerequisites_met_seven` | 31400 | 32970 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_progress_add_three_tasks_sixteen_entries` | 156430 | 164252 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_progress_is_complete_three_tasks` | 21680 | 22764 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_record_abandon` | 17140 | 17997 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_record_accept` | 17040 | 17892 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_record_complete` | 16640 | 17472 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_record_is_accepted` | 17140 | 17997 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_interval_id` | 20130 | 21137 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_is_active` | 19230 | 20192 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_schedule_validate` | 17480 | 18354 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_index_of_absent` | 20850 | 21893 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_bench::bench_tasks_span_three` | 20050 | 21053 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_expired_reverts` | 5877080 | 6170934 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_keeps_counts` | 9208248 | 9668661 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_abandon_refusals` | 6872920 | 7216566 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_completion_reverts` | 10339396 | 10856366 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_after_daily_completion` | 11113946 | 11669644 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_caches_unlock` | 14121752 | 14827840 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_refusals` | 9917810 | 10413701 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_required` | 7471532 | 7845109 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_accept_twice_same_interval_reverts` | 5806530 | 6096857 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_acceptance_expires_at_rollover` | 9393598 | 9863278 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_completion_releases_acceptance` | 10224886 | 10736131 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_accept::quest_is_accepted_false_outside_schedule` | 5991790 | 6291380 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_abandon_requires_player_authorization` | 5926210 | 6222521 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_accept_requires_player_authorization` | 5110260 | 5365773 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_claim_requires_player_authorization` | 14576286 | 15305101 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_consumer_calls_the_internal_layer` | 5962536 | 6260663 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_define_admin_only` | 2987810 | 3137201 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_internal_layer_not_reachable_from_abi` | 2021290 | 2122355 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_player_authorization_is_per_player` | 4910330 | 5155847 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_accepts_registered_reporter` | 7011632 | 7362214 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_many_rejects_unregistered_caller` | 2847530 | 2989907 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_progress_rejects_unregistered_caller` | 5316730 | 5582567 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_reporter_revoked` | 4854300 | 5097015 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_retire_admin_only` | 5611150 | 5891708 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_admin_only` | 2970450 | 3118973 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_access::quest_set_reporter_event_keys` | 2940840 | 3087882 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_accepted` | 27109912 | 28465408 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_batch_bound_accepted` | 1291105702 | 1355660988 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_completed` | 3936036 | 4132838 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_define_worst` | 140916452 | 147962275 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_deployed` | 790500 | 830025 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_plain` | 2532310 | 2658926 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_prerequisites` | 26055202 | 27357963 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_late_collision` | 1291088562 | 1355642991 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_many_late_duplicate` | 1211789592 | 1272379072 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_progress_worst` | 101321042 | 106387095 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::baseline_retire_worst` | 144323012 | 151539163 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_abandon` | 27378872 | 28747816 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_accept_worst` | 27109912 | 28465408 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_claim` | 4305336 | 4520603 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_define_worst` | 144324932 | 151541179 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_accepted` | 28026018 | 29427319 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_event_mode` | 1001736 | 1051823 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_collision` | 2625213 | 2756474 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_late_duplicate` | 2567393 | 2695763 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_event_mode_worst` | 2053886 | 2156581 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_late_collision` | 1974255845 | 2072968638 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_many_worst_late_duplicate` | 1852316665 | 1944932499 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain` | 3387696 | 3557081 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_plain_completing` | 3936036 | 4132838 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_progress_worst` | 144130218 | 151336729 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_retire_worst` | 146468792 | 153792232 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_set_reporter` | 1398910 | 1468856 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_current_interval` | 26217812 | 27528703 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_definition_worst` | 26363282 | 27681447 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_accepted` | 26256152 | 27568960 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_reporter` | 26179892 | 27488887 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_is_unlocked_worst` | 26578052 | 27906955 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::bench_view_progress_and_record` | 26350462 | 27667986 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_bench::quest_batch_bound_accepted` | 1973846068 | 2072538372 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_emits_and_writes` | 12742436 | 13379558 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_after_state_written` | 12730276 | 13366790 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_hook_panic_reverts_claim` | 11030536 | 11582063 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_index_counts_claims` | 21605042 | 22685295 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_twice_reverts` | 13000326 | 13650343 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_claim_uncompleted_reverts` | 6567176 | 6895535 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_after_state_written` | 9672586 | 10156216 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_claim::quest_complete_hook_panic_reverts_progress` | 8033396 | 8435066 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_counts_dependents` | 9640250 | 10122263 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_association_overflow` | 50352270 | 52869884 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_duplicate_condition` | 4927780 | 5174169 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_invalid_input` | 3921080 | 4117134 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_retired_condition` | 5168000 | 5426400 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_self_condition` | 2995740 | 3145527 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_too_many_conditions` | 15999160 | 16799118 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_rejects_undefined_condition` | 3049990 | 3202490 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_stores_and_emits` | 8062170 | 8465279 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_define_twice_reverts` | 4911680 | 5157264 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_define::quest_empty_slot_reads_undefined` | 2745300 | 2882565 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_reaches_max_dependents` | 9544160 | 10021368 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_dependents::quest_define_rejects_too_many_dependents` | 10700260 | 11235273 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_dependents::quest_retire_dependent_frees_max_dependents` | 12997420 | 13647291 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_batch_event_mode_one_event_per_task` | 5237059 | 5498912 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_calls_no_hook` | 4944936 | 5192183 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_cannot_be_claimed` | 5434686 | 5706421 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_emits_only_progressed` | 5179696 | 5438681 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_event_mode_zero_count_emits_nothing` | 3165198 | 3323458 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_event_mode::quest_modes_do_not_mix` | 5957262 | 6255126 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_events::quest_accept_and_abandon_emit_nothing` | 5386190 | 5655500 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_events::quest_current_interval_view` | 5525770 | 5802059 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_events::quest_events_keys_and_data` | 16074402 | 16878123 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_three_per_task` | 88639842 | 93071835 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_game::baseline_game_case_two_per_task` | 63718162 | 66904071 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_game::game_case_three_per_task` | 98784008 | 103723209 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_game::game_case_two_per_task` | 71733208 | 75319869 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n1_k0` | 21503220 | 22578381 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n1_k1` | 35154640 | 36912372 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n1_k3` | 48806720 | 51247056 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n1_k7` | 76118240 | 79924152 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n28_k0` | 408769060 | 429207513 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n28_k7` | 1938232080 | 2035143684 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n2_k0` | 35067780 | 36821169 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n2_k1` | 62372160 | 65490768 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n2_k3` | 89678800 | 94162740 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n2_k7` | 144306800 | 151522140 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n4_k0` | 62204260 | 65314473 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n4_k1` | 116814560 | 122655288 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n4_k3` | 171430320 | 180001836 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n4_k7` | 280691280 | 294725844 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n7_k0` | 102908980 | 108054429 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n7_k1` | 198478160 | 208402068 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n7_k3` | 294057600 | 308760480 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e16_n7_k7` | 485268000 | 509531400 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n1_k0` | 2089400 | 2193870 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n1_k1` | 2941170 | 3088229 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n1_k3` | 3792100 | 3981705 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n1_k7` | 5494420 | 5769141 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n28_k0` | 26267190 | 27580550 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n28_k7` | 121850210 | 127942721 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n2_k0` | 2936210 | 3083021 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n2_k1` | 4641290 | 4873355 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n2_k3` | 6345630 | 6662912 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n2_k7` | 9755230 | 10242992 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n4_k0` | 4630290 | 4861805 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n4_k1` | 8041990 | 8444090 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n4_k3` | 11453150 | 12025808 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n4_k7` | 18277310 | 19191176 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n7_k0` | 7171410 | 7529981 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n7_k1` | 13143040 | 13800192 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n7_k3` | 19114430 | 20070152 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e1_n7_k7` | 31060430 | 32613452 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n1_k0` | 5971980 | 6270579 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n1_k1` | 9383680 | 9852864 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n1_k3` | 12794840 | 13434582 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n1_k7` | 19619000 | 20599950 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n2_k0` | 9362340 | 9830457 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n2_k1` | 16187280 | 16996644 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n2_k3` | 23012080 | 24162684 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n2_k7` | 36665360 | 38498628 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n4_k0` | 16144900 | 16952145 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n4_k1` | 29796320 | 31286136 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n4_k3` | 43448400 | 45620820 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n4_k7` | 70759920 | 74297916 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n7_k0` | 26318740 | 27634677 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n7_k1` | 50209880 | 52720374 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n7_k3` | 74102880 | 77808024 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_e4_n7_k7` | 121901760 | 127996848 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_event_e1` | 794330 | 834047 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_event_e16` | 837750 | 879638 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::baseline_grid_event_e4` | 802830 | 842972 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n1_k0` | 41566016 | 43644317 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n1_k1` | 56695996 | 59530796 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n1_k3` | 71684076 | 75268280 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n1_k7` | 101658156 | 106741064 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n28_k0` | 937958096 | 984856001 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n28_k7` | 2620780476 | 2751819500 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n2_k0` | 73879696 | 77573681 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n2_k1` | 104141196 | 109348256 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n2_k3` | 134119836 | 140825828 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n2_k7` | 194072956 | 203776604 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n4_k0` | 138523536 | 145449713 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n4_k1` | 199048076 | 209000480 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n4_k3` | 259007836 | 271958228 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n4_k7` | 378919036 | 397864988 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n7_k0` | 236417056 | 248237909 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n7_k1` | 342336156 | 359452964 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n7_k3` | 447267596 | 469630976 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e16_n7_k7` | 657115916 | 689971712 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n1_k0` | 3501406 | 3676477 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n1_k1` | 4445586 | 4667866 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n1_k3` | 5380016 | 5649017 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n1_k7` | 7248746 | 7611184 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n28_k0` | 59499586 | 62474566 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n28_k7` | 164667566 | 172900945 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n2_k0` | 5520036 | 5796038 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n2_k1` | 7409936 | 7780433 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n2_k3` | 9281276 | 9745340 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n2_k7` | 13023696 | 13674881 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n4_k0` | 9558326 | 10036243 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n4_k1` | 13339666 | 14006650 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n4_k3` | 17084826 | 17939068 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n4_k7` | 24574626 | 25803358 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n7_k0` | 15673746 | 16457434 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n7_k1` | 22292246 | 23406859 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n7_k3` | 28848136 | 30290543 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e1_n7_k7` | 41959006 | 44056957 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n1_k0` | 11114144 | 11669852 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n1_k1` | 14895484 | 15640259 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n1_k3` | 18640644 | 19572677 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n1_k7` | 26130444 | 27436967 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n2_k0` | 19191784 | 20151374 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n2_k1` | 26756004 | 28093805 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n2_k3` | 34248804 | 35961245 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n2_k7` | 49233364 | 51695033 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n4_k0` | 35351184 | 37118744 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n4_k1` | 50481164 | 53005223 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n4_k3` | 65469244 | 68742707 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n4_k7` | 95443324 | 100215491 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n7_k0` | 59822224 | 62813336 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n7_k1` | 86300844 | 90615887 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n7_k3` | 112531844 | 118158437 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_e4_n7_k7` | 164990204 | 173239715 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_event_e1` | 1015276 | 1066040 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_event_e16` | 2053886 | 2156581 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_event_e16_on_n7_k7` | 486482706 | 510806842 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_grid::grid_event_e4` | 1222814 | 1283955 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e12_n1_k7` | 57273610 | 60137291 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e15_n1_k0` | 20194580 | 21204309 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e16_n1_k0` | 21487910 | 22562306 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e2_n7_k4` | 43415850 | 45586643 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e3_n5_k2` | 34042450 | 35744573 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e4_n3_k7` | 53708610 | 56394041 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e4_n4_k0` | 16140870 | 16947914 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e5_n3_k1` | 28536960 | 29963808 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e7_n2_k3` | 39671910 | 41655506 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::baseline_option_e8_n2_k0` | 17923030 | 18819182 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e12_n1_k7` | 76815759 | 80656547 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e15_n1_k0` | 39530797 | 41507337 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e16_n1_k0` | 42132323 | 44238940 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e2_n7_k4` | 63316699 | 66482534 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e3_n5_k2` | 54053565 | 56756244 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e4_n3_k7` | 72387311 | 76006677 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e4_n4_k0` | 35400531 | 37170558 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e5_n3_k1` | 48104417 | 50509638 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e7_n2_k3` | 59344119 | 62311325 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_options::option_e8_n2_k0` | 37582275 | 39461389 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_dependent_unlocks_when_window_opens` | 14310728 | 15026265 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_inactive_dependent_does_not_revert` | 12383136 | 13002293 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_is_unlocked_evaluates_uncached` | 12211336 | 12821903 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisite_completed_before_definition` | 13539862 | 14216856 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_all_required` | 15304322 | 16069539 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_prerequisites_unlock_after_last` | 20546088 | 21573393 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_dependent_stays_unlocked` | 21897248 | 22992111 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_after_dependent_completed` | 21414358 | 22485076 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completed_before_definition` | 13614872 | 14295616 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_recurring_prerequisite_completes_every_interval` | 21524608 | 22600839 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_unlock_cached_by_progress` | 14581358 | 15310426 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_prerequisites::quest_without_conditions_is_unlocked` | 4582270 | 4811384 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_baseline` | 453720 | 476406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_emit_100` | 5307920 | 5573316 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_read_100` | 3474220 | 3647931 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_definition_100` | 2514990 | 2640740 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_record_100` | 1517190 | 1593050 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_unpack_tasks_100` | 1716190 | 1802000 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_100` | 46363620 | 48681801 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_change_100` | 52345030 | 54962282 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_then_overwrite_100` | 52345030 | 54962282 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_probe::probe_write_twice_in_one_call_baseline` | 46635130 | 48966887 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest` | 5249830 | 5512322 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::baseline_batch_two_tasks_one_quest_not_completing` | 5124590 | 5380820 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_above_bound_reverts` | 3236520 | 3398346 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicate_entries_merged` | 5629349 | 5910817 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_duplicates_count_toward_bound` | 2974800 | 3123540 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_quest_on_two_entries_handled_once` | 8562322 | 8990439 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_rejects_task_zero` | 3030582 | 3182112 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write` | 10336542 | 10853370 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_batch_two_tasks_one_quest_one_write_not_completing` | 6274852 | 6588595 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_max_value` | 10123252 | 10629415 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_count_saturates_at_total` | 10213112 | 10723768 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_interval_aligned_on_utc_midnight` | 7227682 | 7589067 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_daily_rollover_starts_from_zero` | 7050832 | 7403374 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_inactive_quest_skipped_not_reverted` | 7420766 | 7791805 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_interval_id_is_u64` | 5831946 | 6123544 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_one_off_completes_once` | 10098952 | 10603900 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_progress_is_per_player` | 5742726 | 6029863 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_recurring_completes_each_interval` | 20179534 | 21188511 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_progress::quest_task_shared_by_max_quests` | 168914536 | 177360263 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_after_completion_refused` | 7793526 | 8183203 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_accept_other_quest_leaves_outer_unchanged` | 55636314 | 58418130 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_other_quest_leaves_outer_unchanged` | 58265404 | 61178675 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_claim_same_quest_refused` | 11442046 | 12014149 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_later_quest_completes_once` | 17343742 | 18210930 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_other_quest_leaves_outer_unchanged` | 59679100 | 62663055 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_progress_same_quest_completes_once` | 10832082 | 11373687 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_reentrant_retire_other_quest_leaves_outer_unchanged` | 55001484 | 57751559 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_reentry::quest_retired_by_hook_not_progressed` | 13229536 | 13891013 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_redefine_retired_reverts` | 5110540 | 5366067 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_abandon_before_is_kept` | 5722820 | 6008961 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_dependent_then_prerequisite` | 7930330 | 8326847 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_frees_slot` | 51550730 | 54128267 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_keeps_pages_contiguous` | 58104140 | 61009347 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_last_quest_empties_page` | 4986780 | 5236119 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_prerequisite_with_live_dependent_reverts` | 7601270 | 7981334 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retire_twice_reverts` | 5388010 | 5657411 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_accept_reverts` | 5120780 | 5376819 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_completed_still_claimable` | 12715966 | 13351765 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_definition_readable` | 4871670 | 5115254 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_is_not_accepted` | 6228240 | 6539652 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_component_retire::quest_retired_not_progressed` | 7864156 | 8257364 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::conditions_span_has_count_entries` | 104530 | 109757 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::definition_new_one_task` | 27110 | 28466 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::definition_new_round_trips_through_the_spans` | 70830 | 74372 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::definition_new_three_tasks_seven_conditions` | 160730 | 168767 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::definition_new_unused_slots_are_zero` | 37590 | 39470 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_condition_zero` | 27060 | 28413 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition` | 33030 | 34682 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duplicate_condition_far_apart` | 125580 | 131859 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_half_recurring` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_id` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_invalid_window` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_more_than_three_tasks` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_no_task` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task` | 20530 | 21557 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_first_and_last` | 21530 | 22607 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_repeated_task_second_and_last` | 20320 | 21336 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_self_condition` | 21590 | 22670 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_task_zero` | 19120 | 20076 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_too_many_conditions` | 18630 | 19562 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::quest_define_rejects_total_zero` | 20120 | 21126 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::tasks_index_of_finds_used_slots_only` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43210 | 45371 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_errors::quest_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_empty_slot_reads_undefined` | 37980 | 39879 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_accepts_the_bounds` | 4680920 | 4914966 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_presence_bits_at_their_positions` | 1138250 | 1195163 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_16` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_condition_count_8` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_page_len_255` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_page_len_8` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_255` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_rejects_task_count_4` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_conditions` | 19268540 | 20231967 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_max` | 27686180 | 29070489 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_mixed` | 7560970 | 7939019 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_definition_zero` | 2530360 | 2656878 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_page` | 12922480 | 13568604 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_progress` | 11909220 | 12504681 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_record` | 12947340 | 13594707 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_packing_round_trip_tasks` | 15134650 | 15891383 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_progress_reads_bit_97_alone` | 689570 | 724049 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_conditions_bit_224` | 377150 | 396008 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_bit_216` | 396190 | 416000 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_definition_felt_minus_one` | 33560 | 35238 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_page_bit_230` | 407250 | 427613 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_page_len_8` | 409000 | 429450 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_128` | 343080 | 360234 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_progress_bit_98` | 356080 | 373884 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_record_bit_194` | 372130 | 390737 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_packing::quest_unpacking_rejects_tasks_bit_192` | 359240 | 377202 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_pop_empty_panics` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_pop_removes_the_last_id` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_position_among_len_ids` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_push_appends_until_full` | 87110 | 91466 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_push_full_panics` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_set_beyond_len_panics` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_set_replaces_one_id` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::page_span_has_len_entries` | 31900 | 33495 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::pages_removal_keeps_pages_contiguous` | 810930 | 851477 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::pages_removal_of_the_only_id` | 172240 | 180852 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_pages::quest_retire_frees_slot_pages` | 566680 | 595014 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_add_ignores_other_tasks` | 46840 | 49182 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_add_keeps_claimed` | 16790 | 17630 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_add_matches_the_plain_formula` | 9379140 | 9848097 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_add_three_tasks_partial_then_complete` | 63440 | 66612 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_add_touches_only_task_count_slots` | 24310 | 25526 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::progress_is_complete_per_task_count` | 15940 | 16737 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_batch_duplicate_entries_merged_progress` | 58829 | 61771 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_batch_two_tasks_one_quest_one_write_logic` | 50012 | 52513 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value` | 34610 | 36341 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_count_max_value_below_total` | 22160 | 23268 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_count_saturates_at_total` | 45750 | 48038 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_progress::quest_one_off_completes_once` | 31000 | 32550 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::claim_marks_claimed_and_counts` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::prerequisites_met_when_each_completed_once` | 40180 | 42189 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_abandon_expired_reverts` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_accept_twice_same_interval_reverts` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_acceptance_expires_at_rollover_logic` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_claim_index_counts_claims` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_claim_twice_reverts` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_claim_uncompleted_reverts_before_claimed` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_completion_releases_acceptance` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_prerequisites_all_required_logic` | 28420 | 29841 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_past_u32` | 27900 | 29295 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_record_counters_saturate` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::quest_recurring_completes_each_interval_logic` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::record_abandon_clears_active` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::record_abandon_not_accepted_reverts` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::record_accept_sets_active_and_interval` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::record_complete_keeps_unlocked_and_claims` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_record::record_is_accepted_in_its_interval_only` | 15940 | 16737 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::quest_daily_interval_aligned_on_utc_midnight` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::quest_interval_id_is_u64` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_never_panics_at_the_bounds` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_none_when_inactive` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_one_off_is_zero` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_interval_id_recurring` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_duration_equal_to_interval_is_always_active` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_never_ends_when_end_is_zero` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_one_off_window` | 15940 | 16737 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_is_active_recurring` | 16240 | 17052 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_accepts_valid_schedules` | 13720 | 14406 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_duration_above_interval_at_max` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_empty_window` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_end_before_start` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_duration_only` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |
| `quiver_quest_integrationtest::test_schedule::schedule_validate_rejects_half_recurring_interval_only` | 15520 | 16296 | 2026-09-28 | 49fbdb9 |

## Cost model of `progress_many` (ARC-03b, fix loop 2)

Written by hand below the generated table: `scripts/gas.py --write` rewrites this file and drops
this section, `--check` reads only the rows above. Figures are L2 gas as snforge 0.61 reports it,
from the full run of this commit; reads, writes and events from `snforge test
--detailed-resources`. A call's cost is its test minus its baseline (the same fixture without the
call), through a dispatcher, with hooks that do nothing (`MockBench`).

### Unit costs (`test_component_probe`, 100 operations per test)

| Operation | L2 gas | of which Sierra gas |
|---|---|---|
| Storage read, `Map` with a tuple key | 30 205 | 30 205 |
| Storage write to a slot whose value changes in the transaction | 459 099 | 57 099 |
| Storage write of a slot already changed in the transaction, or unchanged | 57 099 | 57 099 |
| Event of 3 keys and 1 data felt (`QuestCompleted`'s shape) | 48 542 | 12 742 |
| Unpack `QuestDefinition` / `QuestTasks` / `QuestRecord` | 20 613 / 12 625 / 10 635 | same |

A slot changed by the transaction costs about 402 000 L2 gas beyond the write's computation, once
per slot per transaction. A quest completed by `progress_many` changes two slots (its progress
P and its record R): about 918 000 L2 gas of the 1.17 M it costs. The rest is 4 to 5 reads, the
`QuestCompleted` event and about 0.14 M of computation.

### The grid: storage mode, every quest completing (`test_component_grid`)

E tasks per call (entries 1..=E, distinct), N live quests per task (one task each, target 1, no
accept step), K prerequisites per quest, completed earlier and first observed by this call (no
two quests share one). Fixtures are seeded in storage, past the caps where needed; N = 28 are the
corners of the bounds of A-G1.

| E | N | K | Quests | Call L2 gas | Sierra gas | Reads | Writes | Events | L2 gas per quest |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 1 412 006 | 573 496 | 6 | 2 | 1 | 1 412 006 |
| 1 | 1 | 1 | 1 | 1 504 416 | 665 906 | 8 | 2 | 1 | 1 504 416 |
| 1 | 1 | 3 | 1 | 1 587 916 | 749 406 | 10 | 2 | 1 | 1 587 916 |
| 1 | 1 | 7 | 1 | 1 754 326 | 915 816 | 14 | 2 | 1 | 1 754 326 |
| 1 | 2 | 0 | 2 | 2 583 826 | 905 476 | 10 | 4 | 2 | 1 291 913 |
| 1 | 2 | 1 | 2 | 2 768 646 | 1 090 296 | 14 | 4 | 2 | 1 384 323 |
| 1 | 2 | 3 | 2 | 2 935 646 | 1 257 296 | 18 | 4 | 2 | 1 467 823 |
| 1 | 2 | 7 | 2 | 3 268 466 | 1 590 116 | 26 | 4 | 2 | 1 634 233 |
| 1 | 4 | 0 | 4 | 4 928 036 | 1 570 006 | 18 | 8 | 4 | 1 232 009 |
| 1 | 4 | 1 | 4 | 5 297 676 | 1 939 646 | 26 | 8 | 4 | 1 324 419 |
| 1 | 4 | 3 | 4 | 5 631 676 | 2 273 646 | 34 | 8 | 4 | 1 407 919 |
| 1 | 4 | 7 | 4 | 6 297 316 | 2 939 286 | 50 | 8 | 4 | 1 574 329 |
| 1 | 7 | 0 | 7 | 8 502 336 | 2 624 786 | 31 | 14 | 7 | 1 214 619 |
| 1 | 7 | 1 | 7 | 9 149 206 | 3 271 656 | 45 | 14 | 7 | 1 307 029 |
| 1 | 7 | 3 | 7 | 9 733 706 | 3 856 156 | 59 | 14 | 7 | 1 390 529 |
| 1 | 7 | 7 | 7 | 10 898 576 | 5 021 026 | 87 | 14 | 7 | 1 556 939 |
| 1 | 28 | 0 | 28 | 33 232 396 | 9 718 206 | 117 | 56 | 28 | 1 186 871 |
| 1 | 28 | 7 | 28 | 42 817 356 | 19 303 166 | 341 | 56 | 28 | 1 529 191 |
| 4 | 1 | 0 | 4 | 5 142 164 | 1 784 134 | 21 | 8 | 4 | 1 285 541 |
| 4 | 1 | 1 | 4 | 5 511 804 | 2 153 774 | 29 | 8 | 4 | 1 377 951 |
| 4 | 1 | 3 | 4 | 5 845 804 | 2 487 774 | 37 | 8 | 4 | 1 461 451 |
| 4 | 1 | 7 | 4 | 6 511 444 | 3 153 414 | 53 | 8 | 4 | 1 627 861 |
| 4 | 2 | 0 | 8 | 9 829 444 | 3 112 054 | 37 | 16 | 8 | 1 228 680 |
| 4 | 2 | 1 | 8 | 10 568 724 | 3 851 334 | 53 | 16 | 8 | 1 321 090 |
| 4 | 2 | 3 | 8 | 11 236 724 | 4 519 334 | 69 | 16 | 8 | 1 404 590 |
| 4 | 2 | 7 | 8 | 12 568 004 | 5 850 614 | 101 | 16 | 8 | 1 571 000 |
| 4 | 4 | 0 | 16 | 19 206 284 | 5 770 174 | 69 | 32 | 16 | 1 200 392 |
| 4 | 4 | 1 | 16 | 20 684 844 | 7 248 734 | 101 | 32 | 16 | 1 292 802 |
| 4 | 4 | 3 | 16 | 22 020 844 | 8 584 734 | 133 | 32 | 16 | 1 376 302 |
| 4 | 4 | 7 | 16 | 24 683 404 | 11 247 294 | 197 | 32 | 16 | 1 542 712 |
| 4 | 7 | 0 | 28 | 33 503 484 | 9 989 294 | 121 | 56 | 28 | 1 196 553 |
| 4 | 7 | 1 | 28 | 36 090 964 | 12 576 774 | 177 | 56 | 28 | 1 288 963 |
| 4 | 7 | 3 | 28 | 38 428 964 | 14 914 774 | 233 | 56 | 28 | 1 372 463 |
| 4 | 7 | 7 | 28 | 43 088 444 | 19 574 254 | 345 | 56 | 28 | 1 538 873 |
| 16 | 1 | 0 | 16 | 20 062 796 | 6 626 686 | 81 | 32 | 16 | 1 253 924 |
| 16 | 1 | 1 | 16 | 21 541 356 | 8 105 246 | 113 | 32 | 16 | 1 346 334 |
| 16 | 1 | 3 | 16 | 22 877 356 | 9 441 246 | 145 | 32 | 16 | 1 429 834 |
| 16 | 1 | 7 | 16 | 25 539 916 | 12 103 806 | 209 | 32 | 16 | 1 596 244 |
| 16 | 2 | 0 | 32 | 38 811 916 | 11 938 366 | 145 | 64 | 32 | 1 212 872 |
| 16 | 2 | 1 | 32 | 41 769 036 | 14 895 486 | 209 | 64 | 32 | 1 305 282 |
| 16 | 2 | 3 | 32 | 44 441 036 | 17 567 486 | 273 | 64 | 32 | 1 388 782 |
| 16 | 2 | 7 | 32 | 49 766 156 | 22 892 606 | 401 | 64 | 32 | 1 555 192 |
| 16 | 4 | 0 | 64 | 76 319 276 | 22 570 846 | 273 | 128 | 64 | 1 192 488 |
| 16 | 4 | 1 | 64 | 82 233 516 | 28 485 086 | 401 | 128 | 64 | 1 284 898 |
| 16 | 4 | 3 | 64 | 87 577 516 | 33 829 086 | 529 | 128 | 64 | 1 368 398 |
| 16 | 4 | 7 | 64 | 98 227 756 | 44 479 326 | 785 | 128 | 64 | 1 534 808 |
| 16 | 7 | 0 | 112 | 133 508 076 | 39 447 326 | 481 | 224 | 112 | 1 192 036 |
| 16 | 7 | 1 | 112 | 143 857 996 | 49 797 246 | 705 | 224 | 112 | 1 284 446 |
| 16 | 7 | 3 | 112 | 153 209 996 | 59 149 246 | 929 | 224 | 112 | 1 367 946 |
| 16 | 7 | 7 | 112 | 171 847 916 | 77 787 166 | 1377 | 224 | 112 | 1 534 356 |
| 16 | 28 | 0 | 448 | 529 189 036 | 152 942 046 | 1857 | 896 | 448 | 1 181 225 |
| 16 | 28 | 7 | 448 | 682 548 396 | 306 301 406 | 5441 | 896 | 448 | 1 523 545 |

### The model

Fitted by least squares on the 52 points; largest error 0.02 %:

```
call(E, N, K) = 169 946
              +    71 229 × E                     per task entry, its first page read included
              +    58 206 × E × (pages(N) − 1)    per further page, pages(N) = min(⌊N/7⌋ + 1, 4)
              + 1 172 066 × E × N                 per quest completed
              +    50 828 × E × N × [K > 0]       per quest with prerequisites: slot C read
              +    41 642 × E × N × K             per prerequisite first observed
```

A task entry with no quest costs about 71 000 (the page read). A quest reached but skipped (not
accepted, locked, outside its schedule, already completed) costs its reads only, about 100 000 to
150 000: no write.

**Event mode** (`grid_event_e*`): 220 946, 419 984 and 1 216 136 for E = 1, 4, 16, that is
about 155 000 + 66 346 × E (one `QuestProgressed` per entry). It does not depend on N or K:
1 214 706 for E = 16 on the fixture of (16, 7, 7).

**The merge.** The grid's entries are distinct ids, the fast path of `batch_merge`. The worst
entries for E (a collision modulo 128 at the last entry, which runs the plain merge) add about
0.5 M at E = 15 or 16 and less below; the options below are measured with them.

### Cap options under 20 M L2 gas (`test_component_options`)

Each option's worst case: E entries of which the last collides modulo 128, N quests per task, K
prerequisites first observed, all completing.

| E | N | K | Quests | Measured call (L2 gas) | Model, fast merge | Reads | Writes | Under 20M |
|---|---|---|---|---|---|---|---|---|
| 2 | 7 | 4 | 14 | 19 900 849 | 19 879 974 | 131 | 28 | yes |
| 3 | 5 | 2 | 15 | 20 011 115 | 19 974 986 | 109 | 30 | **no** |
| 4 | 3 | 7 | 12 | 18 678 701 | 18 626 215 | 149 | 24 | yes |
| 4 | 4 | 0 | 16 | 19 259 661 | 19 206 596 | 69 | 32 | yes |
| 5 | 3 | 1 | 15 | 19 567 457 | 19 492 811 | 96 | 30 | yes |
| 7 | 2 | 3 | 14 | 19 672 209 | 19 536 717 | 120 | 28 | yes |
| 8 | 2 | 0 | 16 | 19 659 245 | 19 491 514 | 73 | 32 | yes |
| 12 | 1 | 7 | 12 | 19 542 149 | 19 196 051 | 157 | 24 | yes |
| 15 | 1 | 0 | 15 | 19 336 217 | 18 818 053 | 76 | 30 | yes |
| 16 | 1 | 0 | 16 | 20 644 413 | 20 061 349 | 81 | 32 | **no** |

**16 entries per call do not fit under 20 M with any caps**: the smallest configuration, one quest
per task and no prerequisite, measures 20 644 413. Every option that fits completes at most 14 to
16 quests in one call.

### Grim World's case (`test_component_game`)

16 task entries; 3 held quests with an accept step and one daily contract, all accepted and all
completing; prerequisites 0 to 2, cached by `accept`; every task shared by 2 or 3 quests in all,
the others not accepted.

| Case | Call (L2 gas) | Reads | Writes | Events |
|---|---|---|---|---|
| 3 quests per task (48) | 10 144 166 | 160 | 8 | 4 |
| 2 quests per task (32) | 8 015 046 | 112 | 8 | 4 |

Reads exclude the reporter check (1 read).
