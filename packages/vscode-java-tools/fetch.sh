#!/usr/bin/env bash

# Downloads the Java extensions for the editor: the redhat.java build for
# each platform, under one name in each platform's extensions directory,
# and the six vscjava extensions, which serve every platform, into common.
# The package's version is that of vscode-java-pack. The package script
# runs this with the package source as the working directory and its fetch
# helpers defined.

version=$(manifest_version)

redhat_java=https://github.com/redhat-developer/vscode-java/releases/download/v1.42.0

download "$redhat_java/java-linux-x64-1.42.0-561.vsix" \
  7660b7b527be6fda46a917966b34d828e7416d5cc84287b29b88e7b99c1737f9 \
  "$DOWNLOADS/java-linux-x64.vsix"
install_file "$DOWNLOADS/java-linux-x64.vsix" \
  linux-amd64/extensions/redhat.java.vsix 0644

download "$redhat_java/java-linux-arm64-1.42.0-561.vsix" \
  e15bc9b2a665d3453203402621b5441062aa41b0ec2d140661f439326fd248c1 \
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

fetch_vscjava_vsix vscode-java-debug 0.58.2 \
  1dc2a6c87abc9a4309c65bffb44952ba1e95b70a30d16058a38f37b142ca64b2
fetch_vscjava_vsix vscode-java-test 0.43.1 \
  16f091b1683cd07845671727b4b1332092660887f08b6af5c76225bfdc071f07
fetch_vscjava_vsix vscode-maven 0.44.0 \
  e42b9eb56fe46d619ae81b766d61f291d04685ded8e3e999603f923299d5890c
fetch_vscjava_vsix vscode-gradle 3.15.0 \
  fda5ffe9d783faf5c5d8317a57fb978e2d3fd00d235e44c01917ab9900e3a4d2
fetch_vscjava_vsix vscode-java-dependency 0.24.1 \
  2ce3dbb53c30184a80832357d9d31f994bc851a5371a5e375c21b0c92bd877bb
fetch_vscjava_vsix vscode-java-pack "$version" \
  a808f61a13846e11d45a249ca967d2396939bdd66f40f268960b21a1d3faaec0
