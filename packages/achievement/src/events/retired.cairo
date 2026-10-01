// Internal imports

pub use crate::events::index::AchievementRetired;

// Implementations

#[generate_trait]
pub impl RetiredImpl of RetiredTrait {
    #[inline(always)]
    fn new(achievement_id: u32) -> AchievementRetired {
        AchievementRetired { achievement_id }
    }
}
