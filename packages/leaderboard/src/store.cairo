//! The store (D-143): the only access to the leaderboard's storage, `get_x` and `set_x` per slot.
//! Arcade's `Store` wraps a Dojo world and `quiver_achievement`'s `StoreImpl` the component state;
//! here the **storage node** is the store: `StoreTrait` is implemented on the storage path of
//! `LeaderboardStorage`, so a call is `path.get_scores(tournament_id)` on the consumer's own
//! storage, with no contract, component or entry point of the package.
//!
//! Two slots per tournament and rank: the scores word (`scores`, one slot for the three ranks) and
//! one player slot per rank (`players`, key `(tournament_id, rank)`): 4 slots. A tournament id is a
//! map key, never packed nor checked: any `u64` is valid.

use starknet::storage::{
    Map, Mutable, StoragePath, StoragePathEntry, StoragePointerReadAccess,
    StoragePointerWriteAccess,
};
use crate::models::scores::Scores;

/// The node a consumer places in its `#[storage]`: `leaderboard: LeaderboardStorage`.
#[starknet::storage_node]
pub struct LeaderboardStorage {
    /// The three scores of a tournament in one word (`Scores`).
    pub scores: Map<u64, Scores>,
    /// The player of rank 1, 2 or 3 of a tournament; zero when the rank is empty.
    pub players: Map<(u64, u8), felt252>,
}

#[generate_trait]
pub impl StoreImpl of StoreTrait {
    /// One read. A tournament never submitted to reads as three zero scores.
    #[inline(always)]
    fn get_scores(self: StoragePath<LeaderboardStorage>, tournament_id: u64) -> Scores {
        self.scores.entry(tournament_id).read()
    }

    /// One read. `rank` is 1..=3; the caller reads the slot only when the rank's score is not 0.
    #[inline(always)]
    fn get_player(self: StoragePath<LeaderboardStorage>, tournament_id: u64, rank: u8) -> felt252 {
        self.players.entry((tournament_id, rank)).read()
    }
}

#[generate_trait]
pub impl StoreMutImpl of StoreMutTrait {
    /// One write.
    #[inline(always)]
    fn set_scores(
        self: StoragePath<Mutable<LeaderboardStorage>>, tournament_id: u64, scores: Scores,
    ) {
        self.scores.entry(tournament_id).write(scores);
    }

    /// One write; the caller writes only a slot whose value changes.
    #[inline(always)]
    fn set_player(
        self: StoragePath<Mutable<LeaderboardStorage>>,
        tournament_id: u64,
        rank: u8,
        player_id: felt252,
    ) {
        self.players.entry((tournament_id, rank)).write(player_id);
    }
}
