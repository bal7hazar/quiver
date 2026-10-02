//! The achievement's status (ARC-07b, ARC-06 §1.3): whether the achievement is defined, and
//! retired. Untracked.
//!
//! **It shares slot A with the definition** (`crate::models::definition::HeadSlot`), under three
//! rules, as `quiver_quest`'s status:
//!
//! 1. **Slot A is read once per path.** A path that needs the status reads A once
//!    (`Store::get_definition_head`) and takes the status from it (`head.status(id)`).
//! 2. **The status is written as the whole of A, from the A that was read**, with the
//!    definition's bits written back unchanged, in one write (`Store::set_status`). Writing the
//!    status bits alone would need a second read of A, because a storage write sets a whole felt.
//! 3. **The status is untracked.** Its writes emit nothing; `retire` emits `AchievementRetired`,
//!    an action event.

// Internal imports

use crate::models::definition::HeadSlot;
pub use crate::models::index::AchievementStatus;

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const STATUS_NOT_EXIST: felt252 = crate::errors::DOES_NOT_EXIST;
    pub const STATUS_ALREADY_DEFINED: felt252 = crate::errors::ALREADY_DEFINED;
    pub const STATUS_RETIRED: felt252 = crate::errors::RETIRED;
}

// Implementations

#[generate_trait]
pub impl StatusImpl of StatusTrait {
    /// Sets `retired`; the caller checked `assert_can_retire`.
    #[inline(always)]
    fn retire(ref self: AchievementStatus) {
        self.retired = true;
    }
}

/// By value: by snapshot costs 1 step more per check, +100 on `define` and the view, +200 on
/// `retire` (measured, ARC-07b fix loop 2).
#[generate_trait]
pub impl StatusAssert of AssertTrait {
    /// `'Achievement: does not exist'` unless defined.
    #[inline(always)]
    fn assert_does_exist(self: AchievementStatus) {
        assert(self.defined, errors::STATUS_NOT_EXIST);
    }

    /// `'Achievement: already defined'` once defined, retired or not.
    #[inline(always)]
    fn assert_does_not_exist(self: AchievementStatus) {
        assert(!self.defined, errors::STATUS_ALREADY_DEFINED);
    }

    /// Defined and not retired: `'Achievement: does not exist'`, `'Achievement: retired'`, in this
    /// order.
    #[inline(always)]
    fn assert_can_retire(self: AchievementStatus) {
        self.assert_does_exist();
        assert(!self.retired, errors::STATUS_RETIRED);
    }
}

/// Storage: bits 130 (`defined`) and 131 (`retired`) of slot A. The status is read from the A a
/// path read, and written back into it. By snapshot, as `quiver_quest`: by value costs the same
/// on every entrypoint (measured, ARC-07b fix loop 2).
#[generate_trait]
pub impl StatusStorage of StatusStorageTrait {
    /// The status of achievement `id` in its slot A.
    #[inline(always)]
    fn status(self: @HeadSlot, id: u32) -> AchievementStatus {
        AchievementStatus { id, defined: *self.defined, retired: *self.retired }
    }

    /// Slot A with this status, the definition's bits of `head` unchanged.
    #[inline(always)]
    fn into_slot(self: @AchievementStatus, head: HeadSlot) -> HeadSlot {
        HeadSlot { defined: *self.defined, retired: *self.retired, ..head }
    }
}

#[cfg(test)]
mod tests {
    use crate::models::definition::{DefinitionStorage, DefinitionTrait, HeadSlot};
    use crate::types::task::AchievementTask;
    use crate::types::window::AchievementWindow;
    use super::{AchievementStatus, StatusAssert, StatusStorage, StatusTrait};

    fn head() -> HeadSlot {
        let tasks = array![AchievementTask { task_id: 7, total: 10 }].span();
        let (slot_a, _) = DefinitionTrait::new(5, AchievementWindow { start: 1, end: 9 }, tasks, 25)
            .into_slots();
        slot_a
    }

    /// Retiring changes `retired` only: the definition's bits of A are written back unchanged.
    #[test]
    #[available_gas(l2_gas: 20633)]
    fn status_retire_keeps_the_definition_bits() {
        let head = head();
        let mut status = head.status(5);
        assert!(status == AchievementStatus { id: 5, defined: true, retired: false });
        status.assert_can_retire();
        status.retire();
        let after = status.into_slot(head);
        assert!(after == HeadSlot { retired: true, ..head });
    }

    #[test]
    #[should_panic(expected: 'Achievement: does not exist')]
    #[available_gas(l2_gas: 8201)]
    fn status_cannot_retire_undefined() {
        AchievementStatus { id: 5, defined: false, retired: false }.assert_can_retire();
    }

    #[test]
    #[should_panic(expected: 'Achievement: retired')]
    #[available_gas(l2_gas: 8201)]
    fn status_cannot_retire_twice() {
        AchievementStatus { id: 5, defined: true, retired: true }.assert_can_retire();
    }

    /// Retired or not, a defined achievement cannot be defined again.
    #[test]
    #[should_panic(expected: 'Achievement: already defined')]
    #[available_gas(l2_gas: 8201)]
    fn status_defined_refuses_define() {
        AchievementStatus { id: 5, defined: true, retired: true }.assert_does_not_exist();
    }
}
