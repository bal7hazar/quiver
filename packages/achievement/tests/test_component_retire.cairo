//! `retire` (ARC-01 §3.11): the `retired` bit, its event, its refusals.

use quiver_achievement::component::AchievementComponent::{AchievementRetired, Event};
use quiver_achievement::errors;
use quiver_achievement::interface::{
    IAchievementSafeDispatcherTrait, IAchievementViewDispatcherTrait,
};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{one, task};
use super::setup::{as_admin, assert_error, define, define_simple, deploy, retire, stop};

#[test]
#[available_gas(l2_gas: 3869061)]
fn achievement_retire_sets_retired_and_keeps_the_rest() {
    let a = deploy();
    let tasks = array![task(1, 5), task(2, 6)].span();
    define(a, 5, super::helpers::always(), tasks, 10);
    let (before, _) = a.view.achievement_definition(5);
    let mut spy = spy_events();
    retire(a, 5);
    spy
        .assert_emitted(
            @array![
                (a.address, Event::AchievementRetired(AchievementRetired { achievement_id: 5 })),
            ],
        );
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (_, event) = events.at(0);
    assert!(event.keys == @array![selector!("AchievementRetired"), 5]);
    assert!(event.data.len() == 0);
    let (after, read) = a.view.achievement_definition(5);
    assert!(after.retired);
    assert!(after.defined);
    assert!(after.window == before.window && after.t0 == before.t0);
    assert!(after.task_count == before.task_count);
    assert!(read == tasks);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3224088)]
fn achievement_retire_twice_reverts() {
    let a = deploy();
    define_simple(a, 5, 7, 10);
    retire(a, 5);
    as_admin(a);
    assert_error(a.safe.retire(5), errors::RETIRED);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1866732)]
fn achievement_retire_undefined_reverts() {
    let a = deploy();
    as_admin(a);
    assert_error(a.safe.retire(5), errors::DOES_NOT_EXIST);
    stop(a);
}

/// Retiring one tier leaves the others on the task untouched.
#[test]
#[available_gas(l2_gas: 3951266)]
fn achievement_retire_one_tier_only() {
    let a = deploy();
    define_simple(a, 1, 7, 10);
    define_simple(a, 2, 7, 50);
    retire(a, 1);
    let (other, tasks) = a.view.achievement_definition(2);
    assert!(!other.retired);
    assert!(tasks == one(7, 50));
}
