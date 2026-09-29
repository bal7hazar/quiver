//! A task of a quest (ARC-01 §3.2): what counts, and how many. Stored in slot B with the
//! definition (`crate::models::definition`), never on its own.

// Types

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestTask {
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
    /// `'Quest: invalid tasks'` unless the id and the total are non-zero.
    #[inline]
    fn assert_valid(self: @QuestTask) {
        assert(*self.task_id != 0 && *self.total != 0, errors::TASK_INVALID);
    }
}
