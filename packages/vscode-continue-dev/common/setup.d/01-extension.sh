#!/bin/sh

# Installs the Continue extension into the session's editor, under $HOME.
# The package holds the build for the session's platform under one name.
# Running it again installs the same extension over itself, leaving one
# copy.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

code-server --install-extension "$PACKAGE_DIR/extensions/continue.vsix"
