---
title: vscode-java-tools-oci-overlay
---

The vscode-java-tools-oci-overlay package copies its unpacked Java
extensions into the editor when the session starts, without installing
them, and merges its editor settings into the user settings.

## The extensions in place

List the extensions the editor has:

```terminal:execute
command: |-
  code-server --list-extensions --show-versions
```

Beside the Educates extension, the list should hold these seven:

- `redhat.java@1.58.0`
- `vscjava.vscode-gradle@3.18.0`
- `vscjava.vscode-java-debug@0.60.0`
- `vscjava.vscode-java-dependency@0.27.7`
- `vscjava.vscode-java-pack@0.31.2`
- `vscjava.vscode-java-test@0.47.0`
- `vscjava.vscode-maven@0.45.3`

The setup script copied each one into the editor's extensions directory
and reported how long that took:

```terminal:execute
command: |-
  ls ~/.local/share/code-server/extensions
  grep '^vscode-java-tools-oci-overlay put ' ~/.local/share/workshop/setup-scripts.log
```

The directory should hold a directory for each extension, and the log a
line such as `vscode-java-tools-oci-overlay put 7 extensions in place in
0.353 seconds`.

The copy of `redhat.java` should be the build for the session's
architecture, whose Java runtime names the same machine as `uname -m`:

```terminal:execute
command: |-
  uname -m
  ls ~/.local/share/code-server/extensions/redhat.java-1.58.0/jre
```

## No duplicates after a rebuild

Run the setup scripts again, as `rebuild-workshop` does when the workshop
is updated:

```terminal:execute
command: |-
  rebuild-workshop
```

Then count the entries in the editor's list of extensions,
`extensions.json`:

```terminal:execute
command: |-
  jq -r '.[].identifier.id' ~/.local/share/code-server/extensions/extensions.json | sort | uniq -c
```

Each extension should be counted once.

## The editor settings

Show the user settings:

```terminal:execute
command: |-
  jq . ~/.local/share/code-server/User/settings.json
```

They should hold the package's `java.*` settings and also the settings the
workshop image set before the package's, such as
`"chat.disableAIFeatures": true`.

## The Java language server

Write a small Java program with a mistake in it, under `~/exercises`,
which is inside the folder the editor has open whether or not it existed
when the editor started:

```terminal:execute
command: |-
  mkdir -p ~/exercises/hello && cat > ~/exercises/hello/Hello.java <<'EOF'
  public class Hello {
      public static void main(String[] args) {
          int count = "three";
          System.out.println("Hello, " + count);
      }
  }
  EOF
```

Open it in the editor:

```editor:open-file
file: ~/exercises/hello/Hello.java
line: 3
```

Opening a Java file starts the Java language server, which can take a
minute the first time. Once it is ready, the editor underlines `"three"`
and the Problems panel reports `Type mismatch: cannot convert from String
to int`. Hovering over `String` shows its documentation, which also comes
from the language server.

Check that the language server is running:

```terminal:execute
command: |-
  pgrep -af org.eclipse.jdt.ls.core
```

It should print the Java command line of the language server.
