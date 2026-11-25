#!/usr/bin/env bash

# Extracts thv from the ToolHive release archive for each platform. The
# package script runs this with the package source as the working directory
# and its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/stacklok/toolhive/releases/download/v$version

download "$release/toolhive_${version}_linux_amd64.tar.gz" \
  78ac04331519b0e4d2787f5eebdbdf7b926919d8856761f5113d46c66fa7f037 \
  "$DOWNLOADS/toolhive_linux_amd64.tar.gz"
extract_tar "$DOWNLOADS/toolhive_linux_amd64.tar.gz" thv \
  linux-amd64/bin/thv 0755

download "$release/toolhive_${version}_linux_arm64.tar.gz" \
  49f253a7153b235afb9de79dc6666a221b417e74d3498c71fe546f26f24e08d6 \
  "$DOWNLOADS/toolhive_linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/toolhive_linux_arm64.tar.gz" thv \
  linux-arm64/bin/thv 0755
