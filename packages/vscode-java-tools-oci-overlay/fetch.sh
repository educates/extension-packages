#!/usr/bin/env bash

# Downloads the Java extensions for VS Code and unpacks each one under the
# directory name its entry in common/extensions.json records: the
# redhat.java build for each platform into that platform's extensions
# directory, and the six vscjava extensions into common's. Each directory
# holds what code-server installs from a .vsix, the contents of the
# archive's extension directory. The package script runs this with the
# package source as the working directory and its fetch helpers defined.

# The version of vscode-java-pack, which names the package's version.
version=$(manifest_version)

# unpack_extension VSIX DIR
#
# Unpacks VSIX and moves the extension directory it holds to DIR.
unpack_extension() {
  local vsix=$1 dir=$2
  unpack_zip "$vsix" "$vsix.unpacked"
  mkdir -p "$(dirname "$dir")"
  mv "$vsix.unpacked/extension" "$dir"
  rm -rf "$vsix.unpacked" "$vsix"
}

# unpack_vscjava_extension NAME VERSION SHA256
#
# Downloads the vscjava extension NAME at VERSION from open-vsx and unpacks
# it into common.
unpack_vscjava_extension() {
  local vsix=vscjava.$1-$2.vsix
  download "https://open-vsx.org/api/vscjava/$1/$2/file/$vsix" "$3" \
    "$DOWNLOADS/$vsix"
  unpack_extension "$DOWNLOADS/$vsix" "common/extensions/vscjava.$1-$2"
}

redhat_java=https://github.com/redhat-developer/vscode-java/releases/download/v1.58.0

download "$redhat_java/java-linux-x64-1.58.0-1114.vsix" \
  45049a2273c78814287fb31a45255e5ce1fdbe34161bb9f1ba8f62a6aa84bdfc \
  "$DOWNLOADS/redhat.java-linux-x64.vsix"
unpack_extension "$DOWNLOADS/redhat.java-linux-x64.vsix" \
  linux-amd64/extensions/redhat.java-1.58.0

download "$redhat_java/java-linux-arm64-1.58.0-1114.vsix" \
  09e2fa38e2f28304bcb530d46cf17a7996b904b981acb04cef9356f42acf4c61 \
  "$DOWNLOADS/redhat.java-linux-arm64.vsix"
unpack_extension "$DOWNLOADS/redhat.java-linux-arm64.vsix" \
  linux-arm64/extensions/redhat.java-1.58.0

unpack_vscjava_extension vscode-java-debug 0.60.0 \
  f09ebe358a7b08b3c17b21b8d8207b0649acad120eb6f1604dc4f15379f59d66
unpack_vscjava_extension vscode-java-test 0.47.0 \
  0fba1ecd2913f40185a8a91c0e5f342418b67dbe0516d813e0ae6b514c1fff99
unpack_vscjava_extension vscode-maven 0.45.3 \
  2d7b30676793604e0c140ab0e5cc5a649d6af2fd9e0b2797911f86a9164654b0
unpack_vscjava_extension vscode-gradle 3.18.0 \
  a0466d8e44b873d2a4e83155d4b7b68d4ff7d989a618f2f54513ae9d7c686dfa
unpack_vscjava_extension vscode-java-dependency 0.27.7 \
  da7c82e61e69f66dfe0ad66a3bb517772944ee065122b672ccf7de40dd3bb469
unpack_vscjava_extension vscode-java-pack "$version" \
  911168da03c2d416b83a77cea9e52e396c616e73d8e2b5a58ebf4dd508667cca

# The setup script copies every unpacked directory and adds the entries of
# extensions.json, so for each platform the two must name the same
# extensions.
recorded=$(sed -n 's/^ *"relativeLocation": "\(.*\)",$/\1/p' common/extensions.json | sort)
for platform in linux-amd64 linux-arm64; do
  unpacked=$( (ls common/extensions && ls "$platform/extensions") | sort)
  if [ "$unpacked" != "$recorded" ]; then
    echo "Error: the extensions unpacked for $platform are not those common/extensions.json records" >&2
    exit 1
  fi
done
