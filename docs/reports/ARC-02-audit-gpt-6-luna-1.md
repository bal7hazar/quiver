# [GPT-6-Luna] Audit — ARC-02 — quality and security

## Verdict

FAIL

## Findings

| # | Severity | Location | Finding | Evidence / failing scenario | Suggested fix |
|---|---|---|---|---|---|
| 1 | major | `.github/workflows/cairo.yml:41,60`; `.github/ci/affected.py:144–149` | A pull request can change the affected-package script and make the required `cairo` check skip its changed package. | The workflow checks out PR code, then runs that checkout’s `affected.py`. Although the current script treats `.github/ci/**` as shared, a PR can change the script to emit an empty matrix; the summary then succeeds when `any=false`. | Make discovery logic come from trusted base-branch code, or arrange for changes to the discovery/workflow logic to force all packages through a mechanism the PR cannot override. |
| 2 | major | `.github/ci/affected.py:123–126, 71–81` | Renaming a file out of a package can omit the package whose file was removed. | `git diff --name-only` reports the destination of a detected rename. Moving `packages/quest/src/x.cairo` to a documentation path leaves only that destination to classify, so `quest` may not run. | Detect renames and classify both paths, or disable rename detection so the deletion under `packages/quest/` is reported. |
| 3 | major | `scripts/gas.py:32–36, 64–90, 147–154` | The gas check does not establish that every source test ran. | It checks budgets only for tests in `measured`. If one test is ignored or otherwise skipped while another passes, the run can succeed without checking the omitted test’s budget. | Compare discovered source tests against snforge’s collected, passed, ignored, and filtered counts; fail if any source test lacks a measured result. |
| 4 | major | `scripts/gas.py:39–47, 55–62` | Tests with the same function name can share the wrong budget. | Budgets are keyed by bare function name, and `budget_of` selects by the last path component. A budgeted test in one module can mask a same-named test without a budget in another module. | Key source budgets by fully qualified test path, matching snforge’s reported test names. |
| 5 | major | `.github/workflows/release.yml:49–55` | The artifact upload action is not pinned by commit SHA. | `actions/upload-artifact@v4` is a mutable major-version tag, despite the brief requiring all third-party actions to be SHA-pinned. | Pin `upload-artifact` to a verified commit SHA. |
| 6 | minor | Tracked `__pycache__` files under `.github/ci/` and `scripts/` | Compiled Python cache files are committed. | `git ls-files` lists six `.pyc` files. `.gitignore` does not ignore `__pycache__` or `*.py[cod]`. | Remove the tracked cache files and add Python cache patterns to `.gitignore`. |
| 7 | note | `.github/workflows/cairo.yml:8–16`; `.github/workflows/release.yml:9–20` | A release tag starts the workspace checks twice. | `cairo.yml` runs on matching tag pushes, and `release.yml` also calls it as a reusable workflow. This is redundant but the release still waits for its own workspace check. | If the duplicate run is undesirable, exclude release tags from the direct `cairo.yml` push trigger while keeping the reusable workflow path. |

## Coverage

Reviewed the ARC-02 specification, ARC-01 §6.1–6.2, `docs/CAIRO.md` §2, affected-package logic and tests, both workflows, release checker and tests, snforge installer, gas tool and tests, manifests, constants and tests, lockfile, `.gitignore`, and `docs/WORKSPACE.md`.

The current affected-package logic covers direct package changes, shared paths, documentation-only paths, and transitive dependents in its pure functions. The `cairo` summary handles success, failure, cancellation, and the no-package case as specified. The gas parser tests include a sample labeled as real snforge 0.61 output. Manifests and constants match the cited ARC-01 proposal.

I did not run tests or workflows, or perform the §6.2 scratch packaging experiment: this worktree is read-only. Therefore I could not independently confirm the package archive’s dependency manifest or the recorded gas measurements against a fresh run.