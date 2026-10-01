//! Models: every stored entity of `quiver_achievement`, its keys first. Each is read and written
//! only through the store (`crate::store`); its file holds its behaviour, its checks, its errors
//! and its storage. Tracked models (`Tracked`): `AchievementDefinition`, `AchievementReporter`.
//! `AchievementStatus` is untracked and emits nothing when written
//! (docs/research/ARC-06-model-store.md §6). Progress is not a model: in event mode nothing of it
//! is stored.

use starknet::ContractAddress;
use crate::types::task::AchievementTask;
use crate::types::window::AchievementWindow;

/// An achievement, as `define` wrote it; it never changes afterwards. Tracked:
/// `Store::set_definition` emits `AchievementDefined` on every write, when the consumer tracks it.
/// Stored in the slots A and B of 0.1.0, with `points` in bits [196, 212) of A
/// (`crate::models::definition`, `DefinitionStorage`). An achievement not defined reads with no
/// task.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementDefinition {
    /// Key.
    pub id: u32,
    pub window: AchievementWindow,
    /// 1 to `MAX_TASKS` tasks, ids distinct and non-zero, totals non-zero.
    pub tasks: Span<AchievementTask>,
    /// Shown, never read by a rule.
    pub points: u16,
}

/// An achievement's status: whether it is defined, and retired. Untracked: retirement has its own
/// action event (`AchievementRetired`). Stored in slot A, **with the definition**
/// (`crate::models::status`): it is read with it in one read and written as the whole of A.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementStatus {
    /// Key.
    pub id: u32,
    /// Set by `define`. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`: the indexer stops counting the achievement.
    pub retired: bool,
}

/// A reporter, allowed or not to report progress. Tracked: `Store::set_reporter` emits
/// `AchievementReporterSet` on every write, when the consumer tracks it.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct AchievementReporter {
    /// Key.
    pub reporter: ContractAddress,
    pub allowed: bool,
}
