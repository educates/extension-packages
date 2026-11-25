#!/usr/bin/env bats

# The unpack_zip fetch helper, through a fixture package whose fetch script
# unpacks a zip archive into common/extensions/zipped.

load helpers

setup() {
  setup_scratch_repo
  add_fixture_package zipped
  UNPACKED=$REPO/packages/zipped/common/extensions/zipped
}

@test "unpack_zip unpacks the whole archive into the directory, with normalised modes" {
  # The archive holds a read-only, a group-writable and an executable file,
  # whose modes unzip restores as they are. A restrictive umask shows that
  # the directories' modes come from the helper too.
  umask 077

  run "$SCRIPT" fetch zipped

  [ "$status" -eq 0 ]
  [ "$(list_files "$REPO/packages/zipped")" = "$(cat <<'EOF'
755 common/extensions/zipped/extension/bin/tool
644 common/extensions/zipped/extension/legal/LICENSE
644 common/extensions/zipped/extension/package.json
644 common/extensions/zipped/manifest.xml
755 fetch.sh
644 package.yaml
EOF
)" ]
  [ "$(cat "$UNPACKED/extension/bin/tool")" = "$(printf '#!/bin/sh\necho tool')" ]
  [ "$(cat "$UNPACKED/extension/legal/LICENSE")" = "A licence that unzip restores read only." ]
  [ "$(file_mode "$UNPACKED") $(file_mode "$UNPACKED/extension") $(file_mode "$UNPACKED/extension/bin") $(file_mode "$UNPACKED/extension/legal")" = "755 755 755 755" ]
}

@test "unpack_zip leaves nothing outside the directory" {
  export TMPDIR=$BATS_TEST_TMPDIR/tmp
  mkdir -p "$TMPDIR"

  run "$SCRIPT" fetch zipped

  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMPDIR")" ]
  [ "$(cd "$REPO/packages/zipped" && find . -type d | LC_ALL=C sort)" = "$(cat <<'EOF'
.
./common
./common/extensions
./common/extensions/zipped
./common/extensions/zipped/extension
./common/extensions/zipped/extension/bin
./common/extensions/zipped/extension/legal
EOF
)" ]
}
