#!/bin/sh

# Writes gh's bash completion under $HOME and sources it from ~/.bashrc in
# every new terminal. Running it again rewrites the completion and adds no
# second line to ~/.bashrc.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

COMPLETION=$HOME/.local/share/gh/completion.bash

mkdir -p "$(dirname "$COMPLETION")"

"$PACKAGE_DIR/bin/gh" completion -s bash > "$COMPLETION"

if ! grep -qxF ". $COMPLETION" "$HOME/.bashrc" 2>/dev/null; then
  echo ". $COMPLETION" >> "$HOME/.bashrc"
fi
