# vcluster

The [vCluster](https://www.vcluster.com/) command line tool, `vcluster`,
version 0.38.0, for linux/amd64 and linux/arm64.

## What it provides

- `vcluster` on `PATH` in every terminal.
- Bash completion for `vcluster` in every new terminal. When the session
  starts, a setup script writes the completion to
  `~/.local/share/vcluster/completion.bash` and adds one line sourcing it
  to `~/.bashrc`.

The package holds only the command line tool. A workshop that runs
`vcluster` against a Kubernetes cluster relies on the access its session
has to that cluster.

Educates can also give each session a virtual cluster of its own through
the `vcluster` application of the workshop definition, as
[Provisioning a virtual cluster](https://docs.educates.dev/en/latest/custom-resources/workshop-definition.html#provisioning-a-virtual-cluster)
describes. That needs no package: this one is for workshops whose users
run `vcluster` themselves.

## Using it

The package needs Educates 4.0 or later, and no other workshop settings.
Declare it in the workshop definition:

```yaml
spec:
  workshop:
    packages:
    - name: vcluster
      image: ghcr.io/educates/extension-packages/vcluster:0.38.0
```
