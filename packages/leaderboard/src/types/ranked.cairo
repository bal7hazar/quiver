//! What a read returns for one rank. A zero player and a zero score mean an empty rank.

#[derive(Copy, Drop, Serde, PartialEq, Debug, Default)]
pub struct Ranked {
    pub player_id: felt252,
    pub score: u32,
}
