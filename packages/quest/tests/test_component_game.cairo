//! Grim World's own use of `progress_many`, a named benchmark (A-G1 amendment point 4; A-10,
//! A-12; D-135).
//!
//! One call per adventurer per transaction, 16 task entries (A-10). The adventurer holds 3 active
//! quests and one daily contract (design/06, design/14; A-12), all accepted and all completing
//! in this call:
//! - quest 1: tasks 1 and 2, no prerequisite;
//! - quest 2: task 3, one prerequisite;
//! - quest 3: tasks 4 and 5, two prerequisites;
//! - contract 4: task 6, daily, no prerequisite.
//! Every one of the 16 tasks is shared by `per_task` quests in all: the others are board quests
//! and contracts this adventurer has not accepted, which the call does not read. Prerequisites
//! were completed earlier; `accept` checked them and cached the unlock. Hooks are empty
//! (`MockBench`).

use quiver_quest::interface::{IQuestDispatcherTrait, IQuestViewDispatcherTrait};
use quiver_quest::logic::{Mode, QuestSchedule, QuestTask, TaskProgress};
use super::grid::{Grid, deploy};
use super::helpers::{distinct_entries, one_off, task};
use super::setup::PLAYER;

const P1: u32 = 901;
const P2: u32 = 902;

fn daily() -> QuestSchedule {
    QuestSchedule { start: 0, end: 0, duration: 86400, interval: 86400 }
}

fn define(
    grid: Grid, id: u32, schedule: QuestSchedule, tasks: Span<QuestTask>, conditions: Span<u32>,
) {
    grid.quest.define(id, schedule, tasks, conditions);
}

/// The adventurer's state before the call, with `per_task` quests on each of the 16 tasks.
fn game(per_task: u32) -> Grid {
    let grid = deploy();
    // Prerequisites, completed earlier
    define(grid, P1, one_off(), array![task(101, 1)].span(), array![].span());
    define(grid, P2, one_off(), array![task(102, 1)].span(), array![].span());
    grid.quest.accept(PLAYER, P1);
    grid.quest.accept(PLAYER, P2);
    grid
        .quest
        .progress_many(
            PLAYER,
            array![TaskProgress { task_id: 101, count: 1 }, TaskProgress { task_id: 102, count: 1 }]
                .span(),
            Mode::Storage,
        );
    // The 4 held quests; the first accept prunes P1 and P2
    define(grid, 1, one_off(), array![task(1, 1), task(2, 1)].span(), array![].span());
    define(grid, 2, one_off(), array![task(3, 1)].span(), array![P1].span());
    define(grid, 3, one_off(), array![task(4, 1), task(5, 1)].span(), array![P1, P2].span());
    define(grid, 4, daily(), array![task(6, 1)].span(), array![].span());
    let mut id: u32 = 1;
    while id <= 4 {
        grid.quest.accept(PLAYER, id);
        id += 1;
    }
    // The other quests on the 16 tasks, not accepted
    let mut other: u32 = 1000;
    let mut task_id: u32 = 1;
    while task_id <= 16 {
        let held = if task_id <= 6 {
            1
        } else {
            0
        };
        let mut n = held;
        while n < per_task {
            let conditions = if other % 3 == 0 {
                array![P1].span()
            } else {
                array![].span()
            };
            define(grid, other, one_off(), array![task(task_id, 1)].span(), conditions);
            other += 1;
            n += 1;
        }
        task_id += 1;
    }
    grid
}

/// Completions of the 4 held quests and of one quest not accepted: the same 5 view calls in a
/// benchmark and its baseline, so that the difference is the call alone.
fn completions(grid: Grid) -> Array<u64> {
    let view = quiver_quest::interface::IQuestViewDispatcher { contract_address: grid.address };
    array![
        view.quest_record(PLAYER, 1).completions, view.quest_record(PLAYER, 2).completions,
        view.quest_record(PLAYER, 3).completions, view.quest_record(PLAYER, 4).completions,
        view.quest_record(PLAYER, 1000).completions,
    ]
}

#[test]
#[available_gas(l2_gas: 81039759)]
fn baseline_game_case_three_per_task() {
    let grid = game(3);
    let _entries = distinct_entries(1, 16, 1);
    assert!(completions(grid) == array![0, 0, 0, 0, 0]);
}

#[test]
#[available_gas(l2_gas: 85788831)]
fn game_case_three_per_task() {
    let grid = game(3);
    grid.quest.progress_many(PLAYER, distinct_entries(1, 16, 1), Mode::Storage);
    assert!(completions(grid) == array![1, 1, 1, 1, 0]);
}

#[test]
#[available_gas(l2_gas: 57080439)]
fn baseline_game_case_two_per_task() {
    let grid = game(2);
    let _entries = distinct_entries(1, 16, 1);
    assert!(completions(grid) == array![0, 0, 0, 0, 0]);
}

#[test]
#[available_gas(l2_gas: 61829511)]
fn game_case_two_per_task() {
    let grid = game(2);
    grid.quest.progress_many(PLAYER, distinct_entries(1, 16, 1), Mode::Storage);
    assert!(completions(grid) == array![1, 1, 1, 1, 0]);
}
