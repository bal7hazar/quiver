use quiver_quest::constants::{
    HELD_SLOTS, MAX_CONDITIONS, MAX_ENTRIES, MAX_HELD, MAX_HELD_LIMIT, MAX_TASKS,
};

#[test]
#[available_gas(l2_gas: 14406)]
fn quest_bounds_are_the_accepted_ones() {
    assert!(MAX_TASKS == 3);
    assert!(MAX_CONDITIONS == 7);
    assert!(MAX_ENTRIES == 16);
    // D-135: 4 held quests, at most 8, in slots of 2 entries
    assert!(MAX_HELD == 4);
    assert!(MAX_HELD <= MAX_HELD_LIMIT);
    assert!(MAX_HELD_LIMIT == 8);
    assert!(HELD_SLOTS * 2 == MAX_HELD_LIMIT);
}
