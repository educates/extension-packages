---
title: helm
---

The helm package puts Helm, `helm`, on `PATH`, ahead of the `helm` the
workshop image ships, and sets up its bash completion when the session
starts.

## Running the tool

Check which `helm` runs, and its version:

```terminal:execute
command: |-
  command -v helm && helm version
```

The first line should be `/opt/packages/helm/bin/helm`, the package's copy,
and the second should report `Version:"v4.3.2"`.

Create a chart and check it, which needs no cluster:

```terminal:execute
command: |-
  helm create ~/helm-check && helm lint ~/helm-check
```

It should create the chart and end with `1 chart(s) linted, 0 chart(s)
failed`.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `helm` to `~/.local/share/helm/completion.bash`, and added a line
sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n /helm/ ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: helm
url: terminal:helm
```

Check that the new terminal has the completion for `helm`:

```terminal:execute
command: |-
  complete -p helm
session: helm
```

It should print a `complete` command ending in `helm`. To see the
completion at work, type `helm` and a space in that terminal and press Tab
twice: bash lists the commands of `helm`.
