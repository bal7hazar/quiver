# Status

**2026-09-29 06:00 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

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
the slow merge path tested; 310 tests within budget, CI green). **Fix loop 2** (the cost cap,
22:44 to 23:42 UTC) measured `progress_many` on a grid of 111 points (model within 0.02 %),
removed about 3 % of waste, measured the game's own use at **10.1M**, and **stopped as its brief
said**: a completed quest costs about 1.17M, most of it its two changed storage slots, so even one
quest per task and no prerequisite measures 20.6M at 16 tasks. **Decided by the project manager,
D-135** ([decision](docs/decisions/2026-09-28-quest-cost-cap.md)): acceptance mandatory, at most
H = 4 held quests per player (8 at most), progress walks the held list, prerequisites checked at
acceptance. **ARC-03c done** (23:49 to 00:28 UTC, [#10](https://github.com/bal7hazar/quiver/pull/10),
CI green; #7 closed as superseded): every quest accepted, at most 4 held (the code works up to 8),
progress walks the held list. **Measured worst calls**: 6.1M (4 held, hooks empty), 11.3M (8 held),
7.9M and 14.9M with a hook writing one slot per completion; the game's use 5.3M; all under the 20M
cap. Its `[GPT-6-Astra]` audit ([report](docs/reports/ARC-03c-audit-gpt-6-astra-1.md)) returned
**FAIL** (no authorization bypass, double claim or packing corruption found): the 402 000 L2 gas
charge is Starknet's allocation cost (a cell going from zero to non-zero), not the cost of every
changed slot, so the update costs and corrections are overstated (the worst calls, with fresh
slots, stand); a hook that abandons and re-accepts a quest lets the outer call progress it; the
one-write tests assert state, not writes. **Fix loop 1** done (00:43 to 01:15 UTC): transition
probes confirm the allocation charge (402 000, a new cell only; updates 57 106); claim 0.36M,
abandon 0.54M, the game's case 4.53M, worst accept 1.89M; worst calls 6.19M, 8.00M (H = 4),
11.38M, 15.01M (H = 8), all fresh slots; acceptance numbers in held entries close the renewal
hole; the writes of progress asserted by gas. **Fix loop 2** done (01:16 to 02:05 UTC): the
worst call measured with the player's slots created (6.18M at H = 4; 15.00M at H = 8 with a
one-slot hook) and existing (2.97M; 8.57M), each with the network's estimate (453 500 per created
slot, 32 000 per overwritten); created and overwritten slots per entrypoint documented; held-list
slots kept instead of zeroed. The `[GPT-6-Astra]` re-audit ([report](docs/reports/ARC-03c-audit-gpt-6-astra-2.md))
resolved the cost model and found no defect in the kept slots, but **FAIL** on the acceptance
number (a u16 that wraps over a player's lifetime can be reused by a renewed entry) and on write
counts that gas cannot prove; the orchestrator decided the second (the rule's purpose is cost,
bounded by the gas guards; exact writes recorded with `--detailed-resources`). **Fix loop 3**
(02:15 to 02:28 UTC) closed the reported renewal case; its final re-audit
([report](docs/reports/ARC-03c-audit-gpt-6-astra-3.md)) accepted the write-count decision but
found a **new major**: after a lifetime wrap of the 16-bit acceptance number, a hook accepting
another quest can make an unchanged held quest lose a batch's counts (unreachable for the game).
**Three fix loops are used; the project manager decided a last loop, as an exception**
([decision](docs/decisions/2026-09-29-ARC-03c-last-loop.md)): limited to the acceptance number,
widened so that a wrap is impossible in practice, then a `[GPT-6-Astra]` pass limited to it. A major
left by that pass blocks the merge and goes back to the project manager. **The last loop is done** (02:54 to
03:37 UTC, CI green, 423 tests within budget): a 30-bit acceptance number and counter (a wrap needs
about 10⁹ acceptances by one player), a 48-bit held interval id, whole entries compared again, the
16-bit wrap case pinned as a regression; worst calls re-measured, all under 20M (6.21M at H = 4;
15.06M at H = 8 with a one-slot hook; the game's use 4.55M). The narrow `[GPT-6-Astra]` pass
([report](docs/reports/ARC-03c-audit-gpt-6-astra-4.md)) is **PASS WITH FINDINGS**, no major left;
**#10 merged** (`6e92b2c`, CI green on `main`). Its last minor (stale layout wording and estimates) and
the ARC-01 sections the lot could not touch are closed by the orchestrator's documentation pull
request. **`quiver_quest` 0.1.0 is published** on
[scarbs.xyz](https://scarbs.xyz/packages/quiver_quest) (go of the project manager, D-138;
[record](docs/decisions/2026-09-29-publish-quiver_quest-0.1.0.md)): commit `364462f`, sha256
`494228f1…379c`, tag and release `quiver_quest-v0.1.0` (release workflow green). **ARC-04**,
`quiver_achievement`: its accepted design breaks the 20M cap in storage mode (448 records in the
worst call, about 200M): **the project manager decided 0.1.0 in event mode only**
([decision](docs/decisions/2026-09-29-achievement-event-only.md)); storage mode with per-task counters
later, its layout not reserved. **ARC-04 done** (04:58 to 05:31 UTC, [#17](https://github.com/bal7hazar/quiver/pull/17),
CI green, 102 tests within budget): worst `progress_many` 1.82M L2 gas (9 % of the cap), the game's
results call 0.83M, worst `define` 1.20M. `[GPT-6-Astra]` audit ([report](docs/reports/ARC-04-audit-gpt-6-astra-1.md)):
PASS WITH FINDINGS, no blocker or major; its two minors fixed in one loop; **#17 merged** (`b525a8c`).
**Publication of `quiver_achievement` 0.1.0 asked** of the project manager:
[PENDING-publish-quiver_achievement-0.1.0](docs/decisions/PENDING-publish-quiver_achievement-0.1.0.md),
commit `50017e7`; nothing is published before the go. The project manager
corrected the slot price the same night (the game's FND-04, 149 Sepolia transactions: a new slot
about 453 500 L2 gas, an overwritten or zeroed one about 32 000; [recorded](docs/decisions/2026-09-28-quest-cost-cap.md));
what fix loop 1 does not cover (the worst call with the player's slots new and existing, created
and overwritten slots per entrypoint, reusing slots instead of zeroing them) goes to fix loop 2. After the merge: the ARC-01 sections the lot could not touch (§2 tables, §3.4, §3.7, §3.8,
§5 notation) are brought in line by the orchestrator, then the publication request of
`quiver_quest` 0.1.0.

**Launcher**: the budget is now **slot locks** ([#9](https://github.com/bal7hazar/quiver/pull/9),
`1d61843`, then [#11](https://github.com/bal7hazar/quiver/pull/11) and
[#12](https://github.com/bal7hazar/quiver/pull/12), synced with the game's `scripts/agent.sh` at
`2628b21` by the project manager's decision (`slots-init` under the launch lock and only with every
slot free; every slot checked for errors before one is chosen): slot files opened read-only,
never created by a probe, the slot directory read-only, only `slots-init` creating missing ones): an agent holds `~/orchestrator/slots/total-N` and
`quiver-1` by a kernel lock for as long as it lives; a launch takes both or refuses, and refuses
while the game's waiting marker is fresh. This replaces #8's process count, and with it the four
findings inherited from the game's launcher. ARC-03c, launched before the slots, is covered by the
placeholder `slotkeep-quiver-ARC-03c-234905` (holds `total-2` and `quiver-1`). To sync again when
the game's CHANGELOG marks the audited reference, if it differs.

Budget slip, 22:28 UTC: the orchestrator resumed ARC-03b while three Grim World agents ran (two
codex audits of the game and the library were counted, then overlooked); it stopped the run
after 15 seconds, before any change, and resumes it when fewer than 3 run. Publications follow
D-132: no sub-agent publishes; the orchestrator asks the project manager with a
`PENDING-publish-*` file and publishes after a go naming package, version and commit.

## What moved

| | |
|---|---|
| Publication of `quiver_achievement` 0.1.0 | [PENDING-publish-quiver_achievement-0.1.0](docs/decisions/PENDING-publish-quiver_achievement-0.1.0.md), to the project manager |
| ARC-00 | [#1](https://github.com/bal7hazar/quiver/pull/1): the repository's minimum, launcher, build lock, profiles, CI of the tooling and the links. [#3](https://github.com/bal7hazar/quiver/pull/3): every profile denies `scarb publish` and reading the user-level settings (D-128). [#5](https://github.com/bal7hazar/quiver/pull/5): every agent runs with the registry token and the Sepolia variables emptied (port of grimworld#38) |
| ARC-01 | [#2](https://github.com/bal7hazar/quiver/pull/2) merged: [docs/research/ARC-01-quest-achievement.md](docs/research/ARC-01-quest-achievement.md). ADR-0004 points 3 and 4 all confirmed, ten further defects, the full API, needs A-1 to A-9, cost estimates, the workspace and CI by affected package, twenty questions. `[GPT-6-Sol]` audit: FAIL, FAIL, then PASS WITH FINDINGS after three fix loops; reports archived in [docs/reports/](docs/reports/ARC-01-report.md) |
| ARC-02 | [#4](https://github.com/bal7hazar/quiver/pull/4) merged: root `Scarb.toml`, `quiver_quest` and `quiver_achievement` skeletons (bounds as constants, one budgeted test each), `cairo.yml` by affected package (base-branch script, fail closed, summary job `cairo`), `scripts/gas.py` (every source test measured and budgeted, `GAS.md` checked), `release.yml` (checks and `scarb package`, no publish), [docs/WORKSPACE.md](docs/WORKSPACE.md). `[GPT-6-Luna]` audit: FAIL, FAIL, then closed by the orchestrator (one finding refuted as a repository limit, D-121); reports in docs/reports |
| ARC-03a | [#6](https://github.com/bal7hazar/quiver/pull/6) merged: `quiver_quest::logic`, types, one-felt packing with field-width and reserved-bit checks, pure functions and errors of the accepted API; 166 tests (36 benchmarks) with budgets; worst case of `batch_merge` 753 k L2 gas (a late duplicate among 16 entries). Reports in docs/reports |
| ARC-03c | [#10](https://github.com/bal7hazar/quiver/pull/10) merged: `quiver_quest` 0.1.0, the component on the player's held quests (D-135): acceptance mandatory, at most 4 held, 30-bit acceptance numbers, held-list slots kept; worst calls measured under 20M (6.21M at H = 4); 423 tests within budget. Four fix loops (the fourth an exception of the project manager); `[GPT-6-Astra]` four passes, the last PASS WITH FINDINGS. Reports in docs/reports |
| ARC-04 | [#17](https://github.com/bal7hazar/quiver/pull/17) merged: `quiver_achievement` 0.1.0 in event mode only (definitions stored, progress as events, reporter access control, no storage mode by absence); worst `progress_many` 1.82M L2 gas; 102 tests within budget. `[GPT-6-Astra]` PASS WITH FINDINGS, two minors fixed. Reports in docs/reports |

## Agents

None running.

## Budget

The game's OPERATIONS §3 at `377576a`: caps game 2, map library 1, **quiver 1 (the slot `quiver-1`),
audits included**, total 3; the game comes first: no quiver launch while `~/orchestrator/waiting/game` exists and is
less than 30 minutes old. ARC-03b (fix loop 2) is this track's one agent; the queued `[GPT-6-Sol]`
audit of #8 was withdrawn at 23:07 UTC before it launched, and waits for ARC-03b to end.

## Open

| | |
|---|---|
