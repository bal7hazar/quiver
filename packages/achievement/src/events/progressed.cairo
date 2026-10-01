// Internal imports

pub use crate::events::index::AchievementProgressed;

// Implementations

#[generate_trait]
pub impl ProgressedImpl of ProgressedTrait {
    #[inline(always)]
    fn new(player_id: felt252, task_id: u32, count: u32) -> AchievementProgressed {
        AchievementProgressed { player_id, task_id, count }
    }
}
