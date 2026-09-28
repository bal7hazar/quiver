//! `Mode::Event` (ARC-01 §2 D-1, §3.7): one `QuestProgressed` per merged non-zero entry, and
//! nothing read, written or called.

use quiver_quest::component::QuestComponent::{Event, QuestProgressed};
use quiver_quest::errors;
use quiver_quest::interface::{IQuestSafeDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestProgress};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{entry, no_progress, no_record, one_off};
use super::mocks::IMockQuestDispatcherTrait;
use super::setup::{
    PLAYER, as_owner, assert_error, define_simple, deploy, report, report_many, stop,
};

#[test]
#[available_gas(l2_gas: 5438681)]
fn quest_event_mode_emits_only_progressed() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 3, Mode::Event);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestProgressed(
                        QuestProgressed { player_id: PLAYER, task_id: 7, count: 3 },
                    ),
                ),
            ],
        );
    assert!(q.view.quest_progress(PLAYER, 1, 0) == no_progress());
    assert!(q.view.quest_record(PLAYER, 1) == no_record());
}

#[test]
#[available_gas(l2_gas: 5192183)]
fn quest_event_mode_calls_no_hook() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    let mut spy = spy_events();
    report(q, PLAYER, 7, 10, Mode::Event);
    assert!(q.mock.hook_count() == 0);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (_, event) = events.at(0);
    assert!(*event.keys.at(0) == selector!("QuestProgressed"));
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 5706421)]
fn quest_event_mode_cannot_be_claimed() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    report(q, PLAYER, 7, 10, Mode::Event);
    as_owner(q);
    assert_error(q.safe.claim(PLAYER, 1, 0), errors::NOT_COMPLETED);
    stop(q);
}

#[test]
#[available_gas(l2_gas: 6257362)]
fn quest_modes_do_not_mix() {
    let q = deploy();
    define_simple(q, 1, one_off(), 7, 10);
    report(q, PLAYER, 7, 6, Mode::Event);
    report(q, PLAYER, 7, 6, Mode::Storage);
    let progress = q.view.quest_progress(PLAYER, 1, 0);
    assert!(progress == QuestProgress { c0: 6, c1: 0, c2: 0, completed: false, claimed: false });
}

#[test]
#[available_gas(l2_gas: 5498912)]
fn quest_batch_event_mode_one_event_per_task() {
    let q = deploy();
    define_simple(q, 1, one_off(), 1, 10);
    let mut spy = spy_events();
    report_many(
        q, PLAYER, array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span(), Mode::Event,
    );
    let events = spy.get_events().events;
    assert!(events.len() == 2);
    spy
        .assert_emitted(
            @array![
                (
                    q.address,
                    Event::QuestProgressed(
                        QuestProgressed { player_id: PLAYER, task_id: 1, count: 3 },
                    ),
                ),
                (
                    q.address,
                    Event::QuestProgressed(
                        QuestProgressed { player_id: PLAYER, task_id: 3, count: 1 },
                    ),
                ),
            ],
        );
    // Event mode reads and writes nothing: quest 1 on task 1 is untouched
    assert!(q.view.quest_progress(PLAYER, 1, 0) == no_progress());
}

#[test]
#[available_gas(l2_gas: 3323458)]
fn quest_event_mode_zero_count_emits_nothing() {
    let q = deploy();
    let mut spy = spy_events();
    report(q, PLAYER, 7, 0, Mode::Event);
    report_many(q, PLAYER, array![entry(7, 0), entry(8, 0)].span(), Mode::Event);
    assert!(spy.get_events().events.len() == 0);
}
