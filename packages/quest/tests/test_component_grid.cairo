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
#[available_gas(l2_gas: 2005409)]
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
#[available_gas(l2_gas: 4625842)]
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
#[available_gas(l2_gas: 4054264)]
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
#[available_gas(l2_gas: 3578341)]
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
#[available_gas(l2_gas: 3876320)]
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
#[available_gas(l2_gas: 3387272)]
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
#[available_gas(l2_gas: 6915587)]
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
#[available_gas(l2_gas: 5713579)]
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
#[available_gas(l2_gas: 4761733)]
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
#[available_gas(l2_gas: 5357587)]
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
#[available_gas(l2_gas: 4379596)]
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
#[available_gas(l2_gas: 11983255)]
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
#[available_gas(l2_gas: 9429371)]
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
#[available_gas(l2_gas: 7525679)]
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
#[available_gas(l2_gas: 8717282)]
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
#[available_gas(l2_gas: 6761405)]
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
#[available_gas(l2_gas: 22067843)]
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
#[available_gas(l2_gas: 16810210)]
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
#[available_gas(l2_gas: 13002826)]
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
#[available_gas(l2_gas: 15385927)]
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
#[available_gas(l2_gas: 11474278)]
fn grid_h8_expired() {
    let grid = deploy();
    seed(grid, 8, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}
