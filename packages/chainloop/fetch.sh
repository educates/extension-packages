#!/usr/bin/env bash

# Downloads the chainloop release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/chainloop-dev/chainloop/releases/download/v$version

download "$release/chainloop-linux-amd64" \
  af245467408315775fe69644cedb05af549fed83e12bef733690d73c139ffa9f \
  "$DOWNLOADS/chainloop-linux-amd64"
install_file "$DOWNLOADS/chainloop-linux-amd64" linux-amd64/bin/chainloop 0755

download "$release/chainloop-linux-arm64" \
  dac4e08a8e9aafb18facec29a3506e63944b63d2477b92e4754dce0b354e335e \
  "$DOWNLOADS/chainloop-linux-arm64"
install_file "$DOWNLOADS/chainloop-linux-arm64" linux-arm64/bin/chainloop 0755
