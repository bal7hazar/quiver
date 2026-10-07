//! The leaderboard (ARC-05a): `submit`, `ranked` and `top` as trait methods on the storage path of
//! `LeaderboardStorage`, called from the consumer's own entrypoints (`self.leaderboard.submit(..)`
//! inside a contract). The package has no `#[starknet::interface]`, no ABI item, no contract and no
//! component: its access control is the consumer's, who alone calls it. It emits no event.
//!
//! **The rule.** A higher score ranks higher; an equal score never displaces (the earlier call
//! stays above); a placed submission shifts the lower ranks down by one and the third is dropped; a
//! score of 0 never ranks; games are ranked, not players (one player may hold several ranks);
//! `game_id` and `time` are data and are never compared; no block timestamp is read.
//!
//! **Never reverts.** Nothing here asserts: a score of 0, a player of 0 or a submission that does
//! not place returns 0 and writes nothing.
//!
//! **Bounds.** N is fixed at 3. No loop exists: `submit` makes at most 3 reads (the scores word and
//! the players of ranks 1 and 2) and 4 writes (the word and the three players), `top` at most 4
//! reads, `ranked` at most 2, whatever the number of submissions already made.

use starknet::storage::{Mutable, StorageAsPath, StoragePath, StoragePathMutableConversion};
use crate::models::scores::{Scores, ScoresTrait};
use crate::store::{LeaderboardStorage, StoreMutTrait, StoreTrait};
use crate::types::ranked::Ranked;
use crate::types::submission::Submission;
use crate::types::top3::Top3;

/// The reads, on a path or a mutable path of the node (a view's `self.leaderboard`, or a write's).
pub trait LeaderboardViewTrait<T> {
    /// The player and the score of `rank`; an empty `Ranked` for a rank outside 1..=3 or empty. The
    /// player slot is not read when the score is 0.
    fn ranked(self: T, tournament_id: u64, rank: u8) -> Ranked;
    /// The three ranks: one read of the scores word, and the player of each non-empty rank.
    fn top(self: T, tournament_id: u64) -> Top3;
}

/// The write, on a mutable path of the node.
pub trait LeaderboardTrait<T> {
    /// Submits a finished game; returns the rank taken, 1..=3, or 0 when not placed (nothing
    /// written). See the module's rule.
    fn submit(self: T, tournament_id: u64, submission: Submission) -> u8;
}

impl ViewImpl of LeaderboardViewTrait<StoragePath<LeaderboardStorage>> {
    fn ranked(self: StoragePath<LeaderboardStorage>, tournament_id: u64, rank: u8) -> Ranked {
        if rank == 0 || rank > 3 {
            return Default::default();
        }
        let score = self.get_scores(tournament_id).at(rank);
        if score == 0 {
            return Default::default();
        }
        Ranked { player_id: self.get_player(tournament_id, rank), score }
    }

    fn top(self: StoragePath<LeaderboardStorage>, tournament_id: u64) -> Top3 {
        let Scores { first, second, third } = self.get_scores(tournament_id);
        Top3 {
            first: self.occupant(tournament_id, 1, first),
            second: self.occupant(tournament_id, 2, second),
            third: self.occupant(tournament_id, 3, third),
        }
    }
}

#[generate_trait]
impl OccupantImpl of OccupantTrait {
    /// The ranked entry of `rank` whose score is `score`: empty, without a read, when it is 0.
    #[inline(always)]
    fn occupant(self: StoragePath<LeaderboardStorage>, tournament_id: u64, rank: u8, score: u32) -> Ranked {
        if score == 0 {
            Default::default()
        } else {
            Ranked { player_id: self.get_player(tournament_id, rank), score }
        }
    }
}

impl ViewMutImpl of LeaderboardViewTrait<StoragePath<Mutable<LeaderboardStorage>>> {
    fn ranked(self: StoragePath<Mutable<LeaderboardStorage>>, tournament_id: u64, rank: u8) -> Ranked {
        self.as_non_mut().ranked(tournament_id, rank)
    }

    fn top(self: StoragePath<Mutable<LeaderboardStorage>>, tournament_id: u64) -> Top3 {
        self.as_non_mut().top(tournament_id)
    }
}

impl SubmitImpl of LeaderboardTrait<StoragePath<Mutable<LeaderboardStorage>>> {
    fn submit(
        self: StoragePath<Mutable<LeaderboardStorage>>, tournament_id: u64, submission: Submission,
    ) -> u8 {
        let Submission { player_id, score, .. } = submission;
        if score == 0 || player_id == 0 {
            return 0;
        }
        let view = self.as_non_mut();
        let scores = view.get_scores(tournament_id);
        let rank = scores.rank(score);
        if rank == 0 {
            return 0;
        }
        let Scores { first, second, third } = scores;
        // An empty rank holds the player 0 and is not read. A slot is written only when its value
        // changes; the value now in a slot is known when it was read or when its rank was empty.
        if rank == 1 {
            let old_first = if first == 0 {
                0
            } else {
                view.get_player(tournament_id, 1)
            };
            let old_second = if second == 0 {
                0
            } else {
                view.get_player(tournament_id, 2)
            };
            if player_id != old_first {
                self.set_player(tournament_id, 1, player_id);
            }
            if old_first != old_second {
                self.set_player(tournament_id, 2, old_first);
            }
            if third != 0 || old_second != 0 {
                self.set_player(tournament_id, 3, old_second);
            }
        } else if rank == 2 {
            let old_second = if second == 0 {
                0
            } else {
                view.get_player(tournament_id, 2)
            };
            if player_id != old_second {
                self.set_player(tournament_id, 2, player_id);
            }
            if third != 0 || old_second != 0 {
                self.set_player(tournament_id, 3, old_second);
            }
        } else {
            self.set_player(tournament_id, 3, player_id);
        }
        self.set_scores(tournament_id, scores.place(rank, score));
        rank
    }
}

/// `self.leaderboard.submit(..)` and the reads on whatever turns into a path of the node: the
/// `StorageBase` of the consumer's storage, a path, a path of a nested node.
impl PathableViewImpl<
    T,
    +Drop<T>,
    impl PathImpl: StorageAsPath<T>,
    impl Inner: LeaderboardViewTrait<StoragePath<PathImpl::Value>>,
> of LeaderboardViewTrait<T> {
    fn ranked(self: T, tournament_id: u64, rank: u8) -> Ranked {
        self.as_path().ranked(tournament_id, rank)
    }

    fn top(self: T, tournament_id: u64) -> Top3 {
        self.as_path().top(tournament_id)
    }
}

impl PathableImpl<
    T,
    +Drop<T>,
    impl PathImpl: StorageAsPath<T>,
    impl Inner: LeaderboardTrait<StoragePath<PathImpl::Value>>,
> of LeaderboardTrait<T> {
    fn submit(self: T, tournament_id: u64, submission: Submission) -> u8 {
        self.as_path().submit(tournament_id, submission)
    }
}

#[cfg(test)]
mod tests {
    use crate::testing::mock::MockBoard;
    use crate::testing::reference::{ReferenceImpl, ReferenceTrait};
    use crate::types::ranked::Ranked;
    use crate::types::submission::Submission;
    use crate::types::top3::Top3;
    use crate::testing::mock::MockBoard::BoardTrait;

    /// Paved's largest tournament id (`timestamp / 86400` at its highest).
    const BIG: u64 = 213503982334600;

    fn game(player_id: felt252, score: u32) -> Submission {
        Submission { player_id, game_id: 7, score, time: 1234 }
    }

    fn at(player_id: felt252, score: u32) -> Ranked {
        Ranked { player_id, score }
    }

    fn top3(first: Ranked, second: Ranked, third: Ranked) -> Top3 {
        Top3 { first, second, third }
    }

    /// The board of the table's cases: A 10, B 8, C 5.
    fn full(ref state: MockBoard::ContractState, t: u64) {
        assert_eq!(state.submit(t, game('B', 8)), 1);
        assert_eq!(state.submit(t, game('C', 5)), 2);
        assert_eq!(state.submit(t, game('A', 10)), 1);
    }

    // The table

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn empty_board_reads_empty() {
        let state = MockBoard::contract_state_for_testing();
        assert_eq!(state.top(1), Default::default());
        assert_eq!(state.ranked(1, 1), Default::default());
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn first_submission_takes_rank_one() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 3)), 1);
        assert_eq!(state.top(1), top3(at('A', 3), at(0, 0), at(0, 0)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn ranks_fill_in_order_of_score() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 10)), 1);
        assert_eq!(state.submit(1, game('B', 8)), 2);
        assert_eq!(state.submit(1, game('C', 5)), 3);
        assert_eq!(state.top(1), top3(at('A', 10), at('B', 8), at('C', 5)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn rank_one_shifts_two_down_and_drops_the_third() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 12)), 1);
        assert_eq!(state.top(1), top3(at('D', 12), at('A', 10), at('B', 8)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn rank_two_shifts_one_down() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 9)), 2);
        assert_eq!(state.top(1), top3(at('A', 10), at('D', 9), at('B', 8)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn rank_three_replaces_the_third() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 6)), 3);
        assert_eq!(state.top(1), top3(at('A', 10), at('B', 8), at('D', 6)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn a_tie_with_the_first_goes_below_it() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 10)), 2);
        assert_eq!(state.top(1), top3(at('A', 10), at('D', 10), at('B', 8)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn a_tie_with_the_second_goes_below_it() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 8)), 3);
        assert_eq!(state.top(1), top3(at('A', 10), at('B', 8), at('D', 8)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn a_score_equal_to_the_third_is_not_placed() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 5)), 0);
        assert_eq!(state.top(1), top3(at('A', 10), at('B', 8), at('C', 5)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn a_score_below_the_third_is_not_placed() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.submit(1, game('D', 1)), 0);
        assert_eq!(state.top(1), top3(at('A', 10), at('B', 8), at('C', 5)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn ties_on_a_board_of_equal_scores_keep_the_earlier_call_above() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 4)), 1);
        assert_eq!(state.submit(1, game('B', 4)), 2);
        assert_eq!(state.submit(1, game('C', 4)), 3);
        assert_eq!(state.submit(1, game('D', 4)), 0);
        assert_eq!(state.top(1), top3(at('A', 4), at('B', 4), at('C', 4)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn score_zero_never_ranks() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 0)), 0);
        assert_eq!(state.top(1), Default::default());
        full(ref state, 2);
        assert_eq!(state.submit(2, game('D', 0)), 0);
        assert_eq!(state.top(2), top3(at('A', 10), at('B', 8), at('C', 5)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn player_zero_never_ranks() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game(0, 9)), 0);
        assert_eq!(state.top(1), Default::default());
        full(ref state, 2);
        assert_eq!(state.submit(2, game(0, 11)), 0);
        assert_eq!(state.top(2), top3(at('A', 10), at('B', 8), at('C', 5)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn a_player_holds_all_three_ranks() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 5)), 1);
        assert_eq!(state.submit(1, game('A', 7)), 1);
        assert_eq!(state.submit(1, game('A', 9)), 1);
        assert_eq!(state.top(1), top3(at('A', 9), at('A', 7), at('A', 5)));
        assert_eq!(state.submit(1, game('A', 8)), 2);
        assert_eq!(state.top(1), top3(at('A', 9), at('A', 8), at('A', 7)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn game_id_and_time_are_data_only() {
        let mut state = MockBoard::contract_state_for_testing();
        let early = Submission { player_id: 'A', game_id: 1, score: 6, time: 1 };
        let late = Submission { player_id: 'B', game_id: 99, score: 6, time: 0 };
        assert_eq!(state.submit(1, late), 1);
        assert_eq!(state.submit(1, early), 2);
        assert_eq!(state.top(1), top3(at('B', 6), at('A', 6), at(0, 0)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn the_largest_score_and_player_are_kept() {
        let mut state = MockBoard::contract_state_for_testing();
        let player = 0x800000000000011000000000000000000000000000000000000000000000000;
        assert_eq!(state.submit(1, game(player, 0xffffffff)), 1);
        assert_eq!(state.submit(1, game('B', 0xffffffff)), 2);
        assert_eq!(state.top(1), top3(at(player, 0xffffffff), at('B', 0xffffffff), at(0, 0)));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn tournament_ids_zero_and_largest_are_valid_and_isolated() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(0, game('A', 3)), 1);
        assert_eq!(state.submit(BIG, game('B', 2)), 1);
        assert_eq!(state.submit(0xffffffffffffffff, game('C', 1)), 1);
        assert_eq!(state.submit(1, game('D', 9)), 1);
        assert_eq!(state.top(0), top3(at('A', 3), at(0, 0), at(0, 0)));
        assert_eq!(state.top(BIG), top3(at('B', 2), at(0, 0), at(0, 0)));
        assert_eq!(state.top(0xffffffffffffffff), top3(at('C', 1), at(0, 0), at(0, 0)));
        assert_eq!(state.top(1), top3(at('D', 9), at(0, 0), at(0, 0)));
    }

    // `ranked`

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn ranked_reads_each_rank() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.ranked(1, 1), at('A', 10));
        assert_eq!(state.ranked(1, 2), at('B', 8));
        assert_eq!(state.ranked(1, 3), at('C', 5));
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn ranked_outside_one_to_three_is_empty() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        assert_eq!(state.ranked(1, 0), Default::default());
        assert_eq!(state.ranked(1, 4), Default::default());
        assert_eq!(state.ranked(1, 255), Default::default());
    }

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn ranked_of_an_empty_rank_is_empty() {
        let mut state = MockBoard::contract_state_for_testing();
        assert_eq!(state.submit(1, game('A', 3)), 1);
        assert_eq!(state.ranked(1, 2), Default::default());
        assert_eq!(state.ranked(1, 3), Default::default());
        assert_eq!(state.ranked(9, 1), Default::default());
    }

    // The reads on a snapshot of the state

    #[test]
    #[available_gas(l2_gas: 100000000)]
    fn reads_work_on_a_snapshot_state() {
        let mut state = MockBoard::contract_state_for_testing();
        full(ref state, 1);
        let view = @state;
        assert_eq!(view.top(1), top3(at('A', 10), at('B', 8), at('C', 5)));
        assert_eq!(view.ranked(1, 2), at('B', 8));
    }

    // The property: sequences against the reference model

    /// Eight submissions from the bytes of four words: scores of 0..=5 (ties and zeros often),
    /// players of 0..=4 (zero often, repeats often), compared with the reference after each step on
    /// the return and on `top`.
    #[test]
    #[fuzzer(runs: 64, seed: 20261007)]
    #[available_gas(l2_gas: 100000000)]
    fn property_sequences_match_the_reference(
        scores_a: u64, scores_b: u64, players_a: u64, players_b: u64, t: u64,
    ) {
        let mut state = MockBoard::contract_state_for_testing();
        let mut model: crate::testing::reference::Reference = Default::default();
        let mut scores = array![];
        let mut players = array![];
        let mut word = scores_a;
        let mut i = 0_u8;
        while i != 8 {
            scores.append(word % 256);
            word = word / 256;
            i += 1;
        }
        word = scores_b;
        i = 0;
        while i != 8 {
            scores.append(word % 256);
            word = word / 256;
            i += 1;
        }
        word = players_a;
        i = 0;
        while i != 8 {
            players.append(word % 256);
            word = word / 256;
            i += 1;
        }
        word = players_b;
        i = 0;
        while i != 8 {
            players.append(word % 256);
            word = word / 256;
            i += 1;
        }
        let mut step = 0;
        while step != 16 {
            let score: u32 = (*scores.at(step) % 6).try_into().unwrap();
            let player: felt252 = (*players.at(step) % 5).into();
            let submission = game(player, score);
            assert_eq!(state.submit(t, submission), model.apply(submission));
            assert_eq!(state.top(t), model.board());
            step += 1;
        }
    }
}
