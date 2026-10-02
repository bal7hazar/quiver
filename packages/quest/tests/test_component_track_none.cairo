//! The component under `TrackNone` (ARC-07a fix loop 1), on `MockBenchSilent`: the tracked
//! models' events (`QuestDefined`, `QuestReporterSet`) are not emitted, and every action event
//! (`QuestCompleted`, `QuestClaimed`, `QuestProgressed` in event mode, `QuestRetired`) is, with
//! 0.1.0's keys and data. The state written is the same as under `TrackAll`.

use quiver_quest::errors;
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestSafeDispatcher, IQuestSafeDispatcherTrait,
    IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::types::batch::TaskProgress;
use quiver_quest::types::mode::Mode;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, spy_events, test_address,
};
use super::helpers::{one_off, task};
use super::setup::{PLAYER, assert_error};

fn deploy() -> (IQuestDispatcher, IQuestViewDispatcher) {
    let class = declare("MockBenchSilent").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    (
        IQuestDispatcher { contract_address: address },
        IQuestViewDispatcher { contract_address: address },
    )
}

#[test]
#[available_gas(l2_gas: 7089781)]
fn track_none_component_emits_action_events_only() {
    let (quest, view) = deploy();
    let mut spy = spy_events();
    // Tracked models: written, not emitted
    quest.set_reporter(test_address(), true);
    quest.define(1, one_off(), array![task(7, 2)].span(), array![].span());
    quest.define(2, one_off(), array![task(8, 1)].span(), array![].span());
    assert!(spy.get_events().events.len() == 0);
    assert!(view.quest_is_reporter(test_address()));
    let (head, tasks, _) = view.quest_definition(1);
    assert!(head.defined && tasks == array![task(7, 2)].span());
    // Accept emits nothing, as under TrackAll
    quest.accept(PLAYER, 1);
    assert!(spy.get_events().events.len() == 0);
    // Action events
    quest
        .progress_many(PLAYER, array![TaskProgress { task_id: 7, count: 2 }].span(), Mode::Storage);
    quest.claim(PLAYER, 1, 0);
    quest.progress(PLAYER, 7, 3, Mode::Event);
    quest.retire(2);
    let events = spy.get_events().events;
    assert!(events.len() == 4);
    let (from, completed) = events.at(0);
    assert!(*from == quest.contract_address);
    assert!(completed.keys == @array![selector!("QuestCompleted"), PLAYER, 1]);
    assert!(completed.data == @array![0]);
    let (_, claimed) = events.at(1);
    assert!(claimed.keys == @array![selector!("QuestClaimed"), PLAYER, 1]);
    assert!(claimed.data == @array![0]);
    let (_, progressed) = events.at(2);
    assert!(progressed.keys == @array![selector!("QuestProgressed"), PLAYER, 7]);
    assert!(progressed.data == @array![3]);
    let (_, retired) = events.at(3);
    assert!(retired.keys == @array![selector!("QuestRetired"), 2]);
    assert!(retired.data == @array![]);
    // The state is the one TrackAll writes
    let progress = view.quest_progress(PLAYER, 1, 0);
    assert!(progress.completed && progress.claimed && progress.c0 == 2);
    assert!(view.quest_record(PLAYER, 1).completions == 1);
}

#[test]
#[available_gas(l2_gas: 845009)]
fn track_none_component_revoked_reporter_emits_nothing() {
    let (quest, view) = deploy();
    let mut spy = spy_events();
    quest.set_reporter(test_address(), true);
    quest.set_reporter(test_address(), false);
    quest.set_reporter(test_address(), false);
    assert!(spy.get_events().events.len() == 0);
    assert!(!view.quest_is_reporter(test_address()));
}

/// The refusals hold under `TrackNone` (ARC-07d), on `MockSilentGuarded`, whose `authorize_admin`
/// refuses: the package's own strings, nothing emitted, nothing written.
#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 760000)]
fn track_none_refuses_with_the_packages_errors() {
    let class = declare("MockSilentGuarded").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let safe = IQuestSafeDispatcher { contract_address: address };
    let view = IQuestViewDispatcher { contract_address: address };
    let mut spy = spy_events();
    assert_error(
        safe.define(1, one_off(), array![task(7, 1)].span(), array![].span()), errors::NOT_ADMIN,
    );
    assert_error(safe.set_reporter(test_address(), true), errors::NOT_ADMIN);
    // No reporter is registered: the unregistered caller is refused as well
    assert_error(safe.progress(PLAYER, 7, 1, Mode::Storage), errors::NOT_REPORTER);
    assert!(spy.get_events().events.len() == 0);
    assert!(!view.quest_is_reporter(test_address()));
}
