//! Events

use crate::logic::types::{QuestSchedule, QuestTask};

/// The event of the tracked model `QuestDefinition` (`crate::models::definition`): emitted by
/// `Store::set_definition` on every write. Unchanged since 0.1.0: its selector, keys and data.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestDefined {
    #[key]
    pub quest_id: u32,
    pub schedule: QuestSchedule,
    pub tasks: Span<QuestTask>,
    pub conditions: Span<u32>,
}
