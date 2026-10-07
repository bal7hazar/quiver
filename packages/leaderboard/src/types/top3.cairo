//! The three ranks of a tournament.

use super::ranked::Ranked;

#[derive(Copy, Drop, Serde, PartialEq, Debug, Default)]
pub struct Top3 {
    pub first: Ranked,
    pub second: Ranked,
    pub third: Ranked,
}
