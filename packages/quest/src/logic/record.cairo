//! A player's record of a quest across intervals: prerequisites, completion and claim (ARC-01
//! §3.2). Acceptance is the held list's (`super::held`).

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

/// `completions + 1`, saturating at `2^64 - 1`.
pub fn record_complete(record: QuestRecord) -> QuestRecord {
    QuestRecord { completions: record.completions.saturating_add(1), ..record }
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
