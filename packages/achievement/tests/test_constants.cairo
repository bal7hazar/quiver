use quiver_achievement::constants::{MAX_ENTRIES, MAX_TASKS};

#[test]
#[available_gas(l2_gas: 14406)]
fn achievement_bounds_are_the_accepted_ones() {
    assert!(MAX_TASKS == 3);
    assert!(MAX_ENTRIES == 16);
}
