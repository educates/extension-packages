#!/bin/sh

# Writes argocd's bash completion under $HOME and sources it from
# ~/.bashrc in every new terminal. Running it again rewrites the completion
# and adds no second line to ~/.bashrc.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

COMPLETION=$HOME/.local/share/argocd/completion.bash

mkdir -p "$(dirname "$COMPLETION")"

"$PACKAGE_DIR/bin/argocd" completion bash > "$COMPLETION"

if ! grep -qxF ". $COMPLETION" "$HOME/.bashrc" 2>/dev/null; then
  echo ". $COMPLETION" >> "$HOME/.bashrc"
fi
