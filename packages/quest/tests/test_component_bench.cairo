//! Benchmarks of the component: one per entrypoint, on the worst case of ARC-01 §5.1
//! (docs/CAIRO.md §2). Each is a test with its budget.
//!
//! Each benchmark has a baseline, `baseline_*`, that runs the same setup without the measured
//! call. The call's cost is the benchmark minus its baseline: in L2 gas, and exactly in storage
//! reads and writes with `snforge test --detailed-resources`. The consumer is `MockBench`, whose
//! hooks do nothing, so that a figure is the component's own.

use quiver_quest::constants::{MAX_CONDITIONS, MAX_ENTRIES, MAX_PAGES, QUESTS_PER_PAGE};
use quiver_quest::interface::{
    IQuestDispatcher, IQuestDispatcherTrait, IQuestViewDispatcher, IQuestViewDispatcherTrait,
};
use quiver_quest::logic::{Mode, QuestTask, TaskProgress};
use snforge_std::{ContractClassTrait, DeclareResultTrait, declare, test_address};
use super::helpers::{distinct_entries, entry, one_off, task};
use super::setup::PLAYER;

const MAX_QUESTS_PER_TASK: u32 = 28;
/// Prerequisites are quests `PREREQUISITE + 1 ..= PREREQUISITE + 7`, on tasks
/// `PREREQUISITE_TASK + 1 ..= PREREQUISITE_TASK + 7`.
const PREREQUISITE: u32 = 1000;
const PREREQUISITE_TASK: u32 = 2000;
/// The quest a single-quest benchmark acts on.
const D: u32 = 5000;

#[derive(Drop, Copy)]
struct Bench {
    quest: IQuestDispatcher,
    view: IQuestViewDispatcher,
}

/// `MockBench`, with the test contract as its reporter.
fn deploy() -> Bench {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let bench = Bench {
        quest: IQuestDispatcher { contract_address: address },
        view: IQuestViewDispatcher { contract_address: address },
    };
    bench.quest.set_reporter(test_address(), true);
    bench
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
    let mut entries: Array<TaskProgress> = array![];
    let mut i: u32 = 1;
    while i <= MAX_CONDITIONS.into() {
        bench
            .quest
            .define(
                PREREQUISITE + i, one_off(), one(PREREQUISITE_TASK + i), no_conditions(), false,
            );
        ids.append(PREREQUISITE + i);
        entries.append(entry(PREREQUISITE_TASK + i, 1));
        i += 1;
    }
    bench.quest.progress_many(PLAYER, entries.span(), Mode::Storage);
    ids.span()
}

/// `MAX_QUESTS_PER_TASK` quests `first ..` on `task_id`, each with the seven prerequisites and
/// no accept step: the witness of §5.1.
fn shared_task(bench: Bench, task_id: u32, first: u32, conditions: Span<u32>) {
    let mut id = first;
    while id < first + MAX_QUESTS_PER_TASK {
        bench.quest.define(id, one_off(), one(task_id), conditions, false);
        id += 1;
    }
}

/// `n` plain quests `first ..` on `task_id`.
fn filler(bench: Bench, task_id: u32, first: u32, n: u32) {
    let mut id = first;
    while id < first + n {
        bench.quest.define(id, one_off(), one(task_id), no_conditions(), false);
        id += 1;
    }
}

// Event mode: nothing read, nothing written

#[test]
#[available_gas(l2_gas: 830025)]
fn baseline_deployed() {
    deploy();
}

#[test]
#[available_gas(l2_gas: 1051823)]
fn bench_progress_event_mode() {
    let bench = deploy();
    bench.quest.progress(PLAYER, 1, 1, Mode::Event);
}

#[test]
#[available_gas(l2_gas: 2156581)]
fn bench_progress_many_event_mode_worst() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES, 1), Mode::Event);
}

#[test]
#[available_gas(l2_gas: 1468856)]
fn bench_set_reporter() {
    let bench = deploy();
    bench.quest.set_reporter(PLAYER.try_into().unwrap(), true);
}

// progress: one task shared by 28 live quests, each with 7 prerequisites met earlier and first
// observed now, all completing. §5.1: 340 reads, 56 writes, 28 events, 28 hooks

fn progress_worst_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    shared_task(bench, 1, 1, conditions);
    bench
}

#[test]
#[available_gas(l2_gas: 106387095)]
fn baseline_progress_worst() {
    let bench = progress_worst_setup();
    assert!(bench.view.quest_record(PLAYER, 1).completions == 0);
}

#[test]
#[available_gas(l2_gas: 151336729)]
fn bench_progress_worst() {
    let bench = progress_worst_setup();
    bench.quest.progress(PLAYER, 1, 1, Mode::Storage);
    assert!(bench.view.quest_record(PLAYER, 1).completions == 1);
}

// progress_many: 16 distinct tasks, each shared by 28 live quests (448, all distinct), each with
// 7 prerequisites met earlier and first observed now, all completing. §5.1: 5 440 reads, 896
// writes, 448 events, 448 hooks

fn progress_many_worst_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    let mut task_id: u32 = 1;
    while task_id <= MAX_ENTRIES {
        shared_task(bench, task_id, (task_id - 1) * MAX_QUESTS_PER_TASK + 1, conditions);
        task_id += 1;
    }
    bench
}

#[test]
#[available_gas(l2_gas: 1355660988)]
fn baseline_batch_bound_accepted() {
    let bench = progress_many_worst_setup();
    assert!(bench.view.quest_record(PLAYER, 448).completions == 0);
}

#[test]
#[available_gas(l2_gas: 2072538372)]
fn quest_batch_bound_accepted() {
    let bench = progress_many_worst_setup();
    bench.quest.progress_many(PLAYER, distinct_entries(1, MAX_ENTRIES, 1), Mode::Storage);
    assert!(bench.view.quest_record(PLAYER, 1).completions == 1);
    assert!(bench.view.quest_record(PLAYER, 448).completions == 1);
}

// progress_many through the slow merge (fix loop 1, point 4). Ids 1..=16 take `batch_merge`'s
// fast path; these inputs meet a collision only at the 16th entry, so the fast pass runs 15
// entries and then the plain merge runs in full (ARC-03a's worst case of `batch_merge`):
// - late collision [1..=15, 129] (129 = 1 mod 128): 16 distinct tasks, the same 448-quest
//   storage witness as above, with task 129 in place of task 16;
// - late duplicate [1..=15, 15]: 15 distinct tasks, so 420 quests.

/// Tasks 1..=15, then `last`, each with count 1.
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

/// 28 quests with 7 prerequisites on each task 1..=15, and on `last` unless it repeats one.
fn late_setup(last: u32) -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    let mut task_id: u32 = 1;
    while task_id < MAX_ENTRIES {
        shared_task(bench, task_id, (task_id - 1) * MAX_QUESTS_PER_TASK + 1, conditions);
        task_id += 1;
    }
    if last >= MAX_ENTRIES {
        shared_task(bench, last, (MAX_ENTRIES - 1) * MAX_QUESTS_PER_TASK + 1, conditions);
    }
    bench
}

#[test]
#[available_gas(l2_gas: 2756474)]
fn bench_progress_many_event_mode_late_collision() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Event);
}

#[test]
#[available_gas(l2_gas: 2695763)]
fn bench_progress_many_event_mode_late_duplicate() {
    let bench = deploy();
    bench.quest.progress_many(PLAYER, fifteen_then(15), Mode::Event);
}

#[test]
#[available_gas(l2_gas: 1355642991)]
fn baseline_progress_many_late_collision() {
    let bench = late_setup(129);
    assert!(bench.view.quest_record(PLAYER, 448).completions == 0);
}

#[test]
#[available_gas(l2_gas: 2072968638)]
fn bench_progress_many_worst_late_collision() {
    let bench = late_setup(129);
    bench.quest.progress_many(PLAYER, fifteen_then(129), Mode::Storage);
    assert!(bench.view.quest_record(PLAYER, 448).completions == 1);
}

#[test]
#[available_gas(l2_gas: 1272379072)]
fn baseline_progress_many_late_duplicate() {
    let bench = late_setup(15);
    assert!(bench.view.quest_record(PLAYER, 420).completions == 0);
}

#[test]
#[available_gas(l2_gas: 1944932499)]
fn bench_progress_many_worst_late_duplicate() {
    let bench = late_setup(15);
    bench.quest.progress_many(PLAYER, fifteen_then(15), Mode::Storage);
    assert!(bench.view.quest_record(PLAYER, 420).completions == 1);
}

// accept, and the views that evaluate prerequisites: quest D with an accept step, 3 tasks and 7
// prerequisites met and not cached. §5.1 accept: A + R + C + K + P = 11 reads, 1 write

fn prerequisites_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    bench
        .quest
        .define(D, one_off(), array![task(1, 5), task(2, 5), task(3, 5)].span(), conditions, true);
    bench
}

#[test]
#[available_gas(l2_gas: 27357963)]
fn baseline_prerequisites() {
    prerequisites_setup();
}

#[test]
#[available_gas(l2_gas: 28465408)]
fn bench_accept_worst() {
    let bench = prerequisites_setup();
    bench.quest.accept(PLAYER, D);
}

#[test]
#[available_gas(l2_gas: 27906955)]
fn bench_view_is_unlocked_worst() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_is_unlocked(PLAYER, D));
}

#[test]
#[available_gas(l2_gas: 27681447)]
fn bench_view_definition_worst() {
    let bench = prerequisites_setup();
    let (_, tasks, conditions) = bench.view.quest_definition(D);
    assert!(tasks.len() == 3 && conditions.len() == 7);
}

#[test]
#[available_gas(l2_gas: 27568960)]
fn bench_view_is_accepted() {
    let bench = prerequisites_setup();
    assert!(!bench.view.quest_is_accepted(PLAYER, D));
}

#[test]
#[available_gas(l2_gas: 27528703)]
fn bench_view_current_interval() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_current_interval(D) == Option::Some(0));
}

#[test]
#[available_gas(l2_gas: 27667986)]
fn bench_view_progress_and_record() {
    let bench = prerequisites_setup();
    assert!(!bench.view.quest_progress(PLAYER, D, 0).completed);
    assert!(bench.view.quest_record(PLAYER, D).completions == 0);
}

#[test]
#[available_gas(l2_gas: 27488887)]
fn bench_view_is_reporter() {
    let bench = prerequisites_setup();
    assert!(bench.view.quest_is_reporter(test_address()));
}

// progress on an accepted quest (unlocked cached by accept). §5.1: Pg + B + A + R + P = 5 reads,
// 1 write

fn accepted_setup() -> Bench {
    let bench = prerequisites_setup();
    bench.quest.accept(PLAYER, D);
    bench
}

#[test]
#[available_gas(l2_gas: 28465408)]
fn baseline_accepted() {
    accepted_setup();
}

#[test]
#[available_gas(l2_gas: 29427319)]
fn bench_progress_accepted() {
    let bench = accepted_setup();
    bench.quest.progress(PLAYER, 1, 1, Mode::Storage);
}

// abandon. §5.1: A + R = 2 reads, 1 write

#[test]
#[available_gas(l2_gas: 28747816)]
fn bench_abandon() {
    let bench = accepted_setup();
    bench.quest.abandon(PLAYER, D);
}

// progress on a plain quest, then claim. §5.1: not completing 4 reads, 1 write; completing
// 5 reads, 2 writes; claim P + R = 2 reads, 2 writes

fn plain_setup() -> Bench {
    let bench = deploy();
    bench.quest.define(D, one_off(), array![task(1, 2)].span(), no_conditions(), false);
    bench
}

#[test]
#[available_gas(l2_gas: 2658926)]
fn baseline_plain() {
    plain_setup();
}

#[test]
#[available_gas(l2_gas: 3557081)]
fn bench_progress_plain() {
    let bench = plain_setup();
    bench.quest.progress(PLAYER, 1, 1, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4132838)]
fn bench_progress_plain_completing() {
    let bench = plain_setup();
    bench.quest.progress(PLAYER, 1, 2, Mode::Storage);
}

fn completed_setup() -> Bench {
    let bench = plain_setup();
    bench.quest.progress(PLAYER, 1, 2, Mode::Storage);
    bench
}

#[test]
#[available_gas(l2_gas: 4132838)]
fn baseline_completed() {
    completed_setup();
}

#[test]
#[available_gas(l2_gas: 4520603)]
fn bench_claim() {
    let bench = completed_setup();
    assert!(bench.quest.claim(PLAYER, D, 0) == 0);
}

// retire: quest D with 3 tasks, each shared by 28 live quests (D first on page 0, the last id on
// page 3), and 7 conditions. §5.1: at most 22 reads, 14 writes

fn retire_worst_setup() -> Bench {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    bench
        .quest
        .define(D, one_off(), array![task(1, 1), task(2, 1), task(3, 1)].span(), conditions, false);
    let rest = MAX_QUESTS_PER_TASK - 1;
    filler(bench, 1, 1, rest);
    filler(bench, 2, 101, rest);
    filler(bench, 3, 201, rest);
    bench
}

#[test]
#[available_gas(l2_gas: 151539163)]
fn baseline_retire_worst() {
    retire_worst_setup();
}

#[test]
#[available_gas(l2_gas: 153792232)]
fn bench_retire_worst() {
    let bench = retire_worst_setup();
    bench.quest.retire(D);
}

// define: 3 tasks, each with 27 live quests (4 pages to read), and 7 conditions. §5.1: K
// conditions' A + each task's pages; writes A, B, C, one page per task, K conditions' A

fn define_worst_setup() -> (Bench, Span<u32>) {
    let bench = deploy();
    let conditions = completed_prerequisites(bench);
    let rest: u32 = (QUESTS_PER_PAGE * MAX_PAGES).into() - 1;
    filler(bench, 1, 1, rest);
    filler(bench, 2, 101, rest);
    filler(bench, 3, 201, rest);
    (bench, conditions)
}

#[test]
#[available_gas(l2_gas: 147962275)]
fn baseline_define_worst() {
    define_worst_setup();
}

#[test]
#[available_gas(l2_gas: 151541179)]
fn bench_define_worst() {
    let (bench, conditions) = define_worst_setup();
    bench
        .quest
        .define(D, one_off(), array![task(1, 1), task(2, 1), task(3, 1)].span(), conditions, false);
}
