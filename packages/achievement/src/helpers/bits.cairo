//! Bits (D-143: a helper, what belongs to no entity): the powers of two of the packings of ARC-01
//! §3.11, the split of a felt into its limbs, and the packing errors. A shift is a multiplication
//! (packing, on felts) or a division with remainder (unpacking, on `u128` limbs) by an entry of
//! these tables (docs/CAIRO.md §3). The tables are free constants: a constant table is what §7
//! leaves outside a trait.

// Errors

/// Not errors of the API: the component never packs or reads such a value. A field narrower than
/// its Cairo type is checked against its bound before packing; unpacking rejects a felt with a
/// bit set outside the encoding, a corruption.
pub mod errors {
    pub const PACKING_FIELD_OUT_OF_RANGE: felt252 = 'Packing: field out of range';
    pub const PACKING_RESERVED_BITS_SET: felt252 = 'Packing: reserved bits set';
}

// Constants

// Multipliers, as felts: the bit offset of a field in the packed felt.
pub const TWO_POW_32: felt252 = 0x100000000;
pub const TWO_POW_64: felt252 = 0x10000000000000000;
pub const TWO_POW_96: felt252 = 0x1000000000000000000000000;
pub const TWO_POW_128: felt252 = 0x100000000000000000000000000000000;
pub const TWO_POW_130: felt252 = 0x400000000000000000000000000000000;
pub const TWO_POW_131: felt252 = 0x800000000000000000000000000000000;
pub const TWO_POW_132: felt252 = 0x1000000000000000000000000000000000;
pub const TWO_POW_164: felt252 = 0x100000000000000000000000000000000000000000;
pub const TWO_POW_196: felt252 = 0x10000000000000000000000000000000000000000000000000;

// Divisors, as non-zero `u128`: the width of a field within a `u128` limb.
pub const NZ_2: NonZero<u128> = 0x2;
pub const NZ_4: NonZero<u128> = 0x4;
pub const NZ_2_32: NonZero<u128> = 0x100000000;
pub const NZ_2_64: NonZero<u128> = 0x10000000000000000;

pub const NZ_128: NonZero<u32> = 128;

/// `POW2[i] = 2^i`, i = 0..128: the bit of a task in the mask of `BatchTrait::merge`.
pub const POW2: [u128; 128] = [
    0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000,
    0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000, 0x200000, 0x400000, 0x800000, 0x1000000,
    0x2000000, 0x4000000, 0x8000000, 0x10000000, 0x20000000, 0x40000000, 0x80000000, 0x100000000,
    0x200000000, 0x400000000, 0x800000000, 0x1000000000, 0x2000000000, 0x4000000000, 0x8000000000,
    0x10000000000, 0x20000000000, 0x40000000000, 0x80000000000, 0x100000000000, 0x200000000000,
    0x400000000000, 0x800000000000, 0x1000000000000, 0x2000000000000, 0x4000000000000,
    0x8000000000000, 0x10000000000000, 0x20000000000000, 0x40000000000000, 0x80000000000000,
    0x100000000000000, 0x200000000000000, 0x400000000000000, 0x800000000000000, 0x1000000000000000,
    0x2000000000000000, 0x4000000000000000, 0x8000000000000000, 0x10000000000000000,
    0x20000000000000000, 0x40000000000000000, 0x80000000000000000, 0x100000000000000000,
    0x200000000000000000, 0x400000000000000000, 0x800000000000000000, 0x1000000000000000000,
    0x2000000000000000000, 0x4000000000000000000, 0x8000000000000000000, 0x10000000000000000000,
    0x20000000000000000000, 0x40000000000000000000, 0x80000000000000000000, 0x100000000000000000000,
    0x200000000000000000000, 0x400000000000000000000, 0x800000000000000000000,
    0x1000000000000000000000, 0x2000000000000000000000, 0x4000000000000000000000,
    0x8000000000000000000000, 0x10000000000000000000000, 0x20000000000000000000000,
    0x40000000000000000000000, 0x80000000000000000000000, 0x100000000000000000000000,
    0x200000000000000000000000, 0x400000000000000000000000, 0x800000000000000000000000,
    0x1000000000000000000000000, 0x2000000000000000000000000, 0x4000000000000000000000000,
    0x8000000000000000000000000, 0x10000000000000000000000000, 0x20000000000000000000000000,
    0x40000000000000000000000000, 0x80000000000000000000000000, 0x100000000000000000000000000,
    0x200000000000000000000000000, 0x400000000000000000000000000, 0x800000000000000000000000000,
    0x1000000000000000000000000000, 0x2000000000000000000000000000, 0x4000000000000000000000000000,
    0x8000000000000000000000000000, 0x10000000000000000000000000000,
    0x20000000000000000000000000000, 0x40000000000000000000000000000,
    0x80000000000000000000000000000, 0x100000000000000000000000000000,
    0x200000000000000000000000000000, 0x400000000000000000000000000000,
    0x800000000000000000000000000000, 0x1000000000000000000000000000000,
    0x2000000000000000000000000000000, 0x4000000000000000000000000000000,
    0x8000000000000000000000000000000, 0x10000000000000000000000000000000,
    0x20000000000000000000000000000000, 0x40000000000000000000000000000000,
    0x80000000000000000000000000000000,
];

// Implementations

#[generate_trait]
pub impl BitsImpl of BitsTrait {
    /// The two `u128` limbs of a felt, `(low, high)`: bits [0, 128) and [128, 252).
    ///
    /// Why `u256` appears here: converting a felt to `u256` is the `u128s_from_felt252` libfunc
    /// and nothing else, and it is the only public way in the corelib to split a felt into its
    /// limbs. No `u256` arithmetic is done; the fields are then read from the limbs with `u128`
    /// division and remainder. No field of §3.11 straddles bit 128.
    #[inline(always)]
    fn split(value: felt252) -> (u128, u128) {
        let u256 { low, high } = value.into();
        (low, high)
    }
}

/// Every table entry against a value computed by doubling: `POW2[i] == 2^i` for each `i`, and each
/// `TWO_POW_*` and `NZ_*` constant at its power.
#[cfg(test)]
mod tests {
    use super::{
        BitsTrait, NZ_128, NZ_2, NZ_2_32, NZ_2_64, NZ_4, POW2, TWO_POW_128, TWO_POW_130,
        TWO_POW_131, TWO_POW_132, TWO_POW_164, TWO_POW_196, TWO_POW_32, TWO_POW_64, TWO_POW_96,
    };

    /// 2^n as a felt, by doubling.
    fn felt_pow2(n: u32) -> felt252 {
        let mut value: felt252 = 1;
        let mut i = 0;
        while i < n {
            value = value * 2;
            i += 1;
        }
        value
    }

    /// 2^n as a `u128`, by doubling; n < 128.
    fn u128_pow2(n: u32) -> u128 {
        let mut value: u128 = 1;
        let mut i = 0;
        while i < n {
            value = value * 2;
            i += 1;
        }
        value
    }

    #[test]
    #[available_gas(l2_gas: 986885)]
    fn pow2_table_is_two_to_the_index() {
        let table = POW2.span();
        assert!(table.len() == 128);
        let mut expected: u128 = 1;
        let mut i: u32 = 0;
        while i < 128 {
            assert!(*table[i] == expected, "POW2[{}]", i);
            if i < 127 {
                expected = expected * 2;
            }
            i += 1;
        }
    }

    #[test]
    #[available_gas(l2_gas: 2092188)]
    fn two_pow_constants_are_their_powers() {
        assert!(TWO_POW_32 == felt_pow2(32));
        assert!(TWO_POW_64 == felt_pow2(64));
        assert!(TWO_POW_96 == felt_pow2(96));
        assert!(TWO_POW_128 == felt_pow2(128));
        assert!(TWO_POW_130 == felt_pow2(130));
        assert!(TWO_POW_131 == felt_pow2(131));
        assert!(TWO_POW_132 == felt_pow2(132));
        assert!(TWO_POW_164 == felt_pow2(164));
        assert!(TWO_POW_196 == felt_pow2(196));
    }

    #[test]
    #[available_gas(l2_gas: 541118)]
    fn nz_constants_are_their_powers() {
        let nz_2: u128 = NZ_2.into();
        let nz_4: u128 = NZ_4.into();
        let nz_2_32: u128 = NZ_2_32.into();
        let nz_2_64: u128 = NZ_2_64.into();
        let nz_128: u32 = NZ_128.into();
        assert!(nz_2 == u128_pow2(1));
        assert!(nz_4 == u128_pow2(2));
        assert!(nz_2_32 == u128_pow2(32));
        assert!(nz_2_64 == u128_pow2(64));
        assert!(nz_128 == 128);
    }

    /// Both limbs set: `low + high × 2^128` splits into `(low, high)`, the high limb at its
    /// widest below 2^123 (a felt is below 2^251 + 17 × 2^192 + 1).
    #[test]
    #[available_gas(l2_gas: 10101)]
    fn split_both_limbs() {
        let low: u128 = 0xfedcba9876543210fedcba9876543210;
        let high: u128 = 0x7ffffffffffffffffffffffffffffff;
        let value: felt252 = low.into() + high.into() * TWO_POW_128;
        assert!(BitsTrait::split(value) == (low, high));
    }

    /// The high limb zero: a felt below 2^128 is its own low limb.
    #[test]
    #[available_gas(l2_gas: 10133)]
    fn split_high_limb_zero() {
        let low: u128 = 0xffffffffffffffffffffffffffffffff;
        assert!(BitsTrait::split(low.into()) == (low, 0));
        assert!(BitsTrait::split(0) == (0, 0));
    }
}
