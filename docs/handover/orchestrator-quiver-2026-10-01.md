# Handover — orchestrator of `quiver`, track ARC — 2026-10-01

Written at **2026-10-01 15:38 UTC** by `[Opus 5.5] Orchestrateur quiver (packages)` (`claude-opus-5-5`),
at the owner's **soft stop** (relayed by the project manager). Nothing runs and no pull request is
open. The session stays on standby: it starts nothing, but it answers the owner.

## Who you are

| | |
|---|---|
| Role | Orchestrator of `bal7hazar/quiver`, **track ARC** of the Grim World plan: the owner's Arcade packages (quests, achievements) rewritten without Dojo, published on scarbs.xyz, consumed by the game by version |
| Above | The project manager, **`[Fable 5.1] Chef de projet Grim World`** (Claude Desktop session `local_3ab2583a-0d2b-469d-872e-cffdf357185d`). Message it with `SendMessage` to that id. It relays the owner's rules and decisions (D-…), and prepares the owner's go for stable publications |
| Below | None running. Implementers are claude CLI processes started by **`scripts/agent.sh`** (transient systemd user units `quiver-<task>-<hhmmss>`, slot locks `total-1..3` and `quiver-1`). Reviews and audits go through **`nexus review` / `nexus audit`** (project `grimworld`, repository `quiver`) |
| Game repository | `/home/claude/projects/grimworld`, **read-only** for you. Read its `OPERATIONS.md` (Nexus roles, D-162), `docs/decisions/`, and `CHANGELOG.md` for the launcher reference |
| Your files | `STATUS.md` (the current state; keep it true), `PLAN.md` (the track's tasks), `docs/briefs/` (one committed brief per task; `COMMON.md`, the common rules), `docs/CAIRO.md` (the owner's Cairo rules, a copy of the game's), `docs/reports/` (every report, review and audit, archived), `docs/decisions/` (publications, cost cap, A-G1), `docs/research/` (ARC-01 API, ARC-06 pattern, ARC-07a mapping) |

## State

**Published** (scarbs.xyz, each after the go, by hand from a clean checkout): `quiver_quest` **0.1.0**
(`364462f`, D-138) and `quiver_achievement` **0.1.0** (`50017e7`, event mode only, D-142).

**On `main` (`69192ed`), not published: both packages at 0.2.0.** They are rewritten on the owner's
pattern (D-143, D-147, docs/CAIRO.md §7–8):
- no `logic/`;
- models read and written through one store;
- each tracked model's event optional for the consumer, at compile time, at no cost on a write;
- unit tests in their modules (D-167);
- builds single-threaded (D-176).

| Task | State | Where |
|---|---|---|
| ARC-07a, `quiver_quest` 0.2.0 | Done (#20); **accepted by the owner (D-167)**. The owner reads [the Arcade mapping](../research/ARC-07a-arcade-mapping.md) and may bring a model back | — |
| ARC-07b, `quiver_achievement` 0.2.0 | Done (#25, `4243132`). Reviews by Fable, the last PASS. Audits on Opus, organisation and cost/access control, both PASS WITH FINDINGS, notes only | [report](../reports/ARC-07b-report.md) |
| ARC-07c, `quiver_quest`'s tests into their modules | Done (#28, `7afe131`), review only (D-177) | [report](../reports/ARC-07c-report.md) |
| ARC-09, `RAYON_NUM_THREADS=1` on measured and packaged builds (D-176) | Done (#32, `7066040`). **No figure moved** | [report](../reports/ARC-09-report.md) |
| **ARC-10, Scarb 2.20.1 and starknet-foundry 0.64.0 (D-180)** | **Briefed, NOT launched.** The 3 total slots were held by the game and the library from 14:13 UTC; the soft stop came before one freed. The launch loop was stopped at 15:36 UTC; no unit started | Brief [ARC-10](../briefs/ARC-10-scarb-latest.md) (pin kept, SPK-13). Worktree **`.claude/worktrees/cli-ARC-10`** on local branch `feat/ARC-10-scarb-latest` at `69192ed`, with no commits and not pushed. The toolchain is installed on the VPS (`asdf list scarb` → 2.20.1; `starknet-foundry` → 0.64.0), and since nexus #48 an agent may `asdf install` itself |
| 0.2.0 publications of both packages | **Not asked.** The drafts are [quest](../decisions/2026-10-02-publish-quiver_quest-0.2.0.md) and [achievement](../decisions/2026-10-02-publish-quiver_achievement-0.2.0.md), kept here so they are not read as requests. Fill them after ARC-10 (its figures); the **go is the owner's** (stable versions, D-132), prepared by the project manager | — |
| ARC-07d, deferred notes | todo, after 0.2.0 unless the owner asks sooner (PLAN) | — |
| ARC-05, `leaderboard`, `social` | Waits for the game's MVP and a project-manager decision | — |

**`nexus progress --project grimworld`** at 15:36 UTC: no quiver agent queued or running. Every
quiver review and audit has ended (succeeded, or failed and replaced). The Codex audit
`audit-arc-07b-quality` is `blocked_quota` and **must not be resumed**: the Opus audits replaced it.

**The launcher**: `scripts/agent.sh slots` at 15:36 UTC showed `quiver-1` free and `total-1..3` held
by other tracks. `systemctl --user list-units 'quiver-*'` lists nothing.

## Decisions taken today, and what would reverse them

| Decision | Content | Reverses it |
|---|---|---|
| D-162 | Nexus roles: implementers through the project launcher; `nexus review` before every merge; `nexus audit` for audits; read `nexus accounts`, `nexus resources` before a launch | A new OPERATIONS naming `nexus run` for track ARC |
| D-167 | ARC-07a accepted. **Unit tests live in their module's file** (`#[cfg(test)] mod tests`); `tests/` only for what deploys a contract | The owner bringing a model back after the mapping; a compile-time cost judged too high |
| D-175 and the rules of 2026-10-01 | While Codex has no quota: reviews by Claude (Sonnet, or a model other than the author's), **audits by Claude Opus 5.5**; Nexus falls back by itself (R2, #46) | Codex quota back (its reset: 2026-10-04 13:36 UTC) |
| **D-177** | **Audits are the exception**: value, access control, randomness, a published interface (once, before a publication), a cost or determinism only a measurement proves, a large refactoring, a lot the owner asks to see. Otherwise the review is the gate. Each PR says why an audit was asked or that none was needed | — |
| D-176 | Every measured, packaged or declared build is single-threaded (`RAYON_NUM_THREADS=1`) | SPK-13 found the drift remains on 2.20.1, so the pin stays |
| D-180 | Every repository on the latest Scarb (2.20.1 / 0.64.0); published versions are not rebuilt; ARC-10 | A dependency breaking with no fix within the lot (then stay one version behind and say so) |
| Project manager, 2026-10-01 | The cost of storing `points` in achievement slot A, and the slower cold test run, are accepted (recorded on #25) | — |

**Pending, with my recommendation:**

1. **ARC-10 launch.** Launch it on Sonnet 5.5 as briefed, when the owner lifts the stop. Review on
   Opus, no audit: it is a toolchain migration, and D-180 says review only. If figures move, they go
   into the 0.2.0 changelogs.
2. **0.2.0 publications.** After ARC-10, fill both drafts:
   - a clean clone of the merged commit;
   - `RAYON_NUM_THREADS=1 scarb --manifest-path packages/<dir>/Scarb.toml package`;
   - the sha256, CI, the changelog date, `.github/ci/release_check.py <pkg>-v0.2.0`.

   Then move them to `docs/decisions/PENDING-publish-<pkg>-0.2.0.md`, commit, and send the paths to
   the project manager for the owner's go. Publish both: they are independent packages. I recommend
   `quiver_quest` first, since the game's GLD-02 needs it first.
3. **`scripts/gas.py --write` drops `GAS.md`'s hand-written sections** (ARC-09's escalation). I
   recommend a small tooling lot (Sonnet, review only) that keeps everything after the generated
   table. ARC-10's brief works around it by asking the agent to put the sections back.

## Threads

- **The owner** reads `docs/research/ARC-07a-arcade-mapping.md` and may bring an Arcade model back
  into `quiver_quest`. That would be a new lot. No answer yet.
- **The project manager** has nothing open with this track. It asked to be told if an audit fails at
  start under the real lens after #46 (send the handle and the error).
- Nexus fault, filed by the Overseer: a review that lands as the 15-minute probe of a blocked Codex
  account goes to Codex and fails. Workaround: ask the review again at once.

## Next, in order

1. When the owner resumes: `nexus accounts --refresh`, `nexus resources`, `scripts/agent.sh slots`,
   and check `~/orchestrator/waiting/game`.
2. Launch ARC-10 (the worktree exists). Start the launch queue with
   `export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus`, then:

   ```sh
   scripts/agent.sh ARC-10 claude sonnet new "Read docs/briefs/ARC-10-scarb-latest.md and docs/briefs/COMMON.md, then execute the task." implement
   ```

   If the total slots are full, loop until the output says `holds slots`. Then
   `scripts/agent.sh wait ARC-10`, in the background, titled `[Sonnet 5.5] ARC-10 Scarb 2.20.1`.
3. When it ends, **copy its `REPORT.md` into `docs/reports/` on its branch before merging**.
   - `nexus review --project grimworld --task ARC-10 --repository quiver --branch feat/ARC-10-scarb-latest --brief docs/briefs/ARC-10-scarb-latest.md --model opus`.
   - Fix notes yourself only when they are a few lines covered by the checks; otherwise resume the
     agent (`scripts/agent.sh ARC-10 claude sonnet resume "<text>"`), at most three fix loops.
   - Merge on green with the review and "Audit: none (D-177)" in the merge body.
4. Fill and send the two 0.2.0 publication requests (Pending, 2). After the go:
   - publish by hand from a clean clone, `RAYON_NUM_THREADS=1`, the sha256 compared first;
   - tag and release;
   - rename each PENDING file to a dated record.
5. STATUS.md, PLAN.md; then ARC-07d, and the `gas.py` lot if the project manager agrees.

## Traps

- **Task worktrees vanish after a merge.** `cli-ARC-07b` and `cli-ARC-07c` disappeared after their
  PRs merged, and their uncommitted `REPORT.md` went with them; the cause is unknown. Archive the
  report into `docs/reports/` on the branch **before** merging. Nexus agents' reports stay readable
  with `nexus report <agent>`, but a resumed agent's report replaces its earlier one.
- **DBUS.** A background shell may lack `DBUS_SESSION_BUS_ADDRESS`. Then `scripts/agent.sh wait`
  returns at once while the agent runs. Export it first, as above.
- **`nexus wait` can end on a control-plane hiccup** ("fetch failed", or a restart during a
  deployment). Loop until `nexus status <agent>` shows `succeeded`, `failed`, `blocked` or
  `interrupted`, not until the wait returns.
- **Lens names collide.** Nexus names an audit `audit-<task>-<lens>`. A second audit of the same task
  and lens is refused (`exists`). Use another task id, as `ARC-07b-cost` was, or `nexus continue`
  (which replaces the report). Since #46, use the real lens.
- **Budget.** quiver may run **one** agent at a time, reviews and audits included. Launch nothing
  while `~/orchestrator/waiting/game` is under 30 minutes old: the game comes first. Never create
  or remove a file under `~/orchestrator/slots`, and never run `slots-init`.
- **The shared machine.** Temporary files go under your scratchpad or a worktree, never `/tmp`.
  Kill or delete only what you created, by exact name: no `pkill -f`, no `git clean` or
  `worktree prune` in another track's checkout.
- **Publication.** The registry token reaches the shell through settings: never print it, pass it on a
  command line or write it. No sub-agent publishes, ever. Publish only what the go names: the
  package, the version, the commit and the archive's sha256. If anything differs, publish nothing.
- **Links.** `.github/ci/check-links.py` reads tracked files: `git add` before running it.
- **Waiting.** `sleep` chains are refused. Wait with `until <check>; do sleep 5; done` or a
  background command.
- **Times.** Write the time you read (`date -u`), never an estimate. An estimated time once had to
  be corrected in STATUS.
- **Reviewers' sandboxes refuse `python3` and some `git` commands.** They lean on CI. Merge only on
  a green CI at the head they read, and ask for a review again when the branch moved, unless the
  change is your own few lines covered by the checks.
- **The launcher** is frozen until the game's FND-07. Sync `scripts/agent.sh` only when the game's
  CHANGELOG marks a new audited reference (the probe-race fix `74c7d50` was pending).
