use quiver_quest::models::record::{RecordSlot, RecordTrait};
use starknet::storage_access::StorePacking;
use super::helpers::{
    U64_MAX, claim_both, complete, no_progress, no_record, progress, record, record_model,
};

// prerequisites_met

// gas: raised, the records are models with their two keys (ARC-07a), `RecordTrait::all_completed`
// walks larger entries
#[test]
#[available_gas(l2_gas: 45864)]
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

// gas: raised, the records are models with their two keys (ARC-07a), `RecordTrait::all_completed`
// walks larger entries
#[test]
#[available_gas(l2_gas: 32256)]
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
#[available_gas(l2_gas: 14406)]
fn quest_recurring_completes_each_interval_logic() {
    let r = complete(complete(complete(no_record())));
    assert!(r.completions == 3);
    assert!(r == record(3, 0, false));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn record_complete_keeps_unlocked_and_claims() {
    let r = complete(record(4, 3, true));
    assert!(r == record(5, 3, true));
}

// claim

#[test]
#[available_gas(l2_gas: 14406)]
fn claim_marks_claimed_and_counts() {
    let (p, r, index) = claim_both(progress(5, 0, 0, true, false), record(1, 0, true));
    assert!(p == progress(5, 0, 0, true, true));
    assert!(r == record(1, 1, true));
    assert!(index == 0);
}

#[test]
#[available_gas(l2_gas: 14406)]
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
#[available_gas(l2_gas: 16296)]
fn quest_claim_uncompleted_reverts() {
    claim_both(no_progress(), no_record());
}

#[test]
#[should_panic(expected: 'Quest: not completed')]
#[available_gas(l2_gas: 16296)]
fn quest_claim_uncompleted_reverts_before_claimed() {
    // not completed is checked first
    claim_both(progress(0, 0, 0, false, true), no_record());
}

#[test]
#[should_panic(expected: 'Quest: already claimed')]
#[available_gas(l2_gas: 16296)]
fn quest_claim_twice_reverts() {
    let (p, r, _) = claim_both(progress(1, 0, 0, true, false), record(1, 0, false));
    claim_both(p, r);
}

// counters

#[test]
#[available_gas(l2_gas: 24087)]
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
#[available_gas(l2_gas: 14406)]
fn quest_record_counters_saturate() {
    let r = record(U64_MAX, U64_MAX, true);
    let r = complete(r);
    let (_, r, index) = claim_both(progress(1, 0, 0, true, false), r);
    assert!(r.completions == U64_MAX);
    assert!(r.claims == U64_MAX);
    assert!(index == U64_MAX);
}
