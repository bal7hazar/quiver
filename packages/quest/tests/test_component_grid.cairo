//! The cost grid of `progress_many` over the held list (ARC-03c), generated: H held quests in
//! one state each (`grid.cairo`), the worst entries `[1..=15, 129]`, hooks empty. Each point
//! `grid_h{H}_{state}` has its baseline `baseline_grid_h{H}_{state}`, the same fixture without the
//! call; the call's cost is their difference. `grid_h0` is an empty list.

use quiver_quest::interface::IQuestDispatcherTrait;
use quiver_quest::logic::Mode;
use super::grid::{COMPLETE, COUNT, DONE, EXPIRED, MISS, deploy, seed, worst_entries};
use super::setup::PLAYER;

#[test]
#[available_gas(l2_gas: 951164)]
fn baseline_grid_h0() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 0, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 1999708)]
fn grid_h0() {
    let grid = deploy();
    seed(grid, 0, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2277072)]
fn baseline_grid_h1_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 4619930)]
fn grid_h1_complete() {
    let grid = deploy();
    seed(grid, 1, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2277072)]
fn baseline_grid_h1_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, COUNT);
}

#[test]
#[available_gas(l2_gas: 4048352)]
fn grid_h1_count() {
    let grid = deploy();
    seed(grid, 1, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2277072)]
fn baseline_grid_h1_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, MISS);
}

#[test]
#[available_gas(l2_gas: 3572429)]
fn grid_h1_miss() {
    let grid = deploy();
    seed(grid, 1, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2720246)]
fn baseline_grid_h1_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, DONE);
}

#[test]
#[available_gas(l2_gas: 3870409)]
fn grid_h1_done() {
    let grid = deploy();
    seed(grid, 1, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2277072)]
fn baseline_grid_h1_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 3381361)]
fn grid_h1_expired() {
    let grid = deploy();
    seed(grid, 1, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160343)]
fn baseline_grid_h2_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 6903544)]
fn grid_h2_complete() {
    let grid = deploy();
    seed(grid, 2, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160343)]
fn baseline_grid_h2_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, COUNT);
}

#[test]
#[available_gas(l2_gas: 5707321)]
fn grid_h2_count() {
    let grid = deploy();
    seed(grid, 2, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160343)]
fn baseline_grid_h2_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, MISS);
}

#[test]
#[available_gas(l2_gas: 4755475)]
fn grid_h2_miss() {
    let grid = deploy();
    seed(grid, 2, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4046585)]
fn baseline_grid_h2_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, DONE);
}

#[test]
#[available_gas(l2_gas: 5351329)]
fn grid_h2_done() {
    let grid = deploy();
    seed(grid, 2, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160343)]
fn baseline_grid_h2_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 4373338)]
fn grid_h2_expired() {
    let grid = deploy();
    seed(grid, 2, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5375076)]
fn baseline_grid_h4_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 11868070)]
fn grid_h4_complete() {
    let grid = deploy();
    seed(grid, 4, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5375076)]
fn baseline_grid_h4_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, COUNT);
}

#[test]
#[available_gas(l2_gas: 9422452)]
fn grid_h4_count() {
    let grid = deploy();
    seed(grid, 4, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5375076)]
fn baseline_grid_h4_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, MISS);
}

#[test]
#[available_gas(l2_gas: 7518760)]
fn grid_h4_miss() {
    let grid = deploy();
    seed(grid, 4, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 7147455)]
fn baseline_grid_h4_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, DONE);
}

#[test]
#[available_gas(l2_gas: 8710363)]
fn grid_h4_done() {
    let grid = deploy();
    seed(grid, 4, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5375076)]
fn baseline_grid_h4_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 6754486)]
fn grid_h4_expired() {
    let grid = deploy();
    seed(grid, 4, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9804543)]
fn baseline_grid_h8_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 21750050)]
fn grid_h8_complete() {
    let grid = deploy();
    seed(grid, 8, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9804543)]
fn baseline_grid_h8_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, COUNT);
}

#[test]
#[available_gas(l2_gas: 16805642)]
fn grid_h8_count() {
    let grid = deploy();
    seed(grid, 8, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9804543)]
fn baseline_grid_h8_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, MISS);
}

#[test]
#[available_gas(l2_gas: 12998258)]
fn grid_h8_miss() {
    let grid = deploy();
    seed(grid, 8, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 13349196)]
fn baseline_grid_h8_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, DONE);
}

#[test]
#[available_gas(l2_gas: 15381359)]
fn grid_h8_done() {
    let grid = deploy();
    seed(grid, 8, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9804543)]
fn baseline_grid_h8_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 11469710)]
fn grid_h8_expired() {
    let grid = deploy();
    seed(grid, 8, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}
