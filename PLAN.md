# Plan — track ARC, the Arcade packages, native

Owned by the orchestrator of `quiver`. The track is defined by the plan of Grim World
([PLAN.md § Track ARC](https://github.com/bal7hazar/grimworld/blob/main/PLAN.md), decisions
D-124, D-125, D-126), [ADR-0007](https://github.com/bal7hazar/grimworld/blob/main/docs/architecture/ADR-0007-native-starknet.md)
§ Arcade packages, and the game's needs in
[docs/needs/arcade.md](https://github.com/bal7hazar/grimworld/blob/main/docs/needs/arcade.md).
This file is the detail; the game's plan keeps the summary.

## Goal

The packages of the owner's Arcade suite that Grim World uses, **rewritten without Dojo** as
pure Cairo libraries and pure Starknet components, one Scarb package each, published on
scarbs.xyz and consumed by the game **by version**.

| | |
|---|---|
| Reference | `cartridge-gg/arcade`, `packages/quest` and `packages/achievement` (MIT by the owner's statement) |
| Order | `quiver_quest` (needed by the game's GLD-02, Phase 3), then `quiver_achievement` (titles); `leaderboard` and `social` after the game's MVP |
| CI | Runs the checks of the packages a change touches and of those that depend on them; the whole workspace on `main` and before a release |
| Publication | Per package (D-132, the game's OPERATIONS §7 "Publications"). **No sub-agent publishes, ever.** The orchestrator's session publishes, only after a go of the project manager naming the package, the version and the commit, asked with `docs/decisions/PENDING-publish-<package>-<version>.md` and one message; the project manager checks the commit, CI, audits, changelog, gas tables, `scarb package` from a clean checkout, the registry and the dependencies first |
| Out of scope | Moving the owner's other `*-cairo` libraries here: the owner decides, library by library |

## Tasks

| ID | Task | Depends on | Executor | Audits | Status |
|---|---|---|---|---|---|
| ARC-00 | The repository: name, visibility (owner); minimum, launcher, CI of the tooling | — | Project manager; orchestrator | — | done: `bal7hazar/quiver`, first pull request |
| ARC-01 | **Analysis** of `quest` and `achievement` as they are: data model, modes, hooks, intervals, prerequisites, claim, what depends on Dojo; the defects of ADR-0004 points 3 to 5 confirmed or refuted as test cases; the **API of the native packages**; coverage of the game's needs A-1 to A-9; cost per call; the workspace and its CI by affected package. Report `docs/research/ARC-01-quest-achievement.md` | ARC-00 | Opus 5.5, research | GPT-6-Sol | done: [#2](https://github.com/bal7hazar/quiver/pull/2), three fix loops |
| **Gate A-G1** | **Is the API accepted?** The project manager decides on the recommendation (D-128). Package names confirmed with the registry's availability | ARC-01 | Project manager | — | **accepted** 2026-09-28, D-131: [decision](docs/decisions/2026-09-28-A-G1-api.md) |
| ARC-02 | Workspace, **CI by affected package**, gas tooling, publication pipeline per package ([brief](docs/briefs/ARC-02-workspace.md)) | A-G1 | Sonnet 5.5 | GPT-6-Luna | done: [#4](https://github.com/bal7hazar/quiver/pull/4), two fix loops |
| ARC-03 | `quiver_quest`: implementation, test-driven, on the accepted API, in two lots: **ARC-03a** the library ([brief](docs/briefs/ARC-03a-quest-logic.md)), **ARC-03b** the component ([brief](docs/briefs/ARC-03b-quest-component.md), superseded after its measurements), **ARC-03c** progress on the player's held quests, D-135 ([brief](docs/briefs/ARC-03c-quest-held.md)); then publication of 0.1.0 after the project manager's go (D-132) | ARC-02 | Opus 5.5 | GPT-6-Astra (access control, ownership) | done: ARC-03a [#6](https://github.com/bal7hazar/quiver/pull/6), ARC-03c [#10](https://github.com/bal7hazar/quiver/pull/10) (ARC-03b measured and superseded); publication of 0.1.0 to ask |
| ARC-04 | `quiver_achievement`: implementation, release; on the game's path (titles in event mode, D-131) | ARC-03 | Opus 5.5 | GPT-6-Astra | todo |
| ARC-05 | `leaderboard`, `social` | After the game's MVP | — | — | todo |

## Budget and rules

**One agent at a time** for this track, **audits included** (the game's OPERATIONS §3 at
`377576a`: caps game 2, map library 1, quiver 1, total 3), and **the game comes first**: before
each launch the orchestrator checks `~/orchestrator/waiting/game`; if it exists and is less than 30
minutes old, it launches nothing and checks again later (by hand until the launcher reference
enforces it). Thresholds of the
launcher: no launch above a 5-minute load of 12 or under 8 GB available. Rules: the game's OPERATIONS.md; common rules of briefs:
[docs/briefs/COMMON.md](docs/briefs/COMMON.md); Cairo rules: [docs/CAIRO.md](docs/CAIRO.md).
After three fix loops on one lot, the orchestrator escalates to the project manager.
**Launcher**: `scripts/agent.sh` follows the game's, the reference of the three launchers: the
commit of the game's `scripts/agent.sh` that its CHANGELOG marks as "launcher reference" after a
passed audit. The orchestrator reads it at its check-ins and syncs in one pull request naming the
commit; a sync never delays a task of the track. At the next sync, the profiles also deny `pkill`, `killall`,
`git clean`, `git worktree prune` and deletions by wildcard outside the worktree (the game's
OPERATIONS §3, "The machine is shared").
