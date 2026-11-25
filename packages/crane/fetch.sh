#!/usr/bin/env bash

# Extracts crane from the go-containerregistry release archive for each
# platform. The package script runs this with the package source as the
# working directory and its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/google/go-containerregistry/releases/download/v$version

download "$release/go-containerregistry_Linux_x86_64.tar.gz" \
  5f2b43c32a901adaaabaa78755d56cea71183954de7547cb4c4bc64b9ac6b2ff \
  "$DOWNLOADS/go-containerregistry_Linux_x86_64.tar.gz"
extract_tar "$DOWNLOADS/go-containerregistry_Linux_x86_64.tar.gz" crane \
  linux-amd64/bin/crane 0755

download "$release/go-containerregistry_Linux_arm64.tar.gz" \
  9118c29cdf2197441c4a934cf517df76c021ba12a70edc14ee9dc4dc08226680 \
  "$DOWNLOADS/go-containerregistry_Linux_arm64.tar.gz"
extract_tar "$DOWNLOADS/go-containerregistry_Linux_arm64.tar.gz" crane \
  linux-arm64/bin/crane 0755
