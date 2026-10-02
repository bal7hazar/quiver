# Changelog

All notable changes to `quiver_achievement` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

## [0.2.0] - 2026-10-02

Not yet released. The package organised as the owner's rule D-143 says (docs/CAIRO.md §7), as
`quiver_quest` 0.2.0 is: no `logic`, every stored entity a model read and written only through
the store, and each tracked model's event optional for the consumer (ARC-06, ARC-07b;
[docs/research/ARC-06-model-store.md](https://github.com/bal7hazar/quiver/blob/main/docs/research/ARC-06-model-store.md)).
Still **in event mode only**: progress is emitted, never stored. **Behaviour, events (selectors,
keys, data), error strings and the inputs of the ABI are those of 0.1.0.** Two changes of results:
**`points` is stored** in slot A, and the view `achievement_definition` returns it (below). The
**Cairo** paths and names change, and the component's impls take a tracking choice: a consumer's
code must be updated.

### Breaking: paths and names

- **`quiver_achievement::logic` is removed.** Its items are now:

  | 0.1.0 | 0.2.0 |
  |---|---|
  | `logic::AchievementWindow`, `window_validate`, `window_is_active` | `types::window::AchievementWindow`, `WindowAssert::assert_valid`, `WindowTrait::is_active` |
  | `logic::AchievementTask` | `types::task::AchievementTask` |
  | `logic::TaskProgress`, `batch_merge`, `batch_count_of` | `types::batch::TaskProgress`, `BatchTrait::merge`, `count_of` |
  | `logic::AchievementDefinition` (slot A) | `models::definition::HeadSlot`, with `points` |
  | `logic::AchievementExtraTasks` (slot B) | `models::definition::TasksSlot` |
  | `logic::definition_new` | `models::definition::DefinitionTrait::new(id, window, tasks, points)`, then `into_slots` |
  | `logic::tasks_span` | `models::definition::HeadSlotTrait::tasks` |
  | `logic::AchievementDefinitionPacking`, `AchievementExtraTasksPacking` | `HeadPacking`, `TasksPacking` |
  | `logic::bits` | `helpers::bits` (`BitsTrait::split`; the tables) |
  | `logic::MAX_TASKS`, `MAX_ENTRIES` | `constants::` (as in 0.1.0) |

- **`AchievementDefinition` is the model only**: `{ id, window, tasks, points }`. The slot types
  are named for their slots.
- **The component's impls take the tracking choice.** `InternalImpl`, `AchievementImpl` and
  `AchievementViewImpl` have a second impl parameter, `impl Tracking:
  AchievementTracking<TContractState>`. A consumer adds one line to its contract, `impl
  AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;` for 0.1.0's
  events.
- The event structs are declared in `quiver_achievement::events` (one file each, `events::index`);
  they are still exported from `quiver_achievement::component::AchievementComponent`, with the same
  selectors, keys and data.

### Changed

- **Storage layout: `points` is stored** in slot A, bits [196, 212), which 0.1.0 reserved; [212,
  252) stay reserved and are checked on unpacking. A tracked model holds every field its event
  carries (ARC-06 §6, rule 1). No new slot: `define` writes A anyway. A slot A written by 0.1.0
  reads with `points` 0: a consumer upgraded in place from 0.1.0 gets `points` 0 from the view and
  the store for the achievements it defined before, and nothing re-emits them; for those, the
  `AchievementDefined` emitted by 0.1.0 stays the source of `points`.
- **The view's ABI: `achievement_definition` returns `(HeadSlot, Span<AchievementTask>)`**, slot A
  with `points` as its last field: one more felt in the output, after `t0`. An ABI client of 0.1.0
  that decodes the struct must read it.
- **Built with Scarb 2.20.1** (Cairo 2.20.0, `snforge_std` 0.64.0; D-180, ARC-10). Behaviour, events
  and layouts are unchanged. **Costs rise on this toolchain: a storage write costs 15 000 L2 gas
  more and a read 6 000 more** (snforge 0.64: a created slot 474 106, was 459 106; an overwritten
  one 72 106, was 57 106). Re-measured, every call is **under the 20 M cap**: `progress_many`, the
  slowest merge, 1 821 093 (9.1 %); `define` of 3 tasks 1 232 920, of 1 task 722 550; `retire`
  262 730; `set_reporter` 620 810; `achievement_definition` 229 420; the 26 tiers of Grim World
  defined in one transaction 18 916 390 (94.6 % of the cap, 92.1 % on 2.19.4). The figures of the
  bullet below are the ones measured on Scarb 2.19.4. No test budget was raised.
- **Costs on Scarb 2.19.4** (`GAS.md`, under `TrackAll`). Progress, the worst call, is 0.1.0's to the unit
  (`progress_many` 1 816 813 on the slowest merge), as are `set_reporter` and
  `achievement_is_reporter`. `define` of 1 task is 4 370 cheaper (703 270), of 3 tasks 1 610 more
  (1 198 640, `points` packed); `retire` 2 570 more (243 330: A unpacked and packed with
  `points`); the view `achievement_definition` 3 610 more (217 740: `points` unpacked and
  returned).

### Added

- **Optional tracking** (D-147). `quiver_achievement::store::AchievementTracking<TContractState>`,
  one constant per tracked model (`DEFINITION`, `REPORTER`), and its ready choices
  `store::tracking::TrackAll` (every tracked model emits, as 0.1.0) and `TrackNone`. Under
  `TrackNone`, `define` does not emit `AchievementDefined` and `set_reporter` does not emit
  `AchievementReporterSet`; the action events (`AchievementProgressed`, the only record of
  progress, and `AchievementRetired`) are emitted whatever the choice. The compiler folds the
  constant: an untracked write costs exactly the write with no event code, a tracked one the
  write plus the event (measured to the unit, `GAS.md`). An indexer that derives the tiers needs
  the definition tracked.
- **Models** (`quiver_achievement::models`, structs in `models::index`): `AchievementDefinition`
  (tracked, slots A and B), `AchievementStatus` (untracked, `defined` and `retired` of slot A,
  shared with the definition) and `AchievementReporter` (tracked). Each with its behaviour, checks,
  `errors` (the strings of `quiver_achievement::errors`) and storage.
- **The store** (`quiver_achievement::store`, `StoreTrait` on the component's state):
  `Tracked<M>`; `get_definition`, `get_definition_head` (A), `get_definition_tasks` (B),
  `set_definition`; `get_status`, `set_status(status, head)`; `get_reporter`, `set_reporter`. The
  component reads and writes storage only through it.
- `quiver_achievement::types` (`window`, `task`, `batch`) and `quiver_achievement::helpers::bits`.
- The unit tests are in their module's file, under `#[cfg(test)] mod tests` (D-167); they are not
  compiled into a consumer's build.

## [0.1.0] - 2026-09-29

Published on [scarbs.xyz](https://scarbs.xyz/packages/quiver_achievement) from commit `50017e7`
(sha256 `1473a07fcbe1298a9ba85ef07b1b5afc63816c1fcbe3c5c10151908ae7a4d9d9`); tag `quiver_achievement-v0.1.0`.

The first release, **in event mode only**
([decision of 2026-09-29](https://github.com/bal7hazar/quiver/blob/main/docs/decisions/2026-09-29-achievement-event-only.md)):
definitions are stored, progress is emitted as events, an indexer derives the tiers. There is no
storage mode, no per-player storage, no completion and no claim. A storage design with per-task
counters is planned for a later version; its layout is not reserved by 0.1.0.

### Added

- `quiver_achievement::logic`: `AchievementWindow`, `AchievementTask`, `AchievementDefinition`
  (slot A), `AchievementExtraTasks` (slot B), `TaskProgress`; their packing into one felt each
  (`AchievementDefinitionPacking`, `AchievementExtraTasksPacking`), with field widths checked and
  reserved bits rejected; `definition_new`, `tasks_span`, `window_validate`, `window_is_active`,
  `batch_merge`, `batch_count_of`.
- `quiver_achievement::component::AchievementComponent`:
  - storage `Achievement_definitions` (slot A: `start` [0, 64), `end` [64, 128), `task_count`
    [128, 130), `defined` [130], `retired` [131], `t0` [132, 196)), `Achievement_extra_tasks`
    (slot B: `t1` [0, 64), `t2` [64, 128); written only for 2 or 3 tasks) and
    `Achievement_reporters`;
  - events `AchievementDefined { #[key] achievement_id, window, tasks, points }`,
    `AchievementProgressed { #[key] player_id, #[key] task_id, count }`,
    `AchievementRetired { #[key] achievement_id }`,
    `AchievementReporterSet { #[key] reporter, allowed }`;
  - the hook trait `AchievementHooksTrait` with `authorize_admin`;
  - the trusted internal layer `InternalImpl`: `define`, `retire`, `set_reporter`, `progress`,
    `progress_many`, `assert_reporter`, `definition`;
  - the optional external ABI `AchievementImpl` (`IAchievement`: `define`, `retire` and
    `set_reporter` through `authorize_admin`; `progress` and `progress_many` through the reporter
    registry) and `AchievementViewImpl` (`IAchievementView`: `achievement_definition`,
    `achievement_is_reporter`).
- `quiver_achievement::errors`: `'Achievement: invalid id'`, `'Achievement: invalid tasks'`,
  `'Achievement: invalid window'`, `'Achievement: already defined'`, `'Achievement: does not
  exist'`, `'Achievement: retired'`, `'Achievement: invalid task'`, `'Achievement: too many
  entries'`, `'Achievement: not reporter'`, `'Achievement: not admin'`.
- `quiver_achievement::constants`: `MAX_TASKS` = 3, `MAX_ENTRIES` = 16.

### Removed

- `ACHIEVEMENTS_PER_PAGE` and `MAX_PAGES` of the unreleased skeleton: there are no task pages in
  event mode, and no cap of achievements per task.
