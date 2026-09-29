//! Progress in `Mode::Storage` (ARC-01 §3.5, amended by D-135): counts, completion, intervals,
//! batches, the held list.

use quiver_quest::component::QuestComponent::{Event, QuestCompleted};
use quiver_quest::constants::{MAX_ENTRIES, MAX_HELD};
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestProgress};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{DAY, U32_MAX, entry, one_off, same_entries, schedule, task};
use super::mocks::IMockQuestDispatcherTrait;
use super::setup::{
    DAY64, OTHER_PLAYER, PLAYER, WEEK, accept, as_reporter, assert_error, at, define, define_held,
    define_simple, deploy, report, report_many, stop,
};

fn completed_events(ref spy: snforge_std::EventSpy) -> u32 {
    let mut n = 0;
    for (_, event) in spy.get_events().events {
        if *event.keys[0] == selector!("QuestCompleted") {
            n += 1;
        }
    }
    n
}

/// D-135: a quest is held only once accepted, so a quest not active cannot be held. The held
/// quest that is inactive is one whose window closed within the interval of its acceptance.
#[test]
#[available_gas(l2_gas: 8818379)]
fn quest_inactive_quest_skipped_not_reverted() {
    let q = deploy();
    at(q, 50);
    define_held(q, 1, one_off(), 7, 5);
    // active for the first 100 seconds of each day
    define_held(q, 2, schedule(0, 0, 100, DAY), 7, 5);
    at(q, 1000);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 1);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 0);
}

#[test]
#[available_gas(l2_gas: 11102419)]
fn quest_count_saturates_at_total() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 10);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 7, Mode::Storage);
    report(q, PLAYER, 7, 7, Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 10, c1: 0, c2: 0, completed: true, claimed: false });
    assert!(completed_events(ref spy) == 1);
    assert!(q.mock.hook_count() == 1);
}

#[test]
#[available_gas(l2_gas: 10969069)]
fn quest_count_max_value() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, U32_MAX);
    report(q, PLAYER, 7, U32_MAX, Mode::Storage);
    report(q, PLAYER, 7, U32_MAX, Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress.c0 == U32_MAX && progress.completed);
    assert!(q.view.quest_record(PLAYER, 1).completions == 1);
}

#[test]
#[available_gas(l2_gas: 10943869)]
fn quest_one_off_completes_once() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 2);
    report(q, PLAYER, 7, 2, Mode::Storage);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 5, Mode::Storage);
    assert!(spy.get_events().events.len() == 0);
    assert!(q.mock.hook_count() == 1);
    assert!(q.view.quest_record(PLAYER, 1).completions == 1);
}

#[test]
#[available_gas(l2_gas: 22625499)]
fn quest_recurring_completes_each_interval() {
    let q = deploy();
    at(q, 0);
    define_held(q, 1, schedule(0, 0, DAY, WEEK.try_into().unwrap()), 7, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, WEEK);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, 2 * WEEK + 5);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_record(PLAYER, 1).completions == 3);
    assert!(q.mock.hook_count() == 3);
    let mut i = 0;
    while i < 3 {
        let call = q.mock.hook_call(i);
        assert!(call.kind == 'complete' && call.interval_id == i.into());
        assert!(call.value == i.into() + 1);
        i += 1;
    }
    // Outside the day of week 3: skipped
    at(q, 3 * WEEK + DAY64);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_record(PLAYER, 1).completions == 3);
}

#[test]
#[available_gas(l2_gas: 8546667)]
fn quest_daily_interval_aligned_on_utc_midnight() {
    let q = deploy();
    define_simple(q, 1, schedule(0, 0, DAY, DAY), 7, 10);
    let k: u64 = 20000; // 2024-10-04
    at(q, DAY64 * k - 1);
    assert!(q.view.quest_current_interval(1) == Option::Some(k - 1));
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, DAY64 * k);
    assert!(q.view.quest_current_interval(1) == Option::Some(k));
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, k - 1).c0 == 1);
    assert!(q.view.quest_progress(PLAYER, 1, k).c0 == 2);
}

#[test]
#[available_gas(l2_gas: 8365132)]
fn quest_daily_rollover_starts_from_zero() {
    let q = deploy();
    at(q, 0);
    define_held(q, 1, schedule(0, 0, DAY, DAY), 7, 10);
    report(q, PLAYER, 7, 9, Mode::Storage);
    at(q, DAY64);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 9);
    assert!(q.view.quest_progress(PLAYER, 1, 1).c0 == 1);
    assert!(!q.view.quest_progress(PLAYER, 1, 1).completed);
}

#[test]
#[available_gas(l2_gas: 6528497)]
fn quest_interval_id_is_u64() {
    let q = deploy();
    define_simple(q, 1, schedule(0, 0, 1, 1), 7, 10);
    let time: u64 = 0x10000000000; // 2^40
    at(q, time);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 3, Mode::Storage);
    assert!(q.view.quest_current_interval(1) == Option::Some(time));
    assert!(q.view.quest_progress(PLAYER, 1, time).c0 == 3);
}

#[test]
#[available_gas(l2_gas: 10589242)]
fn quest_batch_two_tasks_one_quest_one_write() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span());
    accept(q, PLAYER, 1);
    let mut spy = spy_events();
    report_many(q, PLAYER, array![entry(1, 5), entry(2, 5)].span(), Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 5, c1: 5, c2: 0, completed: true, claimed: false });
    assert!(spy.get_events().events.len() == 1);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestCompleted(
                        QuestCompleted { player_id: PLAYER, quest_id: 1, interval_id: 0 },
                    ),
                ),
            ],
        );
    assert!(q.mock.hook_count() == 1);
}

/// Setup of `quest_batch_two_tasks_one_quest_one_write` without the call: the difference of
/// their syscall counts (`snforge test --detailed-resources`) is the call's reads and writes.
#[test]
#[available_gas(l2_gas: 5393850)]
fn baseline_batch_two_tasks_one_quest() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span());
    accept(q, PLAYER, 1);
    let mut spy = spy_events();
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 0, c1: 0, c2: 0, completed: false, claimed: false });
    assert!(spy.get_events().events.len() == 0);
    assert!(q.mock.hook_count() == 0);
}

/// Not completing: one write, P.
#[test]
#[available_gas(l2_gas: 6330253)]
fn quest_batch_two_tasks_one_quest_one_write_not_completing() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span());
    accept(q, PLAYER, 1);
    report_many(q, PLAYER, array![entry(1, 1), entry(2, 2)].span(), Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 1, c1: 2, c2: 0, completed: false, claimed: false });
}

/// Setup of `quest_batch_two_tasks_one_quest_one_write_not_completing` without the call.
#[test]
#[available_gas(l2_gas: 5262348)]
fn baseline_batch_two_tasks_one_quest_not_completing() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span());
    accept(q, PLAYER, 1);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 0, c1: 0, c2: 0, completed: false, claimed: false });
}

#[test]
#[available_gas(l2_gas: 6316117)]
fn quest_batch_duplicate_entries_merged() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 10);
    report_many(q, PLAYER, array![entry(7, 4), entry(7, 4)].span(), Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 8);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3492573)]
fn quest_batch_above_bound_reverts() {
    let q = deploy();
    let mut entries = array![];
    let mut i: u32 = 1;
    while i <= MAX_ENTRIES + 1 {
        entries.append(entry(i, 1));
        i += 1;
    }
    as_reporter(q);
    assert_error(
        q.safe.progress_many(PLAYER, entries.span(), Mode::Storage), errors::TOO_MANY_ENTRIES,
    );
    assert_error(
        q.safe.progress_many(PLAYER, entries.span(), Mode::Event), errors::TOO_MANY_ENTRIES,
    );
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3170549)]
fn quest_batch_duplicates_count_toward_bound() {
    let q = deploy();
    as_reporter(q);
    assert_error(
        q.safe.progress_many(PLAYER, same_entries(7, MAX_ENTRIES + 1, 1), Mode::Storage),
        errors::TOO_MANY_ENTRIES,
    );
    stop(q);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3276339)]
fn quest_batch_rejects_task_zero() {
    let q = deploy();
    as_reporter(q);
    assert_error(
        q.safe.progress_many(PLAYER, array![entry(0, 1)].span(), Mode::Storage),
        errors::INVALID_TASK,
    );
    assert_error(q.safe.progress(PLAYER, 0, 1, Mode::Event), errors::INVALID_TASK);
    stop(q);
}

/// A quest with two tasks reached through both entries of a batch counts both, once.
#[test]
#[available_gas(l2_gas: 9298750)]
fn quest_batch_quest_on_two_entries_handled_once() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span());
    accept(q, PLAYER, 1);
    define_held(q, 2, one_off(), 2, 5);
    report_many(q, PLAYER, array![entry(2, 3), entry(1, 1)].span(), Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 1, c1: 3, c2: 0, completed: false, claimed: false });
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 3);
}

/// Players are separate: progress of one is not the other's.
#[test]
#[available_gas(l2_gas: 6435163)]
fn quest_progress_is_per_player() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 5);
    report(q, PLAYER, 7, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 2);
    assert!(q.view.quest_progress(OTHER_PLAYER, 1, 0).c0 == 0);
}

/// D-135: a quest held by one player is not progressed by a call for another, who does not hold
/// it; each player's call walks that player's own list.
#[test]
#[available_gas(l2_gas: 10536984)]
fn quest_held_by_one_player_not_progressed_by_another() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 5);
    define_simple(q, 2, one_off(), 7, 5);
    accept(q, PLAYER, 1);
    accept(q, OTHER_PLAYER, 2);
    report(q, OTHER_PLAYER, 7, 3, Mode::Storage);
    assert!(q.view.quest_progress(OTHER_PLAYER, 1, 0).c0 == 0);
    assert!(q.view.quest_progress(OTHER_PLAYER, 2, 0).c0 == 3);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 0);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 0);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 1);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 0);
}

/// D-135: a quest is progressed only while held; before `accept`, or when not accepted at all,
/// progress on its task counts nothing.
#[test]
#[available_gas(l2_gas: 6842170)]
fn quest_not_held_not_progressed() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 5);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 5, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 0);
    assert!(spy.get_events().events.len() == 0);
    accept(q, PLAYER, 1);
    report(q, PLAYER, 7, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 2);
}

/// Meaning changed by D-135: many quests may share a task (28 here, the old page bound, and no
/// cap now); one progress counts on the `MAX_HELD` the player holds, and on no other.
#[test]
#[available_gas(l2_gas: 70213769)]
fn quest_task_shared_by_max_quests() {
    let q = deploy();
    let defined: u32 = 28;
    let held: u32 = MAX_HELD.into();
    let mut id: u32 = 1;
    while id <= defined {
        define_simple(q, id, one_off(), 7, 1);
        id += 1;
    }
    // the last MAX_HELD quests defined are held
    let mut id: u32 = defined - held + 1;
    while id <= defined {
        accept(q, PLAYER, id);
        id += 1;
    }
    let mut spy = spy_events();
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(completed_events(ref spy) == held);
    assert!(q.mock.hook_count() == held);
    let mut id: u32 = 1;
    while id <= defined {
        assert!(q.view.quest_progress(PLAYER, id, 0).completed == (id > defined - held));
        id += 1;
    }
}
