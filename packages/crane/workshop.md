---
title: crane
---

The crane package puts the `crane` command line tool on `PATH`, built for
the session's architecture, and sets up its bash completion when the
session starts.

## Running the tool

Check the session's architecture, which is `x86_64` on amd64 and
`aarch64` on arm64:

```terminal:execute
command: |-
  uname -m
```

Run `crane` to print its version, which needs no registry:

```terminal:execute
command: |-
  crane version
```

It should print `0.22.1`, on either architecture.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `crane` to `~/.local/share/crane/completion.bash`, and added a line
sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n crane ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: crane
url: terminal:crane
```

Check that the new terminal has the completion for `crane`:

```terminal:execute
command: |-
  complete -p crane
session: crane
```

It should print a `complete` command ending in `crane`. To see the
completion at work, type `crane` and a space in that terminal and press
Tab twice: bash lists the commands of `crane`.
