#!/usr/bin/env bash

# Downloads the argocd release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/argoproj/argo-cd/releases/download/v$version

download "$release/argocd-linux-amd64" \
  39758d449ea4d1ccc5e863dccc7658b6122095758c7064b6b6606d02c4f8f549 \
  "$DOWNLOADS/argocd-linux-amd64"
install_file "$DOWNLOADS/argocd-linux-amd64" linux-amd64/bin/argocd 0755

download "$release/argocd-linux-arm64" \
  5783392eb607448013a973d2f047365ea16f654773f1f033339fc745a13d95b4 \
  "$DOWNLOADS/argocd-linux-arm64"
install_file "$DOWNLOADS/argocd-linux-arm64" linux-arm64/bin/argocd 0755
