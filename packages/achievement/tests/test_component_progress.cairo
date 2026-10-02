//! Progress in event mode, the only mode (ARC-01 §2 D-1, §3.11, amended by the decision of
//! 2026-09-29): one `AchievementProgressed` per merged non-zero entry; nothing read but the
//! reporter, nothing written, no hook.

use quiver_achievement::component::AchievementComponent::{AchievementProgressed, Event};
use quiver_achievement::constants::MAX_ENTRIES;
use quiver_achievement::errors;
use quiver_achievement::interface::{
    IAchievementSafeDispatcherTrait, IAchievementViewDispatcherTrait,
};
use snforge_std::{EventSpyAssertionsTrait, EventSpyTrait, spy_events};
use super::helpers::{distinct_entries, entry};
use super::mocks::IMockConsumerDispatcherTrait;
use super::setup::{
    PLAYER, as_reporter, assert_error, define_simple, deploy, deploy_consumer, ephemeral, report,
    report_many, retire, stop,
};

fn progressed(player_id: felt252, task_id: u32, count: u32) -> Event {
    Event::AchievementProgressed(AchievementProgressed { player_id, task_id, count })
}

#[test]
#[available_gas(l2_gas: 3232495)]
fn achievement_event_mode_emits_only_progressed() {
    let a = deploy();
    define_simple(a, 1, 7, 10);
    let (before, _) = a.view.achievement_definition(1);
    let mut spy = spy_events();
    report(a, PLAYER, 7, 3);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    spy.assert_emitted(@array![(a.address, progressed(PLAYER, 7, 3))]);
    let (after, _) = a.view.achievement_definition(1);
    assert!(after == before);
}

/// `AchievementProgressed`: keys player and task; data the count.
#[test]
#[available_gas(l2_gas: 1913611)]
fn achievement_progressed_event_fields() {
    let a = deploy();
    let mut spy = spy_events();
    report(a, PLAYER, 7, 0xffffffff);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    let (from, event) = events.at(0);
    assert!(*from == a.address);
    assert!(event.keys == @array![selector!("AchievementProgressed"), PLAYER, 7]);
    assert!(event.data == @array![0xffffffff]);
}

/// Tiers are separate achievements on one task (A-7): one event, whatever the tiers.
#[test]
#[available_gas(l2_gas: 4708385)]
fn achievement_tiers_share_task_one_event() {
    let a = deploy();
    define_simple(a, 1, 7, 10);
    define_simple(a, 2, 7, 50);
    define_simple(a, 3, 7, 100);
    let mut spy = spy_events();
    report(a, PLAYER, 7, 60);
    let events = spy.get_events().events;
    assert!(events.len() == 1);
    spy.assert_emitted(@array![(a.address, progressed(PLAYER, 7, 60))]);
}

/// Progress reads no definition: a task of a retired achievement, or of none, still emits.
#[test]
#[available_gas(l2_gas: 3763623)]
fn achievement_retired_progress_still_emits() {
    let a = deploy();
    define_simple(a, 1, 7, 10);
    retire(a, 1);
    let mut spy = spy_events();
    report(a, PLAYER, 7, 1);
    report(a, PLAYER, 8, 2);
    spy
        .assert_emitted(
            @array![(a.address, progressed(PLAYER, 7, 1)), (a.address, progressed(PLAYER, 8, 2))],
        );
    assert!(spy.get_events().events.len() == 2);
}

#[test]
#[available_gas(l2_gas: 2082989)]
fn achievement_batch_one_event_per_merged_task() {
    let a = deploy();
    let mut spy = spy_events();
    report_many(a, PLAYER, array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span());
    let events = spy.get_events().events;
    assert!(events.len() == 2);
    // In the order of first occurrence
    let (_, first) = events.at(0);
    assert!(first.keys == @array![selector!("AchievementProgressed"), PLAYER, 1]);
    assert!(first.data == @array![3]);
    let (_, second) = events.at(1);
    assert!(second.keys == @array![selector!("AchievementProgressed"), PLAYER, 3]);
    assert!(second.data == @array![1]);
}

#[test]
#[available_gas(l2_gas: 2481411)]
fn achievement_zero_count_emits_nothing() {
    let a = deploy();
    let mut spy = spy_events();
    report(a, PLAYER, 7, 0);
    report_many(a, PLAYER, array![entry(7, 0), entry(8, 0)].span());
    report_many(a, PLAYER, array![].span());
    assert!(spy.get_events().events.len() == 0);
}

#[test]
#[available_gas(l2_gas: 3292376)]
fn achievement_batch_bound_accepted() {
    let a = deploy();
    let mut spy = spy_events();
    report_many(a, PLAYER, distinct_entries(1, MAX_ENTRIES, 1));
    assert!(spy.get_events().events.len() == MAX_ENTRIES);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1958324)]
fn achievement_batch_above_bound_reverts() {
    let a = deploy();
    as_reporter(a);
    assert_error(
        a.safe.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES + 1, 1)),
        errors::TOO_MANY_ENTRIES,
    );
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1946228)]
fn achievement_batch_duplicates_count_toward_bound() {
    let a = deploy();
    let mut entries = array![];
    let mut i = 0;
    while i <= MAX_ENTRIES {
        entries.append(entry(7, 1));
        i += 1;
    }
    as_reporter(a);
    assert_error(a.safe.progress_many(PLAYER, entries.span()), errors::TOO_MANY_ENTRIES);
    stop(a);
}

#[test]
#[feature("safe_dispatcher")]
#[available_gas(l2_gas: 1993459)]
fn achievement_batch_rejects_task_zero() {
    let a = deploy();
    as_reporter(a);
    assert_error(a.safe.progress_many(PLAYER, array![entry(0, 1)].span()), errors::INVALID_TASK);
    assert_error(a.safe.progress(PLAYER, 0, 0), errors::INVALID_TASK);
    stop(a);
}

/// The Sierra gas of a 16-entry `progress_many` through the consumer's results entrypoint (the
/// internal layer), measured 2026-09-29.
const WRITES_NOTHING_REFERENCE: u128 = 603146;

/// Progress writes nothing: its storage writes are counted with `--detailed-resources`
/// (`GAS.md`), and here its Sierra gas is guarded. A 16-entry call through the internal layer
/// stays within 20 000 of its reference; one storage write is about 73 820, so a write added to
/// the path fails the guard.
#[test]
#[available_gas(l2_gas: 2605760)]
fn achievement_progress_writes_nothing() {
    let (address, consumer, _) = deploy_consumer();
    snforge_std::start_cheat_caller_address(address, ephemeral());
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    let before = core::testing::get_available_gas();
    consumer.submit_results(PLAYER, entries);
    let used = before - core::testing::get_available_gas();
    snforge_std::stop_cheat_caller_address(address);
    assert!(
        used + 20000 >= WRITES_NOTHING_REFERENCE && used <= WRITES_NOTHING_REFERENCE + 20000,
        "progress_many used {} Sierra gas, reference {}",
        used,
        WRITES_NOTHING_REFERENCE,
    );
}
