# vscode-roo-code

The [Roo Code](https://roocode.com/) extension, version 3.22.5, an AI
coding agent for VS Code, installed in the workshop editor.

## What it provides

- The Roo Code extension in the workshop editor. When the session starts,
  a setup script installs it with `code-server --install-extension` into
  the editor's extensions, under `~/.local/share/code-server/extensions`.

The package holds the extension as Open VSX publishes it, one build for
every platform. It configures no model provider: connecting Roo Code to
one is left to the workshop or the user.

## Using it

The package needs Educates 4.0 or later, the workshop editor, and 3Gi of
memory for the session. Declare it in the workshop definition, with those
settings:

```yaml
spec:
  workshop:
    packages:
    - name: vscode-roo-code
      image: ghcr.io/educates/extension-packages/vscode-roo-code:3.22.5
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
```
