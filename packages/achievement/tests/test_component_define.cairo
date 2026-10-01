//! `define` and the definition view (ARC-01 §3.11; D-8, D-11): slots A and B, `points` in the
//! event and, since 0.2.0, in A; refusals, the empty slot, any number of achievements on one task.

use quiver_achievement::component::AchievementComponent::{AchievementDefined, Event};
use quiver_achievement::errors;
use quiver_achievement::interface::{
    IAchievementDispatcherTrait, IAchievementSafeDispatcherTrait, IAchievementViewDispatcherTrait,
    IAchievementViewSafeDispatcherTrait,
};
use quiver_achievement::models::definition::{HeadSlot, TasksSlot};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, load, map_entry_address, spy_events};
use starknet::storage_access::StorePacking;
use super::helpers::{always, one, task, window};
use super::setup::{as_admin, assert_error, define, define_simple, deploy, retire, stop};

fn slot(address: starknet::ContractAddress, member: felt252, key: u32) -> felt252 {
    *load(address, map_entry_address(member, array![key.into()].span()), 1)[0]
}

#[test]
#[available_gas(l2_gas: 2716718)]
fn achievement_define_one_task_writes_a_only() {
    let a = deploy();
    let mut spy = spy_events();
    define(a, 5, window(100, 200), one(7, 10), 25);
    spy
        .assert_emitted(
            @array![
                (
                    a.address,
                    Event::AchievementDefined(
                        AchievementDefined {
                            achievement_id: 5,
                            window: window(100, 200),
                            tasks: one(7, 10),
                            points: 25,
                        },
                    ),
                ),
            ],
        );
    let (definition, tasks) = a.view.achievement_definition(5);
    // `points` stored in A since 0.2.0, and returned by the view
    assert!(
        definition == HeadSlot {
            window: window(100, 200),
            task_count: 1,
            defined: true,
            retired: false,
            t0: task(7, 10),
            points: 25,
        },
    );
    assert!(tasks == one(7, 10));
    // A as packed; B never written
    assert!(
        slot(a.address, selector!("Achievement_definitions"), 5) == StorePacking::pack(definition),
    );
    assert!(slot(a.address, selector!("Achievement_extra_tasks"), 5) == 0);
}

#[test]
#[available_gas(l2_gas: 3177920)]
fn achievement_define_three_tasks_writes_a_and_b() {
    let a = deploy();
    let tasks = array![task(1, 5), task(2, 6), task(3, 7)].span();
    define(a, 5, always(), tasks, 0);
    let (definition, read) = a.view.achievement_definition(5);
    assert!(read == tasks);
    assert!(definition.task_count == 3);
    let extra = TasksSlot { t1: task(2, 6), t2: task(3, 7) };
    assert!(slot(a.address, selector!("Achievement_extra_tasks"), 5) == StorePacking::pack(extra));
}

/// `AchievementDefined`: key the id; data the window, the tasks as a span, the points.
#[test]
#[available_gas(l2_gas: 2979113)]
fn achievement_defined_event_fields() {
    let a = deploy();
    let mut spy = spy_events();
    define(a, 9, window(3, 4), array![task(1, 5), task(2, 6)].span(), 0xffff);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == a.address);
    assert!(event.keys == @array![selector!("AchievementDefined"), 9]);
    assert!(event.data == @array![3, 4, 2, 1, 5, 2, 6, 0xffff]);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3021428)]
fn achievement_define_twice_reverts() {
    let a = deploy();
    define_simple(a, 5, 7, 10);
    as_admin(a);
    assert_error(a.safe.define(5, always(), one(8, 1), 0), errors::ALREADY_DEFINED);
    stop(a);
    // Unchanged
    let (_, tasks) = a.view.achievement_definition(5);
    assert!(tasks == one(7, 10));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3272136)]
fn achievement_redefine_retired_reverts() {
    let a = deploy();
    define_simple(a, 5, 7, 10);
    retire(a, 5);
    as_admin(a);
    assert_error(a.safe.define(5, always(), one(7, 10), 0), errors::ALREADY_DEFINED);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1900406)]
fn achievement_define_rejects_no_task() {
    let a = deploy();
    as_admin(a);
    assert_error(a.safe.define(5, always(), array![].span(), 10), errors::INVALID_TASKS);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1906517)]
fn achievement_define_rejects_empty_window() {
    let a = deploy();
    as_admin(a);
    assert_error(a.safe.define(5, window(100, 100), one(7, 1), 10), errors::INVALID_WINDOW);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2719983)]
fn achievement_define_rejects_invalid_id_and_tasks() {
    let a = deploy();
    as_admin(a);
    assert_error(a.safe.define(0, always(), one(7, 1), 10), errors::INVALID_ID);
    assert_error(
        a.safe.define(5, always(), array![task(1, 1), task(1, 2)].span(), 10),
        errors::INVALID_TASKS,
    );
    assert_error(
        a
            .safe
            .define(5, always(), array![task(1, 1), task(2, 1), task(3, 1), task(4, 1)].span(), 1),
        errors::INVALID_TASKS,
    );
    assert_error(a.safe.define(5, always(), one(7, 0), 10), errors::INVALID_TASKS);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1673763)]
fn achievement_empty_slot_reads_undefined() {
    let a = deploy();
    assert_error(a.safe_view.achievement_definition(5), errors::DOES_NOT_EXIST);
}

/// No cap of achievements per task (A-G1's 28 is gone with the task pages): 29 on one task.
#[test]
#[available_gas(l2_gas: 24061401)]
fn achievement_many_on_one_task() {
    let a = deploy();
    as_admin(a);
    let mut id: u32 = 1;
    while id <= 29 {
        a.achievement.define(id, always(), one(7, id), 0);
        id += 1;
    }
    stop(a);
    let (_, tasks) = a.view.achievement_definition(29);
    assert!(tasks == one(7, 29));
}
