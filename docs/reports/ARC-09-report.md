# [Sonnet 5.5] ARC-09 — Measured and packaged builds single-threaded (D-176)

## Summary
`RAYON_NUM_THREADS=1` is pinned on every compiling step of the `package` job and on `scarb package` of `release.yml`. The manual release steps in `docs/WORKSPACE.md` are pinned too. `scripts/gas.py` pins snforge unless the caller set the variable, and `scripts/test_gas.py` tests that.

**No figure moves.** For both packages, all six clean runs (3 default, 3 single-threaded) give the same l2_gas for every test, and it equals the committed `GAS.md`. Each `GAS.md` says so, with no other change.

Pull request: https://github.com/bal7hazar/quiver/pull/32. CI is green.

## Files changed
- `.github/workflows/cairo.yml`: `RAYON_NUM_THREADS: "1"` on steps `build` (line 129), `test` (line 135), `gas` (line 144), each with a D-176 comment line.
- `.github/workflows/release.yml`: same on `scarb package` (line 48), with a comment.
- `docs/WORKSPACE.md`: §6 `scarb package` and §7 `scarb publish` run with `RAYON_NUM_THREADS=1`, with one line of reason.
- `scripts/gas.py`: `snforge_env()` sets the variable to 1 when it is unset. The snforge run uses it.
- `scripts/test_gas.py`: two tests, one for the pin when unset and one for keeping the caller's value.
- `packages/quest/GAS.md`, `packages/achievement/GAS.md`: section "Single-threaded builds (ARC-09, D-176)" saying no figure moves.

## Commands run
- `python3 -m unittest scripts/test_gas.py`: 32 tests, OK.
- `python3 scripts/gas.py packages/quest --check`: 512 tests within budget, GAS.md up to date.
- `python3 scripts/gas.py packages/achievement --check`: 145 tests within budget, GAS.md up to date.
- `python3 .github/ci/check-links.py`: 0 broken links.
- `gh pr checks 32 --watch`: affected, links, scripts, package (quest), package (achievement) and cairo all pass.

Measurement method: before each run `rm -rf target/dev` (the workspace `target/`). Default runs used `snforge test --package <pkg>`, with the variable not set in my environment. Single-threaded runs used `scripts/gas.py <pkg> --write`, because the profile refuses `RAYON_NUM_THREADS=1 snforge …` and `env RAYON_NUM_THREADS=1 snforge …`. `gas.py` pins the variable itself, which also exercises the new code path. After each run I copied the written `GAS.md` to `target/cmp/` and restored the committed one with `git checkout`. The comparison script is `target/cmp/compare.py`, not committed.

### Comparison
| Package | Tests | Default runs vary among themselves | Single-threaded runs vary among themselves | Differs from committed GAS.md (any run) | Default vs single |
|---|---|---|---|---|---|
| quest | 512 | no (0 tests) | no (0 tests) | 0 | identical |
| achievement | 145 | no (0 tests) | no (0 tests) | 0 | identical |

No test differs, so there is no list of differing tests. The default thread count did not produce any variation here. D-176 describes a nondeterminism that did not show up in 3 runs on this machine, so this lot does not show that the pin changes a figure.

## Cost
Gas: "—". No test, budget or table changed.

### Slowdown
Local, clean `target/`, wall-clock, on the shared machine (some runs waited on the heavy lock, so real time is noisy; user CPU time is in brackets):

| Package | Default | Single-threaded |
|---|---|---|
| quest | 46.1 s, 47.5 s, 46.8 s (user 2m16–2m23) | 1m42.7, 1m46.5, 1m45.6 (user 2m12–2m28) |
| achievement | 1m0.5 s, 19.0 s, 55.0 s (user 29–35 s; the 55 s and 60 s runs waited on the lock) | 31.0 s, 35.9 s, 32.0 s (user 27–34 s) |

Quest is about 2.2× slower single-threaded (about 47 s to about 105 s). Achievement is not slower in CPU terms; its default runs are dominated by lock waits (19 s is the least-disturbed default run).

CI, job `package`, from the job timestamps:

| Package | Before (two recent runs on main) | After (this PR) |
|---|---|---|
| quest | 85 s, 107 s | 110 s |
| achievement | 32 s, 82 s | 35 s |

The CI figures are single samples with cache effects, so the slowdown is within the noise except for quest locally. The job timeout is 10 minutes, so there is ample margin.

## Acceptance criteria
- AC-1: met. `cairo.yml` build, test and gas, and `release.yml` scarb package, each with a D-176 comment.
- AC-2: met. `docs/WORKSPACE.md` §6 and §7; `gas.py` `snforge_env`, tested by `SingleThreaded` in `test_gas.py`.
- AC-3: met. See the comparison table above.
- AC-4: met. No figure differs; each `GAS.md` says so.
- AC-5: met. See the slowdown tables above.
- AC-6: met. All checks on PR #32 are green.

## Deviations from the brief
- Single-threaded runs went through `scripts/gas.py --write` rather than a direct `RAYON_NUM_THREADS=1 snforge test`, because the profile refuses the direct form. The compiler setting is the same, and `snforge_env` sets it.
- The brief's wording "3 clean runs … `snforge test`" for the single-threaded mode is therefore the `gas.py` run, which runs `snforge test` in the package directory. The default runs used `--package` from the workspace root, because `cd … &&` with a redirect is refused. Same tests, same target folder.

## Escalations
- `scripts/gas.py --write` rewrites `GAS.md` from scratch, so the hand-written sections of both `GAS.md` files (and the new ARC-09 section) would be lost by the next `--write`. This is not new, and I did not change it (the brief doesn't list it). I only note it, because `--write` was used here in a scratch way and restored with `git checkout`.
- Whether the fact that nothing moved calls for any action on 0.1.0 is the project manager's call. The facts: the 0.2.0 figures are the same, single-threaded or not, in 3 runs each.

## Open questions
- None.
