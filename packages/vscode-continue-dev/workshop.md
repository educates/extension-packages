---
title: vscode-continue-dev
---

The vscode-continue-dev package installs the Continue extension into the
workshop editor when the session starts, and writes Continue's
configuration from the model and MCP server configuration the workshop
mounts.

## The extension is installed

When the session started, the package's first setup script installed the
extension with `code-server`. List the editor's extensions:

```terminal:execute
command: |-
  code-server --list-extensions --show-versions
```

The list should include `continue.continue@1.1.63`.

The package holds a build of the extension for each platform, and the
session holds only the one for its own. Compare the platform the build
targets with the session's architecture:

```terminal:execute
command: |-
  unzip -p /opt/packages/vscode-continue-dev/extensions/continue.vsix extension.vsixmanifest | grep -o 'TargetPlatform="[^"]*"'; uname -m
```

A session on `x86_64` should have `linux-x64`, and one on `aarch64`
should have `linux-arm64`.

## The configuration

The package's second setup script looks for model configuration at
`/opt/continue/config/models` and for MCP server configuration at
`/opt/continue/config/mcpservers`, and says what it found:

```terminal:execute
command: |-
  grep '^Continue: ' ~/.local/share/workshop/setup-scripts.log
```

This workshop mounts neither, so the script should say that it found no
configuration at either place, and it wrote nothing. A workshop that
mounts configuration gets `~/.continue/config.yaml` and
`~/.continue/mcpServers/educates-mcp-servers.yaml` instead, as the
package's README describes.

## The extension in the editor

Open the editor's Extensions view, which lists the installed extensions:

```editor:execute-command
command: workbench.view.extensions
```

Continue should be among them. Open Continue's own view in the side bar:

```editor:execute-command
command: workbench.view.extension.continue
```
