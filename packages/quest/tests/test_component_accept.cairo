//! The accept step, mandatory for every quest (ARC-01 §3.5 `accept`, `abandon`, amended by
//! D-135; A-11: an acceptance expires at rollover with its progress; A-12: at most `MAX_HELD`
//! held), and the held list.

use quiver_quest::constants::MAX_HELD;
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{HELD_EMPTY, Mode, QuestRecord};
use super::helpers::{
    DAY, held, held_slot, held_slot0, held_slot_k, one_off, schedule, stamped, task, unstamped,
};
use super::setup::{
    DAY64, OTHER_PLAYER, PLAYER, Quest, abandon, accept, as_owner, assert_error, at, define,
    define_simple, deploy, held_felts, held_slots, report, retire, stop,
};

const Q: u32 = 1;
const T: u32 = 7;

fn with_quest(quest_schedule: quiver_quest::logic::QuestSchedule, total: u32) -> Quest {
    let q = deploy();
    at(q, 0);
    define(q, Q, quest_schedule, array![task(T, total)].span(), array![].span());
    q
}

fn daily() -> quiver_quest::logic::QuestSchedule {
    schedule(0, 0, DAY, DAY)
}

/// Meaning changed by D-135: every quest needs acceptance, not only one defined with an accept
/// step.
#[test]
#[available_gas(l2_gas: 7175934)]
fn quest_accept_required() {
    let q = with_quest(one_off(), 10);
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 0);
    accept(q, PLAYER, Q);
    assert!(q.view.quest_is_accepted(PLAYER, Q));
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 1);
}

/// Meaning changed by D-135: the acceptance is the held entry, which completion makes dead (the
/// record has no `active` bit any more); the entry stays until the next accept prunes it.
#[test]
#[available_gas(l2_gas: 10843504)]
fn quest_completion_releases_acceptance() {
    let q = with_quest(one_off(), 2);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 2, Mode::Storage);
    assert!(q.view.quest_record(PLAYER, Q).completions == 1);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(Q, 0)].span());
}

#[test]
#[available_gas(l2_gas: 9363625)]
fn quest_acceptance_expires_at_rollover() {
    let q = with_quest(daily(), 10);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 4, Mode::Storage);
    at(q, DAY64);
    // Lost at rollover, with its progress (A-11)
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 1).c0 == 0);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 1).c0 == 1);
    // Day 0's counts stay where they were, never completed
    let day0 = q.view.quest_progress(PLAYER, Q, 0);
    assert!(day0.c0 == 4 && !day0.completed);
    assert!(
        q
            .view
            .quest_record(PLAYER, Q) == QuestRecord { completions: 0, claims: 0, unlocked: false },
    );
    // The entry of day 0 was replaced by that of day 1
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(Q, 1)].span());
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5688743)]
fn quest_accept_twice_same_interval_reverts() {
    let q = with_quest(daily(), 10);
    accept(q, PLAYER, Q);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, Q), errors::ALREADY_ACCEPTED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 10767190)]
fn quest_accept_after_completion_reverts() {
    let q = with_quest(one_off(), 1);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 1, Mode::Storage);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, Q), errors::ALREADY_COMPLETED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 11700241)]
fn quest_accept_after_daily_completion() {
    let q = with_quest(daily(), 1);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 1, Mode::Storage);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, Q), errors::ALREADY_COMPLETED);
    stop(q);
    at(q, DAY64);
    accept(q, PLAYER, Q);
    assert!(q.view.quest_is_accepted(PLAYER, Q));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5683482)]
fn quest_abandon_expired_reverts() {
    let q = with_quest(daily(), 10);
    accept(q, PLAYER, Q);
    at(q, DAY64);
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, Q), errors::NOT_ACCEPTED);
    stop(q);
}

#[test]
#[available_gas(l2_gas: 9031017)]
fn quest_abandon_keeps_counts() {
    let q = with_quest(one_off(), 10);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 3, Mode::Storage);
    abandon(q, PLAYER, Q);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 3);
    // Not accepted: no longer counts, until accepted again
    report(q, PLAYER, T, 3, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 3);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 3, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 6);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 12140709)]
fn quest_accept_refusals() {
    let q = deploy();
    at(q, 1000);
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, schedule(5000, 0, 0, 0), array![task(T, 1)].span(), array![].span());
    define(q, 3, one_off(), array![task(8, 1)].span(), array![1].span());
    retire(q, 3);
    define(q, 4, one_off(), array![task(8, 1)].span(), array![1].span());
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 99), errors::DOES_NOT_EXIST);
    assert_error(q.safe.accept(PLAYER, 3), errors::RETIRED);
    assert_error(q.safe.accept(PLAYER, 2), errors::NOT_ACTIVE);
    assert_error(q.safe.accept(PLAYER, 4), errors::LOCKED);
    stop(q);
    // Nothing was written by the refusals
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![].span());
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 6577253)]
fn quest_abandon_refusals() {
    let q = deploy();
    at(q, 1000);
    define(q, 2, schedule(5000, 0, 0, 0), array![task(T, 1)].span(), array![].span());
    define(q, 3, one_off(), array![task(T, 1)].span(), array![].span());
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, 99), errors::DOES_NOT_EXIST);
    assert_error(q.safe.abandon(PLAYER, 2), errors::NOT_ACTIVE);
    assert_error(q.safe.abandon(PLAYER, 3), errors::NOT_ACCEPTED);
    stop(q);
}

/// `accept` evaluates the prerequisites and caches the unlock.
#[test]
#[available_gas(l2_gas: 15102919)]
fn quest_accept_caches_unlock() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(8, 5)].span(), array![1].span());
    accept(q, PLAYER, 1);
    report(q, PLAYER, T, 1, Mode::Storage);
    accept(q, PLAYER, 2);
    assert!(q.view.quest_record(PLAYER, 2).unlocked);
    assert!(q.view.quest_is_accepted(PLAYER, 2));
    report(q, PLAYER, 8, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 2);
}

/// Outside the schedule, a quest is not accepted, even with its entry in the list.
#[test]
#[available_gas(l2_gas: 5866025)]
fn quest_is_accepted_false_outside_schedule() {
    let q = with_quest(schedule(0, 0, 10, DAY), 10);
    accept(q, PLAYER, Q);
    assert!(q.view.quest_is_accepted(PLAYER, Q));
    at(q, 10);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(Q, 0)].span());
}

// The held list (D-135)

/// `MAX_HELD + 1` one-off quests of one task each: quest `id` on task `10 + id`, total 1.
fn five_quests() -> Quest {
    let q = deploy();
    at(q, 0);
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() + 1 {
        define_simple(q, id, one_off(), 10 + id, 1);
        id += 1;
    }
    q
}

fn accept_first_four(q: Quest) {
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        accept(q, PLAYER, id);
        id += 1;
    }
}

/// The list full: a fifth live quest is refused, and nothing is written.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 16976862)]
fn quest_accept_list_full_reverts() {
    let q = five_quests();
    accept_first_four(q);
    let before = held_slots(q, PLAYER);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 5), errors::TOO_MANY_HELD);
    stop(q);
    assert!(held_slots(q, PLAYER) == before);
    assert!(!q.view.quest_is_accepted(PLAYER, 5));
    // The list is per player: another player still has room
    accept(q, OTHER_PLAYER, 5);
    assert!(q.view.quest_is_accepted(OTHER_PLAYER, 5));
}

/// The layout: entries two per slot, in the order of acceptance, the rest empty.
#[test]
#[available_gas(l2_gas: 13426445)]
fn quest_held_list_layout() {
    let q = five_quests();
    accept(q, PLAYER, 3);
    accept(q, PLAYER, 1);
    accept(q, PLAYER, 4);
    let slots = held_slots(q, PLAYER);
    // acceptances 1, 2, 3; slot 0 carries the counter, 3
    assert!(*slots[0] == held_slot0(stamped(3, 0, 1), stamped(1, 0, 2), 3));
    assert!(*slots[1] == held_slot(stamped(4, 0, 3), HELD_EMPTY));
    assert!(*slots[2] == held_slot(HELD_EMPTY, HELD_EMPTY));
    assert!(*slots[3] == held_slot(HELD_EMPTY, HELD_EMPTY));
    assert!(
        unstamped(q.view.quest_held(PLAYER)) == array![held(3, 0), held(1, 0), held(4, 0)].span(),
    );
}

/// An expired acceptance (A-11) stays in the list until the next accept, which prunes it: it
/// counts neither towards `MAX_HELD` nor in the list afterwards.
#[test]
#[available_gas(l2_gas: 16966782)]
fn quest_expired_acceptance_pruned() {
    let q = deploy();
    at(q, 0);
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        define_simple(q, id, daily(), 10 + id, 5);
        accept(q, PLAYER, id);
        id += 1;
    }
    define_simple(q, 9, one_off(), 19, 5);
    at(q, DAY64);
    // All four expired at rollover: in the list, not accepted
    assert!(q.view.quest_held(PLAYER).len() == 4);
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
    // They do not count: the accept succeeds and prunes all four
    accept(q, PLAYER, 9);
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(9, 0)].span());
    let slots = held_slots(q, PLAYER);
    assert!(*slots[0] == held_slot0(stamped(9, 0, 5), HELD_EMPTY, 5));
    // slot 1 is no longer used, and kept: not zeroed (fix loop 2)
    assert!(*slots[1] == held_slot_k(HELD_EMPTY, HELD_EMPTY, 0, true));
    // Re-accepting one of them on day 1 appends it
    accept(q, PLAYER, 2);
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(9, 0), held(2, 1)].span());
}

/// A completed quest leaves the list at the next accept; the live ones keep their order.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 22560139)]
fn quest_completed_leaves_list() {
    let q = five_quests();
    accept_first_four(q);
    // Quest 2 completes (task 12): its entry is dead, still in the list
    report(q, PLAYER, 12, 1, Mode::Storage);
    assert!(q.view.quest_held(PLAYER).len() == 4);
    assert!(!q.view.quest_is_accepted(PLAYER, 2));
    // Four entries, three live: quest 5 is accepted and quest 2 pruned
    accept(q, PLAYER, 5);
    assert!(
        unstamped(
            q.view.quest_held(PLAYER),
        ) == array![held(1, 0), held(3, 0), held(4, 0), held(5, 0)]
            .span(),
    );
    // A completed one-off quest cannot come back
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 2), errors::ALREADY_COMPLETED);
    stop(q);
}

/// A retired quest is dead in every list that holds it, and pruned at the next accept.
#[test]
#[available_gas(l2_gas: 16047392)]
fn quest_retired_pruned_at_accept() {
    let q = five_quests();
    accept_first_four(q);
    retire(q, 1);
    assert!(!q.view.quest_is_accepted(PLAYER, 1));
    accept(q, PLAYER, 5);
    assert!(
        unstamped(
            q.view.quest_held(PLAYER),
        ) == array![held(2, 0), held(3, 0), held(4, 0), held(5, 0)]
            .span(),
    );
}

/// `abandon` removes the quest; the later entries move up.
#[test]
#[available_gas(l2_gas: 19136639)]
fn quest_abandon_removes_from_list() {
    let q = five_quests();
    accept_first_four(q);
    abandon(q, PLAYER, 2);
    assert!(
        unstamped(q.view.quest_held(PLAYER)) == array![held(1, 0), held(3, 0), held(4, 0)].span(),
    );
    let slots = held_slots(q, PLAYER);
    // the entries keep their acceptance numbers as they move up; the counter is unchanged
    assert!(*slots[0] == held_slot0(stamped(1, 0, 1), stamped(3, 0, 3), 4));
    assert!(*slots[1] == held_slot(stamped(4, 0, 4), HELD_EMPTY));
    // Room again
    accept(q, PLAYER, 5);
    abandon(q, PLAYER, 5);
    abandon(q, PLAYER, 1);
    abandon(q, PLAYER, 3);
    abandon(q, PLAYER, 4);
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![].span());
    // an empty list keeps the counter in slot 0
    assert!(*held_slots(q, PLAYER)[0] == held_slot0(HELD_EMPTY, HELD_EMPTY, 5));
}

/// A completed quest cannot be abandoned: its acceptance ended with the completion.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 16548416)]
fn quest_abandon_completed_reverts() {
    let q = five_quests();
    accept(q, PLAYER, 1);
    report(q, PLAYER, 11, 1, Mode::Storage);
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, 1), errors::NOT_ACCEPTED);
    stop(q);
}

/// Fix loop 1, point 2: each acceptance gets the next number of the player's counter, abandoned
/// and renewed acceptances included, so that a renewed entry differs from the one it replaces.
#[test]
#[available_gas(l2_gas: 14360955)]
fn quest_acceptance_numbers_are_new_on_renewal() {
    let q = five_quests();
    accept(q, PLAYER, 1);
    accept(q, PLAYER, 2);
    abandon(q, PLAYER, 2);
    accept(q, PLAYER, 2);
    assert!(q.view.quest_held(PLAYER) == array![stamped(1, 0, 1), stamped(2, 0, 3)].span());
    // per player
    accept(q, OTHER_PLAYER, 2);
    assert!(q.view.quest_held(OTHER_PLAYER) == array![stamped(2, 0, 1)].span());
}

/// Fix loop 2 (c): a list slot the player has used is never zeroed. When the list shrinks out
/// of it (abandon, or pruning at accept), the slot keeps a marker, so that the next growth into
/// it overwrites a slot instead of creating one.
#[test]
#[available_gas(l2_gas: 17547317)]
fn quest_held_slot_kept_after_shrink() {
    let q = five_quests();
    accept(q, PLAYER, 1);
    accept(q, PLAYER, 2);
    accept(q, PLAYER, 3);
    // slot 1 holds quest 3
    assert!(*held_felts(q, PLAYER)[1] != 0);
    abandon(q, PLAYER, 3);
    // the list no longer uses slot 1, which is not zeroed
    assert!(*held_felts(q, PLAYER)[1] != 0);
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(1, 0), held(2, 0)].span());
    // slots never used stay zero
    assert!(*held_felts(q, PLAYER)[2] == 0);
    // the list grows back into slot 1
    accept(q, PLAYER, 4);
    assert!(
        unstamped(q.view.quest_held(PLAYER)) == array![held(1, 0), held(2, 0), held(4, 0)].span(),
    );
    // abandoning everything keeps slots 0 and 1, and the list reads empty
    abandon(q, PLAYER, 1);
    abandon(q, PLAYER, 2);
    abandon(q, PLAYER, 4);
    assert!(q.view.quest_held(PLAYER) == array![].span());
    assert!(*held_felts(q, PLAYER)[0] != 0 && *held_felts(q, PLAYER)[1] != 0);
}

/// Pruning at accept keeps the slots too: four dead entries pruned leave slot 1 marked.
#[test]
#[available_gas(l2_gas: 36790377)]
fn quest_held_slot_kept_after_pruning() {
    let q = five_quests();
    accept_first_four(q);
    report(q, PLAYER, 11, 1, Mode::Storage);
    report(q, PLAYER, 12, 1, Mode::Storage);
    report(q, PLAYER, 13, 1, Mode::Storage);
    report(q, PLAYER, 14, 1, Mode::Storage);
    accept(q, PLAYER, 5);
    assert!(unstamped(q.view.quest_held(PLAYER)) == array![held(5, 0)].span());
    assert!(*held_felts(q, PLAYER)[1] != 0);
}
