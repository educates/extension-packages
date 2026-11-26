#!/usr/bin/env bash

# Downloads the argocd release binary for each platform. The package
# script runs this with the package source as the working directory and
# its fetch helpers defined.

version=$(manifest_version)
release=https://github.com/argoproj/argo-cd/releases/download/v$version

download "$release/argocd-linux-amd64" \
  3750cd7ed2a2ef05c640344b86f29aa99c9783e847c8f326c81e3900ad39412b \
  "$DOWNLOADS/argocd-linux-amd64"
install_file "$DOWNLOADS/argocd-linux-amd64" linux-amd64/bin/argocd 0755

download "$release/argocd-linux-arm64" \
  04a7b681d6c5eec193159705c5556114f8cba98abada4c17c3991124065e1964 \
  "$DOWNLOADS/argocd-linux-arm64"
install_file "$DOWNLOADS/argocd-linux-arm64" linux-arm64/bin/argocd 0755
