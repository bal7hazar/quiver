# [Sonnet 5.5] ARC-17 — hook tests and shellcheck

## Summary
- `scripts/test_hook.py` (new, `unittest`): builds, in a fresh temporary directory, a bare origin, a clone holding
  `git archive HEAD` of this repository with `core.hooksPath=.githooks`, and a linked worktree on a new branch. Every git
  call gets an environment with all `GIT_*` variables removed; nothing touches a real repository's configuration
  (the real repository is only read by `git archive HEAD`). The directory is removed afterwards.
- Cases: (1) a scripts-only commit pushed with a real `git push` from the linked worktree runs the real hook and
  prepush.sh (output contains `prepush: OK`), the push lands in origin; (2) a dirty tracked file → refused (real push);
  (3) an untracked file → refused; (4) a ref that is not HEAD → refused; (5) a deletion-only push → allowed.
  After every case: the clone's `.git/config` is byte-for-byte unchanged, `core.bare` is `false`, `core.worktree` is
  unset, and `git status` works in the clone and in the linked worktree.
- Case (1) also commits a probe test, `.github/ci/test_zz_hook_env.py`, into the temporary clone only: prepush.sh
  discovers it, and it fails when `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`, `GIT_COMMON_DIR` or `GIT_OBJECT_DIRECTORY`
  reaches the tests. `test_affected.Renames` clears `GIT_*` itself, so without the probe removing the clearing line of
  prepush.sh went unnoticed (measured, below).
- CI (`tooling.yml`): the `shellcheck` step also checks `.githooks/pre-push` and `.github/ci/install-snforge.sh`; a new
  step runs `python3 -m unittest scripts/test_hook.py`.
- `docs/WORKSPACE.md`: one line listing the test.

## Files changed
`scripts/test_hook.py` (new), `.github/workflows/tooling.yml`, `docs/WORKSPACE.md`, `docs/reports/ARC-17-report.md`.
`.githooks/pre-push` and `.github/ci/install-snforge.sh` unchanged (shellcheck is not installed here; see AC-2).

## Commands run
- `python3 -m unittest scripts/test_hook.py -v`, real tree: `Ran 5 tests in 1.5s`, `OK`.
- Mutation, in a scratch copy only (`git archive HEAD` + this test, the line
  `for var in $(git rev-parse --local-env-vars); do unset "$var"; done` removed from the copy's `scripts/prepush.sh`,
  committed in a scratch repository): first run, before the probe existed, `Ran 5 tests`, `OK` (not detected).
  With the probe: `AssertionError: Lists differ: ['GIT_DIR'] != []`, `prepush: FAIL: python unit tests`,
  `FAILED (failures=1)`. The same test in the real tree: `OK`.
- `shellcheck`: not installed here (`command not found`); no pip package available.

## Cost
—

## Acceptance criteria
- AC-1: passes locally (above); fails with the clearing line removed, in the scratch copy only (above).
- AC-2: not shown locally (no shellcheck here). CI's `shellcheck` step runs on both scripts; if it reports a finding,
  it is fixed minimally in a follow-up commit.
- AC-3: the `tooling.yml` diff is the two changes below only.
- AC-4: CI, see the PR.

`tooling.yml` diff:
```diff
-          shellcheck scripts/*.sh
+          shellcheck scripts/*.sh .githooks/pre-push .github/ci/install-snforge.sh
+
+      - name: pre-push hook tests
+        run: python3 -m unittest scripts/test_hook.py
```

## Deviations from the brief
- The probe test (above), added so that AC-1's second half holds.
- Two commands were refused in the first attempt (a read-only `git config core.hooksPath` on the real clone, and a
  scratch-copy script of the mutation check, both with "Permission ... has been denied", no other text). Neither was
  retried; the mutation check was redone with the Edit tool and separate commands.

## Escalations
None.
## Open questions
None.
