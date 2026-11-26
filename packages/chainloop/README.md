# chainloop

The [Chainloop](https://chainloop.dev/) command line tool, `chainloop`,
version 1.138.0, for linux/amd64 and linux/arm64.

## What it provides

- `chainloop` on `PATH` in every terminal.
- Bash completion for `chainloop` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/chainloop/completion.bash` and adds one line sourcing it
  to `~/.bashrc`. The script generates the completion without contacting
  the Chainloop control plane, so it doesn't delay the session's start.

The package holds only the command line tool. A workshop that uses it
against a Chainloop control plane sets up the account or API token itself.

Before it runs most commands, `chainloop` contacts its control plane, by
default `cp.chainloop.dev`, and it waits about 20 seconds when the
session's network drops that traffic. Completing a command line with Tab
runs `chainloop` too, so in a session that can't reach the control plane,
both commands and completion are slow.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: chainloop
      image: ghcr.io/educates/extension-packages/chainloop:1.138.0
```
