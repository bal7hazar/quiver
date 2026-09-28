# [GPT-6-Luna] Audit — ARC-02 — quality and security

## Verdict

FAIL

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | `.github/workflows/cairo.yml:57–73` | **Partially resolved.** The base-branch script protects the matrix calculation when that script exists, but the workflow itself still comes from the PR. | A PR can change the matrix step to emit an empty matrix and `any=false`; the summary job can then succeed. The workflow calls the full run on `main` a backstop, but that runs after the PR may already have merged. | Run the required check from a trusted workflow that the PR cannot change, or enforce an external merge gate that rejects changes without a trusted full check. |
| 2 | — | `.github/ci/affected.py:120–130`; `.github/ci/test_affected.py` rename test | **Resolved.** | `git diff --name-only --no-renames` reports both the old and new paths. The added test checks that moving a file out of a package still affects it. | — |
| 3 | — | `scripts/gas.py:47–50, 95–110, 207–228`; `scripts/test_gas.py` coverage tests | **Resolved.** | The check now fails when a source test has no measured result, or snforge reports ignored or filtered tests. A nonzero test run or a missing summary also fails. | — |
| 4 | — | `scripts/gas.py:53–76, 79–87, 121–139`; `scripts/test_gas.py:162–168` | **Resolved.** | Budgets and `GAS.md` rows use fully qualified snforge paths. A test covers same-named functions in separate modules and confirms an unbudgeted one fails. The source-test prefix also matches snforge’s documented unit-test naming, such as `first_test::tests::test_sum`. ([Starknet Foundry: Writing Tests](https://foundry-rs.github.io/starknet-foundry/testing/testing.html)) | — |
| 5 | — | `.github/workflows/release.yml:49–53` | **Resolved.** | `upload-artifact` is pinned to the supplied commit SHA. The tag still passes through the release checker before `scarb package`; the workflow contains no publish step or secret. | — |
| 6 | — | `.gitignore`; tracked files | **Resolved.** | Python cache patterns are ignored, and `git ls-files` reports no tracked cache or build-output files. | — |
| 7 | — | `.github/workflows/cairo.yml:10–16`; `.github/workflows/release.yml:17–20` | **Resolved.** | Cairo no longer triggers directly on release tags; the release workflow calls it once. | — |
| 8 | major | `.github/workflows/cairo.yml:62–73` | The fallback uses the PR’s affected-package script when the base branch has no copy. | If a base branch has this workflow but lacks `.github/ci/affected.py`, the `git show` condition fails and the step runs the PR checkout’s script. That script can emit an empty matrix for the PR’s changed package. | Fail closed or force all packages when the base script is missing; do not use PR-controlled discovery logic as the fallback. |

## Coverage

Reviewed the updated workflow and affected-package logic, rename test, gas parser and tests, release workflow, tracked-file status, and the ARC-02 audit brief. The `cairo` summary still fails when the affected job fails and requires package success when `any=true`; it accepts a skipped package job only when `any=false`.

I did not run the tests or CI. The added gas tests cover the reported-name cases and summary outcomes, but this is a source review rather than a fresh run.