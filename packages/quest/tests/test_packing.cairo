//! Every packed type of ARC-01 §3.3: round trip at zero, at every field's maximum and on mixed
//! values; the same felt as a plain oracle; below 2^251.
//!
//! The oracle uses `u256` on purpose: it is the plain, obviously correct version the arithmetic
//! packing is tested against (docs/CAIRO.md §2). It never runs in the library.

use core::num::traits::Pow;
use quiver_quest::constants::{ACCEPTANCE_LIMIT, HELD_INTERVAL_LIMIT};
use quiver_quest::models::definition::{ConditionsSlot, HeadSlot, TasksSlot};
use quiver_quest::models::held::HeldSlot;
use quiver_quest::models::progress::ProgressSlot;
use quiver_quest::models::record::RecordSlot;
use starknet::storage_access::StorePacking;
use super::helpers::{
    U32_MAX, U64_MAX, held, held_slot, held_slot0, held_slot_k, ids, progress, record, schedule,
    stamped, task, tasks,
};

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

fn oracle_definition(d: HeadSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, d.schedule.start.into(), 0, 64);
    put(ref acc, d.schedule.end.into(), 64, 64);
    put(ref acc, d.schedule.duration.into(), 128, 32);
    put(ref acc, d.schedule.interval.into(), 160, 32);
    put(ref acc, d.task_count.into(), 192, 2);
    put(ref acc, d.condition_count.into(), 194, 3);
    put(ref acc, bit(d.defined), 197, 1);
    put(ref acc, bit(d.retired), 198, 1);
    put(ref acc, d.live_dependents.into(), 199, 16);
    assert!(acc < pow2(215), "definition wider than 215 bits");
    to_felt(acc)
}

fn oracle_tasks(t: TasksSlot) -> felt252 {
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

fn oracle_conditions(c: ConditionsSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, c.q0.into(), 0, 32);
    put(ref acc, c.q1.into(), 32, 32);
    put(ref acc, c.q2.into(), 64, 32);
    put(ref acc, c.q3.into(), 96, 32);
    put(ref acc, c.q4.into(), 128, 32);
    put(ref acc, c.q5.into(), 160, 32);
    put(ref acc, c.q6.into(), 192, 32);
    assert!(acc < pow2(224), "conditions wider than 224 bits");
    to_felt(acc)
}

fn oracle_held_slot(h: HeldSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, h.e0.quest_id.into(), 0, 32);
    put(ref acc, h.e0.interval_id.into(), 32, 48);
    put(ref acc, h.e0.acceptance.into(), 80, 30);
    put(ref acc, h.counter.into(), 110, 30);
    put(ref acc, h.e1.quest_id.into(), 140, 32);
    put(ref acc, h.e1.interval_id.into(), 172, 48);
    put(ref acc, h.e1.acceptance.into(), 220, 30);
    put(ref acc, bit(h.kept), 250, 1);
    assert!(acc < pow2(251), "held slot wider than 251 bits");
    to_felt(acc)
}

fn oracle_progress(p: ProgressSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, p.c0.into(), 0, 32);
    put(ref acc, p.c1.into(), 32, 32);
    put(ref acc, p.c2.into(), 64, 32);
    put(ref acc, bit(p.completed), 96, 1);
    put(ref acc, bit(p.claimed), 97, 1);
    assert!(acc < pow2(98), "progress wider than 98 bits");
    to_felt(acc)
}

fn oracle_record(r: RecordSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, r.completions.into(), 0, 64);
    put(ref acc, r.claims.into(), 64, 64);
    put(ref acc, bit(r.unlocked), 128, 1);
    assert!(acc < pow2(129), "record wider than 129 bits");
    to_felt(acc)
}

// One check per type: the packing equals the oracle, is below 2^251, and unpacks to the value

fn check_definition(d: HeadSlot) {
    let packed = StorePacking::<HeadSlot, felt252>::pack(d);
    assert!(packed == oracle_definition(d));
    assert_below_2_251(packed);
    assert!(StorePacking::<HeadSlot, felt252>::unpack(packed) == d);
}

fn check_tasks(t: TasksSlot) {
    let packed = StorePacking::<TasksSlot, felt252>::pack(t);
    assert!(packed == oracle_tasks(t));
    assert_below_2_251(packed);
    assert!(StorePacking::<TasksSlot, felt252>::unpack(packed) == t);
}

fn check_conditions(c: ConditionsSlot) {
    let packed = StorePacking::<ConditionsSlot, felt252>::pack(c);
    assert!(packed == oracle_conditions(c));
    assert_below_2_251(packed);
    assert!(StorePacking::<ConditionsSlot, felt252>::unpack(packed) == c);
}

fn check_held_slot(h: HeldSlot) {
    let packed = StorePacking::<HeldSlot, felt252>::pack(h);
    assert!(packed == oracle_held_slot(h));
    assert_below_2_251(packed);
    assert!(StorePacking::<HeldSlot, felt252>::unpack(packed) == h);
}

fn check_progress(p: ProgressSlot) {
    let packed = StorePacking::<ProgressSlot, felt252>::pack(p);
    assert!(packed == oracle_progress(p));
    assert_below_2_251(packed);
    assert!(StorePacking::<ProgressSlot, felt252>::unpack(packed) == p);
}

fn check_record(r: RecordSlot) {
    let packed = StorePacking::<RecordSlot, felt252>::pack(r);
    assert!(packed == oracle_record(r));
    assert_below_2_251(packed);
    assert!(StorePacking::<RecordSlot, felt252>::unpack(packed) == r);
}

fn definition(
    start: u64,
    end: u64,
    duration: u32,
    interval: u32,
    task_count: u8,
    condition_count: u8,
    defined: bool,
    retired: bool,
    live_dependents: u16,
) -> HeadSlot {
    HeadSlot {
        schedule: schedule(start, end, duration, interval),
        task_count,
        condition_count,
        defined,
        retired,
        live_dependents,
    }
}

// HeadSlot (slot A)

#[test]
#[available_gas(l2_gas: 2507999)]
fn quest_packing_round_trip_definition_zero() {
    let zero = definition(0, 0, 0, 0, 0, 0, false, false, 0);
    check_definition(zero);
    assert!(StorePacking::<HeadSlot, felt252>::pack(zero) == 0);
}

#[test]
#[available_gas(l2_gas: 24942540)]
fn quest_packing_round_trip_definition_max() {
    check_definition(definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, true, 0xffff));
    // each field alone at its maximum
    check_definition(definition(U64_MAX, 0, 0, 0, 0, 0, false, false, 0));
    check_definition(definition(0, U64_MAX, 0, 0, 0, 0, false, false, 0));
    check_definition(definition(0, 0, U32_MAX, 0, 0, 0, false, false, 0));
    check_definition(definition(0, 0, 0, U32_MAX, 0, 0, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 3, 0, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 7, false, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, true, false, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, false, true, 0));
    check_definition(definition(0, 0, 0, 0, 0, 0, false, false, 0xffff));
}

#[test]
#[available_gas(l2_gas: 7493210)]
fn quest_packing_round_trip_definition_mixed() {
    check_definition(
        definition(
            0x0123456789abcdef, 0xfedcba9876543210, 86400, 604800, 2, 5, true, false, 0x1234,
        ),
    );
    check_definition(definition(1700000000, 0, 3600, 86400, 1, 0, true, false, 3));
    check_definition(definition(0x8000000000000001, 1, 1, 0x80000001, 3, 1, true, true, 1));
}

#[test]
#[available_gas(l2_gas: 1165805)]
fn quest_packing_presence_bits_at_their_positions() {
    let defined = definition(0, 0, 0, 0, 0, 0, true, false, 0);
    assert!(StorePacking::<HeadSlot, felt252>::pack(defined) == to_felt(pow2(197)));
    let retired = definition(0, 0, 0, 0, 0, 0, false, true, 0);
    assert!(StorePacking::<HeadSlot, felt252>::pack(retired) == to_felt(pow2(198)));
    let packed = StorePacking::<
        HeadSlot, felt252,
    >::pack(definition(U64_MAX, U64_MAX, U32_MAX, U32_MAX, 3, 7, true, false, 0xffff));
    assert!(get(packed, 197, 1) == 1);
    assert!(get(packed, 198, 1) == 0);
}

#[test]
#[available_gas(l2_gas: 37065)]
fn quest_empty_slot_reads_undefined() {
    let empty = StorePacking::<HeadSlot, felt252>::unpack(0);
    assert!(!empty.defined);
    assert!(!empty.retired);
    assert!(empty == definition(0, 0, 0, 0, 0, 0, false, false, 0));
}

// TasksSlot (slot B)

#[test]
#[available_gas(l2_gas: 15891383)]
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
        StorePacking::<TasksSlot, felt252>::pack(tasks(task(0, 0), task(0, 0), task(0, 0))) == 0,
    );
}

// ConditionsSlot (slot C)

#[test]
#[available_gas(l2_gas: 20233017)]
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

// HeldSlot

#[test]
#[available_gas(l2_gas: 42076577)]
fn quest_packing_round_trip_held_slot() {
    let none = held(0, 0);
    // the widths of fix loop 4: interval ids 48 bits, acceptance numbers and the counter 30
    let iv: u64 = HELD_INTERVAL_LIMIT - 1;
    let n: u32 = ACCEPTANCE_LIMIT - 1;
    check_held_slot(held_slot(none, none));
    check_held_slot(held_slot(held(U32_MAX, iv), held(U32_MAX, iv)));
    check_held_slot(held_slot(held(U32_MAX, 0), none));
    check_held_slot(held_slot(held(0, iv), none));
    check_held_slot(held_slot(none, held(U32_MAX, 0)));
    check_held_slot(held_slot(none, held(0, iv)));
    check_held_slot(held_slot(held(7, 19000), held(0x80000000, 0x800000000001)));
    // acceptance numbers and the counter, alone and at their maximum; the counter straddles
    // bit 128: its low 18 bits and its high 12 bits alone
    check_held_slot(held_slot0(stamped(0, 0, n), none, 0));
    check_held_slot(held_slot0(none, none, n));
    check_held_slot(held_slot0(none, none, 0x3ffff));
    check_held_slot(held_slot0(none, none, 0x3ffc0000));
    check_held_slot(held_slot0(none, stamped(0, 0, n), 0));
    check_held_slot(held_slot0(stamped(U32_MAX, iv, n), stamped(U32_MAX, iv, n), n));
    check_held_slot(held_slot0(stamped(3, 20000, 65537), stamped(9, 20000, 65538), 65538));
    // the kept bit alone, on an empty slot, and with nothing else
    check_held_slot(held_slot_k(none, none, 0, true));
    check_held_slot(held_slot_k(stamped(3, 1, 1), none, 0, false));
    // every field at its maximum: the largest value, below 2^251
    let full = StorePacking::<
        HeldSlot, felt252,
    >::pack(held_slot_k(stamped(U32_MAX, iv, n), stamped(U32_MAX, iv, n), n, true));
    assert!(full == to_felt(pow2(251) - 1));
    assert!(StorePacking::<HeldSlot, felt252>::pack(held_slot(none, none)) == 0);
}

/// Fix loop 4: an interval id or a number wider than its field is refused, not truncated.
#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_held_interval_2_48() {
    StorePacking::<HeldSlot, felt252>::pack(held_slot(held(1, HELD_INTERVAL_LIMIT), held(0, 0)));
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_held_acceptance_2_30() {
    StorePacking::<HeldSlot, felt252>::pack(held_slot(held(1, 0), stamped(2, 0, ACCEPTANCE_LIMIT)));
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_held_counter_2_30() {
    StorePacking::<HeldSlot, felt252>::pack(held_slot0(held(1, 0), held(0, 0), ACCEPTANCE_LIMIT));
}

// ProgressSlot

#[test]
#[available_gas(l2_gas: 12504681)]
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

// RecordSlot

#[test]
#[available_gas(l2_gas: 7500749)]
fn quest_packing_round_trip_record() {
    check_record(record(0, 0, false));
    check_record(record(U64_MAX, U64_MAX, true));
    check_record(record(U64_MAX, 0, false));
    check_record(record(0, U64_MAX, false));
    check_record(record(0, 0, true));
    check_record(record(0x100000000, 0xffffffff, true));
    check_record(record(3, 1, false));
}

// Fix loop 1: packing never lets a field spill into its neighbour (§3.3 widths), and unpacking
// rejects a felt the package did not write (a bit set outside the encoding).

fn pack_definition(d: HeadSlot) -> felt252 {
    StorePacking::<HeadSlot, felt252>::pack(d)
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_task_count_4() {
    pack_definition(definition(0, 0, 0, 0, 4, 0, true, false, 0));
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_task_count_255() {
    pack_definition(definition(0, 0, 0, 0, 255, 0, true, false, 0));
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_condition_count_8() {
    pack_definition(definition(0, 0, 0, 0, 1, 8, true, false, 0));
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn quest_packing_rejects_condition_count_16() {
    // 8 = 2^3 would have set `defined` (bit 197); 16 = 2^4 `retired` (bit 198)
    pack_definition(definition(0, 0, 0, 0, 1, 16, false, false, 0));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 446376)]
fn quest_unpacking_rejects_definition_bit_215() {
    StorePacking::<HeadSlot, felt252>::unpack(to_felt(pow2(215)));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 33159)]
fn quest_unpacking_rejects_definition_felt_minus_one() {
    StorePacking::<HeadSlot, felt252>::unpack(-1);
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 377202)]
fn quest_unpacking_rejects_tasks_bit_192() {
    StorePacking::<TasksSlot, felt252>::unpack(to_felt(pow2(192)));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 396113)]
fn quest_unpacking_rejects_conditions_bit_224() {
    StorePacking::<ConditionsSlot, felt252>::unpack(to_felt(pow2(224)));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 36803)]
fn quest_unpacking_rejects_held_bit_251() {
    // bit 250 is `kept`; bit 251, the only one above the layout, is reserved
    StorePacking::<
        HeldSlot, felt252,
    >::unpack(0x800000000000000000000000000000000000000000000000000000000000000);
}

#[test]
#[available_gas(l2_gas: 450114)]
fn quest_unpacking_reads_held_bit_250_as_kept() {
    let h = StorePacking::<HeldSlot, felt252>::unpack(to_felt(pow2(250)));
    assert!(h == held_slot_k(held(0, 0), held(0, 0), 0, true));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 373884)]
fn quest_unpacking_rejects_progress_bit_98() {
    StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(98)));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 360234)]
fn quest_unpacking_rejects_progress_bit_128() {
    StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(128)));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 373842)]
fn quest_unpacking_rejects_record_bit_129() {
    StorePacking::<RecordSlot, felt252>::unpack(to_felt(pow2(129)));
}

#[test]
#[available_gas(l2_gas: 724049)]
fn quest_unpacking_progress_reads_bit_97_alone() {
    let p = StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(97)));
    assert!(p == progress(0, 0, 0, false, true));
    let p = StorePacking::<ProgressSlot, felt252>::unpack(to_felt(pow2(96)));
    assert!(p == progress(0, 0, 0, true, false));
}

#[test]
#[available_gas(l2_gas: 5109279)]
fn quest_packing_accepts_the_bounds() {
    check_definition(definition(0, 0, 0, 0, 3, 7, true, false, 0));
    check_held_slot(held_slot(held(1, 2), held(3, 4)));
}
