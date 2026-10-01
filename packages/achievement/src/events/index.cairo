//! Events: every event of `quiver_achievement`, unchanged since 0.1.0 (selectors, keys and data).
//! Two are the events of tracked models, emitted by the store when the consumer tracks them:
//! `AchievementDefined` and `AchievementReporterSet`. The others are action events, emitted by the
//! component where 0.1.0 emits them, whatever the consumer tracks.

use starknet::ContractAddress;
use crate::types::task::AchievementTask;
use crate::types::window::AchievementWindow;

/// The event of the tracked model `AchievementDefinition` (`crate::models::definition`): emitted
/// by `Store::set_definition` on every write, when the consumer tracks the definition.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct AchievementDefined {
    #[key]
    pub achievement_id: u32,
    pub window: AchievementWindow,
    pub tasks: Span<AchievementTask>,
    pub points: u16,
}

/// Action: one per merged, non-zero entry of a progress call. In event mode, the only record of
/// progress.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct AchievementProgressed {
    #[key]
    pub player_id: felt252,
    #[key]
    pub task_id: u32,
    pub count: u32,
}

/// Action: once per retirement.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct AchievementRetired {
    #[key]
    pub achievement_id: u32,
}

/// The event of the tracked model `AchievementReporter` (`crate::models::reporter`): emitted by
/// `Store::set_reporter` on every write, when the consumer tracks reporters.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct AchievementReporterSet {
    #[key]
    pub reporter: ContractAddress,
    pub allowed: bool,
}
