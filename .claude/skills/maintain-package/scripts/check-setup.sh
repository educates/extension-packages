#!/usr/bin/env bash

# Runs a package's setup scripts the way a workshop session runs them: in an
# Educates workshop image, with the package mounted read only at
# /opt/packages/<name>, through the platform's own rebuild-workshop, twice,
# as a session start and a later rebuild-workshop would. It fails when a
# setup script fails on either run, or when the second run leaves a line
# repeated in ~/.bashrc. It then shows each run's time, the package's setup
# log, its programs, their completion in a new terminal, and the editor's
# extensions.
#
# Usage, from the repository root, after ./package.sh fetch PACKAGE:
#
#   check-setup.sh PACKAGE [linux-amd64|linux-arm64]
#
# The platform defaults to this machine's. The image defaults to the base
# environment image of the educates release that CI pins; set BASE_IMAGE to
# use another, such as a JDK workshop image.

set -euo pipefail

usage() {
  echo "Usage: $0 PACKAGE [linux-amd64|linux-arm64]" >&2
  exit 2
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage

name=$1
source=packages/$name

if [ ! -f "$source/package.yaml" ]; then
  echo "Error: no package $name in packages/, run this from the repository root" >&2
  exit 1
fi

case ${2:-} in
  "")
    case $(uname -m) in
      arm64|aarch64) platform=linux-arm64 ;;
      *) platform=linux-amd64 ;;
    esac
    ;;
  linux-amd64|linux-arm64) platform=$2 ;;
  *) usage ;;
esac

fetched=no
for dir in common "$platform"; do
  for kind in bin extensions; do
    [ ! -d "$source/$dir/$kind" ] || fetched=yes
  done
done
if [ $fetched = no ]; then
  echo "Error: $name has no fetched files, run ./package.sh fetch $name first" >&2
  exit 1
fi

version=$(sed -n 's/^ *EDUCATES_VERSION: *//p' .github/actions/install-educates/action.yml)
image=${BASE_IMAGE:-ghcr.io/educates/educates-base-environment:$version}

# The platform overlays the platform directory onto common, so the session
# sees one directory holding both.
overlay=$(mktemp -d)
trap 'rm -rf "$overlay"' EXIT
cp -p "$source/package.yaml" "$overlay/"
for dir in common "$platform"; do
  [ ! -d "$source/$dir" ] || cp -Rp "$source/$dir/." "$overlay/"
done

echo "Checking $name for $platform in $image"

docker run --rm -i \
  --platform "linux/${platform#linux-}" \
  --env ENABLE_EDITOR=true \
  --volume "$overlay:/opt/packages/$name:ro" \
  --entrypoint bash \
  "$image" -s -- "$name" <<'INSIDE'
name=$1
package_dir=/opt/packages/$name
log=$HOME/.local/share/workshop/setup-scripts.log
failed=$HOME/.local/share/workshop/setup-scripts.failed
status=0

cd "$HOME"
mkdir -p "$(dirname "$log")"

for run in 1 2; do
  : > "$log"
  start=$(date +%s.%N)
  rebuild-workshop > /dev/null 2>&1 || true
  end=$(date +%s.%N)
  seconds=$(awk "BEGIN { printf \"%.1f\", $end - $start }")

  # Each of the package's scripts is logged from its "Executing:" line to
  # the WORKSHOP_ENV lines printed after it, up to rebuild-workshop's next
  # trace line.
  package_log=$(awk -v prefix="Executing: $package_dir/" '
    /^Executing: / { inside = index($0, prefix) == 1; env = 0 }
    inside && env && /^\+/ { inside = 0 }
    inside { print }
    inside && /^\+ cat \/tmp\/workshop-env-/ { env = 1 }' "$log")

  if [ -e "$failed" ]; then
    echo "FAIL: run $run of rebuild-workshop: a setup script failed, after ${seconds}s"
    echo "$package_log"
    status=1
    break
  fi
  echo "ok: run $run of rebuild-workshop, ${seconds}s"
done

if [ $status = 0 ]; then
  echo
  echo "== The package's setup log, run 2"
  echo "$package_log"

  repeated=$(sort "$HOME/.bashrc" 2>/dev/null | uniq -d)
  if [ -n "$repeated" ]; then
    echo
    echo "FAIL: ~/.bashrc repeats lines after two runs:"
    echo "$repeated"
    status=1
  fi
fi

if [ -d "$package_dir/bin" ]; then
  echo
  echo "== Programs in bin, and their completion in a new terminal"
  for program in "$package_dir"/bin/*; do
    program=$(basename "$program")
    completion=$(bash -il -c "complete -p $program" 2> /dev/null) \
      || completion="(no completion)"
    echo "$program: $completion"
  done
fi

if [ -d "$package_dir/extensions" ]; then
  echo
  echo "== Editor extensions"
  code-server --list-extensions --show-versions 2> /dev/null
fi

echo
if [ $status = 0 ]; then
  echo "PASS: $name set up twice with no failure and no repeated ~/.bashrc line"
fi
exit $status
INSIDE
