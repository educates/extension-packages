# toolhive

The [ToolHive](https://github.com/stacklok/toolhive) command line tool,
`thv`, version 0.1.7, for linux/amd64 and linux/arm64. ToolHive runs Model
Context Protocol (MCP) servers in containers.

## What it provides

- `thv` on `PATH` in every terminal.
- Bash completion for `thv` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/thv/completion.bash` and adds one line sourcing it to
  `~/.bashrc`.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: toolhive
      image: ghcr.io/educates/extension-packages/toolhive:0.1.7
```

The package holds only the command line tool. thv runs each MCP server in
a container, so a workshop that starts servers with `thv run` also needs a
container runtime that thv can reach.

Every `thv` command except `completion` checks for a newer ToolHive
release when it starts, and prints a notice when there is one. The setup
script only generates the completion, so it makes no such check.
