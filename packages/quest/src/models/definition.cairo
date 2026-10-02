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

#[cfg(test)]
mod tests {
    use starknet::storage_access::StorePacking;
    use crate::component::QuestComponent::QuestDefined;
    use crate::errors;
    use crate::testing::helpers::{
        DAY, U32_MAX, U64_MAX, daily, definition_slots, held, held_slot, ids, no_ids, one_off,
        one_task, opaque, recurring, schedule, task, tasks, three_tasks,
    };
    use crate::testing::oracle::{definition_new, schedule_interval_id, schedule_is_active};
    use crate::testing::packing::{
        check_conditions, check_definition, check_held_slot, check_tasks, get, pow2, to_felt,
    };
    use crate::types::schedule::{ScheduleAssert, errors as schedule_errors};
    use crate::types::task::QuestTask;
    use super::{
        ConditionsSlot, ConditionsSlotTrait, DefinitionAssert, DefinitionStorage, DefinitionTracked,
        DefinitionTrait, HeadSlot, HeadSlot as DefinitionSlot, QuestDefinition, TasksSlot,
        TasksSlotTrait, errors as definition_errors,
    };

    const Q: u32 = 42;

    fn define(tasks: Span<QuestTask>, conditions: Span<u32>) {
        definition_slots(Q, one_off(), tasks, conditions);
    }

    // definition_new

    #[test]
    #[available_gas(l2_gas: 20244)]
    fn definition_new_one_task() {
        let (definition, quest_tasks, quest_conditions) = definition_slots(
            Q, one_off(), array![task(7, 10)].span(), array![].span(),
        );
        let expected = HeadSlot {
            schedule: one_off(),
            task_count: 1,
            condition_count: 0,
            defined: true,
            retired: false,
            live_dependents: 0,
        };
        assert!(definition == expected);
        assert!(quest_tasks == one_task(7, 10));
        assert!(quest_conditions == no_ids());
    }

    #[test]
    #[available_gas(l2_gas: 160629)]
    fn definition_new_three_tasks_seven_conditions() {
        let s = schedule(100, 1000, 10, 60);
        let (definition, quest_tasks, quest_conditions) = definition_slots(
            Q,
            s,
            array![task(1, 5), task(2, 6), task(3, 0xffffffff)].span(),
            array![11, 12, 13, 14, 15, 16, 17].span(),
        );
        let expected = HeadSlot {
            schedule: s,
            task_count: 3,
            condition_count: 7,
            defined: true,
            retired: false,
            live_dependents: 0,
        };
        assert!(definition == expected);
        assert!(quest_tasks == tasks(task(1, 5), task(2, 6), task(3, 0xffffffff)));
        assert!(quest_conditions == ids(11, 12, 13, 14, 15, 16, 17));
    }

    #[test]
    #[available_gas(l2_gas: 31878)]
    fn definition_new_unused_slots_are_zero() {
        let (definition, quest_tasks, quest_conditions) = definition_slots(
            Q, daily(), array![task(1, 5), task(2, 6)].span(), array![3, 4].span(),
        );
        assert!(definition.task_count == 2);
        assert!(definition.condition_count == 2);
        assert!(quest_tasks == tasks(task(1, 5), task(2, 6), task(0, 0)));
        assert!(quest_conditions == ids(3, 4, 0, 0, 0, 0, 0));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid id')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_invalid_id() {
        definition_slots(0, one_off(), array![task(1, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid window')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_invalid_window() {
        definition_slots(Q, schedule(100, 100, 0, 0), array![task(1, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_duration_above_interval() {
        definition_slots(Q, schedule(0, 0, 2, 1), array![task(1, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_half_recurring() {
        definition_slots(Q, schedule(0, 0, 0, DAY), array![task(1, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_no_task() {
        define(array![].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 8201)]
    fn quest_define_rejects_more_than_three_tasks() {
        define(array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 11876)]
    fn quest_define_rejects_task_zero() {
        define(array![task(1, 1), task(0, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 12926)]
    fn quest_define_rejects_total_zero() {
        define(array![task(1, 1), task(2, 1), task(3, 0)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 13314)]
    fn quest_define_rejects_repeated_task() {
        define(array![task(1, 1), task(1, 2)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 14259)]
    fn quest_define_rejects_repeated_task_first_and_last() {
        define(array![task(1, 1), task(2, 1), task(1, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid tasks')]
    #[available_gas(l2_gas: 13136)]
    fn quest_define_rejects_repeated_task_second_and_last() {
        define(array![task(1, 1), task(2, 1), task(2, 1)].span(), array![].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: too many conditions')]
    #[available_gas(l2_gas: 11361)]
    fn quest_define_rejects_too_many_conditions() {
        define(array![task(1, 1)].span(), array![1, 2, 3, 4, 5, 6, 7, 8].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid condition')]
    #[available_gas(l2_gas: 20948)]
    fn quest_define_rejects_condition_zero() {
        define(array![task(1, 1)].span(), array![1, 0].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid condition')]
    #[available_gas(l2_gas: 14994)]
    fn quest_define_rejects_self_condition() {
        define(array![task(1, 1)].span(), array![Q].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid condition')]
    #[available_gas(l2_gas: 27216)]
    fn quest_define_rejects_duplicate_condition() {
        define(array![task(1, 1)].span(), array![5, 5].span());
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid condition')]
    #[available_gas(l2_gas: 124394)]
    fn quest_define_rejects_duplicate_condition_far_apart() {
        define(array![task(1, 1)].span(), array![1, 2, 3, 4, 5, 6, 1].span());
    }

    // tasks_index_of, tasks_span, conditions_span

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn tasks_index_of_finds_used_slots_only() {
        let t = tasks(task(4, 1), task(5, 1), task(6, 1));
        assert!(TasksSlotTrait::index_of(@t, 3, 4) == Some(0));
        assert!(TasksSlotTrait::index_of(@t, 3, 5) == Some(1));
        assert!(TasksSlotTrait::index_of(@t, 3, 6) == Some(2));
        assert!(TasksSlotTrait::index_of(@t, 3, 7) == None);
        assert!(TasksSlotTrait::index_of(@t, 2, 6) == None);
        assert!(TasksSlotTrait::index_of(@t, 1, 5) == None);
        // task id 0 never matches an unused slot
        assert!(TasksSlotTrait::index_of(@one_task(4, 1), 1, 0) == None);
    }

    #[test]
    #[available_gas(l2_gas: 37149)]
    fn tasks_span_has_task_count_entries() {
        let t = tasks(task(4, 1), task(5, 2), task(6, 3));
        assert!(TasksSlotTrait::tasks(@t, 0) == array![].span());
        assert!(TasksSlotTrait::tasks(@t, 1) == array![task(4, 1)].span());
        assert!(TasksSlotTrait::tasks(@t, 2) == array![task(4, 1), task(5, 2)].span());
        assert!(TasksSlotTrait::tasks(@t, 3) == array![task(4, 1), task(5, 2), task(6, 3)].span());
    }

    #[test]
    #[available_gas(l2_gas: 101535)]
    fn conditions_span_has_count_entries() {
        let c = ids(1, 2, 3, 4, 5, 6, 7);
        assert!(ConditionsSlotTrait::ids(@c, 0) == array![].span());
        assert!(ConditionsSlotTrait::ids(@c, 1) == array![1].span());
        assert!(ConditionsSlotTrait::ids(@c, 2) == array![1, 2].span());
        assert!(ConditionsSlotTrait::ids(@c, 3) == array![1, 2, 3].span());
        assert!(ConditionsSlotTrait::ids(@c, 4) == array![1, 2, 3, 4].span());
        assert!(ConditionsSlotTrait::ids(@c, 5) == array![1, 2, 3, 4, 5].span());
        assert!(ConditionsSlotTrait::ids(@c, 6) == array![1, 2, 3, 4, 5, 6].span());
        assert!(ConditionsSlotTrait::ids(@c, 7) == array![1, 2, 3, 4, 5, 6, 7].span());
    }

    #[test]
    #[available_gas(l2_gas: 66780)]
    fn definition_new_round_trips_through_the_spans() {
        let task_list = array![task(9, 3), task(8, 2)].span();
        let condition_list = array![30, 20, 10].span();
        let (definition, quest_tasks, quest_conditions) = definition_slots(
            Q, daily(), task_list, condition_list,
        );
        assert!(TasksSlotTrait::tasks(@quest_tasks, definition.task_count) == task_list);
        assert!(
            ConditionsSlotTrait::ids(
                @quest_conditions, definition.condition_count,
            ) == condition_list,
        );
    }

    fn one(task_id: u32) -> Span<QuestTask> {
        array![task(task_id, 1)].span()
    }

    fn new(tasks: Span<QuestTask>, conditions: Span<u32>) -> QuestDefinition {
        DefinitionTrait::new(1, one_off(), tasks, conditions)
    }

    // Constructor and checks

    #[test]
    #[available_gas(l2_gas: 171675)]
    fn definition_new_keeps_its_inputs() {
        let tasks = array![task(8, 5), task(9, 6), task(10, 7)].span();
        let conditions = array![2, 3, 4, 5, 6, 7, 8].span();
        let definition = DefinitionTrait::new(1, schedule(10, 20, 3, 4), tasks, conditions);
        assert!(definition.id == 1);
        assert!(definition.schedule == schedule(10, 20, 3, 4));
        assert!(definition.tasks == tasks && definition.conditions == conditions);
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn definition_errors_are_those_of_0_1_0() {
        assert!(definition_errors::DEFINITION_INVALID_ID == errors::INVALID_ID);
        assert!(schedule_errors::SCHEDULE_INVALID_WINDOW == errors::INVALID_WINDOW);
        assert!(schedule_errors::SCHEDULE_INVALID_INTERVAL == errors::INVALID_INTERVAL);
        assert!(definition_errors::DEFINITION_INVALID_TASKS == errors::INVALID_TASKS);
        assert!(definition_errors::DEFINITION_TOO_MANY_CONDITIONS == errors::TOO_MANY_CONDITIONS);
        assert!(definition_errors::DEFINITION_INVALID_CONDITION == errors::INVALID_CONDITION);
        assert!(definition_errors::DEFINITION_ALREADY_DEFINED == errors::ALREADY_DEFINED);
        assert!(definition_errors::DEFINITION_NOT_EXIST == errors::DOES_NOT_EXIST);
    }

    /// The id first, before a window that is also invalid.
    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid id')]
    fn definition_rejects_id_zero_first() {
        DefinitionTrait::new(0, schedule(5, 5, 0, 0), array![].span(), array![0].span());
    }

    /// The window before the interval, the tasks and the conditions.
    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid window')]
    fn definition_rejects_window_second() {
        DefinitionTrait::new(1, schedule(5, 5, 1, 0), array![].span(), array![0].span());
    }

    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid interval')]
    fn definition_rejects_duration_above_interval() {
        DefinitionTrait::new(1, schedule(0, 0, 5, 4), one(1), array![].span());
    }

    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid interval')]
    fn definition_rejects_half_recurring() {
        DefinitionTrait::new(1, schedule(0, 0, 0, 4), one(1), array![].span());
    }

    /// The tasks before the conditions.
    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid tasks')]
    fn definition_rejects_no_task() {
        new(array![].span(), array![0, 0, 0, 0, 0, 0, 0, 0].span());
    }

    #[test]
    #[available_gas(l2_gas: 8201)]
    #[should_panic(expected: 'Quest: invalid tasks')]
    fn definition_rejects_four_tasks() {
        new(array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span(), array![].span());
    }

    #[test]
    #[available_gas(l2_gas: 9146)]
    #[should_panic(expected: 'Quest: invalid tasks')]
    fn definition_rejects_task_zero() {
        new(array![task(1, 1), task(0, 1)].span(), array![].span());
    }

    #[test]
    #[available_gas(l2_gas: 10301)]
    #[should_panic(expected: 'Quest: invalid tasks')]
    fn definition_rejects_total_zero() {
        new(array![task(1, 1), task(2, 1), task(3, 0)].span(), array![].span());
    }

    #[test]
    #[available_gas(l2_gas: 10931)]
    #[should_panic(expected: 'Quest: invalid tasks')]
    fn definition_rejects_repeated_task() {
        new(array![task(1, 1), task(2, 1), task(2, 3)].span(), array![].span());
    }

    /// The count before the ids.
    #[test]
    #[available_gas(l2_gas: 8736)]
    #[should_panic(expected: 'Quest: too many conditions')]
    fn definition_rejects_eight_conditions() {
        new(one(1), array![0, 0, 0, 0, 0, 0, 0, 0].span());
    }

    #[test]
    #[available_gas(l2_gas: 17693)]
    #[should_panic(expected: 'Quest: invalid condition')]
    fn definition_rejects_condition_zero() {
        new(one(1), array![2, 0].span());
    }

    #[test]
    #[available_gas(l2_gas: 17787)]
    #[should_panic(expected: 'Quest: invalid condition')]
    fn definition_rejects_self_condition() {
        new(one(1), array![2, 1].span());
    }

    #[test]
    #[available_gas(l2_gas: 119564)]
    #[should_panic(expected: 'Quest: invalid condition')]
    fn definition_rejects_repeated_condition() {
        new(one(1), array![2, 3, 4, 5, 6, 7, 2].span());
    }

    #[test]
    #[available_gas(l2_gas: 12842)]
    fn definition_exists_with_its_tasks() {
        let definition = new(one(1), array![].span());
        DefinitionAssert::assert_does_exist(@definition);
        let undefined = DefinitionStorage::from_slots(1, zero_a(), zero_b(), zero_c());
        DefinitionAssert::assert_does_not_exist(@undefined);
    }

    #[test]
    #[available_gas(l2_gas: 8799)]
    #[should_panic(expected: 'Quest: does not exist')]
    fn definition_undefined_does_not_exist() {
        let undefined = DefinitionStorage::from_slots(1, zero_a(), zero_b(), zero_c());
        DefinitionAssert::assert_does_exist(@undefined);
    }

    #[test]
    #[available_gas(l2_gas: 12453)]
    #[should_panic(expected: 'Quest: already defined')]
    fn definition_defined_already_exists() {
        DefinitionAssert::assert_does_not_exist(@new(one(1), array![].span()));
    }

    // Behaviour, against `schedule_is_active` and `schedule_interval_id`

    #[test]
    #[available_gas(l2_gas: 1755873)]
    fn definition_schedule_matches_the_oracle() {
        let schedules = array![
            one_off(), schedule(100, 0, 0, 0), schedule(0, 500, 0, 0), schedule(100, 500, 0, 0),
            schedule(0, 0, 10, 60), schedule(100, 0, 10, 60), schedule(100, 500, 60, 60),
            schedule(0xffffffffffff0000, 0, 0xffffffff, 0xffffffff),
        ];
        let times: Array<u64> = array![
            0, 1, 9, 10, 59, 60, 99, 100, 109, 110, 159, 160, 499, 500, 501, 0xffffffffffff0000,
            0xffffffffffffffff,
        ];
        for schedule in schedules {
            let definition = DefinitionTrait::new(1, schedule, one(1), array![].span());
            for time in times.span() {
                let time = *time;
                assert!(definition.is_active(time) == schedule_is_active(@schedule, time));
                assert!(definition.interval_id(time) == schedule_interval_id(@schedule, time));
            }
        }
    }

    // Storage, against the slots of `definition_new`

    fn zero_a() -> DefinitionSlot {
        DefinitionSlot {
            schedule: one_off(),
            task_count: 0,
            condition_count: 0,
            defined: false,
            retired: false,
            live_dependents: 0,
        }
    }

    fn zero_b() -> TasksSlot {
        TasksSlot { t0: task(0, 0), t1: task(0, 0), t2: task(0, 0) }
    }

    fn zero_c() -> ConditionsSlot {
        ConditionsSlot { q0: 0, q1: 0, q2: 0, q3: 0, q4: 0, q5: 0, q6: 0 }
    }

    /// For 1 to 3 tasks and 0 to 7 conditions: the slots are those of 0.1.0, and read back as the
    /// model.
    #[test]
    #[available_gas(l2_gas: 4408940)]
    fn definition_storage_is_the_layout_of_0_1_0() {
        let all_tasks = array![task(8, 5), task(9, 6), task(10, 7)].span();
        let all_conditions = array![2, 3, 4, 5, 6, 7, 8].span();
        let sched = schedule(10, 20, 3, 4);
        let mut task_count = 1;
        while task_count <= 3 {
            let mut condition_count = 0;
            while condition_count <= 7 {
                let tasks = all_tasks.slice(0, task_count);
                let conditions = all_conditions.slice(0, condition_count);
                let definition = DefinitionTrait::new(1, sched, tasks, conditions);
                let slots = DefinitionStorage::into_slots(@definition);
                assert!(slots == definition_new(1, sched, tasks, conditions));
                let (slot_a, slot_b, slot_c) = slots;
                assert!(DefinitionStorage::from_slots(1, slot_a, slot_b, slot_c) == definition);
                condition_count += 1;
            }
            task_count += 1;
        }
    }

    /// A status in A (retired, live dependents) is not part of the model: it reads the same.
    #[test]
    #[available_gas(l2_gas: 47355)]
    fn definition_reads_the_same_whatever_the_status() {
        let definition = new(one(1), array![2].span());
        let (slot_a, slot_b, slot_c) = DefinitionStorage::into_slots(@definition);
        let slot_a = DefinitionSlot { retired: true, live_dependents: 0xffff, ..slot_a };
        assert!(DefinitionStorage::from_slots(1, slot_a, slot_b, slot_c) == definition);
    }

    #[test]
    #[available_gas(l2_gas: 8904)]
    fn definition_undefined_reads_with_no_task() {
        let undefined = DefinitionStorage::from_slots(5, zero_a(), zero_b(), zero_c());
        assert!(undefined.id == 5 && undefined.tasks.len() == 0 && undefined.conditions.len() == 0);
    }

    // Tracked

    #[test]
    #[available_gas(l2_gas: 33863)]
    fn definition_event_carries_its_key_and_values() {
        let tasks = array![task(8, 5), task(9, 6)].span();
        let conditions = array![2].span();
        let definition = DefinitionTrait::new(1, schedule(10, 20, 3, 4), tasks, conditions);
        let event: QuestDefined = DefinitionTracked::event(@definition);
        assert!(
            event == QuestDefined {
                quest_id: 1, schedule: schedule(10, 20, 3, 4), tasks, conditions,
            },
        );
    }

    fn seven_ids() -> ConditionsSlot {
        opaque(ids(1, 2, 3, 4, 5, 6, 7))
    }

    // definition

    #[test]
    #[available_gas(l2_gas: 148544)]
    fn bench_definition_new_three_tasks_seven_conditions() {
        let (definition, _, _) = definition_slots(
            opaque(100),
            recurring(),
            opaque(array![task(1, 5), task(2, 6), task(3, 7)].span()),
            opaque(array![11, 12, 13, 14, 15, 16, 17].span()),
        );
        assert!(definition.condition_count == 7);
    }

    #[test]
    #[available_gas(l2_gas: 13671)]
    fn bench_tasks_index_of_absent() {
        assert!(TasksSlotTrait::index_of(@three_tasks(), opaque(3), opaque(99)) == None);
    }

    #[test]
    #[available_gas(l2_gas: 12831)]
    fn bench_tasks_span_three() {
        assert!(TasksSlotTrait::tasks(@three_tasks(), opaque(3)).len() == 3);
    }

    #[test]
    #[available_gas(l2_gas: 12296)]
    fn bench_conditions_span_seven() {
        assert!(ConditionsSlotTrait::ids(@seven_ids(), opaque(7)).len() == 7);
    }

    // packing: pack then unpack, every field at its maximum

    #[test]
    #[available_gas(l2_gas: 34367)]
    fn bench_pack_unpack_definition() {
        let d = opaque(
            HeadSlot {
                schedule: schedule(U64_MAX, U64_MAX, U32_MAX, U32_MAX),
                task_count: 3,
                condition_count: 7,
                defined: true,
                retired: true,
                live_dependents: 0xffff,
            },
        );
        let packed = StorePacking::<HeadSlot, felt252>::pack(d);
        assert!(StorePacking::<HeadSlot, felt252>::unpack(opaque(packed)) == d);
    }

    #[test]
    #[available_gas(l2_gas: 24738)]
    fn bench_pack_unpack_tasks() {
        let t = opaque(
            tasks(task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX)),
        );
        let packed = StorePacking::<TasksSlot, felt252>::pack(t);
        assert!(StorePacking::<TasksSlot, felt252>::unpack(opaque(packed)) == t);
    }

    #[test]
    #[available_gas(l2_gas: 29180)]
    fn bench_pack_unpack_conditions() {
        let m = U32_MAX;
        let c = opaque(ids(m, m, m, m, m, m, m));
        let packed = StorePacking::<ConditionsSlot, felt252>::pack(c);
        assert!(StorePacking::<ConditionsSlot, felt252>::unpack(opaque(packed)) == c);
    }

    fn definition(
        start: u64,
        end: u64,
        duration: u32,
        interval: u32,
        task_count: u8,
        condition_count: u8,
        defined: bool,
        retired: bool,
        live_dependents: u16,
    ) -> HeadSlot {
        HeadSlot {
            schedule: schedule(start, end, duration, interval),
            task_count,
            condition_count,
            defined,
            retired,
            live_dependents,
        }
    }

    // HeadSlot (slot A)

    #[test]
    #[available_gas(l2_gas: 2499777)]
    fn quest_packing_round_trip_definition_zero() {
        let zero = definition(0, 0, 0, 0, 0, 0, false, false, 0);
        check_definition(zero);
        assert!(StorePacking::<HeadSlot, felt252>::pack(zero) == 0);
    }

    #[test]
    #[available_gas(l2_gas: 24934319)]
    fn quest_packing_round_trip_definition_max() {
        check_definition(definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, true, 0xffff));
        // each field alone at its maximum
        check_definition(definition(U64_MAX, 0, 0, 0, 0, 0, false, false, 0));
        check_definition(definition(0, U64_MAX, 0, 0, 0, 0, false, false, 0));
        check_definition(definition(0, 0, U32_MAX, 0, 0, 0, false, false, 0));
        check_definition(definition(0, 0, 0, U32_MAX, 0, 0, false, false, 0));
        check_definition(definition(0, 0, 0, 0, 3, 0, false, false, 0));
        check_definition(definition(0, 0, 0, 0, 0, 7, false, false, 0));
        check_definition(definition(0, 0, 0, 0, 0, 0, true, false, 0));
        check_definition(definition(0, 0, 0, 0, 0, 0, false, true, 0));
        check_definition(definition(0, 0, 0, 0, 0, 0, false, false, 0xffff));
    }

    #[test]
    #[available_gas(l2_gas: 7484988)]
    fn quest_packing_round_trip_definition_mixed() {
        check_definition(
            definition(
                0x0123456789abcdef, 0xfedcba9876543210, 86400, 604800, 2, 5, true, false, 0x1234,
            ),
        );
        check_definition(definition(1700000000, 0, 3600, 86400, 1, 0, true, false, 3));
        check_definition(definition(0x8000000000000001, 1, 1, 0x80000001, 3, 1, true, true, 1));
    }

    #[test]
    #[available_gas(l2_gas: 1157583)]
    fn quest_packing_presence_bits_at_their_positions() {
        let defined = definition(0, 0, 0, 0, 0, 0, true, false, 0);
        assert!(StorePacking::<HeadSlot, felt252>::pack(defined) == to_felt(pow2(197)));
        let retired = definition(0, 0, 0, 0, 0, 0, false, true, 0);
        assert!(StorePacking::<HeadSlot, felt252>::pack(retired) == to_felt(pow2(198)));
        let packed = StorePacking::<
            HeadSlot, felt252,
        >::pack(definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, false, 0xffff));
        assert!(get(packed, 197, 1) == 1);
        assert!(get(packed, 198, 1) == 0);
    }

    #[test]
    #[available_gas(l2_gas: 28844)]
    fn quest_empty_slot_reads_undefined() {
        let empty = StorePacking::<HeadSlot, felt252>::unpack(0);
        assert!(!empty.defined);
        assert!(!empty.retired);
        assert!(empty == definition(0, 0, 0, 0, 0, 0, false, false, 0));
    }

    // TasksSlot (slot B)

    #[test]
    #[available_gas(l2_gas: 15883161)]
    fn quest_packing_round_trip_tasks() {
        check_tasks(tasks(task(0, 0), task(0, 0), task(0, 0)));
        check_tasks(tasks(task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX)));
        check_tasks(tasks(task(U32_MAX, 0), task(0, 0), task(0, 0)));
        check_tasks(tasks(task(0, U32_MAX), task(0, 0), task(0, 0)));
        check_tasks(tasks(task(0, 0), task(U32_MAX, 0), task(0, 0)));
        check_tasks(tasks(task(0, 0), task(0, U32_MAX), task(0, 0)));
        check_tasks(tasks(task(0, 0), task(0, 0), task(U32_MAX, 0)));
        check_tasks(tasks(task(0, 0), task(0, 0), task(0, U32_MAX)));
        check_tasks(tasks(task(0x12345678, 10), task(0x9abcdef0, 1), task(7, 0x80000000)));
        assert!(
            StorePacking::<
                TasksSlot, felt252,
            >::pack(tasks(task(0, 0), task(0, 0), task(0, 0))) == 0,
        );
    }

    // ConditionsSlot (slot C)

    #[test]
    #[available_gas(l2_gas: 20224796)]
    fn quest_packing_round_trip_conditions() {
        check_conditions(ids(0, 0, 0, 0, 0, 0, 0));
        let m = U32_MAX;
        check_conditions(ids(m, m, m, m, m, m, m));
        check_conditions(ids(m, 0, 0, 0, 0, 0, 0));
        check_conditions(ids(0, m, 0, 0, 0, 0, 0));
        check_conditions(ids(0, 0, m, 0, 0, 0, 0));
        check_conditions(ids(0, 0, 0, m, 0, 0, 0));
        check_conditions(ids(0, 0, 0, 0, m, 0, 0));
        check_conditions(ids(0, 0, 0, 0, 0, m, 0));
        check_conditions(ids(0, 0, 0, 0, 0, 0, m));
        check_conditions(ids(1, 0x80000000, 0x12345678, 3, 0xdeadbeef, 0x7fffffff, 42));
    }

    // Fix loop 1: packing never lets a field spill into its neighbour (§3.3 widths), and unpacking
    // rejects a felt the package did not write (a bit set outside the encoding).

    fn pack_definition(d: HeadSlot) -> felt252 {
        StorePacking::<HeadSlot, felt252>::pack(d)
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 8201)]
    fn quest_packing_rejects_task_count_4() {
        pack_definition(definition(0, 0, 0, 0, 4, 0, true, false, 0));
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 8201)]
    fn quest_packing_rejects_task_count_255() {
        pack_definition(definition(0, 0, 0, 0, 255, 0, true, false, 0));
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 8201)]
    fn quest_packing_rejects_condition_count_8() {
        pack_definition(definition(0, 0, 0, 0, 1, 8, true, false, 0));
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 8201)]
    fn quest_packing_rejects_condition_count_16() {
        // 8 = 2^3 would have set `defined` (bit 197); 16 = 2^4 `retired` (bit 198)
        pack_definition(definition(0, 0, 0, 0, 1, 16, false, false, 0));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 438281)]
    fn quest_unpacking_rejects_definition_bit_215() {
        StorePacking::<HeadSlot, felt252>::unpack(to_felt(pow2(215)));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 25064)]
    fn quest_unpacking_rejects_definition_felt_minus_one() {
        StorePacking::<HeadSlot, felt252>::unpack(-1);
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 369107)]
    fn quest_unpacking_rejects_tasks_bit_192() {
        StorePacking::<TasksSlot, felt252>::unpack(to_felt(pow2(192)));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 388017)]
    fn quest_unpacking_rejects_conditions_bit_224() {
        StorePacking::<ConditionsSlot, felt252>::unpack(to_felt(pow2(224)));
    }

    #[test]
    #[available_gas(l2_gas: 5101194)]
    fn quest_packing_accepts_the_bounds() {
        check_definition(definition(0, 0, 0, 0, 3, 7, true, false, 0));
        check_held_slot(held_slot(held(1, 2), held(3, 4)));
    }
}
