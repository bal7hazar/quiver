use quiver_quest::logic::{batch_merge, progress_add, progress_is_complete};
use super::helpers::{U32_MAX, entry, no_progress, one_task, progress, task, tasks};

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_count_saturates_at_total() {
    let b = one_task(1, 10);
    let batch = array![entry(1, 7)].span();
    let (p, changed, completed) = progress_add(no_progress(), @b, 1, batch);
    assert!(p == progress(7, 0, 0, false, false));
    assert!(changed && !completed);
    let (p, changed, completed) = progress_add(p, @b, 1, batch);
    assert!(p == progress(10, 0, 0, true, false));
    assert!(changed && completed);
    // Completed once: more progress changes nothing and does not complete again
    let (p, changed, completed) = progress_add(p, @b, 1, batch);
    assert!(p == progress(10, 0, 0, true, false));
    assert!(!changed && !completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_count_max_value() {
    let b = one_task(1, U32_MAX);
    let batch = array![entry(1, U32_MAX)].span();
    let (p, changed, completed) = progress_add(progress(1, 0, 0, false, false), @b, 1, batch);
    assert!(p == progress(U32_MAX, 0, 0, true, false));
    assert!(changed && completed);
    let (p, changed, completed) = progress_add(p, @b, 1, batch);
    assert!(p == progress(U32_MAX, 0, 0, true, false));
    assert!(!changed && !completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_count_max_value_below_total() {
    // c + count overflows u32 but stays below no total: saturates at the total, never panics
    let b = one_task(1, U32_MAX);
    let (p, _, completed) = progress_add(
        progress(U32_MAX - 1, 0, 0, false, false), @b, 1, array![entry(1, U32_MAX)].span(),
    );
    assert!(p.c0 == U32_MAX);
    assert!(completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_one_off_completes_once() {
    let b = one_task(1, 1);
    let batch = array![entry(1, 1)].span();
    let (p, _, completed) = progress_add(no_progress(), @b, 1, batch);
    assert!(completed && p.completed);
    let (p2, changed, completed) = progress_add(p, @b, 1, batch);
    assert!(!completed && !changed);
    assert!(p2 == p);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_two_tasks_one_quest_one_write_logic() {
    // Both tasks of the quest are applied by one call: one new state, one completion
    let b = tasks(task(1, 5), task(2, 5), task(0, 0));
    let batch = batch_merge(array![entry(1, 5), entry(2, 5)].span());
    let (p, changed, completed) = progress_add(no_progress(), @b, 2, batch);
    assert!(p == progress(5, 5, 0, true, false));
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_batch_duplicate_entries_merged_progress() {
    let b = one_task(1, 10);
    let batch = batch_merge(array![entry(1, 4), entry(1, 4)].span());
    let (p, changed, completed) = progress_add(no_progress(), @b, 1, batch);
    assert!(p == progress(8, 0, 0, false, false));
    assert!(changed && !completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn progress_add_three_tasks_partial_then_complete() {
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    let (p, changed, completed) = progress_add(
        no_progress(), @b, 3, array![entry(3, 9), entry(1, 1)].span(),
    );
    assert!(p == progress(1, 0, 4, false, false));
    assert!(changed && !completed);
    let (p, changed, completed) = progress_add(
        p, @b, 3, array![entry(2, 3), entry(1, 1)].span(),
    );
    assert!(p == progress(2, 3, 4, true, false));
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn progress_add_ignores_other_tasks() {
    let b = tasks(task(1, 2), task(2, 3), task(0, 0));
    let start = progress(1, 1, 0, false, false);
    let (p, changed, completed) = progress_add(start, @b, 2, array![entry(9, 1)].span());
    assert!(p == start);
    assert!(!changed && !completed);
    let (p, changed, _) = progress_add(start, @b, 2, array![].span());
    assert!(p == start && !changed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn progress_add_touches_only_task_count_slots() {
    // A slot beyond task_count is left as it is, even if its task id is batched
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    let (p, _, completed) = progress_add(
        no_progress(), @b, 1, array![entry(1, 2), entry(2, 3), entry(3, 4)].span(),
    );
    assert!(p == progress(2, 0, 0, true, false));
    assert!(completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn progress_add_keeps_claimed() {
    let b = one_task(1, 2);
    let (p, _, _) = progress_add(
        progress(2, 0, 0, true, true), @b, 1, array![entry(1, 1)].span(),
    );
    assert!(p == progress(2, 0, 0, true, true));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn progress_is_complete_per_task_count() {
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    assert!(!progress_is_complete(@no_progress(), @b, 1));
    assert!(progress_is_complete(@progress(2, 0, 0, false, false), @b, 1));
    assert!(!progress_is_complete(@progress(2, 0, 0, false, false), @b, 2));
    assert!(progress_is_complete(@progress(2, 3, 0, false, false), @b, 2));
    assert!(!progress_is_complete(@progress(2, 3, 3, false, false), @b, 3));
    assert!(progress_is_complete(@progress(2, 3, 4, false, false), @b, 3));
    assert!(!progress_is_complete(@progress(1, 3, 4, false, false), @b, 3));
}
