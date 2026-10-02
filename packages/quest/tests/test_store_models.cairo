//! Every model of `quiver_quest` through the store (ARC-07a), on `MockDefinitionStore`
//! (`TrackAll`) and `MockSilentStore` (`TrackNone`):
//!
//! - a tracked model's `set_x` emits its event exactly once per write under `TrackAll`, and
//!   nothing under `TrackNone`, writing the same felts;
//! - an untracked model's `set_x` never emits, and writes 0.1.0's layout;
//! - under `TrackNone`, a tracked `set_x` costs exactly the hand-written write of 0.1.0 without
//!   its `emit`, to the unit; under `TrackAll`, the write plus the event.
//!
//! The cost of an operation is its benchmark minus the baseline of the same contract.

use quiver_quest::models::held::{HeldPacking, HeldSlot, QuestHeldSlot};
use quiver_quest::models::progress::{ProgressPacking, ProgressSlot, QuestProgress};
use quiver_quest::models::record::{QuestRecord, RecordPacking, RecordSlot};
use quiver_quest::models::status::QuestStatus;
use quiver_quest::types::held::QuestHeld;
use quiver_quest::types::schedule::QuestSchedule;
use quiver_quest::types::task::QuestTask;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyTrait, declare, load, map_entry_address,
    spy_events,
};
use starknet::ContractAddress;
use super::helpers::{one_off, schedule, task};
use super::mock_store::{
    IMockDefinitionStoreDispatcher, IMockDefinitionStoreDispatcherTrait, IMockSilentStoreDispatcher,
    IMockSilentStoreDispatcherTrait,
};

const PLAYER: felt252 = 'player';

fn all() -> IMockDefinitionStoreDispatcher {
    let class = declare("MockDefinitionStore").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockDefinitionStoreDispatcher { contract_address: address }
}

fn none() -> IMockSilentStoreDispatcher {
    let class = declare("MockSilentStore").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    IMockSilentStoreDispatcher { contract_address: address }
}

fn reporter() -> ContractAddress {
    'reporter'.try_into().unwrap()
}

fn worst_schedule() -> QuestSchedule {
    schedule(1000, 9000, 60, 600)
}

fn worst_tasks() -> Span<QuestTask> {
    array![task(11, 5), task(12, 6), task(13, 7)].span()
}

fn worst_conditions() -> Span<u32> {
    array![2, 3, 4, 5, 6, 7, 8].span()
}

fn slot(address: ContractAddress, member: felt252, keys: Span<felt252>) -> felt252 {
    *load(address, map_entry_address(member, keys), 1)[0]
}

fn definition_slots(address: ContractAddress, quest_id: u32) -> (felt252, felt252, felt252) {
    let key = array![quest_id.into()].span();
    (
        slot(address, selector!("Quest_definitions"), key),
        slot(address, selector!("Quest_tasks"), key),
        slot(address, selector!("Quest_conditions"), key),
    )
}

// Tracked models under `TrackAll`: one event per write

#[test]
#[available_gas(l2_gas: 1051596)]
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
        // The keys and data of 0.1.0
        assert!(event.keys == @array![selector!("QuestReporterSet"), reporter().into()]);
        assert!(event.data == @array![allowed]);
        i += 1;
    }
    assert!(!store.store_get_reporter(reporter()));
}

/// One definition rewritten at the same id, changed then unchanged: one event per write, each with
/// the values written. Only the store can do it: the component's `define` refuses an id already
/// defined (`'Quest: already defined'`).
#[test]
#[available_gas(l2_gas: 3215625)]
fn track_all_definition_rewritten_emits_once_per_write() {
    let store = all();
    let mut spy = spy_events();
    store.store_set_definition(1, one_off(), array![task(4, 2)].span(), array![].span());
    // Changed: other schedule, tasks and conditions
    store
        .store_set_definition(
            1, schedule(10, 20, 3, 4), array![task(8, 5), task(9, 6)].span(), array![2].span(),
        );
    // Unchanged
    store
        .store_set_definition(
            1, schedule(10, 20, 3, 4), array![task(8, 5), task(9, 6)].span(), array![2].span(),
        );
    let events = spy.get_events().events;
    assert!(events.len() == 3);
    let expected = array![
        array![0, 0, 0, 0, 1, 4, 2, 0], array![10, 20, 3, 4, 2, 8, 5, 9, 6, 1, 2],
        array![10, 20, 3, 4, 2, 8, 5, 9, 6, 1, 2],
    ];
    let mut i = 0;
    for data in expected {
        let (from, event) = events.at(i);
        assert!(*from == store.contract_address);
        assert!(event.keys == @array![selector!("QuestDefined"), 1]);
        assert!(event.data == @data);
        i += 1;
    }
    let definition = store.store_get_definition(1);
    assert!(definition.tasks == array![task(8, 5), task(9, 6)].span());
    assert!(definition.conditions == array![2].span());
}

// Tracked models under `TrackNone`: nothing emitted, the same felts written

#[test]
#[available_gas(l2_gas: 6623001)]
fn track_none_definition_emits_nothing() {
    let silent = none();
    let tracked = all();
    let mut spy = spy_events();
    silent.store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    silent.store_set_definition(2, one_off(), array![task(4, 2)].span(), array![].span());
    assert!(spy.get_events().events.len() == 0);
    tracked.store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    tracked.store_set_definition(2, one_off(), array![task(4, 2)].span(), array![].span());
    assert!(spy.get_events().events.len() == 2);
    let (a, b, c) = definition_slots(silent.contract_address, 1);
    assert!(a != 0 && b != 0 && c != 0);
    assert!(definition_slots(tracked.contract_address, 1) == (a, b, c));
    assert!(
        definition_slots(
            silent.contract_address, 2,
        ) == definition_slots(tracked.contract_address, 2),
    );
}

#[test]
#[available_gas(l2_gas: 1242549)]
fn track_none_reporter_emits_nothing() {
    let silent = none();
    let mut spy = spy_events();
    silent.store_set_reporter(reporter(), true);
    silent.store_set_reporter(reporter(), false);
    silent.store_set_reporter(reporter(), true);
    assert!(spy.get_events().events.len() == 0);
    assert!(silent.store_get_reporter(reporter()));
    let key = array![reporter().into()].span();
    assert!(slot(silent.contract_address, selector!("Quest_reporters"), key) == 1);
}

// Untracked models: nothing emitted, whatever the choice; 0.1.0's layout

#[test]
#[available_gas(l2_gas: 3050460)]
fn untracked_status_emits_nothing() {
    let store = all();
    store.store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
    let mut spy = spy_events();
    store.store_set_status(1, false, 5);
    store.store_set_status(1, true, 4);
    store.store_set_status(1, true, 4);
    assert!(spy.get_events().events.len() == 0);
    let status = store.store_get_status(1);
    assert!(status == QuestStatus { id: 1, defined: true, retired: true, live_dependents: 4 });
    // The definition's bits of A are kept
    let head = store.store_get_definition_head(1);
    assert!(head.schedule == worst_schedule() && head.task_count == 3 && head.condition_count == 7);
}

#[test]
#[available_gas(l2_gas: 1503978)]
fn untracked_progress_emits_nothing() {
    let store = all();
    let mut spy = spy_events();
    let progress = QuestProgress {
        player_id: PLAYER,
        quest_id: 3,
        interval_id: 0x123456789,
        c0: 1,
        c1: 0xffffffff,
        c2: 7,
        completed: true,
        claimed: false,
    };
    store.store_set_progress(progress);
    store.store_set_progress(QuestProgress { claimed: true, ..progress });
    store.store_set_progress(QuestProgress { claimed: true, ..progress });
    assert!(spy.get_events().events.len() == 0);
    let read = store.store_get_progress(PLAYER, 3, 0x123456789);
    assert!(read == QuestProgress { claimed: true, ..progress });
    // Slot P of 0.1.0
    let key = array![PLAYER, 3, 0x123456789].span();
    let expected = ProgressPacking::pack(
        ProgressSlot { c0: 1, c1: 0xffffffff, c2: 7, completed: true, claimed: true },
    );
    assert!(slot(store.contract_address, selector!("Quest_progress"), key) == expected);
    // Keys read back with the values, a slot never written reads zero
    assert!(
        store
            .store_get_progress(
                PLAYER, 3, 1,
            ) == QuestProgress {
                interval_id: 1, c0: 0, c1: 0, c2: 0, completed: false, claimed: false, ..progress,
            },
    );
}

#[test]
#[available_gas(l2_gas: 1125191)]
fn untracked_record_emits_nothing() {
    let store = all();
    let mut spy = spy_events();
    let record = QuestRecord {
        player_id: PLAYER, quest_id: 3, completions: 0xffffffffffffffff, claims: 2, unlocked: true,
    };
    store.store_set_record(record);
    store.store_set_record(record);
    assert!(spy.get_events().events.len() == 0);
    assert!(store.store_get_record(PLAYER, 3) == record);
    let key = array![PLAYER, 3].span();
    let expected = RecordPacking::pack(
        RecordSlot { completions: 0xffffffffffffffff, claims: 2, unlocked: true },
    );
    assert!(slot(store.contract_address, selector!("Quest_records"), key) == expected);
}

#[test]
#[available_gas(l2_gas: 1189713)]
fn untracked_held_slot_emits_nothing() {
    let store = all();
    let mut spy = spy_events();
    let e0 = QuestHeld { quest_id: 9, interval_id: 0xffffffffffff, acceptance: 0x3fffffff };
    let e1 = QuestHeld { quest_id: 4, interval_id: 2, acceptance: 1 };
    let held = QuestHeldSlot { player_id: PLAYER, index: 1, e0, e1, counter: 0, kept: true };
    store.store_set_held_slot(held);
    store.store_set_held_slot(held);
    assert!(spy.get_events().events.len() == 0);
    assert!(store.store_get_held_slot(PLAYER, 1) == held);
    let key = array![PLAYER, 1].span();
    let expected = HeldPacking::pack(HeldSlot { e0, e1, counter: 0, kept: true });
    assert!(slot(store.contract_address, selector!("Quest_held"), key) == expected);
}

// The held list and the prerequisites through the store (fix loop 1)

fn held_entry(quest_id: u32) -> QuestHeld {
    QuestHeld { quest_id, interval_id: 0, acceptance: quest_id }
}

#[test]
#[available_gas(l2_gas: 2972802)]
fn store_held_list_writes_only_the_slots_that_change() {
    let store = all();
    assert!(store.store_get_held(PLAYER) == array![].span());
    store.store_set_held(PLAYER, array![held_entry(1), held_entry(2), held_entry(3)].span(), 3);
    assert!(
        store.store_get_held(PLAYER) == array![held_entry(1), held_entry(2), held_entry(3)].span(),
    );
    let slot0 = store.store_get_held_slot(PLAYER, 0);
    assert!(slot0.counter == 3 && slot0.kept && slot0.e1 == held_entry(2));
    // Shrunk to one entry: slot 1 keeps its `kept` bit, never zeroed
    store.store_set_held(PLAYER, array![held_entry(2)].span(), 3);
    assert!(store.store_get_held(PLAYER) == array![held_entry(2)].span());
    let slot1 = store.store_get_held_slot(PLAYER, 1);
    assert!(slot1.kept && slot1.e0.quest_id == 0);
    // Unchanged: nothing written, nothing emitted
    let mut spy = spy_events();
    store.store_set_held(PLAYER, array![held_entry(2)].span(), 3);
    assert!(spy.get_events().events.len() == 0);
}

#[test]
#[available_gas(l2_gas: 4136013)]
fn store_prerequisites_met_reads_each_record() {
    let store = all();
    store.store_set_definition(5, one_off(), array![task(4, 2)].span(), array![1, 2].span());
    assert!(!store.store_prerequisites_met(PLAYER, 5, 2));
    let record = QuestRecord {
        player_id: PLAYER, quest_id: 1, completions: 1, claims: 0, unlocked: false,
    };
    store.store_set_record(record);
    assert!(!store.store_prerequisites_met(PLAYER, 5, 2));
    store.store_set_record(QuestRecord { quest_id: 2, ..record });
    assert!(store.store_prerequisites_met(PLAYER, 5, 2));
    // Claims or unlock alone do not count
    store
        .store_set_record(
            QuestRecord { quest_id: 2, completions: 0, claims: 3, unlocked: true, ..record },
        );
    assert!(!store.store_prerequisites_met(PLAYER, 5, 2));
}

// Benchmarks: the definition under both choices, both arms built from the same model
// (`DefinitionTrait::new` in each): the only difference is the tracking path (fix loop 1)

#[test]
#[available_gas(l2_gas: 1930110)]
fn bench_hand_set_model_definition_silent_worst() {
    none().hand_set_model_definition_silent(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 349419)]
fn baseline_model_definition() {
    all().noop(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 2092965)]
fn bench_hand_set_model_definition_worst() {
    all().hand_set_model_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 2092965)]
fn bench_store_set_model_definition_worst() {
    all().store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
}

// Benchmarks: the definition under `TrackNone`, against 0.1.0's writes without `emit`. The worst
// definition: 3 tasks, 7 conditions, A, B, C created

#[test]
#[available_gas(l2_gas: 349419)]
fn baseline_silent_definition() {
    none().noop(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 1935318)]
fn bench_hand_set_definition_silent_worst() {
    none().hand_set_definition_silent(1, worst_schedule(), worst_tasks(), worst_conditions());
}

#[test]
#[available_gas(l2_gas: 1930110)]
fn bench_store_set_definition_silent_worst() {
    none().store_set_definition(1, worst_schedule(), worst_tasks(), worst_conditions());
}

// Benchmarks: the reporter, created, under `TrackNone` and `TrackAll`, against 0.1.0's write
// without and with its `emit`

#[test]
#[available_gas(l2_gas: 284571)]
fn baseline_silent_reporter() {
    none().noop_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 770364)]
fn bench_hand_set_reporter_silent() {
    none().hand_set_reporter_silent(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 770364)]
fn bench_store_set_reporter_silent() {
    none().store_set_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 284571)]
fn baseline_reporter() {
    all().noop_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 816144)]
fn bench_hand_set_reporter() {
    all().hand_set_reporter(reporter(), true);
}

#[test]
#[available_gas(l2_gas: 816144)]
fn bench_store_set_reporter() {
    all().store_set_reporter(reporter(), true);
}
