//! A task of an achievement (ARC-01 §3.10): what counts, and how many. Stored with the definition
//! (`crate::models::definition`: the first in slot A, the others in slot B), never on its own.

// Types

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementTask {
    pub task_id: u32,
    pub total: u32,
}

// Errors

/// The string of 0.1.0 (`crate::errors`), which is API.
pub mod errors {
    pub const TASK_INVALID: felt252 = crate::errors::INVALID_TASKS;
}

// Implementations

#[generate_trait]
pub impl TaskAssert of AssertTrait {
    /// `'Achievement: invalid tasks'` unless the id and the total are non-zero.
    #[inline(always)]
    fn assert_valid(self: @AchievementTask) {
        assert(*self.task_id != 0 && *self.total != 0, errors::TASK_INVALID);
    }
}
