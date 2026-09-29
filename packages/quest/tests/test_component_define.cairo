//! `define` (ARC-01 §2 D-7, D-8, §3.5, amended by D-135): validation with storage, live
//! dependents; any number of quests per task.

use quiver_quest::component::QuestComponent::{Event, QuestDefined};
use quiver_quest::constants::MAX_HELD;
use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait, IQuestViewSafeDispatcherTrait,
};
use quiver_quest::logic::{QuestDefinition, QuestTask};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{one_off, schedule, task};
use super::setup::{
    PLAYER, Quest, accept, as_admin, as_owner, assert_error, define, define_simple, deploy, retire,
    stop,
};

/// `define` as the admin through the safe dispatcher.
#[feature("safe_dispatcher")]
fn try_define(
    q: Quest, quest_id: u32, tasks: Span<QuestTask>, conditions: Span<u32>,
) -> Result<(), Array<felt252>> {
    as_admin(q);
    let result = q.safe.define(quest_id, one_off(), tasks, conditions);
    stop(q);
    result
}

fn one(task_id: u32) -> Span<QuestTask> {
    array![task(task_id, 1)].span()
}

#[test]
#[available_gas(l2_gas: 6664014)]
fn quest_define_stores_and_emits() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    let quest_schedule = schedule(100, 900, 10, 20);
    let tasks = array![task(5, 2), task(6, 3), task(7, 4)].span();
    let mut spy = spy_events();
    define(q, 2, quest_schedule, tasks, array![1].span());
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
#[available_gas(l2_gas: 4587765)]
fn quest_define_twice_reverts() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    assert_error(try_define(q, 1, one(6), array![].span()), errors::ALREADY_DEFINED);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3135993)]
fn quest_define_rejects_self_condition() {
    let q = deploy();
    assert_error(try_define(q, 1, one(5), array![1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 4604670)]
fn quest_define_rejects_duplicate_condition() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    assert_error(try_define(q, 2, one(5), array![1, 1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3190877)]
fn quest_define_rejects_undefined_condition() {
    let q = deploy();
    assert_error(try_define(q, 2, one(5), array![99].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 14792127)]
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
#[available_gas(l2_gas: 5084657)]
fn quest_define_rejects_retired_condition() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    retire(q, 1);
    assert_error(try_define(q, 2, one(6), array![1].span()), errors::INVALID_CONDITION);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 4088952)]
fn quest_define_rejects_invalid_input() {
    let q = deploy();
    assert_error(try_define(q, 0, one(5), array![].span()), errors::INVALID_ID);
    assert_error(try_define(q, 1, array![].span(), array![].span()), errors::INVALID_TASKS);
    as_admin(q);
    assert_error(
        q.safe.define(1, schedule(0, 0, 2, 1), one(5), array![].span()), errors::INVALID_INTERVAL,
    );
    stop(q);
}

#[test]
#[available_gas(l2_gas: 8433191)]
fn quest_define_counts_dependents() {
    let q = deploy();
    define_simple(q, 1, one_off(), 5, 1);
    define(q, 2, one_off(), one(6), array![1].span());
    define(q, 3, one_off(), one(7), array![1].span());
    let (definition, _, _) = q.view.quest_definition(1);
    assert!(definition.live_dependents == 2);
}

/// Meaning changed by D-135: tasks have no pages and no cap on the quests that use them, so
/// defining a 29th quest on a task succeeds; the bound that remains is the player's held list,
/// whose overflow `accept` refuses (`'Quest: too many held'`).
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 50029844)]
fn quest_define_rejects_association_overflow() {
    let q = deploy();
    let old_cap: u32 = 28;
    let mut id: u32 = 1;
    while id <= old_cap + 1 {
        define_simple(q, id, one_off(), 5, 1);
        id += 1;
    }
    let (definition, _, _) = q.view.quest_definition(old_cap + 1);
    assert!(definition.defined);
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        accept(q, PLAYER, id);
        id += 1;
    }
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, old_cap + 1), errors::TOO_MANY_HELD);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2879541)]
fn quest_empty_slot_reads_undefined() {
    let q = deploy();
    assert_error(q.safe_view.quest_definition(5), errors::DOES_NOT_EXIST);
}
