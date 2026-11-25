#!/usr/bin/env bats

load helpers

setup() {
  setup_scratch_repo
}

@test "fetch installs each file under its final name and mode" {
  # A restrictive umask shows the modes come from the fetch script, not
  # from how the files happened to be written.
  umask 077

  run "$SCRIPT" fetch hello

  [ "$status" -eq 0 ]
  [ "$(list_files "$REPO/packages/hello")" = "$(cat <<'EOF'
644 README.md
644 common/extensions/greeting.txt
755 common/setup.d/01-hello.sh
755 fetch.sh
755 linux-amd64/bin/hello
755 linux-arm64/bin/hello
644 package.yaml
EOF
)" ]
  [ "$(cat "$REPO/packages/hello/linux-amd64/bin/hello")" = "$(cat "$UPSTREAM/hello-1.0.0-linux-amd64")" ]
  [ "$(cat "$REPO/packages/hello/linux-arm64/bin/hello")" = "$(cat "$UPSTREAM/hello-1.0.0-linux-arm64")" ]
}

@test "fetch empties the fetched directories before fetching again" {
  run "$SCRIPT" fetch hello
  [ "$status" -eq 0 ]
  touch "$REPO/packages/hello/linux-amd64/bin/stale"
  touch "$REPO/packages/hello/common/extensions/stale"

  run "$SCRIPT" fetch hello

  [ "$status" -eq 0 ]
  [ ! -e "$REPO/packages/hello/linux-amd64/bin/stale" ]
  [ ! -e "$REPO/packages/hello/common/extensions/stale" ]
  [ -x "$REPO/packages/hello/linux-amd64/bin/hello" ]
  [ -f "$REPO/packages/hello/common/setup.d/01-hello.sh" ]
}

@test "a checksum mismatch fails the fetch and leaves no fetched files" {
  # The amd64 download succeeds and is installed before the arm64 one fails.
  echo "changed upstream" >> "$UPSTREAM/hello-1.0.0-linux-arm64"

  run "$SCRIPT" fetch hello

  [ "$status" -ne 0 ]
  [[ "$output" == *"hello-1.0.0-linux-arm64 has sha256 "* ]]
  [ "$(list_files "$REPO/packages/hello")" = "$(list_files "$FIXTURES/packages/hello")" ]
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
  [ ! -e "$REPO/packages/hello/linux-arm64" ]
  [ ! -e "$REPO/packages/hello/common/extensions" ]
}

@test "a failed download fails the fetch and leaves no fetched files" {
  rm "$UPSTREAM/greeting-1.0.0.txt"

  run "$SCRIPT" fetch hello

  [ "$status" -ne 0 ]
  [[ "$output" == *"unable to download "*"greeting-1.0.0.txt"* ]]
  [ "$(list_files "$REPO/packages/hello")" = "$(list_files "$FIXTURES/packages/hello")" ]
}

@test "a package without a fetch script fails the fetch, naming the package and the file" {
  rm "$REPO/packages/hello/fetch.sh"

  run "$SCRIPT" fetch hello

  [ "$status" -ne 0 ]
  [ "$output" = "Error: unable to fetch hello, $REPO/packages/hello/fetch.sh is missing" ]
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
}

@test "fetch leaves no temporary files behind" {
  export TMPDIR=$BATS_TEST_TMPDIR/tmp
  mkdir -p "$TMPDIR"

  run "$SCRIPT" fetch hello

  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMPDIR")" ]
}
