# ARC-02 — The workspace, CI by affected package, gas tooling, release pipeline

## Agent
Title: `[Sonnet 5.5] ARC-02 workspace and CI` · Model: Sonnet 5.5 (`claude-sonnet-5-5`) ·
Profile: `implement`

## Goal
After this task, `quiver` is a Scarb workspace with two package skeletons, `quiver_quest` and
`quiver_achievement`, that build and test; a CI that runs **only the packages a change
affects and their dependents** (all of them on `main`, on a release tag and on a schedule); a
gas tool that measures each test and checks its budget; and a release pipeline that checks a
package for publication **without publishing it**. ARC-03 then writes `quiver_quest` into
this frame without touching the tooling.

## Context
- The accepted API and the workspace proposal: [docs/research/ARC-01-quest-achievement.md](../research/ARC-01-quest-achievement.md)
  **§6 in full** (layout, manifests, dependencies, CI by affected package, publication) and
  §3.1 (the bounds). Accepted at gate A-G1:
  [docs/decisions/2026-09-28-A-G1-api.md](../decisions/2026-09-28-A-G1-api.md).
- [docs/CAIRO.md](../CAIRO.md) **§2** (every test has a gas budget,
  `#[available_gas(l2_gas: N)]` with `N = ceil(1.05 × measured)`; a `GAS.md` per package) and
  §6 point 1 (budgets match the measured figures within 5%).
- A model of a pinned Cairo CI, read-only in your worktree: `ref/grimworld/.github/`
  (`workflows/ci.yml`, `ci/discover.py`, `ci/install-snforge.sh`) from `bal7hazar/grimworld`
  at `9fe8868`. Take the ideas (exact versions, actions pinned by commit SHA, validation of
  what comes from the pull request), not the game's layout.
- The existing CI of this repository, `.github/workflows/tooling.yml` (scripts and links):
  it stays as it is.
- Toolchain: Scarb 2.19.4, snforge 0.61.0 (the machine's global versions; `scarb --version`,
  `snforge --version`). `snforge_std` is a **dev-dependency**.
- Depends on: ARC-00, ARC-01, gate A-G1 (D-131).

## Scope

**In:**

1. **Workspace.** Root `Scarb.toml` with `[workspace]` (`members = ["packages/*"]`),
   `[workspace.package]` and `[workspace.dependencies]` as in ARC-01 §6.1, versions checked
   against Scarb 2.19.4 (`edition.workspace = true` is known to work). `.tool-versions`
   pinning `scarb 2.19.4` and `starknet-foundry 0.61.0`, read by the CI. `Scarb.lock`
   committed.
2. **Two package skeletons**, `packages/quest` (`quiver_quest`, version `0.1.0`) and
   `packages/achievement` (`quiver_achievement`, `0.1.0`), each with: `Scarb.toml` (ARC-01
   §6.1), `README.md` (what the package will be, a link to ARC-01 §3, "not implemented yet"),
   `CHANGELOG.md` (Keep a Changelog, an `Unreleased` section), `GAS.md` (produced by the gas
   tool), `src/lib.cairo` with **one module `constants`** holding the bounds of the accepted
   API as `pub const` (quest: `MAX_TASKS = 3`, `MAX_CONDITIONS = 7`, `QUESTS_PER_PAGE = 7`,
   `MAX_PAGES = 4`, `MAX_ENTRIES = 16`; achievement: `MAX_TASKS = 3`,
   `ACHIEVEMENTS_PER_PAGE = 7`, `MAX_PAGES = 4`, `MAX_ENTRIES = 16`), and **one snforge test**
   per package asserting them, with its `#[available_gas(l2_gas: N)]` set from the measured
   value. Nothing else of the packages: their logic is ARC-03 and ARC-04.
3. **Gas tool**, `scripts/gas.py`, run as `scripts/gas.py <package dir> [--check | --write]`:
   runs `snforge test` in the package, reads each test's measured L2 gas from snforge's
   output and its budget from `#[available_gas(l2_gas: N)]` in the sources, then
   - `--write` rewrites the package's `GAS.md` table: test, measured, budget, date, commit;
   - `--check` fails, naming the test, when a test has no budget, when its budget is below
     the measured value, or above `ceil(1.05 × measured)`; it also fails when `GAS.md`
     disagrees with the measured values.
   Standard library only; the parsing of snforge's output is a pure function with unit
   tests (`scripts/test_gas.py`, `python3 -m unittest`), fed with a sample of real snforge
   0.61 output that you record.
4. **CI by affected package**, `.github/workflows/cairo.yml`, with its logic in
   `.github/ci/affected.py` (pure functions, standard library, unit-tested in
   `.github/ci/test_affected.py`):
   - on a pull request: changed files from the merge base; a file under `packages/<dir>/`
     affects that package; the root `Scarb.toml`, `Scarb.lock`, `.tool-versions`,
     `cairo.yml`, `.github/ci/**` and `scripts/gas.py` affect **all**; anything else affects
     none, and the Cairo jobs are skipped;
   - dependents: from `scarb metadata --format-version 1`, the reverse dependency graph of
     the workspace members; every package depending transitively on an affected one runs
     too (test it with a graph of three packages, even though today's two are independent);
   - on `push` to `main`, on a tag `quiver_*-v*`, on a schedule (daily) and on
     `workflow_dispatch`: **every** package;
   - one matrix job per package: `scarb fmt --check`, `scarb build`, `snforge test`,
     `scripts/gas.py <dir> --check`;
   - one summary job named **`cairo`** that succeeds when every matrix job does or when
     there is none, so that a required check has a stable name;
   - toolchain installed at the exact versions of `.tool-versions`; third-party actions
     pinned by commit SHA; `permissions: contents: read`; the whole run under 10 minutes.
5. **Release pipeline**, `.github/workflows/release.yml`, on a tag `quiver_<name>-v<x.y.z>`:
   the workspace is green (the same jobs, all packages); the tag's version equals the
   package manifest's; `CHANGELOG.md` has a section for that version; `scarb package` of that
   package succeeds and its archive is uploaded as a workflow artifact. **It never runs
   `scarb publish` and holds no token**: publishing is the owner's act (D-128), done by hand.
6. **Verify ARC-01 §6.2**: in a scratch folder inside your worktree (not committed), make a
   package depend on another with `{ path = "…", version = "^0.1.0" }` and run `scarb
   package` on it: say in the report what the packaged manifest records for that dependency.
7. **`docs/WORKSPACE.md`**: the layout, how to add a package, local checks (package-scoped,
   through the build lock), what the CI runs and when, the gas workflow (`--write` then
   `--check`), the release steps up to the archive, and that publishing is not in CI.

**Out:** any logic of `quiver_quest` or `quiver_achievement` beyond `constants` (ARC-03,
ARC-04); `docs/BUDGETS.md` (ARC-03); changes to `tooling.yml`, `.github/ci/check-links.py`,
`scripts/agent.sh`, `scripts/lock.sh`, `scripts/profiles/`, `README.md`, `PLAN.md`,
`STATUS.md`, `docs/decisions/`, `docs/briefs/`, `docs/research/`, `docs/CAIRO.md`; any
`scarb publish`, tag or release; branch protection.

**Allowlist:** `Scarb.toml`, `Scarb.lock`, `.tool-versions`, `packages/**`,
`.github/workflows/cairo.yml`, `.github/workflows/release.yml`, `.github/ci/affected.py`,
`.github/ci/test_affected.py`, other new files under `.github/ci/` if needed,
`scripts/gas.py`, `scripts/test_gas.py`, `docs/WORKSPACE.md`, `.gitignore` (append only).
Anything else is an escalation in your report.

## Interfaces
- `scripts/gas.py <package dir> [--check | --write]`: exit 0 on success, 1 on a failed check,
  2 on a usage error; its messages name the package and the test.
- `.github/ci/affected.py`: a function from (changed paths, package graph) to the set of
  package directories to run, and a command-line entry the workflow calls, writing a JSON
  matrix to `GITHUB_OUTPUT`.
- `quiver_quest::constants`, `quiver_achievement::constants`: the bounds above, `u8` or `u32`
  as the API types them (ARC-01 §3.1, §3.2, §3.10).

## Acceptance criteria
- [ ] AC-1 `scarb metadata --format-version 1` lists the workspace with the two members; each
      package builds and its test passes locally (package-scoped).
- [ ] AC-2 Each test has an `available_gas` budget within `[measured, ceil(1.05 × measured)]`,
      and `scripts/gas.py <dir> --check` passes for both packages; it fails on a doctored
      budget (show it in the report, then restore).
- [ ] AC-3 `python3 -m unittest` passes for `test_gas.py` and `test_affected.py`, including:
      a change in one package runs that package only; a change in a dependency runs its
      dependents; a root manifest change runs all; a documentation-only change runs none.
- [ ] AC-4 The pull request's CI is green, with the `cairo` summary job and both packages run
      (this pull request touches the root manifest, so all run).
- [ ] AC-5 `release.yml` exists and its checks are written; it contains no `publish` and no
      secret. Say how it was checked (it cannot be run without a tag: a dry run of its steps
      locally is enough).
- [ ] AC-6 The §6.2 question is answered in the report with the packaged manifest's content.
- [ ] AC-7 `docs/WORKSPACE.md` covers points 1 to 5; `python3 .github/ci/check-links.py`
      passes.

## Verification
- `scarb metadata --format-version 1 | python3 -c "…"` (members), then per package:
  `scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build`,
  `cd packages/quest && snforge test`, `scripts/gas.py packages/quest --check`; the same for
  `packages/achievement`.
- `python3 -m unittest scripts/test_gas.py .github/ci/test_affected.py` (or the discovery form
  that works), `python3 .github/ci/check-links.py`.
- `gh pr checks <n> --watch --interval 30` until green.

## Report
`REPORT.md` (COMMON.md §6), with the cost table of the two constant tests (measured, budget),
the real outputs of the commands above, the answer to §6.2, and the CI run time. Branch
`chore/ARC-02-workspace`; pull request titled `[Sonnet 5.5] ARC-02 workspace, CI by affected
package, gas tooling`. Foreground only: every command in the foreground, your turn ends when
`REPORT.md` is written.
