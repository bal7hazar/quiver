# [Sonnet 5.5] ARC-14 — prepush waits at most 90 s for the VPS build lock

## Summary
`scripts/prepush.sh` takes the project lock, then the machine-wide heavy lock (same files and order as
`scripts/lock.sh`), waiting 90 s in all (`flock -w`), and keeps both open while the compile steps (the
package builds and `gas.py --check`) run, so the shim sees the heavy lock held by an ancestor. If the wait
runs out, the compile steps are skipped with one line, `build/gas: skipped, the VPS build lock was busy for 90 s; CI will compile`,
and the script continues (exit 0 if the rest passed). `scarb fmt --check` and `scarb metadata` take no lock.
Off Linux (the Mac) no lock is taken, builds run, and the gas step prints `gas: skipped, pins are checked on Linux (CI)`.
Scope extension: `scripts/lock.sh` now takes the heavy lock itself for every compile subcommand
(scarb build, test, lint, check, execute; snforge test), with or without `--heavy`; `fmt` and `metadata` stay
outside it; the nested-call rules are unchanged.

## Files changed
`scripts/prepush.sh`, `scripts/lock.sh`, `AGENTS.md`, `docs/WORKSPACE.md`, `docs/reports/ARC-14-report.md`.
No workflow file. `scripts/gas.py` unchanged (see call sites).

## Call sites of scarb / snforge
- `scripts/lock.sh` (the `case "$1:$sub"` block, ~line 41): used the `--manifest-path`-first form, which the
  shim does not lock; fixed (`heavy=1` for compile subcommands). `scarb build --help` of 2.20.1 lists no
  `--manifest-path`, so the leading form is kept.
- `scripts/prepush.sh`: `scarb fmt --check` (no lock needed), `scarb metadata` (none), `scarb --manifest-path <d>/Scarb.toml build`
  (now under the locks held by the script itself), `python3 scripts/gas.py` (same).
- `scripts/gas.py:266` runs `["snforge", "test"]`: `~/.local/bin/snforge` exists and locks when `test` is its
  first argument, as here; nothing to change.
- `scripts/agent.sh:400`: a comment only. Not touched. `.github/ci/*`: excluded.

## Commands run (real output, VPS, Linux)
- AC-1, scripts-only change (this branch): `fmt/build skipped (no Cairo input changed)`, `prepush: OK (1s)`, `real 0m1.112s`.
- AC-3, one-line change in `packages/quest/src/constants.cairo` (reverted), real lock busy (other programmes'
  runs queued on it, seen in `ps`; I did not hold it): four runs, each
  `fmt (workspace) OK 1s`, `build/gas: skipped, the VPS build lock was busy for 90 s; CI will compile`,
  `prepush: OK (92s)` to `(94s)`, `real 1m31.4s` to `1m34.1s`.
- AC-3 with my own lock: `HEAVY_BUILD_LOCK=<worktree>/target/ac3-heavy.lock` held by `flock … sleep 115` in another shell:
  same skip line, `prepush: OK (92s)`, `real 1m32.503s`; lock file released and deleted.
- Lock.sh: with an own `HEAVY_BUILD_LOCK` and `QUIVER_BUILD_LOCK` (held 40 s elsewhere),
  `timeout 20 scripts/lock.sh scarb --manifest-path packages/quest/Scarb.toml build` waited: `real 0m20.034s`, exit 124 (waiting for the heavy lock);
  `scripts/lock.sh scarb --manifest-path … metadata` in the same state: `real 0m0.189s` (no heavy lock). Lock files deleted.
- `bash -n scripts/prepush.sh scripts/lock.sh`: OK. `shellcheck` is not installed here; the `tooling` CI job runs it.

## Acceptance criteria
- AC-1 met (above).
- AC-2 NOT measured: the real machine heavy lock was never free. I polled it for 20 minutes
  (400 × 3 s) and 4 runs each waited out the 90 s. I did not use a lock file of my own for it (that would
  run snforge outside the machine's serialisation, which risks the OOM kills it prevents). The compile path
  is exercised only when the lock is obtained; please run it once with a free lock.
- AC-3 met (real lock busy, and own lock held).
- Lock.sh criterion met (above).
- AC-4: `bash -n` OK; shellcheck not available locally; CI result below.

## Deviations from the task
- The compile steps call `nice -n 10 scarb --manifest-path … build` directly under the held locks instead of
  through `scripts/lock.sh`, so that the 90 s budget is one wait for both locks.
- Off Linux the lock is skipped even if `flock` exists.

## Escalations
- AC-2 unmeasured (above).
- The shim `~/.local/bin/scarb` locks only a first-argument subcommand (the Overseer knows); not edited.
