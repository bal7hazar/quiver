# Gas of `quiver_achievement`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
`N = ceil(1.05 x measured)` (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_achievement_integrationtest::test_batch::achievement_batch_merges_duplicates` | 170289 | 178804 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_count_of_first_entry_or_zero` | 26290 | 27605 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_above_bound_reverts` | 74260 | 77973 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_bound_accepted` | 228416 | 239837 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_distinct_keeps_order_and_drops_zeros` | 51568 | 54147 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_duplicates_count_toward_bound` | 62140 | 65247 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_late_duplicate` | 1756663 | 1844497 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_modulo_collision_not_merged` | 1821523 | 1912600 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_rejects_task_zero` | 38452 | 40375 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_rejects_task_zero_after_collision` | 62209 | 65320 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_saturates` | 80115 | 84121 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_batch::batch_merge_zero_sum_duplicate_dropped` | 79555 | 83533 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_baseline_sixteen_entries` | 49990 | 52490 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_batch_merge_late_duplicate` | 747613 | 784994 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_batch_merge_late_modulo_collision` | 751523 | 789100 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_batch_merge_sixteen_distinct` | 180396 | 189416 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_definition_new_three_tasks` | 20920 | 21966 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_pack_unpack_definition` | 34120 | 35826 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_bench::bench_pack_unpack_extra_tasks` | 24930 | 26177 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_consumer_calls_the_internal_layer` | 3041256 | 3193319 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_define_admin_only` | 2319980 | 2435979 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_internal_layer_not_reachable_from_abi` | 1730160 | 1816668 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_accepts_registered_reporter` | 3008982 | 3159432 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_many_rejects_unregistered_caller` | 2123860 | 2230053 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_progress_rejects_unregistered_caller` | 1962320 | 2060436 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_reporter_revoked` | 2341876 | 2458970 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_retire_admin_only` | 3097420 | 3252291 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_admin_only` | 2398750 | 2518688 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_access::achievement_set_reporter_event_fields` | 1833500 | 1925175 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::baseline_defined` | 1986810 | 2086151 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::baseline_deployed` | 789600 | 829080 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::baseline_game_defined` | 19313710 | 20279396 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::baseline_reporter_registered` | 1397010 | 1466861 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::baseline_sixteen_tasks_defined` | 58439180 | 61361139 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_one_task` | 1497240 | 1572102 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_define_worst` | 1986630 | 2085962 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_define_titles` | 19315330 | 20281097 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call` | 20143438 | 21150610 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_game_results_call_sixteen` | 20558996 | 21586946 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress` | 998836 | 1048778 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision` | 2606413 | 2736734 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_collision_with_definitions` | 60255793 | 63268583 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_late_duplicate` | 2549593 | 2677073 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_progress_many_sixteen_distinct` | 2035086 | 2136841 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_retire` | 2227570 | 2338949 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter` | 1397010 | 1466861 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_revoke` | 1201740 | 1261827 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_set_reporter_unchanged` | 1603540 | 1683717 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_definition_worst` | 2200940 | 2310987 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_bench::bench_view_is_reporter` | 914290 | 960005 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_one_task_writes_a_only` | 2587350 | 2716718 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_empty_window` | 1815730 | 1906517 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_invalid_id_and_tasks` | 2590460 | 2719983 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_rejects_no_task` | 1809910 | 1900406 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_three_tasks_writes_a_and_b` | 3026590 | 3177920 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_define_twice_reverts` | 2877550 | 3021428 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_defined_event_fields` | 2837250 | 2979113 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_empty_slot_reads_undefined` | 1594060 | 1673763 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_many_on_one_task` | 22915620 | 24061401 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_define::achievement_redefine_retired_reverts` | 3116320 | 3272136 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_above_bound_reverts` | 1865070 | 1958324 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_bound_accepted` | 3135596 | 3292376 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_duplicates_count_toward_bound` | 1853550 | 1946228 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_one_event_per_merged_task` | 1983799 | 2082989 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_batch_rejects_task_zero` | 1898532 | 1993459 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_event_mode_emits_only_progressed` | 3078566 | 3232495 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progress_writes_nothing` | 2481676 | 2605760 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_progressed_event_fields` | 1822486 | 1913611 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_retired_progress_still_emits` | 3586202 | 3765513 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_tiers_share_task_one_event` | 4497286 | 4722151 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_progress::achievement_zero_count_emits_nothing` | 2363248 | 2481411 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_one_tier_only` | 3763110 | 3951266 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_sets_retired_and_keeps_the_rest` | 3684820 | 3869061 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_twice_reverts` | 3070560 | 3224088 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_component_retire::achievement_retire_undefined_reverts` | 1777840 | 1866732 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_constants::achievement_bounds_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::achievement_define_rejects_id_zero` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_checks_id_first` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_checks_window_before_tasks` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_one_task_inline` | 22860 | 24003 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_empty_window` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_end_before_start` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_four_tasks` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_no_task` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_repeated_second_task` | 19020 | 19971 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_repeated_task` | 20920 | 21966 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_task_id_zero` | 16420 | 17241 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_rejects_total_zero` | 17520 | 18396 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::definition_new_three_tasks` | 39430 | 41402 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::tasks_span_has_task_count_entries` | 43450 | 45623 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::window_is_active_bounds` | 15640 | 16422 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_definition::window_validate_accepts_open_and_ordered_windows` | 13720 | 14406 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_errors::achievement_error_strings_are_the_accepted_ones` | 13720 | 14406 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_empty_slot_unpacks_undefined` | 31080 | 32634 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_packing_presence_bits_at_their_positions` | 700910 | 735956 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_packing_rejects_task_count_above_max` | 15520 | 16296 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_packing_round_trip_definition` | 7504240 | 7879452 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_packing_round_trip_extra_tasks` | 3616100 | 3796905 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_packing_widths` | 684780 | 719019 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_unpacking_extra_rejects_bit_128` | 341400 | 358470 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_unpacking_rejects_bit_196` | 377810 | 396701 | 2026-09-29 | 36b8a3c |
| `quiver_achievement_integrationtest::test_packing::achievement_unpacking_rejects_bit_251` | 29460 | 30933 | 2026-09-29 | 36b8a3c |

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
