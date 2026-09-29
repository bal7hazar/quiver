//! Bounds of the API (ARC-01 §3.1, §3.10, amended by the decision of 2026-09-29: event mode only).
//! Every loop of the package is bounded by one of them.

/// Tasks per achievement.
pub const MAX_TASKS: u8 = 3;
/// Entries per `progress_many` call, counted before merging (duplicates and zero counts
/// included).
pub const MAX_ENTRIES: u32 = 16;
