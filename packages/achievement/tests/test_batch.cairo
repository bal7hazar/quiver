//! `batch_merge` and `batch_count_of` (ARC-01 §3.10), against a plain oracle.

use quiver_achievement::constants::MAX_ENTRIES;
use quiver_achievement::logic::{TaskProgress, batch_count_of, batch_merge};
use super::helpers::{U32_MAX, distinct_entries, entry, fifteen_then};

/// The plain merge: for each task in the order of first occurrence, the saturated sum of its
/// counts; zero sums dropped. Obviously correct, quadratic.
fn oracle(entries: Span<TaskProgress>) -> Span<TaskProgress> {
    let mut out: Array<TaskProgress> = array![];
    let mut seen: Array<u32> = array![];
    let mut i = 0;
    while i < entries.len() {
        let id = *entries[i].task_id;
        let mut known = false;
        for s in seen.span() {
            if *s == id {
                known = true;
            }
        }
        if !known {
            seen.append(id);
            let mut sum: u64 = 0;
            for e in entries {
                if *e.task_id == id {
                    sum += (*e.count).into();
                }
            }
            if sum > U32_MAX.into() {
                sum = U32_MAX.into();
            }
            if sum != 0 {
                out.append(entry(id, sum.try_into().unwrap()));
            }
        }
        i += 1;
    }
    out.span()
}

#[test]
#[available_gas(l2_gas: 54147)]
fn batch_merge_distinct_keeps_order_and_drops_zeros() {
    let entries = array![entry(3, 1), entry(1, 0), entry(2, 5)].span();
    assert!(batch_merge(entries) == array![entry(3, 1), entry(2, 5)].span());
}

#[test]
#[available_gas(l2_gas: 178804)]
fn achievement_batch_merges_duplicates() {
    let entries = array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span();
    let merged = batch_merge(entries);
    assert!(merged == array![entry(1, 3), entry(3, 1)].span());
    assert!(merged == oracle(entries));
}

#[test]
#[available_gas(l2_gas: 84121)]
fn batch_merge_saturates() {
    let entries = array![entry(1, U32_MAX), entry(2, 1), entry(1, 5)].span();
    assert!(batch_merge(entries) == array![entry(1, U32_MAX), entry(2, 1)].span());
}

/// Ids equal modulo 128 but distinct are not merged.
#[test]
#[available_gas(l2_gas: 1912600)]
fn batch_merge_modulo_collision_not_merged() {
    let entries = fifteen_then(129);
    let merged = batch_merge(entries);
    assert!(merged == entries);
    assert!(merged == oracle(entries));
}

#[test]
#[available_gas(l2_gas: 1844497)]
fn batch_merge_late_duplicate() {
    let entries = fifteen_then(15);
    let merged = batch_merge(entries);
    assert!(merged.len() == 15);
    assert!(batch_count_of(merged, 15) == 2);
    assert!(merged == oracle(entries));
}

/// A duplicate whose counts sum to zero is dropped, in the plain merge too.
#[test]
#[available_gas(l2_gas: 83533)]
fn batch_merge_zero_sum_duplicate_dropped() {
    let entries = array![entry(1, 0), entry(2, 1), entry(1, 0)].span();
    assert!(batch_merge(entries) == array![entry(2, 1)].span());
}

#[test]
#[available_gas(l2_gas: 239837)]
fn batch_merge_bound_accepted() {
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_merge(entries) == entries);
    assert!(batch_merge(array![].span()).len() == 0);
}

#[test]
#[should_panic(expected: 'Achievement: too many entries')]
#[available_gas(l2_gas: 77973)]
fn batch_merge_above_bound_reverts() {
    batch_merge(distinct_entries(1, MAX_ENTRIES + 1, 1));
}

/// The bound is checked before merging: 17 entries of one task revert.
#[test]
#[should_panic(expected: 'Achievement: too many entries')]
#[available_gas(l2_gas: 65247)]
fn batch_merge_duplicates_count_toward_bound() {
    let mut entries = array![];
    let mut i = 0;
    while i <= MAX_ENTRIES {
        entries.append(entry(7, 1));
        i += 1;
    }
    batch_merge(entries.span());
}

#[test]
#[should_panic(expected: 'Achievement: invalid task')]
#[available_gas(l2_gas: 40375)]
fn batch_merge_rejects_task_zero() {
    batch_merge(array![entry(1, 1), entry(0, 0)].span());
}

/// Task 0 is refused in the plain merge too (after a collision).
#[test]
#[should_panic(expected: 'Achievement: invalid task')]
#[available_gas(l2_gas: 65320)]
fn batch_merge_rejects_task_zero_after_collision() {
    batch_merge(array![entry(1, 1), entry(1, 1), entry(0, 1)].span());
}

#[test]
#[available_gas(l2_gas: 27605)]
fn batch_count_of_first_entry_or_zero() {
    let batch = array![entry(4, 2), entry(9, 3)].span();
    assert!(batch_count_of(batch, 9) == 3);
    assert!(batch_count_of(batch, 5) == 0);
}
