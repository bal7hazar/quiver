//! Types of `quiver_quest::logic` (ARC-01 §3.2) and their packing into one felt (§3.3).

use starknet::storage_access::StorePacking;
use crate::constants::{MAX_CONDITIONS, MAX_TASKS, QUESTS_PER_PAGE};
use super::bits::{
    NZ_2, NZ_2_32, NZ_2_64, NZ_4, NZ_8, TWO_POW_128, TWO_POW_129, TWO_POW_130, TWO_POW_160,
    TWO_POW_192, TWO_POW_194, TWO_POW_197, TWO_POW_198, TWO_POW_199, TWO_POW_200, TWO_POW_224,
    TWO_POW_32, TWO_POW_64, TWO_POW_96, TWO_POW_97, split,
};

/// Where a progress call goes: stored records, or events only.
#[derive(Drop, Copy, Serde, PartialEq, Debug, starknet::Store)]
pub enum Mode {
    #[default]
    Storage,
    Event,
}

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestSchedule {
    /// First second of the quest; 0 = from the epoch.
    pub start: u64,
    /// First second after the quest; 0 = never ends.
    pub end: u64,
    /// Seconds active in each interval; 0 = one-off.
    pub duration: u32,
    /// Seconds between interval starts; 0 = one-off.
    pub interval: u32,
}

#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestTask {
    pub task_id: u32,
    pub total: u32,
}

/// Storage slot A. Layout (bits from 0): `start` [0, 64) · `end` [64, 128) · `duration`
/// [128, 160) · `interval` [160, 192) · `task_count` [192, 194) · `condition_count` [194, 197)
/// ·
/// `needs_accept` [197] · `defined` [198] · `retired` [199] · `live_dependents` [200, 216).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestDefinition {
    pub schedule: QuestSchedule,
    /// 1..=MAX_TASKS.
    pub task_count: u8,
    /// 0..=MAX_CONDITIONS.
    pub condition_count: u8,
    pub needs_accept: bool,
    /// Presence bit: true once `define` wrote the slot. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`; the quest is off every page.
    pub retired: bool,
    /// Defined, non-retired quests naming this one as a condition.
    pub live_dependents: u16,
}

/// Storage slot B; unused entries are zero. Layout: `t{i}.task_id` [64i, 64i + 32) ·
/// `t{i}.total` [64i + 32, 64i + 64), i = 0..3.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestTasks {
    pub t0: QuestTask,
    pub t1: QuestTask,
    pub t2: QuestTask,
}

/// Storage slot C; unused entries are zero. Layout: `q{i}` [32i, 32i + 32), i = 0..7.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestConditions {
    pub q0: u32,
    pub q1: u32,
    pub q2: u32,
    pub q3: u32,
    pub q4: u32,
    pub q5: u32,
    pub q6: u32,
}

/// An association page: live quests using a task. Layout: `ids.q{i}` [32i, 32i + 32),
/// i = 0..7 · `len` [224, 227).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestIdPage {
    /// 0..=QUESTS_PER_PAGE; pages are kept contiguous.
    pub len: u8,
    pub ids: QuestConditions,
}

/// Per (player, quest, interval). Layout: `c0` [0, 32) · `c1` [32, 64) · `c2` [64, 96) ·
/// `completed` [96] · `claimed` [97].
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestProgress {
    /// Counts, saturated at each task's total.
    pub c0: u32,
    pub c1: u32,
    pub c2: u32,
    pub completed: bool,
    pub claimed: bool,
}

/// Per (player, quest), across intervals. Layout: `completions` [0, 64) · `claims` [64, 128) ·
/// `unlocked` [128] · `active` [129] · `accepted_interval` [130, 194).
///
/// An acceptance holds only in the interval in which it was made:
/// `accepted(record, iid) = record.active && record.accepted_interval == iid`.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestRecord {
    /// Completions in all intervals; saturating increment.
    pub completions: u64,
    /// Claims in all intervals; saturating increment.
    pub claims: u64,
    /// Prerequisites seen met (cache).
    pub unlocked: bool,
    /// Accepted, and not completed or abandoned since.
    pub active: bool,
    /// Interval id in which it was accepted.
    pub accepted_interval: u64,
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
// A field narrower than its Cairo type (`task_count`, `condition_count`, a page's `len`) is
// checked against its bound before packing, so that it never spills into its neighbour: the
// layout of §3.3 holds only these values. Unpacking rejects a felt with a bit set above the
// encoding, or a page `len` above 7: a stored felt the package did not write is a corruption.
// Neither panic is an error of the API (§3.5): the component never packs or reads such a value.

const FIELD_OUT_OF_RANGE: felt252 = 'Packing: field out of range';
const RESERVED_BITS_SET: felt252 = 'Packing: reserved bits set';

pub impl QuestDefinitionPacking of StorePacking<QuestDefinition, felt252> {
    fn pack(value: QuestDefinition) -> felt252 {
        assert(
            value.task_count <= MAX_TASKS && value.condition_count <= MAX_CONDITIONS,
            FIELD_OUT_OF_RANGE,
        );
        let schedule = value.schedule;
        schedule.start.into()
            + schedule.end.into() * TWO_POW_64
            + schedule.duration.into() * TWO_POW_128
            + schedule.interval.into() * TWO_POW_160
            + value.task_count.into() * TWO_POW_192
            + value.condition_count.into() * TWO_POW_194
            + value.needs_accept.into() * TWO_POW_197
            + value.defined.into() * TWO_POW_198
            + value.retired.into() * TWO_POW_199
            + value.live_dependents.into() * TWO_POW_200
    }

    fn unpack(value: felt252) -> QuestDefinition {
        let (low, high) = split(value);
        let (end, start) = DivRem::div_rem(low, NZ_2_64);
        let (high, duration) = DivRem::div_rem(high, NZ_2_32);
        let (high, interval) = DivRem::div_rem(high, NZ_2_32);
        let (high, task_count) = DivRem::div_rem(high, NZ_4);
        let (high, condition_count) = DivRem::div_rem(high, NZ_8);
        let (high, needs_accept) = DivRem::div_rem(high, NZ_2);
        let (high, defined) = DivRem::div_rem(high, NZ_2);
        let (live_dependents, retired) = DivRem::div_rem(high, NZ_2);
        QuestDefinition {
            schedule: QuestSchedule {
                start: start.try_into().unwrap(),
                end: end.try_into().unwrap(),
                duration: duration.try_into().unwrap(),
                interval: interval.try_into().unwrap(),
            },
            task_count: task_count.try_into().unwrap(),
            condition_count: condition_count.try_into().unwrap(),
            needs_accept: needs_accept != 0,
            defined: defined != 0,
            retired: retired != 0,
            // bits [200, 216); anything above is reserved
            live_dependents: live_dependents.try_into().expect(RESERVED_BITS_SET),
        }
    }
}

pub impl QuestTasksPacking of StorePacking<QuestTasks, felt252> {
    fn pack(value: QuestTasks) -> felt252 {
        value.t0.task_id.into()
            + value.t0.total.into() * TWO_POW_32
            + value.t1.task_id.into() * TWO_POW_64
            + value.t1.total.into() * TWO_POW_96
            + value.t2.task_id.into() * TWO_POW_128
            + value.t2.total.into() * TWO_POW_160
    }

    fn unpack(value: felt252) -> QuestTasks {
        let (low, high) = split(value);
        let (low, id0) = DivRem::div_rem(low, NZ_2_32);
        let (low, total0) = DivRem::div_rem(low, NZ_2_32);
        let (total1, id1) = DivRem::div_rem(low, NZ_2_32);
        let (total2, id2) = DivRem::div_rem(high, NZ_2_32);
        QuestTasks {
            t0: QuestTask { task_id: id0.try_into().unwrap(), total: total0.try_into().unwrap() },
            t1: QuestTask { task_id: id1.try_into().unwrap(), total: total1.try_into().unwrap() },
            // bits [160, 192); anything above is reserved
            t2: QuestTask {
                task_id: id2.try_into().unwrap(),
                total: total2.try_into().expect(RESERVED_BITS_SET),
            },
        }
    }
}

#[inline(always)]
fn pack_ids(ids: QuestConditions) -> felt252 {
    ids.q0.into()
        + ids.q1.into() * TWO_POW_32
        + ids.q2.into() * TWO_POW_64
        + ids.q3.into() * TWO_POW_96
        + ids.q4.into() * TWO_POW_128
        + ids.q5.into() * TWO_POW_160
        + ids.q6.into() * TWO_POW_192
}

/// The seven ids of `low` and `high`, and what is left of `high` above them.
#[inline(always)]
fn unpack_ids(low: u128, high: u128) -> (QuestConditions, u128) {
    let (low, q0) = DivRem::div_rem(low, NZ_2_32);
    let (low, q1) = DivRem::div_rem(low, NZ_2_32);
    let (q3, q2) = DivRem::div_rem(low, NZ_2_32);
    let (high, q4) = DivRem::div_rem(high, NZ_2_32);
    let (high, q5) = DivRem::div_rem(high, NZ_2_32);
    let (rest, q6) = DivRem::div_rem(high, NZ_2_32);
    let ids = QuestConditions {
        q0: q0.try_into().unwrap(),
        q1: q1.try_into().unwrap(),
        q2: q2.try_into().unwrap(),
        q3: q3.try_into().unwrap(),
        q4: q4.try_into().unwrap(),
        q5: q5.try_into().unwrap(),
        q6: q6.try_into().unwrap(),
    };
    (ids, rest)
}

pub impl QuestConditionsPacking of StorePacking<QuestConditions, felt252> {
    fn pack(value: QuestConditions) -> felt252 {
        pack_ids(value)
    }

    fn unpack(value: felt252) -> QuestConditions {
        let (low, high) = split(value);
        let (ids, rest) = unpack_ids(low, high);
        assert(rest == 0, RESERVED_BITS_SET);
        ids
    }
}

pub impl QuestIdPagePacking of StorePacking<QuestIdPage, felt252> {
    fn pack(value: QuestIdPage) -> felt252 {
        assert(value.len <= QUESTS_PER_PAGE, FIELD_OUT_OF_RANGE);
        pack_ids(value.ids) + value.len.into() * TWO_POW_224
    }

    fn unpack(value: felt252) -> QuestIdPage {
        let (low, high) = split(value);
        let (ids, len) = unpack_ids(low, high);
        // bits [224, 227) hold 0..=7: a len of 8 (2^227) or any higher bit is rejected
        assert(len <= QUESTS_PER_PAGE.into(), RESERVED_BITS_SET);
        QuestIdPage { len: len.try_into().unwrap(), ids }
    }
}

pub impl QuestProgressPacking of StorePacking<QuestProgress, felt252> {
    fn pack(value: QuestProgress) -> felt252 {
        value.c0.into()
            + value.c1.into() * TWO_POW_32
            + value.c2.into() * TWO_POW_64
            + value.completed.into() * TWO_POW_96
            + value.claimed.into() * TWO_POW_97
    }

    fn unpack(value: felt252) -> QuestProgress {
        // 98 bits: one limb, no split; a felt of 128 bits or more is rejected here
        let low: u128 = value.try_into().expect(RESERVED_BITS_SET);
        let (low, c0) = DivRem::div_rem(low, NZ_2_32);
        let (low, c1) = DivRem::div_rem(low, NZ_2_32);
        let (low, c2) = DivRem::div_rem(low, NZ_2_32);
        let (claimed, completed) = DivRem::div_rem(low, NZ_2);
        // bit 97 alone is `claimed`; bits [98, 128) are reserved
        assert(claimed <= 1, RESERVED_BITS_SET);
        QuestProgress {
            c0: c0.try_into().unwrap(),
            c1: c1.try_into().unwrap(),
            c2: c2.try_into().unwrap(),
            completed: completed != 0,
            claimed: claimed != 0,
        }
    }
}

pub impl QuestRecordPacking of StorePacking<QuestRecord, felt252> {
    fn pack(value: QuestRecord) -> felt252 {
        value.completions.into()
            + value.claims.into() * TWO_POW_64
            + value.unlocked.into() * TWO_POW_128
            + value.active.into() * TWO_POW_129
            + value.accepted_interval.into() * TWO_POW_130
    }

    fn unpack(value: felt252) -> QuestRecord {
        let (low, high) = split(value);
        let (claims, completions) = DivRem::div_rem(low, NZ_2_64);
        let (high, unlocked) = DivRem::div_rem(high, NZ_2);
        let (accepted_interval, active) = DivRem::div_rem(high, NZ_2);
        QuestRecord {
            completions: completions.try_into().unwrap(),
            claims: claims.try_into().unwrap(),
            unlocked: unlocked != 0,
            active: active != 0,
            // bits [130, 194); anything above is reserved
            accepted_interval: accepted_interval.try_into().expect(RESERVED_BITS_SET),
        }
    }
}
