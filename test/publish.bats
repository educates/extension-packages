#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

load helpers

setup() {
  setup_scratch_repo
}

@test "publish --dry-run prints the reference and digests under the default repository" {
  run --separate-stderr "$SCRIPT" publish --dry-run hello

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Dry run, nothing was published." ]
  [ "${lines[1]}" = "Package image: localhost:5001/hello:1.0.0" ]
  [[ "${lines[2]}" =~ ^Digest:\ sha256:[0-9a-f]{64}$ ]]
  [[ "${lines[3]}" =~ ^\ \ linux/amd64\ sha256:[0-9a-f]{64}$ ]]
  [[ "${lines[4]}" =~ ^\ \ linux/arm64\ sha256:[0-9a-f]{64}$ ]]
}

@test "publish --dry-run contacts no registry" {
  # A name in the .invalid domain never resolves, so any attempt to reach
  # the registry would fail the publish.
  run --separate-stderr "$SCRIPT" publish --dry-run --image-repository registry.invalid/nowhere hello

  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Package image: registry.invalid/nowhere/hello:1.0.0" ]
  [[ "${lines[2]}" =~ ^Digest:\ sha256:[0-9a-f]{64}$ ]]
}

@test "publish passes registry flags through to educates unchanged" {
  run --separate-stderr "$SCRIPT" publish --dry-run --registry-insecure \
    --registry-retry-count 2 --registry-username=someone \
    --image-repository=registry.invalid/flags hello

  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Package image: registry.invalid/flags/hello:1.0.0" ]

  # Only educates checks a flag's value, so its error shows the flag
  # reached it.
  run --separate-stderr "$SCRIPT" publish --dry-run --registry-retry-count not-a-number hello

  [ "$status" -ne 0 ]
  [[ "$stderr" == *'"not-a-number" for "--registry-retry-count"'* ]]
}

@test "publish pushes an index with both platforms, each holding the manifest and its files" {
  require_registry

  run --separate-stderr "$SCRIPT" publish --image-repository "$TEST_REPOSITORY" hello

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Package image: $TEST_REPOSITORY/hello:1.0.0" ]
  [ "$(registry_digest hello 1.0.0)" = "$(published_digest "$output")" ]

  local index arch child
  index=$(registry_index hello 1.0.0)
  for arch in amd64 arm64; do
    child=$(platform_digest "$index" "$arch")
    [ -n "$child" ]
    [ "$(layer_listing hello "$child")" = "$(cat <<'EOF'
drwxr-xr-x bin/
-rwxr-xr-x bin/hello
drwxr-xr-x extensions/
-rw-r--r-- extensions/greeting.txt
drwxr-xr-x setup.d/
-rwxr-xr-x setup.d/01-hello.sh
-rw-r--r-- package.yaml
EOF
)" ]
    [ "$(layer_file hello "$child" bin/hello)" = "$(cat "$UPSTREAM/hello-1.0.0-linux-$arch")" ]
    [ "$(layer_file hello "$child" package.yaml)" = "$(cat "$REPO/packages/hello/package.yaml")" ]
  done
}

@test "publishing an unchanged package again leaves its digest, and a change gives a new one" {
  require_registry
  local dry_run first second changed

  run --separate-stderr "$SCRIPT" publish --dry-run --image-repository "$TEST_REPOSITORY" hello
  [ "$status" -eq 0 ]
  dry_run=$(published_digest "$output")

  run --separate-stderr "$SCRIPT" publish --image-repository "$TEST_REPOSITORY" hello
  [ "$status" -eq 0 ]
  first=$(published_digest "$output")
  [ "$first" = "$dry_run" ]
  [ "$(registry_digest hello 1.0.0)" = "$first" ]

  run --separate-stderr "$SCRIPT" publish --image-repository "$TEST_REPOSITORY" hello
  [ "$status" -eq 0 ]
  second=$(published_digest "$output")
  [ "$second" = "$first" ]
  [ "$(registry_digest hello 1.0.0)" = "$first" ]

  echo 'echo "and changed"' >> "$REPO/packages/hello/common/setup.d/01-hello.sh"
  run --separate-stderr "$SCRIPT" publish --image-repository "$TEST_REPOSITORY" hello
  [ "$status" -eq 0 ]
  changed=$(published_digest "$output")
  [ -n "$changed" ]
  [ "$changed" != "$first" ]
  [ "$(registry_digest hello 1.0.0)" = "$changed" ]
}
