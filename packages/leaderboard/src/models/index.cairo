//! The structs of every model, together (docs/CAIRO.md §7), with their packing: the compiler
//! looks for `StorePacking<Scores, _>` in the module of `Scores`, so the impl stays here.

/// The three scores of a tournament, one storage slot (`ScoresSlot`): rank 1 in bits [0, 32), rank
/// 2 in [32, 64), rank 3 in [64, 96), bits [96, 252) zero. A rank that holds nobody scores 0.
#[derive(Copy, Drop, Serde, PartialEq, Debug, Default)]
pub struct Scores {
    pub first: u32,
    pub second: u32,
    pub third: u32,
}

const POW32: felt252 = 0x100000000;
const POW64: felt252 = 0x10000000000000000;
const NZ_POW32: NonZero<u128> = 0x100000000;

/// The slot of a tournament's scores: the three scores packed in one felt (`Scores`).
pub impl ScoresStorePacking of starknet::storage_access::StorePacking<Scores, felt252> {
    fn pack(value: Scores) -> felt252 {
        let Scores { first, second, third } = value;
        let first: felt252 = first.into();
        let second: felt252 = second.into();
        let third: felt252 = third.into();
        first + second * POW32 + third * POW64
    }

    fn unpack(value: felt252) -> Scores {
        // The word is below 2^96, so it fits a u128; a word above (nobody writes one) fails here.
        let word: u128 = value.try_into().unwrap();
        let (rest, first) = DivRem::div_rem(word, NZ_POW32);
        let (third, second) = DivRem::div_rem(rest, NZ_POW32);
        Scores {
            first: first.try_into().unwrap(),
            second: second.try_into().unwrap(),
            third: third.try_into().unwrap(),
        }
    }
}
