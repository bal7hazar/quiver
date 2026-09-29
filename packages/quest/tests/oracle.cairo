//! 0.1.0's functions of `quiver_quest::logic` that the models of 0.2.0 replace, kept verbatim in
//! the tests (ARC-07a) as oracles (docs/CAIRO.md §2) and as the hand-written baseline of the
//! store's benchmarks (ARC-06): the definition's slots, the schedule, and the reads of slots B and
//! C. Only the names of the slot types changed.

use quiver_quest::constants::{MAX_CONDITIONS, MAX_TASKS};
use quiver_quest::errors;
use quiver_quest::models::definition::{ConditionsSlot, HeadSlot, TasksSlot};
use quiver_quest::types::schedule::QuestSchedule;
use quiver_quest::types::task::QuestTask;

const NO_TASK: QuestTask = QuestTask { task_id: 0, total: 0 };

/// 0.1.0's `definition_new`: validates a quest and builds its slots A, B and C.
pub fn definition_new(
    quest_id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>, conditions: Span<u32>,
) -> (HeadSlot, TasksSlot, ConditionsSlot) {
    assert(quest_id != 0, errors::INVALID_ID);
    schedule_validate(@schedule);
    let quest_tasks = tasks_new(tasks);
    let quest_conditions = conditions_new(quest_id, conditions);
    let definition = HeadSlot {
        schedule,
        task_count: tasks.len().try_into().unwrap(),
        condition_count: conditions.len().try_into().unwrap(),
        defined: true,
        retired: false,
        live_dependents: 0,
    };
    (definition, quest_tasks, quest_conditions)
}

#[inline(always)]
fn assert_task(task: QuestTask) {
    assert(task.task_id != 0 && task.total != 0, errors::INVALID_TASKS);
}

fn tasks_new(tasks: Span<QuestTask>) -> TasksSlot {
    let len = tasks.len();
    assert(len != 0 && len <= MAX_TASKS.into(), errors::INVALID_TASKS);
    let t0 = *tasks[0];
    assert_task(t0);
    if len == 1 {
        return TasksSlot { t0, t1: NO_TASK, t2: NO_TASK };
    }
    let t1 = *tasks[1];
    assert_task(t1);
    assert(t1.task_id != t0.task_id, errors::INVALID_TASKS);
    if len == 2 {
        return TasksSlot { t0, t1, t2: NO_TASK };
    }
    let t2 = *tasks[2];
    assert_task(t2);
    assert(t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::INVALID_TASKS);
    TasksSlot { t0, t1, t2 }
}

fn conditions_new(quest_id: u32, conditions: Span<u32>) -> ConditionsSlot {
    let len = conditions.len();
    assert(len <= MAX_CONDITIONS.into(), errors::TOO_MANY_CONDITIONS);
    let mut i = 0;
    while i < len {
        let id = *conditions[i];
        assert(id != 0 && id != quest_id, errors::INVALID_CONDITION);
        let mut j = 0;
        while j < i {
            assert(*conditions[j] != id, errors::INVALID_CONDITION);
            j += 1;
        }
        i += 1;
    }
    ConditionsSlot {
        q0: id_at(conditions, 0),
        q1: id_at(conditions, 1),
        q2: id_at(conditions, 2),
        q3: id_at(conditions, 3),
        q4: id_at(conditions, 4),
        q5: id_at(conditions, 5),
        q6: id_at(conditions, 6),
    }
}

#[inline(always)]
fn id_at(ids: Span<u32>, index: u32) -> u32 {
    match ids.get(index) {
        Option::Some(id) => *id.unbox(),
        Option::None => 0,
    }
}

/// 0.1.0's `tasks_span`: the first `task_count` tasks.
pub fn tasks_span(tasks: @TasksSlot, task_count: u8) -> Span<QuestTask> {
    let tasks = *tasks;
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

/// 0.1.0's `conditions_span`: the first `count` ids.
pub fn conditions_span(conditions: @ConditionsSlot, count: u8) -> Span<u32> {
    let ids = *conditions;
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

/// 0.1.0's `schedule_validate`.
pub fn schedule_validate(schedule: @QuestSchedule) {
    let schedule = *schedule;
    assert(schedule.end == 0 || schedule.end > schedule.start, errors::INVALID_WINDOW);
    let valid_interval = if schedule.duration == 0 {
        schedule.interval == 0
    } else {
        schedule.duration <= schedule.interval
    };
    assert(valid_interval, errors::INVALID_INTERVAL);
}

/// 0.1.0's `schedule_is_active`.
pub fn schedule_is_active(schedule: @QuestSchedule, time: u64) -> bool {
    let schedule = *schedule;
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

/// 0.1.0's `schedule_interval_id`.
pub fn schedule_interval_id(schedule: @QuestSchedule, time: u64) -> Option<u64> {
    let schedule = *schedule;
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
