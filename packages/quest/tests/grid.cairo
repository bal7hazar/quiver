//! Fixtures of the cost grid of `progress_many` (fix loop 2, point 1), seeded straight into the
//! component's storage with snforge's `store`: the grid reaches past the caps, which `define`
//! refuses, so that the cost model is fitted on a wide range.
//!
//! Grid point (E, N, K): tasks 1..=E, each with N live one-off quests of one task (target 1, no
//! accept step), each with K prerequisites of its own (no sharing) that `PLAYER` completed and
//! that no call has observed yet. One `progress_many(PLAYER, [(1, 1) .. (E, 1)], Storage)`
//! completes all E × N quests: the worst case of each point.

use quiver_quest::interface::{IQuestDispatcher, IQuestDispatcherTrait};
use quiver_quest::logic::{
    QuestConditions, QuestDefinition, QuestIdPage, QuestRecord, QuestSchedule, QuestTask,
    QuestTasks,
};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, map_entry_address, store, test_address,
};
use starknet::ContractAddress;
use starknet::storage_access::StorePacking;
use super::setup::PLAYER;

/// Prerequisite ids start above every quest id of the grid.
const PREREQUISITE_BASE: u32 = 1000000;

#[derive(Drop, Copy)]
pub struct Grid {
    pub address: ContractAddress,
    pub quest: IQuestDispatcher,
}

/// `MockBench` (hooks empty), with the test contract as its reporter.
pub fn deploy() -> Grid {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let grid = Grid { address, quest: IQuestDispatcher { contract_address: address } };
    grid.quest.set_reporter(test_address(), true);
    grid
}

fn put(address: ContractAddress, member: felt252, keys: Span<felt252>, value: felt252) {
    store(address, map_entry_address(member, keys), array![value].span());
}

fn id_at(ids: Span<u32>, index: u32) -> u32 {
    match ids.get(index) {
        Option::Some(id) => *id.unbox(),
        Option::None => 0,
    }
}

fn ids_of(ids: Span<u32>) -> QuestConditions {
    QuestConditions {
        q0: id_at(ids, 0),
        q1: id_at(ids, 1),
        q2: id_at(ids, 2),
        q3: id_at(ids, 3),
        q4: id_at(ids, 4),
        q5: id_at(ids, 5),
        q6: id_at(ids, 6),
    }
}

/// Quest `quest_id` on `task_id` (target 1), with prerequisites `conditions`, all completed by
/// `PLAYER`.
fn seed_quest(address: ContractAddress, quest_id: u32, task_id: u32, conditions: Span<u32>) {
    let definition = QuestDefinition {
        schedule: QuestSchedule { start: 0, end: 0, duration: 0, interval: 0 },
        task_count: 1,
        condition_count: conditions.len().try_into().unwrap(),
        needs_accept: false,
        defined: true,
        retired: false,
        live_dependents: 0,
    };
    let key = array![quest_id.into()].span();
    put(address, selector!("Quest_definitions"), key, StorePacking::pack(definition));
    let none = QuestTask { task_id: 0, total: 0 };
    let tasks = QuestTasks { t0: QuestTask { task_id, total: 1 }, t1: none, t2: none };
    put(address, selector!("Quest_tasks"), key, StorePacking::pack(tasks));
    if conditions.len() != 0 {
        put(address, selector!("Quest_conditions"), key, StorePacking::pack(ids_of(conditions)));
    }
    let done = QuestRecord {
        completions: 1, claims: 0, unlocked: false, active: false, accepted_interval: 0,
    };
    for condition in conditions {
        put(
            address,
            selector!("Quest_records"),
            array![PLAYER, (*condition).into()].span(),
            StorePacking::pack(done),
        );
    }
}

/// Grid point (e, n, k), seeded into `grid`: tasks 1..=e.
pub fn seed(grid: Grid, e: u32, n: u32, k: u32) {
    let mut tasks = array![];
    let mut task_id: u32 = 1;
    while task_id <= e {
        tasks.append(task_id);
        task_id += 1;
    }
    seed_tasks(grid, tasks.span(), n, k);
}

/// `n` quests with `k` prerequisites each on every task of `tasks`.
pub fn seed_tasks(grid: Grid, tasks: Span<u32>, n: u32, k: u32) {
    let mut index: u32 = 0;
    while index < tasks.len() {
        let task_id = *tasks[index];
        let mut ids: Array<u32> = array![];
        let mut i: u32 = 0;
        while i < n {
            let quest_id = index * n + i + 1;
            let mut conditions = array![];
            let mut j: u32 = 0;
            while j < k {
                conditions.append(PREREQUISITE_BASE + (quest_id - 1) * 7 + j + 1);
                j += 1;
            }
            seed_quest(grid.address, quest_id, task_id, conditions.span());
            ids.append(quest_id);
            i += 1;
        }
        // Pages of 7, contiguous
        let ids = ids.span();
        let mut page: u8 = 0;
        let mut start: u32 = 0;
        while start < ids.len() {
            let end = if start + 7 < ids.len() {
                start + 7
            } else {
                ids.len()
            };
            let chunk = ids.slice(start, end - start);
            let value = QuestIdPage { len: chunk.len().try_into().unwrap(), ids: ids_of(chunk) };
            put(
                grid.address,
                selector!("Quest_task_pages"),
                array![task_id.into(), page.into()].span(),
                StorePacking::pack(value),
            );
            page += 1;
            start = end;
        }
        index += 1;
    }
}

/// The worst entries for `e` tasks: tasks 1..e-1, then 129 (= 1 mod 128), so that
/// `batch_merge` meets a collision at the last entry and runs its plain merge in full.
pub fn late_collision_tasks(e: u32) -> Span<u32> {
    let mut tasks = array![];
    let mut task_id: u32 = 1;
    while task_id < e {
        tasks.append(task_id);
        task_id += 1;
    }
    tasks.append(129);
    tasks.span()
}

/// Count 1 on each of `tasks`.
pub fn entries_of(tasks: Span<u32>) -> Span<quiver_quest::logic::TaskProgress> {
    let mut entries = array![];
    for task_id in tasks {
        entries.append(quiver_quest::logic::TaskProgress { task_id: *task_id, count: 1 });
    }
    entries.span()
}
