# Status

**2026-09-28 22:47 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

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
5.5: done (21:56 to 22:19 UTC), [#7](https://github.com/bal7hazar/quiver/pull/7), 292 tests within
budget, CI green; the reads and writes of every worst case equal the §5.1 estimates. The worst
`progress_many` (16 tasks, each shared by 28 live quests with 7 prerequisites first observed)
measures **about 704 M L2 gas** for the component alone: to compare with the network's
per-transaction limit before relying on the bound at its maximum. The `[GPT-6-Astra]` audit
returned **FAIL** (a quest retired by a hook during a progress call could still complete; hook
re-entry and the `live_dependents` ceiling untested; the late-collision merge path not
benchmarked); no access-control bypass was found. Against the published ceiling of 1.1 billion
L2 gas per transaction, the worst case uses 64 %. **The project manager ruled that unacceptable**
([amendment to A-G1](docs/decisions/2026-09-28-A-G1-amendment-cost-cap.md)): the worst call the
package allows must stay under 20M L2 gas, with caps refused at definition time, quests per task
cut first, and the game's own use benchmarked. **Fix loop 1** (the audit's findings) is done
(22:29 to 22:40 UTC: a quest retired by a hook is skipped; re-entry, the dependents ceiling and
the slow merge path tested; 310 tests within budget, CI green). **Fix loop 2** (the cost cap)
waits for a slot, then the `[GPT-6-Astra]` re-audit.

**Launcher** ([#8](https://github.com/bal7hazar/quiver/pull/8), CI green, `[GPT-6-Sol]` audit
waiting for a slot): the budget of 3 counted by the launcher across the three tracks, failing
closed, and the count and start under the shared lock `~/orchestrator/agent-launch.lock`, ported
from the game's `scripts/agent.sh` at `e3a2e75` (#48). **Inherited findings**, from the audit of
the library's port (bal7hazar/hexx-cairo#24), to fix when the game's launcher does: a codex audit
started under another command form without a pid file is not counted; an unreadable pid record is
skipped instead of refusing the launch. Until #8 merges, launches go through its launcher.

Budget slip, 22:28 UTC: the orchestrator resumed ARC-03b while three Grim World agents ran (two
codex audits of the game and the library were counted, then overlooked); it stopped the run
after 15 seconds, before any change, and resumes it when fewer than 3 run. Publications follow
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
| ARC-03b quest component | `quiver-ARC-03b-*` (resumed) | `claude-opus-5-5` / `claude-opus-5-5` | implement | Fix loop 1 done; fix loop 2 waits for a slot |
| PR-8 audit | setsid (codex) | `gpt-6-sol` | audit | Waits for a slot |
| ARC-03b audit | setsid (codex) | `gpt-6-astra` / `gpt-6-astra` | audit | FAIL at 22:27 UTC; to resume on the fixes |

ARC-01 ran on `claude-opus-5-5` (asked and ran), profile `research`, from 19:25
to 20:11 UTC over four runs; its audit on `gpt-6-sol`, three passes.

## Budget

D-118 and the game's OPERATIONS §3: after ARC-01 and its audit, this track has no slot of its
own before the game's Phase 2; it launches only while fewer than 3 Grim World agents run and
the game has nothing ready.

## Open

| | |
|---|---|
