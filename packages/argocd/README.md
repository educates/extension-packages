# argocd

The [Argo CD](https://argo-cd.readthedocs.io/) command line tool,
`argocd`, version 3.6.3, for linux/amd64 and linux/arm64.

## What it provides

- `argocd` on `PATH` in every terminal.
- Bash completion for `argocd` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/argocd/completion.bash` and adds one line sourcing it to
  `~/.bashrc`.

The package holds only the command line tool. A workshop that needs an
Argo CD server installs one itself.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: argocd
      image: ghcr.io/educates/extension-packages/argocd:3.6.3
```
