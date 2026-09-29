//! `definition_new`, `tasks_span` and the windows (ARC-01 §3.10; D-11: the same validation for
//! every use).

use quiver_achievement::logic::{
    AchievementDefinition, AchievementExtraTasks, definition_new, tasks_span, window_is_active,
    window_validate,
};
use super::helpers::{U64_MAX, always, one, task, window};

#[test]
#[available_gas(l2_gas: 24003)]
fn definition_new_one_task_inline() {
    let (definition, extra) = definition_new(5, window(100, 200), one(7, 10));
    assert!(
        definition == AchievementDefinition {
            window: window(100, 200), task_count: 1, defined: true, retired: false, t0: task(7, 10),
        },
    );
    assert!(extra == AchievementExtraTasks { t1: task(0, 0), t2: task(0, 0) });
}

#[test]
#[available_gas(l2_gas: 41402)]
fn definition_new_three_tasks() {
    let tasks = array![task(1, 5), task(2, 6), task(3, 7)].span();
    let (definition, extra) = definition_new(5, always(), tasks);
    assert!(definition.task_count == 3);
    assert!(definition.t0 == task(1, 5));
    assert!(extra == AchievementExtraTasks { t1: task(2, 6), t2: task(3, 7) });
    assert!(tasks_span(@definition, @extra) == tasks);
}

#[test]
#[available_gas(l2_gas: 45623)]
fn tasks_span_has_task_count_entries() {
    let (d1, e1) = definition_new(1, always(), one(4, 1));
    assert!(tasks_span(@d1, @e1) == one(4, 1));
    let two = array![task(4, 1), task(9, 2)].span();
    let (d2, e2) = definition_new(1, always(), two);
    assert!(tasks_span(@d2, @e2) == two);
}

#[test]
#[should_panic(expected: 'Achievement: invalid id')]
#[available_gas(l2_gas: 16296)]
fn achievement_define_rejects_id_zero() {
    definition_new(0, always(), one(7, 1));
}

/// D-11: `end == start` is empty, refused.
#[test]
#[should_panic(expected: 'Achievement: invalid window')]
#[available_gas(l2_gas: 16296)]
fn definition_new_rejects_empty_window() {
    definition_new(5, window(100, 100), one(7, 1));
}

#[test]
#[should_panic(expected: 'Achievement: invalid window')]
#[available_gas(l2_gas: 16296)]
fn definition_new_rejects_end_before_start() {
    definition_new(5, window(100, 99), one(7, 1));
}

/// The id is checked before the window, the window before the tasks.
#[test]
#[should_panic(expected: 'Achievement: invalid id')]
#[available_gas(l2_gas: 16296)]
fn definition_new_checks_id_first() {
    definition_new(0, window(100, 100), array![].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid window')]
#[available_gas(l2_gas: 16296)]
fn definition_new_checks_window_before_tasks() {
    definition_new(5, window(100, 100), array![].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 16296)]
fn definition_new_rejects_no_task() {
    definition_new(5, always(), array![].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 16296)]
fn definition_new_rejects_four_tasks() {
    definition_new(5, always(), array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 17241)]
fn definition_new_rejects_task_id_zero() {
    definition_new(5, always(), array![task(1, 1), task(0, 1)].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 18396)]
fn definition_new_rejects_total_zero() {
    definition_new(5, always(), array![task(1, 1), task(2, 1), task(3, 0)].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 21966)]
fn definition_new_rejects_repeated_task() {
    definition_new(5, always(), array![task(1, 1), task(2, 1), task(1, 2)].span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid tasks')]
#[available_gas(l2_gas: 19971)]
fn definition_new_rejects_repeated_second_task() {
    definition_new(5, always(), array![task(2, 1), task(2, 3)].span());
}

#[test]
#[available_gas(l2_gas: 14406)]
fn window_validate_accepts_open_and_ordered_windows() {
    window_validate(@always());
    window_validate(@window(100, 0));
    window_validate(@window(0, 1));
    window_validate(@window(U64_MAX - 1, U64_MAX));
}

#[test]
#[available_gas(l2_gas: 16422)]
fn window_is_active_bounds() {
    let w = window(100, 200);
    assert!(!window_is_active(@w, 99));
    assert!(window_is_active(@w, 100));
    assert!(window_is_active(@w, 199));
    assert!(!window_is_active(@w, 200));
    assert!(window_is_active(@always(), 0));
    assert!(window_is_active(@always(), U64_MAX));
    assert!(window_is_active(@window(100, 0), U64_MAX));
    assert!(!window_is_active(@window(100, 0), 99));
}
