//! Every model of `quiver_achievement` through the store (ARC-07b), on `MockStoreAll` (`TrackAll`)
//! and `MockStoreNone` (`TrackNone`):
//!
//! - a tracked model's `set_x` emits its event exactly once per write under `TrackAll` (created,
//!   changed, rewritten unchanged), with 0.1.0's keys and data, and nothing under `TrackNone`,
//!   writing the same felts;
//! - the untracked status never emits, and writes A with the definition's bits unchanged;
//! - `get_definition` reads the model back, `points` included.
//!
//! They need a deployed contract: the store is implemented on the component's state.

use quiver_achievement::models::definition::{HeadPacking, HeadSlot, TasksPacking, TasksSlot};
use quiver_achievement::models::status::AchievementStatus;
use quiver_achievement::types::task::AchievementTask;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, map_entry_address,
    spy_events,
};
use starknet::ContractAddress;
use super::helpers::{always, one, task, window};
use super::mock_tracking::{IMockStoreDispatcher, IMockStoreDispatcherTrait};

fn deploy(name: ByteArray) -> IMockStoreDispatcher {
    let class = declare(name).unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockStoreDispatcher { contract_address: address }
}

fn all() -> IMockStoreDispatcher {
    deploy("MockStoreAll")
}

fn none() -> IMockStoreDispatcher {
    deploy("MockStoreNone")
}

fn reporter() -> ContractAddress {
    'reporter'.try_into().unwrap()
}

fn three_tasks() -> Span<AchievementTask> {
    array![task(1, 5), task(2, 6), task(3, 7)].span()
}

fn slot(address: ContractAddress, member: felt252, key: felt252) -> felt252 {
    *load(address, map_entry_address(member, array![key].span()), 1)[0]
}

/// Slots A and B of `id`.
fn definition_slots(address: ContractAddress, id: u32) -> (felt252, felt252) {
    (
        slot(address, selector!("Achievement_definitions"), id.into()),
        slot(address, selector!("Achievement_extra_tasks"), id.into()),
    )
}

/// One definition rewritten at the same id: created with one task, changed to three, rewritten
/// unchanged. Only the store can do it: the component's `define` refuses an id already defined.
fn write_definitions(store: IMockStoreDispatcher) {
    store.store_set_definition(1, always(), one(4, 2), 10);
    store.store_set_definition(1, window(3, 4), three_tasks(), 0xffff);
    store.store_set_definition(1, window(3, 4), three_tasks(), 0xffff);
}

// Tracked models under `TrackAll`: one event per write

#[test]
#[available_gas(l2_gas: 2225160)]
fn track_all_definition_emits_once_per_write() {
    let store = all();
    let mut spy = spy_events();
    write_definitions(store);
    let events = spy.get_events().events;
    assert!(events.len() == 3);
    // The keys and data of 0.1.0: window, tasks as a span, points
    let expected = array![
        array![0, 0, 1, 4, 2, 10], array![3, 4, 3, 1, 5, 2, 6, 3, 7, 0xffff],
        array![3, 4, 3, 1, 5, 2, 6, 3, 7, 0xffff],
    ];
    let mut i = 0;
    for data in expected {
        let (from, event) = events.at(i);
        assert!(*from == store.contract_address);
        assert!(event.keys == @array![selector!("AchievementDefined"), 1]);
        assert!(event.data == @data);
        i += 1;
    }
}

#[test]
#[available_gas(l2_gas: 1044036)]
fn track_all_reporter_emits_once_per_write() {
    let store = all();
    let mut spy = spy_events();
    // Created, changed, rewritten unchanged
    store.store_set_reporter(reporter(), true);
    store.store_set_reporter(reporter(), false);
    store.store_set_reporter(reporter(), false);
    let events = spy.get_events().events;
    assert!(events.len() == 3);
    let expected = array![1, 0, 0];
    let mut i = 0;
    for allowed in expected {
        let (from, event) = events.at(i);
        assert!(*from == store.contract_address);
        assert!(event.keys == @array![selector!("AchievementReporterSet"), reporter().into()]);
        assert!(event.data == @array![allowed]);
        i += 1;
    }
    assert!(!store.store_get_reporter(reporter()));
}

// Tracked models under `TrackNone`: no event, the same felts

#[test]
#[available_gas(l2_gas: 3810954)]
fn track_none_definition_emits_nothing_and_writes_the_same() {
    let tracked = all();
    let silent = none();
    write_definitions(tracked);
    let mut spy = spy_events();
    write_definitions(silent);
    assert!(spy.get_events().events.len() == 0);
    let (a, b) = definition_slots(silent.contract_address, 1);
    assert!((a, b) == definition_slots(tracked.contract_address, 1));
    // A with `points`, B with the second and third tasks
    let head = HeadSlot {
        window: window(3, 4),
        task_count: 3,
        defined: true,
        retired: false,
        t0: task(1, 5),
        points: 0xffff,
    };
    assert!(a == HeadPacking::pack(head));
    assert!(b == TasksPacking::pack(TasksSlot { t1: task(2, 6), t2: task(3, 7) }));
}

#[test]
#[available_gas(l2_gas: 1917731)]
fn track_none_reporter_emits_nothing_and_writes_the_same() {
    let tracked = all();
    let silent = none();
    tracked.store_set_reporter(reporter(), true);
    let mut spy = spy_events();
    silent.store_set_reporter(reporter(), true);
    silent.hand_set_reporter(reporter(), true);
    assert!(spy.get_events().events.len() == 0);
    let key = reporter().into();
    let member = selector!("Achievement_reporters");
    assert!(slot(silent.contract_address, member, key) == 1);
    assert!(
        slot(silent.contract_address, member, key) == slot(tracked.contract_address, member, key),
    );
    assert!(silent.store_get_reporter(reporter()));
}

// The untracked status

/// The status never emits, whatever the consumer tracks, and its write keeps the definition's
/// bits of A.
#[test]
#[available_gas(l2_gas: 2390031)]
fn status_never_emits() {
    let tracked = all();
    let silent = none();
    tracked.store_set_definition(5, window(1, 9), one(7, 10), 25);
    silent.store_set_definition(5, window(1, 9), one(7, 10), 25);
    let (before, _) = definition_slots(tracked.contract_address, 5);
    let mut spy = spy_events();
    tracked.store_set_status(5, true);
    silent.store_set_status(5, true);
    assert!(spy.get_events().events.len() == 0);
    assert!(
        tracked.store_get_status(5) == AchievementStatus { id: 5, defined: true, retired: true },
    );
    let (after, _) = definition_slots(tracked.contract_address, 5);
    let head: HeadSlot = HeadPacking::unpack(before);
    assert!(after == HeadPacking::pack(HeadSlot { retired: true, ..head }));
    assert!(
        definition_slots(
            silent.contract_address, 5,
        ) == definition_slots(tracked.contract_address, 5),
    );
}

// Reads

#[test]
#[available_gas(l2_gas: 2791058)]
fn get_definition_reads_the_model_back() {
    let store = all();
    store.store_set_definition(1, always(), one(4, 2), 10);
    store.store_set_definition(2, window(3, 4), three_tasks(), 0xffff);
    let first = store.store_get_definition(1);
    assert!(first.id == 1 && first.window == always());
    assert!(first.tasks == one(4, 2) && first.points == 10);
    let second = store.store_get_definition(2);
    assert!(second.window == window(3, 4) && second.tasks == three_tasks());
    assert!(second.points == 0xffff);
    // Not defined: no task, no points
    let absent = store.store_get_definition(3);
    assert!(absent.tasks.len() == 0 && absent.points == 0);
    assert!(
        store.store_get_status(3) == AchievementStatus { id: 3, defined: false, retired: false },
    );
}
