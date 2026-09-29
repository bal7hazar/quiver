// Internal imports

pub use crate::events::index::QuestProgressed;

// Implementations

#[generate_trait]
pub impl ProgressedImpl of ProgressedTrait {
    #[inline(always)]
    fn new(player_id: felt252, task_id: u32, count: u32) -> QuestProgressed {
        QuestProgressed { player_id, task_id, count }
    }
}
