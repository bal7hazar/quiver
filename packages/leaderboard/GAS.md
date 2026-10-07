# Gas of `quiver_leaderboard`

Produced by `scripts/gas.py --write`; checked by `scripts/gas.py --check`. Measured is the
L2 gas snforge reports for the test; the budget is its `#[available_gas(l2_gas: N)]`,
set at `ceil(1.05 x measured)` and never above it; a budget kept tighter, between the
measure and that ceiling, also passes (docs/CAIRO.md §2).

| Test | Measured (l2_gas) | Budget (l2_gas) | Date | Commit |
|---|---|---|---|---|
| `quiver_leaderboard::bench::tests::baseline_after_10` | 5565870 | 5844164 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_after_100` | 44142570 | 46349699 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_after_1000` | 429909570 | 451405049 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_first_rank1_on_two` | 1611440 | 1692012 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_first_second` | 1010740 | 1061277 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_first_submission` | 6010 | 6311 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::baseline_first_third` | 1611440 | 1692012 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_first_rank1_on_two` | 2441120 | 2563176 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_first_second` | 1612940 | 1693587 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_first_submission` | 1011040 | 1061592 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_first_third` | 2211190 | 2321750 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_empty_after_10` | 5610400 | 5890920 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_empty_after_100` | 44187100 | 46396455 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_empty_after_1000` | 429954100 | 451451805 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_full_after_10` | 5649320 | 5931786 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_full_after_100` | 44226020 | 46437321 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_ranked_full_after_1000` | 429993020 | 451492671 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_below_after_10` | 5613790 | 5894480 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_below_after_100` | 44190490 | 46400015 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_below_after_1000` | 429957490 | 451455365 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_equal_third_after_10` | 5613790 | 5894480 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_equal_third_after_100` | 44190490 | 46400015 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_not_placed_equal_third_after_1000` | 429957490 | 451455365 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_player_zero_after_10` | 5565870 | 5844164 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_player_zero_after_100` | 44142570 | 46349699 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_player_zero_after_1000` | 429909570 | 451405049 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank1_after_10` | 5993290 | 6292955 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank1_after_100` | 44569990 | 46798490 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank1_after_1000` | 430336990 | 451853840 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank2_after_10` | 5879410 | 6173381 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank2_after_100` | 44456110 | 46678916 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank2_after_1000` | 430223110 | 451734266 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank3_after_10` | 5763920 | 6052116 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank3_after_100` | 44340620 | 46557651 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_rank3_after_1000` | 430107620 | 451613001 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_score_zero_after_10` | 5565870 | 5844164 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_score_zero_after_100` | 44142570 | 46349699 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_submit_score_zero_after_1000` | 429909570 | 451405049 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_top_after_10` | 5729780 | 6016269 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_top_after_100` | 44306480 | 46521804 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::bench::tests::bench_top_after_1000` | 430073480 | 451577154 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::a_player_holds_all_three_ranks` | 2903070 | 3048224 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::a_score_below_the_third_is_not_placed` | 2657470 | 2790344 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::a_score_equal_to_the_third_is_not_placed` | 2657470 | 2790344 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::a_tie_with_the_first_goes_below_it` | 2921890 | 3067985 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::a_tie_with_the_second_goes_below_it` | 2806400 | 2946720 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::empty_board_reads_empty` | 101750 | 106838 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::first_submission_takes_rank_one` | 1100770 | 1155809 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::game_id_and_time_are_data_only` | 1740530 | 1827557 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::player_zero_never_ranks` | 2659260 | 2792223 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::property_sequences_match_the_reference` | 616904980 | 647750229 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::rank_one_shifts_two_down_and_drops_the_third` | 3035770 | 3187559 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::rank_three_replaces_the_third` | 2806400 | 2946720 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::rank_two_shifts_one_down` | 2921890 | 3067985 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::ranked_of_an_empty_rank_is_empty` | 1146350 | 1203668 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::ranked_outside_one_to_three_is_empty` | 2442740 | 2564877 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::ranked_reads_each_rank` | 2695310 | 2830076 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::ranks_fill_in_order_of_score` | 2378120 | 2497026 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::reads_work_on_a_snapshot_state` | 2693420 | 2828091 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::score_zero_never_ranks` | 2659260 | 2792223 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::the_largest_score_and_player_are_kept` | 1740530 | 1827557 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::ties_on_a_board_of_equal_scores_keep_the_earlier_call_above` | 2425940 | 2547237 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::leaderboard::tests::tournament_ids_zero_and_largest_are_valid_and_isolated` | 4379390 | 4598360 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::at_reads_a_rank_and_zero_outside` | 6010 | 6311 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::packing_empty_slot_unpacks_to_zero_scores` | 14050 | 14753 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::packing_ranks_sit_at_their_bits` | 6010 | 6311 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::packing_round_trips` | 68370 | 71789 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::place_shifts_the_lower_ranks_down` | 6010 | 6311 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard::models::scores::tests::rank_of_a_score` | 6010 | 6311 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::a_placing_submit_changes_only_the_slots_it_moves` | 4307380 | 4522749 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::a_submit_that_does_not_place_leaves_the_storage_unchanged` | 4518780 | 4744719 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::slots_one_and_two_are_written_only_when_they_change` | 6718240 | 7054152 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::no_event_after_any_kind_of_submit` | 4468710 | 4692146 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::the_block_timestamp_changes_nothing` | 4554650 | 4782383 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::the_calls_go_through_a_consumers_storage_path` | 2392640 | 2512272 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::the_gas_of_a_placing_submit_falls_with_the_rank` | 10293080 | 10807734 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::the_slots_hold_the_ranks` | 3525210 | 3701471 | 2026-10-07 | 1788d97 |
| `quiver_leaderboard_integrationtest::test_contract::tournaments_are_isolated` | 7045430 | 7397702 | 2026-10-07 | 1788d97 |

## `quiver_leaderboard` 0.1.0 (ARC-05a)

Measured on Linux, Scarb 2.20.1, snforge 0.64.0, `RAYON_NUM_THREADS=1`, L2 gas. The tests in the
table above are the data; this section is their reading. Every benchmark
(`src/bench.cairo`) has a baseline that builds the same board without the call: **the operation's cost
is the benchmark minus its baseline**. The call is internal to a contract (no dispatcher), which is
what a consumer pays. The prior submissions are real: `n` submissions of rising scores, each taking
rank 1 with two ranks shifted. One `assert` per benchmark (a few hundred gas) is in the figure.

The **network estimate** reprices the slots written at the network's price (BUDGETS: −20 606 per
created slot, −40 106 per overwritten one); reads are unchanged.

| Operation | After 10 | After 100 | After 1 000 | Paved's ceiling | Network estimate | Against 20 M cap |
|---|---|---|---|---|---|---|
| `submit` rank 1, two shifted (worst; 4 overwritten) | 427 420 | 427 420 | 427 420 | 1 300 000 | 266 996 | 2.1 % |
| `submit` rank 2 (3 overwritten) | 313 540 | 313 540 | 313 540 | 1 300 000 | 193 222 | 1.6 % |
| `submit` rank 3 (2 overwritten) | 198 050 | 198 050 | 198 050 | 1 300 000 | 117 838 | 1.0 % |
| `submit` not placed, below rank 3 | 47 920 | 47 920 | 47 920 | 600 000 | 47 920 | 0.2 % |
| `submit` not placed, equal to rank 3 | 47 920 | 47 920 | 47 920 | 600 000 | 47 920 | 0.2 % |
| `submit` score 0 | 0 | 0 | 0 | 600 000 | 0 | 0 % |
| `submit` player 0 | 0 | 0 | 0 | 600 000 | 0 | 0 % |
| `top`, full board | 163 910 | 163 910 | 163 910 | 600 000 | 163 910 | 0.8 % |
| `ranked`, full rank | 83 450 | 83 450 | 83 450 | 300 000 | 83 450 | 0.4 % |
| `ranked`, empty rank | 44 530 | 44 530 | 44 530 | 300 000 | 44 530 | 0.2 % |

Score 0 and player 0 return before any read: their call costs less than the baseline's noise (0).

**The first submissions of a tournament** create slots (a created slot costs 474 106 in snforge,
72 106 overwritten) and do not depend on prior submissions:

| Submission | Call | Slots written | Network estimate | Paved's ceiling |
|---|---|---|---|---|
| 1st (rank 1 on an empty board) | 1 005 030 | word and player 1, created | 963 818 | 1 300 000 |
| 2nd (rank 2) | 602 200 | word overwritten, player 2 created | 541 488 | 1 300 000 |
| 3rd (rank 3) | 599 750 | word overwritten, player 3 created | 539 038 | 1 300 000 |
| rank 1 on a board of two | 829 680 | word, players 1 and 2 overwritten, player 3 created | 688 756 | 1 300 000 |

**Every ceiling is met**, the largest figure being the first submission of a tournament (1 005 030
against 1 300 000, its two created slots being 948 212 of it). None depends on the number of
submissions: the figures are identical at 10, 100 and 1 000.

**Unchanged slots** (`tests/test_contract.cairo`): player slots 1 and 2 are written only when their
value changes; slot 3 is written on every placement that reaches it, even with the same value, since
it is not read (a read would cost about 38 920 on every placing submit; the rewrite costs one
overwrite, about 72 106, and no state diff on the network). A rank-1 submit by the player already
holding ranks 1 and 2 therefore writes two slots fewer (1 and 2) than the same submit over distinct
players; the gas of a placing submit falls with the rank (3, 2 or 1 player slots moved).

**Memory** (capped, `prlimit --as=8589934592 -- /usr/bin/time -v`): first full `snforge test`
1 022 620 kB maximum resident set size; the 1 000-submission benchmark alone 876 584 kB.
