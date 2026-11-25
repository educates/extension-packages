# vscode-continue-dev

The [Continue](https://www.continue.dev/) extension, version 1.1.63, an AI
code assistant for VS Code, installed in the workshop editor, for
linux/amd64 and linux/arm64.

## What it provides

- The Continue extension in the workshop editor. The package holds the
  `linux-x64` and `linux-arm64` builds that Open VSX publishes, and a
  session gets only the one for its platform. When the session starts, a
  setup script installs it with `code-server --install-extension` into
  the editor's extensions, under `~/.local/share/code-server/extensions`.
- Continue's configuration, written under `~/.continue` from the model and
  MCP server configuration the workshop mounts, as
  [Configuring Continue](#configuring-continue) describes. A workshop that
  mounts none gets Continue with no models configured.

## Using it

The package needs Educates 4.0 or later, the workshop editor, and 3Gi of
memory for the session. Declare it in the workshop definition, with those
settings:

```yaml
spec:
  workshop:
    packages:
    - name: vscode-continue-dev
      image: ghcr.io/educates/extension-packages/vscode-continue-dev:1.1.63
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
```

## Configuring Continue

When the session starts, after installing the extension, a second setup
script writes Continue's configuration from two directories that the
workshop can mount into the session. Each is optional:

| Mounted at | Holds | Written to |
|---|---|---|
| `/opt/continue/config/models` | ytt overlays adding models to the package's default configuration | `~/.continue/config.yaml` |
| `/opt/continue/config/mcpservers` | ytt templates rendering a Continue MCP server configuration | `~/.continue/mcpServers/educates-mcp-servers.yaml` |

Where a directory isn't mounted, the script says that it found no
configuration there and writes nothing for it. The script logs what it
did to the session's setup log, `~/.local/share/workshop/setup-scripts.log`,
in lines starting with `Continue:`. When ytt fails on the mounted
configuration, the script fails without writing the file, and the session
reports a failed setup script. Running the script again, as
`rebuild-workshop` does, writes the same files again.

A Kubernetes secret or config map volume holds its files in a `..data`
directory and links to them from the mounted directory. The script reads
the files from `..data` where there is one, and from the mounted directory
itself otherwise, so configuration mounted another way works too.

What Continue's configuration can hold is described in the
[Continue documentation](https://docs.continue.dev/).

### Models

The package's default configuration, `default-config.yaml` at the root of
the package, is a Continue configuration with no models:

```yaml
name: Local Assistant
version: 1.0.0
schema: v1
models: []
context:
  - provider: code
  - provider: docs
  - provider: diff
  - provider: terminal
  - provider: problems
  - provider: folder
  - provider: codebase
```

The script applies each file in `/opt/continue/config/models`, in name
order, to it as a ytt overlay. This overlay adds a model, or merges it
into a model of the same name already there:

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.all
---
models:
#@overlay/match by="name",expects="0+"
- name: LiteLLM
  provider: openai
  model: gemini/gemini-2.5-flash
  apiBase: http://litellm.litellm.svc.cluster.local:4000
  apiKey: sk-5678
  roles:
  - chat
  - edit
  - apply
```

### MCP servers

The script renders the files in `/opt/continue/config/mcpservers`
together with ytt, and writes the result as one Continue MCP server
configuration. One file can give the whole configuration, or give its
first document while other files add servers with overlays. This one
does both:

```yaml
#@ load("@ytt:overlay", "overlay")

---
name: Educates MCP Server Configuration
version: 0.0.1
schema: v1
mcpServers:

#@overlay/match by=overlay.all
---
mcpServers:
#@overlay/match by="name",expects="0+"
- name: fetch
  type: streamable-http
  url: http://127.0.0.1:36648/mcp
```

### Mounting the configuration

On a cluster, keep the configuration in a secret, since a model's `apiKey`
is a credential, with each file as a key. A config map works the same
way. For example, in the `default` namespace:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: continue-config-models
  namespace: default
type: Opaque
stringData:
  litellm-model.yaml: |
    #@ load("@ytt:overlay", "overlay")

    #@overlay/match by=overlay.all
    ---
    models:
    #@overlay/match by="name",expects="0+"
    - name: LiteLLM
      provider: openai
      model: gemini/gemini-2.5-flash
      apiBase: http://litellm.litellm.svc.cluster.local:4000
      apiKey: sk-5678
      roles:
      - chat
      - edit
      - apply
---
apiVersion: v1
kind: Secret
metadata:
  name: continue-config-mcpservers
  namespace: default
type: Opaque
stringData:
  mcp-servers.yaml: |
    #@ load("@ytt:overlay", "overlay")

    ---
    name: Educates MCP Server Configuration
    version: 0.0.1
    schema: v1
    mcpServers:

    #@overlay/match by=overlay.all
    ---
    mcpServers:
    #@overlay/match by="name",expects="0+"
    - name: fetch
      type: streamable-http
      url: http://127.0.0.1:36648/mcp
```

The workshop definition then copies the secrets into the workshop
environment with `environment.secrets`, which also keeps the copies up to
date, and mounts them read only where the script looks:

```yaml
spec:
  workshop:
    packages:
    - name: vscode-continue-dev
      image: ghcr.io/educates/extension-packages/vscode-continue-dev:1.1.63
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
    volumes:
    - name: continue-config-models
      secret:
        secretName: continue-config-models
    - name: continue-config-mcpservers
      secret:
        secretName: continue-config-mcpservers
    volumeMounts:
    - name: continue-config-models
      mountPath: /opt/continue/config/models
      readOnly: true
    - name: continue-config-mcpservers
      mountPath: /opt/continue/config/mcpservers
      readOnly: true
  environment:
    secrets:
    - name: continue-config-models
      namespace: default
    - name: continue-config-mcpservers
      namespace: default
```

The script runs when the session starts, so a session started before a
secret changed keeps the configuration it started with until
`rebuild-workshop` runs.

`educates docker workshop deploy` doesn't mount a workshop's
`session.volumes`, so under Docker the session starts without
configuration.
