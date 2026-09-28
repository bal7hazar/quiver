//! Definitions: validation and the three slots A, B, C (ARC-01 §3.2).

use crate::constants::{MAX_CONDITIONS, MAX_TASKS};
use crate::errors;
use super::schedule::schedule_validate;
use super::types::{QuestConditions, QuestDefinition, QuestSchedule, QuestTask, QuestTasks};

const NO_TASK: QuestTask = QuestTask { task_id: 0, total: 0 };

/// Validates a quest and builds its slots A, B and C; unused entries of B and C are zero.
///
/// Panics, in this order: `'Quest: invalid id'` (`quest_id == 0`); those of
/// `schedule_validate`; `'Quest: invalid tasks'` (none, more than `MAX_TASKS`, a task id 0, a
/// total 0, a task id repeated); `'Quest: too many conditions'` (more than `MAX_CONDITIONS`);
/// `'Quest: invalid condition'` (a condition 0, `== quest_id`, or repeated). That each
/// condition exists is checked by the component, which has storage.
pub fn definition_new(
    quest_id: u32,
    schedule: QuestSchedule,
    tasks: Span<QuestTask>,
    conditions: Span<u32>,
    needs_accept: bool,
) -> (QuestDefinition, QuestTasks, QuestConditions) {
    assert(quest_id != 0, errors::INVALID_ID);
    schedule_validate(@schedule);
    let quest_tasks = tasks_new(tasks);
    let quest_conditions = conditions_new(quest_id, conditions);
    let definition = QuestDefinition {
        schedule,
        task_count: tasks.len().try_into().unwrap(),
        condition_count: conditions.len().try_into().unwrap(),
        needs_accept,
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

/// Slot B from 1 to 3 tasks, unrolled: at most 3 comparisons for repeats.
fn tasks_new(tasks: Span<QuestTask>) -> QuestTasks {
    let len = tasks.len();
    assert(len != 0 && len <= MAX_TASKS.into(), errors::INVALID_TASKS);
    let t0 = *tasks[0];
    assert_task(t0);
    if len == 1 {
        return QuestTasks { t0, t1: NO_TASK, t2: NO_TASK };
    }
    let t1 = *tasks[1];
    assert_task(t1);
    assert(t1.task_id != t0.task_id, errors::INVALID_TASKS);
    if len == 2 {
        return QuestTasks { t0, t1, t2: NO_TASK };
    }
    let t2 = *tasks[2];
    assert_task(t2);
    assert(t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::INVALID_TASKS);
    QuestTasks { t0, t1, t2 }
}

/// Slot C from 0 to 7 conditions. Repeats are found by comparing each id with those before it:
/// at most 21 comparisons, bounded by `MAX_CONDITIONS` (checked first).
fn conditions_new(quest_id: u32, conditions: Span<u32>) -> QuestConditions {
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
    QuestConditions {
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

/// The index among the first `task_count` tasks of `task_id`, if any.
pub fn tasks_index_of(tasks: @QuestTasks, task_count: u8, task_id: u32) -> Option<u8> {
    let tasks = *tasks;
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

/// The first `task_count` tasks (at most 3).
pub fn tasks_span(tasks: @QuestTasks, task_count: u8) -> Span<QuestTask> {
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

/// The first `count` ids (at most 7).
pub fn conditions_span(conditions: @QuestConditions, count: u8) -> Span<u32> {
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
