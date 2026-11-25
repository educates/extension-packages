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

redhat_java=https://github.com/redhat-developer/vscode-java/releases/download/v1.42.0

download "$redhat_java/java-linux-x64-1.42.0-561.vsix" \
  7660b7b527be6fda46a917966b34d828e7416d5cc84287b29b88e7b99c1737f9 \
  "$DOWNLOADS/redhat.java-linux-x64.vsix"
unpack_extension "$DOWNLOADS/redhat.java-linux-x64.vsix" \
  linux-amd64/extensions/redhat.java-1.42.0

download "$redhat_java/java-linux-arm64-1.42.0-561.vsix" \
  e15bc9b2a665d3453203402621b5441062aa41b0ec2d140661f439326fd248c1 \
  "$DOWNLOADS/redhat.java-linux-arm64.vsix"
unpack_extension "$DOWNLOADS/redhat.java-linux-arm64.vsix" \
  linux-arm64/extensions/redhat.java-1.42.0

unpack_vscjava_extension vscode-java-debug 0.58.2 \
  1dc2a6c87abc9a4309c65bffb44952ba1e95b70a30d16058a38f37b142ca64b2
unpack_vscjava_extension vscode-java-test 0.43.1 \
  16f091b1683cd07845671727b4b1332092660887f08b6af5c76225bfdc071f07
unpack_vscjava_extension vscode-maven 0.44.0 \
  e42b9eb56fe46d619ae81b766d61f291d04685ded8e3e999603f923299d5890c
unpack_vscjava_extension vscode-gradle 3.15.0 \
  fda5ffe9d783faf5c5d8317a57fb978e2d3fd00d235e44c01917ab9900e3a4d2
unpack_vscjava_extension vscode-java-dependency 0.24.1 \
  2ce3dbb53c30184a80832357d9d31f994bc851a5371a5e375c21b0c92bd877bb
unpack_vscjava_extension vscode-java-pack "$version" \
  a808f61a13846e11d45a249ca967d2396939bdd66f40f268960b21a1d3faaec0

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
