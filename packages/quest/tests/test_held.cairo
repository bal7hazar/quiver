//! The held list's pure functions (ARC-01 §3.2, amended by D-135).

use quiver_quest::logic::{HELD_EMPTY, held_contains, held_position, held_remove, held_slot};
use super::helpers::{held, held_slot as slot};

#[test]
#[available_gas(l2_gas: 40152)]
fn held_position_finds_the_quest() {
    let list = array![held(5, 0), held(9, 3), held(2, 3)].span();
    assert!(held_position(list, 5) == Some(0));
    assert!(held_position(list, 2) == Some(2));
    assert!(held_position(list, 7) == None);
    assert!(held_position(array![].span(), 5) == None);
}

#[test]
#[available_gas(l2_gas: 39501)]
fn held_contains_needs_the_same_interval() {
    let list = array![held(5, 0), held(9, 3)].span();
    assert!(held_contains(list, held(9, 3)));
    // the same quest accepted in another interval is not this entry
    assert!(!held_contains(list, held(9, 4)));
    assert!(!held_contains(list, held(7, 0)));
    assert!(!held_contains(array![].span(), held(5, 0)));
}

#[test]
#[available_gas(l2_gas: 124058)]
fn held_remove_keeps_the_order() {
    let list = array![held(1, 0), held(2, 0), held(3, 0), held(4, 0)].span();
    assert!(held_remove(list, 0) == array![held(2, 0), held(3, 0), held(4, 0)].span());
    assert!(held_remove(list, 1) == array![held(1, 0), held(3, 0), held(4, 0)].span());
    assert!(held_remove(list, 3) == array![held(1, 0), held(2, 0), held(3, 0)].span());
    // outside the list: unchanged
    assert!(held_remove(list, 4) == list);
    assert!(held_remove(array![held(1, 0)].span(), 0) == array![].span());
}

#[test]
#[available_gas(l2_gas: 19992)]
fn held_slot_pairs_entries_and_pads_with_empty() {
    let list = array![held(1, 10), held(2, 20), held(3, 30)].span();
    assert!(held_slot(list, 0) == slot(held(1, 10), held(2, 20)));
    assert!(held_slot(list, 1) == slot(held(3, 30), HELD_EMPTY));
    assert!(held_slot(list, 2) == slot(HELD_EMPTY, HELD_EMPTY));
    assert!(HELD_EMPTY == held(0, 0));
}
