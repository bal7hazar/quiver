//! The quest's status (ARC-07a, ARC-06 §1.3): whether the quest is defined, retired, and how many
//! live quests name it as a condition. Untracked.
//!
//! **It shares slot A with the definition** (`crate::models::definition::HeadSlot`), under three
//! rules:
//!
//! 1. **Slot A is read once per path.** A path that needs the schedule and the status reads A
//!    once (`Store::get_definition_head`) and takes the status from it (`head.status(id)`).
//! 2. **The status is written as the whole of A, from the A that was read**, with the
//!    definition's bits written back unchanged, in one write (`Store::set_status`). Writing the
//!    status bits alone would need a second read of A, because a storage write sets a whole felt.
//! 3. **The status is untracked.** Its writes emit nothing; `retire` emits `QuestRetired`, an
//!    action event.

// Internal imports

use crate::models::definition::HeadSlot;
pub use crate::models::index::QuestStatus;

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const STATUS_NOT_EXIST: felt252 = crate::errors::DOES_NOT_EXIST;
    pub const STATUS_RETIRED: felt252 = crate::errors::RETIRED;
    pub const STATUS_HAS_LIVE_DEPENDENTS: felt252 = crate::errors::HAS_LIVE_DEPENDENTS;
    pub const STATUS_TOO_MANY_DEPENDENTS: felt252 = crate::errors::TOO_MANY_DEPENDENTS;
    pub const STATUS_INVALID_CONDITION: felt252 = crate::errors::INVALID_CONDITION;
}

// Implementations

#[generate_trait]
pub impl StatusImpl of StatusTrait {
    /// Defined and not retired: a quest that can be accepted, progressed, and named as a
    /// condition.
    #[inline(always)]
    fn is_live(self: @QuestStatus) -> bool {
        *self.defined && !*self.retired
    }

    /// Sets `retired`; the caller checked `assert_can_retire`.
    #[inline(always)]
    fn retire(ref self: QuestStatus) {
        self.retired = true;
    }

    /// One more live quest names this one as a condition; `'Quest: too many dependents'` at
    /// `0xffff`.
    #[inline(always)]
    fn add_dependent(ref self: QuestStatus) {
        assert(self.live_dependents != 0xffff, errors::STATUS_TOO_MANY_DEPENDENTS);
        self.live_dependents += 1;
    }

    /// A quest naming this one as a condition is retired.
    #[inline(always)]
    fn remove_dependent(ref self: QuestStatus) {
        self.live_dependents -= 1;
    }
}

#[generate_trait]
pub impl StatusAssert of AssertTrait {
    /// `'Quest: does not exist'` unless defined.
    #[inline(always)]
    fn assert_does_exist(self: @QuestStatus) {
        assert(*self.defined, errors::STATUS_NOT_EXIST);
    }

    /// `'Quest: retired'` once retired.
    #[inline(always)]
    fn assert_not_retired(self: @QuestStatus) {
        assert(!*self.retired, errors::STATUS_RETIRED);
    }

    /// Defined, not retired, and no live quest names it: `'Quest: does not exist'`, `'Quest:
    /// retired'`, `'Quest: has live dependents'`, in this order.
    #[inline(always)]
    fn assert_can_retire(self: @QuestStatus) {
        self.assert_does_exist();
        self.assert_not_retired();
        assert(*self.live_dependents == 0, errors::STATUS_HAS_LIVE_DEPENDENTS);
    }

    /// A condition of a new quest must be live: `'Quest: invalid condition'`.
    #[inline(always)]
    fn assert_valid_condition(self: @QuestStatus) {
        assert(self.is_live(), errors::STATUS_INVALID_CONDITION);
    }
}

/// Storage: bits [197, 215) of slot A. The status is read from the A a path read, and written
/// back into it.
#[generate_trait]
pub impl StatusStorage of StatusStorageTrait {
    /// The status of quest `id` in its slot A.
    #[inline(always)]
    fn status(self: @HeadSlot, id: u32) -> QuestStatus {
        QuestStatus {
            id, defined: *self.defined, retired: *self.retired, live_dependents: *self.live_dependents,
        }
    }

    /// Slot A with this status, the definition's bits of `head` unchanged.
    #[inline(always)]
    fn into_slot(self: @QuestStatus, head: HeadSlot) -> HeadSlot {
        HeadSlot {
            defined: *self.defined,
            retired: *self.retired,
            live_dependents: *self.live_dependents,
            ..head,
        }
    }
}
