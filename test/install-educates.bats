#!/usr/bin/env bats

# The script CI installs the educates CLI with, run against a fixture
# release served through file:// URLs.

load helpers

setup() {
  INSTALL=$REPO_ROOT/.github/actions/install-educates/install.sh

  RELEASES=$BATS_TEST_TMPDIR/releases
  cp -R "$FIXTURES/releases" "$RELEASES"
  export EDUCATES_RELEASES_URL=file://$RELEASES

  BIN=$BATS_TEST_TMPDIR/bin
}

@test "installs the release's linux-amd64 asset as an executable educates" {
  run "$INSTALL" 1.2.3 "$BIN"

  [ "$status" -eq 0 ]
  [ "$(ls "$BIN")" = "educates" ]
  [ -x "$BIN/educates" ]
  [ "$("$BIN/educates")" = "educates 1.2.3 (test fixture)" ]
}

@test "an asset whose sha256 differs from checksums.txt fails and installs nothing" {
  echo "tampered" >> "$RELEASES/1.2.3/educates-linux-amd64"

  run "$INSTALL" 1.2.3 "$BIN"

  [ "$status" -ne 0 ]
  [[ "$output" == "Error: educates-linux-amd64 of release 1.2.3 has sha256 "*", expected aedfaae054b5167a299fca18d3e89caea80cf95a0fb5eaba53074609e89ed26b" ]]
  [ ! -e "$BIN/educates" ]
}

@test "a checksums.txt that lists no linux-amd64 asset fails and installs nothing" {
  grep -v ' educates-linux-amd64$' "$RELEASES/1.2.3/checksums.txt" > "$BATS_TEST_TMPDIR/checksums.txt"
  cp "$BATS_TEST_TMPDIR/checksums.txt" "$RELEASES/1.2.3/checksums.txt"

  run "$INSTALL" 1.2.3 "$BIN"

  [ "$status" -ne 0 ]
  [ "$output" = "Error: the checksums.txt of release 1.2.3 has no line for educates-linux-amd64" ]
  [ ! -e "$BIN/educates" ]
}

@test "a release that does not exist fails and installs nothing" {
  run "$INSTALL" 9.9.9 "$BIN"

  [ "$status" -ne 0 ]
  # curl's own message comes first.
  [[ "$output" == *"Error: unable to download file://$RELEASES/9.9.9/checksums.txt" ]]
  [ ! -e "$BIN/educates" ]
}
