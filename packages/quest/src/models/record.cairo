//! A player's record of a quest across intervals (ARC-01 §3.2): completions, claims, and the
//! cached unlock. The model's behaviour, its storage, slot R. Untracked: completion and claim
//! have their action events (`QuestCompleted`, `QuestClaimed`), written with P by the same call;
//! tracking R would duplicate them (docs/research/ARC-06-model-store.md §6).

// Internal imports

use core::num::traits::SaturatingAdd;
use starknet::storage_access::StorePacking;
use crate::helpers::bits::errors::PACKING_RESERVED_BITS_SET;
use crate::helpers::bits::{BitsTrait, NZ_2_64, TWO_POW_128, TWO_POW_64};
pub use crate::models::index::QuestRecord;

// Slots

/// Slot R, key `(player_id, quest_id)`. Layout: `completions` [0, 64) · `claims` [64, 128) ·
/// `unlocked` [128]. 0.1.0's `QuestRecord`, renamed: what the view `quest_record` returns.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct RecordSlot {
    /// Completions in all intervals; saturating increment.
    pub completions: u64,
    /// Claims in all intervals; saturating increment.
    pub claims: u64,
    /// Prerequisites seen met, cached by `accept`.
    pub unlocked: bool,
}

// Implementations

#[generate_trait]
pub impl RecordImpl of RecordTrait {
    /// Completed at least once, in any interval: what a prerequisite needs.
    #[inline(always)]
    fn has_completed(self: @QuestRecord) -> bool {
        *self.completions != 0
    }

    /// `completions + 1`, saturating at `2^64 - 1`.
    #[inline(always)]
    fn complete(ref self: QuestRecord) {
        self.completions = self.completions.saturating_add(1);
    }

    /// `claims + 1`, saturating at `2^64 - 1`; returns the claim index, `claims` before the claim
    /// (0 for the first). The progress checks the claim (`ProgressTrait::claim`).
    #[inline(always)]
    fn claim(ref self: QuestRecord) -> u64 {
        let claim_index = self.claims;
        self.claims = claim_index.saturating_add(1);
        claim_index
    }

    /// Caches that the prerequisites were seen met.
    #[inline(always)]
    fn unlock(ref self: QuestRecord) {
        self.unlocked = true;
    }

    /// Every record has completed: the prerequisites of a quest are met, given the record of
    /// each condition (at most `MAX_CONDITIONS`). The component reads the records one by one and
    /// stops at the first not completed; this is its oracle.
    fn all_completed(records: Span<QuestRecord>) -> bool {
        let mut records = records;
        while let Some(record) = records.pop_front() {
            if !record.has_completed() {
                return false;
            }
        }
        true
    }
}

/// Storage: slot R, one felt (`RecordPacking`).
#[generate_trait]
pub impl RecordStorage of RecordStorageTrait {
    #[inline(always)]
    fn into_slot(self: @QuestRecord) -> RecordSlot {
        RecordSlot {
            completions: *self.completions, claims: *self.claims, unlocked: *self.unlocked,
        }
    }

    #[inline(always)]
    fn from_slot(player_id: felt252, quest_id: u32, slot: RecordSlot) -> QuestRecord {
        let RecordSlot { completions, claims, unlocked } = slot;
        QuestRecord { player_id, quest_id, completions, claims, unlocked }
    }
}

// Packing: see `crate::models::definition`.

pub impl RecordPacking of StorePacking<RecordSlot, felt252> {
    fn pack(value: RecordSlot) -> felt252 {
        value.completions.into()
            + value.claims.into() * TWO_POW_64
            + value.unlocked.into() * TWO_POW_128
    }

    fn unpack(value: felt252) -> RecordSlot {
        let (low, high) = BitsTrait::split(value);
        let (claims, completions) = DivRem::div_rem(low, NZ_2_64);
        // bit 128 alone is `unlocked`; bits [129, 252) are reserved
        assert(high <= 1, PACKING_RESERVED_BITS_SET);
        RecordSlot {
            completions: completions.try_into().unwrap(),
            claims: claims.try_into().unwrap(),
            unlocked: high != 0,
        }
    }
}
