# github

The [GitHub CLI](https://cli.github.com/), `gh`, version 2.74.2, for
linux/amd64 and linux/arm64.

## What it provides

- `gh` on `PATH` in every terminal.
- Bash completion for `gh` in every new terminal. When the session starts,
  a setup script writes the completion to
  `~/.local/share/gh/completion.bash` and adds one line sourcing it to
  `~/.bashrc`.

The package holds only `gh`, not the manual pages that its release archive
also carries.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: github
      image: ghcr.io/educates/extension-packages/github:2.74.2
```

Most `gh` commands act on GitHub as a logged in user. The package sets up
no login: a workshop supplies a token, such as in the `GH_TOKEN`
environment variable, or has the workshop user run `gh auth login`.
