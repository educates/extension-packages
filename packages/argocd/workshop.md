---
title: argocd
---

The argocd package puts the Argo CD command line tool, `argocd`, on
`PATH`, and sets up its bash completion when the session starts.

## Running the tool

Run `argocd` to print its version, which needs no Argo CD server:

```terminal:execute
command: |-
  argocd version --client
```

The version should start with `v2.10.6`.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `argocd` to `~/.local/share/argocd/completion.bash`, and added a line
sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n argocd ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: argocd
url: terminal:argocd
```

Check that the new terminal has the completion for `argocd`:

```terminal:execute
command: |-
  complete -p argocd
session: argocd
```

It should print a `complete` command ending in `argocd`. To see the
completion at work, type `argocd` and a space in that terminal and press
Tab twice: bash lists the commands of `argocd`.
