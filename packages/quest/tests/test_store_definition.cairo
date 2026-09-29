//! The store of the quest definition (ARC-06), on `MockDefinitionStore`: `set_definition` writes
//! the slots A, B, C of 0.1.0 and emits `QuestDefined` once per write; `get_definition` reads the
//! model back. The benchmarks set the store against 0.1.0's hand-written code: the cost of an
//! operation is its benchmark minus its baseline.

use quiver_quest::logic::{QuestSchedule, QuestTask};
use quiver_quest::models::definition::{DefinitionTrait, QuestDefinition};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, map_entry_address,
    spy_events,
};
use super::helpers::{one_off, schedule, task};
use super::mock_store::{IMockDefinitionStoreDispatcher, IMockDefinitionStoreDispatcherTrait};

fn deploy() -> IMockDefinitionStoreDispatcher {
    let class = declare("MockDefinitionStore").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockDefinitionStoreDispatcher { contract_address: address }
}

fn worst_schedule() -> QuestSchedule {
    schedule(1000, 9000, 60, 600)
}

/// `MAX_TASKS` tasks and `MAX_CONDITIONS` conditions.
fn worst_tasks() -> Span<QuestTask> {
    array![task(11, 5), task(12, 6), task(13, 7)].span()
}

fn worst_conditions() -> Span<u32> {
    array![2, 3, 4, 5, 6, 7, 8].span()
}

/// Slots A, B, C of `quest_id`.
fn slots(store: IMockDefinitionStoreDispatcher, quest_id: u32) -> (felt252, felt252, felt252) {
    let key = array![quest_id.into()].span();
    let address = store.contract_address;
    (
        *load(address, map_entry_address(selector!("Quest_definitions"), key), 1)[0],
        *load(address, map_entry_address(selector!("Quest_tasks"), key), 1)[0],
        *load(address, map_entry_address(selector!("Quest_conditions"), key), 1)[0],
    )
}

// Behaviour

#[test]
#[available_gas(l2_gas: 1985802)]
fn store_set_definition_emits_quest_defined_once() {
    let store = deploy();
    let mut spy = spy_events();
    store
        .store_set_definition(
            1, schedule(10, 20, 3, 4), array![task(8, 5), task(9, 6)].span(), array![2].span(),
        );
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, defined) = events.at(0);
    assert!(*from == store.contract_address);
    // The keys and data of 0.1.0 (`test_component_events`)
    assert!(defined.keys == @array![selector!("QuestDefined"), 1]);
    assert!(defined.data == @array![10, 20, 3, 4, 2, 8, 5, 9, 6, 1, 2]);
}

/// The storage layout of 0.1.0: the store writes the felts the hand-written code writes, C only
/// with conditions.
#[test]
#[available_gas(l2_gas: 6613394)]
fn store_set_definition_writes_the_slots_of_0_1_0() {
    let store = deploy();
    store.hand_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    store
        .store_set_definition(
            21, worst_schedule(), worst_tasks(), array![2, 3, 4, 5, 6, 7, 8].span(),
        );
    let (a1, b1, c1) = slots(store, 1);
    let (a2, b2, c2) = slots(store, 21);
    assert!(a1 != 0 && b1 != 0 && c1 != 0);
    assert!((a2, b2, c2) == (a1, b1, c1));
    store.hand_set_definition(31, worst_schedule(), array![task(11, 5)].span(), array![].span());
    store.store_set_definition(41, worst_schedule(), array![task(11, 5)].span(), array![].span());
    let (a3, b3, c3) = slots(store, 31);
    assert!(c3 == 0);
    assert!(slots(store, 41) == (a3, b3, c3));
}

#[test]
#[available_gas(l2_gas: 4702866)]
fn store_get_definition_reads_the_model_back() {
    let store = deploy();
    assert!(!store.store_has_definition(1));
    let undefined = store.store_get_definition(1);
    assert!(undefined.id == 1 && undefined.tasks.len() == 0 && undefined.conditions.len() == 0);
    store.store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    assert!(store.store_has_definition(1));
    let expected = DefinitionTrait::new(1, worst_schedule(), worst_tasks(), worst_conditions());
    assert!(store.store_get_definition(1) == expected);
    // Without conditions, and against the hand-written reads of 0.1.0
    store.store_set_definition(9, one_off(), array![task(4, 2)].span(), array![].span());
    let definition: QuestDefinition = store.store_get_definition(9);
    let (slot_a, tasks, conditions) = store.hand_get_definition(9);
    assert!(definition.schedule == slot_a.schedule);
    assert!(definition.tasks == tasks && definition.conditions == conditions);
    assert!(definition.conditions.len() == 0);
}

// Benchmarks: a write of a new definition, the worst (3 tasks, 7 conditions: A, B, C created)

#[test]
#[available_gas(l2_gas: 357851)]
fn baseline_definition() {
    deploy().noop(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 2098173)]
fn bench_hand_set_definition_worst() {
    deploy().hand_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 2093385)]
fn bench_store_set_definition_worst() {
    deploy().store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
}

// Benchmarks: a read of the worst definition

fn defined() -> IMockDefinitionStoreDispatcher {
    let store = deploy();
    store.hand_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    store
}

#[test]
#[available_gas(l2_gas: 2265753)]
fn baseline_definition_defined() {
    defined().noop(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 2338455)]
fn bench_hand_get_definition_worst() {
    assert!(defined().hand_read_definition(1) == 70);
}

#[test]
#[available_gas(l2_gas: 2338424)]
fn bench_store_get_definition_worst() {
    assert!(defined().store_read_definition(1) == 70);
}
