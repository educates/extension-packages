---
title: chainloop
---

The chainloop package puts the Chainloop command line tool, `chainloop`,
on `PATH`, and sets up its bash completion when the session starts.

## Running the tool

Run `chainloop` to print its version, which needs no Chainloop account:

```terminal:execute
command: |-
  chainloop version
```

The client version should be `1.89.8`. The server version is that of the
Chainloop control plane, or `unknown` when the session can't reach it.

## Completion in a new terminal

When the session started, the package's setup script wrote the completion
for `chainloop` to `~/.local/share/chainloop/completion.bash`, and added a
line sourcing it to `~/.bashrc`:

```terminal:execute
command: |-
  grep -n chainloop ~/.bashrc
```

There should be exactly one such line, which every new terminal runs. Open
a new terminal:

```dashboard:reload-dashboard
name: chainloop
url: terminal:chainloop
```

Check that the new terminal has the completion for `chainloop`:

```terminal:execute
command: |-
  complete -p chainloop
session: chainloop
```

It should print a `complete` command ending in `chainloop`. To see the
completion at work, type `chainloop` and a space in that terminal and press
Tab twice: bash lists the commands of `chainloop`. Each completion runs
`chainloop`, which contacts its control plane first, so the list can take
a moment to appear.
