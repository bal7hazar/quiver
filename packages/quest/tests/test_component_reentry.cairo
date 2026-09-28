//! Hooks that re-enter the component (fix loop 1, points 1 and 2). `MockReentrant`'s hooks log
//! their call, then run one `progress`, `claim`, `accept` or `retire` through the internal layer.

use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestSafeDispatcher, IQuestSafeDispatcherTrait,
    IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::logic::{Mode, QuestProgress, QuestRecord};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpy, EventSpyTrait, declare, spy_events,
    test_address,
};
use starknet::ContractAddress;
use super::helpers::{no_progress, one_off, task};
use super::mock_reentrant::{IMockReentrantDispatcher, IMockReentrantDispatcherTrait, Reentry};
use super::mocks::HookCall;
use super::setup::{PLAYER, assert_error};

const T: u32 = 7;

#[derive(Drop, Copy)]
struct Reentrant {
    address: ContractAddress,
    quest: IQuestDispatcher,
    safe: IQuestSafeDispatcher,
    view: IQuestViewDispatcher,
    mock: IMockReentrantDispatcher,
}

/// `MockReentrant`, with the test contract as its reporter.
fn deploy() -> Reentrant {
    let class = declare("MockReentrant").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let r = Reentrant {
        address,
        quest: IQuestDispatcher { contract_address: address },
        safe: IQuestSafeDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
        mock: IMockReentrantDispatcher { contract_address: address },
    };
    r.quest.set_reporter(test_address(), true);
    r
}

fn define(r: Reentrant, quest_id: u32, task_id: u32, needs_accept: bool) {
    r
        .quest
        .define(
            quest_id, one_off(), array![task(task_id, 1)].span(), array![].span(), needs_accept,
        );
}

fn on_complete(on_quest: u32, action: felt252, quest_id: u32, task_id: u32) -> Reentry {
    Reentry { hook: 'complete', on_quest, action, quest_id, task_id, count: 1, interval_id: 0 }
}

/// The events of `address` among those spied, as (first key, second key, third key).
fn events_of(ref spy: EventSpy, address: ContractAddress) -> Array<(felt252, felt252, felt252)> {
    let mut out = array![];
    for (from, event) in spy.get_events().events {
        if from == address {
            let k1 = if event.keys.len() > 1 {
                *event.keys[1]
            } else {
                0
            };
            let k2 = if event.keys.len() > 2 {
                *event.keys[2]
            } else {
                0
            };
            out.append((*event.keys[0], k1, k2));
        }
    }
    out
}

fn completed_events(ref spy: EventSpy, address: ContractAddress, quest_id: u32) -> u32 {
    let mut n = 0;
    for (name, _, quest) in events_of(ref spy, address) {
        if name == selector!("QuestCompleted") && quest == quest_id.into() {
            n += 1;
        }
    }
    n
}

fn hook_calls(r: Reentrant) -> Array<HookCall> {
    let mut out = array![];
    let mut i = 0;
    while i < r.mock.hook_count() {
        out.append(r.mock.hook_call(i));
        i += 1;
    }
    out
}

/// Point 1: two permanent quests on one task, target 1; the first one's completion hook retires
/// the second, which the call read from the task's pages before.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 13893869)]
fn quest_retired_by_hook_not_progressed() {
    let r = deploy();
    define(r, 1, T, false);
    define(r, 2, T, false);
    r.mock.set_reentry(on_complete(1, 'retire', 2, 0));
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    // The first completed; the second was retired and got nothing
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.view.quest_record(PLAYER, 2).completions == 0);
    assert!(completed_events(ref spy, r.address, 1) == 1);
    assert!(completed_events(ref spy, r.address, 2) == 0);
    let calls = hook_calls(r);
    assert!(calls.len() == 1 && *calls[0].quest_id == 1);
    let (definition, _, _) = r.view.quest_definition(2);
    assert!(definition.retired);
    assert_error(r.safe.claim(PLAYER, 2, 0), errors::NOT_COMPLETED);
}

/// Progress from `on_quest_complete` on the same quest, same interval: no second completion, no
/// second hook call.
#[test]
#[available_gas(l2_gas: 11377078)]
fn quest_reentrant_progress_same_quest_completes_once() {
    let r = deploy();
    define(r, 1, T, false);
    r.mock.set_reentry(on_complete(1, 'progress', 1, T));
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(
        r
            .view
            .quest_progress(
                PLAYER, 1, 0,
            ) == QuestProgress { c0: 1, c1: 0, c2: 0, completed: true, claimed: false },
    );
    assert!(r.view.quest_record(PLAYER, 1).completions == 1);
    assert!(completed_events(ref spy, r.address, 1) == 1);
    assert!(r.mock.hook_count() == 1);
}

/// Progress from the first quest's hook on the same task completes the second quest inside the
/// hook; the outer call then reaches the second quest, finds it completed, and skips it.
#[test]
#[available_gas(l2_gas: 18216432)]
fn quest_reentrant_progress_later_quest_completes_once() {
    let r = deploy();
    define(r, 1, T, false);
    define(r, 2, T, false);
    r.mock.set_reentry(on_complete(1, 'progress', 1, T));
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_record(PLAYER, 1).completions == 1);
    assert!(r.view.quest_record(PLAYER, 2).completions == 1);
    assert!(completed_events(ref spy, r.address, 1) == 1);
    assert!(completed_events(ref spy, r.address, 2) == 1);
    let calls = hook_calls(r);
    assert!(calls.len() == 2);
    assert!(*calls[0].quest_id == 1 && *calls[1].quest_id == 2);
}

/// Claim from `on_quest_claim` of the same interval: refused `'Quest: already claimed'`, which
/// reverts the outer claim; nothing is claimed twice.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 12015073)]
fn quest_reentrant_claim_same_quest_refused() {
    let r = deploy();
    define(r, 1, T, false);
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    r
        .mock
        .set_reentry(
            Reentry {
                hook: 'claim',
                on_quest: 1,
                action: 'claim',
                quest_id: 1,
                task_id: 0,
                count: 0,
                interval_id: 0,
            },
        );
    assert_error(r.safe.claim(PLAYER, 1, 0), errors::ALREADY_CLAIMED);
    assert!(!r.view.quest_progress(PLAYER, 1, 0).claimed);
    assert!(r.view.quest_record(PLAYER, 1).claims == 0);
    // snforge's spy keeps the events emitted before the revert; a receipt would not. The
    // reverted state is what is checked here.
    // Only the completion hook of the setup ran
    assert!(r.mock.hook_count() == 1);
}

/// Accept from `on_quest_complete` after the completion: refused `'Quest: already completed'`,
/// which reverts the outer progress.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 8184830)]
fn quest_reentrant_accept_after_completion_refused() {
    let r = deploy();
    define(r, 1, T, true);
    r.quest.accept(PLAYER, 1);
    r.mock.set_reentry(on_complete(1, 'accept', 1, 0));
    assert_error(r.safe.progress(PLAYER, T, 1, Mode::Storage), errors::ALREADY_COMPLETED);
    assert!(r.view.quest_progress(PLAYER, 1, 0) == no_progress());
    assert!(
        r
            .view
            .quest_record(
                PLAYER, 1,
            ) == QuestRecord {
                completions: 0, claims: 0, unlocked: false, active: true, accepted_interval: 0,
            },
    );
    // snforge's spy keeps the events emitted before the revert; a receipt would not. The
    // reverted state is what is checked here.
    assert!(r.mock.hook_count() == 0);
}

// An operation on another quest from a hook leaves the outer call exactly as without it.
//
// Outer call: `progress(PLAYER, T, 1)` on quests 1 and 2 (task T, target 1). Other quests:
// 3 on task 8 (for progress), 4 on task 9 completed in the setup (for claim), 5 on task 10 with
// an accept step (for accept), 6 on task 11 (for retire). The re-entry runs in quest 1's hook.

fn other_quests_setup() -> Reentrant {
    let r = deploy();
    define(r, 1, T, false);
    define(r, 2, T, false);
    define(r, 3, 8, false);
    define(r, 4, 9, false);
    define(r, 5, 10, true);
    define(r, 6, 11, false);
    r.quest.progress(PLAYER, 9, 1, Mode::Storage);
    r
}

/// The outer call's state, events and hook calls, for quests 1 and 2.
#[derive(Drop, PartialEq, Debug)]
struct Outer {
    progress: (QuestProgress, QuestProgress),
    records: (QuestRecord, QuestRecord),
    events: Array<(felt252, felt252, felt252)>,
    hooks: Array<HookCall>,
}

fn outer(ref spy: EventSpy, r: Reentrant) -> Outer {
    let mut events = array![];
    for event in events_of(ref spy, r.address) {
        let (_, _, quest) = event;
        if quest == 1 || quest == 2 {
            events.append(event);
        }
    }
    let mut hooks = array![];
    for call in hook_calls(r) {
        if call.quest_id == 1 || call.quest_id == 2 {
            hooks.append(call);
        }
    }
    Outer {
        progress: (r.view.quest_progress(PLAYER, 1, 0), r.view.quest_progress(PLAYER, 2, 0)),
        records: (r.view.quest_record(PLAYER, 1), r.view.quest_record(PLAYER, 2)),
        events,
        hooks,
    }
}

/// Runs the outer call without a re-entry and with `reentry`; asserts that the outer parts are
/// equal; returns the re-entered contract.
fn assert_outer_unchanged(reentry: Reentry) -> Reentrant {
    let plain = other_quests_setup();
    let mut spy = spy_events();
    plain.quest.progress(PLAYER, T, 1, Mode::Storage);
    let expected = outer(ref spy, plain);

    let r = other_quests_setup();
    r.mock.set_reentry(reentry);
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    let actual = outer(ref spy, r);
    assert!(actual == expected);
    // And the outer call did its work: both completed, one hook each
    assert!(expected.hooks.len() == 2 && expected.events.len() == 2);
    r
}

#[test]
#[available_gas(l2_gas: 62668242)]
fn quest_reentrant_progress_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'progress', 0, 8));
    assert!(r.view.quest_progress(PLAYER, 3, 0).completed);
}

#[test]
#[available_gas(l2_gas: 61182938)]
fn quest_reentrant_claim_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'claim', 4, 0));
    assert!(r.view.quest_progress(PLAYER, 4, 0).claimed);
}

#[test]
#[available_gas(l2_gas: 58422393)]
fn quest_reentrant_accept_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'accept', 5, 0));
    assert!(r.view.quest_is_accepted(PLAYER, 5));
}

#[test]
#[available_gas(l2_gas: 57755822)]
fn quest_reentrant_retire_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'retire', 6, 0));
    let (definition, _, _) = r.view.quest_definition(6);
    assert!(definition.retired);
}
