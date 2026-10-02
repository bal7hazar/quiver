//! An achievement's window (ARC-01 §3.10): when it counts. Stored in slot A with the definition
//! (`crate::models::definition`), never on its own.

// Types

/// When an achievement counts: `start <= time` and (`end == 0` or `time < end`).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementWindow {
    /// First second; 0 = from the epoch.
    pub start: u64,
    /// First second after; 0 = never ends.
    pub end: u64,
}

// Errors

/// The string of 0.1.0 (`crate::errors`), which is API.
pub mod errors {
    pub const WINDOW_INVALID: felt252 = crate::errors::INVALID_WINDOW;
}

// Implementations

#[generate_trait]
pub impl WindowImpl of WindowTrait {
    /// Whether `time` is in the window: `start <= time` and (`end == 0` or `time < end`).
    ///
    /// The component does not call it: progress reads no definition. It states the rule by which
    /// an indexer counts an `AchievementProgressed` towards an achievement, from the block's
    /// timestamp.
    fn is_active(self: @AchievementWindow, time: u64) -> bool {
        let AchievementWindow { start, end } = *self;
        start <= time && (end == 0 || time < end)
    }
}

#[generate_trait]
pub impl WindowAssert of AssertTrait {
    /// `'Achievement: invalid window'` unless `end == 0` (never ends) or `end > start`: an empty
    /// window (`end == start`) is refused, as in both modes of the Dojo package (D-11).
    #[inline(always)]
    fn assert_valid(self: @AchievementWindow) {
        let AchievementWindow { start, end } = *self;
        assert(end == 0 || end > start, errors::WINDOW_INVALID);
    }
}

#[cfg(test)]
mod tests {
    use super::{AchievementWindow, WindowAssert, WindowTrait};

    const U64_MAX: u64 = 0xffffffffffffffff;

    fn window(start: u64, end: u64) -> AchievementWindow {
        AchievementWindow { start, end }
    }

    #[test]
    #[available_gas(l2_gas: 6311)]
    fn window_validate_accepts_open_and_ordered_windows() {
        window(0, 0).assert_valid();
        window(100, 0).assert_valid();
        window(0, 1).assert_valid();
        window(U64_MAX - 1, U64_MAX).assert_valid();
    }

    /// D-11: `end == start` is empty, refused.
    #[test]
    #[should_panic(expected: 'Achievement: invalid window')]
    #[available_gas(l2_gas: 8201)]
    fn window_validate_rejects_empty_window() {
        window(100, 100).assert_valid();
    }

    #[test]
    #[available_gas(l2_gas: 8201)]
    fn window_is_active_bounds() {
        let w = window(100, 200);
        assert!(!w.is_active(99));
        assert!(w.is_active(100));
        assert!(w.is_active(199));
        assert!(!w.is_active(200));
        assert!(window(0, 0).is_active(0));
        assert!(window(0, 0).is_active(U64_MAX));
        assert!(window(100, 0).is_active(U64_MAX));
        assert!(!window(100, 0).is_active(99));
    }
}
