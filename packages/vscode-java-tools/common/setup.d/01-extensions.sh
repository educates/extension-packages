#!/bin/sh

# Installs the Java extensions into the editor and merges the package's
# editor settings into the user's settings, the package's keys replacing
# any the user's settings already have. Running it again skips each
# extension the editor already has at the same version, and leaves the
# settings as they are.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Prints the publisher.name@version of the extension in a .vsix, in lower
# case, as code-server --list-extensions --show-versions prints it, or
# nothing when the .vsix can't be read.
vsix_version() {
  unzip -p "$1" extension/package.json 2>/dev/null \
    | jq -r '"\(.publisher).\(.name)@\(.version)"' 2>/dev/null \
    | tr '[:upper:]' '[:lower:]'
}

INSTALLED=$(code-server --list-extensions --show-versions 2>/dev/null \
  | tr '[:upper:]' '[:lower:]')

# vscode-java-test depends on redhat.java and vscode-java-debug, so those
# come first, and the pack, which lists the others, comes last.
for extension in redhat.java vscjava.vscode-java-debug \
  vscjava.vscode-java-test vscjava.vscode-maven vscjava.vscode-gradle \
  vscjava.vscode-java-dependency vscjava.vscode-java-pack; do
  vsix=$PACKAGE_DIR/extensions/$extension.vsix
  version=$(vsix_version "$vsix")
  if [ -n "$version" ] && printf '%s\n' "$INSTALLED" | grep -qxF "$version"; then
    echo "Extension $version is installed already."
  else
    code-server --install-extension "$vsix"
  fi
done

SETTINGS=$HOME/.local/share/code-server/User/settings.json

mkdir -p "$(dirname "$SETTINGS")"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi
if ! jq -s '.[0] + .[1]' "$SETTINGS" "$PACKAGE_DIR/settings.json" > "$SETTINGS.tmp"; then
  rm -f "$SETTINGS.tmp"
  exit 1
fi
mv "$SETTINGS.tmp" "$SETTINGS"
