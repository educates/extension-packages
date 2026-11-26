# helm

[Helm](https://helm.sh/), the package manager for Kubernetes, `helm`,
version 4.3.2, for linux/amd64 and linux/arm64.

## What it provides

- `helm` on `PATH` in every terminal.
- Bash completion for `helm` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/helm/completion.bash` and adds one line sourcing it to
  `~/.bashrc`.

The package holds only `helm`, not the license and README that its release
archive also carries.

The Educates workshop base image ships a `helm` of its own, whose version
follows the Educates release. The platform puts a package's `bin` ahead of
the image's programs on `PATH`, so with this package `helm` runs version
4.3.2 whichever Educates release runs the workshop.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: helm
      image: ghcr.io/educates/extension-packages/helm:4.3.2
```

Installing a chart needs the session's access to Kubernetes, which a
workshop has unless its definition turns it off.
