#!/bin/sh

# Installs the Roo Code extension into the session's editor, under $HOME.
# Running it again installs the same extension over itself, leaving one
# copy.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

code-server --install-extension "$PACKAGE_DIR/extensions/roo-cline.vsix"
