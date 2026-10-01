//! A quest's schedule (ARC-01 §3.2): its window and its intervals. Stored in slot A with the
//! definition (`crate::models::definition`), never on its own.

// Types

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

// Errors

/// The strings of 0.1.0 (`crate::errors`), which are API.
pub mod errors {
    pub const SCHEDULE_INVALID_WINDOW: felt252 = crate::errors::INVALID_WINDOW;
    pub const SCHEDULE_INVALID_INTERVAL: felt252 = crate::errors::INVALID_INTERVAL;
}

// Implementations

#[generate_trait]
pub impl ScheduleImpl of ScheduleTrait {
    /// `start <= time && (end == 0 || time < end) && (interval == 0 || (time - start) %
    /// interval < duration)`.
    fn is_active(self: @QuestSchedule, time: u64) -> bool {
        let schedule = *self;
        if time < schedule.start || (schedule.end != 0 && time >= schedule.end) {
            return false;
        }
        let interval: u64 = schedule.interval.into();
        match interval.try_into() {
            Option::None => true,
            Option::Some(interval) => {
                let (_, offset) = DivRem::div_rem(time - schedule.start, interval);
                offset < schedule.duration.into()
            },
        }
    }

    /// `None` when inactive (never panics); `Some(0)` for a one-off quest;
    /// `Some((time - start) / interval)` otherwise. The id is below `time < 2^64`: no overflow.
    fn interval_id(self: @QuestSchedule, time: u64) -> Option<u64> {
        let schedule = *self;
        if time < schedule.start || (schedule.end != 0 && time >= schedule.end) {
            return None;
        }
        let interval: u64 = schedule.interval.into();
        match interval.try_into() {
            Option::None => Some(0),
            Option::Some(interval) => {
                let (id, offset) = DivRem::div_rem(time - schedule.start, interval);
                if offset < schedule.duration.into() {
                    Some(id)
                } else {
                    None
                }
            },
        }
    }
}

#[generate_trait]
pub impl ScheduleAssert of AssertTrait {
    /// `'Quest: invalid window'` unless `end == 0 || end > start`, then `'Quest: invalid
    /// interval'` unless `duration == interval == 0` (one-off) or `0 < duration <= interval`.
    #[inline]
    fn assert_valid(self: @QuestSchedule) {
        let schedule = *self;
        assert(schedule.end == 0 || schedule.end > schedule.start, errors::SCHEDULE_INVALID_WINDOW);
        let valid_interval = if schedule.duration == 0 {
            schedule.interval == 0
        } else {
            schedule.duration <= schedule.interval
        };
        assert(valid_interval, errors::SCHEDULE_INVALID_INTERVAL);
    }
}

#[cfg(test)]
mod tests {
    use crate::testing::helpers::{
        DAY, U32_MAX, U64_MAX, daily, one_off, opaque, recurring, schedule,
    };
    use super::{ScheduleAssert, ScheduleTrait};

    // schedule_validate

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_validate_accepts_valid_schedules() {
        ScheduleAssert::assert_valid(@one_off());
        ScheduleAssert::assert_valid(@daily());
        ScheduleAssert::assert_valid(@schedule(100, 0, 0, 0));
        ScheduleAssert::assert_valid(@schedule(100, 101, 0, 0));
        ScheduleAssert::assert_valid(@schedule(100, 200, 10, 60));
        // duration == interval: active through every interval
        ScheduleAssert::assert_valid(@schedule(0, 0, 1, 1));
        ScheduleAssert::assert_valid(@schedule(U64_MAX - 1, U64_MAX, U32_MAX, U32_MAX));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid window')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_empty_window() {
        ScheduleAssert::assert_valid(@schedule(100, 100, 0, 0));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid window')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_end_before_start() {
        ScheduleAssert::assert_valid(@schedule(100, 99, 0, 0));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_duration_above_interval() {
        ScheduleAssert::assert_valid(@schedule(0, 0, 2, 1));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_half_recurring_interval_only() {
        ScheduleAssert::assert_valid(@schedule(0, 0, 0, DAY));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_half_recurring_duration_only() {
        ScheduleAssert::assert_valid(@schedule(0, 0, DAY, 0));
    }

    #[test]
    #[should_panic(expected: 'Quest: invalid interval')]
    #[available_gas(l2_gas: 16296)]
    fn schedule_validate_rejects_duration_above_interval_at_max() {
        // The Dojo check multiplied two u64 and overflowed here (D-12): this is a named error
        ScheduleAssert::assert_valid(@schedule(0, 0, U32_MAX, U32_MAX - 1));
    }

    // schedule_is_active

    #[test]
    #[available_gas(l2_gas: 16737)]
    fn schedule_is_active_one_off_window() {
        let s = schedule(100, 200, 0, 0);
        assert!(!ScheduleTrait::is_active(@s, 0));
        assert!(!ScheduleTrait::is_active(@s, 99));
        assert!(ScheduleTrait::is_active(@s, 100));
        assert!(ScheduleTrait::is_active(@s, 199));
        assert!(!ScheduleTrait::is_active(@s, 200));
        assert!(!ScheduleTrait::is_active(@s, U64_MAX));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_is_active_never_ends_when_end_is_zero() {
        let s = schedule(100, 0, 0, 0);
        assert!(!ScheduleTrait::is_active(@s, 99));
        assert!(ScheduleTrait::is_active(@s, 100));
        assert!(ScheduleTrait::is_active(@s, U64_MAX));
        assert!(ScheduleTrait::is_active(@one_off(), 0));
        assert!(ScheduleTrait::is_active(@one_off(), U64_MAX));
    }

    #[test]
    #[available_gas(l2_gas: 17052)]
    fn schedule_is_active_recurring() {
        // active 10 s in every 60 s from 1000, until 1000 + 3 * 60
        let s = schedule(1000, 1180, 10, 60);
        assert!(!ScheduleTrait::is_active(@s, 999));
        assert!(ScheduleTrait::is_active(@s, 1000));
        assert!(ScheduleTrait::is_active(@s, 1009));
        assert!(!ScheduleTrait::is_active(@s, 1010));
        assert!(!ScheduleTrait::is_active(@s, 1059));
        assert!(ScheduleTrait::is_active(@s, 1060));
        assert!(ScheduleTrait::is_active(@s, 1129));
        assert!(!ScheduleTrait::is_active(@s, 1130));
        assert!(!ScheduleTrait::is_active(@s, 1180));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_is_active_duration_equal_to_interval_is_always_active() {
        let s = daily();
        assert!(ScheduleTrait::is_active(@s, 0));
        assert!(ScheduleTrait::is_active(@s, 86399));
        assert!(ScheduleTrait::is_active(@s, 86400));
        assert!(ScheduleTrait::is_active(@s, U64_MAX));
    }

    // schedule_interval_id

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_interval_id_one_off_is_zero() {
        let s = schedule(100, 200, 0, 0);
        assert!(ScheduleTrait::interval_id(@s, 100) == Some(0));
        assert!(ScheduleTrait::interval_id(@s, 199) == Some(0));
        assert!(ScheduleTrait::interval_id(@one_off(), U64_MAX) == Some(0));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_interval_id_none_when_inactive() {
        let s = schedule(1000, 1180, 10, 60);
        assert!(ScheduleTrait::interval_id(@s, 0) == None);
        assert!(ScheduleTrait::interval_id(@s, 999) == None);
        assert!(ScheduleTrait::interval_id(@s, 1010) == None);
        assert!(ScheduleTrait::interval_id(@s, 1180) == None);
        assert!(ScheduleTrait::interval_id(@s, U64_MAX) == None);
        assert!(ScheduleTrait::interval_id(@schedule(100, 200, 0, 0), 200) == None);
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_interval_id_recurring() {
        let s = schedule(1000, 1180, 10, 60);
        assert!(ScheduleTrait::interval_id(@s, 1000) == Some(0));
        assert!(ScheduleTrait::interval_id(@s, 1009) == Some(0));
        assert!(ScheduleTrait::interval_id(@s, 1060) == Some(1));
        assert!(ScheduleTrait::interval_id(@s, 1129) == Some(2));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn quest_daily_interval_aligned_on_utc_midnight() {
        let s = daily();
        assert!(ScheduleTrait::interval_id(@s, 0) == Some(0));
        assert!(ScheduleTrait::interval_id(@s, 86400 - 1) == Some(0));
        assert!(ScheduleTrait::interval_id(@s, 86400) == Some(1));
        assert!(ScheduleTrait::interval_id(@s, 86400 * 2 - 1) == Some(1));
        assert!(ScheduleTrait::interval_id(@s, 86400 * 2) == Some(2));
        assert!(ScheduleTrait::interval_id(@s, 86400 * 365 - 1) == Some(364));
        assert!(ScheduleTrait::interval_id(@s, 86400 * 365) == Some(365));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn quest_interval_id_is_u64() {
        let s = schedule(0, 0, 1, 1);
        assert!(ScheduleTrait::interval_id(@s, 0x10000000000) == Some(0x10000000000));
        assert!(ScheduleTrait::interval_id(@s, 0x100000000) == Some(0x100000000));
        assert!(ScheduleTrait::interval_id(@s, U64_MAX) == Some(U64_MAX));
    }

    #[test]
    #[available_gas(l2_gas: 14406)]
    fn schedule_interval_id_never_panics_at_the_bounds() {
        assert!(ScheduleTrait::interval_id(@schedule(U64_MAX, 0, 1, 1), 0) == None);
        assert!(ScheduleTrait::interval_id(@schedule(U64_MAX, 0, 1, 1), U64_MAX) == Some(0));
        assert!(
            ScheduleTrait::interval_id(
                @schedule(0, 0, U32_MAX, U32_MAX), U64_MAX,
            ) == Some(0x100000001),
        );
        // (2^64 - 2) mod (2^32 - 1) = 2^32 - 2: past the one active second
        assert!(ScheduleTrait::interval_id(@schedule(0, 0, 1, U32_MAX), U64_MAX - 1) == None);
        assert!(
            ScheduleTrait::interval_id(@schedule(0, 0, 1, U32_MAX), U64_MAX) == Some(0x100000001),
        );
    }

    // schedule

    #[test]
    #[available_gas(l2_gas: 18354)]
    fn bench_schedule_validate() {
        ScheduleAssert::assert_valid(@recurring());
    }

    #[test]
    #[available_gas(l2_gas: 20192)]
    fn bench_schedule_is_active() {
        assert!(ScheduleTrait::is_active(@recurring(), opaque(1000 + 86400 * 30 + 10)));
    }

    #[test]
    #[available_gas(l2_gas: 21137)]
    fn bench_schedule_interval_id() {
        assert!(
            ScheduleTrait::interval_id(@recurring(), opaque(1000 + 86400 * 30 + 10)) == Some(30),
        );
    }
}
