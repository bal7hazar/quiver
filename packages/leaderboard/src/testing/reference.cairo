//! The reference model of the rule: a plain list of three entries, the rule applied as written,
//! with no packing, no storage and no shortcut. The property test compares the package with it
//! after every step. Test code only.

use crate::types::ranked::Ranked;
use crate::types::submission::Submission;
use crate::types::top3::Top3;

#[derive(Copy, Drop, Default)]
pub struct Reference {
    pub first: Ranked,
    pub second: Ranked,
    pub third: Ranked,
}

#[generate_trait]
pub impl ReferenceImpl of ReferenceTrait {
    /// The rule: nothing for a score or a player of 0; not placed when the score is not above the
    /// third's; else the rank is 1 above the first, 2 above the second, 3 otherwise (an equal score
    /// goes below); the lower ranks shift down, the third falls out.
    fn apply(ref self: Reference, submission: Submission) -> u8 {
        if submission.score == 0 || submission.player_id == 0 {
            return 0;
        }
        if submission.score <= self.third.score {
            return 0;
        }
        let entry = Ranked { player_id: submission.player_id, score: submission.score };
        if submission.score > self.first.score {
            self = Reference { first: entry, second: self.first, third: self.second };
            1
        } else if submission.score > self.second.score {
            self = Reference { first: self.first, second: entry, third: self.second };
            2
        } else {
            self = Reference { first: self.first, second: self.second, third: entry };
            3
        }
    }

    fn board(self: @Reference) -> Top3 {
        Top3 { first: *self.first, second: *self.second, third: *self.third }
    }
}
