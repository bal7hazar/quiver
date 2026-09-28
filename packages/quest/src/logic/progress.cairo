//! Progress of a player on a quest in one interval (ARC-01 §3.2).

use super::batch::batch_count_of;
use super::types::{QuestProgress, QuestTasks, TaskProgress};

/// `min(count + add, total)`, without overflow.
#[inline(always)]
fn saturating_count(count: u32, add: u32, total: u32) -> u32 {
    if count >= total || add >= total - count {
        total
    } else {
        count + add
    }
}

/// Adds every batched count of the quest's first `task_count` tasks at once:
/// `c[j] = min(c[j] + batch_count_of(batch, task_j), total[j])`.
///
/// Returns `(progress, changed, completed by this call)`. Completed by this call when every
/// `c[j] == total[j]` and `progress.completed` was false; `progress.completed` is then set.
/// Expects a merged batch (`batch_merge` first). On an unmerged batch it applies, per task, the
/// first matching entry only (as `batch_count_of`); later entries of the same task are ignored.
///
/// Unrolled over the 3 slots; each lookup visits at most `MAX_ENTRIES` entries of a merged batch.
/// (One pass over the batch for the 3 slots was measured more costly: its loop carries more
/// state than three tight scans.)
pub fn progress_add(
    progress: QuestProgress, tasks: @QuestTasks, task_count: u8, batch: Span<TaskProgress>,
) -> (QuestProgress, bool, bool) {
    let quest_tasks = *tasks;
    let mut next = progress;
    if task_count > 0 {
        let t0 = quest_tasks.t0;
        next.c0 = saturating_count(progress.c0, batch_count_of(batch, t0.task_id), t0.total);
        if task_count > 1 {
            let t1 = quest_tasks.t1;
            next.c1 = saturating_count(progress.c1, batch_count_of(batch, t1.task_id), t1.total);
            if task_count > 2 {
                let t2 = quest_tasks.t2;
                next
                    .c2 =
                        saturating_count(progress.c2, batch_count_of(batch, t2.task_id), t2.total);
            }
        }
    }
    let completed = !progress.completed && progress_is_complete(@next, tasks, task_count);
    if completed {
        next.completed = true;
    }
    let changed = completed
        || next.c0 != progress.c0
        || next.c1 != progress.c1
        || next.c2 != progress.c2;
    (next, changed, completed)
}

/// Every one of the first `task_count` counts is at its total.
pub fn progress_is_complete(progress: @QuestProgress, tasks: @QuestTasks, task_count: u8) -> bool {
    let progress = *progress;
    let tasks = *tasks;
    (task_count < 1 || progress.c0 == tasks.t0.total)
        && (task_count < 2 || progress.c1 == tasks.t1.total)
        && (task_count < 3 || progress.c2 == tasks.t2.total)
}
