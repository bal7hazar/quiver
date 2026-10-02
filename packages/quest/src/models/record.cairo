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

#[cfg(test)]
mod tests {
    use starknet::storage_access::StorePacking;
    use crate::testing::helpers::{
        U64_MAX, claim_both, complete, no_progress, no_record, opaque, progress, record,
        record_model,
    };
    use crate::testing::packing::{check_record, pow2, to_felt};
    use crate::types::schedule::ScheduleAssert;
    use super::{RecordSlot, RecordTrait};

    // prerequisites_met

    // gas: raised, the records are models with their two keys (ARC-07a),
    // `RecordTrait::all_completed`
    // walks larger entries
    #[test]
    #[available_gas(l2_gas: 37643)]
    fn prerequisites_met_when_each_completed_once() {
        assert!(RecordTrait::all_completed(array![].span()));
        assert!(RecordTrait::all_completed(array![record_model(1, 0, false)].span()));
        let seven = array![
            record_model(1, 0, false), record_model(2, 0, false), record_model(1, 1, true),
            record_model(U64_MAX, 0, false), record_model(1, 0, false), record_model(5, 5, false),
            record_model(1, 0, false),
        ];
        assert!(RecordTrait::all_completed(seven.span()));
    }

    // gas: raised, the records are models with their two keys (ARC-07a),
    // `RecordTrait::all_completed`
    // walks larger entries
    #[test]
    #[available_gas(l2_gas: 24035)]
    fn quest_prerequisites_all_required_logic() {
        assert!(!RecordTrait::all_completed(array![record_model(0, 0, false)].span()));
        assert!(
            !RecordTrait::all_completed(
                array![record_model(1, 0, false), record_model(0, 0, false)].span(),
            ),
        );
        // unlocked or claims on a prerequisite do not count: only completions
        assert!(!RecordTrait::all_completed(array![record_model(0, 3, true)].span()));
    }

    // completion

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn quest_recurring_completes_each_interval_logic() {
        let r = complete(complete(complete(no_record())));
        assert!(r.completions == 3);
        assert!(r == record(3, 0, false));
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn record_complete_keeps_unlocked_and_claims() {
        let r = complete(record(4, 3, true));
        assert!(r == record(5, 3, true));
    }

    // claim

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn claim_marks_claimed_and_counts() {
        let (p, r, index) = claim_both(progress(5, 0, 0, true, false), record(1, 0, true));
        assert!(p == progress(5, 0, 0, true, true));
        assert!(r == record(1, 1, true));
        assert!(index == 0);
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn quest_claim_index_counts_claims() {
        // completed on days 0 and 1; claim day 1 then day 0
        let day0 = progress(1, 0, 0, true, false);
        let day1 = progress(1, 0, 0, true, false);
        let r = record(2, 0, false);
        let (_, r, first) = claim_both(day1, r);
        let (_, r, second) = claim_both(day0, r);
        assert!(first == 0);
        assert!(second == 1);
        assert!(r.claims == 2);
    }

    #[test]
    #[should_panic(expected: 'Quest: not completed')]
    #[available_gas(l2_gas: 8201)]
    fn quest_claim_uncompleted_reverts() {
        claim_both(no_progress(), no_record());
    }

    #[test]
    #[should_panic(expected: 'Quest: not completed')]
    #[available_gas(l2_gas: 8201)]
    fn quest_claim_uncompleted_reverts_before_claimed() {
        // not completed is checked first
        claim_both(progress(0, 0, 0, false, true), no_record());
    }

    #[test]
    #[should_panic(expected: 'Quest: already claimed')]
    #[available_gas(l2_gas: 8201)]
    fn quest_claim_twice_reverts() {
        let (p, r, _) = claim_both(progress(1, 0, 0, true, false), record(1, 0, false));
        claim_both(p, r);
    }

    // counters

    #[test]
    #[available_gas(l2_gas: 15971)]
    fn quest_record_counters_past_u32() {
        let r = record(0xffffffff, 0xffffffff, false);
        let r = complete(r);
        let (_, r, index) = claim_both(progress(1, 0, 0, true, false), r);
        assert!(r.completions == 0x100000000);
        assert!(r.claims == 0x100000000);
        assert!(index == 0xffffffff);
        let packed = StorePacking::<RecordSlot, felt252>::pack(r);
        assert!(StorePacking::<RecordSlot, felt252>::unpack(packed) == r);
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn quest_record_counters_saturate() {
        let r = record(U64_MAX, U64_MAX, true);
        let r = complete(r);
        let (_, r, index) = claim_both(progress(1, 0, 0, true, false), r);
        assert!(r.completions == U64_MAX);
        assert!(r.claims == U64_MAX);
        assert!(index == U64_MAX);
    }

    // record

    // gas: raised, a record model carries its two keys, so a span of seven costs more to build and
    // walk (ARC-07a); off the component's paths, which read one record at a time
    #[test]
    #[available_gas(l2_gas: 28319)]
    fn bench_prerequisites_met_seven() {
        let r = record_model(1, 0, false);
        assert!(RecordTrait::all_completed(opaque(array![r, r, r, r, r, r, r].span())));
    }

    #[test]
    #[available_gas(l2_gas: 8726)]
    fn bench_record_complete() {
        assert!(complete(opaque(record(1, 0, true))).completions == 2);
    }

    #[test]
    #[available_gas(l2_gas: 10616)]
    fn bench_claim() {
        let (_, _, index) = claim_both(
            opaque(progress(1, 1, 1, true, false)), opaque(record(3, 2, true)),
        );
        assert!(index == 2);
    }

    #[test]
    #[available_gas(l2_gas: 16716)]
    fn bench_pack_unpack_record() {
        let r: RecordSlot = opaque(record(U64_MAX, U64_MAX, true));
        let packed = StorePacking::<RecordSlot, felt252>::pack(r);
        assert!(StorePacking::<RecordSlot, felt252>::unpack(opaque(packed)) == r);
    }

    // RecordSlot

    #[test]
    #[available_gas(l2_gas: 7492527)]
    fn quest_packing_round_trip_record() {
        check_record(record(0, 0, false));
        check_record(record(U64_MAX, U64_MAX, true));
        check_record(record(U64_MAX, 0, false));
        check_record(record(0, U64_MAX, false));
        check_record(record(0, 0, true));
        check_record(record(0x100000000, 0xffffffff, true));
        check_record(record(3, 1, false));
    }

    #[test]
    #[should_panic(expected: 'Packing: reserved bits set')]
    #[available_gas(l2_gas: 365747)]
    fn quest_unpacking_rejects_record_bit_129() {
        StorePacking::<RecordSlot, felt252>::unpack(to_felt(pow2(129)));
    }
}
