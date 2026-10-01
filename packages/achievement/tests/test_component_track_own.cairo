//! Tracking by an impl of the consumer's own (ARC-07b fix loop 1), as the README's tracking table
//! documents: `MockTrackDefinitionOnly` (`DEFINITION = true, REPORTER = false`) and its mirror
//! `MockTrackReporterOnly`. Each constant governs its own model's event only: the two cannot be
//! swapped in the store without failing here.

use quiver_achievement::interface::{IAchievementDispatcher, IAchievementDispatcherTrait};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, spy_events, test_address,
};
use super::helpers::{always, one, window};

fn deploy(name: ByteArray) -> IAchievementDispatcher {
    let class = declare(name).unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IAchievementDispatcher { contract_address: address }
}

#[test]
#[available_gas(l2_gas: 1592766)]
fn own_impl_tracks_the_definition_only() {
    let achievement = deploy("MockTrackDefinitionOnly");
    let mut spy = spy_events();
    achievement.set_reporter(test_address(), true);
    assert!(spy.get_events().events.len() == 0);
    achievement.define(5, window(3, 4), one(7, 10), 25);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == achievement.contract_address);
    assert!(event.keys == @array![selector!("AchievementDefined"), 5]);
    assert!(event.data == @array![3, 4, 1, 7, 10, 25]);
}

#[test]
#[available_gas(l2_gas: 1542765)]
fn own_impl_tracks_the_reporter_only() {
    let achievement = deploy("MockTrackReporterOnly");
    let mut spy = spy_events();
    achievement.define(5, always(), one(7, 10), 25);
    assert!(spy.get_events().events.len() == 0);
    achievement.set_reporter(test_address(), true);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == achievement.contract_address);
    assert!(event.keys == @array![selector!("AchievementReporterSet"), test_address().into()]);
    assert!(event.data == @array![1]);
}
