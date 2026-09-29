//! Types of `quiver_quest::logic` (ARC-01 §3.2) and their packing into one felt (§3.3).

use starknet::storage_access::StorePacking;
use crate::constants::{MAX_CONDITIONS, MAX_TASKS};
use super::bits::{
    NZ_2, NZ_2_16, NZ_2_32, NZ_2_64, NZ_4, NZ_8, TWO_POW_112, TWO_POW_128, TWO_POW_160, TWO_POW_192,
    TWO_POW_194, TWO_POW_197, TWO_POW_198, TWO_POW_199, TWO_POW_224, TWO_POW_32, TWO_POW_64,
    TWO_POW_96, TWO_POW_97, split,
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
/// · `defined` [197] · `retired` [198] · `live_dependents` [199, 215).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestDefinition {
    pub schedule: QuestSchedule,
    /// 1..=MAX_TASKS.
    pub task_count: u8,
    /// 0..=MAX_CONDITIONS.
    pub condition_count: u8,
    /// Presence bit: true once `define` wrote the slot. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`: no progress, no acceptance.
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
/// `unlocked` [128].
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestRecord {
    /// Completions in all intervals; saturating increment.
    pub completions: u64,
    /// Claims in all intervals; saturating increment.
    pub claims: u64,
    /// Prerequisites seen met, cached by `accept`.
    pub unlocked: bool,
}

/// One quest a player holds: accepted in `interval_id`, as the player's acceptance number
/// `acceptance`. `quest_id == 0` is an empty entry.
///
/// An entry is **live** while its quest is not retired, the current interval of its quest is
/// `interval_id`, and that interval is not completed; otherwise it is dead, and the next `accept`
/// prunes it. `acceptance` tells two acceptances of one quest in one interval apart: a quest
/// abandoned and accepted again is a new entry.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestHeld {
    pub quest_id: u32,
    pub interval_id: u64,
    pub acceptance: u16,
}

/// One slot of a player's held list: two entries, and in slot 0 the player's acceptance counter.
/// Layout: `e0.quest_id` [0, 32) · `e0.interval_id` [32, 96) · `e0.acceptance` [96, 112) ·
/// `counter` [112, 128) · `e1.quest_id` [128, 160) · `e1.interval_id` [160, 224) ·
/// `e1.acceptance` [224, 240).
///
/// The list is contiguous: entries fill slot 0 first, `e0` before `e1`, with no empty entry
/// before a non-empty one; so a slot whose `e1` is empty ends the list. `counter` is the number
/// of the player's last acceptance (wrapping at 2^16); it is 0 in the other slots.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestHeldSlot {
    pub e0: QuestHeld,
    pub e1: QuestHeld,
    pub counter: u16,
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
// A field narrower than its Cairo type (`task_count`, `condition_count`) is checked against its
// bound before packing, so that it never spills into its neighbour: the layout of §3.3 holds
// only these values. Unpacking rejects a felt with a bit set outside the encoding: a stored felt
// the package did not write is a corruption.
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
            + value.defined.into() * TWO_POW_197
            + value.retired.into() * TWO_POW_198
            + value.live_dependents.into() * TWO_POW_199
    }

    fn unpack(value: felt252) -> QuestDefinition {
        let (low, high) = split(value);
        let (end, start) = DivRem::div_rem(low, NZ_2_64);
        let (high, duration) = DivRem::div_rem(high, NZ_2_32);
        let (high, interval) = DivRem::div_rem(high, NZ_2_32);
        let (high, task_count) = DivRem::div_rem(high, NZ_4);
        let (high, condition_count) = DivRem::div_rem(high, NZ_8);
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
            defined: defined != 0,
            retired: retired != 0,
            // bits [199, 215); anything above is reserved
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

pub impl QuestConditionsPacking of StorePacking<QuestConditions, felt252> {
    fn pack(value: QuestConditions) -> felt252 {
        value.q0.into()
            + value.q1.into() * TWO_POW_32
            + value.q2.into() * TWO_POW_64
            + value.q3.into() * TWO_POW_96
            + value.q4.into() * TWO_POW_128
            + value.q5.into() * TWO_POW_160
            + value.q6.into() * TWO_POW_192
    }

    fn unpack(value: felt252) -> QuestConditions {
        let (low, high) = split(value);
        let (low, q0) = DivRem::div_rem(low, NZ_2_32);
        let (low, q1) = DivRem::div_rem(low, NZ_2_32);
        let (q3, q2) = DivRem::div_rem(low, NZ_2_32);
        let (high, q4) = DivRem::div_rem(high, NZ_2_32);
        let (high, q5) = DivRem::div_rem(high, NZ_2_32);
        let (rest, q6) = DivRem::div_rem(high, NZ_2_32);
        // bits [224, 252) are reserved
        assert(rest == 0, RESERVED_BITS_SET);
        QuestConditions {
            q0: q0.try_into().unwrap(),
            q1: q1.try_into().unwrap(),
            q2: q2.try_into().unwrap(),
            q3: q3.try_into().unwrap(),
            q4: q4.try_into().unwrap(),
            q5: q5.try_into().unwrap(),
            q6: q6.try_into().unwrap(),
        }
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
    }

    fn unpack(value: felt252) -> QuestRecord {
        let (low, high) = split(value);
        let (claims, completions) = DivRem::div_rem(low, NZ_2_64);
        // bit 128 alone is `unlocked`; bits [129, 252) are reserved
        assert(high <= 1, RESERVED_BITS_SET);
        QuestRecord {
            completions: completions.try_into().unwrap(),
            claims: claims.try_into().unwrap(),
            unlocked: high != 0,
        }
    }
}

/// An entry in a limb: `quest_id` [0, 32) · `interval_id` [32, 96); bits [96, 128) are reserved.
#[inline(always)]
/// An entry in a limb: `quest_id` [0, 32) · `interval_id` [32, 96) · `acceptance` [96, 112);
/// returns it and the bits [112, 128) above it.
fn unpack_held(limb: u128) -> (QuestHeld, u128) {
    let (rest, quest_id) = DivRem::div_rem(limb, NZ_2_32);
    let (rest, interval_id) = DivRem::div_rem(rest, NZ_2_64);
    let (above, acceptance) = DivRem::div_rem(rest, NZ_2_16);
    let entry = QuestHeld {
        quest_id: quest_id.try_into().unwrap(),
        interval_id: interval_id.try_into().unwrap(),
        acceptance: acceptance.try_into().unwrap(),
    };
    (entry, above)
}

pub impl QuestHeldSlotPacking of StorePacking<QuestHeldSlot, felt252> {
    fn pack(value: QuestHeldSlot) -> felt252 {
        value.e0.quest_id.into()
            + value.e0.interval_id.into() * TWO_POW_32
            + value.e0.acceptance.into() * TWO_POW_96
            + value.counter.into() * TWO_POW_112
            + value.e1.quest_id.into() * TWO_POW_128
            + value.e1.interval_id.into() * TWO_POW_160
            + value.e1.acceptance.into() * TWO_POW_224
    }

    fn unpack(value: felt252) -> QuestHeldSlot {
        let (low, high) = split(value);
        let (e0, counter) = unpack_held(low);
        let (e1, reserved) = unpack_held(high);
        // bits [240, 252) are reserved
        assert(reserved == 0, RESERVED_BITS_SET);
        QuestHeldSlot { e0, e1, counter: counter.try_into().unwrap() }
    }
}
