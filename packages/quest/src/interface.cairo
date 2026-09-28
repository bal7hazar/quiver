//! The external ABI of `quiver_quest` (ARC-01 §3.5). Both interfaces are optional: a consumer
//! embeds `QuestComponent::QuestImpl`, `QuestComponent::QuestViewImpl`, both, or neither.

use starknet::ContractAddress;
use crate::logic::{
    Mode, QuestDefinition, QuestProgress, QuestRecord, QuestSchedule, QuestTask, TaskProgress,
};

/// The access-checked entrypoints (§3.6): `define`, `retire` and `set_reporter` need
/// `authorize_admin(caller)`; `progress` and `progress_many` a registered reporter; `accept`,
/// `abandon` and `claim` need `authorize_player(caller, player_id)`.
#[starknet::interface]
pub trait IQuest<TState> {
    fn define(
        ref self: TState,
        quest_id: u32,
        schedule: QuestSchedule,
        tasks: Span<QuestTask>,
        conditions: Span<u32>,
        needs_accept: bool,
    );
    fn retire(ref self: TState, quest_id: u32);
    fn set_reporter(ref self: TState, reporter: ContractAddress, allowed: bool);
    fn progress(ref self: TState, player_id: felt252, task_id: u32, count: u32, mode: Mode);
    fn progress_many(ref self: TState, player_id: felt252, entries: Span<TaskProgress>, mode: Mode);
    fn accept(ref self: TState, player_id: felt252, quest_id: u32);
    fn abandon(ref self: TState, player_id: felt252, quest_id: u32);
    fn claim(ref self: TState, player_id: felt252, quest_id: u32, interval_id: u64) -> u64;
}

/// The views. None writes.
#[starknet::interface]
pub trait IQuestView<TState> {
    fn quest_definition(
        self: @TState, quest_id: u32,
    ) -> (QuestDefinition, Span<QuestTask>, Span<u32>);
    fn quest_progress(
        self: @TState, player_id: felt252, quest_id: u32, interval_id: u64,
    ) -> QuestProgress;
    fn quest_record(self: @TState, player_id: felt252, quest_id: u32) -> QuestRecord;
    fn quest_current_interval(self: @TState, quest_id: u32) -> Option<u64>;
    fn quest_is_unlocked(self: @TState, player_id: felt252, quest_id: u32) -> bool;
    fn quest_is_accepted(self: @TState, player_id: felt252, quest_id: u32) -> bool;
    fn quest_is_reporter(self: @TState, reporter: ContractAddress) -> bool;
}
