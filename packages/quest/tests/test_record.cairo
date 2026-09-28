use quiver_quest::logic::{
    QuestRecord, claim, prerequisites_met, record_abandon, record_accept, record_complete,
    record_is_accepted,
};
use starknet::storage_access::StorePacking;
use super::helpers::{U64_MAX, no_progress, no_record, progress, record};

// prerequisites_met

#[test]
#[available_gas(l2_gas: 99999999)]
fn prerequisites_met_when_each_completed_once() {
    assert!(prerequisites_met(array![].span()));
    assert!(prerequisites_met(array![record(1, 0, false, false, 0)].span()));
    let seven = array![
        record(1, 0, false, false, 0), record(2, 0, false, false, 0), record(1, 1, true, false, 0),
        record(U64_MAX, 0, false, false, 0), record(1, 0, false, true, 3),
        record(5, 5, false, false, 0), record(1, 0, false, false, 0),
    ];
    assert!(prerequisites_met(seven.span()));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_prerequisites_all_required_logic() {
    assert!(!prerequisites_met(array![no_record()].span()));
    assert!(!prerequisites_met(array![record(1, 0, false, false, 0), no_record()].span()));
    // unlocked, active or claims on a prerequisite do not count: only completions
    assert!(!prerequisites_met(array![record(0, 3, true, true, 1)].span()));
}

// acceptance

#[test]
#[available_gas(l2_gas: 99999999)]
fn record_is_accepted_in_its_interval_only() {
    let r = record(0, 0, false, true, 5);
    assert!(record_is_accepted(@r, 5));
    assert!(!record_is_accepted(@r, 4));
    assert!(!record_is_accepted(@r, 6));
    assert!(!record_is_accepted(@record(0, 0, false, false, 5), 5));
    assert!(!record_is_accepted(@no_record(), 0));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn record_accept_sets_active_and_interval() {
    let r = record_accept(record(3, 2, true, false, 0), 7);
    assert!(r == record(3, 2, true, true, 7));
    assert!(record_is_accepted(@r, 7));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_acceptance_expires_at_rollover_logic() {
    let r = record_accept(no_record(), 0);
    assert!(record_is_accepted(@r, 0));
    // day 1: the acceptance of day 0 has expired without a write
    assert!(!record_is_accepted(@r, 1));
    let r = record_accept(r, 1);
    assert!(r == record(0, 0, false, true, 1));
    assert!(record_is_accepted(@r, 1));
}

#[test]
#[should_panic(expected: 'Quest: already accepted')]
#[available_gas(l2_gas: 99999999)]
fn quest_accept_twice_same_interval_reverts() {
    let r = record_accept(no_record(), 0);
    record_accept(r, 0);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn record_abandon_clears_active() {
    let r = record_abandon(record(1, 1, true, true, 4), 4);
    assert!(r == record(1, 1, true, false, 4));
    assert!(!record_is_accepted(@r, 4));
}

#[test]
#[should_panic(expected: 'Quest: not accepted')]
#[available_gas(l2_gas: 99999999)]
fn quest_abandon_expired_reverts() {
    let r = record_accept(no_record(), 0);
    record_abandon(r, 1);
}

#[test]
#[should_panic(expected: 'Quest: not accepted')]
#[available_gas(l2_gas: 99999999)]
fn record_abandon_not_accepted_reverts() {
    record_abandon(no_record(), 0);
}

// completion

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_completion_releases_acceptance() {
    let r = record_complete(record_accept(no_record(), 2));
    assert!(r == record(1, 0, false, false, 2));
    assert!(!record_is_accepted(@r, 2));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_recurring_completes_each_interval_logic() {
    let r = record_complete(record_complete(record_complete(no_record())));
    assert!(r.completions == 3);
    assert!(r == record(3, 0, false, false, 0));
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn record_complete_keeps_unlocked_and_claims() {
    let r = record_complete(record(4, 3, true, true, 9));
    assert!(r == record(5, 3, true, false, 9));
}

// claim

#[test]
#[available_gas(l2_gas: 99999999)]
fn claim_marks_claimed_and_counts() {
    let (p, r, index) = claim(progress(5, 0, 0, true, false), record(1, 0, true, false, 0));
    assert!(p == progress(5, 0, 0, true, true));
    assert!(r == record(1, 1, true, false, 0));
    assert!(index == 0);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_claim_index_counts_claims() {
    // completed on days 0 and 1; claim day 1 then day 0
    let day0 = progress(1, 0, 0, true, false);
    let day1 = progress(1, 0, 0, true, false);
    let r = record(2, 0, false, false, 0);
    let (_, r, first) = claim(day1, r);
    let (_, r, second) = claim(day0, r);
    assert!(first == 0);
    assert!(second == 1);
    assert!(r.claims == 2);
}

#[test]
#[should_panic(expected: 'Quest: not completed')]
#[available_gas(l2_gas: 99999999)]
fn quest_claim_uncompleted_reverts() {
    claim(no_progress(), no_record());
}

#[test]
#[should_panic(expected: 'Quest: not completed')]
#[available_gas(l2_gas: 99999999)]
fn quest_claim_uncompleted_reverts_before_claimed() {
    // not completed is checked first
    claim(progress(0, 0, 0, false, true), no_record());
}

#[test]
#[should_panic(expected: 'Quest: already claimed')]
#[available_gas(l2_gas: 99999999)]
fn quest_claim_twice_reverts() {
    let (p, r, _) = claim(progress(1, 0, 0, true, false), record(1, 0, false, false, 0));
    claim(p, r);
}

// counters

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_record_counters_past_u32() {
    let r = record(0xffffffff, 0xffffffff, false, false, 0);
    let r = record_complete(r);
    let (_, r, index) = claim(progress(1, 0, 0, true, false), r);
    assert!(r.completions == 0x100000000);
    assert!(r.claims == 0x100000000);
    assert!(index == 0xffffffff);
    let packed = StorePacking::<QuestRecord, felt252>::pack(r);
    assert!(StorePacking::<QuestRecord, felt252>::unpack(packed) == r);
}

#[test]
#[available_gas(l2_gas: 99999999)]
fn quest_record_counters_saturate() {
    let r = record(U64_MAX, U64_MAX, true, true, U64_MAX);
    let r = record_complete(r);
    let (_, r, index) = claim(progress(1, 0, 0, true, false), r);
    assert!(r.completions == U64_MAX);
    assert!(r.claims == U64_MAX);
    assert!(index == U64_MAX);
}
