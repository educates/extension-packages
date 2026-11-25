# Shared setup for the package script's tests.
#
# Each test works on a scratch repository: a copy of the package script
# with the fixture packages as its packages directory, so a test drives the
# script exactly as a maintainer does and never touches the real packages.

REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
FIXTURES=$BATS_TEST_DIRNAME/fixtures

# The registry the publish tests push to. It serves plain HTTP on a
# localhost address, as the registry `educates local registry deploy` runs
# and a `registry:2` service container in CI both do.
TEST_REGISTRY=${TEST_REGISTRY:-localhost:5001}

setup_scratch_repo() {
  # A fixed timestamp is part of every digest the tests compare.
  unset SOURCE_DATE_EPOCH

  REPO=$BATS_TEST_TMPDIR/repo
  SCRIPT=$REPO/package.sh

  mkdir -p "$REPO"
  cp "$REPO_ROOT/package.sh" "$SCRIPT"
  cp -R "$FIXTURES/packages" "$REPO/packages"

  UPSTREAM=$BATS_TEST_TMPDIR/upstream
  cp -R "$FIXTURES/upstream" "$UPSTREAM"
  export FIXTURE_UPSTREAM=file://$UPSTREAM
}

# Lists the files under a directory, one `<mode> <path>` line each, with
# paths relative to it, sorted.
list_files() {
  (cd "$1" && find . -type f | sed 's|^\./||' | LC_ALL=C sort | while read -r path; do
    printf '%s %s\n' "$(file_mode "$path")" "$path"
  done)
}

# Prints a file's permission bits as an octal number, such as 755.
file_mode() {
  local mode
  mode=$(ls -ld "$1" | cut -c2-10)
  local bits=0 i char
  for i in 0 1 2 3 4 5 6 7 8; do
    char=${mode:$i:1}
    bits=$((bits * 2))
    if [ "$char" != "-" ]; then
      bits=$((bits + 1))
    fi
  done
  printf '%o\n' "$bits"
}
