# `quiver_leaderboard` 0.1.1 — publication request (published 2026-10-12)

| | |
|---|---|
| Asked by | `[Sonnet 5.5]` thread of track ARC, for the orchestrator of `quiver` |
| Decides | The project manager's go under D-132 as changed by D-186 (D-283). No owner go is needed; nothing is published, tagged or released by this request |
| Package | **`quiver_leaderboard`** (`packages/leaderboard`) |
| Version | **0.1.1**, after 0.1.0 ([published 2026-10-12](2026-10-12-publish-quiver_leaderboard-0.1.0.md)) |
| Commit | `576a7119c856cee1f05d1318528f6a8323355161` (`main`, [#70](https://github.com/bal7hazar/quiver/pull/70), ARC-19), 2026-10-12 |
| Archive | `quiver_leaderboard-0.1.1.tar.zst`, sha256 **6a347a758237fad4ce7374875858c2ab1d355860d927f8016985496dc3d321dd** (`RAYON_NUM_THREADS=1 prlimit --as=8589934592 -- scarb package -p quiver_leaderboard` from a clean checkout of that commit, Scarb 2.20.1; D-176; 22 files, 72.82 KiB, 15.50 KiB compressed). The two sha256, from two fresh detached worktrees of that commit at different absolute paths and depths, are identical |
| Registry | scarbs.xyz; 0.1.1 is a new version of a package that already has 0.1.0 |
| Published by | Not yet. By hand by the orchestrator, after the go, with the bare `scarb publish -p quiver_leaderboard`, from a clean checkout of that commit, the archive's sha256 compared first; no agent, no CI |

## What changed since 0.1.0

The archive now contains the MIT `LICENSE` file (`quiver_leaderboard-0.1.1/LICENSE`, line 4 of the
archive listing): `license-file` in the workspace manifest, inherited by each package. That is all:

- **No change** to source, interface, results, storage layout or gas. The manifest and the lockfile only.
- The file count goes from 21 to **22**: the 21 files of 0.1.0 plus `LICENSE`.
- [#70](https://github.com/bal7hazar/quiver/pull/70) and [docs/reports/ARC-19-report.md](../reports/ARC-19-report.md).
- `CHANGELOG.md` `## [0.1.1] - 2026-10-12`, under "Fixed".

**Not breaking** (D-283): no notice to the Overseer.

## What was checked, at that commit

| The check (D-132) | Result |
|---|---|
| On `main`, every CI check completed and green | To be run by the project manager at `576a7119c856cee1f05d1318528f6a8323355161` |
| Reviews and audits closed without `blocker` or `major` | To be read by the project manager on [#70](https://github.com/bal7hazar/quiver/pull/70) |
| No source changed after the review | To be checked by the project manager. The change of #70 is the manifests and the lockfile; the report states no source, test or `GAS.md` change |
| Changelog and version agree | `Scarb.toml` 0.1.1; `CHANGELOG.md` `## [0.1.1] - 2026-10-12`; to be run: `.github/ci/release_check.py quiver_leaderboard-v0.1.1` |
| Gas table of that commit | Unchanged from 0.1.0: `packages/leaderboard/GAS.md` at that commit, not re-measured (the figures are those of the [0.1.0 request](2026-10-12-publish-quiver_leaderboard-0.1.0.md), "Cost, measured") |
| `scarb package` from a clean checkout | 22 files, 72.82 KiB, sha256 as above, identical from two worktrees at different paths (removed afterwards). The list: `VERSION`, `CHANGELOG.md`, `GAS.md`, **`LICENSE`**, `README.md`, `Scarb.orig.toml`, `Scarb.toml`, `VCS.json` (the commit and `packages/leaderboard`, no dirty flag), `src/` (13 files), `tests/` (`mocks`, `test_contract`); no settings file, no key |
| The checkouts were clean | Each is a fresh `git worktree add --detach` of the commit, used for nothing else; the archive's `VCS.json` carries the commit and no dirty flag |
| No test dependency declared as a regular one | Unchanged from 0.1.0: `starknet` (`^2.20.0`) is the only entry under `[dependencies]` |

## What the consumer must do

Nothing. 0.1.1 behaves as 0.1.0; a consumer on `^0.1.0` takes it as is.

## To publish (after the go)

`scarb publish -p quiver_leaderboard` from one clean detached checkout of
`576a7119c856cee1f05d1318528f6a8323355161`, `sha256sum --check` of the archive first; then the
annotated tag `quiver_leaderboard-v0.1.1` on that commit. This file is then renamed (the `PENDING-`
prefix dropped) and completed with the registry's checksum, as the 0.1.0 record is.

## Published

The go is **D-285**, 2026-10-12, from the project manager, under the owner's delegation for later
`quiver_leaderboard` versions (D-132 as changed by D-186). The project manager's checklist, in a clean
clone: the commit is on `main` and every check run on it is a success; review-opus PASS WITH FINDINGS
(note) at `e4a4340`, the head of [#70](https://github.com/bal7hazar/quiver/pull/70), squashed into
`576a711`; `scarb package` gives 22 files including `LICENSE`, with the same sha256. The archive's sha256
(`6a347a758237fad4ce7374875858c2ab1d355860d927f8016985496dc3d321dd`) was compared in a command
(`sha256sum` of the archive, then a string comparison with the go's value) before the publish: match.

Published by the orchestrator, by hand, on 2026-10-12: the bare `scarb publish -p quiver_leaderboard` (no
prefix or wrapper) from a clean detached checkout of `576a7119c856cee1f05d1318528f6a8323355161` (Scarb
2.20.1). Output: "Published quiver_leaderboard v0.1.1", with one warning: scarbs.xyz does not support
uploading docs, which does not affect the package. The archive is `quiver_leaderboard-0.1.1.tar.zst`,
22 files, 72.82 KiB (15.50 KiB compressed), containing `quiver_leaderboard-0.1.1/LICENSE`.

| | |
|---|---|
| Registry | **https://scarbs.xyz/packages/quiver_leaderboard**, version 0.1.1 |
| Registry checksum | `sha256:6a347a758237fad4ce7374875858c2ab1d355860d927f8016985496dc3d321dd` (the `cksum` of 0.1.1 in the index `qu/iv/quiver_leaderboard.json`, read back after publishing, equal to the go) |
| Dependencies in the index | `starknet ^2.20.0`; for tests `snforge_std ^0.64.0` and `assert_macros ^2.20.0` |
| 0.1.0 | Unchanged in the index |
| Archive from the registry | Downloaded: same sha256, contains `LICENSE` |
| Tag and release | [`quiver_leaderboard-v0.1.1`](https://github.com/bal7hazar/quiver/releases/tag/quiver_leaderboard-v0.1.1), annotated, on `576a711` |
