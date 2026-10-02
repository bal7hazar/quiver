//! A progress batch (ARC-01 §3.2): the entries of one `progress_many` call, merged, then looked
//! up by task. Never stored.

use core::num::traits::SaturatingAdd;
use crate::constants::MAX_ENTRIES;
use crate::helpers::bits::{NZ_128, POW2};
use crate::models::definition::TasksSlot;

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
    /// Panics `'Quest: too many entries'` above `MAX_ENTRIES` entries, counted before merging and
    /// checked first, so that every loop below runs at most `MAX_ENTRIES` times; panics
    /// `'Quest: invalid task'` on a task id 0, whatever its count, so that the zero sentinel of an
    /// unused task slot can never match.
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

    /// The smallest position in the batch of any of the quest's tasks. Reads B only: a slot
    /// whose task id is 0 is unused and never matches. At most `self.len()` entries are visited,
    /// `MAX_ENTRIES` on a merged batch.
    fn first_position(self: Span<TaskProgress>, tasks: @TasksSlot) -> Option<u32> {
        let tasks = *tasks;
        let (id0, id1, id2) = (tasks.t0.task_id, tasks.t1.task_id, tasks.t2.task_id);
        let mut batch = self;
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

#[cfg(test)]
mod tests {
    use crate::constants::MAX_ENTRIES;
    use crate::testing::helpers::{
        U32_MAX, distinct_entries, entry, one_task, opaque, same_entries, task, tasks,
    };
    use crate::types::schedule::ScheduleAssert;
    use super::{BatchTrait, TaskProgress};

    // batch_merge

    #[test]
    #[available_gas(l2_gas: 13524)]
    fn batch_merge_empty() {
        assert!(BatchTrait::merge(array![].span()) == array![].span());
    }

    #[test]
    #[available_gas(l2_gas: 48309)]
    fn batch_merge_keeps_distinct_entries_in_order() {
        let entries = array![entry(3, 1), entry(1, 2), entry(2, 3)].span();
        assert!(BatchTrait::merge(entries) == entries);
    }

    #[test]
    #[available_gas(l2_gas: 50504)]
    fn quest_batch_duplicate_entries_merged() {
        let merged = BatchTrait::merge(array![entry(7, 4), entry(7, 4)].span());
        assert!(merged == array![entry(7, 8)].span());
    }

    #[test]
    #[available_gas(l2_gas: 81563)]
    fn quest_batch_event_mode_one_event_per_task_merge() {
        // The pure part: the batch the event mode emits, one entry per merged non-zero task
        let merged = BatchTrait::merge(
            array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span(),
        );
        assert!(merged == array![entry(1, 3), entry(3, 1)].span());
    }

    #[test]
    #[available_gas(l2_gas: 79585)]
    fn batch_merge_drops_zero_counts() {
        assert!(BatchTrait::merge(array![entry(1, 0)].span()) == array![].span());
        assert!(
            BatchTrait::merge(array![entry(1, 0), entry(1, 0), entry(2, 0)].span()) == array![]
                .span(),
        );
    }

    #[test]
    #[available_gas(l2_gas: 88878)]
    fn batch_merge_keeps_the_position_of_first_occurrence() {
        // task 1 first appears with a zero count: the merged entry is still at its first position
        let merged = BatchTrait::merge(
            array![entry(1, 0), entry(2, 1), entry(1, 2), entry(2, 5)].span(),
        );
        assert!(merged == array![entry(1, 2), entry(2, 6)].span());
    }

    #[test]
    #[available_gas(l2_gas: 276659)]
    fn batch_merge_saturates_duplicates() {
        let merged = BatchTrait::merge(array![entry(1, U32_MAX), entry(2, 1), entry(1, 1)].span());
        assert!(merged == array![entry(1, U32_MAX), entry(2, 1)].span());
        let merged = BatchTrait::merge(same_entries(9, MAX_ENTRIES, U32_MAX));
        assert!(merged == array![entry(9, U32_MAX)].span());
    }

    #[test]
    #[available_gas(l2_gas: 228224)]
    fn quest_batch_bound_accepted() {
        let entries = distinct_entries(1, MAX_ENTRIES, 1);
        assert!(BatchTrait::merge(entries) == entries);
    }

    #[test]
    #[should_panic(expected: 'Quest: too many entries')]
    #[available_gas(l2_gas: 69857)]
    fn quest_batch_above_bound_reverts() {
        BatchTrait::merge(distinct_entries(1, MAX_ENTRIES + 1, 1));
    }

    #[test]
    #[should_panic(expected: 'Quest: too many entries')]
    #[available_gas(l2_gas: 60281)]
    fn quest_batch_duplicates_count_toward_bound() {
        BatchTrait::merge(same_entries(1, MAX_ENTRIES + 1, 1));
    }

    #[test]
    #[should_panic(expected: 'Quest: too many entries')]
    #[available_gas(l2_gas: 69857)]
    fn quest_batch_zero_counts_count_toward_bound() {
        BatchTrait::merge(distinct_entries(1, MAX_ENTRIES + 1, 0));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid task')]
    #[available_gas(l2_gas: 24472)]
    fn quest_batch_rejects_task_zero() {
        BatchTrait::merge(array![entry(0, 1)].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid task')]
    #[available_gas(l2_gas: 32259)]
    fn quest_batch_rejects_task_zero_with_zero_count() {
        BatchTrait::merge(array![entry(1, 1), entry(0, 0)].span());
    }

    // The oracle: a plain merge, obviously correct. For each entry, if no earlier entry names its
    // task, sum every entry of that task (saturating) and keep it when the sum is not zero.

    fn plain_merge(entries: Span<TaskProgress>) -> Span<TaskProgress> {
        let mut out = array![];
        let mut i = 0;
        while i < entries.len() {
            let id = *entries[i].task_id;
            let mut first = true;
            let mut j = 0;
            while j < i {
                if *entries[j].task_id == id {
                    first = false;
                }
                j += 1;
            }
            if first {
                let mut sum: u64 = 0;
                let mut k = 0;
                while k < entries.len() {
                    if *entries[k].task_id == id {
                        sum += (*entries[k].count).into();
                    }
                    k += 1;
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

    fn assert_matches_plain(entries: Span<TaskProgress>) {
        assert!(BatchTrait::merge(entries) == plain_merge(entries));
    }

    #[test]
    #[available_gas(l2_gas: 184410)]
    fn batch_merge_ids_equal_modulo_128_are_distinct() {
        // The mask of the fast path collides; the plain path keeps them apart
        let entries = array![entry(1, 1), entry(129, 2), entry(257, 3), entry(0xffffff81, 4)]
            .span();
        assert!(BatchTrait::merge(entries) == entries);
        let entries = array![entry(129, 2), entry(1, 0), entry(257, 3), entry(1, 5)].span();
        assert!(
            BatchTrait::merge(entries) == array![entry(129, 2), entry(1, 5), entry(257, 3)].span(),
        );
    }

    #[test]
    #[available_gas(l2_gas: 8921498)]
    fn batch_merge_matches_the_plain_merge() {
        assert_matches_plain(array![].span());
        assert_matches_plain(array![entry(5, 0)].span());
        assert_matches_plain(distinct_entries(1, MAX_ENTRIES, 3));
        assert_matches_plain(distinct_entries(120, MAX_ENTRIES, 1));
        assert_matches_plain(distinct_entries(1, MAX_ENTRIES, 0));
        assert_matches_plain(same_entries(7, MAX_ENTRIES, 0x10000000));
        assert_matches_plain(
            array![entry(3, 1), entry(131, 0), entry(3, 2), entry(259, 9), entry(131, 4)].span(),
        );
        assert_matches_plain(
            array![entry(1, U32_MAX), entry(2, 0), entry(1, U32_MAX), entry(2, 0), entry(3, 1)]
                .span(),
        );
        let mut mixed = array![];
        let mut i: u32 = 0;
        while i < MAX_ENTRIES {
            // ids 1, 128 + 2, 3, 128 + 4, ... with every fifth a repeat of task 1
            let id = if i % 5 == 4 {
                1
            } else if i % 2 == 1 {
                128 + i + 1
            } else {
                i + 1
            };
            mixed.append(entry(id, i % 3));
            i += 1;
        }
        assert_matches_plain(mixed.span());
    }

    // batch_count_of

    #[test]
    #[available_gas(l2_gas: 41402)]
    fn batch_count_of_present_and_absent() {
        let batch = array![entry(3, 1), entry(1, 2), entry(2, 3)].span();
        assert!(BatchTrait::count_of(batch, 3) == 1);
        assert!(BatchTrait::count_of(batch, 1) == 2);
        assert!(BatchTrait::count_of(batch, 2) == 3);
        assert!(BatchTrait::count_of(batch, 4) == 0);
        assert!(BatchTrait::count_of(batch, 0) == 0);
        assert!(BatchTrait::count_of(array![].span(), 1) == 0);
    }

    // batch_first_position

    #[test]
    #[available_gas(l2_gas: 24665)]
    fn quest_batch_first_position_uses_zero_sentinel() {
        let b = one_task(1, 5);
        let batch = array![entry(2, 1), entry(1, 1)].span();
        assert!(BatchTrait::first_position(batch, @b) == Some(1));
        // An entry with task id 0 never matches the zero slots t1 and t2
        let raw = array![entry(0, 1), entry(2, 1)].span();
        assert!(BatchTrait::first_position(raw, @b) == None);
    }

    #[test]
    #[available_gas(l2_gas: 30555)]
    fn batch_first_position_is_the_smallest_position() {
        let b = tasks(task(5, 1), task(6, 1), task(7, 1));
        let batch = array![entry(1, 1), entry(7, 1), entry(5, 1), entry(6, 1)].span();
        assert!(BatchTrait::first_position(batch, @b) == Some(1));
        assert!(BatchTrait::first_position(array![entry(6, 1)].span(), @b) == Some(0));
        assert!(BatchTrait::first_position(array![entry(8, 1)].span(), @b) == None);
        assert!(BatchTrait::first_position(array![].span(), @b) == None);
    }

    #[test]
    #[available_gas(l2_gas: 151494)]
    fn batch_first_position_at_the_bound() {
        let batch = distinct_entries(1, MAX_ENTRIES, 1);
        assert!(
            BatchTrait::first_position(batch, @one_task(MAX_ENTRIES, 1)) == Some(MAX_ENTRIES - 1),
        );
        assert!(BatchTrait::first_position(batch, @one_task(MAX_ENTRIES + 1, 1)) == None);
    }

    fn sixteen_distinct() -> Span<TaskProgress> {
        opaque(distinct_entries(1, MAX_ENTRIES, 1))
    }

    /// 16 entries, 8 distinct tasks each named twice, interleaved.
    fn sixteen_with_duplicates() -> Span<TaskProgress> {
        let mut out = array![];
        let mut i: u32 = 0;
        while i < MAX_ENTRIES {
            out.append(entry(i % 8 + 1, i + 1));
            i += 1;
        }
        opaque(out.span())
    }

    /// Tasks 1..=15, then `last`; every count positive. With `last = 15` the fast path of
    /// `batch_merge` meets its repeat only at entry 16; with `last = 129` (= 1 mod 128) it meets a
    /// collision of distinct ids only at entry 16. Both then run the plain merge in full.
    fn fifteen_then(last: u32) -> Span<TaskProgress> {
        let mut out = array![];
        let mut i: u32 = 1;
        while i < MAX_ENTRIES {
            out.append(entry(i, i));
            i += 1;
        }
        out.append(entry(last, 1));
        opaque(out.span())
    }

    // Baselines: the setup of the benchmarks below, without the call

    #[test]
    #[available_gas(l2_gas: 46809)]
    fn bench_baseline_fifteen_then_one() {
        assert!(fifteen_then(16).len() == MAX_ENTRIES);
    }

    #[test]
    #[available_gas(l2_gas: 6731)]
    fn bench_baseline_empty() {
        opaque(0_u8);
    }

    #[test]
    #[available_gas(l2_gas: 57824)]
    fn bench_baseline_sixteen_distinct() {
        assert!(sixteen_distinct().len() == MAX_ENTRIES);
    }

    #[test]
    #[available_gas(l2_gas: 71054)]
    fn bench_baseline_sixteen_with_duplicates() {
        assert!(sixteen_with_duplicates().len() == MAX_ENTRIES);
    }

    // batch

    #[test]
    #[available_gas(l2_gas: 182875)]
    fn bench_batch_merge_sixteen_distinct() {
        assert!(BatchTrait::merge(sixteen_distinct()).len() == MAX_ENTRIES);
    }

    #[test]
    #[available_gas(l2_gas: 565101)]
    fn bench_batch_merge_sixteen_with_duplicates() {
        assert!(BatchTrait::merge(sixteen_with_duplicates()).len() == 8);
    }

    #[test]
    #[available_gas(l2_gas: 778453)]
    fn bench_batch_merge_late_duplicate() {
        // [1..15, 15]: the worst case with a repeated task
        assert!(BatchTrait::merge(fifteen_then(15)).len() == 15);
    }

    #[test]
    #[available_gas(l2_gas: 782558)]
    fn bench_batch_merge_late_modulo_collision() {
        // [1..15, 129]: all distinct, the mask collides at the last entry
        assert!(BatchTrait::merge(fifteen_then(129)).len() == MAX_ENTRIES);
    }

    #[test]
    #[available_gas(l2_gas: 86898)]
    fn bench_batch_count_of_absent() {
        assert!(BatchTrait::count_of(sixteen_distinct(), opaque(99)) == 0);
    }

    #[test]
    #[available_gas(l2_gas: 107793)]
    fn bench_batch_first_position_absent() {
        let absent = opaque(tasks(task(97, 1), task(98, 1), task(99, 1)));
        assert!(BatchTrait::first_position(sixteen_distinct(), @absent) == None);
    }
}
