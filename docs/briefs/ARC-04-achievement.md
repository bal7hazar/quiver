# ARC-04 — `quiver_achievement` 0.1.0, event mode only

## Agent
Title: `[Opus 5.5] ARC-04 achievement event mode` · Model: Opus 5.5 (`claude-opus-5-5`) · Profile:
`implement`

## Goal
After this task, `quiver_achievement` is complete for 0.1.0 **in event mode only**
([decision](../decisions/2026-09-29-achievement-event-only.md)): achievements defined and stored
once, retired, and progress reported **as events only**, by registered reporters, with no per-player
storage. Titles of Grim World (design/13) are built on it: the game reports task progress, an indexer
derives tiers from the definitions and the events. There is no storage mode in 0.1.0, and nothing in
the package lets a consumer ask for one.

## Context
- **The decision**: [docs/decisions/2026-09-29-achievement-event-only.md](../decisions/2026-09-29-achievement-event-only.md)
  and its conditions; the cost cap ([amendment](../decisions/2026-09-28-A-G1-amendment-cost-cap.md)).
- **The API accepted at A-G1**, to amend: [ARC-01](../research/ARC-01-quest-achievement.md) §3.10,
  §3.11, §5.2 (achievement), §2 (the named `achievement_` test cases), §3.1 principles.
- **The model to follow**: `packages/quest/` (`quiver_quest` 0.1.0, published): its frame (library
  and component, packing with field-width and reserved-bit checks, `errors`, the internal layer and
  the optional external ABI, the reporter registry and `authorize_admin`, events with their keys,
  benchmarks with baselines, `GAS.md` including the cost of created and overwritten slots, the
  README's integration budget). Packages are self-contained (Q-13): copy what you need, do not
  depend on `quiver_quest`.
- The game: titles in event mode (D-131, D-63 revised); design/13 (the MVP's titles: Pathfinder,
  Warden, Nestbreaker, Unbroken, Flawless, Grimoire keeper for Region 1; Veteran and Scavenger for
  the account; tiers are separate achievements on one task, A-7); at most 16 distinct tasks per call
  (A-10). Read design/13 from the game with
  `cd /home/claude/projects/grimworld && git show origin/main:docs/design/13-titles.md` (read only).
- [docs/CAIRO.md](../CAIRO.md) in full; [docs/WORKSPACE.md](../WORKSPACE.md).
- Depends on: ARC-02, ARC-03 (merged; `quiver_quest` 0.1.0 published).

## Scope

**In** (all in `packages/achievement/` unless said):

1. **Library** (`src/logic/`): the achievement's definition (window, 1 to 3 tasks with a target
   count, the `defined` and `retired` presence bits, points kept in the event only), its packing into
   the fewest slots (field widths checked, reserved bits rejected, an empty slot reading as
   undefined), validation (`'Achievement: invalid id'`, `'Achievement: invalid tasks'`,
   `'Achievement: invalid window'`, D-11), and the batch merge of `progress_many` (at most
   `MAX_ENTRIES` = 16 entries counted before merging, duplicates merged with saturation, zeros
   dropped, task id 0 rejected). `src/errors.cairo`.
2. **Component** (`src/component.cairo`, `src/interface.cairo`): storage of definitions and of the
   reporter registry only (**no per-player storage, no task pages**); events `AchievementDefined`
   (with `points`), `AchievementProgressed` (one per merged non-zero entry, keys player and task),
   `AchievementRetired`, `AchievementReporterSet`; internal functions `define`, `retire`,
   `set_reporter`, `progress`, `progress_many`, `assert_reporter`, reads; the external ABI
   `IAchievement` (define, retire, set_reporter through `authorize_admin`; progress and
   progress_many through the reporter registry) and `IAchievementView`, each optional to embed; a
   hooks trait with `authorize_admin` only.
3. **Event mode only, enforced by absence**: no `Mode` parameter, no storage-mode entrypoint, no
   per-player record, no completion, no claim. A consumer cannot ask for storage mode: the code that
   would do it does not exist. Say so in the doc comments and the README.
4. **Access control**: as `quiver_quest`: define, retire and set_reporter by the admin hook;
   progress by registered reporters only; the internal layer trusted and documented as such; tests
   for every entrypoint refusing an unauthorised caller, a revoked reporter refused at once, the
   internal layer unreachable from the ABI unless exposed.
5. **Tests**, written first, each with a gas budget: the named `achievement_` cases of ARC-01 §2
   that still apply (event mode, define twice, invalid tasks and window, batch bound and merging,
   access control, retirement); the ones that assumed storage mode (tiers completing, a tier kept,
   one-write) are listed in the report as dropped with the decision as the reason; events checked
   field by field with `spy_events`.
6. **Measurements**, benchmarks with baselines: the worst `progress_many` (16 entries with the most
   expensive merge path, late duplicate and late collision), `progress`, `define` at its worst (3
   tasks), `retire`, `set_reporter`; **the game's use**: the MVP's 8 titles defined with their tiers
   (tiers sharing a task), and a typical results call reporting their tasks; every figure against
   the 20M cap, with the network estimate (a created slot about 453 500 L2 gas, an overwritten one
   about 32 000, as `quiver_quest`'s GAS.md states).
7. **Documents, first**: amend ARC-01 §3.10, §3.11 and §5.2 "by the decision of 2026-09-29" (event
   mode only); `README.md` (usage for an indexer-backed consumer, bounds, access control, the
   integration budget, and that **a storage design with per-task counters is planned for a later
   version and its layout is not reserved by 0.1.0**); `CHANGELOG.md` 0.1.0; `GAS.md`;
   `docs/BUDGETS.md` (an achievement section).

**Out**: storage mode of any kind; `quiver_quest`; the workspace, CI and gas tooling; publishing
(no sub-agent publishes, ever: D-132; the orchestrator asks after this lot).

**Allowlist**: `packages/achievement/**`, `docs/BUDGETS.md`, and the achievement parts of
`docs/research/ARC-01-quest-achievement.md` (§3.10, §3.11, §5.2, and the `achievement_` rows of §2).
Anything else is an escalation.

## Acceptance criteria
- [ ] AC-1 No storage mode reachable: no `Mode` type in the ABI, no per-player storage, no claim.
- [ ] AC-2 Every `IAchievement` entrypoint refuses an unauthorised caller, with a test each.
- [ ] AC-3 The worst call and the game's use measured under 20M L2 gas, with network estimates.
- [ ] AC-4 Every test has a budget; `scripts/gas.py packages/achievement --check` passes.
- [ ] AC-5 ARC-01 amended; README (with the planned storage design and its unreserved layout),
      CHANGELOG 0.1.0, GAS.md and BUDGETS written.
- [ ] AC-6 The pull request's CI is green.

## Verification
`scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml build`,
`cd packages/achievement && snforge test`, `scripts/gas.py packages/achievement --check`,
`scripts/lock.sh scarb --manifest-path packages/achievement/Scarb.toml fmt --check`,
`python3 .github/ci/check-links.py`; then `gh pr checks <n> --watch --interval 30` until green.
Scope every local run to the achievement package.

## Report
`REPORT.md` (COMMON.md §6): the storage layout, the measurements against 20M, the named cases kept and
dropped, deviations, escalations. Branch `feat/ARC-04-achievement`; pull request
`[Opus 5.5] ARC-04 achievement event mode`. Foreground only; your turn ends when `REPORT.md` is
written.
