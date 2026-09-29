//! Models: every stored entity of `quiver_quest`, its keys first. Each is read and written only
//! through the store (`crate::store`); its file holds its behaviour, its checks, its errors and
//! its storage. Tracked models (`Tracked`): `QuestDefinition`, `QuestReporter`. The others are
//! untracked and emit nothing when written (docs/research/ARC-06-model-store.md §6).

use starknet::ContractAddress;
use crate::types::held::QuestHeld;
use crate::types::schedule::QuestSchedule;
use crate::types::task::QuestTask;

/// A quest, as `define` wrote it; it never changes afterwards. Tracked: `Store::set_definition`
/// emits `QuestDefined` on every write, when the consumer tracks it. Stored in the slots A, B and
/// C of 0.1.0, unchanged (`crate::models::definition`, `DefinitionStorage`). A quest not defined
/// reads with no task.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestDefinition {
    /// Key.
    pub id: u32,
    pub schedule: QuestSchedule,
    /// 1 to `MAX_TASKS` tasks, ids distinct and non-zero, totals non-zero.
    pub tasks: Span<QuestTask>,
    /// 0 to `MAX_CONDITIONS` quest ids, distinct, non-zero, other than `id`.
    pub conditions: Span<u32>,
}

/// A quest's status: whether it is defined, retired, and how many live quests name it as a
/// condition. Untracked: its changes have their own action event (`QuestRetired`) or none (the
/// prerequisites' counter). Stored in slot A, **with the definition's schedule and counts**
/// (`crate::models::status`): it is read with them in one read and written as the whole of A.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestStatus {
    /// Key.
    pub id: u32,
    /// Set by `define`. An empty slot reads false.
    pub defined: bool,
    /// Set by `retire`: no progress, no acceptance.
    pub retired: bool,
    /// Defined, non-retired quests naming this one as a condition.
    pub live_dependents: u16,
}

/// A player's progress on a quest in one interval. Untracked: a partial count emits nothing;
/// completion and claim have their action events (`QuestCompleted`, `QuestClaimed`). Slot P.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestProgress {
    /// Key.
    pub player_id: felt252,
    /// Key.
    pub quest_id: u32,
    /// Key.
    pub interval_id: u64,
    /// Counts, saturated at each task's total.
    pub c0: u32,
    pub c1: u32,
    pub c2: u32,
    pub completed: bool,
    pub claimed: bool,
}

/// A player's record of a quest, across intervals. Untracked: completion and claim have their
/// action events, the unlock none. Slot R.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestRecord {
    /// Key.
    pub player_id: felt252,
    /// Key.
    pub quest_id: u32,
    /// Completions in all intervals; saturating increment.
    pub completions: u64,
    /// Claims in all intervals; saturating increment.
    pub claims: u64,
    /// Prerequisites seen met, cached by `accept`.
    pub unlocked: bool,
}

/// One slot of a player's held list: two entries, and in slot 0 the player's acceptance counter.
/// Untracked: nothing is indexed. Slot H (`crate::models::held` for the list's rules).
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestHeldSlot {
    /// Key.
    pub player_id: felt252,
    /// Key: `0..HELD_SLOTS`.
    pub index: u8,
    pub e0: QuestHeld,
    pub e1: QuestHeld,
    /// The number of the player's last acceptance, in slot 0; 0 in the others.
    pub counter: u32,
    /// Set once the slot has held an entry, never cleared.
    pub kept: bool,
}

/// A reporter, allowed or not to report progress. Tracked: `Store::set_reporter` emits
/// `QuestReporterSet` on every write, when the consumer tracks it.
#[derive(Drop, Copy, Serde, PartialEq, Debug)]
pub struct QuestReporter {
    /// Key.
    pub reporter: ContractAddress,
    pub allowed: bool,
}
