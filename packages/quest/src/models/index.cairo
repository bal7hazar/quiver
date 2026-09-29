//! Models

use crate::logic::types::{QuestSchedule, QuestTask};

/// A quest, as `define` wrote it; it never changes afterwards. Tracked: `Store::set_definition`
/// emits `QuestDefined` on every write. Stored in the slots A, B and C of 0.1.0, unchanged
/// (`crate::models::definition`, `DefinitionStorage`). A quest not defined reads with no task.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestDefinition {
    /// Key.
    pub id: u32,
    pub schedule: QuestSchedule,
    /// 1 to `MAX_TASKS` tasks, ids distinct and non-zero, totals non-zero.
    pub tasks: Span<QuestTask>,
    /// 0 to `MAX_CONDITIONS` quest ids, distinct, non-zero, other than `id`.
    pub conditions: Span<u32>,
}
