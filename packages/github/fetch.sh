#!/usr/bin/env bash

# Extracts gh from the GitHub CLI release archive for each platform. Each
# archive holds gh under a directory named after the archive. The package
# script runs this with the package source as the working directory and its
# fetch helpers defined.

version=$(manifest_version)
release=https://github.com/cli/cli/releases/download/v$version

download "$release/gh_${version}_linux_amd64.tar.gz" \
  c421091ae5800390e6aef1f50bfda59cc1d4f2ef2200bcd4e1a662c05c28c444 \
  "$DOWNLOADS/gh_linux_amd64.tar.gz"
extract_tar "$DOWNLOADS/gh_linux_amd64.tar.gz" \
  "gh_${version}_linux_amd64/bin/gh" linux-amd64/bin/gh 0755

download "$release/gh_${version}_linux_arm64.tar.gz" \
  f0b07f0aeaf00f137df1bd33a76e717b1945f4b83bd6a3296b365414d3eb413f \
  "$DOWNLOADS/gh_linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/gh_linux_arm64.tar.gz" \
  "gh_${version}_linux_arm64/bin/gh" linux-arm64/bin/gh 0755
