use quiver_achievement::constants::{ACHIEVEMENTS_PER_PAGE, MAX_ENTRIES, MAX_PAGES, MAX_TASKS};

#[test]
#[available_gas(l2_gas: 14406)]
fn achievement_bounds_are_the_accepted_ones() {
    assert!(MAX_TASKS == 3);
    assert!(ACHIEVEMENTS_PER_PAGE == 7);
    assert!(MAX_PAGES == 4);
    assert!(MAX_ENTRIES == 16);
}
