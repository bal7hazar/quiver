//! The component under `TrackNone` (ARC-07b), on `MockBenchSilent`: the tracked models' events
//! (`AchievementDefined`, `AchievementReporterSet`) are not emitted, and every action event
//! (`AchievementProgressed`, the only record of progress in event mode, and `AchievementRetired`)
//! is, with 0.1.0's keys and data. The state written is the same as under `TrackAll`.

use quiver_achievement::errors;
use quiver_achievement::interface::{
    IAchievementDispatcher, IAchievementDispatcherTrait, IAchievementSafeDispatcher,
    IAchievementSafeDispatcherTrait, IAchievementViewDispatcher, IAchievementViewDispatcherTrait,
};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, spy_events, test_address,
};
use super::helpers::{always, entry, one, task};
use super::setup::{PLAYER, assert_error};

fn deploy() -> (IAchievementDispatcher, IAchievementViewDispatcher) {
    let class = declare("MockBenchSilent").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    (
        IAchievementDispatcher { contract_address: address },
        IAchievementViewDispatcher { contract_address: address },
    )
}

#[test]
#[available_gas(l2_gas: 3891285)]
fn track_none_component_emits_action_events_only() {
    let (achievement, view) = deploy();
    let mut spy = spy_events();
    // Tracked models: written, not emitted
    achievement.set_reporter(test_address(), true);
    achievement.define(1, always(), one(7, 2), 10);
    achievement.define(2, always(), array![task(8, 1), task(9, 3)].span(), 20);
    assert!(spy.get_events().events.len() == 0);
    assert!(view.achievement_is_reporter(test_address()));
    let (head, tasks) = view.achievement_definition(2);
    assert!(head.defined && head.points == 20);
    assert!(tasks == array![task(8, 1), task(9, 3)].span());
    // Action events
    achievement.progress_many(PLAYER, array![entry(7, 2), entry(8, 1), entry(7, 1)].span());
    achievement.retire(2);
    let events = spy.get_events().events;
    assert!(events.len() == 3);
    let (from, first) = events.at(0);
    assert!(*from == achievement.contract_address);
    assert!(first.keys == @array![selector!("AchievementProgressed"), PLAYER, 7]);
    assert!(first.data == @array![3]);
    let (_, second) = events.at(1);
    assert!(second.keys == @array![selector!("AchievementProgressed"), PLAYER, 8]);
    assert!(second.data == @array![1]);
    let (_, retired) = events.at(2);
    assert!(retired.keys == @array![selector!("AchievementRetired"), 2]);
    assert!(retired.data.len() == 0);
    let (after, _) = view.achievement_definition(2);
    assert!(after.retired);
}

/// The refusals hold under `TrackNone` (ARC-07d), on `MockSilentGuarded`, whose `authorize_admin`
/// refuses: the package's own strings, nothing emitted, nothing written.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3000000)]
fn track_none_refuses_with_the_packages_errors() {
    let class = declare("MockSilentGuarded").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let safe = IAchievementSafeDispatcher { contract_address: address };
    let view = IAchievementViewDispatcher { contract_address: address };
    let mut spy = spy_events();
    assert_error(safe.define(1, always(), one(7, 1), 10), errors::NOT_ADMIN);
    assert_error(safe.set_reporter(test_address(), true), errors::NOT_ADMIN);
    // No reporter is registered: the unregistered caller is refused as well
    assert_error(safe.progress(PLAYER, 7, 1), errors::NOT_REPORTER);
    assert!(spy.get_events().events.len() == 0);
    assert!(!view.achievement_is_reporter(test_address()));
}
