#!/usr/bin/env bash

# Installs the educates CLI from a release of educates-training-platform.
#
# Usage: install.sh VERSION DIR
#
# Downloads the release's educates-linux-amd64 asset and its checksums.txt,
# checks the asset's sha256 against the line checksums.txt has for it, and
# installs it as DIR/educates with mode 0755. When a download or the check
# fails, it installs nothing.
#
# EDUCATES_RELEASES_URL sets where releases are downloaded from, as
# <url>/<version>/<asset>. It defaults to the GitHub releases of
# educates/educates-training-platform.

set -euo pipefail

ASSET=educates-linux-amd64
RELEASES_URL=${EDUCATES_RELEASES_URL:-https://github.com/educates/educates-training-platform/releases/download}

if [ $# -ne 2 ]; then
  echo "Usage: $(basename "$0") VERSION DIR" >&2
  exit 1
fi
version=$1
dir=$2

work=$(mktemp -d "${TMPDIR:-/tmp}/install-educates.XXXXXX")
trap 'rm -rf "$work"' EXIT

# download_file URL FILE
download_file() {
  if ! curl -fsSL --retry 3 -o "$2" "$1"; then
    echo "Error: unable to download $1" >&2
    return 1
  fi
}

# Prints the sha256 of a file, with sha256sum where there is one and
# shasum (macOS) otherwise.
sha256_of() {
  local sum
  if command -v sha256sum >/dev/null 2>&1; then
    sum=$(sha256sum "$1")
  else
    sum=$(shasum -a 256 "$1")
  fi
  printf '%s\n' "${sum%% *}"
}

download_file "$RELEASES_URL/$version/checksums.txt" "$work/checksums.txt"
expected=$(awk -v asset="$ASSET" '$2 == asset { print $1 }' "$work/checksums.txt")
if [ -z "$expected" ]; then
  echo "Error: the checksums.txt of release $version has no line for $ASSET" >&2
  exit 1
fi

download_file "$RELEASES_URL/$version/$ASSET" "$work/$ASSET"
actual=$(sha256_of "$work/$ASSET")
if [ "$actual" != "$expected" ]; then
  echo "Error: $ASSET of release $version has sha256 $actual, expected $expected" >&2
  exit 1
fi

chmod 0755 "$work/$ASSET"
mkdir -p "$dir"
mv "$work/$ASSET" "$dir/educates"
echo "Installed educates $version as $dir/educates"
