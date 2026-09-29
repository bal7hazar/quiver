//! Claims and hooks (ARC-01 §3.5): each hook runs once, after the state is written, with
//! `completions` or `claim_index`; a hook that panics reverts the call.

use quiver_quest::component::QuestComponent::{Event, QuestClaimed};
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::Mode;
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{DAY, no_progress, no_record, one_off, schedule};
use super::mocks::{HookCall, IMockQuestDispatcherTrait};
use super::setup::{
    DAY64, PLAYER, accept, as_owner, as_reporter, assert_error, at, claim, define_held, deploy,
    report, stop,
};

#[test]
#[available_gas(l2_gas: 23636878)]
fn quest_claim_index_counts_claims() {
    let q = deploy();
    at(q, 0);
    define_held(q, 1, schedule(0, 0, DAY, DAY), 7, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, DAY64);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(claim(q, PLAYER, 1, 1) == 0);
    assert!(claim(q, PLAYER, 1, 0) == 1);
    assert!(q.mock.hook_count() == 4);
    let call = q.mock.hook_call(2);
    assert!(call.kind == 'claim' && call.interval_id == 1 && call.value == 0);
    let call = q.mock.hook_call(3);
    assert!(call.kind == 'claim' && call.interval_id == 0 && call.value == 1);
    assert!(q.view.quest_record(PLAYER, 1).claims == 2);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 14041814)]
fn quest_claim_twice_reverts() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    claim(q, PLAYER, 1, 0);
    as_owner(q);
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::ALREADY_CLAIMED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 7291952)]
fn quest_claim_uncompleted_reverts() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 5);
    report(q, PLAYER, 7, 4, Mode::Storage);
    as_owner(q);
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::NOT_COMPLETED);
    // A quest never defined has nothing completed
    assert_error(q.safe.claim(PLAYER, 99, 0), errors::NOT_COMPLETED);
    stop(q);
}

#[test]
#[available_gas(l2_gas: 13771712)]
fn quest_claim_emits_and_writes() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    let mut spy = spy_events();
    claim(q, PLAYER, 1, 0);
    assert!(spy.get_events().events.len() == 1);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestClaimed(
                        QuestClaimed { player_id: PLAYER, quest_id: 1, interval_id: 0 },
                    ),
                ),
            ],
        );
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress.completed && progress.claimed);
    assert!(q.view.quest_record(PLAYER, 1).claims == 1);
}

#[test]
#[available_gas(l2_gas: 10564214)]
fn quest_complete_hook_after_state_written() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 3);
    report(q, PLAYER, 7, 3, Mode::Storage);
    assert!(q.mock.hook_count() == 1);
    assert!(
        q
            .mock
            .hook_call(
                0,
            ) == HookCall {
                kind: 'complete',
                player_id: PLAYER,
                quest_id: 1,
                interval_id: 0,
                value: 1,
                seen_counter: 1,
                seen_flag: true,
            },
    );
}

#[test]
#[available_gas(l2_gas: 13766683)]
fn quest_claim_hook_after_state_written() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 3);
    report(q, PLAYER, 7, 3, Mode::Storage);
    claim(q, PLAYER, 1, 0);
    assert!(q.mock.hook_count() == 2);
    assert!(
        q
            .mock
            .hook_call(
                1,
            ) == HookCall {
                kind: 'claim',
                player_id: PLAYER,
                quest_id: 1,
                interval_id: 0,
                value: 0,
                seen_counter: 1,
                seen_flag: true,
            },
    );
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 9427190)]
fn quest_complete_hook_panic_reverts_progress() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 3);
    define_held(q, 2, one_off(), 7, 10);
    q.mock.set_panics(true, false);
    as_reporter(q);
    assert_error(q.safe.progress(PLAYER, 7, 3, Mode::Storage), 'Mock: complete refused');
    stop(q);
    // Nothing of the call is kept, for either quest
    assert!(q.view.quest_progress(PLAYER, 1, 0) == no_progress());
    assert!(q.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(q.view.quest_record(PLAYER, 1) == no_record());
    assert!(q.mock.hook_count() == 0);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 11974847)]
fn quest_claim_hook_panic_reverts_claim() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 3);
    report(q, PLAYER, 7, 3, Mode::Storage);
    q.mock.set_panics(false, true);
    as_owner(q);
    assert_error(q.safe.claim(PLAYER, 1, 0), 'Mock: claim refused');
    stop(q);
    assert!(!q.view.quest_progress(PLAYER, 1, 0).claimed);
    assert!(q.view.quest_record(PLAYER, 1).claims == 0);
    assert!(q.mock.hook_count() == 1);
}
