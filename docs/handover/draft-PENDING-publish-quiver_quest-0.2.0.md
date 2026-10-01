# `quiver_quest` 0.2.0 — publication asked

> **DRAFT** (2026-10-01), kept in `docs/handover/` so that it is not read as a request; moved to `docs/decisions/PENDING-publish-…` when filled in. The commit, the archive's sha256 and the figures are filled in once ARC-10
> (Scarb 2.20.1) is merged; the request is sent only then. Fields marked **TO FILL** are not facts yet.

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver` |
| Decides | **The owner** (a stable version; D-132), the go prepared by the project manager. It names the package, the version, the commit and the archive's sha256 |
| Package | **`quiver_quest`** (`packages/quest`) |
| Version | **0.2.0**, after [0.1.0](../decisions/2026-09-29-publish-quiver_quest-0.1.0.md) (D-138) |
| Commit | **TO FILL**, on `main`, after ARC-10 |
| Archive | `quiver_quest-0.2.0.tar.zst`, sha256 **TO FILL** (`RAYON_NUM_THREADS=1 scarb package` from a clean clone of that commit, Scarb 2.19.4; D-176) |
| Registry | scarbs.xyz; 0.1.0 is published; 0.2.0 must be free: **TO FILL** (the index read on the day) |
| Published by | The orchestrator's session, by hand, after the go, from a clean checkout of that commit, the archive's sha256 compared first; no agent, no CI |

## What changes since 0.1.0

The package is rewritten on the owner's pattern (D-143, docs/CAIRO.md §7), accepted by the owner
(D-147 for the pattern, **D-167** for this package):

- **Breaking: module paths and names.** No `logic/`: `models/` (one file per stored entity), `types/`,
  `helpers/`, `events/`, one `store`; the slot types are named for their slots (`HeadSlot`,
  `TasksSlot`, `ConditionsSlot`, `ProgressSlot`, `RecordSlot`, `HeldSlot`); `QuestDefinition` is the
  model only. A consumer of 0.1.0 changes its imports (`CHANGELOG.md` `[0.2.0]`).
- **New: tracking chosen by the consumer** at compile time, `impl QuestTracking = TrackAll` (as 0.1.0)
  or `TrackNone`, or its own: an untracked write costs exactly the write, measured to the unit.
- **Kept**: behaviour, events and their fields, error strings, storage layouts, every test and budget;
  no worst call raised.
- **Tests beside their code** (D-167, ARC-07c): unit tests in their modules; nothing a consumer
  compiles changes.

[The mapping of Arcade's models and events](../research/ARC-07a-arcade-mapping.md) says what was kept,
merged, added and dropped, and why.

## What was checked, at that commit

| The check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | **TO FILL** |
| Reviews and audits closed without `blocker` or `major` | ARC-07a: `[GPT-6-Sol]` organisation [PASS](../reports/ARC-07a-audit-gpt-6-sol-2.md), `[GPT-6-Astra]` cost and access control [PASS WITH FINDINGS](../reports/ARC-07a-audit-gpt-6-astra-2.md). ARC-07c ([#28](https://github.com/bal7hazar/quiver/pull/28)): review `[Opus 5.5]` PASS WITH FINDINGS, its note fixed; no audit (D-177: a move of tests). ARC-09, ARC-10: reviews only |
| No source changed after the audits | **TO FILL** |
| Changelog and version agree | **TO FILL**: `Scarb.toml` 0.2.0; `CHANGELOG.md` `[0.2.0] - <date>`; `.github/ci/release_check.py quiver_quest-v0.2.0` |
| Gas tables of that commit | `packages/quest/GAS.md`, `docs/BUDGETS.md`: **TO FILL** |
| `scarb package` from a clean checkout | **TO FILL**: files, size, sha256; no settings file or key in the archive |
| No test dependency declared as a regular one | **TO FILL**: `starknet` only under `[dependencies]` |

## Cost, measured (ARC-07a on Scarb 2.19.4; remeasured on 2.20.1 by ARC-10: TO FILL)

| Call | snforge / network | Share of the 20M cap |
|---|---|---|
| Worst `progress_many`, `MAX_HELD` = 4, created slots, hooks empty | 6 205 843 / 6 160 995 | 31 % |
| Same, `on_quest_complete` writing one new slot | 8 020 763 / 7 953 491 | 40 % |
| 8 held (the layout's limit), one-slot hook | 15 045 913 / 14 911 369 | 75 % |
| Grim World's use | 4 546 186 / 4 462 338 | 23 % |
| `accept`, worst | 1 917 170 / 1 880 852 | 10 % |
| `define`, worst (3 tasks, 7 conditions, `TrackAll`) | 2 583 280 / 2 390 720 | 13 % |

## What the consumer must do

As for 0.1.0, plus: change the imports to 0.2.0's paths, and choose the tracking with one line,
`impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;` to keep 0.1.0's events.
