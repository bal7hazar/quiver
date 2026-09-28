# Status

**2026-09-28 21:57 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

## Where we are

**Gate A-G1 accepted** by the project manager on 2026-09-28 (D-131): option A, the API with
the recommended answers to Q-1 to Q-20
([decision](docs/decisions/2026-09-28-A-G1-api.md)). The game answered its questions: a held
contract is lost at rollover (A-11), at most 16 distinct tasks per call, enforced by the game
(A-10), no repeatable quest without an interval in 0.1, titles on `quiver_achievement` in event
mode (ARC-04 is on the game's path). **ARC-02 merged** ([#4](https://github.com/bal7hazar/quiver/pull/4)): the workspace, two
package skeletons, CI by affected package, the gas tool, a release check that never publishes.
**ARC-03a merged** ([#6](https://github.com/bal7hazar/quiver/pull/6)): the library of
`quiver_quest`, 166 tests within budget; `[GPT-6-Astra]` audit FAIL (packing could let a narrow
field spill into its neighbour, reserved bits unchecked), then PASS WITH FINDINGS after one fix
loop. **Next: ARC-03b**, the component ([brief](docs/briefs/ARC-03b-quest-component.md)), on Opus
5.5 with a `[GPT-6-Astra]` audit, launched when a Grim World slot is free. Publications follow
D-132: no sub-agent publishes; the orchestrator asks the project manager with a
`PENDING-publish-*` file and publishes after a go naming package, version and commit.

## What moved

| | |
|---|---|
| ARC-00 | [#1](https://github.com/bal7hazar/quiver/pull/1): the repository's minimum, launcher, build lock, profiles, CI of the tooling and the links. [#3](https://github.com/bal7hazar/quiver/pull/3): every profile denies `scarb publish` and reading the user-level settings (D-128). [#5](https://github.com/bal7hazar/quiver/pull/5): every agent runs with the registry token and the Sepolia variables emptied (port of grimworld#38) |
| ARC-01 | [#2](https://github.com/bal7hazar/quiver/pull/2) merged: [docs/research/ARC-01-quest-achievement.md](docs/research/ARC-01-quest-achievement.md). ADR-0004 points 3 and 4 all confirmed, ten further defects, the full API, needs A-1 to A-9, cost estimates, the workspace and CI by affected package, twenty questions. `[GPT-6-Sol]` audit: FAIL, FAIL, then PASS WITH FINDINGS after three fix loops; reports archived in [docs/reports/](docs/reports/ARC-01-report.md) |
| ARC-02 | [#4](https://github.com/bal7hazar/quiver/pull/4) merged: root `Scarb.toml`, `quiver_quest` and `quiver_achievement` skeletons (bounds as constants, one budgeted test each), `cairo.yml` by affected package (base-branch script, fail closed, summary job `cairo`), `scripts/gas.py` (every source test measured and budgeted, `GAS.md` checked), `release.yml` (checks and `scarb package`, no publish), [docs/WORKSPACE.md](docs/WORKSPACE.md). `[GPT-6-Luna]` audit: FAIL, FAIL, then closed by the orchestrator (one finding refuted as a repository limit, D-121); reports in docs/reports |
| ARC-03a | [#6](https://github.com/bal7hazar/quiver/pull/6) merged: `quiver_quest::logic`, types, one-felt packing with field-width and reserved-bit checks, pure functions and errors of the accepted API; 166 tests (36 benchmarks) with budgets; worst case of `batch_merge` 753 k L2 gas (a late duplicate among 16 entries). Reports in docs/reports |

## Agents

| Task | Unit | Model asked / ran | Profile | State |
|---|---|---|---|---|
| ARC-03b quest component | — | `claude-opus-5-5` / — | implement | Ready; waits for a slot |

ARC-01 ran on `claude-opus-5-5` (asked and ran), profile `research`, from 19:25
to 20:11 UTC over four runs; its audit on `gpt-6-sol`, three passes.

## Budget

D-118 and the game's OPERATIONS §3: after ARC-01 and its audit, this track has no slot of its
own before the game's Phase 2; it launches only while fewer than 3 Grim World agents run and
the game has nothing ready.

## Open

| | |
|---|---|
