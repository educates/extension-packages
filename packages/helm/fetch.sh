#!/usr/bin/env bash

# Extracts helm from the Helm release archive for each platform, which
# get.helm.sh serves. Each archive holds helm under a directory named after
# the platform. The package script runs this with the package source as the
# working directory and its fetch helpers defined.

version=$(manifest_version)
release=https://get.helm.sh

download "$release/helm-v$version-linux-amd64.tar.gz" \
  d1c0278d46beab79582d7e50f5b3dc206944ba8e577cde618513fd07daa53983 \
  "$DOWNLOADS/helm-linux-amd64.tar.gz"
extract_tar "$DOWNLOADS/helm-linux-amd64.tar.gz" \
  linux-amd64/helm linux-amd64/bin/helm 0755

download "$release/helm-v$version-linux-arm64.tar.gz" \
  df31cb61680ef728f82c770e5280dd565617bee6b039d37e85c677288be4bbb0 \
  "$DOWNLOADS/helm-linux-arm64.tar.gz"
extract_tar "$DOWNLOADS/helm-linux-arm64.tar.gz" \
  linux-arm64/helm linux-arm64/bin/helm 0755
