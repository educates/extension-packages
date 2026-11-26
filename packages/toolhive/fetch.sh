#!/usr/bin/env bash

# Extracts thv from the ToolHive release archive for each platform. The
# package script runs this with the package source as the working directory
# and its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/stacklok/toolhive/releases/download/v$version

download "$release/toolhive_${version}_linux_amd64.tar.gz" \
  27dfb82d3affa22fdf2da4fcc0662e635bd4f695ae9adb7a12c004e15c28b8b0 \
  "$DOWNLOADS/toolhive_linux_amd64.tar.gz"
extract_tar "$DOWNLOADS/toolhive_linux_amd64.tar.gz" thv \
  linux-amd64/bin/thv 0755

download "$release/toolhive_${version}_linux_arm64.tar.gz" \
  5710520aca9ad1c625f3b030f187c5438f5fcec8bc6cbdf4f49ef4c0dc4f327d \
  "$DOWNLOADS/toolhive_linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/toolhive_linux_arm64.tar.gz" thv \
  linux-arm64/bin/thv 0755
