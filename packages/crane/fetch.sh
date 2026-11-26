#!/usr/bin/env bash

# Extracts crane from the go-containerregistry release archive for each
# platform. The package script runs this with the package source as the
# working directory and its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/google/go-containerregistry/releases/download/v$version

download "$release/go-containerregistry_Linux_x86_64.tar.gz" \
  0ab7a1d6932a213aed964ce97666c3077fe691c8606413674a8b3e0b9ec4cda0 \
  "$DOWNLOADS/go-containerregistry_Linux_x86_64.tar.gz"
extract_tar "$DOWNLOADS/go-containerregistry_Linux_x86_64.tar.gz" crane \
  linux-amd64/bin/crane 0755

download "$release/go-containerregistry_Linux_arm64.tar.gz" \
  898c0cff975f898a33e8c4580bdafb0e7c02c7faa33374e946762f97c4ab7110 \
  "$DOWNLOADS/go-containerregistry_Linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/go-containerregistry_Linux_arm64.tar.gz" crane \
  linux-arm64/bin/crane 0755
