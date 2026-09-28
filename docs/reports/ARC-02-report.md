# [Sonnet 5.5] ARC-02 — Workspace, CI by affected package, gas tooling, release pipeline

## Summary
`quiver` is now a Scarb workspace with `quiver_quest` and `quiver_achievement` skeletons (a `constants` module and one gas-budgeted test each), a gas tool (`scripts/gas.py`), a Cairo CI that runs only affected packages and their dependents (`cairo.yml`, summary job `cairo`), a release check that never publishes (`release.yml`), and `docs/WORKSPACE.md`. The model matches the brief (Sonnet 5.5).
Pull request: https://github.com/bal7hazar/quiver/pull/4 — CI green (first run).

## Files changed
- `Scarb.toml`, `Scarb.lock`, `.tool-versions`: workspace (ARC-01 §6.1), pins scarb 2.19.4 and starknet-foundry 0.61.0.
- `packages/{quest,achievement}/`: `Scarb.toml`, `README.md`, `CHANGELOG.md`, `GAS.md`, `src/lib.cairo`, `src/constants.cairo`, `tests/test_constants.cairo`.
- `scripts/gas.py`, `scripts/test_gas.py`: gas tool and its 19 unit tests (with real snforge 0.61 output recorded in the test file).
- `.github/ci/affected.py`, `test_affected.py`: affected-package logic and 18 tests.
- `.github/ci/release_check.py`, `test_release_check.py`: tag/manifest/changelog check and 9 tests (new file, not named in the brief, under the `.github/ci/` allowance).
- `.github/ci/install-snforge.sh`: SHA-256-pinned snforge 0.61.0 and universal-sierra-compiler installer, from the grimworld model, minus the 0.51.2 entry.
- `.github/workflows/cairo.yml`, `release.yml`.
- `docs/WORKSPACE.md`.

## Commands run
- Members: `scarb metadata --format-version 1 --no-deps` lists `quiver_achievement 0.1.0` and `quiver_quest 0.1.0`.
- `snforge test` in each package: `[PASS] …quest_bounds_are_the_accepted_ones (l1_gas: ~0, l1_data_gas: ~0, l2_gas: ~13720)`; same for achievement.
- `scripts/gas.py packages/quest --check` → `quiver_quest: 1 tests within budget, GAS.md up to date`; same for achievement.
- Doctored budget (restored afterwards):
  - budget 20000: `quiver_quest: quiver_quest_integrationtest::test_constants::quest_bounds_are_the_accepted_ones budget 20000 is above ceil(1.05 x 13720) = 14406`, plus a `GAS.md says measured/budget (13720, 14406), now (13720, 20000)` line; exit 1.
  - budget 13000: snforge fails the test (`Test cost exceeded the available gas … l2_gas: ~13720`), the tool exits 1 with `…quest_bounds_are_the_accepted_ones failed`.
- `python3 -m unittest scripts/test_gas.py` → 19 tests OK. `python3 -m unittest discover -s .github/ci` → 27 tests OK. (The path form `.github/ci/test_affected.py` does not work with `python -m unittest`: the leading dot is not a module name; the CI uses `discover -s .github/ci`.)
- `python3 .github/ci/check-links.py` → `0 broken link(s)`.
- `python3 .github/ci/affected.py matrix` (non-PR) → `{"include":[{"dir":"packages/achievement"},{"dir":"packages/quest"}]}`.
- `scarb --manifest-path packages/quest/Scarb.toml package` → packaged 10 files, verified, `target/package/quiver_quest-0.1.0.tar.zst`.

## Cost
| Entrypoint or algorithm | Before | After | Budget | Note |
|---|---|---|---|---|
| quest `test_constants::quest_bounds_are_the_accepted_ones` | — | 13720 | 14406 | l2_gas |
| achievement `test_constants::achievement_bounds_are_the_accepted_ones` | — | 13720 | 14406 | l2_gas |

The two figures are equal because the fixed cost of a test dominates five `assert!`s on constants.

## Acceptance criteria
- AC-1: metadata lists both members; both packages build and pass their test (above).
- AC-2: budgets 14406 = ceil(1.05 × 13720); `--check` passes for both and fails on doctored budgets (above).
- AC-3: unit tests pass, including one package only, dependents (three-package graph), root manifest → all, docs only → none.
- AC-4: pull request CI green: `affected`, `package (packages/quest)` 1m14s, `package (packages/achievement)` 1m21s, `cairo`, `scripts`, `links`. All packages ran (the pull request touches the root manifest). Total run about 2 minutes.
- AC-5: `release.yml` has no `publish` and no secret. Checked by a dry run of its steps locally: `release_check.py quiver_quest-v0.1.0` correctly refuses (`CHANGELOG.md has no section ## [0.1.0]`, because 0.1.0 is not released), `quiver_quest-v0.2.0` refuses (`the manifest says version 0.1.0`), unit tests cover the accepted case; `scarb package` and the archive path `target/package/*.tar.zst` verified locally. The workflow itself has not run (needs a tag).
- AC-6: see below.
- AC-7: `docs/WORKSPACE.md` covers layout, adding a package, local checks, CI, gas, release, publishing; link check passes.

### §6.2 answer
In a scratch folder, `scratch_b` depended on `scratch_a = { path = "../a", version = "^0.1.0" }`. `scarb package` records, in the packaged `Scarb.toml`, only `[dependencies.scratch_a] version = "^0.1.0"`: **the `path` is dropped, the version kept** (the original is kept as `Scarb.orig.toml`). Consequence: `scarb package` **with verification fails** (`package not found in registry: scratch_a ^0.1.0`) until the dependency is published; with `--no-verify` it succeeds. So a dependent can only be released after its dependency. Inherited workspace fields resolve in the packaged manifest (quest: edition, license, repository, `cairo-version = "^2.19.0"`, `starknet` and `snforge_std` as `^` versions). Scratch folder deleted.

## Deviations from the brief
- `release.yml` calls `cairo.yml` as a reusable workflow (`workflow_call` added to it) for "the workspace is green"; the tag therefore also runs `cairo.yml` directly. Concurrency groups include the workflow name so the two do not cancel each other.
- `scarb metadata` in `affected.py` uses `--no-deps` (members' dependencies are still listed; no registry access needed).
- Added `release_check.py` and its tests, and `install-snforge.sh`.

## Escalations
- **`actions/upload-artifact` is pinned by the tag `@v4`, not a commit SHA** in `release.yml`. `gh api` and `git ls-remote` were refused in my sandbox, and I would not invent a SHA. The orchestrator should replace it with the SHA of a verified release, with a `# vX.Y.Z` comment. It runs only on a release tag, so this PR's CI is unaffected.
- `.github/` is a shared directory; the brief's allowlist covers the files above, which I stayed within.

## Open questions
- A `GAS.md` `--write` on a test with no budget writes `None`; `--check` then fails on the missing budget, so it is caught, but the workflow in WORKSPACE.md §5 (set a high budget, measure, set `N`) is a manual step. Worth automating if tests multiply. (Fix loop 1: `--write` now refuses a package with a missing measure, but a missing budget still writes `None`.)

## Fix loop 1
Commit `cf311b5`, pushed; CI green (`affected`, both `package` jobs, `cairo`, `scripts`, `links`).

1. **Caches**: `git rm --cached` of the six tracked `.pyc` (`.github/ci/__pycache__/`, `scripts/__pycache__/`), folders deleted, `__pycache__/` and `*.py[cod]` appended to `.gitignore`.
2. **Pin**: `.github/workflows/release.yml` (upload step) is now `actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1`, and the escalation comment is removed. The inputs `name`, `path`, `if-no-files-found` are the ones I used with v4; I could not read v7's `action.yml` from my sandbox (no network API), so their existence in v7 is not verified by me. It only runs on a release tag, so this PR's CI does not exercise it.
3. **Renames**: `.github/ci/affected.py` `changed_files` now runs `git diff --name-only --no-renames`, and takes `cwd` and `remote` so it can be tested. New test `Renames.test_moving_a_file_out_of_a_package_still_affects_it` in `test_affected.py` builds a temporary git repo, moves `packages/quest/notes.md` to `docs/`, and asserts both paths are listed and quest is affected.
4. **Budgets keyed by module path**: `scripts/gas.py` `parse_tests` / `file_prefix` / `read_tests` derive snforge's name from the file (`tests/x.cairo` → `<pkg>_integrationtest::x::fn`, `src/a/b.cairo` → `<pkg>::a::b::fn`, inline `mod` blocks extend it) and match it exactly; GAS.md now lists the full path (both `GAS.md` regenerated). Tests: `ParseTests` (including `test_the_real_test_matches_snforge_name` against the real package) and `Check.test_same_name_in_two_modules_one_without_budget_fails`. Limit: a `tests/lib.cairo` that declares modules is not supported; a test that snforge measures but the sources do not map fails with "not found in the sources", so a mismatch is loud, not silent.
5. **Coverage**: `gas.py` `coverage()` (used by `--check` and `--write`) fails, naming the test, for any source `#[test]` with no measured result (`#[ignore]`d ones say so), for a measured test not in the sources, and when snforge's `Tests:` summary (`parse_summary`) reports ignored or filtered out ≠ 0, or has no summary. Tests: `Check.test_ignored_test_fails_and_is_named`, `test_test_without_a_measure_fails_and_is_named`, `test_no_summary_fails`, `Summary`. Local runs: `scripts/gas.py … --check` passes for both packages (30 tests in `test_gas.py`, 28 in `.github/ci`).
6. **Base branch's script**: `.github/workflows/cairo.yml`, `affected` job, step `matrix`: on `pull_request` it does `git show origin/$BASE:.github/ci/affected.py` to `$RUNNER_TEMP/affected.py` and runs that when it exists; otherwise (as in this PR, since `main` has no such file yet) the PR's copy runs. The unit-test step still uses the PR's copy. `docs/WORKSPACE.md` §4 says the full run on `main` is the backstop since a PR can also edit the workflow. Not exercised in this PR's CI for the reason above; the first PR after the merge will be the first to use it.
7. **Single tag run**: `tags` removed from `cairo.yml`'s push trigger (header comment updated); `release.yml` keeps calling it. `docs/WORKSPACE.md` §4 table and the `affected.py` docstring updated. The concurrency group still includes `github.workflow`, now harmless.

## Fix loop 2
Commit `32ed79f`, pushed; CI green (`affected`, both `package` jobs, `cairo`, `scripts`, `links`).

8. **Fail closed** (`.github/workflows/cairo.yml`, `affected` job, step `matrix`): on `pull_request`, if `git show origin/$BASE:.github/ci/affected.py` succeeds the base copy computes the matrix; otherwise the step prints `the base branch has no .github/ci/affected.py (or git show failed): running every package` and runs the PR copy as `env -u GITHUB_EVENT_NAME python3 .github/ci/affected.py matrix`, its non-pull-request mode, which lists every workspace member without looking at changed files. It is exercised by this very pull request (main has no script yet): both packages ran. `docs/WORKSPACE.md` section 4 says it.
1. **Known limit** (no code change): `docs/WORKSPACE.md` section 4 has a paragraph saying the CI of a pull request is not a security boundary against its author, that main is not protected (D-121), and that what holds is the orchestrator review of `.github/` and `scripts/` plus the full run on main after the merge.
