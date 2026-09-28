//! Schedules: validation, activity and interval ids (ARC-01 §3.2).

use crate::errors;
use super::types::QuestSchedule;

/// Panics `'Quest: invalid window'` unless `end == 0 || end > start`, and
/// `'Quest: invalid interval'` unless `duration == interval == 0` (one-off) or
/// `0 < duration <= interval`.
pub fn schedule_validate(schedule: @QuestSchedule) {
    let schedule = *schedule;
    assert(schedule.end == 0 || schedule.end > schedule.start, errors::INVALID_WINDOW);
    let valid_interval = if schedule.duration == 0 {
        schedule.interval == 0
    } else {
        schedule.duration <= schedule.interval
    };
    assert(valid_interval, errors::INVALID_INTERVAL);
}

/// `start <= time && (end == 0 || time < end) && (interval == 0 || (time - start) % interval <
/// duration)`.
pub fn schedule_is_active(schedule: @QuestSchedule, time: u64) -> bool {
    let schedule = *schedule;
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
pub fn schedule_interval_id(schedule: @QuestSchedule, time: u64) -> Option<u64> {
    let schedule = *schedule;
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
