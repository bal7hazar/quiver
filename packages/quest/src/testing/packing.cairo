//! The packing oracle shared by the unit tests of the models (docs/CAIRO.md §2).

use core::num::traits::Pow;
use starknet::storage_access::StorePacking;
use crate::models::definition::{ConditionsSlot, HeadSlot, TasksSlot};
use crate::models::held::HeldSlot;
use crate::models::progress::ProgressSlot;
use crate::models::record::RecordSlot;

// The oracle

pub fn pow2(n: u32) -> u256 {
    Pow::pow(2_u256, n.into())
}

/// Puts `value` in bits [offset, offset + width) of `acc`; the value must fit its width.
pub fn put(ref acc: u256, value: u256, offset: u32, width: u32) {
    assert!(value < pow2(width), "field wider than its range");
    acc = acc + value * pow2(offset);
}

/// Reads bits [offset, offset + width) of `packed`.
pub fn get(packed: felt252, offset: u32, width: u32) -> u256 {
    let value: u256 = packed.into();
    (value / pow2(offset)) % pow2(width)
}

pub fn bit(flag: bool) -> u256 {
    if flag {
        1
    } else {
        0
    }
}

pub fn to_felt(value: u256) -> felt252 {
    assert!(value < pow2(251), "packed value not below 2^251");
    value.try_into().unwrap()
}

pub fn assert_below_2_251(packed: felt252) {
    let value: u256 = packed.into();
    assert!(value < pow2(251), "packed value not below 2^251");
}

pub fn oracle_definition(d: HeadSlot) -> felt252 {
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

pub fn oracle_tasks(t: TasksSlot) -> felt252 {
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

pub fn oracle_conditions(c: ConditionsSlot) -> felt252 {
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

pub fn oracle_held_slot(h: HeldSlot) -> felt252 {
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

pub fn oracle_progress(p: ProgressSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, p.c0.into(), 0, 32);
    put(ref acc, p.c1.into(), 32, 32);
    put(ref acc, p.c2.into(), 64, 32);
    put(ref acc, bit(p.completed), 96, 1);
    put(ref acc, bit(p.claimed), 97, 1);
    assert!(acc < pow2(98), "progress wider than 98 bits");
    to_felt(acc)
}

pub fn oracle_record(r: RecordSlot) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, r.completions.into(), 0, 64);
    put(ref acc, r.claims.into(), 64, 64);
    put(ref acc, bit(r.unlocked), 128, 1);
    assert!(acc < pow2(129), "record wider than 129 bits");
    to_felt(acc)
}

// One check per type: the packing equals the oracle, is below 2^251, and unpacks to the value

pub fn check_definition(d: HeadSlot) {
    let packed = StorePacking::<HeadSlot, felt252>::pack(d);
    assert!(packed == oracle_definition(d));
    assert_below_2_251(packed);
    assert!(StorePacking::<HeadSlot, felt252>::unpack(packed) == d);
}

pub fn check_tasks(t: TasksSlot) {
    let packed = StorePacking::<TasksSlot, felt252>::pack(t);
    assert!(packed == oracle_tasks(t));
    assert_below_2_251(packed);
    assert!(StorePacking::<TasksSlot, felt252>::unpack(packed) == t);
}

pub fn check_conditions(c: ConditionsSlot) {
    let packed = StorePacking::<ConditionsSlot, felt252>::pack(c);
    assert!(packed == oracle_conditions(c));
    assert_below_2_251(packed);
    assert!(StorePacking::<ConditionsSlot, felt252>::unpack(packed) == c);
}

pub fn check_held_slot(h: HeldSlot) {
    let packed = StorePacking::<HeldSlot, felt252>::pack(h);
    assert!(packed == oracle_held_slot(h));
    assert_below_2_251(packed);
    assert!(StorePacking::<HeldSlot, felt252>::unpack(packed) == h);
}

pub fn check_progress(p: ProgressSlot) {
    let packed = StorePacking::<ProgressSlot, felt252>::pack(p);
    assert!(packed == oracle_progress(p));
    assert_below_2_251(packed);
    assert!(StorePacking::<ProgressSlot, felt252>::unpack(packed) == p);
}

pub fn check_record(r: RecordSlot) {
    let packed = StorePacking::<RecordSlot, felt252>::pack(r);
    assert!(packed == oracle_record(r));
    assert_below_2_251(packed);
    assert!(StorePacking::<RecordSlot, felt252>::unpack(packed) == r);
}
