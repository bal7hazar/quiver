// Internal imports

pub use crate::events::index::AchievementDefined;
use crate::models::index::AchievementDefinition;

// Implementations

#[generate_trait]
pub impl DefinedImpl of DefinedTrait {
    /// The key and the values of the definition. It has no check of its own: an
    /// `AchievementDefinition` is valid once built (`DefinitionTrait::new`).
    #[inline]
    fn new(definition: @AchievementDefinition) -> AchievementDefined {
        let AchievementDefinition { id, window, tasks, points } = *definition;
        AchievementDefined { achievement_id: id, window, tasks, points }
    }
}
