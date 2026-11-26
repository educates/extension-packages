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

# merge_json FILE PACKAGE_FILE FILTER [JQ_OPTION...]
#
# Replaces FILE with what the jq FILTER makes of FILE and PACKAGE_FILE,
# read as .[0] and .[1], FILE being read as null when there is none yet.
# Each JQ_OPTION, such as --arg NAME VALUE, is passed to jq.
merge_json() {
  file=$1
  package_file=$2
  filter=$3
  shift 3
  mkdir -p "$(dirname "$file")"
  if [ -f "$file" ]; then
    set -- "$@" "$filter" "$file" "$package_file"
  else
    set -- "$@" "[null] + . | $filter" "$package_file"
  fi
  if ! jq -s "$@" > "$file.tmp"; then
    rm -f "$file.tmp"
    return 1
  fi
  mv "$file.tmp" "$file"
}

# Prints the milliseconds since the epoch. A date without %N, which the
# GNU date the workshop images have knows, gives whole seconds, and a date
# that fails gives 0, so that timing the script never fails it.
now_ms() {
  ms=$(date +%s%3N 2>/dev/null) || ms=
  case $ms in
    "" | *[!0-9]*)
      ms=$(date +%s 2>/dev/null) || ms=
      case $ms in
        "" | *[!0-9]*) ms=0 ;;
        *) ms=${ms}000 ;;
      esac
      ;;
  esac
  echo "$ms"
}

start=$(now_ms)

mkdir -p "$EXTENSIONS_DIR"
count=0
for extension in "$PACKAGE_DIR"/extensions/*; do
  name=$(basename "$extension")
  rm -rf "${EXTENSIONS_DIR:?}/$name"
  cp -R "$extension" "$EXTENSIONS_DIR/$name"
  count=$((count + 1))
done

# Each of the package's entries replaces any entry for the same extension.
# The package's file was recorded under another home directory, so each
# absolute path in an entry, its location's path, and its fsPath and
# external URL where it has them, is set to the extension's directory
# under $EXTENSIONS_DIR, which its relativeLocation names.
merge_json "$EXTENSIONS_DIR/extensions.json" "$PACKAGE_DIR/extensions.json" '
  def in_extensions_dir:
    ($extensions_dir + "/" + .relativeLocation) as $path
    | .location.path = $path
    | if .location | has("fsPath") then .location.fsPath = $path else . end
    | if .location | has("external")
      then .location.external = "file://" + ($path | split("/") | map(@uri) | join("/"))
      else . end;
  (.[1] | map(.identifier.id | ascii_downcase)) as $ids
  | [(.[0] // [])[] | select((.identifier.id | ascii_downcase) as $id
      | $ids | any(. == $id) | not)]
    + (.[1] | map(in_extensions_dir))' \
  --arg extensions_dir "$EXTENSIONS_DIR"

merge_json "$SETTINGS" "$PACKAGE_DIR/settings.json" '.[0] + .[1]'

elapsed=$(($(now_ms) - start))
if [ "$elapsed" -lt 0 ]; then
  elapsed=0
fi
echo "vscode-java-tools-oci-overlay put $count extensions in place in $((elapsed / 1000)).$(printf '%03d' $((elapsed % 1000))) seconds"
