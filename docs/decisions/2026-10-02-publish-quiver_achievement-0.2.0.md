# `quiver_achievement` 0.2.0 — published 2026-10-02 (D-186)

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver` |
| Decides | The go, given by the project manager under D-186, 2026-10-02: the owner's delegation for these two packages, recorded in the game repository (`22f6967`). It names the package, the version, the commit and the archive's sha256 |
| Package | **`quiver_achievement`** (`packages/achievement`) |
| Version | **0.2.0**, after [0.1.0](../decisions/2026-09-29-publish-quiver_achievement-0.1.0.md) (D-142) |
| Commit | `2e6bb77392335a5420b2ff331f072f66f265c16f` (`main`, #38, after ARC-10 #37), 2026-10-02 |
| Archive | `quiver_achievement-0.2.0.tar.zst`, sha256 **a66de3292e925cdcb2b4c669763d1d75f4aab4edcbe523a2043fb1320449e3db** (`RAYON_NUM_THREADS=1 scarb package` from a clean checkout of that commit, Scarb 2.20.1; D-176; 39 files, 226.01 KiB, 42.92 KiB compressed). The two sha256, from two clean detached worktrees of that commit at different absolute paths, match |
| Registry | scarbs.xyz; 0.1.0 is published; 0.2.0 is free: the index `api/v1/index/qu/iv/quiver_achievement.json`, read on 2026-10-02, lists `0.1.0` only |
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
| On `main`, every CI check completed and green | At `2e6bb77392335a5420b2ff331f072f66f265c16f`: runs `tooling` (37003078145) and `cairo` (37003078164), both completed, success |
| Reviews and audits closed without `blocker` or `major` | Reviews `[Fable 5.1]`: last PASS on `970cff1` after three fix loops; merged as `4243132`. Audits on `[Opus 5.5]` (D-177, before a published interface's publication; Codex out of quota, D-175): organisation PASS WITH FINDINGS ([report](../reports/ARC-07b-audit-opus-organisation-2.md)), cost and access control PASS WITH FINDINGS ([report](../reports/ARC-07b-audit-opus-cost.md)); notes only, one answered in the CHANGELOG (`19a578c`), the others in ARC-07d. ARC-10 ([#37](https://github.com/bal7hazar/quiver/pull/37), Scarb 2.20.1): two reviews by `[Opus 5.5]` (`review-opus`), the first PASS WITH FINDINGS (one minor, fixed), the second PASS WITH FINDINGS (notes only); merged at `c15e515` as `0fd494e`; no audit (D-177) |
| No source changed after the audits and reviews | `git log -- packages/achievement/src`: since ARC-07b's merge (`4243132`, after its reviews and audits), one commit, `0fd494e` ARC-10 (#37), reviewed twice as above. Nothing after it: #38 touched the two changelogs only |
| Changelog and version agree | `Scarb.toml` 0.2.0; `CHANGELOG.md` `## [0.2.0] - 2026-10-02`; `.github/ci/release_check.py quiver_achievement-v0.2.0` passes (`dir=packages/achievement`, `version=0.2.0`) |
| Gas tables of that commit | `packages/achievement/GAS.md` (145 tests), `docs/BUDGETS.md` at that commit, measured on Scarb 2.20.1 and snforge 0.64.0 (figures below) |
| `scarb package` from a clean checkout | 39 files, 226.01 KiB, sha256 as above, identical from two checkouts at different paths. The list: `VERSION`, `CHANGELOG.md`, `GAS.md`, `README.md`, `Scarb.orig.toml`, `Scarb.toml`, `VCS.json` (the commit and `packages/achievement`), `src/` (19 files), `tests/` (13 files); no settings file, no key |
| No test dependency declared as a regular one | `starknet` is the only entry under `[dependencies]`; `snforge_std` is under `[dev-dependencies]` |

## Cost, measured (Scarb 2.20.1 and snforge 0.64.0, by ARC-10; ARC-07b was on 2.19.4 and snforge 0.61)

| Call | L2 gas | Share of the 20M cap |
|---|---|---|
| Worst `progress_many` (16 entries, the slowest merge) | 1 821 093 (progress writes nothing) | 9.1 % |
| Grim World's results call | 838 408 | 4.2 % |
| Worst `define` (3 tasks, `TrackAll`) | 1 232 920 | 6.2 % |
| The game's 26 tiers defined in one transaction | 18 916 390 (18 380 634 at the network's prices) | **94.6 %** (was 92.1 % on 2.19.4; the README says to split) |

Defining the game's 26 tiers in one transaction is at **94.6 % of the 20M cap**, not 92.1 % as on 2.19.4: a
write costs 15 000 more on snforge 0.64. It still fits, with 5.4 % to spare, and the README says to define
over several transactions. The other calls moved by the same toolchain price, none by the code. The network
estimate is snforge minus 20 606 per created slot and 40 106 per overwritten slot.

## What the consumer must do

As for 0.1.0, plus: change the imports to 0.2.0's paths, and choose the tracking with one line,
`impl AchievementTracking = quiver_achievement::store::tracking::TrackAll<ContractState>;` to keep
0.1.0's events.

## Published

The go was given by the project manager under D-186 on 2026-10-02, after the project manager's own D-132
checklist in a clean clone (about 18:4xZ): the commit on `main`, CI green on it, the last source change
reviewed with no blocker or major (ARC-10, #37), the archive rebuilt with `RAYON_NUM_THREADS=1` on Scarb 2.20.1
with the sha256 above, 0.2.0 absent from scarbs.xyz.

Published by the orchestrator's session, by hand, on 2026-10-02: `scarb publish -p quiver_achievement` from one clean
detached checkout of `2e6bb77392335a5420b2ff331f072f66f265c16f`, the archive's sha256 checked with
`sha256sum --check` first. `quiver_quest` was published first. Scarb warned "publishing docs is not supported
by registry"; the package is published.

| | |
|---|---|
| Registry | **https://scarbs.xyz/packages/quiver_achievement**, version 0.2.0 |
| Registry checksum | `sha256:a66de3292e925cdcb2b4c669763d1d75f4aab4edcbe523a2043fb1320449e3db` (the index's `cksum` in `api/v1/index/qu/iv/quiver_achievement.json`, read back after publishing, equal to the approved archive) |
| Consumers need | Scarb 2.20 (`starknet ^2.20.0`, `snforge_std ^0.64.0`) |
| Tag and release | [`quiver_achievement-v0.2.0`](https://github.com/bal7hazar/quiver/releases/tag/quiver_achievement-v0.2.0), annotated, on `2e6bb77` |
