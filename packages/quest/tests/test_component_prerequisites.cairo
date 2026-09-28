//! Prerequisites, evaluated lazily (ARC-01 §2 D-2 to D-6, §3.2): a quest is unlocked once each
//! of its conditions has been completed at least once, whenever that was.

use quiver_quest::interface::IQuestViewDispatcherTrait;
use quiver_quest::logic::{Mode, QuestRecord};
use super::helpers::{DAY, one_off, schedule, task};
use super::mocks::IMockQuestDispatcherTrait;
use super::setup::{DAY64, PLAYER, WEEK, at, define, define_simple, deploy, report};

const A: u32 = 1;
const B: u32 = 2;
const C: u32 = 3;
const T_A: u32 = 11;
const T_B: u32 = 12;
const T_C: u32 = 13;

#[test]
#[available_gas(l2_gas: 16093006)]
fn quest_prerequisites_all_required() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    define_simple(q, B, one_off(), T_B, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A, B].span(), false);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(!q.view.quest_is_unlocked(PLAYER, C));
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 0);
    // Only A's completion called a hook
    assert!(q.mock.hook_count() == 1);
    let call = q.mock.hook_call(0);
    assert!(call.kind == 'complete' && call.quest_id == A);
}

#[test]
#[available_gas(l2_gas: 21593983)]
fn quest_prerequisites_unlock_after_last() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    define_simple(q, B, one_off(), T_B, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A, B].span(), false);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_is_unlocked(PLAYER, C));
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 1);
    // The first progress on C cached the unlock
    assert!(q.view.quest_record(PLAYER, C).unlocked);
}

#[test]
#[available_gas(l2_gas: 13004530)]
fn quest_inactive_dependent_does_not_revert() {
    let q = deploy();
    let t0: u64 = 1000;
    at(q, t0);
    define_simple(q, A, one_off(), T_A, 3);
    define(
        q, B, schedule(t0 + WEEK, 0, 0, 0), array![task(T_B, 1)].span(), array![A].span(), false,
    );
    report(q, PLAYER, T_A, 3, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, A, 0).completed);
    assert!(q.mock.hook_count() == 1);
    let call = q.mock.hook_call(0);
    assert!(call.kind == 'complete' && call.quest_id == A && call.value == 1);
}

#[test]
#[available_gas(l2_gas: 15039390)]
fn quest_dependent_unlocks_when_window_opens() {
    let q = deploy();
    let t0: u64 = 1000;
    at(q, t0);
    define_simple(q, A, one_off(), T_A, 3);
    define(
        q, B, schedule(t0 + WEEK, 0, 0, 0), array![task(T_B, 5)].span(), array![A].span(), false,
    );
    report(q, PLAYER, T_A, 3, Mode::Storage);
    // Before the window: skipped, not reverted
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 0);
    at(q, t0 + WEEK);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

/// P weekly (active one day a week), D one-off with `[P]`.
fn weekly_prerequisite_and_one_off_dependent() -> super::setup::Quest {
    let q = deploy();
    at(q, 0);
    define(
        q,
        A,
        schedule(0, 0, DAY, WEEK.try_into().unwrap()),
        array![task(T_A, 1)].span(),
        array![].span(),
        false,
    );
    define(q, B, one_off(), array![task(T_B, 1)].span(), array![A].span(), false);
    q
}

#[test]
#[available_gas(l2_gas: 22612420)]
fn quest_recurring_prerequisite_completes_every_interval() {
    let q = weekly_prerequisite_and_one_off_dependent();
    report(q, PLAYER, T_A, 1, Mode::Storage);
    at(q, WEEK);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    at(q, 2 * WEEK);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(q.view.quest_record(PLAYER, A).completions == 3);
    assert!(q.view.quest_progress(PLAYER, A, 2).completed);
    assert!(q.view.quest_is_unlocked(PLAYER, B));
}

#[test]
#[available_gas(l2_gas: 22496658)]
fn quest_recurring_prerequisite_after_dependent_completed() {
    let q = weekly_prerequisite_and_one_off_dependent();
    report(q, PLAYER, T_A, 1, Mode::Storage);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    let record = q.view.quest_record(PLAYER, B);
    assert!(
        record == QuestRecord {
            completions: 1, claims: 0, unlocked: true, active: false, accepted_interval: 0,
        },
    );
    at(q, WEEK);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(q.view.quest_record(PLAYER, A).completions == 2);
    assert!(q.view.quest_record(PLAYER, B) == record);
}

#[test]
#[available_gas(l2_gas: 23003692)]
fn quest_recurring_dependent_stays_unlocked() {
    let q = deploy();
    at(q, 0);
    define_simple(q, A, one_off(), T_A, 1);
    define(q, B, schedule(0, 0, DAY, DAY), array![task(T_B, 2)].span(), array![A].span(), false);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    at(q, DAY64);
    report(q, PLAYER, T_B, 2, Mode::Storage);
    at(q, 5 * DAY64);
    report(q, PLAYER, T_B, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 1).completed);
    assert!(q.view.quest_progress(PLAYER, B, 5).completed);
    assert!(q.view.quest_record(PLAYER, B).completions == 2);
}

#[test]
#[available_gas(l2_gas: 14226201)]
fn quest_prerequisite_completed_before_definition() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span(), false);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 14304961)]
fn quest_recurring_prerequisite_completed_before_definition() {
    let q = deploy();
    at(q, 0);
    define_simple(q, A, schedule(0, 0, DAY, DAY), T_A, 1);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span(), false);
    report(q, PLAYER, T_B, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, B, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 12829012)]
fn quest_is_unlocked_evaluates_uncached() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    define(q, B, one_off(), array![task(T_B, 5)].span(), array![A].span(), false);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    assert!(q.view.quest_is_unlocked(PLAYER, B));
    assert!(!q.view.quest_record(PLAYER, B).unlocked);
}

#[test]
#[available_gas(l2_gas: 4811384)]
fn quest_without_conditions_is_unlocked() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    assert!(q.view.quest_is_unlocked(PLAYER, A));
}

/// A locked quest counts nothing and caches nothing; once its prerequisite is met, its next
/// progress counts and caches the unlock.
#[test]
#[available_gas(l2_gas: 15330208)]
fn quest_unlock_cached_by_progress() {
    let q = deploy();
    define_simple(q, A, one_off(), T_A, 1);
    define(q, C, one_off(), array![task(T_C, 5)].span(), array![A].span(), false);
    report(q, PLAYER, T_C, 1, Mode::Storage);
    // Locked: nothing counted, nothing cached
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 0);
    assert!(!q.view.quest_record(PLAYER, C).unlocked);
    report(q, PLAYER, T_A, 1, Mode::Storage);
    report(q, PLAYER, T_C, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, C, 0).c0 == 1);
    assert!(q.view.quest_record(PLAYER, C).unlocked);
}
