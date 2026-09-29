//! Events: every event of `quiver_quest`, unchanged since 0.1.0 (selectors, keys and data). Two
//! are the events of tracked models, emitted by the store when the consumer tracks them:
//! `QuestDefined` and `QuestReporterSet`. The others are action events, emitted by the component
//! where 0.1.0 emits them, whatever the consumer tracks.

use starknet::ContractAddress;
use crate::types::schedule::QuestSchedule;
use crate::types::task::QuestTask;

/// The event of the tracked model `QuestDefinition` (`crate::models::definition`): emitted by
/// `Store::set_definition` on every write, when the consumer tracks the definition.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestDefined {
    #[key]
    pub quest_id: u32,
    pub schedule: QuestSchedule,
    pub tasks: Span<QuestTask>,
    pub conditions: Span<u32>,
}

/// Action: `Mode::Event` only; one per merged, non-zero entry.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestProgressed {
    #[key]
    pub player_id: felt252,
    #[key]
    pub task_id: u32,
    pub count: u32,
}

/// Action: `Mode::Storage`, once per completion.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestCompleted {
    #[key]
    pub player_id: felt252,
    #[key]
    pub quest_id: u32,
    pub interval_id: u64,
}

/// Action: once per claim.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestClaimed {
    #[key]
    pub player_id: felt252,
    #[key]
    pub quest_id: u32,
    pub interval_id: u64,
}

/// Action: once per retirement.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestRetired {
    #[key]
    pub quest_id: u32,
}

/// The event of the tracked model `QuestReporter` (`crate::models::reporter`): emitted by
/// `Store::set_reporter` on every write, when the consumer tracks reporters.
#[derive(Drop, PartialEq, Debug, starknet::Event)]
pub struct QuestReporterSet {
    #[key]
    pub reporter: ContractAddress,
    pub allowed: bool,
}
