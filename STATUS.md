# Status

**2026-09-29 06:25 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

## Where we are

**Track ARC is idle; its slot `quiver-1` is free for the other tracks.** No agent runs and none is
queued.

Both packages the game needs are published on scarbs.xyz, each after the project manager's go:

| Package | Version | Registry | Commit | Record |
|---|---|---|---|---|
| `quiver_quest` | 0.1.0 | https://scarbs.xyz/packages/quiver_quest | `364462f` | [D-138](docs/decisions/2026-09-29-publish-quiver_quest-0.1.0.md) |
| `quiver_achievement` | 0.1.0 (event mode only) | https://scarbs.xyz/packages/quiver_achievement | `50017e7` | [D-142](docs/decisions/2026-09-29-publish-quiver_achievement-0.1.0.md) |

**What wakes the track:**

- the game's needs, through its `docs/needs/arcade.md`, when it embeds the packages (GLD-02 for
  quests, the titles after it), answered by a 0.1.x or a 0.2.0;
- a defect found in a published version: a fix is a new version, asked and checked like the first;
- ARC-05 (`leaderboard`, `social`), after the game's MVP and a decision of the project manager.

At each check-in the orchestrator also reads the game's CHANGELOG for a new audited launcher reference,
and syncs `scripts/agent.sh` in one pull request if it differs (the one pending: the probe race fixed in
the game's `74c7d50`).

## What moved

| | |
|---|---|
| ARC-00 | [#1](https://github.com/bal7hazar/quiver/pull/1): the repository's minimum, launcher, build lock, profiles, CI of the tooling and the links. [#3](https://github.com/bal7hazar/quiver/pull/3): every profile denies `scarb publish` and reading the user-level settings (D-128). [#5](https://github.com/bal7hazar/quiver/pull/5): every agent runs with the registry token and the Sepolia variables emptied (port of grimworld#38) |
| ARC-01 | [#2](https://github.com/bal7hazar/quiver/pull/2) merged: [docs/research/ARC-01-quest-achievement.md](docs/research/ARC-01-quest-achievement.md). ADR-0004 points 3 and 4 all confirmed, ten further defects, the full API, needs A-1 to A-9, cost estimates, the workspace and CI by affected package, twenty questions. `[GPT-6-Sol]` audit: FAIL, FAIL, then PASS WITH FINDINGS after three fix loops; reports archived in [docs/reports/](docs/reports/ARC-01-report.md) |
| ARC-02 | [#4](https://github.com/bal7hazar/quiver/pull/4) merged: root `Scarb.toml`, `quiver_quest` and `quiver_achievement` skeletons (bounds as constants, one budgeted test each), `cairo.yml` by affected package (base-branch script, fail closed, summary job `cairo`), `scripts/gas.py` (every source test measured and budgeted, `GAS.md` checked), `release.yml` (checks and `scarb package`, no publish), [docs/WORKSPACE.md](docs/WORKSPACE.md). `[GPT-6-Luna]` audit: FAIL, FAIL, then closed by the orchestrator (one finding refuted as a repository limit, D-121); reports in docs/reports |
| ARC-03a | [#6](https://github.com/bal7hazar/quiver/pull/6) merged: `quiver_quest::logic`, types, one-felt packing with field-width and reserved-bit checks, pure functions and errors of the accepted API; 166 tests (36 benchmarks) with budgets; worst case of `batch_merge` 753 k L2 gas (a late duplicate among 16 entries). Reports in docs/reports |
| ARC-03c | [#10](https://github.com/bal7hazar/quiver/pull/10) merged: `quiver_quest` 0.1.0, the component on the player's held quests (D-135): acceptance mandatory, at most 4 held, 30-bit acceptance numbers, held-list slots kept; worst calls measured under 20M (6.21M at H = 4); 423 tests within budget. Four fix loops (the fourth an exception of the project manager); `[GPT-6-Astra]` four passes, the last PASS WITH FINDINGS. Reports in docs/reports |
| ARC-04 | [#17](https://github.com/bal7hazar/quiver/pull/17) merged: `quiver_achievement` 0.1.0 in event mode only (definitions stored, progress as events, reporter access control, no storage mode by absence); worst `progress_many` 1.82M L2 gas; 102 tests within budget. `[GPT-6-Astra]` PASS WITH FINDINGS, two minors fixed. Reports in docs/reports |

## Agents

None running.

## Budget

The game's OPERATIONS §3: caps game 2, map library 1, **quiver 1 (the slot `quiver-1`), audits
included**, total 3, held as slot locks by the launcher (`scripts/agent.sh slots`); the game comes
first: no quiver launch while `~/orchestrator/waiting/game` is less than 30 minutes old. The track is
idle: `quiver-1` is free.

## Open

Nothing open with the project manager.
