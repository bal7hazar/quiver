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
