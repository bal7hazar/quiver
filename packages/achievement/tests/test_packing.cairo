//! Every packed type of ARC-01 §3.11: round trip at zero, at every field's maximum and on mixed
//! values; the same felt as a plain oracle; the presence bits at their positions; field widths
//! checked and reserved bits rejected; an empty slot reads as undefined.
//!
//! The oracle uses `u256` on purpose: it is the plain, obviously correct version the arithmetic
//! packing is tested against (docs/CAIRO.md §2). It never runs in the library.

use core::num::traits::Pow;
use quiver_achievement::logic::{AchievementDefinition, AchievementExtraTasks};
use starknet::storage_access::StorePacking;
use super::helpers::{U32_MAX, U64_MAX, task, window};

// The oracle

fn pow2(n: u32) -> u256 {
    Pow::pow(2_u256, n.into())
}

/// Puts `value` in bits [offset, offset + width) of `acc`; the value must fit its width.
fn put(ref acc: u256, value: u256, offset: u32, width: u32) {
    assert!(value < pow2(width), "field wider than its range");
    acc = acc + value * pow2(offset);
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

fn oracle_definition(d: AchievementDefinition) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, d.window.start.into(), 0, 64);
    put(ref acc, d.window.end.into(), 64, 64);
    put(ref acc, d.task_count.into(), 128, 2);
    put(ref acc, bit(d.defined), 130, 1);
    put(ref acc, bit(d.retired), 131, 1);
    put(ref acc, d.t0.task_id.into(), 132, 32);
    put(ref acc, d.t0.total.into(), 164, 32);
    to_felt(acc)
}

fn oracle_extra(e: AchievementExtraTasks) -> felt252 {
    let mut acc: u256 = 0;
    put(ref acc, e.t1.task_id.into(), 0, 32);
    put(ref acc, e.t1.total.into(), 32, 32);
    put(ref acc, e.t2.task_id.into(), 64, 32);
    put(ref acc, e.t2.total.into(), 96, 32);
    to_felt(acc)
}

fn definition(
    start: u64, end: u64, task_count: u8, defined: bool, retired: bool, id: u32, total: u32,
) -> AchievementDefinition {
    AchievementDefinition {
        window: window(start, end), task_count, defined, retired, t0: task(id, total),
    }
}

fn round_trip_definition(d: AchievementDefinition) {
    let packed = StorePacking::pack(d);
    assert!(packed == oracle_definition(d));
    let back: AchievementDefinition = StorePacking::unpack(packed);
    assert!(back == d);
}

fn round_trip_extra(e: AchievementExtraTasks) {
    let packed = StorePacking::pack(e);
    assert!(packed == oracle_extra(e));
    let back: AchievementExtraTasks = StorePacking::unpack(packed);
    assert!(back == e);
}

#[test]
#[available_gas(l2_gas: 7879452)]
fn achievement_packing_round_trip_definition() {
    round_trip_definition(definition(0, 0, 0, false, false, 0, 0));
    round_trip_definition(definition(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX));
    round_trip_definition(definition(100, 200, 1, true, false, 7, 10));
    round_trip_definition(definition(0, 0, 2, false, true, 1, U32_MAX));
    round_trip_definition(definition(U64_MAX, 0, 3, true, false, U32_MAX, 1));
}

#[test]
#[available_gas(l2_gas: 3796905)]
fn achievement_packing_round_trip_extra_tasks() {
    round_trip_extra(AchievementExtraTasks { t1: task(0, 0), t2: task(0, 0) });
    round_trip_extra(
        AchievementExtraTasks { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) },
    );
    round_trip_extra(AchievementExtraTasks { t1: task(8, 5), t2: task(0, 0) });
    round_trip_extra(AchievementExtraTasks { t1: task(1, 2), t2: task(3, 4) });
}

/// `defined` is bit 130 and `retired` bit 131, alone.
#[test]
#[available_gas(l2_gas: 735956)]
fn achievement_packing_presence_bits_at_their_positions() {
    let defined: felt252 = StorePacking::pack(definition(0, 0, 0, true, false, 0, 0));
    assert!(defined == to_felt(pow2(130)));
    let retired: felt252 = StorePacking::pack(definition(0, 0, 0, false, true, 0, 0));
    assert!(retired == to_felt(pow2(131)));
}

/// The widest value of each slot stays below 2^196 (A) and 2^128 (B).
#[test]
#[available_gas(l2_gas: 719019)]
fn achievement_packing_widths() {
    let a: felt252 = StorePacking::pack(
        definition(U64_MAX, U64_MAX, 3, true, true, U32_MAX, U32_MAX),
    );
    assert!(a == to_felt(pow2(196) - 1));
    let b: felt252 = StorePacking::pack(
        AchievementExtraTasks { t1: task(U32_MAX, U32_MAX), t2: task(U32_MAX, U32_MAX) },
    );
    assert!(b == to_felt(pow2(128) - 1));
}

#[test]
#[available_gas(l2_gas: 32634)]
fn achievement_empty_slot_unpacks_undefined() {
    let d: AchievementDefinition = StorePacking::unpack(0);
    assert!(!d.defined);
    assert!(!d.retired);
    assert!(d.task_count == 0);
}

#[test]
#[should_panic(expected: 'Packing: field out of range')]
#[available_gas(l2_gas: 16296)]
fn achievement_packing_rejects_task_count_above_max() {
    let _: felt252 = StorePacking::pack(definition(0, 0, 4, true, false, 1, 1));
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 396701)]
fn achievement_unpacking_rejects_bit_196() {
    let _: AchievementDefinition = StorePacking::unpack(to_felt(pow2(196)));
}

/// Exactly 2^251: bit 251 alone, every lower reserved bit clear. A felt literal, since `to_felt`
/// requires values below 2^251 (2^251 is below the field prime, so it is a valid felt).
const TWO_POW_251: felt252 = 0x800000000000000000000000000000000000000000000000000000000000000;

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 30933)]
fn achievement_unpacking_rejects_bit_251() {
    let _: AchievementDefinition = StorePacking::unpack(TWO_POW_251);
}

#[test]
#[should_panic(expected: 'Packing: reserved bits set')]
#[available_gas(l2_gas: 358470)]
fn achievement_unpacking_extra_rejects_bit_128() {
    let _: AchievementExtraTasks = StorePacking::unpack(to_felt(pow2(128)));
}
