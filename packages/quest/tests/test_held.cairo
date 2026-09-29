//! The held list's pure functions (ARC-01 §3.2, amended by D-135).

use quiver_quest::types::held::{HELD_EMPTY, HeldTrait};
use super::helpers::{held, held_slot as slot, held_slot0 as slot0, held_slot_of, stamped};

#[test]
#[available_gas(l2_gas: 40782)]
fn held_position_finds_the_quest() {
    let list = array![held(5, 0), held(9, 3), held(2, 3)].span();
    assert!(HeldTrait::position(list, 5) == Some(0));
    assert!(HeldTrait::position(list, 2) == Some(2));
    assert!(HeldTrait::position(list, 7) == None);
    assert!(HeldTrait::position(array![].span(), 5) == None);
}

#[test]
#[available_gas(l2_gas: 49739)]
fn held_contains_needs_the_same_interval() {
    let list = array![held(5, 0), held(9, 3)].span();
    assert!(HeldTrait::contains(list, held(9, 3)));
    // the same quest accepted in another interval is not this entry
    assert!(!HeldTrait::contains(list, held(9, 4)));
    // nor the same quest and interval under another acceptance number
    assert!(!HeldTrait::contains(list, stamped(9, 3, 1)));
    assert!(!HeldTrait::contains(list, held(7, 0)));
    assert!(!HeldTrait::contains(array![].span(), held(5, 0)));
}

#[test]
#[available_gas(l2_gas: 135629)]
fn held_remove_keeps_the_order() {
    let list = array![held(1, 0), held(2, 0), held(3, 0), held(4, 0)].span();
    assert!(HeldTrait::remove(list, 0) == array![held(2, 0), held(3, 0), held(4, 0)].span());
    assert!(HeldTrait::remove(list, 1) == array![held(1, 0), held(3, 0), held(4, 0)].span());
    assert!(HeldTrait::remove(list, 3) == array![held(1, 0), held(2, 0), held(3, 0)].span());
    // outside the list: unchanged
    assert!(HeldTrait::remove(list, 4) == list);
    assert!(HeldTrait::remove(array![held(1, 0)].span(), 0) == array![].span());
}

#[test]
#[available_gas(l2_gas: 21252)]
fn held_slot_pairs_entries_and_pads_with_empty() {
    let list = array![held(1, 10), held(2, 20), held(3, 30)].span();
    assert!(held_slot_of(list, 0, 7, true) == slot0(held(1, 10), held(2, 20), 7));
    // the counter is slot 0's only
    assert!(held_slot_of(list, 1, 7, true) == slot(held(3, 30), HELD_EMPTY));
    assert!(held_slot_of(list, 2, 7, false) == slot(HELD_EMPTY, HELD_EMPTY));
    assert!(HELD_EMPTY == held(0, 0));
}
