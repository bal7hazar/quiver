//! The library of `quiver_achievement` (ARC-01 §3.10, amended by the decision of 2026-09-29):
//! types, their packing (§3.11), and pure functions. State in, state out: nothing here reads or
//! writes storage.
//!
//! **Event mode only.** There is no `Mode`, no per-player type and no completion: progress is
//! reported as events, and an indexer derives the tiers from the definitions and the events.
//!
//! Every loop is bounded by a constant of `quiver_achievement::constants`: `batch_merge` by
//! `MAX_ENTRIES` (checked first), `batch_count_of` by the entries of a merged batch
//! (`MAX_ENTRIES`). Tasks are unrolled.

pub mod batch;
pub mod bits;
pub mod definition;
pub mod types;
pub mod window;

pub use batch::{batch_count_of, batch_merge};
pub use definition::{definition_new, tasks_span};
pub use types::{
    AchievementDefinition, AchievementDefinitionPacking, AchievementExtraTasks,
    AchievementExtraTasksPacking, AchievementTask, AchievementWindow, TaskProgress,
};
pub use window::{window_is_active, window_validate};
pub use crate::constants::{MAX_ENTRIES, MAX_TASKS};
