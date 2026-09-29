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
        assert(
            schedule.end == 0 || schedule.end > schedule.start, errors::SCHEDULE_INVALID_WINDOW,
        );
        let valid_interval = if schedule.duration == 0 {
            schedule.interval == 0
        } else {
            schedule.duration <= schedule.interval
        };
        assert(valid_interval, errors::SCHEDULE_INVALID_INTERVAL);
    }
}
