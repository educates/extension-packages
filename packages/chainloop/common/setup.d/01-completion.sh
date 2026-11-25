#!/bin/sh

# Writes chainloop's bash completion under $HOME and sources it from
# ~/.bashrc in every new terminal. Running it again rewrites the completion
# and adds no second line to ~/.bashrc.
#
# Before running any command, completion included, chainloop asks its
# control plane for the current organization, waiting up to 20 seconds when
# the control plane doesn't answer, and sends telemetry. So the completion
# is generated with telemetry off, a closed local port as the control plane
# and an empty configuration file of its own, which keeps it offline and
# leaves the user's ~/.config/chainloop untouched.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

COMPLETION=$HOME/.local/share/chainloop/completion.bash
CONFIG=$HOME/.local/share/chainloop/completion-config.toml

mkdir -p "$(dirname "$COMPLETION")"

: > "$CONFIG"
DO_NOT_TRACK=1 CHAINLOOP_CONTROL_PLANE_API=127.0.0.1:1 \
  "$PACKAGE_DIR/bin/chainloop" --config "$CONFIG" completion bash > "$COMPLETION"
rm -f "$CONFIG"

if ! grep -qxF ". $COMPLETION" "$HOME/.bashrc" 2>/dev/null; then
  echo ". $COMPLETION" >> "$HOME/.bashrc"
fi
