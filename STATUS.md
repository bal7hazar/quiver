# Status

**2026-10-02 19:30 UTC**, written by the orchestrator of track ARC (herdr, project `grimworld-arc`).

## State, 2026-10-02

The track runs in herdr since 2026-10-02. The Nexus-era orchestrator stopped at the soft stop of
2026-10-01 (lifted for all of Grim World on 2026-10-02); Nexus and `scripts/agent.sh` are no longer
used by this track. Its handover note is
[docs/handover/orchestrator-quiver-2026-10-01.md](docs/handover/orchestrator-quiver-2026-10-01.md).

- ARC-10 (Scarb 2.20.1, starknet-foundry 0.64.0) is done: [#37](https://github.com/bal7hazar/quiver/pull/37), `0fd494e`.
- **`quiver_quest` 0.2.0 and `quiver_achievement` 0.2.0 are published** on scarbs.xyz (2026-10-02),
  from commit `2e6bb77392335a5420b2ff331f072f66f265c16f`, on the project manager's go under D-186
  (the owner's delegation). Records:
  [docs/decisions/2026-10-02-publish-quiver_quest-0.2.0.md](docs/decisions/2026-10-02-publish-quiver_quest-0.2.0.md)
  and [docs/decisions/2026-10-02-publish-quiver_achievement-0.2.0.md](docs/decisions/2026-10-02-publish-quiver_achievement-0.2.0.md);
  tags and releases `quiver_quest-v0.2.0` and `quiver_achievement-v0.2.0`. Consumers need Scarb 2.20
  (`starknet` ^2.20.0, `snforge_std` ^0.64.0).
- ARC-11 (`scripts/gas.py --write` keeps the hand-written sections of `GAS.md`) is done:
  [#41](https://github.com/bal7hazar/quiver/pull/41), `621baa5`.
- ARC-12 (three safety fixes to `scripts/gas.py`, notes of ARC-11's review; no package file changes)
  is done: [#42](https://github.com/bal7hazar/quiver/pull/42), `5caf08d`.
- ARC-07d (the deferred notes, [brief](docs/briefs/ARC-07d-deferred-notes.md)) is done:
  [#47](https://github.com/bal7hazar/quiver/pull/47), `5061428`, [report](docs/reports/ARC-07d-report.md).
  It stays under `[Unreleased]` in the changelogs, nothing bumped, to be batched with the next change a consumer needs (likely the game's GLD-02 feedback on `quiver_quest` 0.2.0); reversed if a consumer needs a fix that is in `[Unreleased]`. The quest definition view costs +1 770 L2 gas per call with no
  conditions (+1 200 in the worst case; `Store::get_definition` +1 140), accepted by the orchestrator
  and documented in the bench note, the changelog and the report.
- The pre-push tooling is done, all review only (D-177): ARC-13 the pre-push check and hook
  ([#43](https://github.com/bal7hazar/quiver/pull/43), `afb2e6f`, [report](docs/reports/ARC-13-report.md));
  ARC-14 the pre-push waits at most 90 s for the VPS build lock, `lock.sh` takes the heavy lock for
  every compile ([#44](https://github.com/bal7hazar/quiver/pull/44), `0c840f4`, [report](docs/reports/ARC-14-report.md));
  ARC-15 superseded pull request runs are cancelled, other runs never
  ([#45](https://github.com/bal7hazar/quiver/pull/45), `3750b5d`, [report](docs/reports/ARC-15-report.md));
  ARC-16 the pre-push lock fixes ([#46](https://github.com/bal7hazar/quiver/pull/46), `8d6c7c3`,
  [report](docs/reports/ARC-16-report.md)).
- **Consumers**: the game (Grim World) and, from 2026-10-06, **Paved** (an on-chain Carcassonne),
  which will consume `quiver_quest` and `quiver_achievement` by published version from its phase 3,
  and `quiver_leaderboard`. A breaking release of any package is announced to the project manager
  first (passed to Paved through the Overseer); a request from Paved through the project manager is
  a consumer request.
- **ARC-05a, `quiver_leaderboard` 0.1.0, in progress** (2026-10-07, the owner's request): the
  [design brief](docs/briefs/ARC-05a-leaderboard.md), written from Paved's specification, and the
  [mapping to Arcade's design](docs/research/ARC-05a-arcade-leaderboard-mapping.md) are written. The
  lot is **held** until the owner answers on the licence (Arcade's is non-commercial; no Arcade code
  is copied or ported unless the answer allows it). Review only, no audit; the publication's go is
  the owner's.
- Next: no 0.2.1 request now (ARC-07d waits under `[Unreleased]`, project manager, 2026-10-02); a lot for the hook's automated
  tests and a shellcheck of the hook (review notes, later).

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
| ARC-07a, `quiver_quest` 0.2.0 | Done ([#20](https://github.com/bal7hazar/quiver/pull/20)), **accepted (D-167)**; **published 2026-10-02** | — |
| ARC-07b, `quiver_achievement` 0.2.0 | **Done**: [#25](https://github.com/bal7hazar/quiver/pull/25) merged (`4243132`), [report](docs/reports/ARC-07b-report.md). Reviews by Fable, the last PASS at `970cff1` after three fix loops. Audits on Opus 5.5 (D-177: before a published interface's publication): organisation and cost and access control, both PASS WITH FINDINGS, notes only; one answered in the CHANGELOG, the others in ARC-07d | — (published 2026-10-02 with `quiver_quest`) |
| ARC-07c, `quiver_quest`'s tests into their modules | **Done**: [#28](https://github.com/bal7hazar/quiver/pull/28) merged (`7afe131`) on its review, no audit (D-177), [report](docs/reports/ARC-07c-report.md) | — |
| ARC-09, measured and packaged builds single-threaded (D-176) | **Done**: [#32](https://github.com/bal7hazar/quiver/pull/32) merged (`7066040`), review only; no figure moved | — |
| ARC-10, Scarb 2.20.1 and starknet-foundry 0.64.0 (D-180) | **Done**: [#37](https://github.com/bal7hazar/quiver/pull/37) merged (`0fd494e`), [brief](docs/briefs/ARC-10-scarb-latest.md), [report](docs/reports/ARC-10-report.md); two reviews by Opus 5.5 (`review-opus`), no audit (D-177); single-thread pin kept, SPK-13 | — |
| ARC-07d, deferred notes | **Done**: [#47](https://github.com/bal7hazar/quiver/pull/47) merged (`5061428`), [report](docs/reports/ARC-07d-report.md); review only, no audit (D-177) | Stays under `[Unreleased]`, batched with the next consumer-needed change |
| Publication of both packages as 0.2.0 | **Published 2026-10-02** from `2e6bb77` (D-186), [quest record](docs/decisions/2026-10-02-publish-quiver_quest-0.2.0.md), [achievement record](docs/decisions/2026-10-02-publish-quiver_achievement-0.2.0.md) | — |
| ARC-05a, `quiver_leaderboard` 0.1.0 | **In progress**: [design brief](docs/briefs/ARC-05a-leaderboard.md) written; the lot **held** for the owner's licence answer | The owner's licence answer, then the lot |
| ARC-05, `social` | Waits for the game's MVP and a decision of the project manager | — |

**Reviews and audits while Codex has no quota** (the owner's rules of 2026-10-01): reviews by Claude
(Sonnet, or another model than the author's), every audit by Claude Opus 5.5; Nexus falls back by
itself since R2. **Audits are the exception (D-177)**: the review is the routine gate; each pull
request says why an audit was asked or that none was needed. Applied on 2026-10-01: no audit was
queued (`nexus stop` stopped none); **two planned audits dropped**: the Codex organisation audit of
ARC-07b (replaced by Opus) and ARC-07c's.

**Reports recovered**: the task worktrees of ARC-07b and ARC-07c were removed after their merges
with `REPORT.md` uncommitted; the orchestrator rebuilt both reports from what it had read (noted at
their head). From now on a task's `REPORT.md` is archived before its merge.

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

Both packages the game needs are published on scarbs.xyz, each after the project manager's go (0.2.0 on 2026-10-02, after the owner's review below):

| Package | Version | Registry | Commit | Record |
|---|---|---|---|---|
| `quiver_quest` | 0.1.0 | https://scarbs.xyz/packages/quiver_quest | `364462f` | [D-138](docs/decisions/2026-09-29-publish-quiver_quest-0.1.0.md) |
| `quiver_achievement` | 0.1.0 (event mode only) | https://scarbs.xyz/packages/quiver_achievement | `50017e7` | [D-142](docs/decisions/2026-09-29-publish-quiver_achievement-0.1.0.md) |
| `quiver_quest` | 0.2.0 | https://scarbs.xyz/packages/quiver_quest | `2e6bb77` | [D-186](docs/decisions/2026-10-02-publish-quiver_quest-0.2.0.md) |
| `quiver_achievement` | 0.2.0 | https://scarbs.xyz/packages/quiver_achievement | `2e6bb77` | [D-186](docs/decisions/2026-10-02-publish-quiver_achievement-0.2.0.md) |

**What wakes the track:**

- the game's needs, through its `docs/needs/arcade.md`, when it embeds the packages (GLD-02 for
  quests, the titles after it), answered by a 0.1.x or a 0.2.0;
- a defect found in a published version: a fix is a new version, asked and checked like the first;
- ARC-05 (`social`), after the game's MVP and a decision of the project manager (`leaderboard` is
  ARC-05a, above).

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

None running. The track runs in herdr on the VPS; the Mac is off.

## Budget

The pool is shared; threads run on the profiles of the herdr project (`impl-sonnet`, `review-opus`), the
machine capacity read before each launch.

## Open

Nothing open with the project manager. Waiting for the game's GLD-02 feedback on `quiver_quest` 0.2.0; no 0.2.1 is requested before a consumer needs a change.
