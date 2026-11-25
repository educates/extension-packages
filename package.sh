#!/usr/bin/env bash

# Fetches and publishes the extension packages under packages/, and tries
# them in a workshop generated for them.
#
# Runs with bash 3.2, as macOS ships it, and later, on macOS and Linux.
# Besides the standard Unix tools it needs only educates, curl and unzip.

set -euo pipefail

export LC_ALL=C

# Bash 5.2 and later replace & in the replacement of ${var//pattern/string}
# with the match, which render must not do.
shopt -u patsub_replacement 2>/dev/null || true

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PACKAGES_DIR=$ROOT/packages

# The template try generates its workshop from.
TRY_TEMPLATE_DIR=$ROOT/try-workshop

# The local registry, as educates local registry deploy runs it, which try
# publishes to and the workshops it deploys resolve as $(image_repository).
LOCAL_REGISTRY=localhost:5001

# The reserved directories of a package source, and the directories under
# them that a fetch script writes into. Nothing in a fetched directory is
# committed: the package script removes them before each fetch and after a
# failed one, and git ignores them.
RESERVED_DIRS="common linux-amd64 linux-arm64"
FETCHED_DIRS="bin extensions"

usage() {
  cat <<'EOF'
Usage: package.sh <command> [options] [<package>...]

Each command acts on the packages named, or on every package when none is,
except try, which needs at least one.

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

  try [--cluster] [--package-delivery image-mount|fetch]
      [--workshop-image IMAGE] [--output DIR] [--no-deploy] <package>...
      Publish the packages to the local registry at localhost:5001,
      generate a workshop for them in DIR, a new or empty directory, or in
      a new temporary directory, and publish its content there. Then
      deploy it with educates docker workshop deploy, passing it
      --package-delivery, or with --cluster to the current cluster with
      educates cluster workshop deploy. --workshop-image sets the
      workshop's image. --no-deploy stops before deploying.
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

# extract_tar ARCHIVE MEMBER TARGET MODE
#
# Extracts MEMBER, the path of a file inside the tar archive ARCHIVE, to
# TARGET, creating TARGET's directory, and gives it MODE. Nothing else in
# the archive is written anywhere. ARCHIVE may be compressed in any way tar
# recognizes when it reads, such as gzip.
extract_tar() {
  local archive=$1 member=$2 target=$3 mode=$4
  mkdir -p "$(dirname "$target")" || return 1
  rm -f "$target" || return 1
  if ! tar -xOf "$archive" "$member" > "$target"; then
    rm -f "$target"
    echo "Error: unable to extract $member from $archive" >&2
    return 1
  fi
  chmod "$mode" "$target"
}

# unpack_zip ARCHIVE DIR
#
# Unpacks the whole zip archive ARCHIVE into DIR, creating DIR, and gives
# each directory under DIR mode 0755 and each file 0755 when it has any
# execute bit and 0644 otherwise, whatever modes the archive recorded.
unpack_zip() {
  local archive=$1 dir=$2
  mkdir -p "$dir" || return 1
  if ! unzip -q -o "$archive" -d "$dir"; then
    echo "Error: unable to unpack $archive" >&2
    return 1
  fi
  chmod -R u=rwX,go=rX "$dir"
}

FETCH_HELPERS="manifest_version sha256_of download install_file extract_tar unpack_zip"

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

# Clears a package's fetched directories and runs its fetch script, and
# fails when the package has none. When the fetch script fails, removes the
# fetched directories again, so that nothing partial remains.
fetch_package() {
  local name=$1
  local source=$PACKAGES_DIR/$name
  local downloads status=0

  clear_fetched "$source"
  if [ ! -f "$source/fetch.sh" ]; then
    echo "Error: unable to fetch $name, $source/fetch.sh is missing" >&2
    return 1
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

# The longest workshop name try gives. A cluster deploy renames the
# workshop educates-cli--<name>-<7 hex digits>, and that name is a label
# value, which is at most 63 characters.
MAX_WORKSHOP_NAME=41

# Prints the name of the workshop for the packages: try- followed by the
# package names, joined by hyphens. A name too long is cut short and ends
# with a hash of the whole name, so that it stays distinct.
workshop_name() {
  local name=try package hash
  for package in "$@"; do
    name=$name-$package
  done
  if [ ${#name} -gt $MAX_WORKSHOP_NAME ]; then
    hash=$(printf '%s' "$name" | sha256_of -)
    name=${name:0:$((MAX_WORKSHOP_NAME - 9))}-${hash:0:8}
  fi
  printf '%s\n' "$name"
}

# render TEMPLATE NAME=VALUE...
#
# Prints a file of the try workshop template with each @NAME@ in it
# replaced by its VALUE, which may span lines. A line holding a token whose
# value is empty is left out.
render() {
  local template=$TRY_TEMPLATE_DIR/$1 line pair token value
  shift
  while IFS= read -r line || [ -n "$line" ]; do
    for pair in "$@"; do
      token=@${pair%%=*}@
      value=${pair#*=}
      case $line in
        *"$token"*)
          [ -n "$value" ] || continue 2
          line=${line//$token/$value}
          ;;
      esac
    done
    printf '%s\n' "$line"
  done < "$template"
}

# write_workshop DIR WORKSHOP WORKSHOP_IMAGE <package>...
#
# Writes the workshop named WORKSHOP for the packages, in the order given,
# into DIR. An empty WORKSHOP_IMAGE leaves the workshop image the
# platform's default.
write_workshop() {
  local dir=$1 workshop=$2 workshop_image=$3
  shift 3
  local nl=$'\n'
  local name version declarations="" sections=""

  for name in "$@"; do
    version=$(cd "$PACKAGES_DIR/$name" && manifest_version)
    declarations=${declarations:+$declarations$nl}$(render workshop-package.yaml \
      PACKAGE_NAME="$name" PACKAGE_VERSION="$version")
    sections=${sections:+$sections$nl$nl}$(render packages-page-section.md \
      PACKAGE_NAME="$name")
  done

  mkdir -p "$dir/resources" "$dir/workshop/content"
  render workshop.yaml WORKSHOP_NAME="$workshop" \
    WORKSHOP_IMAGE="$workshop_image" PACKAGE_NAMES="$(join_words "$@")" \
    PACKAGES="$declarations" > "$dir/resources/workshop.yaml"
  render packages-page.md PACKAGE_NAMES="$(join_words "$@")" \
    PACKAGE_SECTIONS="$sections" > "$dir/workshop/content/00-packages.md"

  # The workshop orders its pages by file name, so each validation page is
  # numbered after the packages page.
  local page=0
  for name in "$@"; do
    if [ -f "$PACKAGES_DIR/$name/workshop.md" ]; then
      page=$((page + 1))
      cp "$PACKAGES_DIR/$name/workshop.md" \
        "$dir/workshop/content/$(printf '%02d' "$page")-$name.md"
    fi
  done
}

cmd_try() {
  local deploy=true cluster=false delivery="" output="" workshop_image=""
  local names=() deploy_flags=()
  local selected workshop dir

  while [ $# -gt 0 ]; do
    case $1 in
      --no-deploy)
        deploy=false
        ;;
      --cluster)
        cluster=true
        ;;
      --package-delivery)
        [ $# -ge 2 ] || usage_error "$1 needs a value"
        delivery=$2
        shift
        ;;
      --package-delivery=*)
        delivery=${1#*=}
        ;;
      --workshop-image)
        [ $# -ge 2 ] || usage_error "$1 needs a value"
        workshop_image=$2
        shift
        ;;
      --workshop-image=*)
        workshop_image=${1#*=}
        ;;
      --output)
        [ $# -ge 2 ] || usage_error "$1 needs a value"
        output=$2
        shift
        ;;
      --output=*)
        output=${1#*=}
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

  case $delivery in
    "" | image-mount | fetch) ;;
    *) usage_error "--package-delivery takes image-mount or fetch, not $delivery" ;;
  esac
  if [ "$cluster" = true ] && [ -n "$delivery" ]; then
    usage_error "--package-delivery applies to a Docker deploy only, a cluster delivers packages as its EducatesClusterConfig sets"
  fi
  [ ${#names[@]} -gt 0 ] || usage_error "try needs at least one package"
  selected=$(selected_names "${names[@]}" | sort -u)
  if [ -n "$output" ] && [ -e "$output" ]; then
    if [ ! -d "$output" ] || [ -n "$(ls -A "$output")" ]; then
      echo "Error: $output is not an empty directory" >&2
      return 1
    fi
  fi

  cmd_publish --image-repository "$LOCAL_REGISTRY" $selected

  # The workshop directory is kept, so that the workshop can be deleted
  # with it after the run. A deploy names the workshop from the absolute
  # path of its definition, so that is the path it is given.
  workshop=$(workshop_name $selected)
  dir=${output:-$(mktemp -d "${TMPDIR:-/tmp}/extension-packages-try.XXXXXX")}
  write_workshop "$dir" "$workshop" "$workshop_image" $selected
  dir=$(cd "$dir" && pwd)
  educates workshop publish "$dir" --image-repository "$LOCAL_REGISTRY"
  echo "Workshop $workshop written to $dir."

  if [ "$deploy" = false ]; then
    return 0
  fi
  if [ "$cluster" = true ]; then
    educates cluster workshop deploy --file "$dir" --open-browser
    printf 'To delete the workshop: educates cluster workshop delete --file %q\n' "$dir"
  else
    if [ -n "$delivery" ]; then
      deploy_flags+=(--package-delivery "$delivery")
    fi
    educates docker workshop deploy --file "$dir" \
      ${deploy_flags[@]+"${deploy_flags[@]}"}
    printf 'To delete the workshop: educates docker workshop delete --file %q\n' "$dir"
  fi
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
    try)
      shift
      cmd_try "$@"
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
