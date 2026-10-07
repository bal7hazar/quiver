//! A contract that holds the node in its storage, for the unit tests: they take its state with
//! `contract_state_for_testing` and go through its internal functions, which call the leaderboard
//! on `self.leaderboard` as a consumer does (`ref self` to write, `@self` to read). Test code only;
//! `tests/` has its own mock with wrappers for what needs a deployed contract.

#[starknet::contract]
pub mod MockBoard {
    use crate::leaderboard::{LeaderboardTrait, LeaderboardViewTrait};
    use crate::store::LeaderboardStorage;
    use crate::types::ranked::Ranked;
    use crate::types::submission::Submission;
    use crate::types::top3::Top3;

    #[storage]
    pub struct Storage {
        pub leaderboard: LeaderboardStorage,
    }

    #[generate_trait]
    pub impl BoardImpl of BoardTrait {
        fn submit(ref self: ContractState, tournament_id: u64, submission: Submission) -> u8 {
            self.leaderboard.submit(tournament_id, submission)
        }

        fn ranked(self: @ContractState, tournament_id: u64, rank: u8) -> Ranked {
            self.leaderboard.ranked(tournament_id, rank)
        }

        fn top(self: @ContractState, tournament_id: u64) -> Top3 {
            self.leaderboard.top(tournament_id)
        }
    }
}
