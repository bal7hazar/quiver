//! Access control (ARC-01 §2 D-13, §3.6): every entrypoint of `IQuest` refuses an unauthorised
//! caller; the internal layer is reachable only through the consumer's own entrypoints.

use quiver_quest::component::QuestComponent::{Event, QuestReporterSet};
use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestDispatcherTrait, IQuestSafeDispatcher, IQuestSafeDispatcherTrait,
    IQuestViewDispatcherTrait,
};
use quiver_quest::logic::Mode;
use snforge_std::{
    EventSpyAssertionsTrait, EventSpyTrait, spy_events, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use super::helpers::{entry, one_off, task};
use super::mocks::{
    IMockConsumerDispatcherTrait, IMockConsumerSafeDispatcher, IMockConsumerSafeDispatcherTrait,
};
use super::setup::{
    PLAYER, Quest, admin, as_admin, assert_error, caller, claim, define, define_held, define_simple,
    deploy, deploy_consumer, ephemeral, owner, report, reporter, stop, stranger,
};

/// Quest 1 (task 7, total 1), accepted and completed by `PLAYER`.
fn completed() -> Quest {
    let q = deploy();
    define(q, 1, one_off(), array![task(7, 1)].span(), array![].span());
    super::setup::accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    q
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3127667)]
fn quest_define_admin_only() {
    let q = deploy();
    caller(q, stranger());
    assert_error(
        q.safe.define(1, one_off(), array![task(7, 1)].span(), array![].span()), errors::NOT_ADMIN,
    );
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5209659)]
fn quest_retire_admin_only() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 1);
    caller(q, stranger());
    assert_error(q.safe.retire(1), errors::NOT_ADMIN);
    // Nor the reporter or the player's owner
    caller(q, reporter());
    assert_error(q.safe.retire(1), errors::NOT_ADMIN);
    caller(q, owner());
    assert_error(q.safe.retire(1), errors::NOT_ADMIN);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3118028)]
fn quest_set_reporter_admin_only() {
    let q = deploy();
    caller(q, stranger());
    assert_error(q.safe.set_reporter(stranger(), true), errors::NOT_ADMIN);
    stop(q);
    assert!(!q.view.quest_is_reporter(stranger()));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6159437)]
fn quest_progress_rejects_unregistered_caller() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 5);
    // The admin is not a reporter either
    as_admin(q);
    assert_error(q.safe.progress(PLAYER, 7, 1, Mode::Storage), errors::NOT_REPORTER);
    caller(q, stranger());
    assert_error(q.safe.progress(PLAYER, 7, 1, Mode::Storage), errors::NOT_REPORTER);
    assert_error(q.safe.progress(PLAYER, 7, 1, Mode::Event), errors::NOT_REPORTER);
    stop(q);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 0);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3037829)]
fn quest_progress_many_rejects_unregistered_caller() {
    let q = deploy();
    caller(q, stranger());
    assert_error(
        q.safe.progress_many(PLAYER, array![entry(7, 1)].span(), Mode::Storage),
        errors::NOT_REPORTER,
    );
    stop(q);
}

#[test]
#[available_gas(l2_gas: 7753738)]
fn quest_progress_accepts_registered_reporter() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 5);
    let other: starknet::ContractAddress = 'other reporter'.try_into().unwrap();
    let mut spy = spy_events();
    as_admin(q);
    q.quest.set_reporter(other, true);
    stop(q);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestReporterSet(QuestReporterSet { reporter: other, allowed: true }),
                ),
            ],
        );
    assert!(q.view.quest_is_reporter(other));
    caller(q, other);
    q.quest.progress(PLAYER, 7, 2, Mode::Storage);
    q.quest.progress_many(PLAYER, array![entry(7, 1)].span(), Mode::Storage);
    stop(q);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 3);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5577306)]
fn quest_reporter_revoked() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 5);
    as_admin(q);
    q.quest.set_reporter(reporter(), false);
    stop(q);
    assert!(!q.view.quest_is_reporter(reporter()));
    caller(q, reporter());
    assert_error(q.safe.progress(PLAYER, 7, 1, Mode::Storage), errors::NOT_REPORTER);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 15155675)]
fn quest_claim_requires_player_authorization() {
    let q = completed();
    caller(q, stranger());
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::NOT_AUTHORIZED);
    // Nor the admin, nor the reporter
    as_admin(q);
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::NOT_AUTHORIZED);
    caller(q, reporter());
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::NOT_AUTHORIZED);
    stop(q);
    assert!(claim(q, PLAYER, 1, 0) == 0);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 4879235)]
fn quest_accept_requires_player_authorization() {
    let q = deploy();
    define(q, 1, one_off(), array![task(7, 1)].span(), array![].span());
    caller(q, stranger());
    assert_error(q.safe.accept(PLAYER, 1), errors::NOT_AUTHORIZED);
    stop(q);
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5816727)]
fn quest_abandon_requires_player_authorization() {
    let q = deploy();
    define(q, 1, one_off(), array![task(7, 5)].span(), array![].span());
    super::setup::accept(q, PLAYER, 1);
    caller(q, stranger());
    assert_error(q.safe.abandon(PLAYER, 1), errors::NOT_AUTHORIZED);
    stop(q);
    assert!(q.view.quest_is_accepted(PLAYER, 1));
}

/// The owner of one player cannot act for another.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 4657611)]
fn quest_player_authorization_is_per_player() {
    let q = deploy();
    define(q, 1, one_off(), array![task(7, 5)].span(), array![].span());
    caller(q, owner());
    assert_error(q.safe.accept('nobody', 1), errors::NOT_AUTHORIZED);
    stop(q);
}

/// `MockConsumer` embeds only the views (ARC-01 §3.8): no selector of `IQuest` exists on it.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 2121935)]
fn quest_internal_layer_not_reachable_from_abi() {
    let (address, _, _) = deploy_consumer();
    let safe = IQuestSafeDispatcher { contract_address: address };
    start_cheat_caller_address(address, admin());
    let not_found = 'ENTRYPOINT_NOT_FOUND';
    assert_error(safe.define(1, one_off(), array![task(7, 1)].span(), array![].span()), not_found);
    assert_error(safe.retire(1), not_found);
    assert_error(safe.set_reporter(admin(), true), not_found);
    assert_error(safe.progress(PLAYER, 7, 1, Mode::Storage), not_found);
    assert_error(safe.progress_many(PLAYER, array![entry(7, 1)].span(), Mode::Storage), not_found);
    assert_error(safe.accept(PLAYER, 1), not_found);
    assert_error(safe.abandon(PLAYER, 1), not_found);
    assert_error(safe.claim(PLAYER, 1, 0), not_found);
    stop_cheat_caller_address(address);
}

/// The consumer's own entrypoints reach the internal layer after the consumer's checks.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6193684)]
fn quest_consumer_calls_the_internal_layer() {
    let (address, consumer, view) = deploy_consumer();
    let safe = IMockConsumerSafeDispatcher { contract_address: address };
    start_cheat_caller_address(address, admin());
    consumer.define_quest(1, one_off(), array![task(7, 2)].span(), array![].span());
    // Only the ephemeral contract submits results
    assert_error(safe.submit_results(PLAYER, array![entry(7, 1)].span()), 'not ephemeral');
    stop_cheat_caller_address(address);
    // The consumer's accept_quest: the internal accept checks no caller
    start_cheat_caller_address(address, stranger());
    consumer.accept_quest(PLAYER, 1);
    stop_cheat_caller_address(address);
    start_cheat_caller_address(address, ephemeral());
    consumer.submit_results(PLAYER, array![entry(7, 2)].span());
    stop_cheat_caller_address(address);
    assert!(view.quest_progress(PLAYER, 1, 0).completed);
    assert!(consumer.claim_quest(PLAYER, 1, 0) == 0);
    assert!(view.quest_progress(PLAYER, 1, 0).claimed);
    assert!(!view.quest_is_reporter(ephemeral()));
}

/// `set_reporter` emits `QuestReporterSet` with the reporter as key.
#[test]
#[available_gas(l2_gas: 3087462)]
fn quest_set_reporter_event_keys() {
    let q = deploy();
    let mut spy = spy_events();
    as_admin(q);
    q.quest.set_reporter(stranger(), false);
    stop(q);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == q.address);
    assert!(event.keys == @array![selector!("QuestReporterSet"), stranger().into()]);
    assert!(event.data == @array![0]);
}
