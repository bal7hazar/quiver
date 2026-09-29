# Changelog

All notable changes to `quiver_achievement` are recorded here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Changes to results, storage layout,
events and error strings are named.

## [Unreleased]

## [0.1.0]

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
