// Internal imports

pub use crate::events::index::AchievementReporterSet;
use crate::models::index::AchievementReporter;

// Implementations

#[generate_trait]
pub impl ReporterSetImpl of ReporterSetTrait {
    /// The key and the value of the reporter. It has no check of its own.
    #[inline(always)]
    fn new(reporter: @AchievementReporter) -> AchievementReporterSet {
        AchievementReporterSet { reporter: *reporter.reporter, allowed: *reporter.allowed }
    }
}
