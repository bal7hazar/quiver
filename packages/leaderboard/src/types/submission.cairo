//! What a game contract submits when a game ends. `game_id` and `time` are data: the package
//! never compares them and never reads the block timestamp.

#[derive(Copy, Drop, Serde, PartialEq, Debug)]
pub struct Submission {
    pub player_id: felt252,
    pub game_id: u32,
    pub score: u32,
    pub time: u64,
}
