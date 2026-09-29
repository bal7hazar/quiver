//! "One write per record" asserted on the writes themselves (fix loop 1, point 3).
//!
//! snforge exposes no syscall count to a test. Each test therefore measures the Sierra gas of
//! one `progress_many` call with `core::testing::get_available_gas()` around the dispatcher
//! call: deterministic, and without the state-diff charges of the L2 gas. A storage write costs
//! 58 820 of it (`write_costs_58_820_sierra_gas` below). Each call is checked against its
//! reference within `TOLERANCE` = 20 000: one write more (or one less) than the rule allows
//! fails the test. The consumer is `MockBench`, whose hooks do nothing, so that no hook's write
//! is counted.
//!
//! References, and the writes they contain: completing, P and R; not completing, P only;
//! duplicate entries merged, P once.

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
const COMPLETING: u128 = 792086;
const NOT_COMPLETING: u128 = 634056;
const DUPLICATES: u128 = 674239;
const TWO_TASKS_COMPLETING: u128 = 755152;

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
#[available_gas(l2_gas: 6628069)]
fn quest_progress_completing_writes_p_and_r() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 2)].span()), COMPLETING);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).completed);
}

#[test]
#[available_gas(l2_gas: 6002962)]
fn quest_progress_not_completing_writes_p_only() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 1)].span()), NOT_COMPLETING);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).c0 == 1);
}

#[test]
#[available_gas(l2_gas: 6045784)]
fn quest_progress_duplicate_entries_write_p_once() {
    let bench = setup();
    assert_gas(call_gas(bench, array![entry(7, 1), entry(7, 0), entry(7, 0)].span()), DUPLICATES);
    assert!(bench.view.quest_progress(PLAYER, 1, 0).c0 == 1);
}

/// Two tasks of one quest in one call, completing: P once and R once.
#[test]
#[available_gas(l2_gas: 6589950)]
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
