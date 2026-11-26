#!/usr/bin/env bash

# Downloads the Java extensions for the editor: the redhat.java build for
# each platform, under one name in each platform's extensions directory,
# and the six vscjava extensions, which serve every platform, into common.
# The package's version is that of vscode-java-pack. The package script
# runs this with the package source as the working directory and its fetch
# helpers defined.

version=$(manifest_version)

redhat_java=https://github.com/redhat-developer/vscode-java/releases/download/v1.58.0

download "$redhat_java/java-linux-x64-1.58.0-1114.vsix" \
  45049a2273c78814287fb31a45255e5ce1fdbe34161bb9f1ba8f62a6aa84bdfc \
  "$DOWNLOADS/java-linux-x64.vsix"
install_file "$DOWNLOADS/java-linux-x64.vsix" \
  linux-amd64/extensions/redhat.java.vsix 0644

download "$redhat_java/java-linux-arm64-1.58.0-1114.vsix" \
  09e2fa38e2f28304bcb530d46cf17a7996b904b981acb04cef9356f42acf4c61 \
  "$DOWNLOADS/java-linux-arm64.vsix"
install_file "$DOWNLOADS/java-linux-arm64.vsix" \
  linux-arm64/extensions/redhat.java.vsix 0644

# fetch_vscjava_vsix NAME VERSION SHA256
#
# Downloads vscjava.NAME at VERSION from open-vsx and installs it into
# common as vscjava.NAME.vsix.
fetch_vscjava_vsix() {
  local file=vscjava.$1.vsix
  download "https://open-vsx.org/api/vscjava/$1/$2/file/vscjava.$1-$2.vsix" \
    "$3" "$DOWNLOADS/$file"
  install_file "$DOWNLOADS/$file" "common/extensions/$file" 0644
}

fetch_vscjava_vsix vscode-java-debug 0.60.0 \
  f09ebe358a7b08b3c17b21b8d8207b0649acad120eb6f1604dc4f15379f59d66
fetch_vscjava_vsix vscode-java-test 0.47.0 \
  0fba1ecd2913f40185a8a91c0e5f342418b67dbe0516d813e0ae6b514c1fff99
fetch_vscjava_vsix vscode-maven 0.45.3 \
  2d7b30676793604e0c140ab0e5cc5a649d6af2fd9e0b2797911f86a9164654b0
fetch_vscjava_vsix vscode-gradle 3.18.0 \
  a0466d8e44b873d2a4e83155d4b7b68d4ff7d989a618f2f54513ae9d7c686dfa
fetch_vscjava_vsix vscode-java-dependency 0.27.7 \
  da7c82e61e69f66dfe0ad66a3bb517772944ee065122b672ccf7de40dd3bb469
fetch_vscjava_vsix vscode-java-pack "$version" \
  911168da03c2d416b83a77cea9e52e396c616e73d8e2b5a58ebf4dd508667cca
