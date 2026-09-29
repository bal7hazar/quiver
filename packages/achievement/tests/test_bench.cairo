//! Benchmarks of the library, on the worst case of each function (docs/CAIRO.md §2). A figure
//! includes its setup; the function's own cost is the benchmark minus its `bench_baseline_*`.

use quiver_achievement::logic::{
    AchievementDefinition, AchievementExtraTasks, batch_merge, definition_new,
};
use starknet::storage_access::StorePacking;
use super::helpers::{U32_MAX, U64_MAX, always, distinct_entries, fifteen_then, task, window};

#[test]
#[available_gas(l2_gas: 52490)]
fn bench_baseline_sixteen_entries() {
    fifteen_then(129);
}

#[test]
#[available_gas(l2_gas: 789100)]
fn bench_batch_merge_late_modulo_collision() {
    batch_merge(fifteen_then(129));
}

#[test]
#[available_gas(l2_gas: 784994)]
fn bench_batch_merge_late_duplicate() {
    batch_merge(fifteen_then(15));
}

#[test]
#[available_gas(l2_gas: 189416)]
fn bench_batch_merge_sixteen_distinct() {
    batch_merge(distinct_entries(1, 16, 1));
}

#[test]
#[available_gas(l2_gas: 21966)]
fn bench_definition_new_three_tasks() {
    definition_new(1, always(), array![task(1, 1), task(2, 1), task(3, 1)].span());
}

#[test]
#[available_gas(l2_gas: 35826)]
fn bench_pack_unpack_definition() {
    let d = AchievementDefinition {
        window: window(U64_MAX, U64_MAX),
        task_count: 3,
        defined: true,
        retired: true,
        t0: task(U32_MAX, U32_MAX),
    };
    let back: AchievementDefinition = StorePacking::unpack(StorePacking::pack(d));
    assert!(back == d);
}

#[test]
#[available_gas(l2_gas: 26177)]
fn bench_pack_unpack_extra_tasks() {
    let e = AchievementExtraTasks { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) };
    let back: AchievementExtraTasks = StorePacking::unpack(StorePacking::pack(e));
    assert!(back == e);
}
