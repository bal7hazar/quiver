# `quiver_achievement` 0.1.0 — published 2026-09-29 (D-142)

| | |
|---|---|
| Asked by | `[Opus 5.5]` orchestrator of `quiver`, 2026-09-29 |
| Decides | The project manager (D-132): a go that names the package, the version and the commit |
| Package | **`quiver_achievement`** (`packages/achievement`) |
| Version | **0.1.0**, the first |
| Commit | **`50017e7576fd7d8228016a450f6ccdfac5044f1d`** on `main` (`50017e7`) |
| Archive | `quiver_achievement-0.1.0.tar.zst`, sha256 **`1473a07fcbe1298a9ba85ef07b1b5afc63816c1fcbe3c5c10151908ae7a4d9d9`** |
| Registry | scarbs.xyz; the name is free (`api/v1/index/qu/iv/quiver_achievement.json` answered 404 on 2026-09-29) |
| Published by | The orchestrator's session, by hand, after the go, from a clean checkout of that commit, the archive's sha256 compared first; no agent, no CI |

## What it is

Achievements for Starknet games, without Dojo, **in event mode only**
([decision of 2026-09-29](2026-09-29-achievement-event-only.md)): definitions (a window, 1 to 3 tasks
with a target count, points in the event) stored once and retirable; progress reported **as events
only** (`AchievementProgressed`, one per merged non-zero task, at most 16 distinct tasks per call);
tiers are separate achievements sharing a task (A-7), derived by an indexer from the definitions and
the events. No per-player storage, no completion, no claim, and no `Mode` type: storage mode cannot be
asked for. Only registered reporters report progress; definitions, retirement and reporters through
the consumer's `authorize_admin` hook. A storage design with per-task counters is planned for a later
version; 0.1.0 reserves none of its layout.

## What was checked, at that commit

| The project manager's check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | `tooling` and `cairo` both **success** on `50017e7`; the `package (packages/achievement)` job ran on #17 and #18 (build, 102 tests, gas check) |
| Audits closed without `blocker` or `major` | ARC-04 `[GPT-6-Astra]`: [PASS WITH FINDINGS](../reports/ARC-04-audit-gpt-6-astra-1.md), no blocker or major, no access-control bypass, no storage-mode path; its two minors fixed in `36b8a3c` (the bit-251 test; the description) |
| No source changed after the audit | The audited commit is `33f674c`; the fix loop changed one test and the description; between the pull request's head `ffacba6` and `50017e7`, the package differs by the changelog's date only |
| Changelog and version agree | `Scarb.toml` 0.1.0; `CHANGELOG.md` section `[0.1.0] - 2026-09-29`; `.github/ci/release_check.py quiver_achievement-v0.1.0` passes |
| Gas tables of that commit | `packages/achievement/GAS.md` (102 tests within `ceil(1.05 × measured)`) and `docs/BUDGETS.md` |
| `scarb package` from a clean checkout | A fresh clone at `50017e7`, Scarb 2.19.4: packaged and verified, 32 files, 26.53 KiB; sha256 above; no settings file or key in the archive |
| Name and version free on the registry | `quiver_achievement`: 404 on the index |
| No test dependency declared as a regular one | Packaged manifest: `[dependencies] starknet ^2.19.0` only; `snforge_std ^0.61.0` under dev-dependencies |

## Cost, measured

| Call | L2 gas | Share of the 20M cap |
|---|---|---|
| Worst `progress_many` (16 entries, the slowest merge path) | 1 816 813 (network: the same; progress writes nothing) | 9.1 % |
| Grim World's results call (6 character and 2 account tasks) | 829 728 | 4.1 % |
| Worst `define` (3 tasks) | 1 197 030 (network 1 185 818) | 6.0 % |

Progress reads no definition, so its cost does not depend on how many achievements share a task.
Defining the game's 26 title tiers in one transaction costs about 18.5M: the README tells consumers
to split definitions over several transactions (judged adequate by the audit).

## What the consumer must do

- Depend on `quiver_achievement = "0.1.0"`; embed the component, implement `authorize_admin`, embed
  the view impl, and the external ABI only if it wants it; register its reporters (or call the
  internal layer from its own checked entrypoints).
- Aggregate progress by task id; call `progress_many` once per player per transaction, at most 16
  distinct tasks.
- Run an indexer that applies windows, retirement and tier thresholds; progress on a task that no
  live achievement uses still emits an event, which the indexer ignores.
- For Grim World: titles in event mode (D-131), A-7 answered by tiers sharing a task.

## Answer and publication

Go given by the project manager `[Fable 5.1]` in the owner's name on 2026-09-29, **D-142**
([record in the game](https://github.com/bal7hazar/grimworld/blob/main/docs/decisions/2026-09-29-publish-quiver_achievement-0.1.0.md),
`32d204e`), for that package, that version, that commit and that archive only.

Published by the orchestrator's session, by hand, on 2026-09-29: a fresh clone at `50017e7`,
`scarb --manifest-path packages/achievement/Scarb.toml package` with Scarb 2.19.4 gave sha256
`1473a07fcbe1298a9ba85ef07b1b5afc63816c1fcbe3c5c10151908ae7a4d9d9`, equal to the go's; then
`scarb … publish` from the same checkout.

| | |
|---|---|
| Registry | **https://scarbs.xyz/packages/quiver_achievement**, version 0.1.0 |
| Registry checksum | `sha256:1473a07fcbe1298a9ba85ef07b1b5afc63816c1fcbe3c5c10151908ae7a4d9d9` (the index's `cksum`, equal to the approved archive) |
| Recorded dependencies | `starknet ^2.19.0` (normal), `snforge_std ^0.61.0` (test) |
| Tag and release | [`quiver_achievement-v0.1.0`](https://github.com/bal7hazar/quiver/releases/tag/quiver_achievement-v0.1.0), on `50017e7`, with the archive attached |
