//! Bounds of the API (ARC-01 §3.1, §3.2). Every loop of the package is bounded by one of them.

/// Tasks per quest.
pub const MAX_TASKS: u8 = 3;
/// Conditions (prerequisites) per quest.
pub const MAX_CONDITIONS: u8 = 7;
/// Quest ids in one page of a task.
pub const QUESTS_PER_PAGE: u8 = 7;
/// Pages per task: 28 live quests per task.
pub const MAX_PAGES: u8 = 4;
/// Entries (distinct tasks) per `progress_many` call.
pub const MAX_ENTRIES: u32 = 16;
