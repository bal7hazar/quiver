//! Tracking by an impl of the consumer's own (ARC-07c, as ARC-07b's fix loop 1 did for
//! `quiver_achievement`), as the README's tracking table documents: `MockTrackDefinitionOnly`
//! (`DEFINITION = true, REPORTER = false`) and its mirror `MockTrackReporterOnly`. Each constant
//! governs its own model's event only: the two cannot be swapped in the store without failing
//! here, which `TrackAll` and `TrackNone` alone could not tell.

use quiver_quest::interface::{IQuestDispatcher, IQuestDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, spy_events, test_address,
};
use super::helpers::{one_off, task};

fn deploy(name: ByteArray) -> IQuestDispatcher {
    let class = declare(name).unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IQuestDispatcher { contract_address: address }
}

#[test]
#[available_gas(l2_gas: 2120423)]
fn own_impl_tracks_the_definition_only() {
    let quest = deploy("MockTrackDefinitionOnly");
    let mut spy = spy_events();
    quest.set_reporter(test_address(), true);
    assert!(spy.get_events().events.len() == 0);
    quest.define(5, one_off(), array![task(7, 10)].span(), array![].span());
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == quest.contract_address);
    assert!(event.keys == @array![selector!("QuestDefined"), 5]);
    // schedule (start, end, duration, interval), tasks [len, (id, total)...], conditions [len]
    assert!(event.data == @array![0, 0, 0, 0, 1, 7, 10, 0]);
}

#[test]
#[available_gas(l2_gas: 2048676)]
fn own_impl_tracks_the_reporter_only() {
    let quest = deploy("MockTrackReporterOnly");
    let mut spy = spy_events();
    quest.define(5, one_off(), array![task(7, 10)].span(), array![].span());
    assert!(spy.get_events().events.len() == 0);
    quest.set_reporter(test_address(), true);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == quest.contract_address);
    assert!(event.keys == @array![selector!("QuestReporterSet"), test_address().into()]);
    assert!(event.data == @array![1]);
}
