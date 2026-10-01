//! Access control (ARC-01 §2 D-13, §3.6, §3.11): every entrypoint of `IAchievement` refuses an
//! unauthorised caller; a revoked reporter is refused at once; the internal layer is reachable
//! only through the consumer's own entrypoints.

use quiver_achievement::component::AchievementComponent::{AchievementReporterSet, Event};
use quiver_achievement::errors;
use quiver_achievement::interface::{
    IAchievementDispatcherTrait, IAchievementSafeDispatcher, IAchievementSafeDispatcherTrait,
    IAchievementViewDispatcherTrait, IAchievementViewSafeDispatcherTrait,
};
use snforge_std::{
    EventSpyAssertionsTrait, EventSpyTrait, spy_events, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use super::helpers::{always, entry, one};
use super::mocks::{
    IMockConsumerDispatcherTrait, IMockConsumerSafeDispatcher, IMockConsumerSafeDispatcherTrait,
};
use super::setup::{
    PLAYER, admin, as_admin, assert_error, caller, define_simple, deploy, deploy_consumer,
    ephemeral, report, reporter, stop, stranger,
};

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2435979)]
fn achievement_define_admin_only() {
    let a = deploy();
    caller(a, stranger());
    assert_error(a.safe.define(1, always(), one(7, 1), 10), errors::NOT_ADMIN);
    // Nor the reporter
    caller(a, reporter());
    assert_error(a.safe.define(1, always(), one(7, 1), 10), errors::NOT_ADMIN);
    stop(a);
    assert_error(a.safe_view.achievement_definition(1), errors::DOES_NOT_EXIST);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3252291)]
fn achievement_retire_admin_only() {
    let a = deploy();
    define_simple(a, 1, 7, 1);
    caller(a, stranger());
    assert_error(a.safe.retire(1), errors::NOT_ADMIN);
    caller(a, reporter());
    assert_error(a.safe.retire(1), errors::NOT_ADMIN);
    stop(a);
    let (definition, _) = a.view.achievement_definition(1);
    assert!(!definition.retired);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2518688)]
fn achievement_set_reporter_admin_only() {
    let a = deploy();
    caller(a, stranger());
    assert_error(a.safe.set_reporter(stranger(), true), errors::NOT_ADMIN);
    // A reporter cannot register another, nor revoke itself
    caller(a, reporter());
    assert_error(a.safe.set_reporter(stranger(), true), errors::NOT_ADMIN);
    assert_error(a.safe.set_reporter(reporter(), false), errors::NOT_ADMIN);
    stop(a);
    assert!(!a.view.achievement_is_reporter(stranger()));
    assert!(a.view.achievement_is_reporter(reporter()));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2060436)]
fn achievement_progress_rejects_unregistered_caller() {
    let a = deploy();
    let mut spy = spy_events();
    // The admin is not a reporter either
    as_admin(a);
    assert_error(a.safe.progress(PLAYER, 7, 1), errors::NOT_REPORTER);
    caller(a, stranger());
    assert_error(a.safe.progress(PLAYER, 7, 1), errors::NOT_REPORTER);
    stop(a);
    assert!(spy.get_events().events.len() == 0);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2230053)]
fn achievement_progress_many_rejects_unregistered_caller() {
    let a = deploy();
    as_admin(a);
    assert_error(a.safe.progress_many(PLAYER, array![entry(7, 1)].span()), errors::NOT_REPORTER);
    caller(a, stranger());
    assert_error(a.safe.progress_many(PLAYER, array![entry(7, 1)].span()), errors::NOT_REPORTER);
    // Refused before the batch is looked at: an empty batch too
    assert_error(a.safe.progress_many(PLAYER, array![].span()), errors::NOT_REPORTER);
    stop(a);
}

#[test]
#[available_gas(l2_gas: 3159432)]
fn achievement_progress_accepts_registered_reporter() {
    let a = deploy();
    let other: starknet::ContractAddress = 'other reporter'.try_into().unwrap();
    let mut spy = spy_events();
    as_admin(a);
    a.achievement.set_reporter(other, true);
    stop(a);
    spy
        .assert_emitted(
            @array![
                (
                    a.address,
                    Event::AchievementReporterSet(
                        AchievementReporterSet { reporter: other, allowed: true },
                    ),
                ),
            ],
        );
    assert!(a.view.achievement_is_reporter(other));
    caller(a, other);
    a.achievement.progress(PLAYER, 7, 2);
    a.achievement.progress_many(PLAYER, array![entry(7, 1)].span());
    stop(a);
    assert!(spy.get_events().events.len() == 3);
}

/// Revoked, then refused in the very next call.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2458970)]
fn achievement_reporter_revoked() {
    let a = deploy();
    report(a, PLAYER, 7, 1);
    as_admin(a);
    a.achievement.set_reporter(reporter(), false);
    stop(a);
    assert!(!a.view.achievement_is_reporter(reporter()));
    caller(a, reporter());
    assert_error(a.safe.progress(PLAYER, 7, 1), errors::NOT_REPORTER);
    assert_error(a.safe.progress_many(PLAYER, array![entry(7, 1)].span()), errors::NOT_REPORTER);
    stop(a);
}

/// `set_reporter` emits `AchievementReporterSet` with the reporter as key.
#[test]
#[available_gas(l2_gas: 1925175)]
fn achievement_set_reporter_event_fields() {
    let a = deploy();
    let mut spy = spy_events();
    as_admin(a);
    a.achievement.set_reporter(stranger(), false);
    stop(a);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == a.address);
    assert!(event.keys == @array![selector!("AchievementReporterSet"), stranger().into()]);
    assert!(event.data == @array![0]);
}

/// `MockConsumer` embeds only the views: no selector of `IAchievement` exists on it.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1816668)]
fn achievement_internal_layer_not_reachable_from_abi() {
    let (address, _, _) = deploy_consumer();
    let safe = IAchievementSafeDispatcher { contract_address: address };
    start_cheat_caller_address(address, admin());
    let not_found = 'ENTRYPOINT_NOT_FOUND';
    assert_error(safe.define(1, always(), one(7, 1), 10), not_found);
    assert_error(safe.retire(1), not_found);
    assert_error(safe.set_reporter(admin(), true), not_found);
    assert_error(safe.progress(PLAYER, 7, 1), not_found);
    assert_error(safe.progress_many(PLAYER, array![entry(7, 1)].span()), not_found);
    stop_cheat_caller_address(address);
}

/// The consumer's own entrypoints reach the internal layer after the consumer's checks; the
/// internal layer checks no reporter.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3190432)]
fn achievement_consumer_calls_the_internal_layer() {
    let (address, consumer, view) = deploy_consumer();
    let safe = IMockConsumerSafeDispatcher { contract_address: address };
    start_cheat_caller_address(address, admin());
    consumer.define_achievement(1, always(), one(7, 2), 10);
    // Only the ephemeral contract submits results
    assert_error(safe.submit_results(PLAYER, array![entry(7, 1)].span()), 'not ephemeral');
    stop_cheat_caller_address(address);
    start_cheat_caller_address(address, stranger());
    assert_error(safe.define_achievement(2, always(), one(7, 2), 10), 'not admin');
    stop_cheat_caller_address(address);
    let mut spy = spy_events();
    start_cheat_caller_address(address, ephemeral());
    consumer.submit_results(PLAYER, array![entry(7, 2)].span());
    stop_cheat_caller_address(address);
    assert!(spy.get_events().events.len() == 1);
    assert!(!view.achievement_is_reporter(ephemeral()));
}
