#!/usr/bin/env bash

# Extracts gh from the GitHub CLI release archive for each platform. Each
# archive holds gh under a directory named after the archive. The package
# script runs this with the package source as the working directory and its
# fetch helpers defined.

version=$(manifest_version)
release=https://github.com/cli/cli/releases/download/v$version

download "$release/gh_${version}_linux_amd64.tar.gz" \
  a476449fa9625413c54a3734eded62e9e480e49f421ff08e7f3b3879c059a033 \
  "$DOWNLOADS/gh_linux_amd64.tar.gz"
extract_tar "$DOWNLOADS/gh_linux_amd64.tar.gz" \
  "gh_${version}_linux_amd64/bin/gh" linux-amd64/bin/gh 0755

download "$release/gh_${version}_linux_arm64.tar.gz" \
  5e8a0c51e1a8345f36bd0b8bb88604b6a5388df16f3ab3e3b9b6d794fa223a67 \
  "$DOWNLOADS/gh_linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/gh_linux_arm64.tar.gz" \
  "gh_${version}_linux_arm64/bin/gh" linux-arm64/bin/gh 0755
