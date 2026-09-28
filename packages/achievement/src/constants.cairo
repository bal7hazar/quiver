//! Bounds of the API (ARC-01 §3.1, §3.10). Every loop of the package is bounded by one of them.

/// Tasks per achievement.
pub const MAX_TASKS: u8 = 3;
/// Achievement ids in one page of a task.
pub const ACHIEVEMENTS_PER_PAGE: u8 = 7;
/// Pages per task: 28 live achievements per task.
pub const MAX_PAGES: u8 = 4;
/// Entries (distinct tasks) per `progress_many` call.
pub const MAX_ENTRIES: u32 = 16;
