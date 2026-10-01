//! Builders shared by the tests: they keep each test to its given, when and then.

use quiver_achievement::constants::MAX_ENTRIES;
use quiver_achievement::types::batch::TaskProgress;
use quiver_achievement::types::task::AchievementTask;
use quiver_achievement::types::window::AchievementWindow;

pub const U32_MAX: u32 = 0xffffffff;
pub const U64_MAX: u64 = 0xffffffffffffffff;

pub fn window(start: u64, end: u64) -> AchievementWindow {
    AchievementWindow { start, end }
}

/// Open on both sides: always counts.
pub fn always() -> AchievementWindow {
    window(0, 0)
}

pub fn task(task_id: u32, total: u32) -> AchievementTask {
    AchievementTask { task_id, total }
}

pub fn entry(task_id: u32, count: u32) -> TaskProgress {
    TaskProgress { task_id, count }
}

/// `[(task_id, total)]`.
pub fn one(task_id: u32, total: u32) -> Span<AchievementTask> {
    array![task(task_id, total)].span()
}

/// `n` entries with the task ids `first`, `first + 1`, ..., each with `count`.
pub fn distinct_entries(first: u32, n: u32, count: u32) -> Span<TaskProgress> {
    let mut entries = array![];
    let mut i: u32 = 0;
    while i < n {
        entries.append(entry(first + i, count));
        i += 1;
    }
    entries.span()
}

/// Tasks 1..=15, then `last`, each with count 1. `[1..=15, 129]` (129 = 1 mod 128) meets a
/// collision only at the 16th entry, so the fast pass of `batch_merge` runs 15 entries and then
/// the plain merge runs in full; `[1..=15, 15]` is a late duplicate.
pub fn fifteen_then(last: u32) -> Span<TaskProgress> {
    let mut entries = array![];
    let mut task_id: u32 = 1;
    while task_id < MAX_ENTRIES {
        entries.append(entry(task_id, 1));
        task_id += 1;
    }
    entries.append(entry(last, 1));
    entries.span()
}
