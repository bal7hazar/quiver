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
| ARC-03 | `quiver_quest`: implementation, test-driven, on the accepted API, in two lots: **ARC-03a** the library ([brief](docs/briefs/ARC-03a-quest-logic.md)), **ARC-03b** the component ([brief](docs/briefs/ARC-03b-quest-component.md), superseded after its measurements), **ARC-03c** progress on the player's held quests, D-135 ([brief](docs/briefs/ARC-03c-quest-held.md)); then publication of 0.1.0 after the project manager's go (D-132) | ARC-02 | Opus 5.5 | GPT-6-Astra (access control, ownership) | done: ARC-03a [#6](https://github.com/bal7hazar/quiver/pull/6), ARC-03c [#10](https://github.com/bal7hazar/quiver/pull/10) (ARC-03b measured and superseded); **0.1.0 published** on scarbs.xyz, 2026-09-29 (D-138) |
| ARC-04 | `quiver_achievement` 0.1.0 **in event mode only** ([decision](docs/decisions/2026-09-29-achievement-event-only.md), [brief](docs/briefs/ARC-04-achievement.md)); storage mode with per-task counters later; on the game's path (titles, D-131) | ARC-03 | Opus 5.5 | GPT-6-Astra | done: [#17](https://github.com/bal7hazar/quiver/pull/17); **0.1.0 published** on scarbs.xyz, 2026-09-29 (D-142) |
| ARC-06 | **The pattern of docs/CAIRO.md §7** (owner's rule D-143): model, storage, tracked event, store; its cost against a hand-written write; a reference implementation on one model (the quest definition), shown to the owner before any rework ([brief](docs/briefs/ARC-06-model-store.md)) | — | Opus 5.5 | GPT-6-Sol (organisation, §8), GPT-6-Astra (cost) | done: [#19](https://github.com/bal7hazar/quiver/pull/19); owner's review of the reference model |
| ARC-07 | Both packages rewritten on the pattern as **0.2.0** (the owner's review of ARC-06, D-147: `logic/` removed; each model's event optional for the consumer at compile time, at no cost on a write); in two lots: **ARC-07a** `quiver_quest` ([brief](docs/briefs/ARC-07a-quest-0.2.0.md)), shown to the owner, then **ARC-07b** `quiver_achievement`; publication asked of the project manager | ARC-06, D-147 | Opus 5.5 | GPT-6-Sol (organisation), GPT-6-Astra (cost, access control) | ARC-07a done ([#20](https://github.com/bal7hazar/quiver/pull/20)), accepted (D-167), [mapping to Arcade](docs/research/ARC-07a-arcade-mapping.md); **ARC-07b done** ([#25](https://github.com/bal7hazar/quiver/pull/25), [brief](docs/briefs/ARC-07b-achievement-0.2.0.md), [report](docs/reports/ARC-07b-report.md)), reviews by Fable, audits on Opus (D-177) |
| ARC-07c | `quiver_quest`'s unit tests moved into their modules' files (D-167, docs/CAIRO.md §2); no change of code, budgets moved with their tests | ARC-07b | Sonnet 5.5 | — (D-177: review only) | done: [#28](https://github.com/bal7hazar/quiver/pull/28), [report](docs/reports/ARC-07c-report.md) |
| ARC-07d | Deferred notes of ARC-07b's organisation audit (`[Opus 5.5]`, 2026-10-01), for both packages: (1) the rule of when slot B (achievement) or slot C (quest) holds data is written twice, in the component's view and in `Store::get_definition`: one store read for the view; (5) test names inside a module mixing 0.1.0's prefixes, if the owner wants them aligned; and two optional tests of the cost audit (`[Opus 5.5]`): a 0.1.0-packed slot A unpacked by 0.2.0 reads `points` 0; a refusal tested under a `TrackNone` mock | ARC-07b, ARC-07c | Sonnet 5.5 | — | todo, after the 0.2.0 publications, since its notes touch the packages' code (project manager, 2026-10-02). Reversed if the owner asks sooner, or if 0.2.0 is not published within a few days: then ARC-07d goes first and the publication requests are re-measured |
| ARC-09 | Measured and packaged builds single-threaded, `RAYON_NUM_THREADS=1` (the game's D-176): CI's `package` job, `release.yml`, the manual steps, `scripts/gas.py`; whether any figure of 0.2.0 moves, measured, and the tables again if one does ([brief](docs/briefs/ARC-09-single-threaded-builds.md)) | ARC-07b, ARC-07c merged | Sonnet 5.5 | — (review) | done: [#32](https://github.com/bal7hazar/quiver/pull/32) (`7066040`) |
| ARC-10 | The workspace on the latest Scarb, 2.20.1, and starknet-foundry 0.64.0 (the owner's D-180): pins, CI, every gas figure re-measured; the 0.2.0 versions carry the moved figures ([brief](docs/briefs/ARC-10-scarb-latest.md)) | ARC-09; SPK-13's test of the drift on 2.20.1; the toolchain installed on the VPS (the owner's) | Sonnet 5.5 | — (review, D-177) | done: [#37](https://github.com/bal7hazar/quiver/pull/37) (`0fd494e`) |
| ARC-11 | `scripts/gas.py --write` keeps every section of `GAS.md` after the generated table (today it rewrites the file whole and drops the hand-written sections, ARC-09's escalation) | ARC-10 merged (ARC-10 rewrites GAS.md's figures) | Sonnet 5.5 | — (review only, D-177) | done: [#41](https://github.com/bal7hazar/quiver/pull/41) (`621baa5`), [report](docs/reports/ARC-11-report.md) |
| ARC-12 | Three safety fixes to `scripts/gas.py`, notes of the review of ARC-11: `--write` refuses a non-empty `GAS.md` with no generated table; the generated table ends at its last generated row, not at the first line without `\|`; `--check` reads the generated table only. No package file changes (the 0.2.0 archives wait for the owner's go) | ARC-11 merged | Sonnet 5.5 | — (review only, D-177) | in progress |
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
