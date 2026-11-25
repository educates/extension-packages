#!/usr/bin/env bash

# Extracts the fixture's program from a tar archive downloaded from
# $FIXTURE_UPSTREAM, a file:// URL the tests set, the way a real package
# extracts a release binary. The archive also holds a license, a second
# program and a manual page, none of which the package keeps.

version=$(manifest_version)

download "$FIXTURE_UPSTREAM/tool_${version}_linux.tar.gz" \
  fd518ab85df7ae4ee86be12b95a810a43c72571e568daf111c0661caca3517da \
  "$DOWNLOADS/tool.tar.gz"
extract_tar "$DOWNLOADS/tool.tar.gz" "tool_${version}_linux/bin/tool" \
  linux-amd64/bin/tool 0755
