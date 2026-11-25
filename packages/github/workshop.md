---
title: github
---

The github package puts the GitHub CLI, `gh`, on `PATH`, and sets up its
bash completion when the session starts.

## Running the tool

Run `gh` to print its version, which needs no login:

```terminal:execute
command: |-
  gh --version
```

The first line should be `gh version 2.74.2`, followed by the release
date.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `gh` to `~/.local/share/gh/completion.bash`, and added a line sourcing
it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n /gh/ ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: github
url: terminal:github
```

Check that the new terminal has the completion for `gh`:

```terminal:execute
command: |-
  complete -p gh
session: github
```

It should print a `complete` command ending in `gh`. To see the completion
at work, type `gh` and a space in that terminal and press Tab twice: bash
lists the commands of `gh`.
