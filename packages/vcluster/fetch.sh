#!/usr/bin/env bash

# Downloads the vcluster release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/loft-sh/vcluster/releases/download/v$version

download "$release/vcluster-linux-amd64" \
  03b950eed632e07f2f3e2e8856f92649ba1d974c51f36fede9f432c9c018428c \
  "$DOWNLOADS/vcluster-linux-amd64"
install_file "$DOWNLOADS/vcluster-linux-amd64" linux-amd64/bin/vcluster 0755

download "$release/vcluster-linux-arm64" \
  6f108737ee58eed5a1a680764f153672d0c4406ca8274b092eaba5134159702b \
  "$DOWNLOADS/vcluster-linux-arm64"
install_file "$DOWNLOADS/vcluster-linux-arm64" linux-arm64/bin/vcluster 0755
