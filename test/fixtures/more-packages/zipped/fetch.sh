#!/usr/bin/env bash

# Downloads the fixture's zip archive from $FIXTURE_UPSTREAM, a file:// URL
# the tests set, and unpacks it, the way a package unpacks a .vsix.

version=$(manifest_version)

download "$FIXTURE_UPSTREAM/zipped-$version.zip" \
  2dce96362e203e6f153ac8628d8d738b4b36bc019dbc75a05dec6f61c4ecb498 \
  "$DOWNLOADS/zipped.zip"
unpack_zip "$DOWNLOADS/zipped.zip" common/extensions/zipped
