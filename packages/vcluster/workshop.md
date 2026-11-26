---
title: vcluster
---

The vcluster package puts the vCluster command line tool, `vcluster`, on
`PATH`, and sets up its bash completion when the session starts.

## Running the tool

Run `vcluster` to print its version, which needs no access to a
Kubernetes cluster:

```terminal:execute
command: |-
  vcluster version
```

It should print `vcluster version 0.38.0`.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `vcluster` to `~/.local/share/vcluster/completion.bash`, and added a
line sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n vcluster ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: vcluster
url: terminal:vcluster
```

Check that the new terminal has the completion for `vcluster`:

```terminal:execute
command: |-
  complete -p vcluster
session: vcluster
```

It should print a `complete` command ending in `vcluster`. To see the
completion at work, type `vcluster` and a space in that terminal and press
Tab twice: bash lists the commands of `vcluster`.
