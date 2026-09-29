//! A reporter (ARC-01 §3.6): a contract allowed or not to report progress. The model's checks,
//! its errors and its tracking. Stored as one `bool` per address, as in 0.1.0; tracked:
//! `QuestReporterSet` carries its key and its one value.

// Internal imports

use crate::events::reporter_set::{QuestReporterSet, ReporterSetTrait};
pub use crate::models::index::QuestReporter;
use crate::store::Tracked;

// Errors

/// The string of 0.1.0 (`crate::errors`), which is API.
pub mod errors {
    pub const REPORTER_NOT_ALLOWED: felt252 = crate::errors::NOT_REPORTER;
}

// Implementations

#[generate_trait]
pub impl ReporterAssert of AssertTrait {
    /// `'Quest: not reporter'` unless allowed.
    #[inline(always)]
    fn assert_is_allowed(self: @QuestReporter) {
        assert(*self.allowed, errors::REPORTER_NOT_ALLOWED);
    }
}

/// Tracked (D-143): the indexer reads `QuestReporterSet`, which `Store::set_reporter` emits on
/// every write when the consumer tracks reporters (`QuestTracking::REPORTER`).
pub impl ReporterTracked of Tracked<QuestReporter> {
    type Event = QuestReporterSet;

    #[inline]
    fn event(self: @QuestReporter) -> QuestReporterSet {
        ReporterSetTrait::new(self)
    }
}
