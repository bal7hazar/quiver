//! The scores of a tournament (the word `LeaderboardStorage::scores` holds), the rank a score
//! takes and the shift a placement makes. Not tracked: the package emits nothing.

pub use crate::models::index::{Scores, ScoresStorePacking};

#[generate_trait]
pub impl ScoresImpl of ScoresTrait {
    /// The rank `score` takes: 1 if above the first, else 2 if above the second, else 3 if above
    /// the third, else 0 (not placed). An equal score goes below.
    #[inline(always)]
    fn rank(self: @Scores, score: u32) -> u8 {
        if score > *self.first {
            1
        } else if score > *self.second {
            2
        } else if score > *self.third {
            3
        } else {
            0
        }
    }

    /// The scores once `score` takes `rank` (1..=3): the lower ranks shift down by one, the third
    /// is dropped when displaced. Any other rank leaves the scores as they are.
    #[inline(always)]
    fn place(self: @Scores, rank: u8, score: u32) -> Scores {
        let Scores { first, second, third } = *self;
        if rank == 1 {
            Scores { first: score, second: first, third: second }
        } else if rank == 2 {
            Scores { first, second: score, third: second }
        } else if rank == 3 {
            Scores { first, second, third: score }
        } else {
            Scores { first, second, third }
        }
    }

    /// The score of `rank`; 0 outside 1..=3, as for an empty rank.
    #[inline(always)]
    fn at(self: @Scores, rank: u8) -> u32 {
        if rank == 1 {
            *self.first
        } else if rank == 2 {
            *self.second
        } else if rank == 3 {
            *self.third
        } else {
            0
        }
    }
}

#[cfg(test)]
mod tests {
    use starknet::storage_access::StorePacking;
    use super::{Scores, ScoresTrait};

    const MAX: u32 = 0xffffffff;

    fn scores(first: u32, second: u32, third: u32) -> Scores {
        Scores { first, second, third }
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn packing_ranks_sit_at_their_bits() {
        assert_eq!(StorePacking::pack(scores(1, 0, 0)), 1);
        assert_eq!(StorePacking::pack(scores(0, 1, 0)), 0x100000000);
        assert_eq!(StorePacking::pack(scores(0, 0, 1)), 0x10000000000000000);
        assert_eq!(StorePacking::pack(scores(MAX, MAX, MAX)), 0xffffffffffffffffffffffff);
    }

    #[test]
    #[available_gas(l2_gas: 71789)]
    fn packing_round_trips() {
        let cases = array![
            scores(0, 0, 0), scores(1, 0, 0), scores(3, 2, 1), scores(MAX, 0, 7),
            scores(MAX, MAX, MAX), scores(0x12345678, 0x9abcdef0, 0x0fedcba9),
        ];
        for case in cases {
            let word: felt252 = StorePacking::pack(case);
            assert_eq!(StorePacking::unpack(word), case);
        }
    }

    #[test]
    #[available_gas(l2_gas: 14753)]
    fn packing_empty_slot_unpacks_to_zero_scores() {
        assert_eq!(StorePacking::unpack(0), scores(0, 0, 0));
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn rank_of_a_score() {
        let board = scores(10, 8, 5);
        assert_eq!(board.rank(11), 1);
        assert_eq!(board.rank(10), 2); // equal to the first goes below it
        assert_eq!(board.rank(9), 2);
        assert_eq!(board.rank(8), 3);
        assert_eq!(board.rank(6), 3);
        assert_eq!(board.rank(5), 0); // equal to the third is not placed
        assert_eq!(board.rank(1), 0);
        assert_eq!(scores(0, 0, 0).rank(1), 1);
        assert_eq!(scores(4, 0, 0).rank(4), 2);
        assert_eq!(scores(4, 3, 0).rank(3), 3);
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn place_shifts_the_lower_ranks_down() {
        let board = scores(10, 8, 5);
        assert_eq!(board.place(1, 12), scores(12, 10, 8));
        assert_eq!(board.place(2, 9), scores(10, 9, 8));
        assert_eq!(board.place(3, 6), scores(10, 8, 6));
        assert_eq!(board.place(0, 6), board);
        assert_eq!(board.place(4, 6), board);
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn at_reads_a_rank_and_zero_outside() {
        let board = scores(10, 8, 5);
        assert_eq!(board.at(0), 0);
        assert_eq!(board.at(1), 10);
        assert_eq!(board.at(2), 8);
        assert_eq!(board.at(3), 5);
        assert_eq!(board.at(4), 0);
    }
}
