---
title: vscode-java-tools
---

The vscode-java-tools package installs the Java extensions into the
editor when the session starts, and merges its editor settings into the
user settings.

## The installed extensions

List the extensions the editor has:

```terminal:execute
command: |-
  code-server --list-extensions --show-versions
```

Beside the Educates extension, the list should hold these seven:

- `redhat.java@1.42.0`
- `vscjava.vscode-gradle@3.15.0`
- `vscjava.vscode-java-debug@0.58.2`
- `vscjava.vscode-java-dependency@0.24.1`
- `vscjava.vscode-java-pack@0.29.2`
- `vscjava.vscode-java-test@0.43.1`
- `vscjava.vscode-maven@0.44.0`

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
