//! Benchmarks: one per function of `quiver_quest::logic`, on its worst case (docs/CAIRO.md §2):
//! 3 tasks, 7 conditions, a full page, 16 batch entries. Each is a test with its budget.

use quiver_quest::logic::{
    MAX_ENTRIES, QuestConditions, QuestDefinition, QuestIdPage, QuestProgress, QuestRecord,
    QuestTasks, TaskProgress, batch_count_of, batch_first_position, batch_merge, claim,
    conditions_span, definition_new, page_pop, page_position, page_push, page_set, page_span,
    prerequisites_met, progress_add, progress_is_complete, record_abandon, record_accept,
    record_complete, record_is_accepted, schedule_interval_id, schedule_is_active,
    schedule_validate, tasks_index_of, tasks_span,
};
use starknet::storage_access::StorePacking;
use super::helpers::{
    U32_MAX, U64_MAX, distinct_entries, entry, ids, page, progress, record, schedule, task, tasks,
};

fn recurring() -> quiver_quest::logic::QuestSchedule {
    schedule(1000, 0xffffffffffff, 3600, 86400)
}

fn three_tasks() -> QuestTasks {
    tasks(task(14, 100), task(15, 100), task(16, 100))
}

fn full_page() -> QuestIdPage {
    page(7, ids(1, 2, 3, 4, 5, 6, 7))
}

/// 16 entries, 8 distinct tasks each named twice, interleaved: the merge's worst case with
/// duplicates.
fn sixteen_with_duplicates() -> Span<TaskProgress> {
    let mut out = array![];
    let mut i: u32 = 0;
    while i < MAX_ENTRIES {
        out.append(entry(i % 8 + 1, i + 1));
        i += 1;
    }
    out.span()
}

// schedule

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_schedule_validate() {
    schedule_validate(@recurring());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_schedule_is_active() {
    assert!(schedule_is_active(@recurring(), 1000 + 86400 * 30 + 10));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_schedule_interval_id() {
    assert!(schedule_interval_id(@recurring(), 1000 + 86400 * 30 + 10) == Some(30));
}

// definition

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_definition_new_three_tasks_seven_conditions() {
    let (definition, _, _) = definition_new(
        100,
        recurring(),
        array![task(1, 5), task(2, 6), task(3, 7)].span(),
        array![11, 12, 13, 14, 15, 16, 17].span(),
        true,
    );
    assert!(definition.condition_count == 7);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_tasks_index_of_absent() {
    assert!(tasks_index_of(@three_tasks(), 3, 99) == None);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_tasks_span_three() {
    assert!(tasks_span(@three_tasks(), 3).len() == 3);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_conditions_span_seven() {
    assert!(conditions_span(@ids(1, 2, 3, 4, 5, 6, 7), 7).len() == 7);
}

// batch

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_batch_merge_sixteen_distinct() {
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_merge(entries).len() == MAX_ENTRIES);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_batch_merge_sixteen_with_duplicates() {
    assert!(batch_merge(sixteen_with_duplicates()).len() == 8);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_batch_count_of_absent() {
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_count_of(entries, 99) == 0);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_batch_first_position_absent() {
    let entries = distinct_entries(1, MAX_ENTRIES, 1);
    assert!(batch_first_position(entries, @tasks(task(97, 1), task(98, 1), task(99, 1))) == None);
}

// progress

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_progress_add_three_tasks_sixteen_entries() {
    // tasks 14, 15, 16 are the last entries of the batch; the call completes the quest
    let batch = distinct_entries(1, MAX_ENTRIES, 100);
    let (_, changed, completed) = progress_add(
        progress(99, 99, 99, false, false), @three_tasks(), 3, batch,
    );
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_progress_is_complete_three_tasks() {
    assert!(progress_is_complete(@progress(100, 100, 100, true, false), @three_tasks(), 3));
}

// record

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_prerequisites_met_seven() {
    let r = record(1, 0, false, false, 0);
    assert!(prerequisites_met(array![r, r, r, r, r, r, r].span()));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_record_is_accepted() {
    assert!(record_is_accepted(@record(0, 0, false, true, 30), 30));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_record_complete() {
    assert!(record_complete(record(1, 0, true, true, 30)).completions == 2);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_record_accept() {
    assert!(record_accept(record(1, 0, true, true, 29), 30).accepted_interval == 30);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_record_abandon() {
    assert!(!record_abandon(record(1, 0, true, true, 30), 30).active);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_claim() {
    let (_, _, index) = claim(progress(1, 1, 1, true, false), record(3, 2, true, false, 30));
    assert!(index == 2);
}

// pages

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_page_push_seventh() {
    assert!(page_push(page(6, ids(1, 2, 3, 4, 5, 6, 0)), 7) == full_page());
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_page_span_full() {
    assert!(page_span(@full_page()).len() == 7);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_page_position_absent() {
    assert!(page_position(@full_page(), 99) == None);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_page_set_last() {
    assert!(page_set(full_page(), 6, 99).ids.q6 == 99);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_page_pop_full() {
    let (_, id) = page_pop(full_page());
    assert!(id == 7);
}

// packing: pack then unpack, every field at its maximum

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_definition() {
    let d = QuestDefinition {
        schedule: schedule(U64_MAX, U64_MAX, U32_MAX, U32_MAX),
        task_count: 3,
        condition_count: 7,
        needs_accept: true,
        defined: true,
        retired: true,
        live_dependents: 0xffff,
    };
    let packed = StorePacking::<QuestDefinition, felt252>::pack(d);
    assert!(StorePacking::<QuestDefinition, felt252>::unpack(packed) == d);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_tasks() {
    let t = tasks(task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX));
    let packed = StorePacking::<QuestTasks, felt252>::pack(t);
    assert!(StorePacking::<QuestTasks, felt252>::unpack(packed) == t);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_conditions() {
    let m = U32_MAX;
    let c = ids(m, m, m, m, m, m, m);
    let packed = StorePacking::<QuestConditions, felt252>::pack(c);
    assert!(StorePacking::<QuestConditions, felt252>::unpack(packed) == c);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_page() {
    let m = U32_MAX;
    let p = page(7, ids(m, m, m, m, m, m, m));
    let packed = StorePacking::<QuestIdPage, felt252>::pack(p);
    assert!(StorePacking::<QuestIdPage, felt252>::unpack(packed) == p);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_progress() {
    let p: QuestProgress = progress(U32_MAX, U32_MAX, U32_MAX, true, true);
    let packed = StorePacking::<QuestProgress, felt252>::pack(p);
    assert!(StorePacking::<QuestProgress, felt252>::unpack(packed) == p);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn bench_pack_unpack_record() {
    let r: QuestRecord = record(U64_MAX, U64_MAX, true, true, U64_MAX);
    let packed = StorePacking::<QuestRecord, felt252>::pack(r);
    assert!(StorePacking::<QuestRecord, felt252>::unpack(packed) == r);
}
