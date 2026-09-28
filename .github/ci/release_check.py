#!/usr/bin/env python3
"""Checks a release tag `quiver_<name>-v<x.y.z>` against the package it names (release.yml).

Usage: release_check.py <tag>

The tag names package `quiver_<name>`, in packages/<name>. Its version must equal the version of
the package manifest, and its CHANGELOG.md must have a section `## [x.y.z]`. On success writes
`dir` (the package directory) and `version` to GITHUB_OUTPUT (or stdout); otherwise exits 1 with
the reason. The tag is chosen by whoever pushes it, so it is validated before it is used.
Standard library only; never publishes anything.
"""

import os
import pathlib
import re
import sys

TAG_RE = re.compile(r"^quiver_([a-z0-9]+(?:_[a-z0-9]+)*)-v([0-9]+\.[0-9]+\.[0-9]+)$")


def parse_tag(tag):
    """(package name, directory name, version) of a tag, or ValueError."""
    found = TAG_RE.match(tag)
    if not found:
        raise ValueError(f"tag {tag!r} is not quiver_<name>-v<x.y.z>")
    return f"quiver_{found.group(1)}", found.group(1), found.group(2)


def manifest_field(manifest, field):
    """The value of `field = "..."` in the [package] table of a manifest text."""
    package = re.search(r"^\[package\]\n(.*?)(?=^\[|\Z)", manifest, re.M | re.S)
    found = re.search(rf'^{field}\s*=\s*"([^"]*)"', package.group(1), re.M) if package else None
    return found.group(1) if found else None


def has_changelog_section(changelog, version):
    return re.search(rf"^## \[{re.escape(version)}\]", changelog, re.M) is not None


def check(tag, root="."):
    """Returns (directory, version) when the tag is consistent with the package, else raises."""
    name, directory, version = parse_tag(tag)
    package_dir = pathlib.Path(root) / "packages" / directory
    manifest_path = package_dir / "Scarb.toml"
    if not manifest_path.is_file():
        raise ValueError(f"{tag}: no package at packages/{directory}")
    manifest = manifest_path.read_text()
    if manifest_field(manifest, "name") != name:
        raise ValueError(f"{tag}: packages/{directory} is not the package {name}")
    if manifest_field(manifest, "version") != version:
        raise ValueError(
            f"{tag}: the manifest says version {manifest_field(manifest, 'version')}, not {version}"
        )
    changelog = package_dir / "CHANGELOG.md"
    if not changelog.is_file() or not has_changelog_section(changelog.read_text(), version):
        raise ValueError(f"{tag}: packages/{directory}/CHANGELOG.md has no section ## [{version}]")
    return f"packages/{directory}", version


def main(argv):
    if len(argv) != 1:
        print(__doc__, file=sys.stderr)
        return 2
    try:
        directory, version = check(argv[0])
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1
    lines = f"dir={directory}\nversion={version}\n"
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a") as out:
            out.write(lines)
    else:
        sys.stdout.write(lines)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
