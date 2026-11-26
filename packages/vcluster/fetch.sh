#!/usr/bin/env bash

# Downloads the vcluster release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/loft-sh/vcluster/releases/download/v$version

download "$release/vcluster-linux-amd64" \
  a27849d95f6565fb0eaf452f593b17628116201dd054cde6d83354afac6f89e5 \
  "$DOWNLOADS/vcluster-linux-amd64"
install_file "$DOWNLOADS/vcluster-linux-amd64" linux-amd64/bin/vcluster 0755

download "$release/vcluster-linux-arm64" \
  84dd7a34b10d44c28bf48989c607e3bcb434042ca18bd62788f844f459d091d4 \
  "$DOWNLOADS/vcluster-linux-arm64"
install_file "$DOWNLOADS/vcluster-linux-arm64" linux-arm64/bin/vcluster 0755
