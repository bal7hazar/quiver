#!/usr/bin/env bash
# Installs snforge and universal-sierra-compiler from their official GitHub release archives, with
# the SHA-256 of each archive pinned below and verified BEFORE extraction. Used instead of
# foundry-rs/setup-snfoundry, which calls software-mansion/setup-universal-sierra-compiler@v1, a
# mutable tag: every executed action of the workflow stays pinned by SHA, transitively.
#
# Usage: SNFORGE=<x.y.z> install-snforge.sh   (the version comes from a validated .tool-versions)
# A snforge version without a pinned hash is refused: when .tool-versions moves, add its hash here
# (sha256sum of the release archive, cross-checked with the `digest` GitHub shows for the asset).
set -euo pipefail

: "${SNFORGE:?SNFORGE is not set}"
: "${RUNNER_TEMP:?RUNNER_TEMP is not set}"

case "$SNFORGE" in
  0.64.0) snforge_sha=24c96491a1532431ccd9d1675b49d881eb3d09f209748199d91b4d4eed5030a0 ;;
  *)
    echo "no pinned SHA-256 for snforge $SNFORGE: add it to .github/ci/install-snforge.sh" >&2
    exit 1
    ;;
esac

# universal-sierra-compiler 2.10.1 serves snforge 0.64.0 (CI runs it with that compiler).
usc=2.10.1
usc_sha=8f6d9faf2ce644faa99e2acee7e855e3fbeb7919b99ec13d29f57c08089f2fb9

dest="$RUNNER_TEMP/cairo-tools"
mkdir -p "$dest"

# fetch_and_extract <name> <url> <sha256>
# Up to three attempts, ten seconds apart, for the infrastructure failures of the download (an
# HTTP 500 from GitHub, a reset connection, a truncated archive). The SHA-256 is verified on every
# attempt and before extraction: a wrong archive still fails the step, after the last attempt.
fetch_and_extract() {
  local archive="$dest/$1.tar.gz" attempt
  for attempt in 1 2 3; do
    if curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 --output "$archive" "$2" \
      && echo "$3  $archive" | sha256sum --check --strict -; then
      break
    fi
    [ "$attempt" -lt 3 ] || { echo "$1: download or checksum failed 3 times" >&2; exit 1; }
    echo "$1: download or checksum failed (attempt $attempt of 3), retrying in 10 s" >&2
    sleep 10
  done
  tar --extract --gzip --strip-components=1 --file "$archive" --directory "$dest"
}

fetch_and_extract snforge \
  "https://github.com/foundry-rs/starknet-foundry/releases/download/v$SNFORGE/starknet-foundry-v$SNFORGE-x86_64-unknown-linux-gnu.tar.gz" \
  "$snforge_sha"
fetch_and_extract universal-sierra-compiler \
  "https://github.com/software-mansion/universal-sierra-compiler/releases/download/v$usc/universal-sierra-compiler-v$usc-x86_64-unknown-linux-gnu.tar.gz" \
  "$usc_sha"

echo "$dest/bin" >> "$GITHUB_PATH"
"$dest/bin/snforge" --version
"$dest/bin/universal-sierra-compiler" --version
