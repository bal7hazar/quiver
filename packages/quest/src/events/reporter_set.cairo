// Internal imports

pub use crate::events::index::QuestReporterSet;
use crate::models::index::QuestReporter;

// Implementations

#[generate_trait]
pub impl ReporterSetImpl of ReporterSetTrait {
    /// The key and the value of the reporter. It has no check of its own.
    #[inline(always)]
    fn new(reporter: @QuestReporter) -> QuestReporterSet {
        QuestReporterSet { reporter: *reporter.reporter, allowed: *reporter.allowed }
    }
}
