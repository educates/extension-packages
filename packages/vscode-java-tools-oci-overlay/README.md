# vscode-java-tools-oci-overlay

The [Extension Pack for Java](https://github.com/microsoft/vscode-java-pack),
version 0.31.2, and the extensions it brings together, for the workshop
editor, on linux/amd64 and linux/arm64. It holds the same extensions as
[vscode-java-tools](../vscode-java-tools/README.md), unpacked ahead of
time, so that the session copies them into place instead of installing
them.

## What it provides

The package holds these extensions unpacked, as the editor keeps an
extension once it is installed:

- `redhat.java` 1.58.0, Language Support for Java by Red Hat, which runs
  the Java language server. The package holds a build of it for each
  architecture, and the session gets the one for its own.
- `vscjava.vscode-java-debug` 0.60.0, the Debugger for Java.
- `vscjava.vscode-java-test` 0.47.0, the Test Runner for Java.
- `vscjava.vscode-maven` 0.45.3, Maven for Java.
- `vscjava.vscode-gradle` 3.18.0, Gradle for Java.
- `vscjava.vscode-java-dependency` 0.27.7, the Project Manager for Java.
- `vscjava.vscode-java-pack` 0.31.2, the Extension Pack for Java itself.

The pack lists the other six extensions and nothing else, so the package
holds the whole pack.

When the session starts, a setup script copies each extension into the
editor's extensions directory, `~/.local/share/code-server/extensions`,
and adds the package's entries to `extensions.json` there, the list of
extensions the editor loads. An entry the package adds replaces any entry
for the same extension, so running the script again, as
`rebuild-workshop` does, leaves one entry for each. The script reports how
long it took in the setup log,
`~/.local/share/workshop/setup-scripts.log`, as a line such as
`vscode-java-tools-oci-overlay put 7 extensions in place in 0.108 seconds`.

The same script merges the package's editor settings, `settings.json`,
into the user settings, `~/.local/share/code-server/User/settings.json`.
A setting the package sets replaces one of the same name, and every other
setting, such as those the workshop image sets, is kept. The package's
settings turn off update checks, telemetry and the Project Manager's
dependency checkup, which suggests upgrading old Java and Spring versions
and reports known vulnerabilities. They also hide the Eclipse project
files from the explorer, and have the Java language server update a
project's build configuration automatically.

## Choosing between the Java packages

vscode-java-tools installs the extensions from their `.vsix` files when
the session starts. This package is unpacked when it is published, so the
session only copies files. Measured in sessions on an arm64 cluster node,
this package's setup took about 0.1 seconds and vscode-java-tools' about
4.5, so a session has its editor extensions about 4 seconds sooner.

The image is hardly larger to download, about 202 MB for each
architecture against 192 MB, since the `.vsix` files are compressed
already. Unpacked on the node, it takes about 274 MB against 193 MB.

What this package gives up is going through code-server to install: it
writes code-server's `extensions.json` itself, in the form code-server
used when the package was built. A code-server release that changed that
form would break this package and not vscode-java-tools. Declare one of
the two packages, not both.

## Using it

The package needs Educates 4.0 or later, and these workshop settings:

- the editor, which the extensions are copied into;
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
    - name: vscode-java-tools-oci-overlay
      image: ghcr.io/educates/extension-packages/vscode-java-tools-oci-overlay:0.31.2
  session:
    resources:
      memory: 3Gi
    applications:
      editor:
        enabled: true
```
