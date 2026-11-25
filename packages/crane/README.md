# crane

The [crane](https://github.com/google/go-containerregistry/blob/main/cmd/crane/README.md)
command line tool, `crane`, version 0.19.1, for linux/amd64 and
linux/arm64. crane works with images in remote registries directly, with no
container runtime.

## What it provides

- `crane` on `PATH` in every terminal, built for the session's
  architecture.
- Bash completion for `crane` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/crane/completion.bash` and adds one line sourcing it to
  `~/.bashrc`.

The package holds only `crane`, not the `gcrane` and `krane` programs that
its release archive also carries.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: crane
      image: ghcr.io/educates/extension-packages/crane:0.19.1
```
