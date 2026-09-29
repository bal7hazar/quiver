// Internal imports

pub use crate::events::index::QuestRetired;

// Implementations

#[generate_trait]
pub impl RetiredImpl of RetiredTrait {
    #[inline(always)]
    fn new(quest_id: u32) -> QuestRetired {
        QuestRetired { quest_id }
    }
}
