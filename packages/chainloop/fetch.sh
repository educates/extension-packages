#!/usr/bin/env bash

# Downloads the chainloop release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/chainloop-dev/chainloop/releases/download/v$version

download "$release/chainloop-linux-amd64" \
  1dce9953b74fddb2317be18adb9cca97f079df8e0416b72e996dff82b20d300c \
  "$DOWNLOADS/chainloop-linux-amd64"
install_file "$DOWNLOADS/chainloop-linux-amd64" linux-amd64/bin/chainloop 0755

download "$release/chainloop-linux-arm64" \
  23c8e38eca6fb7432a7aa061dd6790420078b5310a855cb504cd7e405e237f56 \
  "$DOWNLOADS/chainloop-linux-arm64"
install_file "$DOWNLOADS/chainloop-linux-arm64" linux-arm64/bin/chainloop 0755
