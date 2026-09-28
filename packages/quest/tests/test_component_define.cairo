//! `define` (ARC-01 §2 D-7, D-8, §3.5): validation with storage, pages, live dependents.

use quiver_quest::component::QuestComponent::{Event, QuestDefined};
use quiver_quest::constants::{MAX_PAGES, QUESTS_PER_PAGE};
use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait, IQuestViewSafeDispatcherTrait,
};
use quiver_quest::logic::{QuestDefinition, QuestTask};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{one_off, schedule, task};
use super::setup::{
    Quest, as_admin, assert_error, define, define_simple, deploy, retire, stop,
};

/// `define` as the admin through the safe dispatcher.
#[feature("safe_dispatcher")]
fn try_define(
    q: Quest, quest_id: u32, tasks: Span<QuestTask>, conditions: Span<u32>,
) -> Result<(), Array<felt252>> {
    as_admin(q);
    let result = q.safe.define(quest_id, one_off(), tasks, conditions, false);
    stop(q);
    result
}

fn one(task_id: u32) -> Span<QuestTask> {
    array![task(task_id, 1)].span()
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_stores_and_emits() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    let quest_schedule = schedule(100, 900, 10, 20);
    let tasks = array![task(5, 2), task(6, 3), task(7, 4)].span();
    let mut spy = spy_events();
    define(q, 2, quest_schedule, tasks, array![1].span(), true);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestDefined(
                        QuestDefined {
                            quest_id: 2,
                            schedule: quest_schedule,
                            tasks,
                            conditions: array![1].span(),
                            needs_accept: true,
                        },
                    ),
                ),
            ],
        );
    assert!(spy.get_events().events.len() == 1);
    let (definition, stored_tasks, conditions) = q.view.quest_definition(2);
    assert!(
        definition == QuestDefinition {
            schedule: quest_schedule,
            task_count: 3,
            condition_count: 1,
            needs_accept: true,
            defined: true,
            retired: false,
            live_dependents: 0,
        },
    );
    assert!(stored_tasks == tasks);
    assert!(conditions == array![1].span());
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_twice_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    assert_error(try_define(q, 1, one(6), array![].span()), errors::ALREADY_DEFINED);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_self_condition() {
    let q = deploy();
    assert_error(try_define(q, 1, one(5), array![1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_duplicate_condition() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    assert_error(try_define(q, 2, one(5), array![1, 1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_undefined_condition() {
    let q = deploy();
    assert_error(try_define(q, 2, one(5), array![99].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_too_many_conditions() {
    let q = deploy();
    let mut id: u32 = 1;
    while id <= 8 {
        define_simple(q, id, one_off(), 5, 1);
        id += 1;
    }
    assert_error(
        try_define(q, 20, one(5), array![1, 2, 3, 4, 5, 6, 7, 8].span()),
        errors::TOO_MANY_CONDITIONS,
    );
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_retired_condition() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    retire(q, 1);
    assert_error(try_define(q, 2, one(6), array![1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_rejects_invalid_input() {
    let q = deploy();
    assert_error(try_define(q, 0, one(5), array![].span()), errors::INVALID_ID);
    assert_error(try_define(q, 1, array![].span(), array![].span()), errors::INVALID_TASKS);
    as_admin(q);
    assert_error(
        q.safe.define(1, schedule(0, 0, 2, 1), one(5), array![].span(), false),
        errors::INVALID_INTERVAL,
    );
    stop(q);
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_define_counts_dependents() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    define(q, 2, one_off(), one(6), array![1].span(), false);
    define(q, 3, one_off(), one(7), array![1].span(), false);
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 2);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2000000000)]
fn quest_define_rejects_association_overflow() {
    let q = deploy();
    let max: u32 = (QUESTS_PER_PAGE * MAX_PAGES).into();
    let mut id: u32 = 1;
    while id <= max {
        define_simple(q, id, one_off(), 5, 1);
        id += 1;
    }
    assert_error(try_define(q, max + 1, one(5), array![].span()), errors::TASK_FULL);
    // A quest with the full task among others is refused too, and leaves nothing behind
    assert_error(
        try_define(q, max + 1, array![task(6, 1), task(5, 1)].span(), array![].span()),
        errors::TASK_FULL,
    );
    assert_error(q.safe_view.quest_definition(max + 1), errors::DOES_NOT_EXIST);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_empty_slot_reads_undefined() {
    let q = deploy();
    assert_error(q.safe_view.quest_definition(5), errors::DOES_NOT_EXIST);
}
