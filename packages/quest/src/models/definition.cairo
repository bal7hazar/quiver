//! The quest definition (D-143, ARC-06): the model's constructor and behaviour, its checks, its
//! errors, its storage and its tracking.

// Internal imports

use crate::constants::{MAX_CONDITIONS, MAX_TASKS};
use crate::events::defined::{DefinedTrait, QuestDefined};
use crate::logic::types::{
    QuestConditions, QuestDefinition as DefinitionSlot, QuestSchedule, QuestTask, QuestTasks,
};
pub use crate::models::index::QuestDefinition;
use crate::store::Tracked;

// Constants

const NO_TASK: QuestTask = QuestTask { task_id: 0, total: 0 };

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const DEFINITION_INVALID_ID: felt252 = crate::errors::INVALID_ID;
    pub const DEFINITION_INVALID_WINDOW: felt252 = crate::errors::INVALID_WINDOW;
    pub const DEFINITION_INVALID_INTERVAL: felt252 = crate::errors::INVALID_INTERVAL;
    pub const DEFINITION_INVALID_TASKS: felt252 = crate::errors::INVALID_TASKS;
    pub const DEFINITION_TOO_MANY_CONDITIONS: felt252 = crate::errors::TOO_MANY_CONDITIONS;
    pub const DEFINITION_INVALID_CONDITION: felt252 = crate::errors::INVALID_CONDITION;
    pub const DEFINITION_ALREADY_DEFINED: felt252 = crate::errors::ALREADY_DEFINED;
    pub const DEFINITION_NOT_EXIST: felt252 = crate::errors::DOES_NOT_EXIST;
}

// Implementations

#[generate_trait]
pub impl DefinitionImpl of DefinitionTrait {
    /// A valid definition, or panics, in this order: `'Quest: invalid id'`; `'Quest: invalid
    /// window'`, `'Quest: invalid interval'`; `'Quest: invalid tasks'`; `'Quest: too many
    /// conditions'`, `'Quest: invalid condition'`. That each condition exists is checked by the
    /// component, which reads it.
    #[inline]
    fn new(
        id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>, conditions: Span<u32>,
    ) -> QuestDefinition {
        // [Check] Inputs
        DefinitionAssert::assert_valid_id(id);
        DefinitionAssert::assert_valid_schedule(schedule);
        DefinitionAssert::assert_valid_tasks(tasks);
        DefinitionAssert::assert_valid_conditions(id, conditions);
        // [Return] QuestDefinition
        QuestDefinition { id, schedule, tasks, conditions }
    }

    /// `start <= time && (end == 0 || time < end) && (interval == 0 || (time - start) %
    /// interval < duration)`.
    #[inline]
    fn is_active(self: @QuestDefinition, time: u64) -> bool {
        let schedule = *self.schedule;
        if time < schedule.start || (schedule.end != 0 && time >= schedule.end) {
            return false;
        }
        let interval: u64 = schedule.interval.into();
        match interval.try_into() {
            Option::None => true,
            Option::Some(interval) => {
                let (_, offset) = DivRem::div_rem(time - schedule.start, interval);
                offset < schedule.duration.into()
            },
        }
    }

    /// `None` when inactive (never panics); `Some(0)` for a one-off quest;
    /// `Some((time - start) / interval)` otherwise.
    #[inline]
    fn interval_id(self: @QuestDefinition, time: u64) -> Option<u64> {
        let schedule = *self.schedule;
        if time < schedule.start || (schedule.end != 0 && time >= schedule.end) {
            return None;
        }
        let interval: u64 = schedule.interval.into();
        match interval.try_into() {
            Option::None => Some(0),
            Option::Some(interval) => {
                let (id, offset) = DivRem::div_rem(time - schedule.start, interval);
                if offset < schedule.duration.into() {
                    Some(id)
                } else {
                    None
                }
            },
        }
    }
}

/// Tracked (D-143): the indexer reads `QuestDefined`, which `Store::set_definition` emits on
/// every write. Being tracked is this impl: known at compile time.
pub impl DefinitionTracked of Tracked<QuestDefinition> {
    type Event = QuestDefined;

    #[inline]
    fn event(self: @QuestDefinition) -> QuestDefined {
        DefinedTrait::new(self)
    }
}

/// Storage: the slots A, B and C of 0.1.0, unchanged; each is one felt, packed by
/// `crate::logic::types` (`QuestDefinitionPacking`, `QuestTasksPacking`,
/// `QuestConditionsPacking`). A also holds the quest's status (`defined`, `retired`,
/// `live_dependents`), which is not part of this model: a definition written is a new one, with
/// the status of a new quest.
#[generate_trait]
pub impl DefinitionStorage of DefinitionStorageTrait {
    /// A (defined, not retired, no live dependents), B and C; unused entries of B and C are zero.
    /// C is written only when there are conditions.
    #[inline]
    fn into_slots(self: @QuestDefinition) -> (DefinitionSlot, QuestTasks, QuestConditions) {
        let tasks = *self.tasks;
        let conditions = *self.conditions;
        let slot_a = DefinitionSlot {
            schedule: *self.schedule,
            task_count: tasks.len().try_into().unwrap(),
            condition_count: conditions.len().try_into().unwrap(),
            defined: true,
            retired: false,
            live_dependents: 0,
        };
        let slot_b = QuestTasks {
            t0: tasks.task_or_zero(0), t1: tasks.task_or_zero(1), t2: tasks.task_or_zero(2),
        };
        let slot_c = QuestConditions {
            q0: conditions.id_or_zero(0),
            q1: conditions.id_or_zero(1),
            q2: conditions.id_or_zero(2),
            q3: conditions.id_or_zero(3),
            q4: conditions.id_or_zero(4),
            q5: conditions.id_or_zero(5),
            q6: conditions.id_or_zero(6),
        };
        (slot_a, slot_b, slot_c)
    }

    /// The definition of `id` from its slots: the first `task_count` tasks of B, the first
    /// `condition_count` ids of C. A quest not defined (A zero) has no task.
    #[inline]
    fn from_slots(
        id: u32, slot_a: DefinitionSlot, slot_b: QuestTasks, slot_c: QuestConditions,
    ) -> QuestDefinition {
        let mut tasks = array![];
        let count = slot_a.task_count;
        if count > 0 {
            tasks.append(slot_b.t0);
            if count > 1 {
                tasks.append(slot_b.t1);
                if count > 2 {
                    tasks.append(slot_b.t2);
                }
            }
        }
        let ids = [slot_c.q0, slot_c.q1, slot_c.q2, slot_c.q3, slot_c.q4, slot_c.q5, slot_c.q6];
        let conditions = ids.span().slice(0, slot_a.condition_count.into());
        QuestDefinition { id, schedule: slot_a.schedule, tasks: tasks.span(), conditions }
    }
}

#[generate_trait]
pub impl DefinitionAssert of AssertTrait {
    #[inline]
    fn assert_valid_id(id: u32) {
        assert(id != 0, errors::DEFINITION_INVALID_ID);
    }

    /// `end == 0 || end > start`; `duration == interval == 0` (one-off) or
    /// `0 < duration <= interval`.
    #[inline]
    fn assert_valid_schedule(schedule: QuestSchedule) {
        assert(
            schedule.end == 0 || schedule.end > schedule.start, errors::DEFINITION_INVALID_WINDOW,
        );
        let valid_interval = if schedule.duration == 0 {
            schedule.interval == 0
        } else {
            schedule.duration <= schedule.interval
        };
        assert(valid_interval, errors::DEFINITION_INVALID_INTERVAL);
    }

    /// 1 to `MAX_TASKS` (3), unrolled: ids distinct and non-zero, totals non-zero.
    #[inline]
    fn assert_valid_tasks(tasks: Span<QuestTask>) {
        let len = tasks.len();
        assert(len != 0 && len <= MAX_TASKS.into(), errors::DEFINITION_INVALID_TASKS);
        let t0 = *tasks[0];
        Self::assert_valid_task(t0);
        if len == 1 {
            return;
        }
        let t1 = *tasks[1];
        Self::assert_valid_task(t1);
        assert(t1.task_id != t0.task_id, errors::DEFINITION_INVALID_TASKS);
        if len == 2 {
            return;
        }
        let t2 = *tasks[2];
        Self::assert_valid_task(t2);
        assert(
            t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::DEFINITION_INVALID_TASKS,
        );
    }

    #[inline]
    fn assert_valid_task(task: QuestTask) {
        assert(task.task_id != 0 && task.total != 0, errors::DEFINITION_INVALID_TASKS);
    }

    /// At most `MAX_CONDITIONS` (7), checked first; each non-zero, other than `id`, and not
    /// repeated: each is compared with those before it, at most 21 comparisons.
    #[inline]
    fn assert_valid_conditions(id: u32, conditions: Span<u32>) {
        let len = conditions.len();
        assert(len <= MAX_CONDITIONS.into(), errors::DEFINITION_TOO_MANY_CONDITIONS);
        let mut i = 0;
        while i < len {
            let condition = *conditions[i];
            assert(condition != 0 && condition != id, errors::DEFINITION_INVALID_CONDITION);
            let mut j = 0;
            while j < i {
                assert(*conditions[j] != condition, errors::DEFINITION_INVALID_CONDITION);
                j += 1;
            }
            i += 1;
        }
    }

    #[inline]
    fn assert_does_exist(self: @QuestDefinition) {
        assert(self.tasks.len() != 0, errors::DEFINITION_NOT_EXIST);
    }

    #[inline]
    fn assert_does_not_exist(self: @QuestDefinition) {
        assert(self.tasks.len() == 0, errors::DEFINITION_ALREADY_DEFINED);
    }
}

/// For `DefinitionStorage::into_slots` only: the entry of a span at an index, or zero, the
/// value of an unused entry of B or C. Private to this file, and called as a method of the span
/// (`tasks.task_or_zero(1)`), so that no free function remains (fix loop 1, point 4).
#[generate_trait]
impl SlotEntries of SlotEntriesTrait {
    #[inline(always)]
    fn task_or_zero(self: Span<QuestTask>, index: u32) -> QuestTask {
        match self.get(index) {
            Option::Some(task) => *task.unbox(),
            Option::None => NO_TASK,
        }
    }

    #[inline(always)]
    fn id_or_zero(self: Span<u32>, index: u32) -> u32 {
        match self.get(index) {
            Option::Some(id) => *id.unbox(),
            Option::None => 0,
        }
    }
}
