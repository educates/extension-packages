#!/usr/bin/env bash

# Fetches and publishes the extension packages under packages/.
#
# Runs with bash 3.2, as macOS ships it, and later, on macOS and Linux.
# Besides the standard Unix tools it needs only educates and curl.

set -euo pipefail

export LC_ALL=C

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PACKAGES_DIR=$ROOT/packages

# The reserved directories of a package source, and the directories under
# them that a fetch script writes into. Nothing in a fetched directory is
# committed: the package script removes them before each fetch and after a
# failed one, and git ignores them.
RESERVED_DIRS="common linux-amd64 linux-arm64"
FETCHED_DIRS="bin extensions"

usage() {
  cat <<'EOF'
Usage: package.sh <command> [options] [<package>...]

Each command acts on the packages named, or on every package when none is.

Commands:
  list [<package>...]
      Print the package names, one per line.

  fetch [<package>...]
      Empty each package's fetched directories and run its fetch script.

  publish [--dry-run] [--image-repository REPO] [registry flags] [<package>...]
      Fetch each package and publish it with educates package publish as
      REPO/<name>:<version>. REPO defaults to localhost:5001. --dry-run
      validates and prints the digests without contacting a registry. The
      registry flags of educates package publish, such as
      --registry-username, --registry-password and --registry-insecure,
      are passed to it unchanged.
EOF
}

usage_error() {
  echo "Error: $1" >&2
  echo >&2
  usage >&2
  exit 1
}

# A temporary directory for the whole run, created by ensure_work_dir and
# removed when the script exits.
WORK_DIR=

ensure_work_dir() {
  if [ -z "$WORK_DIR" ]; then
    WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/extension-packages.XXXXXX")
    trap 'rm -rf "$WORK_DIR"' EXIT
  fi
}

# Helpers for fetch scripts. A fetch script runs in a bash of its own with
# errexit, nounset and pipefail set, its package source as the working
# directory, these functions defined and $DOWNLOADS naming an empty
# directory for its downloads.

# Prints the version from the package manifest, package.yaml.
manifest_version() {
  local version
  version=$(sed -n -e 's/^version:[[:space:]]*//p' package.yaml |
    sed -e 's/[[:space:]]#.*$//' -e 's/[[:space:]]*$//' \
      -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/") || return 1
  if [ -z "$version" ]; then
    echo "Error: package.yaml sets no version" >&2
    return 1
  fi
  printf '%s\n' "$version"
}

# Prints the sha256 of a file, with sha256sum where there is one and
# shasum (macOS) otherwise.
sha256_of() {
  local sum
  if command -v sha256sum >/dev/null 2>&1; then
    sum=$(sha256sum "$1") || return 1
  else
    sum=$(shasum -a 256 "$1") || return 1
  fi
  printf '%s\n' "${sum%% *}"
}

# download URL SHA256 FILE
#
# Downloads URL to FILE and checks its sha256, removing FILE and failing
# when the download fails or the checksum differs.
download() {
  local url=$1 sha256=$2 file=$3 actual
  mkdir -p "$(dirname "$file")" || return 1
  echo "Downloading $url" >&2
  if ! curl -fsSL --retry 3 -o "$file" "$url"; then
    rm -f "$file"
    echo "Error: unable to download $url" >&2
    return 1
  fi
  actual=$(sha256_of "$file") || return 1
  if [ "$actual" != "$sha256" ]; then
    rm -f "$file"
    echo "Error: $url has sha256 $actual, expected $sha256" >&2
    return 1
  fi
}

# install_file SOURCE TARGET MODE
#
# Copies SOURCE to TARGET, creating TARGET's directory, and gives it MODE,
# such as 0755 for a program or 0644 for any other file.
install_file() {
  local source=$1 target=$2 mode=$3
  mkdir -p "$(dirname "$target")" || return 1
  rm -f "$target" || return 1
  cp "$source" "$target" || return 1
  chmod "$mode" "$target"
}

FETCH_HELPERS="manifest_version sha256_of download install_file"

# Prints the name of every package: each directory under packages/ that
# holds a package.yaml, in name order.
package_names() {
  local manifest
  for manifest in "$PACKAGES_DIR"/*/package.yaml; do
    [ -f "$manifest" ] || continue
    basename "$(dirname "$manifest")"
  done
}

cmd_list() {
  selected_names "$@"
}

# Prints the package names given, or every package's name when none is.
# Fails naming the packages there are when a name given is not one.
selected_names() {
  local all name known
  all=$(package_names)
  if [ $# -eq 0 ]; then
    if [ -n "$all" ]; then
      printf '%s\n' "$all"
    fi
    return 0
  fi
  for name in "$@"; do
    case $name in
      -*) usage_error "unknown option $name" ;;
    esac
    for known in $all; do
      if [ "$name" = "$known" ]; then
        continue 2
      fi
    done
    echo "Error: unknown package \"$name\", expected one of: $(join_words $all)" >&2
    return 1
  done
  printf '%s\n' "$@"
}

# Prints its arguments separated by a comma and a space.
join_words() {
  local IFS=,
  local joined="$*"
  printf '%s\n' "${joined//,/, }"
}

# Removes a package source's fetched directories, and any reserved
# directory left empty.
clear_fetched() {
  local source=$1 dir fetched
  for dir in $RESERVED_DIRS; do
    for fetched in $FETCHED_DIRS; do
      rm -rf "${source:?}/$dir/$fetched"
    done
    if [ -d "$source/$dir" ]; then
      rmdir "$source/$dir" 2>/dev/null || true
    fi
  done
}

# Clears a package's fetched directories and runs its fetch script. When
# the fetch script fails, removes the fetched directories again, so that
# nothing partial remains.
fetch_package() {
  local name=$1
  local source=$PACKAGES_DIR/$name
  local downloads status=0

  clear_fetched "$source"
  if [ ! -f "$source/fetch.sh" ]; then
    return 0
  fi

  echo "Fetching $name" >&2
  ensure_work_dir
  downloads=$WORK_DIR/downloads-$name
  mkdir -p "$downloads"

  # A bash of its own, so that errexit holds in the fetch script whatever
  # the context fetch_package is called in.
  (cd "$source" && DOWNLOADS=$downloads "$BASH" -c "$(declare -f $FETCH_HELPERS)
set -euo pipefail
. ./fetch.sh" fetch.sh) || status=$?

  rm -rf "$downloads"
  if [ "$status" -ne 0 ]; then
    clear_fetched "$source"
    echo "Error: unable to fetch $name, its fetched directories were removed" >&2
    return 1
  fi
}

cmd_fetch() {
  local names name
  names=$(selected_names "$@")
  for name in $names; do
    fetch_package "$name"
  done
}

cmd_publish() {
  local image_repository=localhost:5001
  local publish_flags=() names=()
  local selected name

  while [ $# -gt 0 ]; do
    case $1 in
      --dry-run)
        publish_flags+=("$1")
        ;;
      --image-repository)
        [ $# -ge 2 ] || usage_error "$1 needs a value"
        image_repository=$2
        shift
        ;;
      --image-repository=*)
        image_repository=${1#*=}
        ;;
      # The registry flags of educates package publish, passed through.
      --registry-*=* | --registry-anon | --registry-insecure | --registry-verify-certs)
        publish_flags+=("$1")
        ;;
      --registry-ca-cert-path | --registry-password | \
        --registry-response-header-timeout | --registry-retry-count | \
        --registry-token | --registry-username)
        [ $# -ge 2 ] || usage_error "$1 needs a value"
        publish_flags+=("$1" "$2")
        shift
        ;;
      -*)
        usage_error "unknown option $1"
        ;;
      *)
        names+=("$1")
        ;;
    esac
    shift
  done

  selected=$(selected_names ${names[@]+"${names[@]}"})
  for name in $selected; do
    fetch_package "$name"
    educates package publish "$PACKAGES_DIR/$name" \
      --image-repository "$image_repository" \
      ${publish_flags[@]+"${publish_flags[@]}"}
  done
}

main() {
  local command=${1:-}
  case $command in
    list)
      shift
      cmd_list "$@"
      ;;
    fetch)
      shift
      cmd_fetch "$@"
      ;;
    publish)
      shift
      cmd_publish "$@"
      ;;
    -h | --help | help)
      usage
      ;;
    "")
      usage >&2
      exit 1
      ;;
    *)
      usage_error "unknown command \"$command\""
      ;;
  esac
}

main "$@"
