//! Hooks that re-enter the component (fix loop 1, points 1 and 2; D-135). `MockReentrant`'s hooks
//! log their call, then run one `progress`, `claim`, `accept`, `abandon` or `retire` through the
//! internal layer.

use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestSafeDispatcher, IQuestSafeDispatcherTrait,
    IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::logic::{Mode, QuestProgress, QuestRecord};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpy, EventSpyTrait, declare, map_entry_address,
    spy_events, store, test_address,
};
use starknet::ContractAddress;
use starknet::storage_access::StorePacking;
use super::helpers::{entry, held, held_slot0, no_progress, one_off, stamped, task, unstamped};
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

/// A one-off quest of one task, target 1; accepted by `PLAYER` when `held`.
fn define(r: Reentrant, quest_id: u32, task_id: u32, held: bool) {
    r.quest.define(quest_id, one_off(), array![task(task_id, 1)].span(), array![].span());
    if held {
        r.quest.accept(PLAYER, quest_id);
    }
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

/// Point 1: two held quests on one task, target 1; the first one's completion hook retires the
/// second, which the call read from the held list before.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 14330407)]
fn quest_retired_by_hook_not_progressed() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
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
#[available_gas(l2_gas: 11539933)]
fn quest_reentrant_progress_same_quest_completes_once() {
    let r = deploy();
    define(r, 1, T, true);
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
#[available_gas(l2_gas: 18831112)]
fn quest_reentrant_progress_later_quest_completes_once() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
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
#[available_gas(l2_gas: 12571531)]
fn quest_reentrant_claim_same_quest_refused() {
    let r = deploy();
    define(r, 1, T, true);
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
#[available_gas(l2_gas: 7954303)]
fn quest_reentrant_accept_after_completion_refused() {
    let r = deploy();
    define(r, 1, T, true);
    r.mock.set_reentry(on_complete(1, 'accept', 1, 0));
    assert_error(r.safe.progress(PLAYER, T, 1, Mode::Storage), errors::ALREADY_COMPLETED);
    assert!(r.view.quest_progress(PLAYER, 1, 0) == no_progress());
    assert!(
        r
            .view
            .quest_record(PLAYER, 1) == QuestRecord { completions: 0, claims: 0, unlocked: false },
    );
    assert!(r.view.quest_is_accepted(PLAYER, 1));
    // snforge's spy keeps the events emitted before the revert; a receipt would not. The
    // reverted state is what is checked here.
    assert!(r.mock.hook_count() == 0);
}

// An operation on another quest from a hook leaves the outer call exactly as without it.
//
// Outer call: `progress(PLAYER, T, 1)` on held quests 1 and 2 (task T, target 1). Other quests:
// 3 on task 8, held (for progress), 4 on task 9 completed in the setup (for claim), 5 on task 10
// not held (for accept), 6 on task 11, held (for abandon and retire). The held list is
// `[1, 2, 3, 6]`: 4 was pruned when 6 was accepted. The re-entry runs in quest 1's hook.

fn other_quests_setup() -> Reentrant {
    let r = deploy();
    define(r, 4, 9, true);
    r.quest.progress(PLAYER, 9, 1, Mode::Storage);
    define(r, 1, T, true);
    define(r, 2, T, true);
    define(r, 3, 8, true);
    define(r, 5, 10, false);
    define(r, 6, 11, true);
    assert!(
        unstamped(
            r.view.quest_held(PLAYER),
        ) == array![held(1, 0), held(2, 0), held(3, 0), held(6, 0)]
            .span(),
    );
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
#[available_gas(l2_gas: 66577655)]
fn quest_reentrant_progress_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'progress', 0, 8));
    assert!(r.view.quest_progress(PLAYER, 3, 0).completed);
}

#[test]
#[available_gas(l2_gas: 64574060)]
fn quest_reentrant_claim_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'claim', 4, 0));
    assert!(r.view.quest_progress(PLAYER, 4, 0).claimed);
}

#[test]
#[available_gas(l2_gas: 62780502)]
fn quest_reentrant_accept_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'accept', 5, 0));
    assert!(r.view.quest_is_accepted(PLAYER, 5));
}

#[test]
#[available_gas(l2_gas: 61929908)]
fn quest_reentrant_abandon_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'abandon', 6, 0));
    assert!(!r.view.quest_is_accepted(PLAYER, 6));
    assert!(
        unstamped(r.view.quest_held(PLAYER)) == array![held(1, 0), held(2, 0), held(3, 0)].span(),
    );
}

#[test]
#[available_gas(l2_gas: 61275789)]
fn quest_reentrant_retire_other_quest_leaves_outer_unchanged() {
    let r = assert_outer_unchanged(on_complete(1, 'retire', 6, 0));
    let (definition, _, _) = r.view.quest_definition(6);
    assert!(definition.retired);
}

// D-135: a hook that accepts or abandons changes the held list during the walk. The walk is of
// the quests held when the call starts, and each is processed only if the list still holds it.

/// A hook of quest 1 abandons quest 2, later in the list: quest 2 is not progressed.
#[test]
#[available_gas(l2_gas: 21719845)]
fn quest_reentrant_abandon_later_quest_not_progressed() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
    define(r, 3, T, true);
    r.mock.set_reentry(on_complete(1, 'abandon', 2, 0));
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.view.quest_record(PLAYER, 2).completions == 0);
    assert!(completed_events(ref spy, r.address, 2) == 0);
    // Quest 3 moved up in the list and was still processed
    assert!(r.view.quest_progress(PLAYER, 3, 0).completed);
    let calls = hook_calls(r);
    assert!(calls.len() == 2);
    assert!(*calls[0].quest_id == 1 && *calls[1].quest_id == 3);
    assert!(unstamped(r.view.quest_held(PLAYER)) == array![held(1, 0), held(3, 0)].span());
}

/// A hook of quest 1 accepts quest 2 on the same task: quest 2 is held from then on, but this
/// call, whose batch was reported before the acceptance, does not progress it.
#[test]
#[available_gas(l2_gas: 17778298)]
fn quest_reentrant_accept_not_progressed_by_the_call() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, false);
    r.mock.set_reentry(on_complete(1, 'accept', 2, 0));
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_is_accepted(PLAYER, 2));
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.mock.hook_count() == 1);
    // The accept pruned quest 1, completed: the list holds 2 only
    assert!(unstamped(r.view.quest_held(PLAYER)) == array![held(2, 0)].span());
    // The next call progresses it
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 2, 0).completed);
}

// Fix loop 1, point 2: a hook that renews the acceptance of a quest the call is about to reach.
// The renewed entry has the same quest and interval as the one the call started with; it is a
// new acceptance, made after the batch was reported, and the call must not progress it.

/// Quest 1's hook abandons quest 2, then accepts it again, in the same interval.
#[test]
#[available_gas(l2_gas: 18660634)]
fn quest_reentrant_abandon_then_accept_not_progressed() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
    r.mock.set_reentry(on_complete(1, 'abandon_accept', 2, 0));
    let mut spy = spy_events();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_is_accepted(PLAYER, 2));
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(completed_events(ref spy, r.address, 2) == 0);
    assert!(r.mock.hook_count() == 1);
    // The next call progresses it
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 2, 0).completed);
}

/// Quest 1's hook accepts quest 2, abandons it, and accepts it again.
#[test]
#[available_gas(l2_gas: 13194517)]
fn quest_reentrant_accept_abandon_accept_not_progressed() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, false);
    r.mock.set_reentry(on_complete(1, 'accept_abandon_accept', 2, 0));
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_is_accepted(PLAYER, 2));
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.mock.hook_count() == 1);
}

/// Quest 2 held when the call starts, renewed by the hook of quest 1; quest 3, held throughout,
/// still counts after it.
#[test]
#[available_gas(l2_gas: 21064225)]
fn quest_reentrant_renewed_not_progressed_others_are() {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
    define(r, 3, T, true);
    r.mock.set_reentry(on_complete(1, 'abandon_accept', 2, 0));
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 3, 0).completed);
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.view.quest_is_accepted(PLAYER, 2));
}

// Fix loop 3, point 2, and fix loop 4: the prehistory of the audit. Q1 (number 1) and Q2 (number
// 2) held; in earlier transactions the player accepted and abandoned another quest 65 535 times.
// A 16-bit counter was then back at 1, and the next acceptance got number 2 again, Q2's.
// Since fix loop 4 the counter has 30 bits, and the same history leaves it at 65 537: the next
// number is 65 538, which is 2 modulo 2^16 but not equal to 2. Seeded with `store`.

/// The counter after the prehistory: 2 + 65 535.
const AFTER_PREHISTORY: u32 = 65537;

fn wrapped_prehistory() -> Reentrant {
    let r = deploy();
    define(r, 1, T, true);
    define(r, 2, T, true);
    assert!(r.view.quest_held(PLAYER) == array![stamped(1, 0, 1), stamped(2, 0, 2)].span());
    store(
        r.address,
        map_entry_address(selector!("Quest_held"), array![PLAYER, 0].span()),
        array![StorePacking::pack(held_slot0(stamped(1, 0, 1), stamped(2, 0, 2), AFTER_PREHISTORY))]
            .span(),
    );
    r
}

/// Q1's hook abandons Q2 and accepts it again: the new acceptance gets number 2 again, the same
/// tuple as the entry the call started with. It is still a new acceptance, and the call must not
/// progress it.
#[test]
#[available_gas(l2_gas: 18789102)]
fn quest_reentrant_renewal_after_counter_wrap_not_progressed() {
    let r = wrapped_prehistory();
    r.mock.set_reentry(on_complete(1, 'abandon_accept', 2, 0));
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    // the renewed entry's number is 65 538: at 16 bits it would have been 2, Q2's old number
    assert!(r.view.quest_held(PLAYER) == array![stamped(2, 0, 65538)].span());
    assert!(65538_u32 % 0x10000 == 2);
    assert!(r.view.quest_progress(PLAYER, 2, 0) == no_progress());
    assert!(r.mock.hook_count() == 1);
    // the next call progresses it
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 2, 0).completed);
}

/// Without a renewal, the wrapped counter changes nothing: both held quests count.
#[test]
#[available_gas(l2_gas: 14824348)]
fn quest_counter_wrap_without_renewal_progresses_both() {
    let r = wrapped_prehistory();
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_progress(PLAYER, 2, 0).completed);
}

// Fix loop 4 (exception): finding 6 of the third audit pass, pinned at the old width. Q1 (number
// 1) and Q2 (number 2) held, Q2 on task T with target 10; the player has made 65 535 more
// acceptances since. Q1's completion hook accepts **another** quest, Q3. At 16 bits Q3 got
// number 2, the number of the unchanged Q2, and fix loop 3's window then skipped Q2 and lost the
// batch's counts (this test failed on that code, seeded with the 16-bit counter 1). At 30 bits Q3
// gets 65 538 and the call compares whole entries: Q2 keeps the counts.

fn prehistory_other_accept() -> Reentrant {
    let r = deploy();
    define(r, 1, T, true);
    r.quest.define(2, one_off(), array![task(T, 10)].span(), array![].span());
    r.quest.accept(PLAYER, 2);
    define(r, 3, 9, false);
    store(
        r.address,
        map_entry_address(selector!("Quest_held"), array![PLAYER, 0].span()),
        array![StorePacking::pack(held_slot0(stamped(1, 0, 1), stamped(2, 0, 2), AFTER_PREHISTORY))]
            .span(),
    );
    r
}

#[test]
#[available_gas(l2_gas: 16871917)]
fn quest_hook_accepting_another_quest_keeps_counts_after_16_bit_wrap() {
    let r = prehistory_other_accept();
    r.mock.set_reentry(on_complete(1, 'accept', 3, 0));
    r.quest.progress(PLAYER, T, 3, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 1, 0).completed);
    assert!(r.view.quest_is_accepted(PLAYER, 3));
    // Q3's number collides with Q2's at 16 bits, not at 30
    assert!(unstamped(r.view.quest_held(PLAYER)) == array![held(2, 0), held(3, 0)].span());
    assert!(*r.view.quest_held(PLAYER)[1].acceptance == 65538);
    // Q2 was held throughout: it keeps the 3 of this batch
    assert!(r.view.quest_progress(PLAYER, 2, 0).c0 == 3);
    r.quest.progress(PLAYER, T, 1, Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 2, 0).c0 == 4);
}

// Fix loop 4: the new counter's wrap boundary, seeded. After 2^30 - 1 the counter wraps to 0.
// From there, an acceptance can get the number of an entry accepted 2^30 acceptances earlier (about
// 1.07 × 10^9 acceptances by one player, at least 7.5 × 10^14 L2 gas of their own) and still
// held;
// that is the only way two outstanding acceptances can share a whole entry.

#[test]
#[available_gas(l2_gas: 26720293)]
fn quest_acceptance_counter_wraps_at_2_30() {
    let r = deploy();
    define(r, 1, T, true);
    // the counter one short of its last value: Q1 had number 2^30 - 2, the last issued
    store(
        r.address,
        map_entry_address(selector!("Quest_held"), array![PLAYER, 0].span()),
        array![StorePacking::pack(held_slot0(stamped(1, 0, 0x3ffffffe), held(0, 0), 0x3ffffffe))]
            .span(),
    );
    define(r, 2, 8, true);
    define(r, 3, 9, true);
    // Q2 got the last number, 2^30 - 1; Q3 the first after the wrap, 0
    assert!(
        r
            .view
            .quest_held(
                PLAYER,
            ) == array![stamped(1, 0, 0x3ffffffe), stamped(2, 0, 0x3fffffff), stamped(3, 0, 0)]
            .span(),
    );
    // and progress is unaffected: whole entries are compared, all three count
    r.mock.set_reentry(on_complete(1, 'accept', 4, 0));
    r.quest.define(4, one_off(), array![task(10, 1)].span(), array![].span());
    r
        .quest
        .progress_many(PLAYER, array![entry(T, 1), entry(8, 1), entry(9, 1)].span(), Mode::Storage);
    assert!(r.view.quest_progress(PLAYER, 2, 0).completed);
    assert!(r.view.quest_progress(PLAYER, 3, 0).completed);
    // Q4, accepted by Q1's hook, got number 1; the accept pruned Q1, completed
    assert!(
        r
            .view
            .quest_held(
                PLAYER,
            ) == array![stamped(2, 0, 0x3fffffff), stamped(3, 0, 0), stamped(4, 0, 1)]
            .span(),
    );
}
