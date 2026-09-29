//! Optional tracking (ARC-07a), on `MockTrackAll` and `MockTrackNone`: under `TrackAll` a tracked
//! `set` emits its event once per write, under `TrackNone` nothing; and an untracked choice costs
//! exactly the write with no event code, to the unit. The cost of an operation is its benchmark
//! minus the baseline of the same contract.

use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, map_entry_address,
    spy_events,
};
use super::mock_store::{Values, ValuesPacking};
use super::mock_tracking::{IMockTrackingDispatcher, IMockTrackingDispatcherTrait};

const ID: u32 = 7;
const A: u64 = 0x1234567890;
const B: u64 = 0x9876543210;

fn deploy(name: ByteArray) -> IMockTrackingDispatcher {
    let class = declare(name).unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockTrackingDispatcher { contract_address: address }
}

fn all() -> IMockTrackingDispatcher {
    deploy("MockTrackAll")
}

fn none() -> IMockTrackingDispatcher {
    deploy("MockTrackNone")
}

fn read_slot(mock: IMockTrackingDispatcher, id: u32) -> felt252 {
    let key = map_entry_address(selector!("Mock_logged"), array![id.into()].span());
    *load(mock.contract_address, key, 1)[0]
}

// Behaviour

#[test]
#[available_gas(l2_gas: 2098247)]
fn track_all_emits_once_per_write() {
    let mock = all();
    let mut spy = spy_events();
    // Created, overwritten with other values, rewritten unchanged
    mock.set_by_constant(ID, A, B);
    mock.set_by_constant(ID, 3, 4);
    mock.set_by_constant(ID, 3, 4);
    let events = spy.get_events().events;
    assert!(events.len() == 3);
    let expected = array![(A, B), (3, 4), (3, 4)];
    let mut i = 0;
    for (a, b) in expected {
        let (from, event) = events.at(i);
        assert!(*from == mock.contract_address);
        assert!(event.keys == @array![selector!("LoggedSet"), ID.into()]);
        assert!(event.data == @array![a.into(), b.into()]);
        i += 1;
    }
    mock.set_by_emitter(ID + 1, A, B);
    assert!(spy.get_events().events.len() == 4);
    assert!(read_slot(mock, ID) == ValuesPacking::pack(Values { a: 3, b: 4 }));
}

#[test]
#[available_gas(l2_gas: 1714062)]
fn track_none_emits_nothing() {
    let mock = none();
    let mut spy = spy_events();
    mock.set_by_constant(ID, A, B);
    mock.set_by_constant(ID, 3, 4);
    mock.set_by_constant(ID, 3, 4);
    mock.set_by_emitter(ID + 1, A, B);
    assert!(spy.get_events().events.len() == 0);
    // The write is the same
    assert!(read_slot(mock, ID) == ValuesPacking::pack(Values { a: 3, b: 4 }));
    assert!(read_slot(mock, ID + 1) == ValuesPacking::pack(Values { a: A, b: B }));
}

// Benchmarks: created slots, `TrackNone` against the write with no event code

#[test]
#[available_gas(l2_gas: 294273)]
fn baseline_track_none() {
    none().noop(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 771530)]
fn bench_track_none_hand_silent() {
    none().hand_set_silent(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 771530)]
fn bench_track_none_by_constant() {
    none().set_by_constant(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 771530)]
fn bench_track_none_by_emitter() {
    none().set_by_emitter(ID, A, B);
}

// Benchmarks: created slots, `TrackAll` against the write then `emit`

#[test]
#[available_gas(l2_gas: 294273)]
fn baseline_track_all() {
    all().noop(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 818801)]
fn bench_track_all_hand_emitted() {
    all().hand_set_emitted(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 818801)]
fn bench_track_all_by_constant() {
    all().set_by_constant(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 818801)]
fn bench_track_all_by_emitter() {
    all().set_by_emitter(ID, A, B);
}
