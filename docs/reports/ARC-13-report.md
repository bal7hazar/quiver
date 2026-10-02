# [Sonnet 5.5] ARC-13 — prepush check

## Summary
`scripts/prepush.sh` (the local check before a push), `.githooks/pre-push` (runs it; also passes the
`quiver_*-v*` tags being pushed to the release check), `AGENTS.md` (new: the repository had none),
`docs/WORKSPACE.md` (layout and section 3), and download retries in `.github/ci/install-snforge.sh`.
Steps, cheapest first, the first failure stops the run: unit tests of the Python scripts, links,
`scarb fmt --check`, `scarb build` (single-threaded, through `scripts/lock.sh` when `flock` exists) of each
package `affected.py` says the change affects, `gas.py --check` only for a package whose `src/`, `tests/`,
`Scarb.toml`, `Scarb.lock`, `.tool-versions` or `GAS.md` changed (a dependency's inputs count), and
`release_check.py` only for a pushed tag (a tag derived from the manifest would compare the manifest with
itself and fail ordinary changes whose version is ahead of the changelog).

## Files changed
- `scripts/prepush.sh`, `.githooks/pre-push` (new)
- `AGENTS.md` (new), `docs/WORKSPACE.md`
- `.github/ci/install-snforge.sh` (retries)
- `.github/ci/test_affected.py` (test only, added to the allowlist by the orchestrator: its `Renames` test drops
  every `GIT_*` variable from the environment, so its `git init`/`add` cannot reach the real repository)
- `docs/reports/ARC-13-report.md`
- Workflow files changed: none (`cairo.yml`, `release.yml` untouched).

## Commands run
Real outputs (VPS, Linux; times include waiting for the shared heavy lock):
- Clean branch: `prepush: OK (6s)`.
- AC-1 broken format, `const   BROKEN_FMT :  u8   =  1;` appended to `packages/quest/src/constants.cairo`, reverted:
  `fmt (workspace)  FAIL  2s`, the diff, `prepush: FAIL: fmt (workspace) (2s)`, exit 1.
- AC-2, one-line comment in `packages/quest/src/constants.cairo` (reverted):
  `build packages/quest OK 10s`, `gas packages/quest (snforge, slow) OK 551s`, `prepush: OK (563s)`;
  `real 9m22.740s`, `user 2m22.184s`. The gap is the wait for the machine's heavy lock behind other programmes
  (CPU time was 2m22s). Measured as it is; over the two-minute aim whenever a measured source changes.
- AC-2, scripts-only comment in `scripts/lock.sh`: `build skipped`, `gas skipped`, `prepush: OK (1s)`, real 1.9s.
- Comment in `scripts/gas.py` (affects all packages, no gas input): builds both, `prepush: OK (11s)`, real 10.4s.
- Docs/tests change (this branch): `prepush: OK (2s)`.
- AC-3: `git -c core.hooksPath=.githooks push -u origin HEAD` ran the script (output above, `prepush: OK (2s)`).
  Its first run, with the bug fixed since, failed in `test_affected` because a hook exports `GIT_DIR`: the test's
  `git init` rewrote the clone's config to `bare = true` (repaired by the orchestrator). Fixed twice: the script
  unsets git's local variables, and the test no longer inherits `GIT_*`
  (checked: `GIT_DIR=<bogus> GIT_INDEX_FILE=<bogus> python3 -m unittest discover -s .github/ci -p test_affected.py` passes).

## Cost
—

## Acceptance criteria
- AC-1 met (clean: OK; broken format: FAIL naming `fmt (workspace)`, exit 1).
- AC-2 measured, above. 9m22s for a `src/` change (gas step, heavy lock); seconds otherwise.
- AC-3 met (the hook ran on my push).
- AC-4 met: the only workflow-adjacent change is in the download script, quoted:

```diff
 # fetch_and_extract <name> <url> <sha256>
+# Up to three attempts, ten seconds apart, ... a wrong archive still fails the step, after the last attempt.
 fetch_and_extract() {
-  local archive="$dest/$1.tar.gz"
-  curl --fail ... --output "$archive" "$2"
-  echo "$3  $archive" | sha256sum --check --strict -
+  local archive="$dest/$1.tar.gz" attempt
+  for attempt in 1 2 3; do
+    if curl --fail ... --output "$archive" "$2" \
+      && echo "$3  $archive" | sha256sum --check --strict -; then
+      break
+    fi
+    [ "$attempt" -lt 3 ] || { echo "$1: download or checksum failed 3 times" >&2; exit 1; }
+    echo "$1: download or checksum failed (attempt $attempt of 3), retrying in 10 s" >&2
+    sleep 10
+  done
   tar --extract ...
```
- AC-5 met at 8b1e5d6: `gh pr checks 43` all pass (affected, package quest 2m13s, package achievement 38s, cairo, scripts incl. shellcheck, links).

## Deviations from the brief
- `git config core.hooksPath` not run (refused; the orchestrator set it in both clones).
- Scarb's download through `setup-scarb` has no retry: the action is a third-party step pinned by SHA, and
  retrying a `uses:` step needs `continue-on-error` plus a second step, which the workflow rule forbids. So
  `cairo.yml` and `release.yml` are unchanged.
- `install-snforge.sh` was not run locally (the command was refused); CI runs it on every package job.
- `shellcheck` is not installed here; the `tooling` job runs it on `scripts/*.sh`.

## Escalations
None open. The `bare = true` incident above is repaired.

## Open questions

## Fix loop 1 (review-opus at 8b1e5d6: PASS WITH FINDINGS)
1. `.githooks/pre-push` now refuses (exit 1) a push whose ref (`local_sha^{commit}`) is not `HEAD`
   ("check out the ref you push") and a push with uncommitted changes to tracked files ("commit or stash
   first"); deletions stay allowed. Checked by feeding the hook crafted stdin: dirty tree: refused, exit 1;
   a ref that is not HEAD: refused, exit 1; a deletion: exit 0. `scripts/prepush.sh` still checks the working tree
   when run by hand.
2. `scripts/prepush.sh` runs no scarb (no fmt, no `scarb metadata`, no build, no gas) when no Cairo input changed
   (`.cairo`, any `Scarb.toml`, `Scarb.lock`, `.tool-versions`); it prints `fmt/build skipped (no Cairo input changed)`.
   Consequence: a change to `GAS.md` alone is not checked locally. Otherwise fmt, builds and gas as before; the gas
   step prints its warning line first.
3. The script header says a change to `scripts/gas.py` gets its gas check from CI.

Re-measured (real output):
- Scripts-only change (comment in `scripts/lock.sh`): `fmt/build skipped (no Cairo input changed)`,
  `prepush: OK (1s)`, `real 0m0.754s`.
- One-line comment in `packages/quest/src/constants.cairo`: python tests 1s, links 0s, fmt 3s,
  build achievement 0s, build quest 7s, then `gas packages/quest (snforge, slow)` **did not finish**: it waited for the
  shared heavy lock for 30 minutes and the run was stopped by its time limit (`Terminated`). Other programmes and other
  threads' `prepush.sh` runs were queued on the same lock (`ps` showed them). I did not restart it. The earlier
  measure of the same change, with a free queue, was `prepush: OK (563s)` (`real 9m22s`, `user 2m22s`). Everything
  before the gas step took 11s.

## Fix loop 2 (review-opus at 3335848: PASS WITH FINDINGS)
1. `.githooks/pre-push` also refuses (exit 1) when `git ls-files --others --exclude-standard` is not empty: the script
   reads untracked files from disk (a `mod foo;` committed without `foo.cairo` would pass locally and fail in CI). It
   prints `pre-push: untracked files: add, ignore or remove them` and the first five names. Ignored files stay allowed.
   Checked with crafted stdin: an untracked `probe-untracked.txt` gives the message, the file name and `exit=1`;
   only an ignored `REPORT.md` (and `target/`) gives `prepush: OK (0s)`, `exit=0`. The probe files were removed.
2. The header of `scripts/prepush.sh` no longer lists a package's `GAS.md` as a gas input of step 5, and says a change
   to `scripts/gas.py` or to a `GAS.md` alone gets its gas check from CI. `GAS.md` is not in the Cairo-input regex.
Not in this lot: an automated test of the hook's refusals, shellcheck of the hook.
