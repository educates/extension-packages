#!/usr/bin/env bash

# Downloads the fixture's files from $FIXTURE_UPSTREAM, a file:// URL the
# tests set, the way a real package downloads its release assets.

version=$(manifest_version)

download "$FIXTURE_UPSTREAM/hello-$version-linux-amd64" \
  13278a0ef8b337fd58135fc655d73d5cee911ed8b88c8ae4f4600c29d849bda7 \
  "$DOWNLOADS/hello-linux-amd64"
install_file "$DOWNLOADS/hello-linux-amd64" linux-amd64/bin/hello 0755

download "$FIXTURE_UPSTREAM/hello-$version-linux-arm64" \
  8362b18f8297f4da60744d398105b53a192d0d337f4edb8f583e8a140cb8bb7d \
  "$DOWNLOADS/hello-linux-arm64"
install_file "$DOWNLOADS/hello-linux-arm64" linux-arm64/bin/hello 0755

download "$FIXTURE_UPSTREAM/greeting-$version.txt" \
  a8fdade2df75efa9e17c736bed5e0766cbc264ebf9365ad7a738909bf9988ad8 \
  "$DOWNLOADS/greeting.txt"
install_file "$DOWNLOADS/greeting.txt" common/extensions/greeting.txt 0644
