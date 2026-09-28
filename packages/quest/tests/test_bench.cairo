//! Benchmarks: one per function of `quiver_quest::logic`, on its worst case (docs/CAIRO.md §2):
//! 3 tasks, 7 conditions, a full page, 16 batch entries. Each is a test with its budget.
//!
//! Inputs pass through `opaque` so that the compiler cannot fold a call into a constant. A
//! figure includes the test's own setup: `bench_baseline_*` measure that setup alone, and the
//! cost of a function is its benchmark minus the matching baseline.

use quiver_quest::logic::{
    MAX_ENTRIES, QuestConditions, QuestDefinition, QuestIdPage, QuestProgress, QuestRecord,
    QuestSchedule, QuestTasks, TaskProgress, batch_count_of, batch_first_position, batch_merge,
    claim, conditions_span, definition_new, page_pop, page_position, page_push, page_set, page_span,
    prerequisites_met, progress_add, progress_is_complete, record_abandon, record_accept,
    record_complete, record_is_accepted, schedule_interval_id, schedule_is_active,
    schedule_validate, tasks_index_of, tasks_span,
};
use starknet::storage_access::StorePacking;
use super::helpers::{
    U32_MAX, U64_MAX, distinct_entries, entry, ids, opaque, page, progress, record, schedule, task,
    tasks,
};

fn recurring() -> QuestSchedule {
    opaque(schedule(1000, 0xffffffffffff, 3600, 86400))
}

fn three_tasks() -> QuestTasks {
    opaque(tasks(task(14, 100), task(15, 100), task(16, 100)))
}

fn seven_ids() -> QuestConditions {
    opaque(ids(1, 2, 3, 4, 5, 6, 7))
}

fn full_page() -> QuestIdPage {
    opaque(page(7, ids(1, 2, 3, 4, 5, 6, 7)))
}

fn sixteen_distinct() -> Span<TaskProgress> {
    opaque(distinct_entries(1, MAX_ENTRIES, 1))
}

/// 16 entries, 8 distinct tasks each named twice, interleaved.
fn sixteen_with_duplicates() -> Span<TaskProgress> {
    let mut out = array![];
    let mut i: u32 = 0;
    while i < MAX_ENTRIES {
        out.append(entry(i % 8 + 1, i + 1));
        i += 1;
    }
    opaque(out.span())
}

/// Tasks 1..=15, then `last`; every count positive. With `last = 15` the fast path of
/// `batch_merge` meets its repeat only at entry 16; with `last = 129` (= 1 mod 128) it meets a
/// collision of distinct ids only at entry 16. Both then run the plain merge in full.
fn fifteen_then(last: u32) -> Span<TaskProgress> {
    let mut out = array![];
    let mut i: u32 = 1;
    while i < MAX_ENTRIES {
        out.append(entry(i, i));
        i += 1;
    }
    out.append(entry(last, 1));
    opaque(out.span())
}

// Baselines: the setup of the benchmarks below, without the call

#[test]
#[available_gas(l2_gas: 55031)]
fn bench_baseline_fifteen_then_one() {
    assert!(fifteen_then(16).len() == MAX_ENTRIES);
}

#[test]
#[available_gas(l2_gas: 14826)]
fn bench_baseline_empty() {
    opaque(0_u8);
}

#[test]
#[available_gas(l2_gas: 66045)]
fn bench_baseline_sixteen_distinct() {
    assert!(sixteen_distinct().len() == MAX_ENTRIES);
}

#[test]
#[available_gas(l2_gas: 79275)]
fn bench_baseline_sixteen_with_duplicates() {
    assert!(sixteen_with_duplicates().len() == MAX_ENTRIES);
}

// schedule

#[test]
#[available_gas(l2_gas: 18354)]
fn bench_schedule_validate() {
    schedule_validate(@recurring());
}

#[test]
#[available_gas(l2_gas: 20192)]
fn bench_schedule_is_active() {
    assert!(schedule_is_active(@recurring(), opaque(1000 + 86400 * 30 + 10)));
}

#[test]
#[available_gas(l2_gas: 21137)]
fn bench_schedule_interval_id() {
    assert!(schedule_interval_id(@recurring(), opaque(1000 + 86400 * 30 + 10)) == Some(30));
}

// definition

#[test]
#[available_gas(l2_gas: 158928)]
fn bench_definition_new_three_tasks_seven_conditions() {
    let (definition, _, _) = definition_new(
        opaque(100),
        recurring(),
        opaque(array![task(1, 5), task(2, 6), task(3, 7)].span()),
        opaque(array![11, 12, 13, 14, 15, 16, 17].span()),
        opaque(true),
    );
    assert!(definition.condition_count == 7);
}

#[test]
#[available_gas(l2_gas: 21893)]
fn bench_tasks_index_of_absent() {
    assert!(tasks_index_of(@three_tasks(), opaque(3), opaque(99)) == None);
}

#[test]
#[available_gas(l2_gas: 21053)]
fn bench_tasks_span_three() {
    assert!(tasks_span(@three_tasks(), opaque(3)).len() == 3);
}

#[test]
#[available_gas(l2_gas: 20517)]
fn bench_conditions_span_seven() {
    assert!(conditions_span(@seven_ids(), opaque(7)).len() == 7);
}

// batch

#[test]
#[available_gas(l2_gas: 190991)]
fn bench_batch_merge_sixteen_distinct() {
    assert!(batch_merge(sixteen_distinct()).len() == MAX_ENTRIES);
}

#[test]
#[available_gas(l2_gas: 573218)]
fn bench_batch_merge_sixteen_with_duplicates() {
    assert!(batch_merge(sixteen_with_duplicates()).len() == 8);
}

#[test]
#[available_gas(l2_gas: 786569)]
fn bench_batch_merge_late_duplicate() {
    // [1..15, 15]: the worst case with a repeated task
    assert!(batch_merge(fifteen_then(15)).len() == 15);
}

#[test]
#[available_gas(l2_gas: 790675)]
fn bench_batch_merge_late_modulo_collision() {
    // [1..15, 129]: all distinct, the mask collides at the last entry
    assert!(batch_merge(fifteen_then(129)).len() == MAX_ENTRIES);
}

#[test]
#[available_gas(l2_gas: 95120)]
fn bench_batch_count_of_absent() {
    assert!(batch_count_of(sixteen_distinct(), opaque(99)) == 0);
}

#[test]
#[available_gas(l2_gas: 116015)]
fn bench_batch_first_position_absent() {
    let absent = opaque(tasks(task(97, 1), task(98, 1), task(99, 1)));
    assert!(batch_first_position(sixteen_distinct(), @absent) == None);
}

// progress

#[test]
#[available_gas(l2_gas: 164252)]
fn bench_progress_add_three_tasks_sixteen_entries() {
    // tasks 14, 15, 16 are the last entries of the batch; the call completes the quest
    let batch = opaque(distinct_entries(1, MAX_ENTRIES, 100));
    let (_, changed, completed) = progress_add(
        opaque(progress(99, 99, 99, false, false)), @three_tasks(), opaque(3), batch,
    );
    assert!(changed && completed);
}

#[test]
#[available_gas(l2_gas: 22764)]
fn bench_progress_is_complete_three_tasks() {
    let p = opaque(progress(100, 100, 100, true, false));
    assert!(progress_is_complete(@p, @three_tasks(), opaque(3)));
}

// record

#[test]
#[available_gas(l2_gas: 32970)]
fn bench_prerequisites_met_seven() {
    let r = record(1, 0, false, false, 0);
    assert!(prerequisites_met(opaque(array![r, r, r, r, r, r, r].span())));
}

#[test]
#[available_gas(l2_gas: 17997)]
fn bench_record_is_accepted() {
    assert!(record_is_accepted(@opaque(record(0, 0, false, true, 30)), opaque(30)));
}

#[test]
#[available_gas(l2_gas: 17472)]
fn bench_record_complete() {
    assert!(record_complete(opaque(record(1, 0, true, true, 30))).completions == 2);
}

#[test]
#[available_gas(l2_gas: 17892)]
fn bench_record_accept() {
    assert!(
        record_accept(opaque(record(1, 0, true, true, 29)), opaque(30)).accepted_interval == 30,
    );
}

#[test]
#[available_gas(l2_gas: 17997)]
fn bench_record_abandon() {
    assert!(!record_abandon(opaque(record(1, 0, true, true, 30)), opaque(30)).active);
}

#[test]
#[available_gas(l2_gas: 19257)]
fn bench_claim() {
    let (_, _, index) = claim(
        opaque(progress(1, 1, 1, true, false)), opaque(record(3, 2, true, false, 30)),
    );
    assert!(index == 2);
}

// pages

#[test]
#[available_gas(l2_gas: 22764)]
fn bench_page_push_seventh() {
    let p = opaque(page(6, ids(1, 2, 3, 4, 5, 6, 0)));
    assert!(page_push(p, opaque(7)).len == 7);
}

#[test]
#[available_gas(l2_gas: 20307)]
fn bench_page_span_full() {
    assert!(page_span(@full_page()).len() == 7);
}

#[test]
#[available_gas(l2_gas: 27122)]
fn bench_page_position_absent() {
    assert!(page_position(@full_page(), opaque(99)) == None);
}

#[test]
#[available_gas(l2_gas: 22764)]
fn bench_page_set_last() {
    assert!(page_set(full_page(), opaque(6), opaque(99)).ids.q6 == 99);
}

#[test]
#[available_gas(l2_gas: 26156)]
fn bench_page_pop_full() {
    let (_, id) = page_pop(full_page());
    assert!(id == 7);
}

// packing: pack then unpack, every field at its maximum

#[test]
#[available_gas(l2_gas: 45623)]
fn bench_pack_unpack_definition() {
    let d = opaque(
        QuestDefinition {
            schedule: schedule(U64_MAX, U64_MAX, U32_MAX, U32_MAX),
            task_count: 3,
            condition_count: 7,
            needs_accept: true,
            defined: true,
            retired: true,
            live_dependents: 0xffff,
        },
    );
    let packed = StorePacking::<QuestDefinition, felt252>::pack(d);
    assert!(StorePacking::<QuestDefinition, felt252>::unpack(opaque(packed)) == d);
}

#[test]
#[available_gas(l2_gas: 32960)]
fn bench_pack_unpack_tasks() {
    let t = opaque(tasks(task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX)));
    let packed = StorePacking::<QuestTasks, felt252>::pack(t);
    assert!(StorePacking::<QuestTasks, felt252>::unpack(opaque(packed)) == t);
}

#[test]
#[available_gas(l2_gas: 37296)]
fn bench_pack_unpack_conditions() {
    let m = U32_MAX;
    let c = opaque(ids(m, m, m, m, m, m, m));
    let packed = StorePacking::<QuestConditions, felt252>::pack(c);
    assert!(StorePacking::<QuestConditions, felt252>::unpack(opaque(packed)) == c);
}

#[test]
#[available_gas(l2_gas: 39512)]
fn bench_pack_unpack_page() {
    let m = U32_MAX;
    let p = opaque(page(7, ids(m, m, m, m, m, m, m)));
    let packed = StorePacking::<QuestIdPage, felt252>::pack(p);
    assert!(StorePacking::<QuestIdPage, felt252>::unpack(opaque(packed)) == p);
}

#[test]
#[available_gas(l2_gas: 30587)]
fn bench_pack_unpack_progress() {
    let p: QuestProgress = opaque(progress(U32_MAX, U32_MAX, U32_MAX, true, true));
    let packed = StorePacking::<QuestProgress, felt252>::pack(p);
    assert!(StorePacking::<QuestProgress, felt252>::unpack(opaque(packed)) == p);
}

#[test]
#[available_gas(l2_gas: 30471)]
fn bench_pack_unpack_record() {
    let r: QuestRecord = opaque(record(U64_MAX, U64_MAX, true, true, U64_MAX));
    let packed = StorePacking::<QuestRecord, felt252>::pack(r);
    assert!(StorePacking::<QuestRecord, felt252>::unpack(opaque(packed)) == r);
}
