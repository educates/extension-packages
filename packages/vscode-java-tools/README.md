# vscode-java-tools

The [Extension Pack for Java](https://github.com/microsoft/vscode-java-pack),
version 0.29.2, and the extensions it brings together, for the workshop
editor, on linux/amd64 and linux/arm64.

## What it provides

When the session starts, a setup script installs these extensions into
the editor:

- `redhat.java` 1.42.0, Language Support for Java by Red Hat, which runs
  the Java language server. The package holds a build of it for each
  architecture, and the session installs the one for its own.
- `vscjava.vscode-java-debug` 0.58.2, the Debugger for Java.
- `vscjava.vscode-java-test` 0.43.1, the Test Runner for Java.
- `vscjava.vscode-maven` 0.44.0, Maven for Java.
- `vscjava.vscode-gradle` 3.15.0, Gradle for Java.
- `vscjava.vscode-java-dependency` 0.24.1, the Project Manager for Java.
- `vscjava.vscode-java-pack` 0.29.2, the Extension Pack for Java itself.

The pack also lists IntelliCode, which Open VSX, the editor's extension
gallery, does not serve. Installing the pack goes on without it, with no
error and no network access needed, so the editor has no IntelliCode.

The same script merges the package's editor settings, `settings.json`,
into the user settings, `~/.local/share/code-server/User/settings.json`.
A setting the package sets replaces one of the same name, and every other
setting, such as those the workshop image sets, is kept. The package's
settings turn off update checks and telemetry, hide the Eclipse project
files from the explorer, and have the Java language server update a
project's build configuration automatically.

## Using it

The package needs Educates 4.0 or later, and these workshop settings:

- the editor, which the extensions are installed into;
- 3Gi of memory for the session, for the editor and the Java language
  server;
- a JDK workshop image, such as `jdk21-environment:*`, to build and run
  Java code.

Declare it in the workshop definition:

```yaml
spec:
  workshop:
    image: jdk21-environment:*
    packages:
    - name: vscode-java-tools
      image: ghcr.io/educates/extension-packages/vscode-java-tools:0.29.2
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
```
