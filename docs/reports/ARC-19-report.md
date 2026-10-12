# [Sonnet 5.5] ARC-19 — package the LICENSE file; quiver_leaderboard 0.1.1 (D-283)

## Summary
`license-file = "LICENSE"` in `[workspace.package]` of the root `Scarb.toml`, and
`license-file.workspace = true` in each of the three packages. `license = "MIT"` is unchanged.
`quiver_leaderboard` goes to 0.1.1; `quest` and `achievement` keep 0.2.0 with the entry under
`[Unreleased]`. No source, test or `GAS.md` change.

## What was tried
Only the first option: Scarb 2.20.1 resolves the workspace `license-file` against the workspace root
and puts that file into each archive as `<pkg>-<version>/LICENSE`, byte-identical to the root
`LICENSE` (checked with `cmp`). One source of truth, no copy, so the other two options were not needed.

## Files changed
`Scarb.toml`, `packages/*/Scarb.toml`, `packages/*/CHANGELOG.md`, `Scarb.lock` (leaderboard 0.1.1),
this report.

## Commands
`scripts/lock.sh` refuses `scarb package` ("does not wrap 'scarb package'", exit 2), and it is outside
the allowlist, so `scarb package` was run directly:
`RAYON_NUM_THREADS=1 prlimit --as=8589934592 -- scarb package -p <pkg>` (WORKSPACE.md §6, D-176).

## Verification (listing, before -> after; LICENSE is entry 4 of each listing)
| Package | Files before | Files after | LICENSE line |
| --- | --- | --- | --- |
| `quiver_quest` 0.2.0 | 66 | 67 | `quiver_quest-0.2.0/LICENSE` |
| `quiver_achievement` 0.2.0 | 39 | 40 | `quiver_achievement-0.2.0/LICENSE` |
| `quiver_leaderboard` 0.1.1 | 21 (0.1.0) | 22 | `quiver_leaderboard-0.1.1/LICENSE` |

`tar --zstd -xOf … <pkg>-<version>/LICENSE | head -3` gives `MIT License`, an empty line,
`Copyright (c) 2026 Bal7hazar` for all three. The archive contains `VCS.json` (the commit sha), so a
sha256 of the leaderboard archive depends on the head and cannot be written in a file of that head:
the two sha256 values of the final head are in the pull request and the thread report.
No Cairo tests were run: nothing that compiles changed.
