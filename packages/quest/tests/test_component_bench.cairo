//! Benchmarks of the component: one per entrypoint, on the worst case of ARC-01 §5.1 as amended by
//! D-135 (docs/CAIRO.md §2). Each is a test with its budget.
//!
//! Each benchmark has a baseline, `baseline_*`, that runs the same setup without the measured
//! call. The call's cost is the benchmark minus its baseline: in L2 gas, and exactly in storage
//! reads and writes with `snforge test --detailed-resources`. The consumer is `MockBench`, whose
//! hooks do nothing, so that a figure is the component's own, or `MockBenchHook`, whose
//! `on_quest_complete` writes one slot per completion.
//!
//! **The worst call the package allows** (Scope 5 of ARC-03c): `MAX_ENTRIES` entries whose last
//! one collides modulo 128 (`batch_merge`'s plain merge in full), every held quest completing,
//! each with 3 tasks at the last three positions of the batch (the longest lookups), a daily
//! schedule (the interval id is a division). For `MAX_HELD = 4` the list is built by `accept`;
//! **for 8, entries 5 to 8 are seeded** into slots 2 and 3 of the list with snforge's `store`
//! (the component accepts at most `MAX_HELD`, but its walk reads up to `HELD_SLOTS` slots, so the
//! same code walks the 8).

use quiver_quest::constants::{MAX_CONDITIONS, MAX_ENTRIES, MAX_HELD};
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::models::progress::ProgressSlot;
use quiver_quest::models::record::RecordSlot;
use quiver_quest::types::batch::TaskProgress;
use quiver_quest::types::mode::Mode;
use quiver_quest::types::schedule::QuestSchedule;
use quiver_quest::types::task::QuestTask;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, map_entry_address, start_cheat_block_timestamp,
    store, test_address,
};
use starknet::ContractAddress;
use starknet::storage_access::StorePacking;
use super::helpers::{DAY, distinct_entries, entry, held, held_slot, one_off, schedule, task};
use super::setup::PLAYER;

/// Prerequisites are quests `PREREQUISITE + 1 ..= PREREQUISITE + 7`, on tasks
/// `PREREQUISITE_TASK + 1 ..= PREREQUISITE_TASK + 7`.
const PREREQUISITE: u32 = 1000;
const PREREQUISITE_TASK: u32 = 2000;
/// The quest a single-quest benchmark acts on.
const D: u32 = 5000;
/// Day 20 000 (2024-10-04), one hour in: interval id `NOW_DAY` of a daily quest.
const NOW_DAY: u64 = 20000;
const NOW: u64 = 20000 * 86400 + 3600;

#[derive(Drop, Copy)]
struct Bench {
    address: ContractAddress,
    quest: IQuestDispatcher,
    view: IQuestViewDispatcher,
}

fn deploy_named(name: ByteArray) -> Bench {
    let class = declare(name).unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let bench = Bench {
        address,
        quest: IQuestDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
    };
    start_cheat_block_timestamp(address, NOW);
    bench.quest.set_reporter(test_address(), true);
    bench
}

/// `MockBench` (hooks empty), with the test contract as its reporter, at `NOW`.
fn deploy() -> Bench {
    deploy_named("MockBench")
}

/// `MockBenchHook` (`on_quest_complete` writes one slot), at `NOW`.
fn deploy_hook() -> Bench {
    deploy_named("MockBenchHook")
}

fn daily() -> QuestSchedule {
    schedule(0, 0, DAY, DAY)
}

fn one(task_id: u32) -> Span<QuestTask> {
    array![task(task_id, 1)].span()
}

fn no_conditions() -> Span<u32> {
    array![].span()
}

/// Seven prerequisites, defined and completed by `PLAYER`; returns their ids.
fn completed_prerequisites(bench: Bench) -> Span<u32> {
    let mut ids = array![];
    let mut i: u32 = 1;
    while i <= MAX_CONDITIONS.into() {
        let id = PREREQUISITE + i;
        bench.quest.define(id, one_off(), one(PREREQUISITE_TASK + i), no_conditions());
        bench.quest.accept(PLAYER, id);
        bench.quest.progress(PLAYER, PREREQUISITE_TASK + i, 1, Mode::Storage);
        ids.append(id);
        i += 1;
    }
    ids.span()
}

// Event mode: nothing read, nothing written

#[test]
#[available_gas(l2_gas: 908177)]
fn baseline_deployed() {
    deploy();
}

#[test]
#[available_gas(l2_gas: 1131161)]
fn bench_progress_event_mode() {
    let bench = deploy();
    bench.quest.progress(PLAYER, 1, 1, Mode::Event);
}

#[test]
#[available_gas(l2_gas: 2231383)]
fn bench_progress_many_event_mode_worst() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES, 1), Mode::Event);
}

#[test]
#[available_gas(l2_gas: 1546797)]
fn bench_set_reporter() {
    let bench = deploy();
    bench.quest.set_reporter(PLAYER.try_into().unwrap(), true);
}

/// Tasks 1..=15, then `last`, each with count 1. `[1..=15, 129]` (129 = 1 mod 128) meets a
/// collision only at the 16th entry, so the fast pass of `batch_merge` runs 15 entries and then
/// the plain merge runs in full (ARC-03a's worst case of `batch_merge`).
fn fifteen_then(last: u32) -> Span<TaskProgress> {
    let mut entries = array![];
    let mut task_id: u32 = 1;
    while task_id < MAX_ENTRIES {
        entries.append(entry(task_id, 1));
        task_id += 1;
    }
    entries.append(entry(last, 1));
    entries.span()
}

#[test]
#[available_gas(l2_gas: 2831276)]
fn bench_progress_many_event_mode_late_collision() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Event);
}

#[test]
#[available_gas(l2_gas: 2770775)]
fn bench_progress_many_event_mode_late_duplicate() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, fifteen_then(15), Mode::Event);
}

// set_reporter on a reporter already registered (fix loop 3, point 4): revoking it zeroes its
// slot; setting it to its value again writes it unchanged

fn other_reporter() -> ContractAddress {
    'other reporter'.try_into().unwrap()
}

fn reporter_registered_setup() -> Bench {
    let bench = deploy();
    bench.quest.set_reporter(other_reporter(), true);
    bench
}

#[test]
#[available_gas(l2_gas: 1546797)]
fn baseline_reporter_registered() {
    reporter_registered_setup();
}

#[test]
#[available_gas(l2_gas: 1342604)]
fn bench_set_reporter_revoke() {
    let bench = reporter_registered_setup();
    bench.quest.set_reporter(other_reporter(), false);
}

#[test]
#[available_gas(l2_gas: 1764494)]
fn bench_set_reporter_unchanged() {
    let bench = reporter_registered_setup();
    bench.quest.set_reporter(other_reporter(), true);
}

// The worst call: `held` quests 1..=held held and all completing

/// The worst tasks for the lookups of `progress_add` in `fifteen_then(129)`: its last three.
fn worst_tasks() -> Span<QuestTask> {
    array![task(129, 1), task(15, 1), task(14, 1)].span()
}

/// Quests 1..=`held`, daily, on the worst tasks, all held by `PLAYER` in interval `NOW_DAY`: the
/// first `MAX_HELD` by `accept`, the rest seeded into the list (slots 2 and 3).
fn held_setup(bench: Bench, held_count: u32) {
    let mut id: u32 = 1;
    while id <= held_count {
        bench.quest.define(id, daily(), worst_tasks(), no_conditions());
        if id <= MAX_HELD.into() {
            bench.quest.accept(PLAYER, id);
        }
        id += 1;
    }
    let mut slot: u32 = 2;
    while 2 * slot < held_count {
        let e0 = held(2 * slot + 1, NOW_DAY);
        let e1 = if 2 * slot + 2 <= held_count {
            held(2 * slot + 2, NOW_DAY)
        } else {
            held(0, 0)
        };
        let key = array![PLAYER, slot.into()].span();
        store(
            bench.address,
            map_entry_address(selector!("Quest_held"), key),
            array![StorePacking::pack(held_slot(e0, e1))].span(),
        );
        slot += 1;
    }
    assert!(bench.view.quest_held(PLAYER).len() == held_count);
}

fn worst_setup(bench: Bench, held_count: u32) -> Bench {
    held_setup(bench, held_count);
    bench
}

/// Whether each of quests 1..=`held_count` is completed: the same view calls in a benchmark and
/// its baseline, so that their difference is the call alone.
fn completed(bench: Bench, held_count: u32) -> Array<bool> {
    let mut out = array![];
    let mut id: u32 = 1;
    while id <= held_count {
        out.append(bench.view.quest_progress(PLAYER, id, NOW_DAY).completed);
        id += 1;
    }
    out
}

fn all(value: bool, n: u32) -> Array<bool> {
    let mut out = array![];
    let mut i: u32 = 0;
    while i < n {
        out.append(value);
        i += 1;
    }
    out
}

#[test]
#[available_gas(l2_gas: 10442628)]
fn baseline_progress_many_worst_held4() {
    let bench = worst_setup(deploy(), 4);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 4) == all(false, 4));
}

#[test]
#[available_gas(l2_gas: 16958764)]
fn bench_progress_many_worst_held4() {
    let bench = worst_setup(deploy(), 4);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 4) == all(true, 4));
}

#[test]
#[available_gas(l2_gas: 17299160)]
fn baseline_progress_many_worst_held8() {
    let bench = worst_setup(deploy(), 8);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 8) == all(false, 8));
}

#[test]
#[available_gas(l2_gas: 29286037)]
fn bench_progress_many_worst_held8() {
    let bench = worst_setup(deploy(), 8);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 8) == all(true, 8));
}

#[test]
#[available_gas(l2_gas: 10442628)]
fn baseline_progress_many_worst_held4_hook() {
    let bench = worst_setup(deploy_hook(), 4);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 4) == all(false, 4));
}

#[test]
#[available_gas(l2_gas: 18864430)]
fn bench_progress_many_worst_held4_hook() {
    let bench = worst_setup(deploy_hook(), 4);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 4) == all(true, 4));
}

#[test]
#[available_gas(l2_gas: 17299160)]
fn baseline_progress_many_worst_held8_hook() {
    let bench = worst_setup(deploy_hook(), 8);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 8) == all(false, 8));
}

#[test]
#[available_gas(l2_gas: 33097369)]
fn bench_progress_many_worst_held8_hook() {
    let bench = worst_setup(deploy_hook(), 8);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 8) == all(true, 8));
}

// The worst call with the player's slots existing (fix loop 2, (a)): the same quests, held, but
// each quest's progress P already counts 1 of 2 on each task in this interval, and its record R
// already has one completion (a quest completed in an earlier interval). The call completes every
// held quest as above, and overwrites P and R instead of creating them. With the hook, its slot
// is new, as above: the consumer's slot is its own, and the worst is a new one.

fn existing_setup(bench: Bench, held_count: u32) -> Bench {
    // totals 2: the batch's count of 1 completes a quest already at 1
    let tasks = array![task(129, 2), task(15, 2), task(14, 2)].span();
    let mut id: u32 = 1;
    while id <= held_count {
        bench.quest.define(id, daily(), tasks, no_conditions());
        if id <= MAX_HELD.into() {
            bench.quest.accept(PLAYER, id);
        }
        let at_one = ProgressSlot { c0: 1, c1: 1, c2: 1, completed: false, claimed: false };
        store(
            bench.address,
            map_entry_address(
                selector!("Quest_progress"), array![PLAYER, id.into(), NOW_DAY.into()].span(),
            ),
            array![StorePacking::pack(at_one)].span(),
        );
        let done_once = RecordSlot { completions: 1, claims: 1, unlocked: false };
        store(
            bench.address,
            map_entry_address(selector!("Quest_records"), array![PLAYER, id.into()].span()),
            array![StorePacking::pack(done_once)].span(),
        );
        id += 1;
    }
    let mut slot: u32 = 2;
    while 2 * slot < held_count {
        let e1 = if 2 * slot + 2 <= held_count {
            held(2 * slot + 2, NOW_DAY)
        } else {
            held(0, 0)
        };
        store(
            bench.address,
            map_entry_address(selector!("Quest_held"), array![PLAYER, slot.into()].span()),
            array![StorePacking::pack(held_slot(held(2 * slot + 1, NOW_DAY), e1))].span(),
        );
        slot += 1;
    }
    assert!(bench.view.quest_held(PLAYER).len() == held_count);
    bench
}

#[test]
#[available_gas(l2_gas: 13978293)]
fn baseline_progress_many_worst_held4_existing() {
    let bench = existing_setup(deploy(), 4);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 4) == all(false, 4));
}

#[test]
#[available_gas(l2_gas: 17117629)]
fn bench_progress_many_worst_held4_existing() {
    let bench = existing_setup(deploy(), 4);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 4) == all(true, 4));
}

#[test]
#[available_gas(l2_gas: 13978293)]
fn baseline_progress_many_worst_held4_existing_hook() {
    let bench = existing_setup(deploy_hook(), 4);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 4) == all(false, 4));
}

#[test]
#[available_gas(l2_gas: 19023295)]
fn bench_progress_many_worst_held4_existing_hook() {
    let bench = existing_setup(deploy_hook(), 4);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 4) == all(true, 4));
}

#[test]
#[available_gas(l2_gas: 24368568)]
fn baseline_progress_many_worst_held8_existing() {
    let bench = existing_setup(deploy(), 8);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 8) == all(false, 8));
}

#[test]
#[available_gas(l2_gas: 29601845)]
fn bench_progress_many_worst_held8_existing() {
    let bench = existing_setup(deploy(), 8);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 8) == all(true, 8));
}

#[test]
#[available_gas(l2_gas: 24368568)]
fn baseline_progress_many_worst_held8_existing_hook() {
    let bench = existing_setup(deploy_hook(), 8);
    let _entries = fifteen_then(129);
    assert!(completed(bench, 8) == all(false, 8));
}

#[test]
#[available_gas(l2_gas: 33413177)]
fn bench_progress_many_worst_held8_existing_hook() {
    let bench = existing_setup(deploy_hook(), 8);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(completed(bench, 8) == all(true, 8));
}

// The §5.1 witness, adapted (D-135): `MAX_ENTRIES` distinct tasks 1..=16 (fast merge), the
// `MAX_HELD` held quests on tasks 14, 15, 16 all completing, and 28 quests on each of the 16 tasks
// defined but not held, which the call does not read.

fn bound_setup() -> Bench {
    let bench = deploy();
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        bench
            .quest
            .define(
                id, daily(), array![task(16, 1), task(15, 1), task(14, 1)].span(), no_conditions(),
            );
        bench.quest.accept(PLAYER, id);
        id += 1;
    }
    let mut task_id: u32 = 1;
    while task_id <= MAX_ENTRIES {
        let mut n: u32 = 0;
        while n < 28 {
            bench.quest.define(100 + task_id * 28 + n, daily(), one(task_id), no_conditions());
            n += 1;
        }
        task_id += 1;
    }
    bench
}

#[test]
#[available_gas(l2_gas: 575200815)]
fn baseline_batch_bound_accepted() {
    let bench = bound_setup();
    let _entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(completed(bench, 4) == all(false, 4));
    assert!(!bench.view.quest_progress(PLAYER, 100 + 28, NOW_DAY).completed);
}

/// Meaning changed by D-135: what the call reaches is the held list, not the quests of the tasks.
#[test]
#[available_gas(l2_gas: 581105623)]
fn quest_batch_bound_accepted() {
    let bench = bound_setup();
    bench.quest.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES, 1), Mode::Storage);
    assert!(completed(bench, 4) == all(true, 4));
    assert!(!bench.view.quest_progress(PLAYER, 100 + 28, NOW_DAY).completed);
}

// accept at its worst: quest D with 3 tasks and 7 prerequisites met and not cached, and a full
// list whose `MAX_HELD` entries are all dead, pruned by this accept: expired (one read each), or
// completed in the current interval (two reads each)

/// Quests 1..=`MAX_HELD` (task `10 + id`) fill the list with dead entries. `expired`: daily,
/// accepted yesterday and never completed. Otherwise: one-off, accepted and completed now.
fn accept_worst_setup(expired: bool) -> Bench {
    let bench = deploy();
    if expired {
        start_cheat_block_timestamp(bench.address, NOW - 86400);
    }
    let conditions = completed_prerequisites(bench);
    let quest_schedule = if expired {
        daily()
    } else {
        one_off()
    };
    let mut entries = array![];
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        bench.quest.define(id, quest_schedule, one(10 + id), no_conditions());
        bench.quest.accept(PLAYER, id);
        entries.append(entry(10 + id, 1));
        id += 1;
    }
    if expired {
        start_cheat_block_timestamp(bench.address, NOW);
    } else {
        bench.quest.progress_many(PLAYER, entries.span(), Mode::Storage);
    }
    bench.quest.define(D, one_off(), array![task(1, 5), task(2, 5), task(3, 5)].span(), conditions);
    assert!(bench.view.quest_held(PLAYER).len() == MAX_HELD.into());
    assert!(!bench.view.quest_is_accepted(PLAYER, 1));
    bench
}

#[test]
#[available_gas(l2_gas: 35170656)]
fn baseline_accept_worst_expired() {
    accept_worst_setup(true);
}

#[test]
#[available_gas(l2_gas: 36844282)]
fn bench_accept_worst_expired() {
    let bench = accept_worst_setup(true);
    bench.quest.accept(PLAYER, D);
}

#[test]
#[available_gas(l2_gas: 40471879)]
fn baseline_accept_worst_completed() {
    accept_worst_setup(false);
}

#[test]
#[available_gas(l2_gas: 42315353)]
fn bench_accept_worst_completed() {
    let bench = accept_worst_setup(false);
    bench.quest.accept(PLAYER, D);
}

// accept on a mixed list (fix loop 1, point 1): recurring quests accepted yesterday, in the
// order weekly, daily, weekly, daily. Today the weekly ones are live (their interval has not
// rolled over) and the daily ones are stale: `accept` reads A and P of each live entry and A of
// each stale one, keeps the live, drops the stale, and appends D. Both list slots are updated;
// R of D is allocated (its unlock). Quest D has 3 tasks and 7 prerequisites not cached.

fn weekly() -> QuestSchedule {
    schedule(0, 0, 7 * DAY, 7 * DAY)
}

fn accept_mixed_setup() -> Bench {
    let bench = deploy();
    start_cheat_block_timestamp(bench.address, NOW - 86400);
    let conditions = completed_prerequisites(bench);
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        let quest_schedule = if id % 2 == 1 {
            weekly()
        } else {
            daily()
        };
        bench.quest.define(id, quest_schedule, one(10 + id), no_conditions());
        bench.quest.accept(PLAYER, id);
        id += 1;
    }
    start_cheat_block_timestamp(bench.address, NOW);
    bench.quest.define(D, one_off(), array![task(1, 5), task(2, 5), task(3, 5)].span(), conditions);
    assert!(bench.view.quest_is_accepted(PLAYER, 1) && !bench.view.quest_is_accepted(PLAYER, 2));
    bench
}

#[test]
#[available_gas(l2_gas: 35246980)]
fn baseline_accept_mixed() {
    accept_mixed_setup();
}

#[test]
#[available_gas(l2_gas: 37011274)]
fn bench_accept_mixed() {
    let bench = accept_mixed_setup();
    bench.quest.accept(PLAYER, D);
}

// accept that grows the list into a slot that is zero (fix loop 1, point 1): two live weekly
// quests fill slot 0; D goes to slot 1, which is allocated, and slot 0's counter is updated. R of
// D is allocated too: two allocations, the most one accept can make.

fn accept_growth_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    let mut id: u32 = 1;
    while id <= 2 {
        bench.quest.define(id, weekly(), one(10 + id), no_conditions());
        bench.quest.accept(PLAYER, id);
        id += 1;
    }
    bench.quest.define(D, one_off(), array![task(1, 5), task(2, 5), task(3, 5)].span(), conditions);
    bench
}

#[test]
#[available_gas(l2_gas: 29826334)]
fn baseline_accept_growth() {
    accept_growth_setup();
}

#[test]
#[available_gas(l2_gas: 31839363)]
fn bench_accept_growth() {
    let bench = accept_growth_setup();
    bench.quest.accept(PLAYER, D);
}

// accept that grows the list back into a slot the player used before (fix loop 2, (c)): three
// quests were held, the third abandoned; the new acceptance goes to slot 1 again. The present
// design zeroed slot 1 at the abandon and creates it again; a design that keeps the slot
// overwrites it. No prerequisite.

fn accept_regrow_setup() -> Bench {
    let bench = deploy();
    let mut id: u32 = 1;
    while id <= 4 {
        bench.quest.define(id, weekly(), one(10 + id), no_conditions());
        id += 1;
    }
    bench.quest.accept(PLAYER, 1);
    bench.quest.accept(PLAYER, 2);
    bench.quest.accept(PLAYER, 3);
    bench.quest.abandon(PLAYER, 3);
    bench
}

#[test]
#[available_gas(l2_gas: 8885940)]
fn baseline_accept_regrow() {
    accept_regrow_setup();
}

#[test]
#[available_gas(l2_gas: 9625119)]
fn bench_accept_regrow() {
    let bench = accept_regrow_setup();
    bench.quest.accept(PLAYER, 4);
}

// abandon that empties slot 1 (fix loop 2, (c)): the present design zeroes it

fn three_held_setup() -> Bench {
    let bench = deploy();
    let mut id: u32 = 1;
    while id <= 3 {
        bench.quest.define(id, weekly(), one(10 + id), no_conditions());
        bench.quest.accept(PLAYER, id);
        id += 1;
    }
    bench
}

#[test]
#[available_gas(l2_gas: 7152306)]
fn baseline_three_held() {
    three_held_setup();
}

#[test]
#[available_gas(l2_gas: 7625709)]
fn bench_abandon_shrink() {
    let bench = three_held_setup();
    bench.quest.abandon(PLAYER, 3);
}

// accept, the common case: no prerequisite, an empty list. One slot written

fn plain_setup() -> Bench {
    let bench = deploy();
    bench.quest.define(D, one_off(), array![task(1, 2)].span(), no_conditions());
    bench
}

#[test]
#[available_gas(l2_gas: 2167400)]
fn baseline_plain() {
    plain_setup();
}

#[test]
#[available_gas(l2_gas: 2975364)]
fn bench_accept_plain() {
    let bench = plain_setup();
    bench.quest.accept(PLAYER, D);
}

// The views that evaluate prerequisites or read the list, on quest D with 7 prerequisites and
// the list full of dead entries

fn prerequisites_setup() -> Bench {
    accept_worst_setup(false)
}

#[test]
#[available_gas(l2_gas: 40471879)]
fn baseline_prerequisites() {
    prerequisites_setup();
}

#[test]
#[available_gas(l2_gas: 40993508)]
fn bench_view_is_unlocked_worst() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_is_unlocked(PLAYER, D));
}

#[test]
#[available_gas(l2_gas: 40791604)]
fn bench_view_definition_worst() {
    let bench = prerequisites_setup();
    let (_, tasks, conditions) = bench.view.quest_definition(D);
    assert!(tasks.len() == 3 && conditions.len() == 7);
}

#[test]
#[available_gas(l2_gas: 40821896)]
fn bench_view_is_accepted() {
    let bench = prerequisites_setup();
    assert!(!bench.view.quest_is_accepted(PLAYER, D));
}

#[test]
#[available_gas(l2_gas: 40785503)]
fn bench_view_held_full() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_held(PLAYER).len() == MAX_HELD.into());
}

#[test]
#[available_gas(l2_gas: 40640540)]
fn bench_view_current_interval() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_current_interval(D) == Option::Some(0));
}

#[test]
#[available_gas(l2_gas: 40775423)]
fn bench_view_progress_and_record() {
    let bench = prerequisites_setup();
    assert!(!bench.view.quest_progress(PLAYER, D, 0).completed);
    assert!(bench.view.quest_record(PLAYER, D).completions == 0);
}

#[test]
#[available_gas(l2_gas: 40602803)]
fn bench_view_is_reporter() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_is_reporter(test_address()));
}

// abandon at its worst: a full list of live quests, the first abandoned, the three others move
// up: both slots written

/// Quests 1..=`MAX_HELD`, daily, on task `10 + id` with total 2, all held.
fn full_list_setup() -> Bench {
    let bench = deploy();
    let mut id: u32 = 1;
    while id <= MAX_HELD.into() {
        bench.quest.define(id, daily(), array![task(10 + id, 2)].span(), no_conditions());
        bench.quest.accept(PLAYER, id);
        id += 1;
    }
    bench
}

#[test]
#[available_gas(l2_gas: 9256191)]
fn baseline_full_list() {
    full_list_setup();
}

#[test]
#[available_gas(l2_gas: 9848549)]
fn bench_abandon_worst() {
    let bench = full_list_setup();
    bench.quest.abandon(PLAYER, 1);
}

/// A full list, one live quest progressed and not completing: the common case of a call.
#[test]
#[available_gas(l2_gas: 10717945)]
fn bench_progress_full_list_one_counts() {
    let bench = full_list_setup();
    bench.quest.progress(PLAYER, 11, 1, Mode::Storage);
}

/// A full list, one live quest completing.
#[test]
#[available_gas(l2_gas: 11466511)]
fn bench_progress_full_list_one_completes() {
    let bench = full_list_setup();
    bench.quest.progress(PLAYER, 11, 2, Mode::Storage);
}

/// A full list, every quest completing: 16 entries, 4 of them the quests' tasks.
#[test]
#[available_gas(l2_gas: 14698776)]
fn bench_progress_full_list_all_complete() {
    let bench = full_list_setup();
    bench
        .quest
        .progress_many(
            PLAYER,
            array![entry(11, 2), entry(12, 2), entry(13, 2), entry(14, 2)].span(),
            Mode::Storage,
        );
}

/// A full list, the batch on none of its tasks: the list and each quest read, nothing written.
#[test]
#[available_gas(l2_gas: 10233349)]
fn bench_progress_full_list_none_counts() {
    let bench = full_list_setup();
    bench.quest.progress(PLAYER, 99, 1, Mode::Storage);
}

// progress on one held quest; then claim

fn accepted_setup() -> Bench {
    let bench = plain_setup();
    bench.quest.accept(PLAYER, D);
    bench
}

#[test]
#[available_gas(l2_gas: 2975364)]
fn baseline_accepted() {
    accepted_setup();
}

#[test]
#[available_gas(l2_gas: 3852593)]
fn bench_progress_plain() {
    let bench = accepted_setup();
    bench.quest.progress(PLAYER, 1, 1, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4425851)]
fn bench_progress_plain_completing() {
    let bench = accepted_setup();
    bench.quest.progress(PLAYER, 1, 2, Mode::Storage);
}

/// No quest held: one slot of the list read, nothing else.
#[test]
#[available_gas(l2_gas: 2405494)]
fn bench_progress_nothing_held() {
    let bench = plain_setup();
    bench.quest.progress(PLAYER, 1, 1, Mode::Storage);
}

/// Two quests held, D second: abandoning it rewrites slot 0 alone.
fn two_held_setup() -> Bench {
    let bench = deploy();
    bench.quest.define(1, one_off(), one(9), no_conditions());
    bench.quest.accept(PLAYER, 1);
    bench.quest.define(D, one_off(), array![task(1, 2)].span(), no_conditions());
    bench.quest.accept(PLAYER, D);
    bench
}

#[test]
#[available_gas(l2_gas: 4721556)]
fn baseline_two_held() {
    two_held_setup();
}

#[test]
#[available_gas(l2_gas: 5165045)]
fn bench_abandon() {
    let bench = two_held_setup();
    bench.quest.abandon(PLAYER, D);
}

fn completed_setup() -> Bench {
    let bench = accepted_setup();
    bench.quest.progress(PLAYER, 1, 2, Mode::Storage);
    bench
}

#[test]
#[available_gas(l2_gas: 4425851)]
fn baseline_completed() {
    completed_setup();
}

#[test]
#[available_gas(l2_gas: 4808597)]
fn bench_claim() {
    let bench = completed_setup();
    assert!(bench.quest.claim(PLAYER, D, 0) == 0);
}

// retire and define: quest D with 3 tasks and 7 conditions. Neither touches a task any more

fn retire_worst_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    bench.quest.define(D, one_off(), array![task(1, 1), task(2, 1), task(3, 1)].span(), conditions);
    bench
}

#[test]
#[available_gas(l2_gas: 26325109)]
fn baseline_retire_worst() {
    retire_worst_setup();
}

#[test]
#[available_gas(l2_gas: 27378826)]
fn bench_retire_worst() {
    let bench = retire_worst_setup();
    bench.quest.retire(D);
}

fn define_worst_setup() -> (Bench, Span<u32>) {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    (bench, conditions)
}

#[test]
#[available_gas(l2_gas: 23611846)]
fn baseline_define_worst() {
    define_worst_setup();
}

#[test]
#[available_gas(l2_gas: 26324710)]
fn bench_define_worst() {
    let (bench, conditions) = define_worst_setup();
    bench.quest.define(D, one_off(), array![task(1, 1), task(2, 1), task(3, 1)].span(), conditions);
}
