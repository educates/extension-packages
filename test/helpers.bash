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

  # A repository of its own in the test registry for each test, since the
  # registry may not allow deleting what a test pushed.
  TEST_NAMESPACE=extension-packages-test/$(date +%Y%m%d%H%M%S)-$$-$RANDOM
  TEST_REPOSITORY=$TEST_REGISTRY/$TEST_NAMESPACE
}

# Fails the test unless the test registry answers.
require_registry() {
  if ! curl -fsS -o /dev/null "http://$TEST_REGISTRY/v2/"; then
    echo "No registry answers at $TEST_REGISTRY: start one, or set TEST_REGISTRY." >&2
    return 1
  fi
}

# Prints the value of the `Digest:` line in the output of a publish.
published_digest() {
  printf '%s\n' "$1" | sed -n 's/^Digest: //p'
}

# registry_get PATH ACCEPT
#
# Prints what the test registry serves at /v2/<PATH>.
registry_get() {
  curl -fsSL -H "Accept: $2" "http://$TEST_REGISTRY/v2/$1"
}

# registry_digest NAME TAG
#
# Prints the digest the test registry holds for <namespace>/NAME:TAG.
registry_digest() {
  curl -fsSI -H 'Accept: application/vnd.oci.image.index.v1+json' \
    "http://$TEST_REGISTRY/v2/$TEST_NAMESPACE/$1/manifests/$2" |
    tr -d '\r' | sed -n 's/^[Dd]ocker-[Cc]ontent-[Dd]igest: //p'
}

# Prints the image index for <namespace>/NAME:TAG.
registry_index() {
  registry_get "$TEST_NAMESPACE/$1/manifests/$2" application/vnd.oci.image.index.v1+json
}

# platform_digest INDEX ARCH
#
# Prints the digest of the linux/ARCH child in an image index.
platform_digest() {
  printf '%s' "$1" |
    grep -o '"digest":"sha256:[0-9a-f]*","platform":{"architecture":"'"$2"'","os":"linux"' |
    grep -o 'sha256:[0-9a-f]*'
}

# layer_blob NAME CHILD_DIGEST
#
# Writes the single layer of a child image of <namespace>/NAME to stdout.
layer_blob() {
  local manifest layer
  manifest=$(registry_get "$TEST_NAMESPACE/$1/manifests/$2" application/vnd.oci.image.manifest.v1+json)
  layer=$(printf '%s' "$manifest" | grep -o '"layers":\[{[^}]*}' | grep -o 'sha256:[0-9a-f]*')
  registry_get "$TEST_NAMESPACE/$1/blobs/$layer" application/octet-stream
}

# layer_listing NAME CHILD_DIGEST
#
# Lists a child image's files as `<mode string> <path>` lines, in layer
# order.
layer_listing() {
  layer_blob "$1" "$2" | tar -tvzf - | awk '{print $1, $NF}'
}

# layer_file NAME CHILD_DIGEST PATH
#
# Prints one file from a child image.
layer_file() {
  layer_blob "$1" "$2" | tar -xzOf - "$3"
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
