#!/bin/sh

# Puts the package's Java extensions in place for the editor without
# installing them. Copies each unpacked extension into code-server's
# extensions directory, adds the package's entries to the extensions.json
# there, and merges the package's editor settings into the user's
# settings, the package's keys replacing any the user's settings already
# have. Running it again replaces the copies and the entries, and
# duplicates nothing. Reports how long it took.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

EXTENSIONS_DIR=$HOME/.local/share/code-server/extensions
SETTINGS=$HOME/.local/share/code-server/User/settings.json

# merge_json FILE PACKAGE_FILE FILTER
#
# Replaces FILE with what the jq FILTER makes of FILE and PACKAGE_FILE,
# read as .[0] and .[1], or copies PACKAGE_FILE to FILE when there is no
# FILE yet.
merge_json() {
  if [ -f "$1" ]; then
    if ! jq -s "$3" "$1" "$2" > "$1.tmp"; then
      rm -f "$1.tmp"
      return 1
    fi
    mv "$1.tmp" "$1"
  else
    mkdir -p "$(dirname "$1")"
    cp "$2" "$1"
  fi
}

# Milliseconds since the epoch, from the GNU date the workshop images have.
start=$(date +%s%3N)

mkdir -p "$EXTENSIONS_DIR"
count=0
for extension in "$PACKAGE_DIR"/extensions/*; do
  name=$(basename "$extension")
  rm -rf "${EXTENSIONS_DIR:?}/$name"
  cp -R "$extension" "$EXTENSIONS_DIR/$name"
  count=$((count + 1))
done

# Each of the package's entries replaces any entry for the same extension.
merge_json "$EXTENSIONS_DIR/extensions.json" "$PACKAGE_DIR/extensions.json" '
  (.[1] | map(.identifier.id | ascii_downcase)) as $ids
  | [.[0][] | select((.identifier.id | ascii_downcase) as $id
      | $ids | any(. == $id) | not)]
    + .[1]'

merge_json "$SETTINGS" "$PACKAGE_DIR/settings.json" '.[0] + .[1]'

elapsed=$(($(date +%s%3N) - start))
echo "vscode-java-tools-oci-overlay put $count extensions in place in $((elapsed / 1000)).$(printf '%03d' $((elapsed % 1000))) seconds"
