# `quiver_leaderboard` 0.1.0 — publication request (pending the owner's go)

| | |
|---|---|
| Asked by | `[Sonnet 5.5]` thread of track ARC, for the orchestrator of `quiver` |
| Decides | The owner. D-186 does not cover this package: no go has been given, and nothing is published, tagged or released by this request |
| Package | **`quiver_leaderboard`** (`packages/leaderboard`) |
| Version | **0.1.0**, the first |
| Commit | `3f0912507e9e71e1adeac663037050d468596861` (`main`, #63, after ARC-05a #62), 2026-10-07 |
| Archive | `quiver_leaderboard-0.1.0.tar.zst`, sha256 **f8900c602c983acbbc39513a964eefacdbcb861902b2501d9e50b891981e770e** (`RAYON_NUM_THREADS=1 scarb package -p quiver_leaderboard` from a clean checkout of that commit, Scarb 2.20.1; D-176; 21 files, 71.51 KiB, 14.76 KiB compressed). The two sha256, from two fresh detached worktrees of that commit at different absolute paths and depths, are identical |
| Registry | scarbs.xyz; 0.1.0 is free: the index `api/v1/index/qu/iv/quiver_leaderboard.json`, read on 2026-10-07, answers HTTP 404, so the package has no record at all. The same URL form for `quiver_quest` (`api/v1/index/qu/iv/quiver_quest.json`) lists `0.1.0` and `0.2.0` |
| Published by | Not yet. By hand, after the owner's go, from a clean checkout of that commit, the archive's sha256 compared first; no agent, no CI |

## What the package is

A top-3 leaderboard for Starknet games, written from Paved's specification (licence D-230: no Arcade
code), as internal code on the consumer's own storage: the `LeaderboardStorage` storage node, with
`submit`, `ranked` and `top` as trait methods on its storage path. Top 3, 4 slots per tournament (one
word of three scores, one player slot per rank). No entry point, no event; `LeaderboardSubmitted` is an
event type a consumer may emit itself (`CHANGELOG.md` `[0.1.0]`).

## What was checked, at that commit

| The check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | At `3f0912507e9e71e1adeac663037050d468596861`: runs `tooling` (37659598769) and `cairo` (37659598754), both completed, success. CI's gas check passed at the reviewed head (`32d76ad`, #62) |
| Reviews and audits closed without `blocker` or `major` | ARC-05a ([#62](https://github.com/bal7hazar/quiver/pull/62)): review `[Opus 5.5]` (`review-opus`) PASS at `32d76ad`, after one fix loop; D-232 deviation on slot 3 (see GAS.md, "Unchanged slots"); licence D-230. No audit, and no external entry point |
| No source changed after the review | #63, the only commit after #62, touched `packages/leaderboard/CHANGELOG.md` only (`[Unreleased]` became `[0.1.0] - 2026-10-07`) |
| Changelog and version agree | `Scarb.toml` 0.1.0; `CHANGELOG.md` `## [0.1.0] - 2026-10-07`; `.github/ci/release_check.py quiver_leaderboard-v0.1.0` passes (`dir=packages/leaderboard`, `version=0.1.0`) |
| Gas table of that commit | `packages/leaderboard/GAS.md` at that commit (figures below) |
| `scarb package` from a clean checkout | 21 files, 71.51 KiB, sha256 as above, identical from two checkouts at different paths. The list: `VERSION`, `CHANGELOG.md`, `GAS.md`, `README.md`, `Scarb.orig.toml`, `Scarb.toml`, `VCS.json` (the commit and `packages/leaderboard`, no dirty flag), `src/` (13 files: `bench`, `events/submitted`, `leaderboard`, `lib`, `models/index`, `models/scores`, `store`, `testing/mock`, `testing/reference`, `types/ranked`, `types/submission`, `types/top3`), `tests/` (`mocks`, `test_contract`); no settings file, no key |
| The checkouts were clean | Each is a fresh `git worktree add --detach` of the commit, used for nothing else; the archive's `VCS.json` carries the commit and no dirty flag |
| No test dependency declared as a regular one | `starknet` (`^2.20.0`) is the only entry under `[dependencies]`; `assert_macros` and `snforge_std` are under `[dev-dependencies]` |

## Cost, measured (Linux, Scarb 2.20.1, snforge 0.64.0, `RAYON_NUM_THREADS=1`, L2 gas)

From `packages/leaderboard/GAS.md` at that commit. Each operation is its benchmark minus its baseline
(the same board built without the call). The figures are **flat** at 10, 100 and 1 000 prior
submissions. The network estimate reprices the slots written (−20 606 per created slot, −40 106 per
overwritten one).

| Operation | After 10 / 100 / 1 000 | Paved's ceiling | Network estimate | Against 20 M cap |
|---|---|---|---|---|
| `submit` rank 1, two shifted (worst; 4 overwritten) | 427 420 | 1 300 000 | 266 996 | 2.1 % |
| `submit` rank 2 (3 overwritten) | 313 540 | 1 300 000 | 193 222 | 1.6 % |
| `submit` rank 3 (2 overwritten) | 198 050 | 1 300 000 | 117 838 | 1.0 % |
| `submit` not placed, below rank 3 | 47 920 | 600 000 | 47 920 | 0.2 % |
| `submit` not placed, equal to rank 3 | 47 920 | 600 000 | 47 920 | 0.2 % |
| `submit` score 0 / player 0 | 0 | 600 000 | 0 | 0 % |
| `top`, full board | 163 910 | 600 000 | 163 910 | 0.8 % |
| `ranked`, full rank | 83 450 | 300 000 | 83 450 | 0.4 % |
| `ranked`, empty rank | 44 530 | 300 000 | 44 530 | 0.2 % |

The first submissions of a tournament create slots and do not depend on prior submissions:

| Submission | Call | Network estimate | Paved's ceiling |
|---|---|---|---|
| 1st (rank 1 on an empty board) | 1 005 030 | 963 818 | 1 300 000 |
| 2nd (rank 2) | 602 200 | 541 488 | 1 300 000 |
| 3rd (rank 3) | 599 750 | 539 038 | 1 300 000 |
| rank 1 on a board of two | 829 680 | 688 756 | 1 300 000 |

Every ceiling is met; the largest figure is the first submission (1 005 030 against 1 300 000).

## What the consumer must do

Compile with Scarb 2.20 (`starknet ^2.20.0`, `snforge_std ^0.64.0` for tests). Hold a
`LeaderboardStorage` in the contract's storage and call `submit`, `ranked` and `top` through its
storage path; the package has no entry point and emits no event, so the consumer exposes the calls and
emits `LeaderboardSubmitted` itself if it wants the event.

## To publish (after the go)

`scarb publish -p quiver_leaderboard` from one clean detached checkout of
`3f0912507e9e71e1adeac663037050d468596861`, `sha256sum --check` of the archive first; then the
annotated tag `quiver_leaderboard-v0.1.0` on that commit. This file is then renamed (the `PENDING-`
prefix dropped) and completed with the registry's checksum, as the 0.2.0 records are.
