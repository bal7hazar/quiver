//! A reporter (ARC-01 §3.11): a contract allowed or not to report progress. The model's checks,
//! its errors and its tracking. Stored as one `bool` per address, as in 0.1.0; tracked:
//! `AchievementReporterSet` carries its key and its one value.

// Internal imports

use crate::events::reporter_set::{AchievementReporterSet, ReporterSetTrait};
pub use crate::models::index::AchievementReporter;
use crate::store::Tracked;

// Errors

/// The string of 0.1.0 (`crate::errors`), which is API.
pub mod errors {
    pub const REPORTER_NOT_ALLOWED: felt252 = crate::errors::NOT_REPORTER;
}

// Implementations

#[generate_trait]
pub impl ReporterAssert of AssertTrait {
    /// `'Achievement: not reporter'` unless allowed. By value: by snapshot costs 5 steps more on
    /// every progress call (measured, ARC-07b).
    #[inline(always)]
    fn assert_is_allowed(self: AchievementReporter) {
        assert(self.allowed, errors::REPORTER_NOT_ALLOWED);
    }
}

/// Tracked (D-143): the indexer reads `AchievementReporterSet`, which `Store::set_reporter` emits
/// on every write when the consumer tracks reporters (`AchievementTracking::REPORTER`).
pub impl ReporterTracked of Tracked<AchievementReporter> {
    type Event = AchievementReporterSet;

    #[inline]
    fn event(self: @AchievementReporter) -> AchievementReporterSet {
        ReporterSetTrait::new(self)
    }
}

#[cfg(test)]
mod tests {
    use super::{AchievementReporter, ReporterAssert};

    fn reporter(allowed: bool) -> AchievementReporter {
        AchievementReporter { reporter: 'reporter'.try_into().unwrap(), allowed }
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn reporter_allowed_passes() {
        reporter(true).assert_is_allowed();
    }

    #[test]
    #[should_panic(expected: 'Achievement: not reporter')]
    #[available_gas(l2_gas: 8201)]
    fn reporter_refused_reverts_not_reporter() {
        reporter(false).assert_is_allowed();
    }
}
