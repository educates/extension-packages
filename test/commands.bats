#!/usr/bin/env bats

load helpers

setup() {
  setup_scratch_repo
}

@test "list prints each package name, one per line, in name order" {
  cp -R "$REPO/packages/hello" "$REPO/packages/another"
  mkdir -p "$REPO/packages/not-a-package"

  run "$SCRIPT" list

  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'another\nhello')" ]
}

@test "list prints nothing when there are no packages" {
  rm -rf "$REPO/packages/hello"

  # Not through run, whose output drops a blank line.
  "$SCRIPT" list > "$BATS_TEST_TMPDIR/list"

  [ ! -s "$BATS_TEST_TMPDIR/list" ]
}

@test "list prints only the packages named, and fails on an unknown one" {
  cp -R "$REPO/packages/hello" "$REPO/packages/another"

  run "$SCRIPT" list hello
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]

  run "$SCRIPT" list nope
  [ "$status" -ne 0 ]
  [ "$output" = 'Error: unknown package "nope", expected one of: another, hello' ]
}

@test "fetch fails on an unknown package, listing the packages, and fetches nothing" {
  cp -R "$REPO/packages/hello" "$REPO/packages/another"

  run "$SCRIPT" fetch hello nope

  [ "$status" -ne 0 ]
  [ "$output" = 'Error: unknown package "nope", expected one of: another, hello' ]
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
}

@test "publish fails on an unknown package, listing the packages, and fetches nothing" {
  run "$SCRIPT" publish --dry-run nope hello

  [ "$status" -ne 0 ]
  [ "$output" = 'Error: unknown package "nope", expected one of: hello' ]
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
}

@test "an unknown option fails with the usage" {
  local command
  for command in list fetch publish; do
    run "$SCRIPT" "$command" --bogus hello

    [ "$status" -ne 0 ]
    [ "${lines[0]}" = "Error: unknown option --bogus" ]
    [[ "$output" == *"Usage: package.sh"* ]]
  done
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
}

@test "an unknown command fails with the usage" {
  run "$SCRIPT" bogus

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = 'Error: unknown command "bogus"' ]
  [[ "$output" == *"Usage: package.sh"* ]]
}
