---
name: maintain-package
description: Add or bump an extension package in this repository and check it from fetch to a workshop session. Use when asked to package a new CLI or VS Code extension, or to move a package to a newer upstream version.
---

# Maintain a package

The repository README is the source of truth for how a package is built:
its "Package sources", "Fetch scripts", "Setup scripts" and "Validation
pages" sections give the layout, the fetch helpers and the rules. Read them
first. This skill adds the steps and the checks.

1. Follow the branch that fits, then come back for the checks below:
   - a package that doesn't exist yet: [ADD.md](ADD.md);
   - a newer upstream version of an existing package: [BUMP.md](BUMP.md).
2. Run the checks below until every one passes.
3. Hand the live session check to the human, and say which checks passed.

## Upstream facts

Both branches take versions, asset names and checksums from the upstream
source, never from memory:

- **Assets.** Read the release's asset list, with
  `gh release view <tag> -R <owner>/<repo> --json assets`, or open-vsx's API,
  `https://open-vsx.org/api/<publisher>/<name>/<version>`, with
  `/<platform>/<version>` for a platform build such as `linux-x64`. Copy
  asset names from the listing: projects spell the platforms differently,
  as `amd64`, `x86_64` or `x64`, and `Linux` or `linux`.
- **Checksums.** Compute each sha256 from the download,
  `curl -fsSL <url> | shasum -a 256`, and confirm it against what upstream
  publishes: the release's checksums file, the `digest` that
  `gh release view --json assets` reports for recent assets, or open-vsx's
  checksum at the file's URL with `.vsix` replaced by `.sha256`. A mismatch
  stops the work until it is explained.
- **Archives.** `tar -tzf <archive>` lists a tar archive's member paths,
  which can carry the version, as `gh_<version>_linux_amd64/bin/gh` does.
  `zipinfo <file>.vsix` lists an extension's entries.

## Checks

Run them in order. When one fails, fix the package and start again from
the first.

1. **Fetch.** Run `./package.sh fetch <name>`. It passes when it exits 0,
   `ls -lR packages/<name>` shows each fetched file under its final name,
   0755 for a program and 0644 for anything else, and `file` on each program
   says x86-64 under `linux-amd64` and aarch64 under `linux-arm64`. A
   swapped asset passes every later check, so this is the only place it
   shows.
2. **Dry run.** Run `./package.sh publish --dry-run <name>`. It passes when
   it exits 0, prints a `linux/amd64` and a `linux/arm64` line, and its
   `Ignored in the package source:` list is exactly `README.md, fetch.sh`,
   with `workshop.md` when the package has one.
3. **Setup.** Run
   `.claude/skills/maintain-package/scripts/check-setup.sh <name>`. It runs
   the package's setup scripts through the platform's own
   `rebuild-workshop`, twice, in the base environment image of the release
   CI pins, with the package mounted read only; the first run pulls the
   image. For a package that needs a JDK workshop image, set
   `BASE_IMAGE=ghcr.io/educates/educates-jdk21-environment:<version>`, the
   version being CI's pin. It passes when it prints `PASS`. Read the rest of
   its output too: a second run that takes as long as the first is calling
   the network or reinstalling; each program should show a `complete` line;
   each extension should be listed.
4. **Generated workshop.** Run
   `./package.sh try --no-deploy --output "$(mktemp -d)" <name>`. It passes
   when the written `resources/workshop.yaml` declares
   `$(image_repository)/<name>:<version>` and `workshop/content/` holds the
   package's page, when the package has a `workshop.md`, before the last
   page, `NN-delete-workshop.md`.
5. **Tests.** When the change touched `package.sh` or `test/`, run
   `bats test`, which needs the local registry at `localhost:5001`
   (`educates local registry deploy`). A package alone needs no new test.
6. **Live session, for the human.** `./package.sh try <name>` deploys the
   generated workshop under Docker and opens it in the browser, adding
   `--workshop-image` for a package that needs another image. The human
   works through the package's validation page and checks the first page's
   `Package <name>: image mount` line, then deletes the workshop with the
   command its last page gives, which `try` also prints, before trying
   again. A forced fetch,
   `--package-delivery fetch`, that fails with
   `http: server gave HTTP response to HTTPS client` is the platform's
   fetcher refusing the plain HTTP local registry, not the package.

The package is ready for a pull request when checks 1 to 5 pass and the
human has seen check 6. Commit it as `feat(<name>): add the <name> package`
or `feat(<name>): bump <name> to <version>`.

## After the merge

CI publishes `ghcr.io/educates/extension-packages/<name>:<version>` when
the pull request merges. A new package's GHCR package can start private:
make it public in its package settings. The first publish has to be CI's,
since the workflow's token cannot write to a package pushed by hand.
