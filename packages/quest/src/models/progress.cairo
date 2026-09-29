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
