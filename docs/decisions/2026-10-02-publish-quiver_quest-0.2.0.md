# `quiver_quest` 0.2.0 — published 2026-10-02 (D-186)

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver` |
| Decides | The go, given by the project manager under D-186, 2026-10-02: the owner's delegation for these two packages, recorded in the game repository (`22f6967`). It names the package, the version, the commit and the archive's sha256 |
| Package | **`quiver_quest`** (`packages/quest`) |
| Version | **0.2.0**, after [0.1.0](../decisions/2026-09-29-publish-quiver_quest-0.1.0.md) (D-138) |
| Commit | `2e6bb77392335a5420b2ff331f072f66f265c16f` (`main`, #38, after ARC-10 #37), 2026-10-02 |
| Archive | `quiver_quest-0.2.0.tar.zst`, sha256 **15f0a3710a471e779f7a003f61eedc1814296a4dfa22ac7dda5c079e20cdcb54** (`RAYON_NUM_THREADS=1 scarb package` from a clean checkout of that commit, Scarb 2.20.1; D-176; 66 files, 632.13 KiB, 100.43 KiB compressed). The two sha256, from two clean detached worktrees of that commit at different absolute paths, match |
| Registry | scarbs.xyz; 0.1.0 is published; 0.2.0 is free: the index `api/v1/index/qu/iv/quiver_quest.json`, read on 2026-10-02, lists `0.1.0` only |
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
| On `main`, every CI check completed and green | At `2e6bb77392335a5420b2ff331f072f66f265c16f`: runs `tooling` (37003078145) and `cairo` (37003078164), both completed, success |
| Reviews and audits closed without `blocker` or `major` | ARC-07a: `[GPT-6-Sol]` organisation [PASS](../reports/ARC-07a-audit-gpt-6-sol-2.md), `[GPT-6-Astra]` cost and access control [PASS WITH FINDINGS](../reports/ARC-07a-audit-gpt-6-astra-2.md). ARC-07c ([#28](https://github.com/bal7hazar/quiver/pull/28)): review `[Opus 5.5]` PASS WITH FINDINGS, its note fixed; no audit (D-177: a move of tests). ARC-09: review only. ARC-10 ([#37](https://github.com/bal7hazar/quiver/pull/37), Scarb 2.20.1): two reviews by `[Opus 5.5]` (`review-opus`), the first PASS WITH FINDINGS (one minor, fixed), the second PASS WITH FINDINGS (notes only); merged at `c15e515` as `0fd494e`; no audit (D-177) |
| No source changed after the audits and reviews | `git log -- packages/quest/src`: since the audited ARC-07a (`5571876`), two commits, both reviewed: `7afe131` ARC-07c (#28, tests moved into their modules) and `0fd494e` ARC-10 (#37). Since ARC-07c, the last reviewed before ARC-10, only `0fd494e`. Nothing after it: #38 touched the two changelogs only |
| Changelog and version agree | `Scarb.toml` 0.2.0; `CHANGELOG.md` `## [0.2.0] - 2026-10-02`; `.github/ci/release_check.py quiver_quest-v0.2.0` passes (`dir=packages/quest`, `version=0.2.0`) |
| Gas tables of that commit | `packages/quest/GAS.md`, `docs/BUDGETS.md` at that commit, measured on Scarb 2.20.1 and snforge 0.64.0 (figures below) |
| `scarb package` from a clean checkout | 66 files, 632.13 KiB, sha256 as above, identical from two checkouts at different paths. The list: `VERSION`, `CHANGELOG.md`, `GAS.md`, `README.md`, `Scarb.orig.toml`, `Scarb.toml`, `VCS.json` (the commit and `packages/quest`), `src/` (29 files), `tests/` (30 files); no settings file, no key |
| No test dependency declared as a regular one | `starknet` is the only entry under `[dependencies]`; `snforge_std` is under `[dev-dependencies]` |

## Cost, measured (Scarb 2.20.1 and snforge 0.64.0, by ARC-10; 0.1.0 and ARC-07a were on 2.19.4 and snforge 0.61)

| Call | snforge / network | Share of the 20M cap (snforge / network) |
|---|---|---|
| Worst `progress_many`, `MAX_HELD` = 4, created slots, hooks empty | 6 460 843 / 6 295 995 | 32 % / 31 % |
| Same, `on_quest_complete` writing one new slot | 8 335 763 / 8 088 491 | 42 % / 40 % |
| 8 held (the layout's limit), one-slot hook | 15 666 913 / 15 172 369 | 78 % / 76 % |
| Grim World's use | 4 801 186 / 4 597 338 | 24 % / 23 % |
| `accept`, worst | 2 061 170 / 1 979 852 | 10 % / 10 % |
| `define`, worst (3 tasks, 7 conditions, `TrackAll`) | 2 779 560 / 2 437 000 | 14 % / 12 % |

The figures moved with the toolchain, not with the code: snforge 0.64 charges 15 000 more per storage write and 6 000 more per read than 0.61. The network estimate is snforge minus 20 606 per created slot and 40 106 per overwritten slot. No worst call reaches the cap.

## What the consumer must do

As for 0.1.0, plus: change the imports to 0.2.0's paths, and choose the tracking with one line,
`impl QuestTracking = quiver_quest::store::tracking::TrackAll<ContractState>;` to keep 0.1.0's events.

## Published

The go was given by the project manager under D-186 on 2026-10-02, after the project manager's own D-132
checklist in a clean clone (about 18:4xZ): the commit on `main`, CI green on it, the last source change
reviewed with no blocker or major (ARC-10, #37), the archive rebuilt with `RAYON_NUM_THREADS=1` on Scarb 2.20.1
with the sha256 above, 0.2.0 absent from scarbs.xyz.

Published by the orchestrator's session, by hand, on 2026-10-02: `scarb publish -p quiver_quest` from one clean
detached checkout of `2e6bb77392335a5420b2ff331f072f66f265c16f`, the archive's sha256 checked with
`sha256sum --check` first. `quiver_quest` was published first. Scarb warned "publishing docs is not supported
by registry"; the package is published.

| | |
|---|---|
| Registry | **https://scarbs.xyz/packages/quiver_quest**, version 0.2.0 |
| Registry checksum | `sha256:15f0a3710a471e779f7a003f61eedc1814296a4dfa22ac7dda5c079e20cdcb54` (the index's `cksum` in `api/v1/index/qu/iv/quiver_quest.json`, read back after publishing, equal to the approved archive) |
| Consumers need | Scarb 2.20 (`starknet ^2.20.0`, `snforge_std ^0.64.0`) |
| Tag and release | [`quiver_quest-v0.2.0`](https://github.com/bal7hazar/quiver/releases/tag/quiver_quest-v0.2.0), annotated, on `2e6bb77` |
