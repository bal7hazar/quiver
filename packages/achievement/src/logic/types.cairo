//! Types of `quiver_achievement::logic` (ARC-01 §3.10) and their packing into one felt each
//! (§3.11).
//!
//! There is no per-player type: 0.1.0 is event mode only (decision of 2026-09-29). A storage
//! design with per-task counters is planned for a later version; none of its layout is reserved
//! here.

use starknet::storage_access::StorePacking;
use crate::constants::MAX_TASKS;
use super::bits::{
    NZ_2, NZ_2_32, NZ_2_64, NZ_4, TWO_POW_128, TWO_POW_130, TWO_POW_131, TWO_POW_132, TWO_POW_164,
    TWO_POW_32, TWO_POW_64, TWO_POW_96, split,
};

/// When an achievement counts: `start <= time` and (`end == 0` or `time < end`).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementWindow {
    /// First second; 0 = from the epoch.
    pub start: u64,
    /// First second after; 0 = never ends.
    pub end: u64,
}

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementTask {
    pub task_id: u32,
    pub total: u32,
}

/// Storage slot A. Layout (bits from 0): `start` [0, 64) · `end` [64, 128) · `task_count`
/// [128, 130) · `defined` [130] · `retired` [131] · `t0.task_id` [132, 164) · `t0.total`
/// [164, 196). Bits [196, 252) are reserved.
///
/// The first task is inline, so a single-task achievement (every tier of a title) is one slot.
/// `points` is not stored: it is emitted in `AchievementDefined` only.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementDefinition {
    pub window: AchievementWindow,
    /// 1..=MAX_TASKS.
    pub task_count: u8,
    /// Presence bit: true once `define` wrote the slot. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`.
    pub retired: bool,
    pub t0: AchievementTask,
}

/// Storage slot B, written only when `task_count > 1`; unused entries are zero. Layout:
/// `t1.task_id` [0, 32) · `t1.total` [32, 64) · `t2.task_id` [64, 96) · `t2.total` [96, 128).
/// Bits [128, 252) are reserved.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementExtraTasks {
    pub t1: AchievementTask,
    pub t2: AchievementTask,
}

/// One entry of a progress batch.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct TaskProgress {
    pub task_id: u32,
    pub count: u32,
}

// Packing. Every field is put at its offset by a multiplication on felts and read back by a
// division with remainder on a `u128` limb; no field straddles bit 128.
//
// A field narrower than its Cairo type (`task_count`) is checked against its bound before
// packing, so that it never spills into its neighbour. Unpacking rejects a felt with a bit set
// outside the encoding: a stored felt the package did not write is a corruption. Neither panic
// is an error of the API: the component never packs or reads such a value.

const FIELD_OUT_OF_RANGE: felt252 = 'Packing: field out of range';
const RESERVED_BITS_SET: felt252 = 'Packing: reserved bits set';

pub impl AchievementDefinitionPacking of StorePacking<AchievementDefinition, felt252> {
    fn pack(value: AchievementDefinition) -> felt252 {
        assert(value.task_count <= MAX_TASKS, FIELD_OUT_OF_RANGE);
        value.window.start.into()
            + value.window.end.into() * TWO_POW_64
            + value.task_count.into() * TWO_POW_128
            + value.defined.into() * TWO_POW_130
            + value.retired.into() * TWO_POW_131
            + value.t0.task_id.into() * TWO_POW_132
            + value.t0.total.into() * TWO_POW_164
    }

    fn unpack(value: felt252) -> AchievementDefinition {
        let (low, high) = split(value);
        let (end, start) = DivRem::div_rem(low, NZ_2_64);
        let (high, task_count) = DivRem::div_rem(high, NZ_4);
        let (high, defined) = DivRem::div_rem(high, NZ_2);
        let (high, retired) = DivRem::div_rem(high, NZ_2);
        let (high, task_id) = DivRem::div_rem(high, NZ_2_32);
        // bits [164, 196) are `t0.total`; anything above is reserved
        let (rest, total) = DivRem::div_rem(high, NZ_2_32);
        assert(rest == 0, RESERVED_BITS_SET);
        AchievementDefinition {
            window: AchievementWindow {
                start: start.try_into().unwrap(), end: end.try_into().unwrap(),
            },
            task_count: task_count.try_into().unwrap(),
            defined: defined != 0,
            retired: retired != 0,
            t0: AchievementTask {
                task_id: task_id.try_into().unwrap(), total: total.try_into().unwrap(),
            },
        }
    }
}

pub impl AchievementExtraTasksPacking of StorePacking<AchievementExtraTasks, felt252> {
    fn pack(value: AchievementExtraTasks) -> felt252 {
        value.t1.task_id.into()
            + value.t1.total.into() * TWO_POW_32
            + value.t2.task_id.into() * TWO_POW_64
            + value.t2.total.into() * TWO_POW_96
    }

    fn unpack(value: felt252) -> AchievementExtraTasks {
        // 128 bits: one limb, no split; a felt of 128 bits or more is rejected here
        let low: u128 = value.try_into().expect(RESERVED_BITS_SET);
        let (low, id1) = DivRem::div_rem(low, NZ_2_32);
        let (low, total1) = DivRem::div_rem(low, NZ_2_32);
        let (total2, id2) = DivRem::div_rem(low, NZ_2_32);
        AchievementExtraTasks {
            t1: AchievementTask {
                task_id: id1.try_into().unwrap(), total: total1.try_into().unwrap(),
            },
            t2: AchievementTask {
                task_id: id2.try_into().unwrap(), total: total2.try_into().unwrap(),
            },
        }
    }
}
