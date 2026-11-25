#!/usr/bin/env bats

# The extract_tar fetch helper, driven through a fetch of the tarball
# fixture package. Its archive holds a license, two programs and a manual
# page, and the package keeps only the program bin/tool.

load helpers

setup() {
  setup_scratch_repo
  add_fixture_package tarball
}

# Lists every file and directory under a directory, relative to it, sorted.
list_entries() {
  (cd "$1" && find . -mindepth 1 | sed 's|^\./||' | LC_ALL=C sort)
}

@test "extract_tar installs the named member under its final name and mode, and nothing else from the archive" {
  # The archive stores the program with mode 0600, and a restrictive umask
  # shows the mode comes from the fetch script, not from the archive or how
  # the file happened to be written.
  umask 077
  export TMPDIR=$BATS_TEST_TMPDIR/tmp
  mkdir -p "$TMPDIR"

  run "$SCRIPT" fetch tarball

  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMPDIR")" ]
  [ "$(list_entries "$REPO/packages/tarball")" = "$(cat <<'EOF'
README.md
fetch.sh
linux-amd64
linux-amd64/bin
linux-amd64/bin/tool
package.yaml
EOF
)" ]
  [ "$(file_mode "$REPO/packages/tarball/linux-amd64/bin/tool")" = 755 ]
  [ "$(cat "$REPO/packages/tarball/linux-amd64/bin/tool")" = "$(printf '#!/bin/sh\necho "tool 1.0.0"')" ]
}

@test "a member missing from the archive fails the fetch, naming it, and leaves no fetched files" {
  # The program is extracted before the missing member is asked for.
  echo 'extract_tar "$DOWNLOADS/tool.tar.gz" tool_1.0.0_linux/bin/missing linux-arm64/bin/tool 0755' \
    >> "$REPO/packages/tarball/fetch.sh"

  run "$SCRIPT" fetch tarball

  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: unable to extract tool_1.0.0_linux/bin/missing from "*"tool.tar.gz"* ]]
  [ "$(list_entries "$REPO/packages/tarball")" = "$(cat <<'EOF'
README.md
fetch.sh
package.yaml
EOF
)" ]
}
