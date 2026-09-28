# The workspace

`quiver` is a Scarb workspace: one package per feature, each published on its own. The design
is [ARC-01 §6](research/ARC-01-quest-achievement.md); this page is how it is built and run.

## 1. Layout

```
Scarb.toml            [workspace]: members = ["packages/*"], shared package fields and dependencies
Scarb.lock            committed
.tool-versions        scarb 2.19.4, starknet-foundry 0.61.0: read by the CI
packages/quest/       quiver_quest        (Scarb.toml, README.md, CHANGELOG.md, GAS.md, src/, tests/)
packages/achievement/ quiver_achievement  (same shape)
scripts/gas.py        the gas tool (test_gas.py: its unit tests)
.github/workflows/    tooling.yml, cairo.yml, release.yml
.github/ci/           affected.py, release_check.py, install-snforge.sh, and their tests
```

A package inherits `edition`, `cairo-version`, `license` and `repository` from
`[workspace.package]` (`edition.workspace = true`) and its dependencies from
`[workspace.dependencies]`. Its `version` is its own. `snforge_std` is a dev-dependency.

## 2. Adding a package

1. Create `packages/<name>/` with a `Scarb.toml` copied from an existing package, named
   `quiver_<name>`, version `0.1.0`; the directory is the name without the `quiver_` prefix
   (the release tag relies on it).
2. Add `README.md`, `CHANGELOG.md` (an `Unreleased` section), `src/lib.cairo` and a test.
3. Run `scripts/gas.py packages/<name> --write` once the tests carry their budgets.
4. Depending on another package of the workspace: `quiver_x = { path = "../x", version = "^0.1.0" }`.
   The CI then runs the dependent whenever `quiver_x` changes. The packaged manifest keeps the
   version and drops the path; `scarb package` verifies against the registry, so **the
   dependency must be published before its dependent** can be packaged with verification.

No workflow changes: `members = ["packages/*"]` and the CI's discovery pick the package up.

## 3. Local checks

Package-scoped, through the build lock (the whole workspace is the pull request's CI job):

```
scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build
cd packages/quest && snforge test
scripts/gas.py packages/quest --check
scarb --manifest-path packages/quest/Scarb.toml fmt --check
python3 -m unittest scripts/test_gas.py
python3 -m unittest discover -s .github/ci
python3 .github/ci/check-links.py
```

Run the tests of the package you touched and of the packages that depend on it.

## 4. What the CI runs, and when

`tooling.yml` checks the scripts and the links. `cairo.yml`:

| Event | Packages |
|---|---|
| Pull request | Those the change affects, and their dependents |
| Push to `main`, daily schedule, manual run | All |
| Tag `quiver_*-v*` | All, once: `release.yml` calls `cairo.yml`; the tag push does not trigger `cairo.yml` itself |

On a pull request, `.github/ci/affected.py` lists the files changed since the merge base, with
renames listed as a deletion and an addition (moving a file out of a package affects it). A file
under `packages/<dir>/` affects that package; the root `Scarb.toml` and `Scarb.lock`,
`.tool-versions`, `cairo.yml`, `release.yml`, `.github/ci/**` and `scripts/gas.py` affect all;
anything else affects none and the Cairo jobs are skipped. Dependents come from
`scarb metadata --format-version 1`: every package that depends, transitively, on an affected one
also runs.

Each package job runs `scarb fmt --check`, `scarb build`, `snforge test` and
`scripts/gas.py <dir> --check`, on the exact versions of `.tool-versions` (snforge from its
SHA-256-pinned release archive). The job named **`cairo`** succeeds when every package job does,
or when none was needed: it is the check to require. Third-party actions are pinned by commit
SHA and the token is read-only.

The pull request controls `affected.py`, so on a pull request the `affected` job runs the **base
branch's** copy of it; a change under `.github/ci/` then runs every package, and a pull request that
edits the script cannot narrow its own run. It fails closed: when the base branch has no such
script (or `git show` fails), the job says so and **every package runs**. A pull request can also
edit the workflow itself: **the full run on `main` after the merge is the backstop.**

The CI of a pull request is **not a security boundary against the pull request's author**: the
author can edit the workflow. `main` is not protected (the game's D-121), so anyone who can push a
branch can push to `main`. What holds is the orchestrator's review of every change under `.github/`
and `scripts/`, and the full run on `main` after the merge.

## 5. Gas

Every test has `#[available_gas(l2_gas: N)]`, `N = ceil(1.05 × measured)` ([CAIRO.md](CAIRO.md) §2).
Workflow: write the test, run `scripts/gas.py <dir> --write` (it prints nothing useful until the
budgets exist: set a high one, run, then set `N` from the measured value), edit `N` in the
source, run `--write` again, then `--check`. `--write` rewrites the package's `GAS.md` (test,
measured, budget, date, commit; tests are named as snforge names them, by module path);
`--check` fails, naming the test, when a budget is missing, below the measure, above
`ceil(1.05 × measured)`, or when `GAS.md` disagrees with the measures. Both fail when a `#[test]`
of the sources has no measured result (an `#[ignore]`d or filtered test included) or when
snforge's summary reports a test ignored or filtered out: every test runs and has a budget.
Commit `GAS.md` with the change.

## 6. Release, up to the archive

1. Move the changelog's `Unreleased` entries under `## [x.y.z] - date`, set the manifest's version,
   refresh `GAS.md`; merge the pull request.
2. Tag the merge commit `quiver_<name>-v<x.y.z>` (for example `quiver_quest-v0.1.0`).
3. `release.yml` runs: the workspace jobs of `cairo.yml` for every package; the tag's version
   equals the manifest's and the changelog has the section (`.github/ci/release_check.py`);
   `scarb package` of that package succeeds and the archive `target/package/*.tar.zst` is
   uploaded as a workflow artifact.

## 7. Publishing is not in CI

`release.yml` never runs `scarb publish` and holds no token. **No sub-agent publishes, ever**
(the game's D-132, [COMMON.md](briefs/COMMON.md) §2). The orchestrator asks by committing
`docs/decisions/PENDING-publish-<package>-<version>.md` (package, version, commit, what changed,
what the consumer must do) and sending its path to the project manager, who checks the commit
on `main` (every CI check completed and green), the audits, the changelog and version, the gas
tables, `scarb package` from a clean checkout, the registry and the dependencies. After a go
that names the package, the version and the commit, the orchestrator's session runs
`scarb --manifest-path packages/<dir>/Scarb.toml publish` by hand from that commit. A published
version cannot be replaced.
