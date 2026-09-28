use quiver_quest::logic::{MAX_ENTRIES, batch_count_of, batch_first_position, batch_merge};
use super::helpers::{U32_MAX, distinct_entries, entry, one_task, same_entries, task, tasks};

// batch_merge

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_merge_empty() {
    assert!(batch_merge(array![].span()) == array![].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_merge_keeps_distinct_entries_in_order() {
    let entries = array![entry(3, 1), entry(1, 2), entry(2, 3)].span();
    assert!(batch_merge(entries) == entries);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_duplicate_entries_merged() {
    let merged = batch_merge(array![entry(7, 4), entry(7, 4)].span());
    assert!(merged == array![entry(7, 8)].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_event_mode_one_event_per_task_merge() {
    // The pure part: the batch the event mode emits, one entry per merged non-zero task
    let merged = batch_merge(array![entry(1, 1), entry(1, 2), entry(2, 0), entry(3, 1)].span());
    assert!(merged == array![entry(1, 3), entry(3, 1)].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_merge_drops_zero_counts() {
    assert!(batch_merge(array![entry(1, 0)].span()) == array![].span());
    assert!(batch_merge(array![entry(1, 0), entry(1, 0), entry(2, 0)].span()) == array![].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_merge_keeps_the_position_of_first_occurrence() {
    // task 1 first appears with a zero count: the merged entry is still at its first position
    let merged = batch_merge(array![entry(1, 0), entry(2, 1), entry(1, 2), entry(2, 5)].span());
    assert!(merged == array![entry(1, 2), entry(2, 6)].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_merge_saturates_duplicates() {
    let merged = batch_merge(array![entry(1, U32_MAX), entry(2, 1), entry(1, 1)].span());
    assert!(merged == array![entry(1, U32_MAX), entry(2, 1)].span());
    let merged = batch_merge(same_entries(9, MAX_ENTRIES, U32_MAX));
    assert!(merged == array![entry(9, U32_MAX)].span());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_bound_accepted() {
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_merge(entries) == entries);
}

#[test]
#[should_panic(expected: 'Quest: too many entries')]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_above_bound_reverts() {
    batch_merge(distinct_entries(1, MAX_ENTRIES + 1, 1));
}

#[test]
#[should_panic(expected: 'Quest: too many entries')]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_duplicates_count_toward_bound() {
    batch_merge(same_entries(1, MAX_ENTRIES + 1, 1));
}

#[test]
#[should_panic(expected: 'Quest: too many entries')]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_zero_counts_count_toward_bound() {
    batch_merge(distinct_entries(1, MAX_ENTRIES + 1, 0));
}

#[test]
#[should_panic(expected: 'Quest: invalid task')]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_rejects_task_zero() {
    batch_merge(array![entry(0, 1)].span());
}

#[test]
#[should_panic(expected: 'Quest: invalid task')]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_rejects_task_zero_with_zero_count() {
    batch_merge(array![entry(1, 1), entry(0, 0)].span());
}

// batch_count_of

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_count_of_present_and_absent() {
    let batch = array![entry(3, 1), entry(1, 2), entry(2, 3)].span();
    assert!(batch_count_of(batch, 3) == 1);
    assert!(batch_count_of(batch, 1) == 2);
    assert!(batch_count_of(batch, 2) == 3);
    assert!(batch_count_of(batch, 4) == 0);
    assert!(batch_count_of(batch, 0) == 0);
    assert!(batch_count_of(array![].span(), 1) == 0);
}

// batch_first_position

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_first_position_uses_zero_sentinel() {
    let b = one_task(1, 5);
    let batch = array![entry(2, 1), entry(1, 1)].span();
    assert!(batch_first_position(batch, @b) == Some(1));
    // An entry with task id 0 never matches the zero slots t1 and t2
    let raw = array![entry(0, 1), entry(2, 1)].span();
    assert!(batch_first_position(raw, @b) == None);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_first_position_is_the_smallest_position() {
    let b = tasks(task(5, 1), task(6, 1), task(7, 1));
    let batch = array![entry(1, 1), entry(7, 1), entry(5, 1), entry(6, 1)].span();
    assert!(batch_first_position(batch, @b) == Some(1));
    assert!(batch_first_position(array![entry(6, 1)].span(), @b) == Some(0));
    assert!(batch_first_position(array![entry(8, 1)].span(), @b) == None);
    assert!(batch_first_position(array![].span(), @b) == None);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn batch_first_position_at_the_bound() {
    let batch = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_first_position(batch, @one_task(MAX_ENTRIES, 1)) == Some(MAX_ENTRIES - 1));
    assert!(batch_first_position(batch, @one_task(MAX_ENTRIES + 1, 1)) == None);
}
