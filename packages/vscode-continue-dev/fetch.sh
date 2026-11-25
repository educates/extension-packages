#!/usr/bin/env bash

# Downloads the Continue extension from Open VSX, one build for each
# platform, each under the same name in its platform directory. The package
# script runs this with the package source as the working directory and its
# fetch helpers defined.

version=$(manifest_version)
api=https://open-vsx.org/api/Continue/continue

download "$api/linux-x64/$version/file/Continue.continue-$version@linux-x64.vsix" \
  2cab725c52dfe3ad73cab5074a9de634e60a2b3aa13134250abd7f30c864b7d5 \
  "$DOWNLOADS/continue-linux-x64.vsix"
install_file "$DOWNLOADS/continue-linux-x64.vsix" linux-amd64/extensions/continue.vsix 0644

download "$api/linux-arm64/$version/file/Continue.continue-$version@linux-arm64.vsix" \
  ac3a79b4f0cd587bf2ff72968df642b5d7d179de1ada2aeb4df39a5bf1d4d987 \
  "$DOWNLOADS/continue-linux-arm64.vsix"
install_file "$DOWNLOADS/continue-linux-arm64.vsix" linux-arm64/extensions/continue.vsix 0644
