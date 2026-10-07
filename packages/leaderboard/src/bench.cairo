//! Benchmarks (docs/CAIRO.md §2, ARC-05a): one per operation on its worst case, each **after 10,
//! 100 and 1,000 prior submissions** to one tournament, to show that the cost does not grow with
//! them.
//!
//! The prior submissions are real: `prime(n)` submits the scores 2, 4, .., 2n by players 1..=n,
//! each one taking rank 1 with two ranks shifted (the worst `submit`), so the board ends on (2n,
//! 2n-2, 2n-4), full. Each benchmark has a baseline, `baseline_after_n`, that primes the same board
//! and calls nothing: **the operation's cost is the benchmark minus its baseline**, in L2 gas, the
//! call being internal to the contract (no dispatcher, no entry point), which is what a consumer
//! pays. `scripts/gas.py` records both in `GAS.md`. Each benchmark checks the call's result with
//! one assertion (a few hundred gas, counted in the figure).
//!
//! The first submissions of a tournament (`bench_first_*`) are measured apart: they create the
//! slots (a created slot costs more than an overwritten one) and do not depend on prior
//! submissions.

#[cfg(test)]
mod tests {
    use crate::testing::mock::MockBoard;
    use crate::testing::mock::MockBoard::BoardTrait;
    use crate::types::submission::Submission;

    const T: u64 = 7;

    fn game(player_id: felt252, score: u32) -> Submission {
        Submission { player_id, game_id: 1, score, time: 1 }
    }

    /// `n` real submissions of rising scores: the board ends on (2n, 2n-2, 2n-4).
    fn prime(n: u32) -> MockBoard::ContractState {
        let mut state = MockBoard::contract_state_for_testing();
        let mut i: u32 = 1;
        while i <= n {
            state.submit(T, game(i.into(), 2 * i));
            i += 1;
        }
        state
    }

    #[test]
    #[available_gas(l2_gas: 5844164)]
    fn baseline_after_10() {
        let _state = prime(10);
    }

    #[test]
    #[available_gas(l2_gas: 46349699)]
    fn baseline_after_100() {
        let _state = prime(100);
    }

    #[test]
    #[available_gas(l2_gas: 451405049)]
    fn baseline_after_1000() {
        let _state = prime(1000);
    }

    #[test]
    #[available_gas(l2_gas: 6292955)]
    fn bench_submit_rank1_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA1, 2 * 10 + 1));
        assert(rank == 1, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46798490)]
    fn bench_submit_rank1_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA1, 2 * 100 + 1));
        assert(rank == 1, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451853840)]
    fn bench_submit_rank1_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA1, 2 * 1000 + 1));
        assert(rank == 1, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 6173381)]
    fn bench_submit_rank2_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA2, 2 * 10 - 1));
        assert(rank == 2, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46678916)]
    fn bench_submit_rank2_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA2, 2 * 100 - 1));
        assert(rank == 2, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451734266)]
    fn bench_submit_rank2_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA2, 2 * 1000 - 1));
        assert(rank == 2, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 6052116)]
    fn bench_submit_rank3_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA3, 2 * 10 - 3));
        assert(rank == 3, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46557651)]
    fn bench_submit_rank3_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA3, 2 * 100 - 3));
        assert(rank == 3, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451613001)]
    fn bench_submit_rank3_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA3, 2 * 1000 - 3));
        assert(rank == 3, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 5894480)]
    fn bench_submit_not_placed_below_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA4, 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46400015)]
    fn bench_submit_not_placed_below_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA4, 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451455365)]
    fn bench_submit_not_placed_below_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA4, 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 5894480)]
    fn bench_submit_not_placed_equal_third_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA5, 2 * 10 - 4));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46400015)]
    fn bench_submit_not_placed_equal_third_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA5, 2 * 100 - 4));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451455365)]
    fn bench_submit_not_placed_equal_third_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA5, 2 * 1000 - 4));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 5844164)]
    fn bench_submit_score_zero_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0xA6, 0));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46349699)]
    fn bench_submit_score_zero_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0xA6, 0));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451405049)]
    fn bench_submit_score_zero_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0xA6, 0));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 5844164)]
    fn bench_submit_player_zero_after_10() {
        let mut state = prime(10);
        let rank = state.submit(T, game(0, 2 * 10 + 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 46349699)]
    fn bench_submit_player_zero_after_100() {
        let mut state = prime(100);
        let rank = state.submit(T, game(0, 2 * 100 + 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 451405049)]
    fn bench_submit_player_zero_after_1000() {
        let mut state = prime(1000);
        let rank = state.submit(T, game(0, 2 * 1000 + 1));
        assert(rank == 0, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 6016269)]
    fn bench_top_after_10() {
        let mut state = prime(10);
        let top = state.top(T);
        assert(top.first.score == 2 * 10, 'top');
    }

    #[test]
    #[available_gas(l2_gas: 46521804)]
    fn bench_top_after_100() {
        let mut state = prime(100);
        let top = state.top(T);
        assert(top.first.score == 2 * 100, 'top');
    }

    #[test]
    #[available_gas(l2_gas: 451577154)]
    fn bench_top_after_1000() {
        let mut state = prime(1000);
        let top = state.top(T);
        assert(top.first.score == 2 * 1000, 'top');
    }

    #[test]
    #[available_gas(l2_gas: 5931786)]
    fn bench_ranked_full_after_10() {
        let mut state = prime(10);
        let ranked = state.ranked(T, 1);
        assert(ranked.score == 2 * 10, 'ranked');
    }

    #[test]
    #[available_gas(l2_gas: 46437321)]
    fn bench_ranked_full_after_100() {
        let mut state = prime(100);
        let ranked = state.ranked(T, 1);
        assert(ranked.score == 2 * 100, 'ranked');
    }

    #[test]
    #[available_gas(l2_gas: 451492671)]
    fn bench_ranked_full_after_1000() {
        let mut state = prime(1000);
        let ranked = state.ranked(T, 1);
        assert(ranked.score == 2 * 1000, 'ranked');
    }

    #[test]
    #[available_gas(l2_gas: 5890920)]
    fn bench_ranked_empty_after_10() {
        let mut state = prime(10);
        let ranked = state.ranked(T + 1, 1);
        assert(ranked.score == 0, 'ranked');
    }

    #[test]
    #[available_gas(l2_gas: 46396455)]
    fn bench_ranked_empty_after_100() {
        let mut state = prime(100);
        let ranked = state.ranked(T + 1, 1);
        assert(ranked.score == 0, 'ranked');
    }

    #[test]
    #[available_gas(l2_gas: 451451805)]
    fn bench_ranked_empty_after_1000() {
        let mut state = prime(1000);
        let ranked = state.ranked(T + 1, 1);
        assert(ranked.score == 0, 'ranked');
    }

    // The first submissions of a tournament: created slots (not dependent on prior submissions).
    // Each has the baseline of its own setup (`baseline_first_setup_*`).

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn baseline_first_submission() {
        let _state = MockBoard::contract_state_for_testing();
    }

    #[test]
    #[available_gas(l2_gas: 1061592)]
    fn bench_first_submission() {
        let mut state = MockBoard::contract_state_for_testing();

        let rank = state.submit(T, game(1, 5));
        assert(rank == 1, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 1061277)]
    fn baseline_first_second() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
    }

    #[test]
    #[available_gas(l2_gas: 1693587)]
    fn bench_first_second() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
        let rank = state.submit(T, game(2, 4));
        assert(rank == 2, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 1692012)]
    fn baseline_first_third() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
        state.submit(T, game(2, 4));
    }

    #[test]
    #[available_gas(l2_gas: 2321750)]
    fn bench_first_third() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
        state.submit(T, game(2, 4));
        let rank = state.submit(T, game(3, 3));
        assert(rank == 3, 'rank');
    }

    #[test]
    #[available_gas(l2_gas: 1692012)]
    fn baseline_first_rank1_on_two() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
        state.submit(T, game(2, 4));
    }

    #[test]
    #[available_gas(l2_gas: 2563176)]
    fn bench_first_rank1_on_two() {
        let mut state = MockBoard::contract_state_for_testing();
        state.submit(T, game(1, 5));
        state.submit(T, game(2, 4));
        let rank = state.submit(T, game(3, 9));
        assert(rank == 1, 'rank');
    }
}
