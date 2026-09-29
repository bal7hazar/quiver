// Internal imports

pub use crate::events::index::QuestCompleted;

// Implementations

#[generate_trait]
pub impl CompletedImpl of CompletedTrait {
    #[inline(always)]
    fn new(player_id: felt252, quest_id: u32, interval_id: u64) -> QuestCompleted {
        QuestCompleted { player_id, quest_id, interval_id }
    }
}
