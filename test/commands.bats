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

@test "fetch fails on an unknown package, listing the packages, and fetches nothing" {
  cp -R "$REPO/packages/hello" "$REPO/packages/another"

  run "$SCRIPT" fetch hello nope

  [ "$status" -ne 0 ]
  [ "$output" = 'Error: unknown package "nope", expected one of: another, hello' ]
  [ ! -e "$REPO/packages/hello/linux-amd64" ]
}
