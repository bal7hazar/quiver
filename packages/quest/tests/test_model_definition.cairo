//! The model `QuestDefinition` (ARC-06): its constructor and checks, in the order and with the
//! strings of 0.1.0; its behaviour against 0.1.0's functions as oracles (`super::oracle`); its
//! storage against the slots of `definition_new`; its event.

use quiver_quest::component::QuestComponent::QuestDefined;
use quiver_quest::errors;
use quiver_quest::models::definition::{
    ConditionsSlot, DefinitionAssert, DefinitionStorage, DefinitionTracked, DefinitionTrait,
    HeadSlot as DefinitionSlot, QuestDefinition, TasksSlot, errors as definition_errors,
};
use quiver_quest::types::schedule::errors as schedule_errors;
use quiver_quest::types::task::QuestTask;
use super::helpers::{one_off, schedule, task};
use super::oracle::{definition_new, schedule_interval_id, schedule_is_active};

fn one(task_id: u32) -> Span<QuestTask> {
    array![task(task_id, 1)].span()
}

fn new(tasks: Span<QuestTask>, conditions: Span<u32>) -> QuestDefinition {
    DefinitionTrait::new(1, one_off(), tasks, conditions)
}

// Constructor and checks

#[test]
#[available_gas(l2_gas: 179897)]
fn definition_new_keeps_its_inputs() {
    let tasks = array![task(8, 5), task(9, 6), task(10, 7)].span();
    let conditions = array![2, 3, 4, 5, 6, 7, 8].span();
    let definition = DefinitionTrait::new(1, schedule(10, 20, 3, 4), tasks, conditions);
    assert!(definition.id == 1);
    assert!(definition.schedule == schedule(10, 20, 3, 4));
    assert!(definition.tasks == tasks && definition.conditions == conditions);
}

#[test]
#[available_gas(l2_gas: 14406)]
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
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid id')]
fn definition_rejects_id_zero_first() {
    DefinitionTrait::new(0, schedule(5, 5, 0, 0), array![].span(), array![0].span());
}

/// The window before the interval, the tasks and the conditions.
#[test]
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid window')]
fn definition_rejects_window_second() {
    DefinitionTrait::new(1, schedule(5, 5, 1, 0), array![].span(), array![0].span());
}

#[test]
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid interval')]
fn definition_rejects_duration_above_interval() {
    DefinitionTrait::new(1, schedule(0, 0, 5, 4), one(1), array![].span());
}

#[test]
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid interval')]
fn definition_rejects_half_recurring() {
    DefinitionTrait::new(1, schedule(0, 0, 0, 4), one(1), array![].span());
}

/// The tasks before the conditions.
#[test]
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid tasks')]
fn definition_rejects_no_task() {
    new(array![].span(), array![0, 0, 0, 0, 0, 0, 0, 0].span());
}

#[test]
#[available_gas(l2_gas: 16296)]
#[should_panic(expected: 'Quest: invalid tasks')]
fn definition_rejects_four_tasks() {
    new(array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span(), array![].span());
}

#[test]
#[available_gas(l2_gas: 17241)]
#[should_panic(expected: 'Quest: invalid tasks')]
fn definition_rejects_task_zero() {
    new(array![task(1, 1), task(0, 1)].span(), array![].span());
}

#[test]
#[available_gas(l2_gas: 18396)]
#[should_panic(expected: 'Quest: invalid tasks')]
fn definition_rejects_total_zero() {
    new(array![task(1, 1), task(2, 1), task(3, 0)].span(), array![].span());
}

#[test]
#[available_gas(l2_gas: 19026)]
#[should_panic(expected: 'Quest: invalid tasks')]
fn definition_rejects_repeated_task() {
    new(array![task(1, 1), task(2, 1), task(2, 3)].span(), array![].span());
}

/// The count before the ids.
#[test]
#[available_gas(l2_gas: 16832)]
#[should_panic(expected: 'Quest: too many conditions')]
fn definition_rejects_eight_conditions() {
    new(one(1), array![0, 0, 0, 0, 0, 0, 0, 0].span());
}

#[test]
#[available_gas(l2_gas: 25788)]
#[should_panic(expected: 'Quest: invalid condition')]
fn definition_rejects_condition_zero() {
    new(one(1), array![2, 0].span());
}

#[test]
#[available_gas(l2_gas: 25883)]
#[should_panic(expected: 'Quest: invalid condition')]
fn definition_rejects_self_condition() {
    new(one(1), array![2, 1].span());
}

#[test]
#[available_gas(l2_gas: 127659)]
#[should_panic(expected: 'Quest: invalid condition')]
fn definition_rejects_repeated_condition() {
    new(one(1), array![2, 3, 4, 5, 6, 7, 2].span());
}

#[test]
#[available_gas(l2_gas: 20937)]
fn definition_exists_with_its_tasks() {
    let definition = new(one(1), array![].span());
    DefinitionAssert::assert_does_exist(@definition);
    let undefined = DefinitionStorage::from_slots(1, zero_a(), zero_b(), zero_c());
    DefinitionAssert::assert_does_not_exist(@undefined);
}

#[test]
#[available_gas(l2_gas: 16895)]
#[should_panic(expected: 'Quest: does not exist')]
fn definition_undefined_does_not_exist() {
    let undefined = DefinitionStorage::from_slots(1, zero_a(), zero_b(), zero_c());
    DefinitionAssert::assert_does_exist(@undefined);
}

#[test]
#[available_gas(l2_gas: 20549)]
#[should_panic(expected: 'Quest: already defined')]
fn definition_defined_already_exists() {
    DefinitionAssert::assert_does_not_exist(@new(one(1), array![].span()));
}

// Behaviour, against `schedule_is_active` and `schedule_interval_id`

#[test]
#[available_gas(l2_gas: 1764095)]
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
#[available_gas(l2_gas: 4417035)]
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
#[available_gas(l2_gas: 55577)]
fn definition_reads_the_same_whatever_the_status() {
    let definition = new(one(1), array![2].span());
    let (slot_a, slot_b, slot_c) = DefinitionStorage::into_slots(@definition);
    let slot_a = DefinitionSlot { retired: true, live_dependents: 0xffff, ..slot_a };
    assert!(DefinitionStorage::from_slots(1, slot_a, slot_b, slot_c) == definition);
}

#[test]
#[available_gas(l2_gas: 17126)]
fn definition_undefined_reads_with_no_task() {
    let undefined = DefinitionStorage::from_slots(5, zero_a(), zero_b(), zero_c());
    assert!(undefined.id == 5 && undefined.tasks.len() == 0 && undefined.conditions.len() == 0);
}

// Tracked

#[test]
#[available_gas(l2_gas: 42084)]
fn definition_event_carries_its_key_and_values() {
    let tasks = array![task(8, 5), task(9, 6)].span();
    let conditions = array![2].span();
    let definition = DefinitionTrait::new(1, schedule(10, 20, 3, 4), tasks, conditions);
    let event: QuestDefined = DefinitionTracked::event(@definition);
    assert!(
        event == QuestDefined { quest_id: 1, schedule: schedule(10, 20, 3, 4), tasks, conditions },
    );
}
