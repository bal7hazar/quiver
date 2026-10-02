//! A player's progress on a quest in one interval (ARC-01 §3.2): the model's behaviour, its
//! checks, its errors and its storage, slot P. Untracked: a partial count emits nothing, and
//! `QuestCompleted` and `QuestClaimed` are action events of the component, emitted once
//! (docs/research/ARC-06-model-store.md §6).

// Internal imports

use starknet::storage_access::StorePacking;
use crate::helpers::bits::errors::PACKING_RESERVED_BITS_SET;
use crate::helpers::bits::{NZ_2, NZ_2_32, TWO_POW_32, TWO_POW_64, TWO_POW_96, TWO_POW_97};
use crate::models::definition::TasksSlot;
pub use crate::models::index::QuestProgress;
use crate::types::batch::{BatchTrait, TaskProgress};

// Slots

/// Slot P, key `(player_id, quest_id, interval_id)`. Layout: `c0` [0, 32) · `c1` [32, 64) · `c2`
/// [64, 96) · `completed` [96] · `claimed` [97]. 0.1.0's `QuestProgress`, renamed: what the view
/// `quest_progress` returns.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct ProgressSlot {
    /// Counts, saturated at each task's total.
    pub c0: u32,
    pub c1: u32,
    pub c2: u32,
    pub completed: bool,
    pub claimed: bool,
}

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const PROGRESS_NOT_COMPLETED: felt252 = crate::errors::NOT_COMPLETED;
    pub const PROGRESS_ALREADY_CLAIMED: felt252 = crate::errors::ALREADY_CLAIMED;
}

// Implementations

#[generate_trait]
pub impl ProgressImpl of ProgressTrait {
    /// Adds every batched count of the quest's first `task_count` tasks at once:
    /// `c[j] = min(c[j] + batch.count_of(task_j), total[j])`.
    ///
    /// Returns `(changed, completed by this call)`. Completed by this call when every
    /// `c[j] == total[j]` and `completed` was false; `completed` is then set. Expects a merged
    /// batch (`BatchTrait::merge` first). On an unmerged batch it applies, per task, the first
    /// matching entry only (as `count_of`); later entries of the same task are ignored.
    ///
    /// Unrolled over the 3 slots; each lookup visits at most `MAX_ENTRIES` entries of a merged
    /// batch. (One pass over the batch for the 3 slots was measured more costly: its loop carries
    /// more state than three tight scans.)
    #[inline]
    fn add(
        ref self: QuestProgress, tasks: @TasksSlot, task_count: u8, batch: Span<TaskProgress>,
    ) -> (bool, bool) {
        let progress = self;
        let quest_tasks = *tasks;
        if task_count > 0 {
            let t0 = quest_tasks.t0;
            self.c0 = progress.c0.add_up_to(batch.count_of(t0.task_id), t0.total);
            if task_count > 1 {
                let t1 = quest_tasks.t1;
                self.c1 = progress.c1.add_up_to(batch.count_of(t1.task_id), t1.total);
                if task_count > 2 {
                    let t2 = quest_tasks.t2;
                    self.c2 = progress.c2.add_up_to(batch.count_of(t2.task_id), t2.total);
                }
            }
        }
        let completed = !progress.completed && self.is_complete(tasks, task_count);
        if completed {
            self.completed = true;
        }
        let changed = completed
            || self.c0 != progress.c0
            || self.c1 != progress.c1
            || self.c2 != progress.c2;
        (changed, completed)
    }

    /// Every one of the first `task_count` counts is at its total.
    fn is_complete(self: @QuestProgress, tasks: @TasksSlot, task_count: u8) -> bool {
        let progress = *self;
        let tasks = *tasks;
        (task_count < 1 || progress.c0 == tasks.t0.total)
            && (task_count < 2 || progress.c1 == tasks.t1.total)
            && (task_count < 3 || progress.c2 == tasks.t2.total)
    }

    /// Claims a completed interval: `'Quest: not completed'`, then `'Quest: already claimed'`.
    #[inline(always)]
    fn claim(ref self: QuestProgress) {
        self.assert_is_completed();
        self.assert_not_claimed();
        self.claimed = true;
    }
}

#[generate_trait]
pub impl ProgressAssert of AssertTrait {
    #[inline(always)]
    fn assert_is_completed(self: @QuestProgress) {
        assert(*self.completed, errors::PROGRESS_NOT_COMPLETED);
    }

    #[inline(always)]
    fn assert_not_claimed(self: @QuestProgress) {
        assert(!*self.claimed, errors::PROGRESS_ALREADY_CLAIMED);
    }
}

/// Storage: slot P, one felt (`ProgressPacking`).
#[generate_trait]
pub impl ProgressStorage of ProgressStorageTrait {
    #[inline(always)]
    fn into_slot(self: @QuestProgress) -> ProgressSlot {
        ProgressSlot {
            c0: *self.c0,
            c1: *self.c1,
            c2: *self.c2,
            completed: *self.completed,
            claimed: *self.claimed,
        }
    }

    #[inline(always)]
    fn from_slot(
        player_id: felt252, quest_id: u32, interval_id: u64, slot: ProgressSlot,
    ) -> QuestProgress {
        let ProgressSlot { c0, c1, c2, completed, claimed } = slot;
        QuestProgress { player_id, quest_id, interval_id, c0, c1, c2, completed, claimed }
    }
}

/// For `ProgressTrait::add` only: a count raised without passing its task's total.
#[generate_trait]
impl Counts of CountsTrait {
    /// `min(self + add, total)`, without overflow.
    #[inline(always)]
    fn add_up_to(self: u32, add: u32, total: u32) -> u32 {
        if self >= total || add >= total - self {
            total
        } else {
            self + add
        }
    }
}

// Packing: see `crate::models::definition`.

pub impl ProgressPacking of StorePacking<ProgressSlot, felt252> {
    fn pack(value: ProgressSlot) -> felt252 {
        value.c0.into()
            + value.c1.into() * TWO_POW_32
            + value.c2.into() * TWO_POW_64
            + value.completed.into() * TWO_POW_96
            + value.claimed.into() * TWO_POW_97
    }

    fn unpack(value: felt252) -> ProgressSlot {
        // 98 bits: one limb, no split; a felt of 128 bits or more is rejected here
        let low: u128 = value.try_into().expect(PACKING_RESERVED_BITS_SET);
        let (low, c0) = DivRem::div_rem(low, NZ_2_32);
        let (low, c1) = DivRem::div_rem(low, NZ_2_32);
        let (low, c2) = DivRem::div_rem(low, NZ_2_32);
        let (claimed, completed) = DivRem::div_rem(low, NZ_2);
        // bit 97 alone is `claimed`; bits [98, 128) are reserved
        assert(claimed <= 1, PACKING_RESERVED_BITS_SET);
        ProgressSlot {
            c0: c0.try_into().unwrap(),
            c1: c1.try_into().unwrap(),
            c2: c2.try_into().unwrap(),
            completed: completed != 0,
            claimed: claimed != 0,
        }
    }
}

#[cfg(test)]
mod tests {
    use starknet::storage_access::StorePacking;
    use crate::constants::MAX_ENTRIES;
    use crate::models::definition::TasksSlot;
    use crate::testing::helpers::{
        U32_MAX, add_counts, distinct_entries, entry, is_complete, no_progress, one_task, opaque,
        progress, task, tasks, three_tasks,
    };
    use crate::testing::packing::{check_progress, pow2, to_felt};
    use crate::types::batch::{BatchTrait, TaskProgress};
    use crate::types::schedule::ScheduleAssert;
    use super::ProgressSlot;

    #[test]
    #[available_gas(l2_gas: 40047)]
    fn quest_count_saturates_at_total() {
        let b = one_task(1, 10);
        let batch = array![entry(1, 7)].span();
        let (p, changed, completed) = add_counts(no_progress(), @b, 1, batch);
        assert!(p == progress(7, 0, 0, false, false));
        assert!(changed && !completed);
        let (p, changed, completed) = add_counts(p, @b, 1, batch);
        assert!(p == progress(10, 0, 0, true, false));
        assert!(changed && completed);
        // Completed once: more progress changes nothing and does not complete again
        let (p, changed, completed) = add_counts(p, @b, 1, batch);
        assert!(p == progress(10, 0, 0, true, false));
        assert!(!changed && !completed);
    }

    #[test]
    #[available_gas(l2_gas: 28245)]
    fn quest_count_max_value() {
        let b = one_task(1, U32_MAX);
        let batch = array![entry(1, U32_MAX)].span();
        let (p, changed, completed) = add_counts(progress(1, 0, 0, false, false), @b, 1, batch);
        assert!(p == progress(U32_MAX, 0, 0, true, false));
        assert!(changed && completed);
        let (p, changed, completed) = add_counts(p, @b, 1, batch);
        assert!(p == progress(U32_MAX, 0, 0, true, false));
        assert!(!changed && !completed);
    }

    #[test]
    #[available_gas(l2_gas: 15173)]
    fn quest_count_max_value_below_total() {
        // c + count overflows u32 but stays below no total: saturates at the total, never panics
        let b = one_task(1, U32_MAX);
        let (p, _, completed) = add_counts(
            progress(U32_MAX - 1, 0, 0, false, false), @b, 1, array![entry(1, U32_MAX)].span(),
        );
        assert!(p.c0 == U32_MAX);
        assert!(completed);
    }

    #[test]
    #[available_gas(l2_gas: 23268)]
    fn quest_one_off_completes_once() {
        let b = one_task(1, 1);
        let batch = array![entry(1, 1)].span();
        let (p, _, completed) = add_counts(no_progress(), @b, 1, batch);
        assert!(completed && p.completed);
        let (p2, changed, completed) = add_counts(p, @b, 1, batch);
        assert!(!completed && !changed);
        assert!(p2 == p);
    }

    #[test]
    #[available_gas(l2_gas: 44628)]
    fn quest_batch_two_tasks_one_quest_one_write_logic() {
        // Both tasks of the quest are applied by one call: one new state, one completion
        let b = tasks(task(1, 5), task(2, 5), task(0, 0));
        let batch = BatchTrait::merge(array![entry(1, 5), entry(2, 5)].span());
        let (p, changed, completed) = add_counts(no_progress(), @b, 2, batch);
        assert!(p == progress(5, 5, 0, true, false));
        assert!(changed && completed);
    }

    #[test]
    #[available_gas(l2_gas: 53885)]
    fn quest_batch_duplicate_entries_merged_progress() {
        let b = one_task(1, 10);
        let batch = BatchTrait::merge(array![entry(1, 4), entry(1, 4)].span());
        let (p, changed, completed) = add_counts(no_progress(), @b, 1, batch);
        assert!(p == progress(8, 0, 0, false, false));
        assert!(changed && !completed);
    }

    #[test]
    #[available_gas(l2_gas: 58632)]
    fn progress_add_three_tasks_partial_then_complete() {
        let b = tasks(task(1, 2), task(2, 3), task(3, 4));
        let (p, changed, completed) = add_counts(
            no_progress(), @b, 3, array![entry(3, 9), entry(1, 1)].span(),
        );
        assert!(p == progress(1, 0, 4, false, false));
        assert!(changed && !completed);
        let (p, changed, completed) = add_counts(p, @b, 3, array![entry(2, 3), entry(1, 1)].span());
        assert!(p == progress(2, 3, 4, true, false));
        assert!(changed && completed);
    }

    #[test]
    #[available_gas(l2_gas: 41591)]
    fn progress_add_ignores_other_tasks() {
        let b = tasks(task(1, 2), task(2, 3), task(0, 0));
        let start = progress(1, 1, 0, false, false);
        let (p, changed, completed) = add_counts(start, @b, 2, array![entry(9, 1)].span());
        assert!(p == start);
        assert!(!changed && !completed);
        let (p, changed, _) = add_counts(start, @b, 2, array![].span());
        assert!(p == start && !changed);
    }

    #[test]
    #[available_gas(l2_gas: 17535)]
    fn progress_add_touches_only_task_count_slots() {
        // A slot beyond task_count is left as it is, even if its task id is batched
        let b = tasks(task(1, 2), task(2, 3), task(3, 4));
        let (p, _, completed) = add_counts(
            no_progress(), @b, 1, array![entry(1, 2), entry(2, 3), entry(3, 4)].span(),
        );
        assert!(p == progress(2, 0, 0, true, false));
        assert!(completed);
    }

    #[test]
    #[available_gas(l2_gas: 9534)]
    fn progress_add_keeps_claimed() {
        let b = one_task(1, 2);
        let (p, _, _) = add_counts(
            progress(2, 0, 0, true, true), @b, 1, array![entry(1, 1)].span(),
        );
        assert!(p == progress(2, 0, 0, true, true));
    }

    // The oracle: ARC-01 §3.2's formula, written plainly with its own lookup and u64 sums. It uses
    // nothing of the library but the types.

    /// The count of the first entry naming `task_id`, by index; 0 if none.
    fn plain_lookup(batch: Span<TaskProgress>, task_id: u32) -> u32 {
        let mut found: Option<u32> = None;
        let mut i = 0;
        while i < batch.len() {
            if found.is_none() && *batch[i].task_id == task_id {
                found = Some(*batch[i].count);
            }
            i += 1;
        }
        match found {
            Some(count) => count,
            None => 0,
        }
    }

    fn plain_count(count: u32, add: u32, total: u32) -> u32 {
        let sum: u64 = count.into() + add.into();
        if sum > total.into() {
            total
        } else {
            sum.try_into().unwrap()
        }
    }

    fn plain_add(
        p: ProgressSlot, b: TasksSlot, task_count: u8, batch: Span<TaskProgress>,
    ) -> (ProgressSlot, bool, bool) {
        let mut next = p;
        if task_count >= 1 {
            next.c0 = plain_count(p.c0, plain_lookup(batch, b.t0.task_id), b.t0.total);
        }
        if task_count >= 2 {
            next.c1 = plain_count(p.c1, plain_lookup(batch, b.t1.task_id), b.t1.total);
        }
        if task_count >= 3 {
            next.c2 = plain_count(p.c2, plain_lookup(batch, b.t2.task_id), b.t2.total);
        }
        let all_done = (task_count < 1 || next.c0 == b.t0.total)
            && (task_count < 2 || next.c1 == b.t1.total)
            && (task_count < 3 || next.c2 == b.t2.total);
        let completed = all_done && !p.completed;
        if completed {
            next.completed = true;
        }
        (next, next != p, completed)
    }

    fn assert_matches_plain(
        p: ProgressSlot, b: TasksSlot, task_count: u8, batch: Span<TaskProgress>,
    ) {
        assert!(add_counts(p, @b, task_count, batch) == plain_add(p, b, task_count, batch));
    }

    #[test]
    #[available_gas(l2_gas: 9730046)]
    fn progress_add_matches_the_plain_formula() {
        let b = tasks(task(1, 10), task(2, 20), task(3, U32_MAX));
        let batches = array![
            array![].span(), array![entry(1, 3)].span(), array![entry(3, 1), entry(2, 25)].span(),
            array![entry(9, 1), entry(2, 5), entry(1, 10), entry(3, U32_MAX)].span(),
            // an unmerged batch: only the first entry of a task counts (a merged batch is expected)
            array![entry(1, 1), entry(1, 9), entry(2, 2), entry(2, 30)].span(),
            distinct_entries(1, 16, 7), distinct_entries(2, 16, 0),
        ];
        let starts = array![
            no_progress(), progress(9, 19, U32_MAX - 1, false, false),
            progress(10, 20, U32_MAX, true, false), progress(0, 20, 5, false, true),
        ];
        for batch in batches.span() {
            for start in starts.span() {
                let mut task_count: u8 = 0;
                while task_count <= 3 {
                    assert_matches_plain(*start, b, task_count, *batch);
                    task_count += 1;
                }
            }
        }
    }

    #[test]
    #[available_gas(l2_gas: 8516)]
    fn progress_is_complete_per_task_count() {
        let b = tasks(task(1, 2), task(2, 3), task(3, 4));
        assert!(!is_complete(@no_progress(), @b, 1));
        assert!(is_complete(@progress(2, 0, 0, false, false), @b, 1));
        assert!(!is_complete(@progress(2, 0, 0, false, false), @b, 2));
        assert!(is_complete(@progress(2, 3, 0, false, false), @b, 2));
        assert!(!is_complete(@progress(2, 3, 3, false, false), @b, 3));
        assert!(is_complete(@progress(2, 3, 4, false, false), @b, 3));
        assert!(!is_complete(@progress(1, 3, 4, false, false), @b, 3));
    }

    // progress

    #[test]
    #[available_gas(l2_gas: 155568)]
    fn bench_progress_add_three_tasks_sixteen_entries() {
        // tasks 14, 15, 16 are the last entries of the batch; the call completes the quest
        let batch = opaque(distinct_entries(1, MAX_ENTRIES, 100));
        let (_, changed, completed) = add_counts(
            opaque(progress(99, 99, 99, false, false)), @three_tasks(), opaque(3), batch,
        );
        assert!(changed && completed);
    }

    #[test]
    #[available_gas(l2_gas: 14333)]
    fn bench_progress_is_complete_three_tasks() {
        let p = opaque(progress(100, 100, 100, true, false));
        assert!(is_complete(@p, @three_tasks(), opaque(3)));
    }

    #[test]
    #[available_gas(l2_gas: 22365)]
    fn bench_pack_unpack_progress() {
        let p: ProgressSlot = opaque(progress(U32_MAX, U32_MAX, U32_MAX, true, true));
        let packed = StorePacking::<ProgressSlot, felt252>::pack(p);
        assert!(StorePacking::<ProgressSlot, felt252>::unpack(opaque(packed)) == p);
    }

    // ProgressSlot

    #[test]
    #[available_gas(l2_gas: 12496460)]
    fn quest_packing_round_trip_progress() {
        check_progress(progress(0, 0, 0, false, false));
        check_progress(progress(U32_MAX, U32_MAX, U32_MAX, true, true));
        check_progress(progress(U32_MAX, 0, 0, false, false));
        check_progress(progress(0, U32_MAX, 0, false, false));
        check_progress(progress(0, 0, U32_MAX, false, false));
        check_progress(progress(0, 0, 0, true, false));
        check_progress(progress(0, 0, 0, false, true));
        check_progress(progress(10, 0x12345678, 3, true, false));
        check_progress(progress(0x80000000, 1, 0x7fffffff, false, true));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 365789)]
    fn quest_unpacking_rejects_progress_bit_98() {
        StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(98)));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 352139)]
    fn quest_unpacking_rejects_progress_bit_128() {
        StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(128)));
    }

    #[test]
    #[available_gas(l2_gas: 715827)]
    fn quest_unpacking_progress_reads_bit_97_alone() {
        let p = StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(97)));
        assert!(p == progress(0, 0, 0, false, true));
        let p = StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(96)));
        assert!(p == progress(0, 0, 0, true, false));
    }
}
