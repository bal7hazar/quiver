//! Progress batches: merge, lookup, and the first position of a quest (ARC-01 §3.2).

use core::num::traits::SaturatingAdd;
use crate::constants::MAX_ENTRIES;
use crate::errors;
use super::types::{QuestTasks, TaskProgress};

/// One entry per task, in the order of first occurrence: duplicates summed (saturating at
/// `0xffffffff`), zero counts dropped.
///
/// Panics `'Quest: too many entries'` above `MAX_ENTRIES` entries, counted before merging and
/// checked first, so that every loop below runs at most `MAX_ENTRIES` times; panics
/// `'Quest: invalid task'` on a task id 0, whatever its count, so that the zero sentinel of an
/// unused task slot can never match. At most `MAX_ENTRIES²` comparisons.
pub fn batch_merge(entries: Span<TaskProgress>) -> Span<TaskProgress> {
    let len = entries.len();
    assert(len <= MAX_ENTRIES, errors::TOO_MANY_ENTRIES);
    let mut merged: Array<TaskProgress> = array![];
    let mut i = 0;
    while i < len {
        let entry = *entries[i];
        assert(entry.task_id != 0, errors::INVALID_TASK);
        // A task already merged was summed in full at its first occurrence. A task whose sum
        // was zero is not in `merged`: its later occurrences sum to zero again and are dropped.
        if batch_count_of(merged.span(), entry.task_id) == 0 {
            let mut count = entry.count;
            let mut k = i + 1;
            while k < len {
                let other = *entries[k];
                if other.task_id == entry.task_id {
                    count = count.saturating_add(other.count);
                }
                k += 1;
            }
            if count != 0 {
                merged.append(TaskProgress { task_id: entry.task_id, count });
            }
        }
        i += 1;
    }
    merged.span()
}

/// The count of the first entry for `task_id`; 0 if absent. At most `batch.len()` comparisons,
/// `MAX_ENTRIES` on a merged batch.
pub fn batch_count_of(batch: Span<TaskProgress>, task_id: u32) -> u32 {
    let mut batch = batch;
    while let Some(entry) = batch.pop_front() {
        if *entry.task_id == task_id {
            return *entry.count;
        }
    }
    0
}

/// The smallest position in `batch` of any of the quest's tasks. Reads B only: a slot whose
/// task id is 0 is unused and never matches. At most `batch.len()` entries are visited,
/// `MAX_ENTRIES` on a merged batch.
pub fn batch_first_position(batch: Span<TaskProgress>, tasks: @QuestTasks) -> Option<u32> {
    let tasks = *tasks;
    let (id0, id1, id2) = (tasks.t0.task_id, tasks.t1.task_id, tasks.t2.task_id);
    let mut batch = batch;
    let mut position = 0;
    while let Some(entry) = batch.pop_front() {
        let id = *entry.task_id;
        if id != 0 && (id == id0 || id == id1 || id == id2) {
            return Some(position);
        }
        position += 1;
    }
    None
}
