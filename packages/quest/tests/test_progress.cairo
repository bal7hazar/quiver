use quiver_quest::models::definition::TasksSlot;
use quiver_quest::models::progress::ProgressSlot;
use quiver_quest::types::batch::{BatchTrait, TaskProgress};
use super::helpers::{
    U32_MAX, add_counts, distinct_entries, entry, is_complete, no_progress, one_task, progress,
    task, tasks,
};

#[test]
#[available_gas(l2_gas: 48038)]
fn quest_count_saturates_at_total() {
    let b = one_task(1, 10);
    let batch = array![entry(1, 7)].span();
    let (p, changed, completed) = add_counts(no_progress(), @b, 1, batch);
    assert!(p == progress(7, 0, 0, false, false));
    assert!(changed && !completed);
    let (p, changed, completed) = add_counts(p, @b, 1, batch);
    assert!(p == progress(10, 0, 0, true, false));
    assert!(changed && completed);
    // Completed once: more progress changes nothing and does not complete again
    let (p, changed, completed) = add_counts(p, @b, 1, batch);
    assert!(p == progress(10, 0, 0, true, false));
    assert!(!changed && !completed);
}

#[test]
#[available_gas(l2_gas: 36341)]
fn quest_count_max_value() {
    let b = one_task(1, U32_MAX);
    let batch = array![entry(1, U32_MAX)].span();
    let (p, changed, completed) = add_counts(progress(1, 0, 0, false, false), @b, 1, batch);
    assert!(p == progress(U32_MAX, 0, 0, true, false));
    assert!(changed && completed);
    let (p, changed, completed) = add_counts(p, @b, 1, batch);
    assert!(p == progress(U32_MAX, 0, 0, true, false));
    assert!(!changed && !completed);
}

#[test]
#[available_gas(l2_gas: 23268)]
fn quest_count_max_value_below_total() {
    // c + count overflows u32 but stays below no total: saturates at the total, never panics
    let b = one_task(1, U32_MAX);
    let (p, _, completed) = add_counts(
        progress(U32_MAX - 1, 0, 0, false, false), @b, 1, array![entry(1, U32_MAX)].span(),
    );
    assert!(p.c0 == U32_MAX);
    assert!(completed);
}

#[test]
#[available_gas(l2_gas: 31490)]
fn quest_one_off_completes_once() {
    let b = one_task(1, 1);
    let batch = array![entry(1, 1)].span();
    let (p, _, completed) = add_counts(no_progress(), @b, 1, batch);
    assert!(completed && p.completed);
    let (p2, changed, completed) = add_counts(p, @b, 1, batch);
    assert!(!completed && !changed);
    assert!(p2 == p);
}

#[test]
#[available_gas(l2_gas: 52513)]
fn quest_batch_two_tasks_one_quest_one_write_logic() {
    // Both tasks of the quest are applied by one call: one new state, one completion
    let b = tasks(task(1, 5), task(2, 5), task(0, 0));
    let batch = BatchTrait::merge(array![entry(1, 5), entry(2, 5)].span());
    let (p, changed, completed) = add_counts(no_progress(), @b, 2, batch);
    assert!(p == progress(5, 5, 0, true, false));
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 61771)]
fn quest_batch_duplicate_entries_merged_progress() {
    let b = one_task(1, 10);
    let batch = BatchTrait::merge(array![entry(1, 4), entry(1, 4)].span());
    let (p, changed, completed) = add_counts(no_progress(), @b, 1, batch);
    assert!(p == progress(8, 0, 0, false, false));
    assert!(changed && !completed);
}

#[test]
#[available_gas(l2_gas: 66612)]
fn progress_add_three_tasks_partial_then_complete() {
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    let (p, changed, completed) = add_counts(
        no_progress(), @b, 3, array![entry(3, 9), entry(1, 1)].span(),
    );
    assert!(p == progress(1, 0, 4, false, false));
    assert!(changed && !completed);
    let (p, changed, completed) = add_counts(p, @b, 3, array![entry(2, 3), entry(1, 1)].span());
    assert!(p == progress(2, 3, 4, true, false));
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 49182)]
fn progress_add_ignores_other_tasks() {
    let b = tasks(task(1, 2), task(2, 3), task(0, 0));
    let start = progress(1, 1, 0, false, false);
    let (p, changed, completed) = add_counts(start, @b, 2, array![entry(9, 1)].span());
    assert!(p == start);
    assert!(!changed && !completed);
    let (p, changed, _) = add_counts(start, @b, 2, array![].span());
    assert!(p == start && !changed);
}

#[test]
#[available_gas(l2_gas: 25526)]
fn progress_add_touches_only_task_count_slots() {
    // A slot beyond task_count is left as it is, even if its task id is batched
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    let (p, _, completed) = add_counts(
        no_progress(), @b, 1, array![entry(1, 2), entry(2, 3), entry(3, 4)].span(),
    );
    assert!(p == progress(2, 0, 0, true, false));
    assert!(completed);
}

#[test]
#[available_gas(l2_gas: 17630)]
fn progress_add_keeps_claimed() {
    let b = one_task(1, 2);
    let (p, _, _) = add_counts(progress(2, 0, 0, true, true), @b, 1, array![entry(1, 1)].span());
    assert!(p == progress(2, 0, 0, true, true));
}

// The oracle: ARC-01 §3.2's formula, written plainly with its own lookup and u64 sums. It uses
// nothing of the library but the types.

/// The count of the first entry naming `task_id`, by index; 0 if none.
fn plain_lookup(batch: Span<TaskProgress>, task_id: u32) -> u32 {
    let mut found: Option<u32> = None;
    let mut i = 0;
    while i < batch.len() {
        if found.is_none() && *batch[i].task_id == task_id {
            found = Some(*batch[i].count);
        }
        i += 1;
    }
    match found {
        Some(count) => count,
        None => 0,
    }
}

fn plain_count(count: u32, add: u32, total: u32) -> u32 {
    let sum: u64 = count.into() + add.into();
    if sum > total.into() {
        total
    } else {
        sum.try_into().unwrap()
    }
}

fn plain_add(
    p: ProgressSlot, b: TasksSlot, task_count: u8, batch: Span<TaskProgress>,
) -> (ProgressSlot, bool, bool) {
    let mut next = p;
    if task_count >= 1 {
        next.c0 = plain_count(p.c0, plain_lookup(batch, b.t0.task_id), b.t0.total);
    }
    if task_count >= 2 {
        next.c1 = plain_count(p.c1, plain_lookup(batch, b.t1.task_id), b.t1.total);
    }
    if task_count >= 3 {
        next.c2 = plain_count(p.c2, plain_lookup(batch, b.t2.task_id), b.t2.total);
    }
    let all_done = (task_count < 1 || next.c0 == b.t0.total)
        && (task_count < 2 || next.c1 == b.t1.total)
        && (task_count < 3 || next.c2 == b.t2.total);
    let completed = all_done && !p.completed;
    if completed {
        next.completed = true;
    }
    (next, next != p, completed)
}

fn assert_matches_plain(p: ProgressSlot, b: TasksSlot, task_count: u8, batch: Span<TaskProgress>) {
    assert!(add_counts(p, @b, task_count, batch) == plain_add(p, b, task_count, batch));
}

#[test]
#[available_gas(l2_gas: 9738267)]
fn progress_add_matches_the_plain_formula() {
    let b = tasks(task(1, 10), task(2, 20), task(3, U32_MAX));
    let batches = array![
        array![].span(), array![entry(1, 3)].span(), array![entry(3, 1), entry(2, 25)].span(),
        array![entry(9, 1), entry(2, 5), entry(1, 10), entry(3, U32_MAX)].span(),
        // an unmerged batch: only the first entry of a task counts (a merged batch is expected)
        array![entry(1, 1), entry(1, 9), entry(2, 2), entry(2, 30)].span(),
        distinct_entries(1, 16, 7), distinct_entries(2, 16, 0),
    ];
    let starts = array![
        no_progress(), progress(9, 19, U32_MAX - 1, false, false),
        progress(10, 20, U32_MAX, true, false), progress(0, 20, 5, false, true),
    ];
    for batch in batches.span() {
        for start in starts.span() {
            let mut task_count: u8 = 0;
            while task_count <= 3 {
                assert_matches_plain(*start, b, task_count, *batch);
                task_count += 1;
            }
        }
    }
}

#[test]
#[available_gas(l2_gas: 16737)]
fn progress_is_complete_per_task_count() {
    let b = tasks(task(1, 2), task(2, 3), task(3, 4));
    assert!(!is_complete(@no_progress(), @b, 1));
    assert!(is_complete(@progress(2, 0, 0, false, false), @b, 1));
    assert!(!is_complete(@progress(2, 0, 0, false, false), @b, 2));
    assert!(is_complete(@progress(2, 3, 0, false, false), @b, 2));
    assert!(!is_complete(@progress(2, 3, 3, false, false), @b, 3));
    assert!(is_complete(@progress(2, 3, 4, false, false), @b, 3));
    assert!(!is_complete(@progress(1, 3, 4, false, false), @b, 3));
}
