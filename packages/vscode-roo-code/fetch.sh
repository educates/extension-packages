#!/usr/bin/env bash

# Downloads the Roo Code extension from Open VSX. It is one build for every
# platform, so it goes into common. The package script runs this with the
# package source as the working directory and its fetch helpers defined.

version=$(manifest_version)

download "https://open-vsx.org/api/RooVeterinaryInc/roo-cline/$version/file/RooVeterinaryInc.roo-cline-$version.vsix" \
  d593dcf29f6678c9ef2a2e87a6c37842810a08b232e47689a4cfb701c3eaa485 \
  "$DOWNLOADS/roo-cline.vsix"
install_file "$DOWNLOADS/roo-cline.vsix" common/extensions/roo-cline.vsix 0644
