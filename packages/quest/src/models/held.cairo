//! One slot of a player's held list (ARC-01 §3.2, amended by D-135): the model's constructor, its
//! storage, slot H. Untracked: nothing is indexed. The list as a whole, the span of its entries,
//! is `crate::types::held`.
//!
//! The list is contiguous: entries fill slot 0 first, `e0` before `e1`, with no empty entry
//! before a non-empty one; so a slot whose `e1` is empty ends the list. `counter` is the number
//! of the player's last acceptance (30 bits, wrapping to 0 after 2^30 - 1); it is 0 in the other
//! slots. `kept` is set once the slot has held an entry and never cleared: a slot the list no
//! longer uses stays non-zero, so that the next use overwrites it instead of creating it.

// Internal imports

use starknet::storage_access::StorePacking;
use crate::constants::{ACCEPTANCE_LIMIT, HELD_INTERVAL_LIMIT};
use crate::helpers::bits::errors::{PACKING_FIELD_OUT_OF_RANGE, PACKING_RESERVED_BITS_SET};
use crate::helpers::bits::{
    BitsTrait, NZ_2_12, NZ_2_30, NZ_2_32, NZ_2_48, TWO_POW_110, TWO_POW_140, TWO_POW_172,
    TWO_POW_220, TWO_POW_250, TWO_POW_32, TWO_POW_80,
};
pub use crate::models::index::QuestHeldSlot;
use crate::types::held::{HeldTrait, QuestHeld};

// Slots

/// Slot H, key `(player_id, index)`. Layout: `e0.quest_id` [0, 32) · `e0.interval_id` [32, 80) ·
/// `e0.acceptance` [80, 110) · `counter` [110, 140) · `e1.quest_id` [140, 172) ·
/// `e1.interval_id` [172, 220) · `e1.acceptance` [220, 250) · `kept` [250]. 251 bits: every value
/// is below 2^251. `counter` is the one field that straddles bit 128 (18 bits in the low limb,
/// 12 in the high). 0.1.0's `QuestHeldSlot`, renamed.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct HeldSlot {
    pub e0: QuestHeld,
    pub e1: QuestHeld,
    pub counter: u32,
    pub kept: bool,
}

// Implementations

#[generate_trait]
pub impl HeldSlotImpl of HeldSlotTrait {
    /// Slot `index` of the list `held`: entries `2 × index` and `2 × index + 1`, empty past the
    /// end, `counter` in slot 0 (0 in the others), and `kept`.
    #[inline]
    fn new(
        player_id: felt252, index: u8, held: Span<QuestHeld>, counter: u32, kept: bool,
    ) -> QuestHeldSlot {
        let slot: u32 = index.into();
        let counter = if slot == 0 {
            counter
        } else {
            0
        };
        QuestHeldSlot {
            player_id,
            index,
            e0: held.entry_at(2 * slot),
            e1: held.entry_at(2 * slot + 1),
            counter,
            kept,
        }
    }
}

/// Storage: slot H, one felt (`HeldPacking`).
#[generate_trait]
pub impl HeldSlotStorage of HeldSlotStorageTrait {
    #[inline(always)]
    fn into_slot(self: @QuestHeldSlot) -> HeldSlot {
        HeldSlot { e0: *self.e0, e1: *self.e1, counter: *self.counter, kept: *self.kept }
    }

    #[inline(always)]
    fn from_slot(player_id: felt252, index: u8, slot: HeldSlot) -> QuestHeldSlot {
        let HeldSlot { e0, e1, counter, kept } = slot;
        QuestHeldSlot { player_id, index, e0, e1, counter, kept }
    }
}

// Packing: see `crate::models::definition`.

pub impl HeldPacking of StorePacking<HeldSlot, felt252> {
    fn pack(value: HeldSlot) -> felt252 {
        value.e0.assert_packable();
        value.e1.assert_packable();
        assert(value.counter < ACCEPTANCE_LIMIT, PACKING_FIELD_OUT_OF_RANGE);
        value.e0.quest_id.into()
            + value.e0.interval_id.into() * TWO_POW_32
            + value.e0.acceptance.into() * TWO_POW_80
            + value.counter.into() * TWO_POW_110
            + value.e1.quest_id.into() * TWO_POW_140
            + value.e1.interval_id.into() * TWO_POW_172
            + value.e1.acceptance.into() * TWO_POW_220
            + value.kept.into() * TWO_POW_250
    }

    fn unpack(value: felt252) -> HeldSlot {
        let (low, high) = BitsTrait::split(value);
        // low limb: e0 [0, 110), then the counter's low 18 bits [110, 128)
        let (e0, counter_low) = EntryPacking::unpack_entry(low);
        // high limb (bit 128 = its bit 0): the counter's high 12 bits, then e1, then `kept`
        let (rest, counter_high) = DivRem::div_rem(high, NZ_2_12);
        let (e1, kept) = EntryPacking::unpack_entry(rest);
        // bit 250 alone is `kept`; bit 251 is reserved
        assert(kept <= 1, PACKING_RESERVED_BITS_SET);
        let counter = counter_low + counter_high * 0x40000;
        HeldSlot { e0, e1, counter: counter.try_into().unwrap(), kept: kept != 0 }
    }
}

/// For `HeldPacking` only: an entry's part of the slot.
#[generate_trait]
impl EntryPacking of EntryPackingTrait {
    /// An entry from the low bits of a limb: `quest_id` [0, 32) · `interval_id` [32, 80) ·
    /// `acceptance` [80, 110); returns it and the bits above.
    #[inline(always)]
    fn unpack_entry(limb: u128) -> (QuestHeld, u128) {
        let (rest, quest_id) = DivRem::div_rem(limb, NZ_2_32);
        let (rest, interval_id) = DivRem::div_rem(rest, NZ_2_48);
        let (above, acceptance) = DivRem::div_rem(rest, NZ_2_30);
        let entry = QuestHeld {
            quest_id: quest_id.try_into().unwrap(),
            interval_id: interval_id.try_into().unwrap(),
            acceptance: acceptance.try_into().unwrap(),
        };
        (entry, above)
    }

    /// The interval and the acceptance number fit their widths.
    #[inline(always)]
    fn assert_packable(self: QuestHeld) {
        assert(
            self.interval_id < HELD_INTERVAL_LIMIT && self.acceptance < ACCEPTANCE_LIMIT,
            PACKING_FIELD_OUT_OF_RANGE,
        );
    }
}

#[cfg(test)]
mod tests {
    use starknet::storage_access::StorePacking;
    use crate::constants::{ACCEPTANCE_LIMIT, HELD_INTERVAL_LIMIT};
    use crate::testing::helpers::{
        U32_MAX, eight_held, held, held_slot, held_slot as slot, held_slot0, held_slot0 as slot0,
        held_slot_k, held_slot_of, opaque, stamped,
    };
    use crate::testing::packing::{check_held_slot, pow2, to_felt};
    use crate::types::held::{HELD_EMPTY, QuestHeld};
    use crate::types::schedule::ScheduleAssert;
    use super::HeldSlot;

    #[test]
    #[available_gas(l2_gas: 21252)]
    fn held_slot_pairs_entries_and_pads_with_empty() {
        let list = array![held(1, 10), held(2, 20), held(3, 30)].span();
        assert!(held_slot_of(list, 0, 7, true) == slot0(held(1, 10), held(2, 20), 7));
        // the counter is slot 0's only
        assert!(held_slot_of(list, 1, 7, true) == slot(held(3, 30), HELD_EMPTY));
        assert!(held_slot_of(list, 2, 7, false) == slot(HELD_EMPTY, HELD_EMPTY));
        assert!(HELD_EMPTY == held(0, 0));
    }

    #[test]
    #[available_gas(l2_gas: 31458)]
    fn bench_held_slot_last() {
        assert!(
            held_slot_of(
                eight_held(), opaque(3), opaque(9), opaque(true),
            ) == slot(held(7, 30), held(8, 30)),
        );
    }

    #[test]
    #[available_gas(l2_gas: 48017)]
    fn bench_pack_unpack_held_slot() {
        // every field at its maximum: interval ids 2^48 - 1, numbers and the counter 2^30 - 1
        let iv = HELD_INTERVAL_LIMIT - 1;
        let n = ACCEPTANCE_LIMIT - 1;
        let h: HeldSlot = opaque(
            HeldSlot {
                e0: QuestHeld { quest_id: U32_MAX, interval_id: iv, acceptance: n },
                e1: QuestHeld { quest_id: U32_MAX, interval_id: iv, acceptance: n },
                counter: n,
                kept: true,
            },
        );
        let packed = StorePacking::<HeldSlot, felt252>::pack(h);
        assert!(StorePacking::<HeldSlot, felt252>::unpack(opaque(packed)) == h);
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
        StorePacking::<
            HeldSlot, felt252,
        >::pack(held_slot(held(1, HELD_INTERVAL_LIMIT), held(0, 0)));
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 16296)]
    fn quest_packing_rejects_held_acceptance_2_30() {
        StorePacking::<
            HeldSlot, felt252,
        >::pack(held_slot(held(1, 0), stamped(2, 0, ACCEPTANCE_LIMIT)));
    }

    #[test]
    #[should_panic(expected: 'Packing: field out of range')]
    #[available_gas(l2_gas: 16296)]
    fn quest_packing_rejects_held_counter_2_30() {
        StorePacking::<
            HeldSlot, felt252,
        >::pack(held_slot0(held(1, 0), held(0, 0), ACCEPTANCE_LIMIT));
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
}
