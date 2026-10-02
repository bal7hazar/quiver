//! Optional tracking (ARC-07b), measured on the package's own models: the definition of 1 task
//! (slot A), of 3 tasks (A and B), and the reporter, each created, through the store and by hand,
//! on `MockStoreNone` and `MockStoreAll`. The criterion: under `TrackNone` a write through the
//! store costs exactly the write with no event code, to the unit; under `TrackAll`, exactly the
//! write then `emit`. The cost of an operation is its benchmark minus the baseline of the same
//! contract (`GAS.md`, docs/research/ARC-06-model-store.md).
//!
//! Kept in `tests/` for a reason of the rule (D-167): each benchmark deploys a contract.

use quiver_achievement::types::task::AchievementTask;
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare};
use starknet::ContractAddress;
use super::helpers::{one, task, window};
use super::mock_tracking::{IMockStoreDispatcher, IMockStoreDispatcherTrait};

const ID: u32 = 7;
const POINTS: u16 = 0xffff;

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
    array![task(1, 0xffffffff), task(2, 0xffffffff), task(3, 0xffffffff)].span()
}

// `TrackNone`: the store against the write with no event code

#[test]
#[available_gas(l2_gas: 298967)]
fn baseline_track_none_one_task() {
    none().noop(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 798704)]
fn bench_track_none_definition_one_task_store() {
    none().store_set_definition(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 798704)]
fn bench_track_none_definition_one_task_hand() {
    none().hand_set_definition(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 311189)]
fn baseline_track_none_three_tasks() {
    none().noop(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 1292540)]
fn bench_track_none_definition_three_tasks_store() {
    none().store_set_definition(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 1292540)]
fn bench_track_none_definition_three_tasks_hand() {
    none().hand_set_definition(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 284571)]
fn baseline_track_none_reporter() {
    none().noop_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 770364)]
fn bench_track_none_reporter_store() {
    none().store_set_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 770364)]
fn bench_track_none_reporter_hand() {
    none().hand_set_reporter(reporter(), true);
}

// `TrackAll`: the store against the write then `emit`

#[test]
#[available_gas(l2_gas: 298967)]
fn baseline_track_all_one_task() {
    all().noop(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 872393)]
fn bench_track_all_definition_one_task_store() {
    all().store_set_definition(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 872393)]
fn bench_track_all_definition_one_task_hand() {
    all().hand_set_definition(ID, window(1, 2), one(9, 0xffffffff), POINTS);
}

#[test]
#[available_gas(l2_gas: 311189)]
fn baseline_track_all_three_tasks() {
    all().noop(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 1392038)]
fn bench_track_all_definition_three_tasks_store() {
    all().store_set_definition(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 1392038)]
fn bench_track_all_definition_three_tasks_hand() {
    all().hand_set_definition(ID, window(1, 2), three_tasks(), POINTS);
}

#[test]
#[available_gas(l2_gas: 284571)]
fn baseline_track_all_reporter() {
    all().noop_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 813624)]
fn bench_track_all_reporter_store() {
    all().store_set_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 813624)]
fn bench_track_all_reporter_hand() {
    all().hand_set_reporter(reporter(), true);
}
