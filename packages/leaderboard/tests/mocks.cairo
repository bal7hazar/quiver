//! A contract that holds the node in its storage, with test-only wrappers: the three calls, the
//! gas of one `submit` (measured inside the contract, so that the figure is the internal call's)
//! and the storage addresses of a tournament's four slots, so that a test reads them with `load`.

use quiver_leaderboard::types::ranked::Ranked;
use quiver_leaderboard::types::top3::Top3;

#[starknet::interface]
pub trait IMockConsumer<T> {
    fn submit(ref self: T, tournament_id: u64, player_id: felt252, score: u32) -> u8;
    /// `submit`, and the L2 gas the leaderboard call itself used.
    fn submit_gas(ref self: T, tournament_id: u64, player_id: felt252, score: u32) -> (u8, u64);
    fn ranked(self: @T, tournament_id: u64, rank: u8) -> Ranked;
    fn top(self: @T, tournament_id: u64) -> Top3;
    fn scores_address(self: @T, tournament_id: u64) -> felt252;
    fn player_address(self: @T, tournament_id: u64, rank: u8) -> felt252;
}

#[starknet::contract]
pub mod MockConsumer {
    use core::testing::get_available_gas;
    use quiver_leaderboard::leaderboard::{LeaderboardTrait, LeaderboardViewTrait};
    use quiver_leaderboard::store::LeaderboardStorage;
    use quiver_leaderboard::types::ranked::Ranked;
    use quiver_leaderboard::types::submission::Submission;
    use quiver_leaderboard::types::top3::Top3;
    use starknet::storage::{StorageAsPointer, StoragePathEntry};
    use starknet::storage_access::storage_address_from_base_and_offset;

    #[storage]
    struct Storage {
        leaderboard: LeaderboardStorage,
    }

    fn game(player_id: felt252, score: u32) -> Submission {
        Submission { player_id, game_id: 1, score, time: 1 }
    }

    #[abi(embed_v0)]
    impl MockImpl of super::IMockConsumer<ContractState> {
        fn submit(
            ref self: ContractState, tournament_id: u64, player_id: felt252, score: u32,
        ) -> u8 {
            self.leaderboard.submit(tournament_id, game(player_id, score))
        }

        fn submit_gas(
            ref self: ContractState, tournament_id: u64, player_id: felt252, score: u32,
        ) -> (u8, u64) {
            let before = get_available_gas();
            let rank = self.leaderboard.submit(tournament_id, game(player_id, score));
            let after = get_available_gas();
            (rank, (before - after).try_into().unwrap())
        }

        fn ranked(self: @ContractState, tournament_id: u64, rank: u8) -> Ranked {
            self.leaderboard.ranked(tournament_id, rank)
        }

        fn top(self: @ContractState, tournament_id: u64) -> Top3 {
            self.leaderboard.top(tournament_id)
        }

        fn scores_address(self: @ContractState, tournament_id: u64) -> felt252 {
            let ptr = self.leaderboard.scores.entry(tournament_id).as_ptr();
            storage_address_from_base_and_offset(
                ptr.__storage_pointer_address__, ptr.__storage_pointer_offset__,
            )
                .into()
        }

        fn player_address(self: @ContractState, tournament_id: u64, rank: u8) -> felt252 {
            let ptr = self.leaderboard.players.entry((tournament_id, rank)).as_ptr();
            storage_address_from_base_and_offset(
                ptr.__storage_pointer_address__, ptr.__storage_pointer_offset__,
            )
                .into()
        }
    }
}
