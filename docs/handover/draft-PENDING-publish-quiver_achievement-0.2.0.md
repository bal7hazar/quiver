# `quiver_achievement` 0.2.0 — publication asked

> **DRAFT** (2026-10-01), kept in `docs/handover/` so that it is not read as a request; moved to `docs/decisions/PENDING-publish-…` when filled in. The commit, the archive's sha256 and the figures are filled in once ARC-10
> (Scarb 2.20.1) is merged; ARC-07b ([#25](https://github.com/bal7hazar/quiver/pull/25)) is merged with its
> audits; the request is sent only then. Fields marked **TO FILL** are not
> facts yet.

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver` |
| Decides | **The owner** (a stable version; D-132), the go prepared by the project manager. It names the package, the version, the commit and the archive's sha256 |
| Package | **`quiver_achievement`** (`packages/achievement`) |
| Version | **0.2.0**, after [0.1.0](../decisions/2026-09-29-publish-quiver_achievement-0.1.0.md) (D-142) |
| Commit | **TO FILL**, on `main`, after ARC-10 |
| Archive | `quiver_achievement-0.2.0.tar.zst`, sha256 **TO FILL** (`RAYON_NUM_THREADS=1 scarb package` from a clean clone of that commit, Scarb 2.19.4; D-176) |
| Registry | scarbs.xyz; 0.1.0 is published; 0.2.0 must be free: **TO FILL** |
| Published by | The orchestrator's session, by hand, after the go, from a clean checkout of that commit, the archive's sha256 compared first; no agent, no CI |

## What changes since 0.1.0

The package is rewritten on the owner's pattern (D-143, docs/CAIRO.md §7), as `quiver_quest` 0.2.0
(accepted, D-167); still **in event mode only**:

- **Breaking: module paths and names.** No `logic/`: `models/` (definition, status, reporter),
  `types/`, `helpers/`, `events/`, one `store`; slot A is `HeadSlot`, slot B `TasksSlot`;
  `AchievementDefinition` is the model only.
- **Changed layout: `points` stored** in slot A, bits [196, 212), so that `AchievementDefined` is built
  from the model; the view `achievement_definition` returns it (one more felt). A slot written by 0.1.0
  reads `points` 0. Cost accepted by the project manager (2026-10-01): `retire` +2 570 (+1.1 %), the
  view +3 610 (+1.7 %), `define` of 3 tasks +0.13 %; the worst call unchanged.
- **New: tracking chosen by the consumer** at compile time, `impl AchievementTracking = TrackAll`
  (as 0.1.0) or `TrackNone`, or its own; an untracked write costs exactly the write, measured to the
  unit. `AchievementProgressed` and `AchievementRetired` are emitted whatever the choice.
- **Tests beside their code** (D-167): 62 unit tests in their modules, 83 in `tests/`; nothing a
  consumer compiles changes.

## What was checked, at that commit

| The check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | **TO FILL** |
| Reviews and audits closed without `blocker` or `major` | Reviews `[Fable 5.1]`: last PASS on `970cff1` after three fix loops; merged as `4243132`. Audits on `[Opus 5.5]` (D-177, before a published interface's publication; Codex out of quota, D-175): organisation PASS WITH FINDINGS ([report](../reports/ARC-07b-audit-opus-organisation-2.md)), cost and access control PASS WITH FINDINGS ([report](../reports/ARC-07b-audit-opus-cost.md)); notes only, one answered in the CHANGELOG (`19a578c`), the others in ARC-07d |
| No source changed after the audits | **TO FILL** |
| Changelog and version agree | **TO FILL**: `Scarb.toml` 0.2.0; `CHANGELOG.md` `[0.2.0] - <date>`; `.github/ci/release_check.py quiver_achievement-v0.2.0` |
| Gas tables of that commit | `packages/achievement/GAS.md` (145 tests), `docs/BUDGETS.md`: **TO FILL** |
| `scarb package` from a clean checkout | **TO FILL** |
| No test dependency declared as a regular one | **TO FILL** |

## Cost, measured (ARC-07b on Scarb 2.19.4; remeasured on 2.20.1 by ARC-10: TO FILL)

| Call | L2 gas | Share of the 20M cap |
|---|---|---|
| Worst `progress_many` (16 entries, the slowest merge) | 1 816 813 (progress writes nothing) | 9.1 % |
| Grim World's results call | 829 728 | 4.1 % |
| Worst `define` (3 tasks, `TrackAll`) | 1 198 640 | 6.0 % |
| The game's 26 tiers defined in one transaction | 18 412 110 | 92.1 % (the README says to split) |

## What the consumer must do

As for 0.1.0, plus: change the imports to 0.2.0's paths, and choose the tracking with one line,
`impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;` to keep
0.1.0's events.
