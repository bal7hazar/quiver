//! The cost grid of `progress_many` (fix loop 2, point 1): storage mode at every point
//! (E, N, K) of E in {1, 4, 16} tasks per call, N in {1, 2, 4, 7} live quests per task, K in
//! {0, 1, 3, 7} prerequisites first observed per quest, and the corners of the old bounds
//! (N = 28); event mode for E in {1, 4, 16}. Every quest completes; hooks are empty
//! (`MockBench`). Fixtures are seeded in storage (`grid.cairo`), past the caps where needed.
//!
//! Each `grid_*` test has a `baseline_grid_*` that builds the same fixture and entries
//! without the call: the call's cost is the difference. The fitted model is in `GAS.md`.

use quiver_quest::interface::IQuestDispatcherTrait;
use quiver_quest::logic::Mode;
use super::grid::{deploy, seed};
use super::helpers::distinct_entries;
use super::setup::PLAYER;

#[test]
#[available_gas(l2_gas: 2193870)]
fn baseline_grid_e1_n1_k0() {
    let grid = deploy();
    seed(grid, 1, 1, 0);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 3676477)]
fn grid_e1_n1_k0() {
    let grid = deploy();
    seed(grid, 1, 1, 0);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3088229)]
fn baseline_grid_e1_n1_k1() {
    let grid = deploy();
    seed(grid, 1, 1, 1);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 4667866)]
fn grid_e1_n1_k1() {
    let grid = deploy();
    seed(grid, 1, 1, 1);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3981705)]
fn baseline_grid_e1_n1_k3() {
    let grid = deploy();
    seed(grid, 1, 1, 3);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 5649017)]
fn grid_e1_n1_k3() {
    let grid = deploy();
    seed(grid, 1, 1, 3);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 5769141)]
fn baseline_grid_e1_n1_k7() {
    let grid = deploy();
    seed(grid, 1, 1, 7);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 7611184)]
fn grid_e1_n1_k7() {
    let grid = deploy();
    seed(grid, 1, 1, 7);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 3083021)]
fn baseline_grid_e1_n2_k0() {
    let grid = deploy();
    seed(grid, 1, 2, 0);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 5796038)]
fn grid_e1_n2_k0() {
    let grid = deploy();
    seed(grid, 1, 2, 0);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4873355)]
fn baseline_grid_e1_n2_k1() {
    let grid = deploy();
    seed(grid, 1, 2, 1);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 7780433)]
fn grid_e1_n2_k1() {
    let grid = deploy();
    seed(grid, 1, 2, 1);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 6662912)]
fn baseline_grid_e1_n2_k3() {
    let grid = deploy();
    seed(grid, 1, 2, 3);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 9745340)]
fn grid_e1_n2_k3() {
    let grid = deploy();
    seed(grid, 1, 2, 3);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 10242992)]
fn baseline_grid_e1_n2_k7() {
    let grid = deploy();
    seed(grid, 1, 2, 7);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 13674881)]
fn grid_e1_n2_k7() {
    let grid = deploy();
    seed(grid, 1, 2, 7);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 4861805)]
fn baseline_grid_e1_n4_k0() {
    let grid = deploy();
    seed(grid, 1, 4, 0);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 10036243)]
fn grid_e1_n4_k0() {
    let grid = deploy();
    seed(grid, 1, 4, 0);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 8444090)]
fn baseline_grid_e1_n4_k1() {
    let grid = deploy();
    seed(grid, 1, 4, 1);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 14006650)]
fn grid_e1_n4_k1() {
    let grid = deploy();
    seed(grid, 1, 4, 1);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 12025808)]
fn baseline_grid_e1_n4_k3() {
    let grid = deploy();
    seed(grid, 1, 4, 3);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 17939068)]
fn grid_e1_n4_k3() {
    let grid = deploy();
    seed(grid, 1, 4, 3);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 19191176)]
fn baseline_grid_e1_n4_k7() {
    let grid = deploy();
    seed(grid, 1, 4, 7);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 25803358)]
fn grid_e1_n4_k7() {
    let grid = deploy();
    seed(grid, 1, 4, 7);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 7529981)]
fn baseline_grid_e1_n7_k0() {
    let grid = deploy();
    seed(grid, 1, 7, 0);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 16457434)]
fn grid_e1_n7_k0() {
    let grid = deploy();
    seed(grid, 1, 7, 0);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 13800192)]
fn baseline_grid_e1_n7_k1() {
    let grid = deploy();
    seed(grid, 1, 7, 1);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 23406859)]
fn grid_e1_n7_k1() {
    let grid = deploy();
    seed(grid, 1, 7, 1);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 20070152)]
fn baseline_grid_e1_n7_k3() {
    let grid = deploy();
    seed(grid, 1, 7, 3);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 30290543)]
fn grid_e1_n7_k3() {
    let grid = deploy();
    seed(grid, 1, 7, 3);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 32613452)]
fn baseline_grid_e1_n7_k7() {
    let grid = deploy();
    seed(grid, 1, 7, 7);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 44056957)]
fn grid_e1_n7_k7() {
    let grid = deploy();
    seed(grid, 1, 7, 7);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 6270579)]
fn baseline_grid_e4_n1_k0() {
    let grid = deploy();
    seed(grid, 4, 1, 0);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 11669852)]
fn grid_e4_n1_k0() {
    let grid = deploy();
    seed(grid, 4, 1, 0);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9852864)]
fn baseline_grid_e4_n1_k1() {
    let grid = deploy();
    seed(grid, 4, 1, 1);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 15640259)]
fn grid_e4_n1_k1() {
    let grid = deploy();
    seed(grid, 4, 1, 1);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 13434582)]
fn baseline_grid_e4_n1_k3() {
    let grid = deploy();
    seed(grid, 4, 1, 3);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 19572677)]
fn grid_e4_n1_k3() {
    let grid = deploy();
    seed(grid, 4, 1, 3);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 20599950)]
fn baseline_grid_e4_n1_k7() {
    let grid = deploy();
    seed(grid, 4, 1, 7);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 27436967)]
fn grid_e4_n1_k7() {
    let grid = deploy();
    seed(grid, 4, 1, 7);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 9830457)]
fn baseline_grid_e4_n2_k0() {
    let grid = deploy();
    seed(grid, 4, 2, 0);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 20151374)]
fn grid_e4_n2_k0() {
    let grid = deploy();
    seed(grid, 4, 2, 0);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 16996644)]
fn baseline_grid_e4_n2_k1() {
    let grid = deploy();
    seed(grid, 4, 2, 1);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 28093805)]
fn grid_e4_n2_k1() {
    let grid = deploy();
    seed(grid, 4, 2, 1);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 24162684)]
fn baseline_grid_e4_n2_k3() {
    let grid = deploy();
    seed(grid, 4, 2, 3);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 35961245)]
fn grid_e4_n2_k3() {
    let grid = deploy();
    seed(grid, 4, 2, 3);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 38498628)]
fn baseline_grid_e4_n2_k7() {
    let grid = deploy();
    seed(grid, 4, 2, 7);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 51695033)]
fn grid_e4_n2_k7() {
    let grid = deploy();
    seed(grid, 4, 2, 7);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 16952145)]
fn baseline_grid_e4_n4_k0() {
    let grid = deploy();
    seed(grid, 4, 4, 0);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 37118744)]
fn grid_e4_n4_k0() {
    let grid = deploy();
    seed(grid, 4, 4, 0);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 31286136)]
fn baseline_grid_e4_n4_k1() {
    let grid = deploy();
    seed(grid, 4, 4, 1);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 53005223)]
fn grid_e4_n4_k1() {
    let grid = deploy();
    seed(grid, 4, 4, 1);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 45620820)]
fn baseline_grid_e4_n4_k3() {
    let grid = deploy();
    seed(grid, 4, 4, 3);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 68742707)]
fn grid_e4_n4_k3() {
    let grid = deploy();
    seed(grid, 4, 4, 3);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 74297916)]
fn baseline_grid_e4_n4_k7() {
    let grid = deploy();
    seed(grid, 4, 4, 7);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 100215491)]
fn grid_e4_n4_k7() {
    let grid = deploy();
    seed(grid, 4, 4, 7);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 27634677)]
fn baseline_grid_e4_n7_k0() {
    let grid = deploy();
    seed(grid, 4, 7, 0);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 62813336)]
fn grid_e4_n7_k0() {
    let grid = deploy();
    seed(grid, 4, 7, 0);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 52720374)]
fn baseline_grid_e4_n7_k1() {
    let grid = deploy();
    seed(grid, 4, 7, 1);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 90615887)]
fn grid_e4_n7_k1() {
    let grid = deploy();
    seed(grid, 4, 7, 1);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 77808024)]
fn baseline_grid_e4_n7_k3() {
    let grid = deploy();
    seed(grid, 4, 7, 3);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 118158437)]
fn grid_e4_n7_k3() {
    let grid = deploy();
    seed(grid, 4, 7, 3);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 127996848)]
fn baseline_grid_e4_n7_k7() {
    let grid = deploy();
    seed(grid, 4, 7, 7);
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 173239715)]
fn grid_e4_n7_k7() {
    let grid = deploy();
    seed(grid, 4, 7, 7);
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 22578381)]
fn baseline_grid_e16_n1_k0() {
    let grid = deploy();
    seed(grid, 16, 1, 0);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 43644317)]
fn grid_e16_n1_k0() {
    let grid = deploy();
    seed(grid, 16, 1, 0);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 36912372)]
fn baseline_grid_e16_n1_k1() {
    let grid = deploy();
    seed(grid, 16, 1, 1);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 59530796)]
fn grid_e16_n1_k1() {
    let grid = deploy();
    seed(grid, 16, 1, 1);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 51247056)]
fn baseline_grid_e16_n1_k3() {
    let grid = deploy();
    seed(grid, 16, 1, 3);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 75268280)]
fn grid_e16_n1_k3() {
    let grid = deploy();
    seed(grid, 16, 1, 3);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 79924152)]
fn baseline_grid_e16_n1_k7() {
    let grid = deploy();
    seed(grid, 16, 1, 7);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 106741064)]
fn grid_e16_n1_k7() {
    let grid = deploy();
    seed(grid, 16, 1, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 36821169)]
fn baseline_grid_e16_n2_k0() {
    let grid = deploy();
    seed(grid, 16, 2, 0);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 77573681)]
fn grid_e16_n2_k0() {
    let grid = deploy();
    seed(grid, 16, 2, 0);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 65490768)]
fn baseline_grid_e16_n2_k1() {
    let grid = deploy();
    seed(grid, 16, 2, 1);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 109348256)]
fn grid_e16_n2_k1() {
    let grid = deploy();
    seed(grid, 16, 2, 1);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 94162740)]
fn baseline_grid_e16_n2_k3() {
    let grid = deploy();
    seed(grid, 16, 2, 3);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 140825828)]
fn grid_e16_n2_k3() {
    let grid = deploy();
    seed(grid, 16, 2, 3);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 151522140)]
fn baseline_grid_e16_n2_k7() {
    let grid = deploy();
    seed(grid, 16, 2, 7);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 203776604)]
fn grid_e16_n2_k7() {
    let grid = deploy();
    seed(grid, 16, 2, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 65314473)]
fn baseline_grid_e16_n4_k0() {
    let grid = deploy();
    seed(grid, 16, 4, 0);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 145449713)]
fn grid_e16_n4_k0() {
    let grid = deploy();
    seed(grid, 16, 4, 0);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 122655288)]
fn baseline_grid_e16_n4_k1() {
    let grid = deploy();
    seed(grid, 16, 4, 1);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 209000480)]
fn grid_e16_n4_k1() {
    let grid = deploy();
    seed(grid, 16, 4, 1);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 180001836)]
fn baseline_grid_e16_n4_k3() {
    let grid = deploy();
    seed(grid, 16, 4, 3);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 271958228)]
fn grid_e16_n4_k3() {
    let grid = deploy();
    seed(grid, 16, 4, 3);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 294725844)]
fn baseline_grid_e16_n4_k7() {
    let grid = deploy();
    seed(grid, 16, 4, 7);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 397864988)]
fn grid_e16_n4_k7() {
    let grid = deploy();
    seed(grid, 16, 4, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 108054429)]
fn baseline_grid_e16_n7_k0() {
    let grid = deploy();
    seed(grid, 16, 7, 0);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 248237909)]
fn grid_e16_n7_k0() {
    let grid = deploy();
    seed(grid, 16, 7, 0);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 208402068)]
fn baseline_grid_e16_n7_k1() {
    let grid = deploy();
    seed(grid, 16, 7, 1);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 359452964)]
fn grid_e16_n7_k1() {
    let grid = deploy();
    seed(grid, 16, 7, 1);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 308760480)]
fn baseline_grid_e16_n7_k3() {
    let grid = deploy();
    seed(grid, 16, 7, 3);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 469630976)]
fn grid_e16_n7_k3() {
    let grid = deploy();
    seed(grid, 16, 7, 3);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 509531400)]
fn baseline_grid_e16_n7_k7() {
    let grid = deploy();
    seed(grid, 16, 7, 7);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 689971712)]
fn grid_e16_n7_k7() {
    let grid = deploy();
    seed(grid, 16, 7, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 27580550)]
fn baseline_grid_e1_n28_k0() {
    let grid = deploy();
    seed(grid, 1, 28, 0);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 62474566)]
fn grid_e1_n28_k0() {
    let grid = deploy();
    seed(grid, 1, 28, 0);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 127942721)]
fn baseline_grid_e1_n28_k7() {
    let grid = deploy();
    seed(grid, 1, 28, 7);
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 172900945)]
fn grid_e1_n28_k7() {
    let grid = deploy();
    seed(grid, 1, 28, 7);
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 429207513)]
fn baseline_grid_e16_n28_k0() {
    let grid = deploy();
    seed(grid, 16, 28, 0);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 984856001)]
fn grid_e16_n28_k0() {
    let grid = deploy();
    seed(grid, 16, 28, 0);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 2035143684)]
fn baseline_grid_e16_n28_k7() {
    let grid = deploy();
    seed(grid, 16, 28, 7);
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 2751819500)]
fn grid_e16_n28_k7() {
    let grid = deploy();
    seed(grid, 16, 28, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Storage);
}

#[test]
#[available_gas(l2_gas: 834047)]
fn baseline_grid_event_e1() {
    let _grid = deploy();
    let _entries = distinct_entries(1, 1, 1);
}

#[test]
#[available_gas(l2_gas: 1066040)]
fn grid_event_e1() {
    let grid = deploy();
    let entries = distinct_entries(1, 1, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Event);
}

#[test]
#[available_gas(l2_gas: 842972)]
fn baseline_grid_event_e4() {
    let _grid = deploy();
    let _entries = distinct_entries(1, 4, 1);
}

#[test]
#[available_gas(l2_gas: 1283955)]
fn grid_event_e4() {
    let grid = deploy();
    let entries = distinct_entries(1, 4, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Event);
}

#[test]
#[available_gas(l2_gas: 879638)]
fn baseline_grid_event_e16() {
    let _grid = deploy();
    let _entries = distinct_entries(1, 16, 1);
}

#[test]
#[available_gas(l2_gas: 2156581)]
fn grid_event_e16() {
    let grid = deploy();
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Event);
}

/// Event mode on the fixture of `grid_e16_n7_k7`: it reads nothing, so its cost does not
/// depend on N or K (compare with `baseline_grid_e16_n7_k7`).
#[test]
#[available_gas(l2_gas: 510806842)]
fn grid_event_e16_on_n7_k7() {
    let grid = deploy();
    seed(grid, 16, 7, 7);
    let entries = distinct_entries(1, 16, 1);
    grid.quest.progress_many(PLAYER, entries, Mode::Event);
}
