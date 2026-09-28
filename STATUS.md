# Status

**2026-09-28 20:34 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

## Where we are

**Gate A-G1 accepted** by the project manager on 2026-09-28 (D-131): option A, the API with
the recommended answers to Q-1 to Q-20
([decision](docs/decisions/2026-09-28-A-G1-api.md)). The game answered its questions: a held
contract is lost at rollover (A-11), at most 16 distinct tasks per call, enforced by the game
(A-10), no repeatable quest without an interval in 0.1, titles on `quiver_achievement` in event
mode (ARC-04 is on the game's path). **Next: ARC-02** on Sonnet 5.5
([brief](docs/briefs/ARC-02-workspace.md)): pull request
[#4](https://github.com/bal7hazar/quiver/pull/4), CI green; the `[GPT-6-Luna]` audit returned FAIL
(5 majors, 1 minor, 1 note, all verified); **fix loop 1** runs. Then
ARC-03 on Opus 5.5 with a `[GPT-6-Astra]` audit. Publication is not granted: asked when
ARC-03 is accepted.

## What moved

| | |
|---|---|
| ARC-00 | [#1](https://github.com/bal7hazar/quiver/pull/1): the repository's minimum, launcher, build lock, profiles, CI of the tooling and the links. [#3](https://github.com/bal7hazar/quiver/pull/3): every profile denies `scarb publish` and reading the user-level settings (D-128). [#5](https://github.com/bal7hazar/quiver/pull/5): every agent runs with the registry token and the Sepolia variables emptied (port of grimworld#38) |
| ARC-01 | [#2](https://github.com/bal7hazar/quiver/pull/2) merged: [docs/research/ARC-01-quest-achievement.md](docs/research/ARC-01-quest-achievement.md). ADR-0004 points 3 and 4 all confirmed, ten further defects, the full API, needs A-1 to A-9, cost estimates, the workspace and CI by affected package, twenty questions. `[GPT-6-Sol]` audit: FAIL, FAIL, then PASS WITH FINDINGS after three fix loops; reports archived in [docs/reports/](docs/reports/ARC-01-report.md) |

## Agents

| Task | Unit | Model asked / ran | Profile | State |
|---|---|---|---|---|
| ARC-02 workspace and CI | `quiver-ARC-02-203136` (resumed) | `claude-sonnet-5-5` / `claude-sonnet-5-5` | implement | Fix loop 1 since 20:31 UTC |

ARC-01 ran on `claude-opus-5-5` (asked and ran), profile `research`, from 19:25
to 20:11 UTC over four runs; its audit on `gpt-6-sol`, three passes.

## Budget

D-118 and the game's OPERATIONS §3: after ARC-01 and its audit, this track has no slot of its
own before the game's Phase 2; it launches only while fewer than 3 Grim World agents run and
the game has nothing ready.

## Open

| | |
|---|---|
