//! Every packed type of ARC-01 §3.3: round trip at zero, at every field's maximum and on mixed
//! values; the same felt as a plain oracle; below 2^251.
//!
//! The oracle uses `u256` on purpose: it is the plain, obviously correct version the arithmetic
//! packing is tested against (docs/CAIRO.md §2). It never runs in the library.

use core::num::traits::Pow;
use quiver_quest::logic::{
    QuestConditions, QuestDefinition, QuestIdPage, QuestProgress, QuestRecord, QuestTasks,
};
use starknet::storage_access::StorePacking;
use super::helpers::{U32_MAX, U64_MAX, ids, page, progress, record, schedule, task, tasks};

// The oracle

fn pow2(n: u32) -> u256 {
    Pow::pow(2_u256, n.into())
}

/// Puts `value` in bits [offset, offset + width) of `acc`; the value must fit its width.
fn put(ref acc: u256, value: u256, offset: u32, width: u32) {
    assert!(value < pow2(width), "field wider than its range");
    acc = acc + value * pow2(offset);
}

/// Reads bits [offset, offset + width) of `packed`.
fn get(packed: felt252, offset: u32, width: u32) -> u256 {
    let value: u256 = packed.into();
    (value / pow2(offset)) % pow2(width)
}

fn bit(flag: bool) -> u256 {
    if flag {
        1
    } else {
        0
    }
}

fn to_felt(value: u256) -> felt252 {
    assert!(value < pow2(251), "packed value not below 2^251");
    value.try_into().unwrap()
}

fn assert_below_2_251(packed: felt252) {
    let value: u256 = packed.into();
    assert!(value < pow2(251), "packed value not below 2^251");
}

fn oracle_definition(d: QuestDefinition) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, d.schedule.start.into(), 0, 64);
    put(ref acc, d.schedule.end.into(), 64, 64);
    put(ref acc, d.schedule.duration.into(), 128, 32);
    put(ref acc, d.schedule.interval.into(), 160, 32);
    put(ref acc, d.task_count.into(), 192, 2);
    put(ref acc, d.condition_count.into(), 194, 3);
    put(ref acc, bit(d.needs_accept), 197, 1);
    put(ref acc, bit(d.defined), 198, 1);
    put(ref acc, bit(d.retired), 199, 1);
    put(ref acc, d.live_dependents.into(), 200, 16);
    assert!(acc < pow2(216), "definition wider than 216 bits");
    to_felt(acc)
}

fn oracle_tasks(t: QuestTasks) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, t.t0.task_id.into(), 0, 32);
    put(ref acc, t.t0.total.into(), 32, 32);
    put(ref acc, t.t1.task_id.into(), 64, 32);
    put(ref acc, t.t1.total.into(), 96, 32);
    put(ref acc, t.t2.task_id.into(), 128, 32);
    put(ref acc, t.t2.total.into(), 160, 32);
    assert!(acc < pow2(192), "tasks wider than 192 bits");
    to_felt(acc)
}

fn put_ids(ref acc: u256, c: QuestConditions) {
    put(ref acc, c.q0.into(), 0, 32);
    put(ref acc, c.q1.into(), 32, 32);
    put(ref acc, c.q2.into(), 64, 32);
    put(ref acc, c.q3.into(), 96, 32);
    put(ref acc, c.q4.into(), 128, 32);
    put(ref acc, c.q5.into(), 160, 32);
    put(ref acc, c.q6.into(), 192, 32);
}

fn oracle_conditions(c: QuestConditions) -> felt252 {
    let mut acc: u256 = 0;
    put_ids(ref acc, c);
    assert!(acc < pow2(224), "conditions wider than 224 bits");
    to_felt(acc)
}

fn oracle_page(p: QuestIdPage) -> felt252 {
    let mut acc: u256 = 0;
    put_ids(ref acc, p.ids);
    put(ref acc, p.len.into(), 224, 3);
    assert!(acc < pow2(227), "page wider than 227 bits");
    to_felt(acc)
}

fn oracle_progress(p: QuestProgress) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, p.c0.into(), 0, 32);
    put(ref acc, p.c1.into(), 32, 32);
    put(ref acc, p.c2.into(), 64, 32);
    put(ref acc, bit(p.completed), 96, 1);
    put(ref acc, bit(p.claimed), 97, 1);
    assert!(acc < pow2(98), "progress wider than 98 bits");
    to_felt(acc)
}

fn oracle_record(r: QuestRecord) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, r.completions.into(), 0, 64);
    put(ref acc, r.claims.into(), 64, 64);
    put(ref acc, bit(r.unlocked), 128, 1);
    put(ref acc, bit(r.active), 129, 1);
    put(ref acc, r.accepted_interval.into(), 130, 64);
    assert!(acc < pow2(194), "record wider than 194 bits");
    to_felt(acc)
}

// One check per type: the packing equals the oracle, is below 2^251, and unpacks to the value

fn check_definition(d: QuestDefinition) {
    let packed = StorePacking::<QuestDefinition, felt252>::pack(d);
    assert!(packed == oracle_definition(d));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestDefinition, felt252>::unpack(packed) == d);
}

fn check_tasks(t: QuestTasks) {
    let packed = StorePacking::<QuestTasks, felt252>::pack(t);
    assert!(packed == oracle_tasks(t));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestTasks, felt252>::unpack(packed) == t);
}

fn check_conditions(c: QuestConditions) {
    let packed = StorePacking::<QuestConditions, felt252>::pack(c);
    assert!(packed == oracle_conditions(c));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestConditions, felt252>::unpack(packed) == c);
}

fn check_page(p: QuestIdPage) {
    let packed = StorePacking::<QuestIdPage, felt252>::pack(p);
    assert!(packed == oracle_page(p));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestIdPage, felt252>::unpack(packed) == p);
}

fn check_progress(p: QuestProgress) {
    let packed = StorePacking::<QuestProgress, felt252>::pack(p);
    assert!(packed == oracle_progress(p));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestProgress, felt252>::unpack(packed) == p);
}

fn check_record(r: QuestRecord) {
    let packed = StorePacking::<QuestRecord, felt252>::pack(r);
    assert!(packed == oracle_record(r));
    assert_below_2_251(packed);
    assert!(StorePacking::<QuestRecord, felt252>::unpack(packed) == r);
}

fn definition(
    start: u64,
    end: u64,
    duration: u32,
    interval: u32,
    task_count: u8,
    condition_count: u8,
    needs_accept: bool,
    defined: bool,
    retired: bool,
    live_dependents: u16,
) -> QuestDefinition {
    QuestDefinition {
        schedule: schedule(start, end, duration, interval),
        task_count,
        condition_count,
        needs_accept,
        defined,
        retired,
        live_dependents,
    }
}

// QuestDefinition (slot A)

#[test]
#[available_gas(l2_gas: 2656101)]
fn quest_packing_round_trip_definition_zero() {
    let zero = definition(0, 0, 0, 0, 0, 0, false, false, false, 0);
    check_definition(zero);
    assert!(StorePacking::<QuestDefinition, felt252>::pack(zero) == 0);
}

#[test]
#[available_gas(l2_gas: 29061942)]
fn quest_packing_round_trip_definition_max() {
    check_definition(
        definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, true, true, 0xffff),
    );
    // each field alone at its maximum
    check_definition(definition(U64_MAX, 0, 0, 0, 0, 0, false, false, false, 0));
    check_definition(definition(0, U64_MAX, 0, 0, 0, 0, false, false, false, 0));
    check_definition(definition(0, 0, U32_MAX, 0, 0, 0, false, false, false, 0));
    check_definition(definition(0, 0, 0, U32_MAX, 0, 0, false, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 3, 0, false, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 7, false, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, true, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, false, true, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, false, false, true, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, false, false, false, 0xffff));
}

#[test]
#[available_gas(l2_gas: 7936688)]
fn quest_packing_round_trip_definition_mixed() {
    check_definition(
        definition(
            0x0123456789abcdef, 0xfedcba9876543210, 86400, 604800, 2, 5, true, true, false, 0x1234,
        ),
    );
    check_definition(definition(1700000000, 0, 3600, 86400, 1, 0, false, true, false, 3));
    check_definition(definition(0x8000000000000001, 1, 1, 0x80000001, 3, 1, false, true, true, 1));
}

#[test]
#[available_gas(l2_gas: 1195163)]
fn quest_packing_presence_bits_at_their_positions() {
    let defined = definition(0, 0, 0, 0, 0, 0, false, true, false, 0);
    assert!(StorePacking::<QuestDefinition, felt252>::pack(defined) == to_felt(pow2(198)));
    let retired = definition(0, 0, 0, 0, 0, 0, false, false, true, 0);
    assert!(StorePacking::<QuestDefinition, felt252>::pack(retired) == to_felt(pow2(199)));
    let packed = StorePacking::<
        QuestDefinition, felt252,
    >::pack(definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, true, false, 0xffff));
    assert!(get(packed, 198, 1) == 1);
    assert!(get(packed, 199, 1) == 0);
}

#[test]
#[available_gas(l2_gas: 40089)]
fn quest_empty_slot_reads_undefined() {
    let empty = StorePacking::<QuestDefinition, felt252>::unpack(0);
    assert!(!empty.defined);
    assert!(!empty.retired);
    assert!(empty == definition(0, 0, 0, 0, 0, 0, false, false, false, 0));
}

// QuestTasks (slot B)

#[test]
#[available_gas(l2_gas: 15893273)]
fn quest_packing_round_trip_tasks() {
    check_tasks(tasks(task(0, 0), task(0, 0), task(0, 0)));
    check_tasks(tasks(task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX), task(U32_MAX, U32_MAX)));
    check_tasks(tasks(task(U32_MAX, 0), task(0, 0), task(0, 0)));
    check_tasks(tasks(task(0, U32_MAX), task(0, 0), task(0, 0)));
    check_tasks(tasks(task(0, 0), task(U32_MAX, 0), task(0, 0)));
    check_tasks(tasks(task(0, 0), task(0, U32_MAX), task(0, 0)));
    check_tasks(tasks(task(0, 0), task(0, 0), task(U32_MAX, 0)));
    check_tasks(tasks(task(0, 0), task(0, 0), task(0, U32_MAX)));
    check_tasks(tasks(task(0x12345678, 10), task(0x9abcdef0, 1), task(7, 0x80000000)));
    assert!(
        StorePacking::<QuestTasks, felt252>::pack(tasks(task(0, 0), task(0, 0), task(0, 0))) == 0,
    );
}

// QuestConditions (slot C)

#[test]
#[available_gas(l2_gas: 20231967)]
fn quest_packing_round_trip_conditions() {
    check_conditions(ids(0, 0, 0, 0, 0, 0, 0));
    let m = U32_MAX;
    check_conditions(ids(m, m, m, m, m, m, m));
    check_conditions(ids(m, 0, 0, 0, 0, 0, 0));
    check_conditions(ids(0, m, 0, 0, 0, 0, 0));
    check_conditions(ids(0, 0, m, 0, 0, 0, 0));
    check_conditions(ids(0, 0, 0, m, 0, 0, 0));
    check_conditions(ids(0, 0, 0, 0, m, 0, 0));
    check_conditions(ids(0, 0, 0, 0, 0, m, 0));
    check_conditions(ids(0, 0, 0, 0, 0, 0, m));
    check_conditions(ids(1, 0x80000000, 0x12345678, 3, 0xdeadbeef, 0x7fffffff, 42));
}

// QuestIdPage

#[test]
#[available_gas(l2_gas: 13562682)]
fn quest_packing_round_trip_page() {
    check_page(page(0, ids(0, 0, 0, 0, 0, 0, 0)));
    let m = U32_MAX;
    check_page(page(7, ids(m, m, m, m, m, m, m)));
    check_page(page(7, ids(0, 0, 0, 0, 0, 0, 0)));
    check_page(page(0, ids(0, 0, 0, 0, 0, 0, m)));
    check_page(page(3, ids(5, 0x80000000, 0x12345678, 0, 0, 0, 0)));
    check_page(page(6, ids(1, 2, 3, 4, 5, 0xfffffffe, 0)));
}

// QuestProgress

#[test]
#[available_gas(l2_gas: 12500240)]
fn quest_packing_round_trip_progress() {
    check_progress(progress(0, 0, 0, false, false));
    check_progress(progress(U32_MAX, U32_MAX, U32_MAX, true, true));
    check_progress(progress(U32_MAX, 0, 0, false, false));
    check_progress(progress(0, U32_MAX, 0, false, false));
    check_progress(progress(0, 0, U32_MAX, false, false));
    check_progress(progress(0, 0, 0, true, false));
    check_progress(progress(0, 0, 0, false, true));
    check_progress(progress(10, 0x12345678, 3, true, false));
    check_progress(progress(0x80000000, 1, 0x7fffffff, false, true));
}

// QuestRecord

#[test]
#[available_gas(l2_gas: 13596597)]
fn quest_packing_round_trip_record() {
    check_record(record(0, 0, false, false, 0));
    check_record(record(U64_MAX, U64_MAX, true, true, U64_MAX));
    check_record(record(U64_MAX, 0, false, false, 0));
    check_record(record(0, U64_MAX, false, false, 0));
    check_record(record(0, 0, true, false, 0));
    check_record(record(0, 0, false, true, 0));
    check_record(record(0, 0, false, false, U64_MAX));
    check_record(record(0x100000000, 0xffffffff, true, false, 0x10000000000));
    check_record(record(3, 1, false, true, 0x8000000000000001));
}
