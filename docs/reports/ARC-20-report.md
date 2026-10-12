# [Sonnet 5.5] ARC-20 — CI checks LICENSE in each package archive (D-286)

## Summary
`.github/ci/check_archive.py packages/<name>` reads the name and version from `scarb metadata`,
builds the archive with `scarb package -p <name>`, lists it with `tar --zstd -t`, and exits 1 when
`<name>-<version>/LICENSE` is not an entry. It is a step (`archive has LICENSE`) of the per-package
`package (packages/<pkg>)` job of `cairo.yml`, so the required `cairo` check covers it. No job is
renamed, deleted or narrowed.

## Path gating
`LICENSE` was not a trigger (a `LICENSE`-only change concerned no job). It is now in `ALL_FILES` of
`affected.py`, so it runs all packages and, through `CAIRO_FILES`, the `cairo` group. `Scarb.toml`,
`Scarb.lock` and `packages/<dir>/` already were. `test_affected.py` follows (LICENSE moved from the
"concerns nothing" list to the shared Cairo files). On a pull request the base branch's copy of
`affected.py` decides, so this PR's own run is gated by the old script: it runs all packages
because it touches `.github/ci/` and `cairo.yml`. The new trigger applies from the merge.

## Tests
`test_check_archive.py` (pure function: present, absent, other version, `LICENSE.md`, empty), run by
the `affected` job beside `test_affected.py`. `python3 -m unittest discover -s .github/ci -p "test_*.py"`:
55 tests OK.

## Local verification (VPS, `RAYON_NUM_THREADS=1`, `prlimit --as=8589934592`)
Pass (tree committed: `scarb package` refuses a dirty one):
- `quiver_quest-0.2.0.tar.zst: 67 entries` / `ok: quiver_quest-0.2.0/LICENSE`
- `quiver_achievement-0.2.0.tar.zst: 40 entries` / `ok: quiver_achievement-0.2.0/LICENSE`
- `quiver_leaderboard-0.1.1.tar.zst: 22 entries` / `ok: quiver_leaderboard-0.1.1/LICENSE`

Fail: the leaderboard archive re-packed by hand without its LICENSE (scratchpad, nothing committed):
`FAIL: nolic.tar.zst has no quiver_leaderboard-0.1.1/LICENSE`, exit 1.
