//! Progress batches: merge, lookup, and the first position of a quest (ARC-01 §3.2).

use core::num::traits::SaturatingAdd;
use crate::constants::MAX_ENTRIES;
use crate::errors;
use super::bits::{NZ_128, POW2};
use super::types::{QuestTasks, TaskProgress};

/// One entry per task, in the order of first occurrence: duplicates summed (saturating at
/// `0xffffffff`), zero counts dropped.
///
/// Panics `'Quest: too many entries'` above `MAX_ENTRIES` entries, counted before merging and
/// checked first, so that every loop below runs at most `MAX_ENTRIES` times; panics
/// `'Quest: invalid task'` on a task id 0, whatever its count, so that the zero sentinel of an
/// unused task slot can never match.
///
/// Fast path, one pass: each task id sets bit `task_id % 128` of a mask. When no bit is set
/// twice, the ids are distinct and the batch is the entries without zero counts. Otherwise
/// (a repeated id, or two ids equal modulo 128), the plain merge runs: at most `MAX_ENTRIES²`
/// comparisons.
pub fn batch_merge(entries: Span<TaskProgress>) -> Span<TaskProgress> {
    assert(entries.len() <= MAX_ENTRIES, errors::TOO_MANY_ENTRIES);
    let pow2 = POW2.span();
    let mut mask: u128 = 0;
    let mut distinct: Array<TaskProgress> = array![];
    let mut rest = entries;
    let mut collision = false;
    while let Some(entry) = rest.pop_front() {
        let entry = *entry;
        assert(entry.task_id != 0, errors::INVALID_TASK);
        let (_, index) = DivRem::div_rem(entry.task_id, NZ_128);
        let bit = *pow2[index];
        if mask & bit != 0 {
            collision = true;
            break;
        }
        mask = mask | bit;
        if entry.count != 0 {
            distinct.append(entry);
        }
    }
    if !collision {
        return distinct.span();
    }
    merge_plain(entries)
}

/// The merge by comparisons, for a batch that may repeat a task id.
fn merge_plain(entries: Span<TaskProgress>) -> Span<TaskProgress> {
    let mut merged: Array<TaskProgress> = array![];
    let mut rest = entries;
    while let Some(entry) = rest.pop_front() {
        let TaskProgress { task_id, count } = *entry;
        assert(task_id != 0, errors::INVALID_TASK);
        // A task already merged was summed in full at its first occurrence. A task whose sum
        // was zero is not in `merged`: its later occurrences sum to zero again and are dropped.
        if batch_count_of(merged.span(), task_id) == 0 {
            let mut count = count;
            let mut later = rest;
            while let Some(other) = later.pop_front() {
                if *other.task_id == task_id {
                    count = count.saturating_add(*other.count);
                }
            }
            if count != 0 {
                merged.append(TaskProgress { task_id, count });
            }
        }
    }
    merged.span()
}

/// The count of the first entry for `task_id`; 0 if absent. At most `batch.len()` comparisons,
/// `MAX_ENTRIES` on a merged batch.
///
/// Expects a merged batch (`batch_merge` first), where each task has one entry. On an unmerged
/// batch it returns the count of the first matching entry only; later entries of the same task
/// are ignored, not summed.
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
