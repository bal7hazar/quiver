//! Cap options under the 20M L2 gas decision (fix loop 2, point 3), measured: each (E, N, K)
//! is E task entries per call, N live quests per task, K prerequisites first observed per
//! quest, every quest completing, hooks empty, and the worst entries for E (a late collision
//! modulo 128, so `batch_merge` runs its plain merge). `option_e16_n1_k0` is the smallest
//! configuration that keeps 16 entries: it measures above 20M.

use quiver_quest::interface::IQuestDispatcherTrait;
use quiver_quest::logic::Mode;
use super::grid::{deploy, entries_of, late_collision_tasks, seed_tasks};
use super::setup::PLAYER;

#[test]
#[available_gas(l2_gas: 22562306)]
fn baseline_option_e16_n1_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(16);
    seed_tasks(grid, tasks, 1, 0);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 44238940)]
fn option_e16_n1_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(16);
    seed_tasks(grid, tasks, 1, 0);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 21204309)]
fn baseline_option_e15_n1_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(15);
    seed_tasks(grid, tasks, 1, 0);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 41507337)]
fn option_e15_n1_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(15);
    seed_tasks(grid, tasks, 1, 0);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 60137291)]
fn baseline_option_e12_n1_k7() {
    let grid = deploy();
    let tasks = late_collision_tasks(12);
    seed_tasks(grid, tasks, 1, 7);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 80656547)]
fn option_e12_n1_k7() {
    let grid = deploy();
    let tasks = late_collision_tasks(12);
    seed_tasks(grid, tasks, 1, 7);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 18819182)]
fn baseline_option_e8_n2_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(8);
    seed_tasks(grid, tasks, 2, 0);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 39461389)]
fn option_e8_n2_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(8);
    seed_tasks(grid, tasks, 2, 0);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 41655506)]
fn baseline_option_e7_n2_k3() {
    let grid = deploy();
    let tasks = late_collision_tasks(7);
    seed_tasks(grid, tasks, 2, 3);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 62311325)]
fn option_e7_n2_k3() {
    let grid = deploy();
    let tasks = late_collision_tasks(7);
    seed_tasks(grid, tasks, 2, 3);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 29963808)]
fn baseline_option_e5_n3_k1() {
    let grid = deploy();
    let tasks = late_collision_tasks(5);
    seed_tasks(grid, tasks, 3, 1);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 50509638)]
fn option_e5_n3_k1() {
    let grid = deploy();
    let tasks = late_collision_tasks(5);
    seed_tasks(grid, tasks, 3, 1);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 16947914)]
fn baseline_option_e4_n4_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(4);
    seed_tasks(grid, tasks, 4, 0);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 37170558)]
fn option_e4_n4_k0() {
    let grid = deploy();
    let tasks = late_collision_tasks(4);
    seed_tasks(grid, tasks, 4, 0);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 56394041)]
fn baseline_option_e4_n3_k7() {
    let grid = deploy();
    let tasks = late_collision_tasks(4);
    seed_tasks(grid, tasks, 3, 7);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 76006677)]
fn option_e4_n3_k7() {
    let grid = deploy();
    let tasks = late_collision_tasks(4);
    seed_tasks(grid, tasks, 3, 7);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 35744573)]
fn baseline_option_e3_n5_k2() {
    let grid = deploy();
    let tasks = late_collision_tasks(3);
    seed_tasks(grid, tasks, 5, 2);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 56756244)]
fn option_e3_n5_k2() {
    let grid = deploy();
    let tasks = late_collision_tasks(3);
    seed_tasks(grid, tasks, 5, 2);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 45586643)]
fn baseline_option_e2_n7_k4() {
    let grid = deploy();
    let tasks = late_collision_tasks(2);
    seed_tasks(grid, tasks, 7, 4);
    let _entries = entries_of(tasks);
}

#[test]
#[available_gas(l2_gas: 66482534)]
fn option_e2_n7_k4() {
    let grid = deploy();
    let tasks = late_collision_tasks(2);
    seed_tasks(grid, tasks, 7, 4);
    let entries = entries_of(tasks);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}
