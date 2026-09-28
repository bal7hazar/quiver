use quiver_quest::logic::{
    QuestDefinition, QuestTask, conditions_span, definition_new, tasks_index_of, tasks_span,
};
use super::helpers::{DAY, daily, ids, no_ids, one_off, one_task, schedule, task, tasks};

const Q: u32 = 42;

fn define(tasks: Span<QuestTask>, conditions: Span<u32>) {
    definition_new(Q, one_off(), tasks, conditions, false);
}

// definition_new

#[test]
#[available_gas(l2_gas: 28466)]
fn definition_new_one_task() {
    let (definition, quest_tasks, quest_conditions) = definition_new(
        Q, one_off(), array![task(7, 10)].span(), array![].span(), false,
    );
    let expected = QuestDefinition {
        schedule: one_off(),
        task_count: 1,
        condition_count: 0,
        needs_accept: false,
        defined: true,
        retired: false,
        live_dependents: 0,
    };
    assert!(definition == expected);
    assert!(quest_tasks == one_task(7, 10));
    assert!(quest_conditions == no_ids());
}

#[test]
#[available_gas(l2_gas: 168767)]
fn definition_new_three_tasks_seven_conditions() {
    let s = schedule(100, 1000, 10, 60);
    let (definition, quest_tasks, quest_conditions) = definition_new(
        Q,
        s,
        array![task(1, 5), task(2, 6), task(3, 0xffffffff)].span(),
        array![11, 12, 13, 14, 15, 16, 17].span(),
        true,
    );
    let expected = QuestDefinition {
        schedule: s,
        task_count: 3,
        condition_count: 7,
        needs_accept: true,
        defined: true,
        retired: false,
        live_dependents: 0,
    };
    assert!(definition == expected);
    assert!(quest_tasks == tasks(task(1, 5), task(2, 6), task(3, 0xffffffff)));
    assert!(quest_conditions == ids(11, 12, 13, 14, 15, 16, 17));
}

#[test]
#[available_gas(l2_gas: 39470)]
fn definition_new_unused_slots_are_zero() {
    let (definition, quest_tasks, quest_conditions) = definition_new(
        Q, daily(), array![task(1, 5), task(2, 6)].span(), array![3, 4].span(), false,
    );
    assert!(definition.task_count == 2);
    assert!(definition.condition_count == 2);
    assert!(quest_tasks == tasks(task(1, 5), task(2, 6), task(0, 0)));
    assert!(quest_conditions == ids(3, 4, 0, 0, 0, 0, 0));
}

#[test]
#[should_panic(expected: 'Quest: invalid id')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_invalid_id() {
    definition_new(0, one_off(), array![task(1, 1)].span(), array![].span(), false);
}

#[test]
#[should_panic(expected: 'Quest: invalid window')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_invalid_window() {
    definition_new(Q, schedule(100, 100, 0, 0), array![task(1, 1)].span(), array![].span(), false);
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_duration_above_interval() {
    definition_new(Q, schedule(0, 0, 2, 1), array![task(1, 1)].span(), array![].span(), false);
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_half_recurring() {
    definition_new(Q, schedule(0, 0, 0, DAY), array![task(1, 1)].span(), array![].span(), false);
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_no_task() {
    define(array![].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 16296)]
fn quest_define_rejects_more_than_three_tasks() {
    define(array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 20076)]
fn quest_define_rejects_task_zero() {
    define(array![task(1, 1), task(0, 1)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 21126)]
fn quest_define_rejects_total_zero() {
    define(array![task(1, 1), task(2, 1), task(3, 0)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 21557)]
fn quest_define_rejects_repeated_task() {
    define(array![task(1, 1), task(1, 2)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 22607)]
fn quest_define_rejects_repeated_task_first_and_last() {
    define(array![task(1, 1), task(2, 1), task(1, 1)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid tasks')]
#[available_gas(l2_gas: 21336)]
fn quest_define_rejects_repeated_task_second_and_last() {
    define(array![task(1, 1), task(2, 1), task(2, 1)].span(), array![].span());
}

#[test]
#[should_panic(expected: 'Quest: too many conditions')]
#[available_gas(l2_gas: 19562)]
fn quest_define_rejects_too_many_conditions() {
    define(array![task(1, 1)].span(), array![1, 2, 3, 4, 5, 6, 7, 8].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid condition')]
#[available_gas(l2_gas: 28413)]
fn quest_define_rejects_condition_zero() {
    define(array![task(1, 1)].span(), array![1, 0].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid condition')]
#[available_gas(l2_gas: 22670)]
fn quest_define_rejects_self_condition() {
    define(array![task(1, 1)].span(), array![Q].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid condition')]
#[available_gas(l2_gas: 34682)]
fn quest_define_rejects_duplicate_condition() {
    define(array![task(1, 1)].span(), array![5, 5].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid condition')]
#[available_gas(l2_gas: 131859)]
fn quest_define_rejects_duplicate_condition_far_apart() {
    define(array![task(1, 1)].span(), array![1, 2, 3, 4, 5, 6, 1].span());
}

// tasks_index_of, tasks_span, conditions_span

#[test]
#[available_gas(l2_gas: 14406)]
fn tasks_index_of_finds_used_slots_only() {
    let t = tasks(task(4, 1), task(5, 1), task(6, 1));
    assert!(tasks_index_of(@t, 3, 4) == Some(0));
    assert!(tasks_index_of(@t, 3, 5) == Some(1));
    assert!(tasks_index_of(@t, 3, 6) == Some(2));
    assert!(tasks_index_of(@t, 3, 7) == None);
    assert!(tasks_index_of(@t, 2, 6) == None);
    assert!(tasks_index_of(@t, 1, 5) == None);
    // task id 0 never matches an unused slot
    assert!(tasks_index_of(@one_task(4, 1), 1, 0) == None);
}

#[test]
#[available_gas(l2_gas: 45371)]
fn tasks_span_has_task_count_entries() {
    let t = tasks(task(4, 1), task(5, 2), task(6, 3));
    assert!(tasks_span(@t, 0) == array![].span());
    assert!(tasks_span(@t, 1) == array![task(4, 1)].span());
    assert!(tasks_span(@t, 2) == array![task(4, 1), task(5, 2)].span());
    assert!(tasks_span(@t, 3) == array![task(4, 1), task(5, 2), task(6, 3)].span());
}

#[test]
#[available_gas(l2_gas: 109757)]
fn conditions_span_has_count_entries() {
    let c = ids(1, 2, 3, 4, 5, 6, 7);
    assert!(conditions_span(@c, 0) == array![].span());
    assert!(conditions_span(@c, 1) == array![1].span());
    assert!(conditions_span(@c, 2) == array![1, 2].span());
    assert!(conditions_span(@c, 3) == array![1, 2, 3].span());
    assert!(conditions_span(@c, 4) == array![1, 2, 3, 4].span());
    assert!(conditions_span(@c, 5) == array![1, 2, 3, 4, 5].span());
    assert!(conditions_span(@c, 6) == array![1, 2, 3, 4, 5, 6].span());
    assert!(conditions_span(@c, 7) == array![1, 2, 3, 4, 5, 6, 7].span());
}

#[test]
#[available_gas(l2_gas: 74372)]
fn definition_new_round_trips_through_the_spans() {
    let task_list = array![task(9, 3), task(8, 2)].span();
    let condition_list = array![30, 20, 10].span();
    let (definition, quest_tasks, quest_conditions) = definition_new(
        Q, daily(), task_list, condition_list, false,
    );
    assert!(tasks_span(@quest_tasks, definition.task_count) == task_list);
    assert!(conditions_span(@quest_conditions, definition.condition_count) == condition_list);
}
