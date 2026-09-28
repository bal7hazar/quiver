use quiver_quest::logic::{schedule_interval_id, schedule_is_active, schedule_validate};
use super::helpers::{DAY, U32_MAX, U64_MAX, daily, one_off, schedule};

// schedule_validate

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_validate_accepts_valid_schedules() {
    schedule_validate(@one_off());
    schedule_validate(@daily());
    schedule_validate(@schedule(100, 0, 0, 0));
    schedule_validate(@schedule(100, 101, 0, 0));
    schedule_validate(@schedule(100, 200, 10, 60));
    // duration == interval: active through every interval
    schedule_validate(@schedule(0, 0, 1, 1));
    schedule_validate(@schedule(U64_MAX - 1, U64_MAX, U32_MAX, U32_MAX));
}

#[test]
#[should_panic(expected: 'Quest: invalid window')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_empty_window() {
    schedule_validate(@schedule(100, 100, 0, 0));
}

#[test]
#[should_panic(expected: 'Quest: invalid window')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_end_before_start() {
    schedule_validate(@schedule(100, 99, 0, 0));
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_duration_above_interval() {
    schedule_validate(@schedule(0, 0, 2, 1));
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_half_recurring_interval_only() {
    schedule_validate(@schedule(0, 0, 0, DAY));
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_half_recurring_duration_only() {
    schedule_validate(@schedule(0, 0, DAY, 0));
}

#[test]
#[should_panic(expected: 'Quest: invalid interval')]
#[available_gas(l2_gas: 16296)]
fn schedule_validate_rejects_duration_above_interval_at_max() {
    // The Dojo check multiplied two u64 and overflowed here (D-12): this is a named error
    schedule_validate(@schedule(0, 0, U32_MAX, U32_MAX - 1));
}

// schedule_is_active

#[test]
#[available_gas(l2_gas: 16737)]
fn schedule_is_active_one_off_window() {
    let s = schedule(100, 200, 0, 0);
    assert!(!schedule_is_active(@s, 0));
    assert!(!schedule_is_active(@s, 99));
    assert!(schedule_is_active(@s, 100));
    assert!(schedule_is_active(@s, 199));
    assert!(!schedule_is_active(@s, 200));
    assert!(!schedule_is_active(@s, U64_MAX));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_is_active_never_ends_when_end_is_zero() {
    let s = schedule(100, 0, 0, 0);
    assert!(!schedule_is_active(@s, 99));
    assert!(schedule_is_active(@s, 100));
    assert!(schedule_is_active(@s, U64_MAX));
    assert!(schedule_is_active(@one_off(), 0));
    assert!(schedule_is_active(@one_off(), U64_MAX));
}

#[test]
#[available_gas(l2_gas: 17052)]
fn schedule_is_active_recurring() {
    // active 10 s in every 60 s from 1000, until 1000 + 3 * 60
    let s = schedule(1000, 1180, 10, 60);
    assert!(!schedule_is_active(@s, 999));
    assert!(schedule_is_active(@s, 1000));
    assert!(schedule_is_active(@s, 1009));
    assert!(!schedule_is_active(@s, 1010));
    assert!(!schedule_is_active(@s, 1059));
    assert!(schedule_is_active(@s, 1060));
    assert!(schedule_is_active(@s, 1129));
    assert!(!schedule_is_active(@s, 1130));
    assert!(!schedule_is_active(@s, 1180));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_is_active_duration_equal_to_interval_is_always_active() {
    let s = daily();
    assert!(schedule_is_active(@s, 0));
    assert!(schedule_is_active(@s, 86399));
    assert!(schedule_is_active(@s, 86400));
    assert!(schedule_is_active(@s, U64_MAX));
}

// schedule_interval_id

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_interval_id_one_off_is_zero() {
    let s = schedule(100, 200, 0, 0);
    assert!(schedule_interval_id(@s, 100) == Some(0));
    assert!(schedule_interval_id(@s, 199) == Some(0));
    assert!(schedule_interval_id(@one_off(), U64_MAX) == Some(0));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_interval_id_none_when_inactive() {
    let s = schedule(1000, 1180, 10, 60);
    assert!(schedule_interval_id(@s, 0) == None);
    assert!(schedule_interval_id(@s, 999) == None);
    assert!(schedule_interval_id(@s, 1010) == None);
    assert!(schedule_interval_id(@s, 1180) == None);
    assert!(schedule_interval_id(@s, U64_MAX) == None);
    assert!(schedule_interval_id(@schedule(100, 200, 0, 0), 200) == None);
}

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_interval_id_recurring() {
    let s = schedule(1000, 1180, 10, 60);
    assert!(schedule_interval_id(@s, 1000) == Some(0));
    assert!(schedule_interval_id(@s, 1009) == Some(0));
    assert!(schedule_interval_id(@s, 1060) == Some(1));
    assert!(schedule_interval_id(@s, 1129) == Some(2));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn quest_daily_interval_aligned_on_utc_midnight() {
    let s = daily();
    assert!(schedule_interval_id(@s, 0) == Some(0));
    assert!(schedule_interval_id(@s, 86400 - 1) == Some(0));
    assert!(schedule_interval_id(@s, 86400) == Some(1));
    assert!(schedule_interval_id(@s, 86400 * 2 - 1) == Some(1));
    assert!(schedule_interval_id(@s, 86400 * 2) == Some(2));
    assert!(schedule_interval_id(@s, 86400 * 365 - 1) == Some(364));
    assert!(schedule_interval_id(@s, 86400 * 365) == Some(365));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn quest_interval_id_is_u64() {
    let s = schedule(0, 0, 1, 1);
    assert!(schedule_interval_id(@s, 0x10000000000) == Some(0x10000000000));
    assert!(schedule_interval_id(@s, 0x100000000) == Some(0x100000000));
    assert!(schedule_interval_id(@s, U64_MAX) == Some(U64_MAX));
}

#[test]
#[available_gas(l2_gas: 14406)]
fn schedule_interval_id_never_panics_at_the_bounds() {
    assert!(schedule_interval_id(@schedule(U64_MAX, 0, 1, 1), 0) == None);
    assert!(schedule_interval_id(@schedule(U64_MAX, 0, 1, 1), U64_MAX) == Some(0));
    assert!(schedule_interval_id(@schedule(0, 0, U32_MAX, U32_MAX), U64_MAX) == Some(0x100000001));
    // (2^64 - 2) mod (2^32 - 1) = 2^32 - 2: past the one active second
    assert!(schedule_interval_id(@schedule(0, 0, 1, U32_MAX), U64_MAX - 1) == None);
    assert!(schedule_interval_id(@schedule(0, 0, 1, U32_MAX), U64_MAX) == Some(0x100000001));
}
