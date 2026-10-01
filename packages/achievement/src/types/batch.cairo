//! A progress batch (ARC-01 §3.10): the entries of one `progress_many` call, merged, then looked
//! up by task. Never stored: in event mode, each merged entry is one `AchievementProgressed`.

use core::num::traits::SaturatingAdd;
use crate::constants::MAX_ENTRIES;
use crate::helpers::bits::{NZ_128, POW2};

// Types

/// One entry of a progress batch.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct TaskProgress {
    pub task_id: u32,
    pub count: u32,
}

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const BATCH_TOO_MANY_ENTRIES: felt252 = crate::errors::TOO_MANY_ENTRIES;
    pub const BATCH_INVALID_TASK: felt252 = crate::errors::INVALID_TASK;
}

// Implementations

/// A batch is a span of entries: `entries.merge()`, then `batch.count_of(task_id)`.
#[generate_trait]
pub impl BatchImpl of BatchTrait {
    /// One entry per task, in the order of first occurrence: duplicates summed (saturating at
    /// `0xffffffff`), zero counts dropped.
    ///
    /// Panics `'Achievement: too many entries'` above `MAX_ENTRIES` entries, counted before
    /// merging and checked first, so that every loop below runs at most `MAX_ENTRIES` times;
    /// panics `'Achievement: invalid task'` on a task id 0, whatever its count, since no
    /// achievement has a task 0.
    ///
    /// Fast path, one pass: each task id sets bit `task_id % 128` of a mask. When no bit is set
    /// twice, the ids are distinct and the batch is the entries without zero counts. Otherwise
    /// (a repeated id, or two ids equal modulo 128), the plain merge runs: at most `MAX_ENTRIES²`
    /// comparisons.
    fn merge(self: Span<TaskProgress>) -> Span<TaskProgress> {
        let entries = self;
        assert(entries.len() <= MAX_ENTRIES, errors::BATCH_TOO_MANY_ENTRIES);
        let pow2 = POW2.span();
        let mut mask: u128 = 0;
        let mut distinct: Array<TaskProgress> = array![];
        let mut rest = entries;
        let mut collision = false;
        while let Some(entry) = rest.pop_front() {
            let entry = *entry;
            assert(entry.task_id != 0, errors::BATCH_INVALID_TASK);
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
        entries.merge_plain()
    }

    /// The count of the first entry for `task_id`; 0 if absent. At most `self.len()`
    /// comparisons, `MAX_ENTRIES` on a merged batch.
    ///
    /// Expects a merged batch (`merge` first), where each task has one entry. On an unmerged
    /// batch it returns the count of the first matching entry only; later entries of the same
    /// task are ignored, not summed.
    fn count_of(self: Span<TaskProgress>, task_id: u32) -> u32 {
        let mut batch = self;
        while let Some(entry) = batch.pop_front() {
            if *entry.task_id == task_id {
                return *entry.count;
            }
        }
        0
    }
}

#[generate_trait]
impl BatchPrivate of BatchPrivateTrait {
    /// The merge by comparisons, for a batch that may repeat a task id.
    fn merge_plain(self: Span<TaskProgress>) -> Span<TaskProgress> {
        let mut merged: Array<TaskProgress> = array![];
        let mut rest = self;
        while let Some(entry) = rest.pop_front() {
            let TaskProgress { task_id, count } = *entry;
            assert(task_id != 0, errors::BATCH_INVALID_TASK);
            // A task already merged was summed in full at its first occurrence. A task whose sum
            // was zero is not in `merged`: its later occurrences sum to zero again and are
            // dropped.
            if merged.span().count_of(task_id) == 0 {
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
}

/// The merge and the lookup against a plain oracle, and their benchmarks on the worst case of
/// each (docs/CAIRO.md §2). A benchmark's figure includes its setup; the function's own cost is
/// the benchmark minus `bench_baseline_sixteen_entries`.
#[cfg(test)]
mod tests {
    use crate::constants::MAX_ENTRIES;
    use super::{BatchTrait, TaskProgress};

    const U32_MAX: u32 = 0xffffffff;

    fn entry(task_id: u32, count: u32) -> TaskProgress {
        TaskProgress { task_id, count }
    }

    /// `n` entries with the task ids `first`, `first + 1`, ..., each with `count`.
    fn distinct_entries(first: u32, n: u32, count: u32) -> Span<TaskProgress> {
        let mut entries = array![];
        let mut i: u32 = 0;
        while i < n {
            entries.append(entry(first + i, count));
            i += 1;
        }
        entries.span()
    }

    /// Tasks 1..=15, then `last`, each with count 1. `[1..=15, 129]` (129 = 1 mod 128) meets a
    /// collision only at the 16th entry, so the fast pass of `merge` runs 15 entries and then the
    /// plain merge runs in full; `[1..=15, 15]` is a late duplicate.
    fn fifteen_then(last: u32) -> Span<TaskProgress> {
        let mut entries = array![];
        let mut task_id: u32 = 1;
        while task_id < MAX_ENTRIES {
            entries.append(entry(task_id, 1));
            task_id += 1;
        }
        entries.append(entry(last, 1));
        entries.span()
    }

    /// The plain merge: for each task in the order of first occurrence, the saturated sum of its
    /// counts; zero sums dropped. Obviously correct, quadratic.
    fn oracle(entries: Span<TaskProgress>) -> Span<TaskProgress> {
        let mut out: Array<TaskProgress> = array![];
        let mut seen: Array<u32> = array![];
        let mut i = 0;
        while i < entries.len() {
            let id = *entries[i].task_id;
            let mut known = false;
            for s in seen.span() {
                if *s == id {
                    known = true;
                }
            }
            if !known {
                seen.append(id);
                let mut sum: u64 = 0;
                for e in entries {
                    if *e.task_id == id {
                        sum += (*e.count).into();
                    }
                }
                if sum > U32_MAX.into() {
                    sum = U32_MAX.into();
                }
                if sum != 0 {
                    out.append(entry(id, sum.try_into().unwrap()));
                }
            }
            i += 1;
        }
        out.span()
    }

    #[test]
    #[available_gas(l2_gas: 54147)]
    fn batch_merge_distinct_keeps_order_and_drops_zeros() {
        let entries = array![entry(3, 1), entry(1, 0), entry(2, 5)].span();
        assert!(entries.merge() == array![entry(3, 1), entry(2, 5)].span());
    }

    #[test]
    #[available_gas(l2_gas: 178804)]
    fn achievement_batch_merges_duplicates() {
        let entries = array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span();
        let merged = entries.merge();
        assert!(merged == array![entry(1, 3), entry(3, 1)].span());
        assert!(merged == oracle(entries));
    }

    #[test]
    #[available_gas(l2_gas: 84121)]
    fn batch_merge_saturates() {
        let entries = array![entry(1, U32_MAX), entry(2, 1), entry(1, 5)].span();
        assert!(entries.merge() == array![entry(1, U32_MAX), entry(2, 1)].span());
    }

    /// Ids equal modulo 128 but distinct are not merged.
    #[test]
    #[available_gas(l2_gas: 1912600)]
    fn batch_merge_modulo_collision_not_merged() {
        let entries = fifteen_then(129);
        let merged = entries.merge();
        assert!(merged == entries);
        assert!(merged == oracle(entries));
    }

    #[test]
    #[available_gas(l2_gas: 1844497)]
    fn batch_merge_late_duplicate() {
        let entries = fifteen_then(15);
        let merged = entries.merge();
        assert!(merged.len() == 15);
        assert!(merged.count_of(15) == 2);
        assert!(merged == oracle(entries));
    }

    /// A duplicate whose counts sum to zero is dropped, in the plain merge too.
    #[test]
    #[available_gas(l2_gas: 83533)]
    fn batch_merge_zero_sum_duplicate_dropped() {
        let entries = array![entry(1, 0), entry(2, 1), entry(1, 0)].span();
        assert!(entries.merge() == array![entry(2, 1)].span());
    }

    #[test]
    #[available_gas(l2_gas: 239837)]
    fn batch_merge_bound_accepted() {
        let entries = distinct_entries(1, MAX_ENTRIES, 1);
        assert!(entries.merge() == entries);
        let empty: Span<TaskProgress> = array![].span();
        assert!(empty.merge().len() == 0);
    }

    #[test]
    #[should_panic(expected: 'Achievement: too many entries')]
    #[available_gas(l2_gas: 77973)]
    fn batch_merge_above_bound_reverts() {
        distinct_entries(1, MAX_ENTRIES + 1, 1).merge();
    }

    /// The bound is checked before merging: 17 entries of one task revert.
    #[test]
    #[should_panic(expected: 'Achievement: too many entries')]
    #[available_gas(l2_gas: 65247)]
    fn batch_merge_duplicates_count_toward_bound() {
        let mut entries = array![];
        let mut i = 0;
        while i <= MAX_ENTRIES {
            entries.append(entry(7, 1));
            i += 1;
        }
        entries.span().merge();
    }

    #[test]
    #[should_panic(expected: 'Achievement: invalid task')]
    #[available_gas(l2_gas: 40375)]
    fn batch_merge_rejects_task_zero() {
        array![entry(1, 1), entry(0, 0)].span().merge();
    }

    /// Task 0 is refused in the plain merge too (after a collision).
    #[test]
    #[should_panic(expected: 'Achievement: invalid task')]
    #[available_gas(l2_gas: 65320)]
    fn batch_merge_rejects_task_zero_after_collision() {
        array![entry(1, 1), entry(1, 1), entry(0, 1)].span().merge();
    }

    #[test]
    #[available_gas(l2_gas: 27605)]
    fn batch_count_of_first_entry_or_zero() {
        let batch = array![entry(4, 2), entry(9, 3)].span();
        assert!(batch.count_of(9) == 3);
        assert!(batch.count_of(5) == 0);
    }

    // Benchmarks

    #[test]
    #[available_gas(l2_gas: 52490)]
    fn bench_baseline_sixteen_entries() {
        fifteen_then(129);
    }

    #[test]
    #[available_gas(l2_gas: 789100)]
    fn bench_batch_merge_late_modulo_collision() {
        fifteen_then(129).merge();
    }

    #[test]
    #[available_gas(l2_gas: 784994)]
    fn bench_batch_merge_late_duplicate() {
        fifteen_then(15).merge();
    }

    #[test]
    #[available_gas(l2_gas: 189416)]
    fn bench_batch_merge_sixteen_distinct() {
        distinct_entries(1, 16, 1).merge();
    }
}
