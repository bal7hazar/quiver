// Internal imports

pub use crate::events::index::QuestDefined;
use crate::models::definition::QuestDefinition;

// Implementations

#[generate_trait]
pub impl DefinedImpl of DefinedTrait {
    /// The keys and the values of the definition. It has no check of its own: a
    /// `QuestDefinition` is valid once built (`DefinitionTrait::new`).
    #[inline]
    fn new(definition: @QuestDefinition) -> QuestDefined {
        QuestDefined {
            quest_id: *definition.id,
            schedule: *definition.schedule,
            tasks: *definition.tasks,
            conditions: *definition.conditions,
        }
    }
}
