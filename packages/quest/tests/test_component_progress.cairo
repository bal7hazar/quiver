//! Progress in `Mode::Storage` (ARC-01 §3.5): counts, completion, intervals, batches.

use quiver_quest::component::QuestComponent::{Event, QuestCompleted};
use quiver_quest::constants::{MAX_ENTRIES, MAX_PAGES, QUESTS_PER_PAGE};
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestProgress};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{DAY, U32_MAX, entry, one_off, same_entries, schedule, task};
use super::mocks::IMockQuestDispatcherTrait;
use super::setup::{
    DAY64, PLAYER, WEEK, as_reporter, assert_error, at, define, define_simple, deploy, report,
    report_many, stop,
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

#[test]
#[available_gas(l2_gas: 7795973)]
fn quest_inactive_quest_skipped_not_reverted() {
    let q = deploy();
    at(q, 1000);
    define_simple(q, 1, one_off(), 7, 5);
    define_simple(q, 2, schedule(2000, 0, 0, 0), 7, 5);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 1);
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 0);
}

#[test]
#[available_gas(l2_gas: 10728451)]
fn quest_count_saturates_at_total() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 7, Mode::Storage);
    report(q, PLAYER, 7, 7, Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 10, c1: 0, c2: 0, completed: true, claimed: false });
    assert!(completed_events(ref spy) == 1);
    assert!(q.mock.hook_count() == 1);
}

#[test]
#[available_gas(l2_gas: 10635642)]
fn quest_count_max_value() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, U32_MAX);
    report(q, PLAYER, 7, U32_MAX, Mode::Storage);
    report(q, PLAYER, 7, U32_MAX, Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress.c0 == U32_MAX && progress.completed);
    assert!(q.view.quest_record(PLAYER, 1).completions == 1);
}

#[test]
#[available_gas(l2_gas: 10610127)]
fn quest_one_off_completes_once() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 2);
    report(q, PLAYER, 7, 2, Mode::Storage);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 5, Mode::Storage);
    assert!(spy.get_events().events.len() == 0);
    assert!(q.mock.hook_count() == 1);
    assert!(q.view.quest_record(PLAYER, 1).completions == 1);
}

#[test]
#[available_gas(l2_gas: 21199421)]
fn quest_recurring_completes_each_interval() {
    let q = deploy();
    at(q, 0);
    define_simple(q, 1, schedule(0, 0, DAY, WEEK.try_into().unwrap()), 7, 1);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, WEEK);
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, 2 * WEEK + 5);
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
#[available_gas(l2_gas: 7593750)]
fn quest_daily_interval_aligned_on_utc_midnight() {
    let q = deploy();
    define_simple(q, 1, schedule(0, 0, DAY, DAY), 7, 10);
    let k: u64 = 20000; // 2024-10-04
    at(q, DAY64 * k - 1);
    assert!(q.view.quest_current_interval(1) == Option::Some(k - 1));
    report(q, PLAYER, 7, 1, Mode::Storage);
    at(q, DAY64 * k);
    assert!(q.view.quest_current_interval(1) == Option::Some(k));
    report(q, PLAYER, 7, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, k - 1).c0 == 1);
    assert!(q.view.quest_progress(PLAYER, 1, k).c0 == 2);
}

#[test]
#[available_gas(l2_gas: 7408057)]
fn quest_daily_rollover_starts_from_zero() {
    let q = deploy();
    at(q, 0);
    define_simple(q, 1, schedule(0, 0, DAY, DAY), 7, 10);
    report(q, PLAYER, 7, 9, Mode::Storage);
    at(q, DAY64);
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 9);
    assert!(q.view.quest_progress(PLAYER, 1, 1).c0 == 1);
    assert!(!q.view.quest_progress(PLAYER, 1, 1).completed);
}

#[test]
#[available_gas(l2_gas: 6125885)]
fn quest_interval_id_is_u64() {
    let q = deploy();
    define_simple(q, 1, schedule(0, 0, 1, 1), 7, 10);
    let time: u64 = 0x10000000000; // 2^40
    at(q, time);
    report(q, PLAYER, 7, 3, Mode::Storage);
    assert!(q.view.quest_current_interval(1) == Option::Some(time));
    assert!(q.view.quest_progress(PLAYER, 1, time).c0 == 3);
}

#[test]
#[available_gas(l2_gas: 10852624)]
fn quest_batch_two_tasks_one_quest_one_write() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span(), false);
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
#[available_gas(l2_gas: 5512322)]
fn baseline_batch_two_tasks_one_quest() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span(), false);
    let mut spy = spy_events();
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 0, c1: 0, c2: 0, completed: false, claimed: false });
    assert!(spy.get_events().events.len() == 0);
    assert!(q.mock.hook_count() == 0);
}

/// Not completing: one write, P.
#[test]
#[available_gas(l2_gas: 6587850)]
fn quest_batch_two_tasks_one_quest_one_write_not_completing() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span(), false);
    report_many(q, PLAYER, array![entry(1, 1), entry(2, 2)].span(), Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 1, c1: 2, c2: 0, completed: false, claimed: false });
}

/// Setup of `quest_batch_two_tasks_one_quest_one_write_not_completing` without the call.
#[test]
#[available_gas(l2_gas: 5380820)]
fn baseline_batch_two_tasks_one_quest_not_completing() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span(), false);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 0, c1: 0, c2: 0, completed: false, claimed: false });
}

#[test]
#[available_gas(l2_gas: 5913158)]
fn quest_batch_duplicate_entries_merged() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    report_many(q, PLAYER, array![entry(7, 4), entry(7, 4)].span(), Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 8);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 3396666)]
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
#[available_gas(l2_gas: 3122700)]
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
#[available_gas(l2_gas: 3180432)]
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
#[available_gas(l2_gas: 8989977)]
fn quest_batch_quest_on_two_entries_handled_once() {
    let q = deploy();
    define(q, 1, one_off(), array![task(1, 5), task(2, 5)].span(), array![].span(), false);
    define_simple(q, 2, one_off(), 2, 5);
    report_many(q, PLAYER, array![entry(2, 3), entry(1, 1)].span(), Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 1, c1: 3, c2: 0, completed: false, claimed: false });
    assert!(q.view.quest_progress(PLAYER, 2, 0).c0 == 3);
}

/// Players are separate: progress of one is not the other's.
#[test]
#[available_gas(l2_gas: 6032204)]
fn quest_progress_is_per_player() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 5);
    report(q, PLAYER, 7, 2, Mode::Storage);
    assert!(q.view.quest_progress(PLAYER, 1, 0).c0 == 2);
    assert!(q.view.quest_progress(super::setup::OTHER_PLAYER, 1, 0).c0 == 0);
}

/// `MAX_QUESTS_PER_TASK` live quests on one task: one progress counts on each.
#[test]
#[available_gas(l2_gas: 177360001)]
fn quest_task_shared_by_max_quests() {
    let q = deploy();
    let max: u32 = (QUESTS_PER_PAGE * MAX_PAGES).into();
    let mut id: u32 = 1;
    while id <= max {
        define_simple(q, id, one_off(), 7, 1);
        id += 1;
    }
    let mut spy = spy_events();
    report(q, PLAYER, 7, 1, Mode::Storage);
    assert!(completed_events(ref spy) == max);
    assert!(q.mock.hook_count() == max);
    let mut id: u32 = 1;
    while id <= max {
        assert!(q.view.quest_progress(PLAYER, id, 0).completed);
        id += 1;
    }
}
