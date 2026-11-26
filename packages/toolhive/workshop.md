---
title: toolhive
---

The toolhive package puts the ToolHive command line tool, `thv`, on
`PATH`, and sets up its bash completion when the session starts.

## Running the tool

Run `thv` to print its version, which needs no container runtime:

```terminal:execute
command: |-
  thv version
```

It should print `ToolHive v0.69.1`, followed by the commit, build date, Go
version and platform, which is `linux/amd64` or `linux/arm64` to match the
session. `thv` first checks for a newer ToolHive release, so it may also
print that a newer version is available, while the package stays on
0.69.1. When the session can't reach ToolHive's update service, it prints
a warning that it could not check for updates instead.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `thv` to `~/.local/share/thv/completion.bash`, and added a line
sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n /thv/ ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: toolhive
url: terminal:toolhive
```

Check that the new terminal has the completion for `thv`:

```terminal:execute
command: |-
  complete -p thv
session: toolhive
```

It should print a `complete` command ending in `thv`. To see the
completion at work, type `thv` and a space in that terminal and press Tab
twice: bash lists the commands of `thv`.
