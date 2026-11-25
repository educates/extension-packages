#!/bin/sh

# Writes thv's bash completion under $HOME and sources it from ~/.bashrc in
# every new terminal. Running it again rewrites the completion and adds no
# second line to ~/.bashrc.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

COMPLETION=$HOME/.local/share/thv/completion.bash

mkdir -p "$(dirname "$COMPLETION")"

"$PACKAGE_DIR/bin/thv" completion bash > "$COMPLETION"

if ! grep -qxF ". $COMPLETION" "$HOME/.bashrc" 2>/dev/null; then
  echo ". $COMPLETION" >> "$HOME/.bashrc"
fi
