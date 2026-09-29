//! Prerequisites (ARC-01 §2 D-2 to D-6, §3.2, amended by D-135): a quest is unlocked once each of
//! its conditions has been completed at least once, whenever that was. They are checked when the
//! quest is accepted, which caches the unlock; progress does not read them.

use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestRecord};
use super::helpers::{DAY, one_off, schedule, task};
use super::mocks::IMockQuestDispatcherTrait;
use super::setup::{
    DAY64, PLAYER, WEEK, accept, as_owner, assert_error, at, define, define_held, define_simple,
    deploy, report, stop,
};

const A: u32 = 1;
const B: u32 = 2;
const C: u32 = 3;
const T_A: u32 = 11;
const T_B: u32 = 12;
const T_C: u32 = 13;

/// Meaning changed by D-135: C cannot be accepted while locked, so progress on its task cannot
/// count.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 15721044)]
fn quest_prerequisites_all_required() {
    let q = deploy();
    define_held(q, A, one_off(), T_A, 1);
    define_simple(q, B, one_off(), T_B, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A, B].span());
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(!q.view.quest_is_unlocked(PLAYER, C));
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, C), errors::LOCKED);
    stop(q);
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 0);
    // Only A's completion called a hook
    assert!(q.mock.hook_count() == 1);
    let call = q.mock.hook_call(0);
    assert!(call.kind == 'complete' && call.quest_id == A);
}

/// Meaning changed by D-135: the unlock is cached by `accept`, not by the first progress.
#[test]
#[available_gas(l2_gas: 22542595)]
fn quest_prerequisites_unlock_after_last() {
    let q = deploy();
    define_held(q, A, one_off(), T_A, 1);
    define_held(q, B, one_off(), T_B, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A, B].span());
    report(q, PLAYER, T_A, 1, Mode::Storage);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_is_unlocked(PLAYER, C));
    accept(q, PLAYER, C);
    assert!(q.view.quest_record(PLAYER, C).unlocked);
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 12809188)]
fn quest_inactive_dependent_does_not_revert() {
    let q = deploy();
    let t0: u64 = 1000;
    at(q, t0);
    define_held(q, A, one_off(), T_A, 3);
    define(q, B, schedule(t0 + WEEK, 0, 0, 0), array![task(T_B, 1)].span(), array![A].span());
    report(q, PLAYER, T_A, 3, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, A, 0).completed);
    assert!(q.mock.hook_count() == 1);
    let call = q.mock.hook_call(0);
    assert!(call.kind == 'complete' && call.quest_id == A && call.value == 1);
}

/// Meaning changed by D-135: before its window, B cannot be accepted (`'Quest: not active'`), so
/// progress on its task counts nothing; once the window opens it is accepted and counts.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 15791368)]
fn quest_dependent_unlocks_when_window_opens() {
    let q = deploy();
    let t0: u64 = 1000;
    at(q, t0);
    define_held(q, A, one_off(), T_A, 3);
    define(q, B, schedule(t0 + WEEK, 0, 0, 0), array![task(T_B, 5)].span(), array![A].span());
    report(q, PLAYER, T_A, 3, Mode::Storage);
    // Before the window: not accepted, skipped, not reverted
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, B), errors::NOT_ACTIVE);
    stop(q);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 0);
    at(q, t0 + WEEK);
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

/// A weekly (active one day a week), B one-off with `[A]`.
fn weekly_prerequisite_and_one_off_dependent() -> super::setup::Quest {
    let q = deploy();
    at(q, 0);
    define(
        q,
        A,
        schedule(0, 0, DAY, WEEK.try_into().unwrap()),
        array![task(T_A, 1)].span(),
        array![].span(),
    );
    define(q, B, one_off(), array![task(T_B, 1)].span(), array![A].span());
    q
}

/// A accepted and completed in its current week.
fn complete_a(q: super::setup::Quest) {
    accept(q, PLAYER, A);
    report(q, PLAYER, T_A, 1, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 23431819)]
fn quest_recurring_prerequisite_completes_every_interval() {
    let q = weekly_prerequisite_and_one_off_dependent();
    complete_a(q);
    at(q, WEEK);
    complete_a(q);
    at(q, 2 * WEEK);
    complete_a(q);
    assert!(q.view.quest_record(PLAYER, A).completions == 3);
    assert!(q.view.quest_progress(PLAYER, A, 2).completed);
    assert!(q.view.quest_is_unlocked(PLAYER, B));
}

#[test]
#[available_gas(l2_gas: 23580268)]
fn quest_recurring_prerequisite_after_dependent_completed() {
    let q = weekly_prerequisite_and_one_off_dependent();
    complete_a(q);
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    let record = q.view.quest_record(PLAYER, B);
    assert!(record == QuestRecord { completions: 1, claims: 0, unlocked: true });
    at(q, WEEK);
    complete_a(q);
    assert!(q.view.quest_record(PLAYER, A).completions == 2);
    assert!(q.view.quest_record(PLAYER, B) == record);
}

#[test]
#[available_gas(l2_gas: 24044883)]
fn quest_recurring_dependent_stays_unlocked() {
    let q = deploy();
    at(q, 0);
    define_held(q, A, one_off(), T_A, 1);
    define(q, B, schedule(0, 0, DAY, DAY), array![task(T_B, 2)].span(), array![A].span());
    report(q, PLAYER, T_A, 1, Mode::Storage);
    at(q, DAY64);
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 2, Mode::Storage);
    at(q, 5 * DAY64);
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 1).completed);
    assert!(q.view.quest_progress(PLAYER, B, 5).completed);
    assert!(q.view.quest_record(PLAYER, B).completions == 2);
}

#[test]
#[available_gas(l2_gas: 14629947)]
fn quest_prerequisite_completed_before_definition() {
    let q = deploy();
    define_held(q, A, one_off(), T_A, 1);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span());
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 14712172)]
fn quest_recurring_prerequisite_completed_before_definition() {
    let q = deploy();
    at(q, 0);
    define_held(q, A, schedule(0, 0, DAY, DAY), T_A, 1);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span());
    accept(q, PLAYER, B);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 12612764)]
fn quest_is_unlocked_evaluates_uncached() {
    let q = deploy();
    define_held(q, A, one_off(), T_A, 1);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span());
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(q.view.quest_is_unlocked(PLAYER, B));
    assert!(!q.view.quest_record(PLAYER, B).unlocked);
}

#[test]
#[available_gas(l2_gas: 4249025)]
fn quest_without_conditions_is_unlocked() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    assert!(q.view.quest_is_unlocked(PLAYER, A));
}

/// A locked quest cannot be accepted and caches nothing; once its prerequisite is met, `accept`
/// caches the unlock and the quest counts.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 15493141)]
fn quest_unlock_cached_by_accept() {
    let q = deploy();
    define_held(q, A, one_off(), T_A, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A].span());
    as_owner(q);
    assert_error(q.safe.accept(PLAYER, C), errors::LOCKED);
    stop(q);
    assert!(!q.view.quest_record(PLAYER, C).unlocked);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    accept(q, PLAYER, C);
    assert!(q.view.quest_record(PLAYER, C).unlocked);
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 1);
}
