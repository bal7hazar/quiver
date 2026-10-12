#!/usr/bin/env python3
"""Fails when a package's archive lacks its LICENSE (ARC-20, D-286).

  check_archive.py packages/<name>             builds the archive with `scarb package -p <name>`,
                                               lists it, and checks <name>-<version>/LICENSE
  check_archive.py packages/<name> ARCHIVE     checks an archive already built (a .tar.zst)

The name and the version come from `scarb metadata`, never from this script. Standard library
only; the check is a pure function, tested in test_check_archive.py.
"""

import json
import pathlib
import subprocess
import sys


def license_entry(name, version):
    return f"{name}-{version}/LICENSE"


def missing_license(listing, name, version):
    """True when the archive listing (one path per line) has no <name>-<version>/LICENSE entry."""
    wanted = license_entry(name, version)
    return wanted not in {line.strip() for line in listing.splitlines()}


def member(directory):
    """(name, version, workspace root) of the workspace package in `directory`."""
    raw = subprocess.run(
        ["scarb", "metadata", "--format-version", "1", "--no-deps"],
        capture_output=True, text=True, check=True, cwd=directory,
    ).stdout
    metadata = json.loads(raw)
    here = pathlib.Path(directory).resolve()
    for package in metadata["packages"]:
        if pathlib.Path(package["manifest_path"]).parent == here:
            return package["name"], package["version"], pathlib.Path(metadata["workspace"]["root"])
    raise ValueError(f"no package in {directory}")


def main(argv):
    if len(argv) not in (1, 2):
        print(__doc__, file=sys.stderr)
        return 2
    name, version, root = member(argv[0])
    if len(argv) == 2:
        archive = pathlib.Path(argv[1])
    else:
        subprocess.run(["scarb", "package", "-p", name], check=True, cwd=argv[0])
        archive = root / "target" / "package" / f"{name}-{version}.tar.zst"
    listing = subprocess.run(
        ["tar", "--zstd", "-tf", str(archive)], capture_output=True, text=True, check=True
    ).stdout
    print(f"{archive.name}: {len(listing.splitlines())} entries")
    if missing_license(listing, name, version):
        print(f"FAIL: {archive.name} has no {license_entry(name, version)}", file=sys.stderr)
        return 1
    print(f"ok: {license_entry(name, version)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
