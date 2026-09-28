//! The library of `quiver_quest` (ARC-01 §3.2): types, their packing into one felt (§3.3), and
//! pure functions. State in, state out: nothing here reads or writes storage.
//!
//! Every loop is bounded by a constant of `quiver_quest::constants`: `batch_merge` by
//! `MAX_ENTRIES` (checked first), the lookups of a merged batch by `MAX_ENTRIES`,
//! `definition_new` by `MAX_CONDITIONS` (checked first), `prerequisites_met` by the component's
//! one record per condition (`MAX_CONDITIONS`). Tasks and pages are unrolled.

pub mod batch;
pub mod bits;
pub mod definition;
pub mod pages;
pub mod progress;
pub mod record;
pub mod schedule;
pub mod types;

pub use batch::{batch_count_of, batch_first_position, batch_merge};
pub use definition::{conditions_span, definition_new, tasks_index_of, tasks_span};
pub use pages::{page_pop, page_position, page_push, page_set, page_span};
pub use progress::{progress_add, progress_is_complete};
pub use record::{
    claim, prerequisites_met, record_abandon, record_accept, record_complete, record_is_accepted,
};
pub use schedule::{schedule_interval_id, schedule_is_active, schedule_validate};
pub use types::{
    Mode, QuestConditions, QuestConditionsPacking, QuestDefinition, QuestDefinitionPacking,
    QuestIdPage, QuestIdPagePacking, QuestProgress, QuestProgressPacking, QuestRecord,
    QuestRecordPacking, QuestSchedule, QuestTask, QuestTasks, QuestTasksPacking, TaskProgress,
};
pub use crate::constants::{MAX_CONDITIONS, MAX_ENTRIES, MAX_PAGES, MAX_TASKS, QUESTS_PER_PAGE};
