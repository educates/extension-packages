## @PACKAGE_NAME@

The package manifest, which the package image carries at its root:

```terminal:execute
command: |-
  cat /opt/packages/@PACKAGE_NAME@/package.yaml
```

The programs the package's `bin` puts on `PATH`. A package without
programs has no `bin`, and `ls` says so:

```terminal:execute
command: |-
  ls -l /opt/packages/@PACKAGE_NAME@/bin
```

How the package arrived, `image mount` when the platform mounted its image
read only, or `package fetch` when it fetched its files:

```terminal:execute
command: |-
  grep '^Package @PACKAGE_NAME@: ' ~/.local/share/workshop/download-workshop.log
```
