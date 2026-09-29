//! Gas guards on the writes of `progress_many` (fix loop 1, point 3; fix loop 3, point 3).
//!
//! snforge exposes no syscall count to a test. Each test therefore measures the Sierra gas of
//! one `progress_many` call with `core::testing::get_available_gas()` around the dispatcher
//! call: deterministic, and without the state-diff charges of the L2 gas. A storage write costs
//! 58 820 of it (`write_costs_58_820_sierra_gas` below). Each call is checked against its
//! reference within `TOLERANCE` = 20 000.
//!
//! **What the guards bound is the cost, not the count.** An extra write, with nothing else
//! changed, moves the call by about 58 820 and fails the guard (shown in fix loop 1 with a write
//! injected). But a change that adds a write and saves as much elsewhere would pass. The exact
//! writes of each test are counted outside the test, with `snforge test test_component_writes
//! --detailed-resources` (the `StorageWrite` syscalls, minus those of `baseline_writes_setup*`),
//! and recorded in `GAS.md` beside the guards. The consumer is `MockBench`, whose hooks do
//! nothing, so no hook's write is in them.
//!
//! The writes of each call: completing, P and R; not completing, P only; duplicate entries
//! merged, P once; two tasks of one quest, P once, and R once on completion; duplicate entries
//! with several positive counts on two quests' tasks, each quest's P once.

use core::testing::get_available_gas;
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::logic::{Mode, TaskProgress};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare, test_address};
use super::helpers::{entry, one_off, task};
use super::setup::PLAYER;
use super::test_component_probe::{IProbeDispatcher, IProbeDispatcherTrait};

const TOLERANCE: u128 = 20000;
/// Sierra gas of the calls below, measured.
const COMPLETING: u128 = 802776;
const NOT_COMPLETING: u128 = 639896;
const DUPLICATES: u128 = 680079;
const TWO_TASKS_COMPLETING: u128 = 760992;
const TWO_TASKS_NOT_COMPLETING: u128 = 654102;
const DUPLICATES_SEVERAL: u128 = 772245;

#[derive(Drop, Copy)]
struct Bench {
    quest: IQuestDispatcher,
    view: IQuestViewDispatcher,
}

/// `MockBench`, quest 1 on task 7 (total 2) and quest 2 on tasks 8 and 9 (totals 1), both held.
fn setup() -> Bench {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let bench = Bench {
        quest: IQuestDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
    };
    bench.quest.set_reporter(test_address(), true);
    bench.quest.define(1, one_off(), array![task(7, 2)].span(), array![].span());
    bench.quest.define(2, one_off(), array![task(8, 1), task(9, 1)].span(), array![].span());
    bench.quest.accept(PLAYER, 1);
    bench.quest.accept(PLAYER, 2);
    bench
}

/// The Sierra gas of `progress_many(PLAYER, entries, Storage)`.
fn call_gas(bench: Bench, entries: Span<TaskProgress>) -> u128 {
    let before = get_available_gas();
    bench.quest.progress_many(PLAYER, entries, Mode::Storage);
    before - get_available_gas()
}

fn assert_gas(used: u128, reference: u128) {
    println!("sierra gas of the call: {}", used);
    let diff = if used > reference {
        used - reference
    } else {
        reference - used
    };
    assert!(diff <= TOLERANCE, "{} is not within {} of {}", used, TOLERANCE, reference);
}

#[test]
#[available_gas(l2_gas: 6649898)]
fn quest_progress_completing_writes_p_and_r() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 2)].span()), COMPLETING);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).completed);
}

#[test]
#[available_gas(l2_gas: 6019457)]
fn quest_progress_not_completing_writes_p_only() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 1)].span()), NOT_COMPLETING);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 6062279)]
fn quest_progress_duplicate_entries_write_p_once() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 1), entry(7, 0), entry(7, 0)].span()), DUPLICATES);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).c0 == 1);
}

/// Two tasks of one quest in one call, completing: P once and R once.
#[test]
#[available_gas(l2_gas: 6606445)]
fn quest_progress_two_tasks_write_p_and_r_once() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(8, 1), entry(9, 1)].span()), TWO_TASKS_COMPLETING);
    assert!(bench.view.quest_progress(PLAYER, 2, 0).completed);
}

/// The unit of the tolerance: a second write in a call costs 58 820 Sierra gas more.
#[test]
#[available_gas(l2_gas: 1431150)]
fn write_costs_58_820_sierra_gas() {
    let class = declare("Probe").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let probe = IProbeDispatcher { contract_address: address };
    let g0 = get_available_gas();
    probe.write_n(1);
    let g1 = get_available_gas();
    probe.write_n(2);
    let g2 = get_available_gas();
    assert!((g1 - g2) - (g0 - g1) == 58820);
}

/// Fix loop 3: two tasks of one quest in one call, not completing: P once, no R.
#[test]
#[available_gas(l2_gas: 6035424)]
fn quest_progress_two_tasks_not_completing_write_p_once() {
    let bench = setup_totals_two();
    assert_gas(call_gas(bench, array![entry(8, 1), entry(9, 1)].span()), TWO_TASKS_NOT_COMPLETING);
    let progress = bench.view.quest_progress(PLAYER, 2, 0);
    assert!(progress.c0 == 1 && progress.c1 == 1 && !progress.completed);
}

/// Fix loop 3: duplicate entries with several positive counts on two tasks, merged: each
/// quest's P once, two writes in all, no R.
#[test]
#[available_gas(l2_gas: 6738591)]
fn quest_progress_duplicates_several_counts_write_each_p_once() {
    let bench = setup_totals_two();
    assert_gas(
        call_gas(bench, array![entry(7, 1), entry(8, 1), entry(7, 2), entry(8, 1)].span()),
        DUPLICATES_SEVERAL,
    );
    // quest 1: 1 + 2 on task 7; quest 2: 1 + 1 on task 8
    assert!(bench.view.quest_progress(PLAYER, 1, 0).c0 == 3);
    assert!(bench.view.quest_progress(PLAYER, 2, 0).c0 == 2);
}

/// The setup alone, for the write counts of `snforge test --detailed-resources`: a test's
/// `StorageWrite` minus this baseline's is its call's writes.
#[test]
#[available_gas(l2_gas: 4680575)]
fn baseline_writes_setup() {
    setup();
}

/// The setup of the fix loop 3 fixtures alone.
#[test]
#[available_gas(l2_gas: 4680575)]
fn baseline_writes_setup_totals_two() {
    setup_totals_two();
}

/// `MockBench`, quest 1 on task 7 (total 5) and quest 2 on tasks 8 and 9 (totals 5), both held.
fn setup_totals_two() -> Bench {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let bench = Bench {
        quest: IQuestDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
    };
    bench.quest.set_reporter(test_address(), true);
    bench.quest.define(1, one_off(), array![task(7, 5)].span(), array![].span());
    bench.quest.define(2, one_off(), array![task(8, 5), task(9, 5)].span(), array![].span());
    bench.quest.accept(PLAYER, 1);
    bench.quest.accept(PLAYER, 2);
    bench
}
