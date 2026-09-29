//! Fixtures of the cost grid of `progress_many` over the held list (ARC-03c), seeded straight into
//! the component's storage with snforge's `store`, so that a list of up to `MAX_HELD_LIMIT` = 8
//! entries is reached although `accept` stops at `MAX_HELD`.
//!
//! Grid point (H, state): quests 1..=H, daily, held by `PLAYER` in interval `NOW_DAY`; the call is
//! `progress_many(PLAYER, [1..=15, 129], Storage)`, the worst entries for the merge. Each quest is,
//! by `state`:
//! - `COMPLETE`: tasks 129, 15, 14 (the last three entries), totals 1: completes;
//! - `COUNT`: the same tasks, totals 2: counts 1 on each, does not complete;
//! - `MISS`: tasks 201, 202, 203, not in the batch: read, nothing written;
//! - `DONE`: completed earlier in this interval (a dead entry, pruned at the next accept);
//! - `EXPIRED`: accepted in interval `NOW_DAY - 1` (a dead entry).

use quiver_quest::interface::{IQuestDispatcher, IQuestDispatcherTrait};
use quiver_quest::models::definition::{HeadSlot, TasksSlot};
use quiver_quest::models::held::HeldSlot;
use quiver_quest::models::progress::ProgressSlot;
use quiver_quest::types::batch::TaskProgress;
use quiver_quest::types::held::QuestHeld;
use quiver_quest::types::schedule::QuestSchedule;
use quiver_quest::types::task::QuestTask;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, map_entry_address, start_cheat_block_timestamp,
    store, test_address,
};
use starknet::ContractAddress;
use starknet::storage_access::StorePacking;
use super::setup::PLAYER;

/// Day 20 000 (2024-10-04), one hour in.
pub const NOW_DAY: u64 = 20000;
pub const NOW: u64 = 20000 * 86400 + 3600;

pub const COMPLETE: u8 = 0;
pub const COUNT: u8 = 1;
pub const MISS: u8 = 2;
pub const DONE: u8 = 3;
pub const EXPIRED: u8 = 4;

#[derive(Drop, Copy)]
pub struct Grid {
    pub address: ContractAddress,
    pub quest: IQuestDispatcher,
}

/// `MockBench` (hooks empty), with the test contract as its reporter, at `NOW`.
pub fn deploy() -> Grid {
    let class = declare("MockBench").unwrap().contract_class();
    let (address, _) = class.deploy(@array![]).unwrap();
    let grid = Grid { address, quest: IQuestDispatcher { contract_address: address } };
    start_cheat_block_timestamp(address, NOW);
    grid.quest.set_reporter(test_address(), true);
    grid
}

fn put(address: ContractAddress, member: felt252, keys: Span<felt252>, value: felt252) {
    store(address, map_entry_address(member, keys), array![value].span());
}

fn daily() -> QuestSchedule {
    QuestSchedule { start: 0, end: 0, duration: 86400, interval: 86400 }
}

/// Quest `quest_id` in `state`, and its held entry.
fn seed_quest(address: ContractAddress, quest_id: u32, state: u8) -> QuestHeld {
    let definition = HeadSlot {
        schedule: daily(),
        task_count: 3,
        condition_count: 0,
        defined: true,
        retired: false,
        live_dependents: 0,
    };
    let key = array![quest_id.into()].span();
    put(address, selector!("Quest_definitions"), key, StorePacking::pack(definition));
    let (ids, total) = if state == MISS {
        ((201, 202, 203), 1)
    } else if state == COUNT {
        ((129, 15, 14), 2)
    } else {
        ((129, 15, 14), 1)
    };
    let (a, b, c) = ids;
    let tasks = TasksSlot {
        t0: QuestTask { task_id: a, total },
        t1: QuestTask { task_id: b, total },
        t2: QuestTask { task_id: c, total },
    };
    put(address, selector!("Quest_tasks"), key, StorePacking::pack(tasks));
    if state == DONE {
        let done = ProgressSlot { c0: 1, c1: 1, c2: 1, completed: true, claimed: false };
        put(
            address,
            selector!("Quest_progress"),
            array![PLAYER, quest_id.into(), NOW_DAY.into()].span(),
            StorePacking::pack(done),
        );
    }
    let interval_id = if state == EXPIRED {
        NOW_DAY - 1
    } else {
        NOW_DAY
    };
    // accepted as the player's `quest_id`-th acceptance
    QuestHeld { quest_id, interval_id, acceptance: quest_id.try_into().unwrap() }
}

/// Grid point (h, state), seeded into `grid`: quests 1..=h and the held list.
pub fn seed(grid: Grid, h: u32, state: u8) {
    let mut entries: Array<QuestHeld> = array![];
    let mut id: u32 = 1;
    while id <= h {
        entries.append(seed_quest(grid.address, id, state));
        id += 1;
    }
    let entries = entries.span();
    let none = QuestHeld { quest_id: 0, interval_id: 0, acceptance: 0 };
    let mut slot: u32 = 0;
    while 2 * slot < h {
        let e0 = *entries[2 * slot];
        // the counter, in slot 0: the number of the last acceptance
        let counter: u32 = if slot == 0 {
            h.try_into().unwrap()
        } else {
            0
        };
        let e1 = if 2 * slot + 1 < h {
            *entries[2 * slot + 1]
        } else {
            none
        };
        put(
            grid.address,
            selector!("Quest_held"),
            array![PLAYER, slot.into()].span(),
            StorePacking::pack(HeldSlot { e0, e1, counter, kept: true }),
        );
        slot += 1;
    }
}

/// `[1..=15, 129]`, count 1 each: 129 = 1 mod 128, so `batch_merge` runs its plain merge in full.
pub fn worst_entries() -> Span<TaskProgress> {
    let mut entries = array![];
    let mut task_id: u32 = 1;
    while task_id < 16 {
        entries.append(TaskProgress { task_id, count: 1 });
        task_id += 1;
    }
    entries.append(TaskProgress { task_id: 129, count: 1 });
    entries.span()
}
