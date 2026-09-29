//! The quest definition (D-143, ARC-06): the model's constructor and behaviour, its checks, its
//! errors, its storage (the slots A, B and C of 0.1.0, unchanged) and its tracking.

// Internal imports

use starknet::storage_access::StorePacking;
use crate::constants::{MAX_CONDITIONS, MAX_TASKS};
use crate::events::defined::{DefinedTrait, QuestDefined};
use crate::helpers::bits::errors::{PACKING_FIELD_OUT_OF_RANGE, PACKING_RESERVED_BITS_SET};
use crate::helpers::bits::{
    BitsTrait, NZ_2, NZ_2_32, NZ_2_64, NZ_4, NZ_8, TWO_POW_128, TWO_POW_160, TWO_POW_192,
    TWO_POW_194, TWO_POW_197, TWO_POW_198, TWO_POW_199, TWO_POW_32, TWO_POW_64, TWO_POW_96,
};
pub use crate::models::index::QuestDefinition;
use crate::store::Tracked;
use crate::types::schedule::{QuestSchedule, ScheduleAssert, ScheduleTrait};
use crate::types::task::{QuestTask, TaskAssert};

// Slots

/// Slot A, key `quest_id`: the definition's schedule and counts, and the quest's status
/// (`crate::models::status`), which shares it. Layout (bits from 0): `start` [0, 64) · `end`
/// [64, 128) · `duration` [128, 160) · `interval` [160, 192) · `task_count` [192, 194) ·
/// `condition_count` [194, 197) · `defined` [197] · `retired` [198] · `live_dependents`
/// [199, 215). 0.1.0's `quiver_quest::logic::QuestDefinition`, renamed.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct HeadSlot {
    pub schedule: QuestSchedule,
    /// 1..=MAX_TASKS.
    pub task_count: u8,
    /// 0..=MAX_CONDITIONS.
    pub condition_count: u8,
    /// Presence bit: true once `define` wrote the slot. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`: no progress, no acceptance.
    pub retired: bool,
    /// Defined, non-retired quests naming this one as a condition.
    pub live_dependents: u16,
}

/// Slot B, key `quest_id`: the tasks; unused entries are zero. Layout: `t{i}.task_id`
/// [64i, 64i + 32) · `t{i}.total` [64i + 32, 64i + 64), i = 0..3. 0.1.0's `QuestTasks`, renamed.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct TasksSlot {
    pub t0: QuestTask,
    pub t1: QuestTask,
    pub t2: QuestTask,
}

/// Slot C, key `quest_id`: the conditions; unused entries are zero; written only for a quest with
/// conditions. Layout: `q{i}` [32i, 32i + 32), i = 0..7. 0.1.0's `QuestConditions`, renamed.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct ConditionsSlot {
    pub q0: u32,
    pub q1: u32,
    pub q2: u32,
    pub q3: u32,
    pub q4: u32,
    pub q5: u32,
    pub q6: u32,
}

// Constants

const NO_TASK: QuestTask = QuestTask { task_id: 0, total: 0 };
/// Slot B of a quest not defined.
pub const NO_TASKS: TasksSlot = TasksSlot { t0: NO_TASK, t1: NO_TASK, t2: NO_TASK };
/// Slot C of a quest without conditions.
pub const NO_CONDITIONS: ConditionsSlot = ConditionsSlot {
    q0: 0, q1: 0, q2: 0, q3: 0, q4: 0, q5: 0, q6: 0,
};

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API. The schedule's and a task's own are in
/// `crate::types::schedule` and `crate::types::task`.
pub mod errors {
    pub const DEFINITION_INVALID_ID: felt252 = crate::errors::INVALID_ID;
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

    /// Whether the quest is active at `time`: its schedule's (`ScheduleTrait::is_active`).
    #[inline]
    fn is_active(self: @QuestDefinition, time: u64) -> bool {
        self.schedule.is_active(time)
    }

    /// The interval of `time`, `None` when inactive: its schedule's
    /// (`ScheduleTrait::interval_id`).
    #[inline]
    fn interval_id(self: @QuestDefinition, time: u64) -> Option<u64> {
        self.schedule.interval_id(time)
    }
}

/// Tracked (D-143): the indexer reads `QuestDefined`, which `Store::set_definition` emits on
/// every write when the consumer tracks the definition (`QuestTracking::DEFINITION`). Being
/// tracked is this impl: known at compile time.
pub impl DefinitionTracked of Tracked<QuestDefinition> {
    type Event = QuestDefined;

    #[inline]
    fn event(self: @QuestDefinition) -> QuestDefined {
        DefinedTrait::new(self)
    }
}

/// Storage: the slots A, B and C of 0.1.0, unchanged; each is one felt (`HeadPacking`,
/// `TasksPacking`, `ConditionsPacking`). A also holds the quest's status (`defined`, `retired`,
/// `live_dependents`), which is not part of this model: a definition written is a new one, with
/// the status of a new quest.
#[generate_trait]
pub impl DefinitionStorage of DefinitionStorageTrait {
    /// A (defined, not retired, no live dependents), B and C; unused entries of B and C are zero.
    /// C is written only when there are conditions.
    #[inline]
    fn into_slots(self: @QuestDefinition) -> (HeadSlot, TasksSlot, ConditionsSlot) {
        let tasks = *self.tasks;
        let conditions = *self.conditions;
        let slot_a = HeadSlot {
            schedule: *self.schedule,
            task_count: tasks.len().try_into().unwrap(),
            condition_count: conditions.len().try_into().unwrap(),
            defined: true,
            retired: false,
            live_dependents: 0,
        };
        let slot_b = TasksSlot {
            t0: tasks.task_or_zero(0), t1: tasks.task_or_zero(1), t2: tasks.task_or_zero(2),
        };
        let slot_c = ConditionsSlot {
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
        id: u32, slot_a: HeadSlot, slot_b: TasksSlot, slot_c: ConditionsSlot,
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

    /// `ScheduleAssert::assert_valid`: `end == 0 || end > start`; `duration == interval == 0`
    /// (one-off) or `0 < duration <= interval`.
    #[inline]
    fn assert_valid_schedule(schedule: QuestSchedule) {
        schedule.assert_valid();
    }

    /// 1 to `MAX_TASKS` (3), unrolled: ids distinct and non-zero, totals non-zero.
    #[inline]
    fn assert_valid_tasks(tasks: Span<QuestTask>) {
        let len = tasks.len();
        assert(len != 0 && len <= MAX_TASKS.into(), errors::DEFINITION_INVALID_TASKS);
        let t0 = *tasks[0];
        t0.assert_valid();
        if len == 1 {
            return;
        }
        let t1 = *tasks[1];
        t1.assert_valid();
        assert(t1.task_id != t0.task_id, errors::DEFINITION_INVALID_TASKS);
        if len == 2 {
            return;
        }
        let t2 = *tasks[2];
        t2.assert_valid();
        assert(
            t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::DEFINITION_INVALID_TASKS,
        );
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

/// Slot B's entries, for the paths that read B alone (`Store::get_definition_tasks`).
#[generate_trait]
pub impl TasksSlotImpl of TasksSlotTrait {
    /// The first `task_count` tasks (at most 3).
    fn tasks(self: @TasksSlot, task_count: u8) -> Span<QuestTask> {
        let tasks = *self;
        let mut out = array![];
        if task_count > 0 {
            out.append(tasks.t0);
            if task_count > 1 {
                out.append(tasks.t1);
                if task_count > 2 {
                    out.append(tasks.t2);
                }
            }
        }
        out.span()
    }

    /// The index among the first `task_count` tasks of `task_id`, if any.
    fn index_of(self: @TasksSlot, task_count: u8, task_id: u32) -> Option<u8> {
        let tasks = *self;
        if task_count > 0 && tasks.t0.task_id == task_id {
            return Some(0);
        }
        if task_count > 1 && tasks.t1.task_id == task_id {
            return Some(1);
        }
        if task_count > 2 && tasks.t2.task_id == task_id {
            return Some(2);
        }
        None
    }
}

/// Slot C's ids, for the paths that read C alone (`Store::get_definition_conditions`).
#[generate_trait]
pub impl ConditionsSlotImpl of ConditionsSlotTrait {
    /// The first `count` ids (at most 7).
    fn ids(self: @ConditionsSlot, count: u8) -> Span<u32> {
        let ids = *self;
        let mut out = array![];
        if count == 0 {
            return out.span();
        }
        out.append(ids.q0);
        if count == 1 {
            return out.span();
        }
        out.append(ids.q1);
        if count == 2 {
            return out.span();
        }
        out.append(ids.q2);
        if count == 3 {
            return out.span();
        }
        out.append(ids.q3);
        if count == 4 {
            return out.span();
        }
        out.append(ids.q4);
        if count == 5 {
            return out.span();
        }
        out.append(ids.q5);
        if count == 6 {
            return out.span();
        }
        out.append(ids.q6);
        out.span()
    }
}

/// For `DefinitionStorage::into_slots` only: the entry of a span at an index, or zero, the
/// value of an unused entry of B or C. Private to this file, and called as a method of the span
/// (`tasks.task_or_zero(1)`), so that no free function remains (ARC-06 fix loop 1, point 4).
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

// Packing. Every field is put at its offset by a multiplication on felts and read back by a
// division with remainder on a `u128` limb; no field of these slots straddles bit 128.
//
// A field narrower than its Cairo type (`task_count`, `condition_count`) is checked against its
// bound before packing, so that it never spills into its neighbour: the layout of §3.3 holds
// only these values. Unpacking rejects a felt with a bit set outside the encoding: a stored felt
// the package did not write is a corruption (`crate::helpers::bits::errors`).

pub impl HeadPacking of StorePacking<HeadSlot, felt252> {
    fn pack(value: HeadSlot) -> felt252 {
        assert(
            value.task_count <= MAX_TASKS && value.condition_count <= MAX_CONDITIONS,
            PACKING_FIELD_OUT_OF_RANGE,
        );
        let schedule = value.schedule;
        schedule.start.into()
            + schedule.end.into() * TWO_POW_64
            + schedule.duration.into() * TWO_POW_128
            + schedule.interval.into() * TWO_POW_160
            + value.task_count.into() * TWO_POW_192
            + value.condition_count.into() * TWO_POW_194
            + value.defined.into() * TWO_POW_197
            + value.retired.into() * TWO_POW_198
            + value.live_dependents.into() * TWO_POW_199
    }

    fn unpack(value: felt252) -> HeadSlot {
        let (low, high) = BitsTrait::split(value);
        let (end, start) = DivRem::div_rem(low, NZ_2_64);
        let (high, duration) = DivRem::div_rem(high, NZ_2_32);
        let (high, interval) = DivRem::div_rem(high, NZ_2_32);
        let (high, task_count) = DivRem::div_rem(high, NZ_4);
        let (high, condition_count) = DivRem::div_rem(high, NZ_8);
        let (high, defined) = DivRem::div_rem(high, NZ_2);
        let (live_dependents, retired) = DivRem::div_rem(high, NZ_2);
        HeadSlot {
            schedule: QuestSchedule {
                start: start.try_into().unwrap(),
                end: end.try_into().unwrap(),
                duration: duration.try_into().unwrap(),
                interval: interval.try_into().unwrap(),
            },
            task_count: task_count.try_into().unwrap(),
            condition_count: condition_count.try_into().unwrap(),
            defined: defined != 0,
            retired: retired != 0,
            // bits [199, 215); anything above is reserved
            live_dependents: live_dependents.try_into().expect(PACKING_RESERVED_BITS_SET),
        }
    }
}

pub impl TasksPacking of StorePacking<TasksSlot, felt252> {
    fn pack(value: TasksSlot) -> felt252 {
        value.t0.task_id.into()
            + value.t0.total.into() * TWO_POW_32
            + value.t1.task_id.into() * TWO_POW_64
            + value.t1.total.into() * TWO_POW_96
            + value.t2.task_id.into() * TWO_POW_128
            + value.t2.total.into() * TWO_POW_160
    }

    fn unpack(value: felt252) -> TasksSlot {
        let (low, high) = BitsTrait::split(value);
        let (low, id0) = DivRem::div_rem(low, NZ_2_32);
        let (low, total0) = DivRem::div_rem(low, NZ_2_32);
        let (total1, id1) = DivRem::div_rem(low, NZ_2_32);
        let (total2, id2) = DivRem::div_rem(high, NZ_2_32);
        TasksSlot {
            t0: QuestTask { task_id: id0.try_into().unwrap(), total: total0.try_into().unwrap() },
            t1: QuestTask { task_id: id1.try_into().unwrap(), total: total1.try_into().unwrap() },
            // bits [160, 192); anything above is reserved
            t2: QuestTask {
                task_id: id2.try_into().unwrap(),
                total: total2.try_into().expect(PACKING_RESERVED_BITS_SET),
            },
        }
    }
}

pub impl ConditionsPacking of StorePacking<ConditionsSlot, felt252> {
    fn pack(value: ConditionsSlot) -> felt252 {
        value.q0.into()
            + value.q1.into() * TWO_POW_32
            + value.q2.into() * TWO_POW_64
            + value.q3.into() * TWO_POW_96
            + value.q4.into() * TWO_POW_128
            + value.q5.into() * TWO_POW_160
            + value.q6.into() * TWO_POW_192
    }

    fn unpack(value: felt252) -> ConditionsSlot {
        let (low, high) = BitsTrait::split(value);
        let (low, q0) = DivRem::div_rem(low, NZ_2_32);
        let (low, q1) = DivRem::div_rem(low, NZ_2_32);
        let (q3, q2) = DivRem::div_rem(low, NZ_2_32);
        let (high, q4) = DivRem::div_rem(high, NZ_2_32);
        let (high, q5) = DivRem::div_rem(high, NZ_2_32);
        let (rest, q6) = DivRem::div_rem(high, NZ_2_32);
        // bits [224, 252) are reserved
        assert(rest == 0, PACKING_RESERVED_BITS_SET);
        ConditionsSlot {
            q0: q0.try_into().unwrap(),
            q1: q1.try_into().unwrap(),
            q2: q2.try_into().unwrap(),
            q3: q3.try_into().unwrap(),
            q4: q4.try_into().unwrap(),
            q5: q5.try_into().unwrap(),
            q6: q6.try_into().unwrap(),
        }
    }
}
