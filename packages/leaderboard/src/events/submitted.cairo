//! The event a consumer may emit itself, from its own contract, after a `submit`. The package
//! never emits it. Paved's indexer does not read it.

use crate::types::submission::Submission;

#[derive(Drop, starknet::Event)]
pub struct LeaderboardSubmitted {
    #[key]
    pub tournament_id: u64,
    #[key]
    pub player_id: felt252,
    pub game_id: u32,
    pub score: u32,
    pub time: u64,
    pub rank: u8,
}

#[generate_trait]
pub impl SubmittedImpl of SubmittedTrait {
    /// The event for a submission and the rank `submit` returned.
    #[inline(always)]
    fn new(tournament_id: u64, submission: @Submission, rank: u8) -> LeaderboardSubmitted {
        LeaderboardSubmitted {
            tournament_id,
            player_id: *submission.player_id,
            game_id: *submission.game_id,
            score: *submission.score,
            time: *submission.time,
            rank,
        }
    }
}
