#!/bin/sh

# Writes the Continue configuration under ~/.continue from the configuration
# the workshop mounts:
#
# - The ytt overlays mounted at /opt/continue/config/models are applied to
#   the package's default configuration, and the result is written to
#   ~/.continue/config.yaml.
# - The ytt templates mounted at /opt/continue/config/mcpservers are
#   rendered to ~/.continue/mcpServers/educates-mcp-servers.yaml.
#
# A Kubernetes secret or config map volume links its files to the ones
# under its ..data directory, so the files are read from there when it
# exists. Where nothing is mounted, the script says so and writes nothing.
# A configuration that ytt fails on fails the script. Running it again
# writes the same files.

set -e

PACKAGE_DIR=$(cd "$(dirname "$0")/.." && pwd)

MODELS_DIR=/opt/continue/config/models
MCP_SERVERS_DIR=/opt/continue/config/mcpservers

# Prints the directory holding a mounted configuration's files.
mounted_files() {
  if [ -d "$1/..data" ]; then
    echo "$1/..data/"
  else
    echo "$1/"
  fi
}

# write_config FILE YTT_ARGUMENTS...
#
# Writes what ytt renders to FILE, replacing FILE only when ytt succeeds,
# and removes FILE when ytt renders nothing.
write_config() {
  file=$1
  shift
  mkdir -p "$(dirname "$file")"
  if ! ytt "$@" > "$file.new"; then
    rm -f "$file.new"
    echo "Continue: ytt failed to render $file from the mounted configuration" >&2
    return 1
  fi
  if [ -s "$file.new" ]; then
    mv "$file.new" "$file"
    echo "Continue: wrote $file"
  else
    rm -f "$file.new" "$file"
    echo "Continue: the mounted configuration renders nothing for $file"
  fi
}

if [ -d "$MODELS_DIR" ]; then
  write_config "$HOME/.continue/config.yaml" \
    -f "$PACKAGE_DIR/default-config.yaml" -f "$(mounted_files "$MODELS_DIR")"
else
  echo "Continue: no model configuration found at $MODELS_DIR"
fi

if [ -d "$MCP_SERVERS_DIR" ]; then
  write_config "$HOME/.continue/mcpServers/educates-mcp-servers.yaml" \
    -f "$(mounted_files "$MCP_SERVERS_DIR")"
else
  echo "Continue: no MCP server configuration found at $MCP_SERVERS_DIR"
fi
