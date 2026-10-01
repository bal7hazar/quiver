# Status

**2026-10-01 07:40 UTC**, written by the orchestrator `[Opus 5.5] Orchestrateur quiver (packages)`.

## Resumed 2026-09-30, under Nexus (D-162)

Resumed after the pause under the standard roles of Nexus (the game's OPERATIONS.md, D-162): every
pull request gets a Codex review (`nexus review`) before its merge, audits go through `nexus audit`,
implementers still through `scripts/agent.sh`, and `nexus accounts` and `nexus resources` are read
before any launch.

**The owner accepted ARC-07a (D-167)**: "clean and close to the target". Two remarks: (1) a mapping
of Arcade's models and events to `quiver_quest` 0.2.0's, with the reasons, for the owner to read:
[docs/research/ARC-07a-arcade-mapping.md](docs/research/ARC-07a-arcade-mapping.md); (2) a new rule,
docs/CAIRO.md §2: a module's unit tests live in its file under `#[cfg(test)] mod tests`.

| Task | State | Next step |
|---|---|---|
| ARC-07a, `quiver_quest` 0.2.0 | Done ([#20](https://github.com/bal7hazar/quiver/pull/20)), **accepted (D-167)**; not published | The owner reads the mapping and may bring a model back |
| ARC-07b, `quiver_achievement` 0.2.0 | **Running** since 07:33 UTC, `[Opus 5.5]`, unit `quiver-ARC-07b-073347`, slots `total-1` and `quiver-1` ([brief](docs/briefs/ARC-07b-achievement-0.2.0.md)): the pattern, `points` stored in slot A, the first lot under D-167's rule of tests | Audits `[GPT-6-Sol]` organisation and `[GPT-6-Astra]` cost through `nexus audit` (queued while Codex has no quota); the review before the merge (below); shown to the owner |
| ARC-07c, `quiver_quest`'s tests into their modules | Planned, after ARC-07b | Brief after ARC-07b; Sonnet 5.5 |
| Publication of both packages as 0.2.0 | Not asked | After ARC-07c: one `PENDING-publish-*` file per package (D-132) |
| ARC-05, `leaderboard` and `social` | Waits for the game's MVP and a decision of the project manager | — |

**Reviews while Codex has no quota** (the owner's rule of 2026-10-01): a pull request is reviewed by
Claude Opus 5.5, by Fable when Opus 5.5 wrote it (`nexus review --model fable`), once Nexus falls back
by itself (bal7hazar/nexus #35). Until then code merges wait; documents merge with `Codex review:
none — documents only`. Audits do not fall back: they wait for Codex.

## Where we are

**Woken on 2026-09-29 by the owner's rule D-143** (docs/CAIRO.md §7, §8): quiver's code does not keep
the layering of `cartridge-gg/arcade` (models, events, types, a store, functions scoped in traits).
**ARC-06** settles the pattern and shows it on one model, the quest definition
([brief](docs/briefs/ARC-06-model-store.md)); the owner reviews that model before ARC-07 rewrites
both packages as 0.2.0. 0.1.0 stays published; no consumer uses it. **ARC-06 done** (08:20 to 09:03 UTC,
[#19](https://github.com/bal7hazar/quiver/pull/19), CI green, 470 tests): a model is tracked when
it implements `Tracked<M>`; the component's state is the store (`get_x`, `set_x`); the store costs
exactly the hand-written code, a tracked write the event more (45 020); a convention, not a package.
Reference model: `packages/quest/src/models/definition.cairo`. Audits: `[GPT-6-Astra]` cost PASS WITH
FINDINGS; `[GPT-6-Sol]` organisation FAIL (production reads bypassing the store; no rule for an
event field not stored), then PASS WITH FINDINGS after one fix loop. **#19 merged** (`e9e1d48`).
**The owner reviewed it (D-147)**: `logic/` disappears; each model's event is optional for the
consumer, at compile time, at no cost on a write. **ARC-07a done** (`quiver_quest` 0.2.0,
[#20](https://github.com/bal7hazar/quiver/pull/20) merged): no `logic/`, every stored entity a model
through one store, `TrackAll`/`TrackNone` chosen by the consumer (an untracked write costs exactly a
write with no event code, measured to the unit); behaviour, layouts and every test of 0.1.0 kept, no
worst call raised. Audits after one fix loop: `[GPT-6-Sol]` PASS, `[GPT-6-Astra]` PASS WITH FINDINGS.
**Waiting for the owner's review of this lot**; ARC-07b (`quiver_achievement` 0.2.0) after it.

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

| Task | Model | Unit | Since | Slots |
|---|---|---|---|---|
| ARC-07b | `[Opus 5.5]` (`claude-opus-5-5`), profile `implement` | `quiver-ARC-07b-073347` | 2026-10-01 07:33 UTC | `total-1`, `quiver-1` |

## Budget

The game's OPERATIONS §3: caps game 2, map library 1, **quiver 1 (the slot `quiver-1`), audits
included**, total 3, held as slot locks by the launcher (`scripts/agent.sh slots`); the game comes
first: no quiver launch while `~/orchestrator/waiting/game` is less than 30 minutes old. `quiver-1` is held by ARC-07b.

## Open

Nothing open with the project manager.
