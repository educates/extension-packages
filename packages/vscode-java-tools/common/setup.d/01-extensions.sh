#!/bin/sh

# Installs the Java extensions into the editor and merges the package's
# editor settings into the user's settings, the package's keys replacing
# any the user's settings already have. Running it again installs nothing
# new and leaves the settings as they are.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

# vscode-java-test depends on redhat.java and vscode-java-debug, so those
# come first, and the pack, which lists the others, comes last.
for extension in redhat.java vscjava.vscode-java-debug \
  vscjava.vscode-java-test vscjava.vscode-maven vscjava.vscode-gradle \
  vscjava.vscode-java-dependency vscjava.vscode-java-pack; do
  code-server --install-extension "$PACKAGE_DIR/extensions/$extension.vsix"
done

SETTINGS=$HOME/.local/share/code-server/User/settings.json

mkdir -p "$(dirname "$SETTINGS")"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi
jq -s '.[0] + .[1]' "$SETTINGS" "$PACKAGE_DIR/settings.json" > "$SETTINGS.$$"
mv "$SETTINGS.$$" "$SETTINGS"
