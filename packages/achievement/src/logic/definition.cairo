//! Definitions: validation and the two slots A and B (ARC-01 §3.10).

use crate::constants::MAX_TASKS;
use crate::errors;
use super::types::{
    AchievementDefinition, AchievementExtraTasks, AchievementTask, AchievementWindow,
};
use super::window::window_validate;

const NO_TASK: AchievementTask = AchievementTask { task_id: 0, total: 0 };

/// Validates an achievement and builds its slots A and B; unused entries of B are zero.
///
/// Panics, in this order: `'Achievement: invalid id'` (`achievement_id == 0`); `'Achievement:
/// invalid window'` (`window_validate`); `'Achievement: invalid tasks'` (none, more than
/// `MAX_TASKS`, a task id 0, a total 0, a task id repeated). The same checks whatever the use of
/// the achievement (D-11).
pub fn definition_new(
    achievement_id: u32, window: AchievementWindow, tasks: Span<AchievementTask>,
) -> (AchievementDefinition, AchievementExtraTasks) {
    assert(achievement_id != 0, errors::INVALID_ID);
    window_validate(@window);
    let len = tasks.len();
    assert(len != 0 && len <= MAX_TASKS.into(), errors::INVALID_TASKS);
    let t0 = *tasks[0];
    assert_task(t0);
    let definition = AchievementDefinition {
        window, task_count: len.try_into().unwrap(), defined: true, retired: false, t0,
    };
    if len == 1 {
        return (definition, AchievementExtraTasks { t1: NO_TASK, t2: NO_TASK });
    }
    let t1 = *tasks[1];
    assert_task(t1);
    assert(t1.task_id != t0.task_id, errors::INVALID_TASKS);
    if len == 2 {
        return (definition, AchievementExtraTasks { t1, t2: NO_TASK });
    }
    let t2 = *tasks[2];
    assert_task(t2);
    assert(t2.task_id != t0.task_id && t2.task_id != t1.task_id, errors::INVALID_TASKS);
    (definition, AchievementExtraTasks { t1, t2 })
}

#[inline(always)]
fn assert_task(task: AchievementTask) {
    assert(task.task_id != 0 && task.total != 0, errors::INVALID_TASKS);
}

/// The first `task_count` tasks (at most 3): `t0` from A, then `t1` and `t2` from B.
pub fn tasks_span(
    definition: @AchievementDefinition, extra: @AchievementExtraTasks,
) -> Span<AchievementTask> {
    let task_count = *definition.task_count;
    let mut out = array![];
    if task_count > 0 {
        out.append(*definition.t0);
        if task_count > 1 {
            out.append(*extra.t1);
            if task_count > 2 {
                out.append(*extra.t2);
            }
        }
    }
    out.span()
}
