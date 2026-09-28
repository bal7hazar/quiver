//! The accept step (ARC-01 §3.5 `accept`, `abandon`; A-11: an acceptance expires at rollover
//! with its progress).

use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestRecord};
use super::helpers::{DAY, one_off, schedule, task};
use super::setup::{
    DAY64, PLAYER, Quest, abandon, accept, as_owner, assert_error, at, define, define_simple,
    deploy, report, stop,
};

const Q: u32 = 1;
const T: u32 = 7;

fn with_accept(quest_schedule: quiver_quest::logic::QuestSchedule, total: u32) -> Quest {
    let q = deploy();
    at(q, 0);
    define(q, Q, quest_schedule, array![task(T, total)].span(), array![].span(), true);
    q
}

fn daily() -> quiver_quest::logic::QuestSchedule {
    schedule(0, 0, DAY, DAY)
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_required() {
    let q = with_accept(one_off(), 10);
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 0);
    accept(q, PLAYER, Q);
    assert!(q.view.quest_is_accepted(PLAYER, Q));
    report(q, PLAYER, T, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, Q, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_completion_releases_acceptance() {
    let q = with_accept(one_off(), 2);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 2, Mode::Storage);
    let record = q.view.quest_record(PLAYER, Q);
    assert!(record.completions == 1 && !record.active);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_acceptance_expires_at_rollover() {
    let q = with_accept(daily(), 10);
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
            .quest_record(PLAYER, Q) == QuestRecord {
                completions: 0, claims: 0, unlocked: false, active: true, accepted_interval: 1,
            },
    );
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_twice_same_interval_reverts() {
    let q = with_accept(daily(), 10);
    accept(q, PLAYER, Q);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, Q), errors::ALREADY_ACCEPTED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_after_completion_reverts() {
    let q = with_accept(one_off(), 1);
    accept(q, PLAYER, Q);
    report(q, PLAYER, T, 1, Mode::Storage);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, Q), errors::ALREADY_COMPLETED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_after_daily_completion() {
    let q = with_accept(daily(), 1);
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
#[available_gas(l2_gas: 1000000000)]
fn quest_abandon_expired_reverts() {
    let q = with_accept(daily(), 10);
    accept(q, PLAYER, Q);
    at(q, DAY64);
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, Q), errors::NOT_ACCEPTED);
    stop(q);
}

#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_abandon_keeps_counts() {
    let q = with_accept(one_off(), 10);
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
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_refusals() {
    let q = deploy();
    at(q, 1000);
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, schedule(5000, 0, 0, 0), array![task(T, 1)].span(), array![].span(), true);
    define(q, 3, one_off(), array![task(8, 1)].span(), array![1].span(), true);
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, 99), errors::DOES_NOT_EXIST);
    assert_error(q.safe.accept(PLAYER, 1), errors::NO_ACCEPT_STEP);
    assert_error(q.safe.accept(PLAYER, 2), errors::NOT_ACTIVE);
    assert_error(q.safe.accept(PLAYER, 3), errors::LOCKED);
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1000000000)]
fn quest_abandon_refusals() {
    let q = deploy();
    at(q, 1000);
    define(q, 2, schedule(5000, 0, 0, 0), array![task(T, 1)].span(), array![].span(), true);
    define(q, 3, one_off(), array![task(T, 1)].span(), array![].span(), true);
    as_owner(q);
    assert_error(q.safe.abandon(PLAYER, 99), errors::DOES_NOT_EXIST);
    assert_error(q.safe.abandon(PLAYER, 2), errors::NOT_ACTIVE);
    assert_error(q.safe.abandon(PLAYER, 3), errors::NOT_ACCEPTED);
    stop(q);
}

/// `accept` evaluates the prerequisites and caches the unlock.
#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_accept_caches_unlock() {
    let q = deploy();
    define_simple(q, 1, one_off(), T, 1);
    define(q, 2, one_off(), array![task(8, 5)].span(), array![1].span(), true);
    report(q, PLAYER, T, 1, Mode::Storage);
    accept(q, PLAYER, 2);
    let record = q.view.quest_record(PLAYER, 2);
    assert!(record.unlocked && record.active);
    report(q, PLAYER, 8, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 2);
}

/// Outside the schedule, a quest is not accepted, even with the record's bits set.
#[test]
#[available_gas(l2_gas: 1000000000)]
fn quest_is_accepted_false_outside_schedule() {
    let q = with_accept(schedule(0, 0, 10, DAY), 10);
    accept(q, PLAYER, Q);
    assert!(q.view.quest_is_accepted(PLAYER, Q));
    at(q, 10);
    assert!(!q.view.quest_is_accepted(PLAYER, Q));
    assert!(q.view.quest_record(PLAYER, Q).active);
}
