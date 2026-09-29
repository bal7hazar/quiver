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
#[available_gas(l2_gas: 2004496)]
fn grid_h0() {
    let grid = deploy();
    seed(grid, 0, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2276747)]
fn baseline_grid_h1_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 4624498)]
fn grid_h1_complete() {
    let grid = deploy();
    seed(grid, 1, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2276747)]
fn baseline_grid_h1_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, COUNT);
}

#[test]
#[available_gas(l2_gas: 4052920)]
fn grid_h1_count() {
    let grid = deploy();
    seed(grid, 1, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2276747)]
fn baseline_grid_h1_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, MISS);
}

#[test]
#[available_gas(l2_gas: 3576997)]
fn grid_h1_miss() {
    let grid = deploy();
    seed(grid, 1, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2719920)]
fn baseline_grid_h1_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, DONE);
}

#[test]
#[available_gas(l2_gas: 3874976)]
fn grid_h1_done() {
    let grid = deploy();
    seed(grid, 1, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2276747)]
fn baseline_grid_h1_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 1, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 3385928)]
fn grid_h1_expired() {
    let grid = deploy();
    seed(grid, 1, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160017)]
fn baseline_grid_h2_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 6907996)]
fn grid_h2_complete() {
    let grid = deploy();
    seed(grid, 2, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160017)]
fn baseline_grid_h2_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, COUNT);
}

#[test]
#[available_gas(l2_gas: 5711531)]
fn grid_h2_count() {
    let grid = deploy();
    seed(grid, 2, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160017)]
fn baseline_grid_h2_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, MISS);
}

#[test]
#[available_gas(l2_gas: 4759685)]
fn grid_h2_miss() {
    let grid = deploy();
    seed(grid, 2, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4046259)]
fn baseline_grid_h2_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, DONE);
}

#[test]
#[available_gas(l2_gas: 5355539)]
fn grid_h2_done() {
    let grid = deploy();
    seed(grid, 2, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3160017)]
fn baseline_grid_h2_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 2, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 4377548)]
fn grid_h2_expired() {
    let grid = deploy();
    seed(grid, 2, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5374436)]
fn baseline_grid_h4_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 11872543)]
fn grid_h4_complete() {
    let grid = deploy();
    seed(grid, 4, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5374436)]
fn baseline_grid_h4_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, COUNT);
}

#[test]
#[available_gas(l2_gas: 9426200)]
fn grid_h4_count() {
    let grid = deploy();
    seed(grid, 4, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5374436)]
fn baseline_grid_h4_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, MISS);
}

#[test]
#[available_gas(l2_gas: 7522508)]
fn grid_h4_miss() {
    let grid = deploy();
    seed(grid, 4, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 7146815)]
fn baseline_grid_h4_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, DONE);
}

#[test]
#[available_gas(l2_gas: 8714111)]
fn grid_h4_done() {
    let grid = deploy();
    seed(grid, 4, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5374436)]
fn baseline_grid_h4_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 4, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 6758234)]
fn grid_h4_expired() {
    let grid = deploy();
    seed(grid, 4, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9803273)]
fn baseline_grid_h8_complete() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, COMPLETE);
}

#[test]
#[available_gas(l2_gas: 21751489)]
fn grid_h8_complete() {
    let grid = deploy();
    seed(grid, 8, COMPLETE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9803273)]
fn baseline_grid_h8_count() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, COUNT);
}

#[test]
#[available_gas(l2_gas: 16805390)]
fn grid_h8_count() {
    let grid = deploy();
    seed(grid, 8, COUNT);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9803273)]
fn baseline_grid_h8_miss() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, MISS);
}

#[test]
#[available_gas(l2_gas: 12998006)]
fn grid_h8_miss() {
    let grid = deploy();
    seed(grid, 8, MISS);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 13347926)]
fn baseline_grid_h8_done() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, DONE);
}

#[test]
#[available_gas(l2_gas: 15381107)]
fn grid_h8_done() {
    let grid = deploy();
    seed(grid, 8, DONE);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9803273)]
fn baseline_grid_h8_expired() {
    let grid = deploy();
    let _entries = worst_entries();
    seed(grid, 8, EXPIRED);
}

#[test]
#[available_gas(l2_gas: 11469458)]
fn grid_h8_expired() {
    let grid = deploy();
    seed(grid, 8, EXPIRED);
    grid.quest.progress_many(PLAYER, worst_entries(), Mode::Storage);
}
