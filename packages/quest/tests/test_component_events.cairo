//! Events (ARC-01 §3.4), checked felt by felt: the keys the indexer filters on, then the data.
//! And the views that are not covered elsewhere.

use quiver_quest::interface::IQuestViewDispatcherTrait;
use quiver_quest::logic::Mode;
use snforge_std::{EventSpyTrait, spy_events};
use super::helpers::{one_off, schedule, task};
use super::setup::{PLAYER, at, claim, define, define_held, define_simple, deploy, report, retire};

#[test]
#[available_gas(l2_gas: 16666810)]
fn quest_events_keys_and_data() {
    let q = deploy();
    define_held(q, 1, one_off(), 7, 2);
    let mut spy = spy_events();
    define(q, 2, schedule(10, 20, 3, 4), array![task(8, 5), task(9, 6)].span(), array![1].span());
    report(q, PLAYER, 7, 3, Mode::Event);
    report(q, PLAYER, 7, 2, Mode::Storage);
    claim(q, PLAYER, 1, 0);
    retire(q, 2);
    let events = spy.get_events().events;
    assert!(events.len() == 5);
    for (from, _) in events.span() {
        assert!(*from == q.address);
    }
    let (_, defined) = events.at(0);
    assert!(defined.keys == @array![selector!("QuestDefined"), 2]);
    // schedule (start, end, duration, interval), tasks [len, (id, total)...], conditions
    // [len, ids...]
    assert!(defined.data == @array![10, 20, 3, 4, 2, 8, 5, 9, 6, 1, 1]);
    let (_, progressed) = events.at(1);
    assert!(progressed.keys == @array![selector!("QuestProgressed"), PLAYER, 7]);
    assert!(progressed.data == @array![3]);
    let (_, completed) = events.at(2);
    assert!(completed.keys == @array![selector!("QuestCompleted"), PLAYER, 1]);
    assert!(completed.data == @array![0]);
    let (_, claimed) = events.at(3);
    assert!(claimed.keys == @array![selector!("QuestClaimed"), PLAYER, 1]);
    assert!(claimed.data == @array![0]);
    let (_, retired) = events.at(4);
    assert!(retired.keys == @array![selector!("QuestRetired"), 2]);
    assert!(retired.data == @array![]);
}

/// Accept and abandon emit nothing (§3.4).
#[test]
#[available_gas(l2_gas: 5667417)]
fn quest_accept_and_abandon_emit_nothing() {
    let q = deploy();
    define(q, 1, one_off(), array![task(7, 5)].span(), array![].span());
    let mut spy = spy_events();
    super::setup::accept(q, PLAYER, 1);
    super::setup::abandon(q, PLAYER, 1);
    assert!(spy.get_events().events.len() == 0);
}

#[test]
#[available_gas(l2_gas: 5231489)]
fn quest_current_interval_view() {
    let q = deploy();
    at(q, 100);
    define_simple(q, 1, schedule(1000, 5000, 10, 100), 7, 1);
    // Not defined; before the start; in interval 2; between two windows; after the end
    assert!(q.view.quest_current_interval(99) == Option::None);
    assert!(q.view.quest_current_interval(1) == Option::None);
    at(q, 1205);
    assert!(q.view.quest_current_interval(1) == Option::Some(2));
    at(q, 1250);
    assert!(q.view.quest_current_interval(1) == Option::None);
    at(q, 5000);
    assert!(q.view.quest_current_interval(1) == Option::None);
}
