// Internal imports

pub use crate::events::index::QuestClaimed;

// Implementations

#[generate_trait]
pub impl ClaimedImpl of ClaimedTrait {
    #[inline(always)]
    fn new(player_id: felt252, quest_id: u32, interval_id: u64) -> QuestClaimed {
        QuestClaimed { player_id, quest_id, interval_id }
    }
}
