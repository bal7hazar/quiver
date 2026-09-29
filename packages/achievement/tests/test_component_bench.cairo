//! Benchmarks of the component: one per entrypoint on its worst case, and the game's use
//! (docs/CAIRO.md §2; the decision of 2026-09-29). Each is a test with its budget.
//!
//! Each benchmark has a baseline, `baseline_*`, that runs the same setup without the measured
//! call. The call's cost is the benchmark minus its baseline: in L2 gas, and exactly in storage
//! reads and writes with `snforge test --detailed-resources`. The consumer is `MockBench`, whose
//! `authorize_admin` accepts every caller; the test contract is its reporter, so that the reads
//! include the reporter check of the external ABI.
//!
//! **The worst call the package allows**: `progress_many` with `MAX_ENTRIES` entries on the
//! slowest merge path, a late modulo-128 collision or a late duplicate (the plain merge in full),
//! each emitting its events. Nothing else grows with the configuration: progress reads no
//! definition, so the number of achievements on a task costs it nothing.

use quiver_achievement::constants::MAX_ENTRIES;
use quiver_achievement::interface::{
    IAchievementDispatcher, IAchievementDispatcherTrait, IAchievementViewDispatcher,
    IAchievementViewDispatcherTrait,
};
use quiver_achievement::logic::{AchievementTask, TaskProgress};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare, test_address};
use starknet::ContractAddress;
use super::helpers::{always, distinct_entries, entry, fifteen_then, one, task};
use super::setup::PLAYER;

#[derive(Drop, Copy)]
struct Bench {
    address: ContractAddress,
    achievement: IAchievementDispatcher,
    view: IAchievementViewDispatcher,
}

/// `MockBench`, with the test contract as its reporter.
fn deploy() -> Bench {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let bench = Bench {
        address,
        achievement: IAchievementDispatcher { contract_address: address },
        view: IAchievementViewDispatcher { contract_address: address },
    };
    bench.achievement.set_reporter(test_address(), true);
    bench
}

fn three_tasks() -> Span<AchievementTask> {
    array![task(1, 0xffffffff), task(2, 0xffffffff), task(3, 0xffffffff)].span()
}

// Progress: nothing read but the reporter, nothing written

#[test]
#[available_gas(l2_gas: 829080)]
fn baseline_deployed() {
    deploy();
}

#[test]
#[available_gas(l2_gas: 1048778)]
fn bench_progress() {
    let bench = deploy();
    bench.achievement.progress(PLAYER, 1, 1);
}

#[test]
#[available_gas(l2_gas: 2136841)]
fn bench_progress_many_sixteen_distinct() {
    let bench = deploy();
    bench.achievement.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES, 1));
}

/// The worst `progress_many`: 15 entries on the fast path, a collision modulo 128 at the 16th,
/// then the plain merge in full; 16 events.
#[test]
#[available_gas(l2_gas: 2736734)]
fn bench_progress_many_late_collision() {
    let bench = deploy();
    bench.achievement.progress_many(PLAYER, fifteen_then(129));
}

/// A late duplicate: the plain merge in full; 15 events.
#[test]
#[available_gas(l2_gas: 2677073)]
fn bench_progress_many_late_duplicate() {
    let bench = deploy();
    bench.achievement.progress_many(PLAYER, fifteen_then(15));
}

/// The worst call with 3 achievements of 3 tasks defined on each of the 16 tasks: the same cost
/// as without them, since progress reads no definition.
#[test]
#[available_gas(l2_gas: 61361139)]
fn baseline_sixteen_tasks_defined() {
    sixteen_tasks_defined();
}

fn sixteen_tasks_defined() -> Bench {
    let bench = deploy();
    let mut id: u32 = 1;
    while id <= 48 {
        // Achievement `id` on tasks id % 16 + 1 and two others: 3 per task at least
        let t = id % 16 + 1;
        let tasks = array![task(t, 1), task((t % 16) + 1, 1), task(((t + 1) % 16) + 1, 1)];
        bench.achievement.define(id, always(), tasks.span(), 10);
        id += 1;
    }
    bench
}

#[test]
#[available_gas(l2_gas: 63268583)]
fn bench_progress_many_late_collision_with_definitions() {
    let bench = sixteen_tasks_defined();
    bench.achievement.progress_many(PLAYER, fifteen_then(129));
}

// Admin entrypoints

#[test]
#[available_gas(l2_gas: 1572102)]
fn bench_define_one_task() {
    let bench = deploy();
    bench.achievement.define(1, always(), one(1, 10), 10);
}

/// The worst `define`: 3 tasks, so A and B are both created.
#[test]
#[available_gas(l2_gas: 2085962)]
fn bench_define_worst() {
    let bench = deploy();
    bench
        .achievement
        .define(1, super::helpers::window(1, 0xffffffffffffffff), three_tasks(), 0xffff);
}

fn defined_setup() -> Bench {
    let bench = deploy();
    bench.achievement.define(1, always(), three_tasks(), 10);
    bench
}

#[test]
#[available_gas(l2_gas: 2086151)]
fn baseline_defined() {
    defined_setup();
}

#[test]
#[available_gas(l2_gas: 2338949)]
fn bench_retire() {
    let bench = defined_setup();
    bench.achievement.retire(1);
}

#[test]
#[available_gas(l2_gas: 2310987)]
fn bench_view_definition_worst() {
    let bench = defined_setup();
    let (_, tasks) = bench.view.achievement_definition(1);
    assert!(tasks.len() == 3);
}

#[test]
#[available_gas(l2_gas: 960005)]
fn bench_view_is_reporter() {
    let bench = deploy();
    assert!(bench.view.achievement_is_reporter(test_address()));
}

#[test]
#[available_gas(l2_gas: 1466861)]
fn bench_set_reporter() {
    let bench = deploy();
    bench.achievement.set_reporter(PLAYER.try_into().unwrap(), true);
}

fn other_reporter() -> ContractAddress {
    'other reporter'.try_into().unwrap()
}

fn reporter_registered_setup() -> Bench {
    let bench = deploy();
    bench.achievement.set_reporter(other_reporter(), true);
    bench
}

#[test]
#[available_gas(l2_gas: 1466861)]
fn baseline_reporter_registered() {
    reporter_registered_setup();
}

/// Zeroes the slot the setup created: in the test, the write minus the allocation it undoes.
#[test]
#[available_gas(l2_gas: 1261827)]
fn bench_set_reporter_revoke() {
    let bench = reporter_registered_setup();
    bench.achievement.set_reporter(other_reporter(), false);
}

#[test]
#[available_gas(l2_gas: 1683717)]
fn bench_set_reporter_unchanged() {
    let bench = reporter_registered_setup();
    bench.achievement.set_reporter(other_reporter(), true);
}

// The game's use (design/13, MVP): 8 titles, tiers as separate achievements on one task each (A-7)

/// Title `t` (1..=8) reports on task `100 + t`; its tier `k` (1-based) is achievement `10t + k`.
/// Thresholds are the tiers of design/13; where it gives a share ("half", "50 %", "all"), the
/// denominator is illustrative: 6 zones, 10 quests, 8 dungeons, 5 trials, 20 recipes, and an
/// experience unit of 10 000 for "level 20 worth". They change the stored totals only, not the
/// cost.
fn titles() -> Span<Span<u32>> {
    array![
        array![1, 3, 6].span(), // Pathfinder of Region 1: zones revealed in one instance
        array![5, 8, 10].span(), // Warden of Region 1: distinct quests, 50 / 80 / 100 %
        array![1, 3, 6, 8].span(), // Nestbreaker: distinct dungeons, 1 / 3 / 6 / all
        array![10000, 40000, 100000].span(), // Unbroken: experience since the last defeat
        array![1, 3, 5].span(), // Flawless: trials passed at the first attempt, 1 / 3 / all
        array![10, 20].span(), // Grimoire keeper of Region 1: recipes, 50 / 100 %
        array![1, 3, 6].span(), // Veteran (account): professions at Silver
        array![10, 100, 1000, 10000, 100000].span() // Scavenger (account): remains looted
    ]
        .span()
}

fn define_titles(bench: Bench) -> u32 {
    let mut defined = 0;
    let mut t: u32 = 1;
    for tiers in titles() {
        let mut k: u32 = 1;
        for total in *tiers {
            bench
                .achievement
                .define(10 * t + k, always(), one(100 + t, *total), 10 * k.try_into().unwrap());
            defined += 1;
            k += 1;
        }
        t += 1;
    }
    defined
}

#[test]
#[available_gas(l2_gas: 20281097)]
fn bench_game_define_titles() {
    let bench = deploy();
    assert!(define_titles(bench) == 26);
}

fn game_setup() -> Bench {
    let bench = deploy();
    define_titles(bench);
    bench
}

#[test]
#[available_gas(l2_gas: 20279396)]
fn baseline_game_defined() {
    game_setup();
}

/// A typical results call: the adventurer's six character titles each move (tasks 101 to 106),
/// then the account's two (107, 108), in the one results transaction: two `progress_many` calls,
/// one per player id.
#[test]
#[available_gas(l2_gas: 21150610)]
fn bench_game_results_call() {
    let bench = game_setup();
    let adventurer: Span<TaskProgress> = array![
        entry(101, 1), entry(102, 1), entry(103, 1), entry(104, 2500), entry(105, 1), entry(106, 2),
    ]
        .span();
    bench.achievement.progress_many('adventurer', adventurer);
    bench.achievement.progress_many('account', array![entry(107, 1), entry(108, 14)].span());
}

/// The game's bound (A-10): 16 distinct tasks in one call, the 8 of the titles and 8 others.
#[test]
#[available_gas(l2_gas: 21586946)]
fn bench_game_results_call_sixteen() {
    let bench = game_setup();
    bench.achievement.progress_many('adventurer', distinct_entries(101, MAX_ENTRIES, 1));
}
