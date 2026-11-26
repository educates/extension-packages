# vscode-java-tools

The [Extension Pack for Java](https://github.com/microsoft/vscode-java-pack),
version 0.31.2, and the extensions it brings together, for the workshop
editor, on linux/amd64 and linux/arm64.

## What it provides

When the session starts, a setup script installs these extensions into
the editor:

- `redhat.java` 1.58.0, Language Support for Java by Red Hat, which runs
  the Java language server. The package holds a build of it for each
  architecture, and the session installs the one for its own.
- `vscjava.vscode-java-debug` 0.60.0, the Debugger for Java.
- `vscjava.vscode-java-test` 0.47.0, the Test Runner for Java.
- `vscjava.vscode-maven` 0.45.3, Maven for Java.
- `vscjava.vscode-gradle` 3.18.0, Gradle for Java.
- `vscjava.vscode-java-dependency` 0.27.7, the Project Manager for Java.
- `vscjava.vscode-java-pack` 0.31.2, the Extension Pack for Java itself.

The pack lists the other six extensions and nothing else. The script
installs them before the pack, so installing the pack doesn't need the
network, though when the extension gallery can be reached, code-server
still asks it about the pack, which took about half a second in a
measured session. A rerun, as `rebuild-workshop` makes, installs only an
extension the editor doesn't already have at that version.

vscode-java-tools-oci-overlay provides the same extensions unpacked ahead
of time, so that a session has them about 4 seconds sooner; its README
compares the two.

The same script merges the package's editor settings, `settings.json`,
into the user settings, `~/.local/share/code-server/User/settings.json`.
A setting the package sets replaces one of the same name, and every other
setting, such as those the workshop image sets, is kept. The package's
settings turn off update checks, telemetry and the Project Manager's
dependency checkup, which suggests upgrading old Java and Spring versions
and reports known vulnerabilities. They also hide the Eclipse project
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
      image: ghcr.io/educates/extension-packages/vscode-java-tools:0.31.2
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
```
