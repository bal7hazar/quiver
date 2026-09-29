//! Windows: validation, and the rule an indexer applies (ARC-01 §3.10).

use crate::errors;
use super::types::AchievementWindow;

/// Panics `'Achievement: invalid window'` unless `end == 0` (never ends) or `end > start`: an
/// empty window (`end == start`) is refused, as in both modes of the Dojo package (D-11).
pub fn window_validate(window: @AchievementWindow) {
    let AchievementWindow { start, end } = *window;
    assert(end == 0 || end > start, errors::INVALID_WINDOW);
}

/// Whether `time` is in the window: `start <= time` and (`end == 0` or `time < end`).
///
/// The component does not call it: progress reads no definition. It states the rule by which an
/// indexer counts an `AchievementProgressed` towards an achievement, from the block's timestamp.
pub fn window_is_active(window: @AchievementWindow, time: u64) -> bool {
    let AchievementWindow { start, end } = *window;
    start <= time && (end == 0 || time < end)
}
