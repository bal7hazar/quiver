//! A player's record of a quest across intervals: prerequisites, completion, acceptance and
//! claim (ARC-01 §3.2).

use core::num::traits::SaturatingAdd;
use crate::errors;
use super::types::{QuestProgress, QuestRecord};

/// Every record has `completions > 0`. The component passes one record per condition: at most
/// `MAX_CONDITIONS`.
pub fn prerequisites_met(records: Span<QuestRecord>) -> bool {
    let mut records = records;
    while let Some(record) = records.pop_front() {
        if *record.completions == 0 {
            return false;
        }
    }
    true
}

/// `record.active && record.accepted_interval == interval_id`: an acceptance holds only in the
/// interval in which it was made.
pub fn record_is_accepted(record: @QuestRecord, interval_id: u64) -> bool {
    *record.active && *record.accepted_interval == interval_id
}

/// `completions + 1`, saturating at `2^64 - 1`; releases the acceptance (`active = false`).
pub fn record_complete(record: QuestRecord) -> QuestRecord {
    QuestRecord { completions: record.completions.saturating_add(1), active: false, ..record }
}

/// Panics `'Quest: already accepted'` if accepted in `interval_id`; otherwise accepts in
/// `interval_id`, replacing an acceptance that expired in an earlier interval.
pub fn record_accept(record: QuestRecord, interval_id: u64) -> QuestRecord {
    assert(!record_is_accepted(@record, interval_id), errors::ALREADY_ACCEPTED);
    QuestRecord { active: true, accepted_interval: interval_id, ..record }
}

/// Panics `'Quest: not accepted'` unless accepted in `interval_id`; sets `active = false`.
pub fn record_abandon(record: QuestRecord, interval_id: u64) -> QuestRecord {
    assert(record_is_accepted(@record, interval_id), errors::NOT_ACCEPTED);
    QuestRecord { active: false, ..record }
}

/// Claims a completed interval. Returns `(progress, record, claim_index)`, where `claim_index` is
/// `record.claims` before the claim (0 for the first). `claims + 1` saturates at `2^64 - 1`.
/// Panics `'Quest: not completed'`, then `'Quest: already claimed'`.
pub fn claim(progress: QuestProgress, record: QuestRecord) -> (QuestProgress, QuestRecord, u64) {
    assert(progress.completed, errors::NOT_COMPLETED);
    assert(!progress.claimed, errors::ALREADY_CLAIMED);
    let claim_index = record.claims;
    (
        QuestProgress { claimed: true, ..progress },
        QuestRecord { claims: claim_index.saturating_add(1), ..record },
        claim_index,
    )
}
