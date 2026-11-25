---
title: vscode-roo-code
---

The vscode-roo-code package installs the Roo Code extension into the
workshop editor when the session starts.

## The extension is installed

When the session started, the package's setup script installed the
extension with `code-server`. List the editor's extensions:

```terminal:execute
command: |-
  code-server --list-extensions --show-versions
```

The list should include `rooveterinaryinc.roo-cline@3.22.5`.

## The extension in the editor

Open the editor's Extensions view, which lists the installed extensions:

```editor:execute-command
command: workbench.view.extensions
```

Roo Code should be among them. Open Roo Code's own view in the side bar:

```editor:execute-command
command: workbench.view.extension.roo-cline-ActivityBar
```

The package installs only the extension. Connecting Roo Code to a model
provider is left to the workshop or the user.
