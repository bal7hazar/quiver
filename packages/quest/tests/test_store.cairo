//! The store's mechanism (ARC-06), on `MockModels`: an untracked `set` emits nothing, a tracked
//! `set` emits exactly its event on every write, and neither costs more than the same code by
//! hand. Each benchmark has a baseline, `baseline_*`, the same setup and a call that does
//! nothing: the cost of an operation is its benchmark minus its baseline. A slot is **created**
//! when it is zero before the test, **overwritten** when it is set before by `store` (a cheatcode,
//! not a write of the test).

use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, map_entry_address,
    spy_events, store,
};
use super::mock_store::{IMockModelsDispatcher, IMockModelsDispatcherTrait, Values, ValuesPacking};

const ID: u32 = 7;
const A: u64 = 0x1234567890;
const B: u64 = 0x9876543210;

fn deploy() -> IMockModelsDispatcher {
    let class = declare("MockModels").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockModelsDispatcher { contract_address: address }
}

fn slot(member: felt252, id: u32) -> felt252 {
    map_entry_address(member, array![id.into()].span())
}

/// Both models' slots of `ID` non-zero before the test.
fn deploy_existing() -> IMockModelsDispatcher {
    let models = deploy();
    let old = ValuesPacking::pack(Values { a: 1, b: 1 });
    store(models.contract_address, slot(selector!("Mock_plain"), ID), array![old].span());
    store(models.contract_address, slot(selector!("Mock_logged"), ID), array![old].span());
    models
}

fn read_slot(models: IMockModelsDispatcher, member: felt252, id: u32) -> felt252 {
    *load(models.contract_address, slot(member, id), 1)[0]
}

// Behaviour

#[test]
#[available_gas(l2_gas: 2112800)]
fn store_untracked_set_emits_nothing() {
    let models = deploy_existing();
    let mut spy = spy_events();
    models.store_set_plain(ID, A, B);
    models.store_set_plain(ID + 1, A, B);
    models.store_set_plain(ID + 1, A, B);
    assert!(spy.get_events().events.len() == 0);
    assert!(models.store_get_plain(ID) == (A, B));
}

#[test]
#[available_gas(l2_gas: 2624601)]
fn store_tracked_set_emits_its_event_on_every_write() {
    let models = deploy_existing();
    let mut spy = spy_events();
    // Overwritten, created, overwritten with other values, rewritten unchanged
    models.store_set_logged(ID, A, B);
    models.store_set_logged(ID + 1, 3, 4);
    models.store_set_logged(ID + 1, 5, 6);
    models.store_set_logged(ID + 1, 5, 6);
    let events = spy.get_events().events;
    assert!(events.len() == 4);
    let expected = array![(ID, A, B), (ID + 1, 3, 4), (ID + 1, 5, 6), (ID + 1, 5, 6)];
    let mut i = 0;
    for (id, a, b) in expected {
        let (from, event) = events.at(i);
        assert!(*from == models.contract_address);
        assert!(event.keys == @array![selector!("LoggedSet"), id.into()]);
        assert!(event.data == @array![a.into(), b.into()]);
        i += 1;
    }
    assert!(models.store_get_logged(ID + 1) == (5, 6));
}

/// The store writes the felt the hand-written code writes, and reads it back the same.
#[test]
#[available_gas(l2_gas: 3084333)]
fn store_writes_what_the_hand_writes() {
    let models = deploy();
    models.hand_set_plain(ID, A, B);
    models.store_set_plain(ID + 1, A, B);
    let by_hand = read_slot(models, selector!("Mock_plain"), ID);
    assert!(by_hand == ValuesPacking::pack(Values { a: A, b: B }));
    assert!(read_slot(models, selector!("Mock_plain"), ID + 1) == by_hand);
    models.hand_set_logged(ID, A, B);
    models.store_set_logged(ID + 1, A, B);
    assert!(
        read_slot(
            models, selector!("Mock_logged"), ID + 1,
        ) == read_slot(models, selector!("Mock_logged"), ID),
    );
    assert!(models.hand_get_plain(ID) == models.store_get_plain(ID));
    assert!(models.store_get_plain(ID + 2) == (0, 0));
}

// Benchmarks: created slots

#[test]
#[available_gas(l2_gas: 294273)]
fn baseline_models() {
    deploy().noop(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 771530)]
fn bench_hand_set_untracked_created() {
    deploy().hand_set_plain(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 771530)]
fn bench_store_set_untracked_created() {
    deploy().store_set_plain(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 818801)]
fn bench_hand_set_tracked_created() {
    deploy().hand_set_logged(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 818801)]
fn bench_store_set_tracked_created() {
    deploy().store_set_logged(ID, A, B);
}

// Benchmarks: overwritten slots

#[test]
#[available_gas(l2_gas: 1170855)]
fn baseline_models_existing() {
    deploy_existing().noop(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 1226012)]
fn bench_hand_set_untracked_overwritten() {
    deploy_existing().hand_set_plain(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 1226012)]
fn bench_store_set_untracked_overwritten() {
    deploy_existing().store_set_plain(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 1273283)]
fn bench_hand_set_tracked_overwritten() {
    deploy_existing().hand_set_logged(ID, A, B);
}

#[test]
#[available_gas(l2_gas: 1273283)]
fn bench_store_set_tracked_overwritten() {
    deploy_existing().store_set_logged(ID, A, B);
}

// Benchmarks: reads (baseline `baseline_models_existing`)

#[test]
#[available_gas(l2_gas: 1205075)]
fn bench_hand_get() {
    let (a, _) = deploy_existing().hand_get_plain(ID);
    assert!(a == 1);
}

#[test]
#[available_gas(l2_gas: 1205075)]
fn bench_store_get() {
    let (a, _) = deploy_existing().store_get_plain(ID);
    assert!(a == 1);
}
