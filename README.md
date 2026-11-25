# Educates Extension Packages

Extension packages for Educates workshops, maintained by the Educates team
and published as package images. A workshop declares a package by its
image reference, and the platform mounts the image read only where the
cluster or the Docker daemon supports it, and fetches it otherwise.

The packages need Educates 4.0 or later. Workshops on Educates 3.x keep
using the earlier images from
[educates-extension-packages](https://github.com/educates/educates-extension-packages)
with the `files` form.

## Packages

| Package | Reference | Description |
|---|---|---|
| [argocd](packages/argocd/README.md) | `ghcr.io/educates/extension-packages/argocd:2.10.6` | The Argo CD command line tool, argocd, with bash completion. |
| [crane](packages/crane/README.md) | `ghcr.io/educates/extension-packages/crane:0.19.1` | The crane command line tool for container registries, with bash completion. |
| [github](packages/github/README.md) | `ghcr.io/educates/extension-packages/github:2.74.2` | The GitHub command line tool, gh, with bash completion. |
| [toolhive](packages/toolhive/README.md) | `ghcr.io/educates/extension-packages/toolhive:0.1.7` | The ToolHive command line tool for MCP servers, thv, with bash completion. |

## Using a package

Declare a package under `spec.workshop.packages` in the workshop
definition, giving its reference as `image`:

```yaml
spec:
  workshop:
    packages:
    - name: argocd
      image: ghcr.io/educates/extension-packages/argocd:2.10.6
```

A package's programs are on `PATH` in every terminal, and its setup
scripts run when the session starts. Each package's README says what it
provides and which workshop settings it needs.

What a package image holds, and how the platform delivers it, is described
in
[Creating Extension Packages](https://docs.educates.dev/en/latest/workshop-content/creating-extension-packages.html)
and
[Declaring an extension package as an image](https://docs.educates.dev/en/latest/custom-resources/workshop-definition.html#declaring-an-extension-package-as-an-image).

## Working on the packages

The tooling needs only bash, the `educates` CLI 4.0 or later, `curl`,
`tar` and `unzip`, and runs on macOS, with the bash it ships, and on
Linux. The tests also need [bats](https://github.com/bats-core/bats-core)
and a local registry.

### The package script

`package.sh` at the root of the repository fetches, publishes and tries
the packages. Each command acts on the packages named, or on every package
when none is, except `try`, which needs at least one. Each fails listing
the packages there are when a name is unknown.

```
./package.sh list [<package>...]
./package.sh fetch [<package>...]
./package.sh publish [--dry-run] [--image-repository REPO] [registry flags] [<package>...]
./package.sh try [--cluster] [--package-delivery image-mount|fetch]
    [--workshop-image IMAGE] [--output DIR] [--no-deploy] <package>...
```

- `list` prints the package names, one per line.
- `fetch` empties a package's fetched directories and runs its fetch
  script. When the fetch fails, it removes the fetched directories again,
  so nothing partial remains.
- `publish` fetches each package and runs `educates package publish` on
  it, which prints the reference and digests. The image repository
  defaults to `localhost:5001`, the registry `educates local registry
  deploy` runs, and the reference is `REPO/<name>:<version>`. `--dry-run`
  validates the package and prints its digests without contacting a
  registry. The registry flags of `educates package publish`, such as
  `--registry-username`, `--registry-password` and `--registry-insecure`,
  are passed to it unchanged.
- `try` publishes packages to the local registry and opens a workshop
  session that uses them, as [Trying packages](#trying-packages)
  describes.

`publish` always publishes. Publishing an unchanged package again with the
same `educates` CLI pushes an identical image index, so its tag keeps its
digest. Another CLI version can give different digests for the same
source.

For example, to check a package and then publish it to the local
registry:

```
./package.sh publish --dry-run argocd
./package.sh publish argocd
```

### Trying packages

`try` checks packages in a real workshop session in one step, so that no
package needs a sample workshop of its own:

```
./package.sh try argocd
```

It takes one or more packages, and:

1. publishes them to the local registry at `localhost:5001`, as `publish`
   does;
2. generates a workshop for them from the template in `try-workshop/`, in
   the directory `--output` names, which must be new or empty, or else in
   a new temporary directory;
3. publishes the workshop's content to the local registry with
   `educates workshop publish`;
4. deploys the workshop with `educates docker workshop deploy`, which
   opens it in the browser, or, with `--cluster`, to the current cluster
   with `educates cluster workshop deploy --open-browser`.

Run `educates local registry deploy` first, to start the local registry.
`try` prints where it wrote the workshop and, after deploying it, the
command that deletes it, such as
`educates docker workshop delete --file DIR`. `--no-deploy` stops before
deploying, so that the workshop can be inspected, or kept as a starting
point for a real one.

`--package-delivery image-mount` or `--package-delivery fetch` is passed
to `educates docker workshop deploy`, to force a delivery other than the
one the Docker daemon supports best. On a cluster, the
`packageDelivery.imageMount` setting of `EducatesClusterConfig` chooses
the delivery, so `--cluster` takes no `--package-delivery`.
`--workshop-image` sets the workshop's image, such as
`jdk21-environment:*` for a package that needs a JDK.

The workshop is named `try-` followed by the package names, joined by
hyphens. A name longer than 41 characters is cut short and ends with a
hash of the whole name, so that the name a cluster deploy gives the
workshop, `educates-cli--<name>-<hash>`, stays within the 63 characters
of a Kubernetes label value. The workshop:

- declares each package as `$(image_repository)/<name>:<version>`, which
  resolves to the local registry under Docker and on a local cluster
  alike, with `imagePullPolicy: Always`, so that a republished tag is
  pulled again;
- takes its content from
  `$(image_repository)/<workshop>-files:$(workshop_version)`;
- enables the terminal and the editor, disables the other dashboard
  applications, and asks for 3Gi of memory, which the VS Code packages
  need.

Its first page shows, for each package, the package manifest, the
programs in its `bin` and the line of `download-workshop.log` saying how
the platform delivered it, `image mount` or `package fetch`, as commands
to click. The validation page of each package that has one follows, in
package name order.

### Package sources

Each package is a directory under `packages/`, named after the package:

```
packages/argocd/
  package.yaml                    the package manifest
  fetch.sh                        downloads the upstream files
  README.md                       what the package provides and needs
  workshop.md                     the validation page, optional
  common/setup.d/01-completion.sh run in the session when it starts
  linux-amd64/bin/argocd          fetched
  linux-arm64/bin/argocd          fetched
```

The manifest gives the package's `name`, which is also its directory
name, its `version`, the upstream tool's version without a leading `v`,
and a one-line `description`. `educates package publish` publishes the
manifest with the `common`, `linux-amd64` and `linux-arm64` directories,
and lists everything else in the source as ignored, so the README, the
fetch script and the validation page appear in that listing.

Fetched files go only into the `bin` and `extensions` directories under
`common`, `linux-amd64` and `linux-arm64`. Nothing in those is committed:
git ignores them, and the package script removes them before each fetch.
Committed files, such as setup scripts, live elsewhere in `common`.

### Fetch scripts

The package script runs a package's `fetch.sh` with bash, with the package
source as the working directory, `errexit`, `nounset` and `pipefail` set,
and these helpers defined:

- `manifest_version` prints the `version` from `package.yaml`.
- `download URL SHA256 FILE` downloads `URL` to `FILE`, and fails unless
  the file's sha256 is `SHA256`.
- `install_file SOURCE TARGET MODE` copies `SOURCE` to `TARGET`, creating
  its directory, and gives it `MODE`: 0755 for a program, 0644 for any
  other file.
- `extract_tar ARCHIVE MEMBER TARGET MODE` extracts the file `MEMBER`, its
  path inside the tar archive `ARCHIVE`, to `TARGET` with `MODE`, as
  `install_file` does, and writes nothing else from the archive. It reads
  any archive `tar` recognizes, compressed or not, with bsdtar on macOS
  and GNU tar on Linux.

`$DOWNLOADS` names an empty directory for the downloads, which is removed
afterwards. A fetch script takes the version from the manifest, so a new
version changes the version in `package.yaml` and the recorded checksums.

### Setup scripts

The scripts in a package's `common/setup.d` run in the session when it
starts, and again whenever `rebuild-workshop` runs. Each one:

- is a `.sh` file committed executable, written for POSIX `sh`, which is
  what runs it;
- finds the package directory from `$0`, as
  `$(cd "$(dirname "$0")/.." && pwd)`;
- writes only under `$HOME`, since the package may be mounted read only;
- can run again without duplicating anything.

No package ships `profile.d`: the platform puts a package's `bin` on
`PATH`. An environment variable is written as a `NAME=VALUE` line to the
file `$WORKSHOP_ENV` names.

### Validation pages

A package can have a validation page, `workshop.md` beside its manifest,
which `try` adds to the workshop it generates. The page is a Markdown page
for the workshop's Hugo renderer, starting with front matter that gives
its `title`. Its clickable actions check what the package provides, such
as running a program in a new terminal or opening the editor. `try` adds
only the page, so the page must need nothing outside the package.

### Tests

The bats suite in `test/` drives the package script against a fixture
package kept with the tests, so `list` doesn't show it:

```
bats test
```

The publish tests push to the registry `TEST_REGISTRY` names,
`localhost:5001` by default, under a new repository for each test. Run
`educates local registry deploy` first to start that registry.

The `try` tests publish to `localhost:5001` whatever `TEST_REGISTRY`
names, since `try` always publishes to the local registry, and they leave
the fixture packages and their workshops' content there. They deploy
nothing: a stand-in for `educates` records each deploy instead of running
it.

## Continuous integration

GitHub Actions checks every pull request and publishes every push to
`main`, running the same package script a maintainer runs.

On a pull request, the Check workflow runs the bats suite against a
`registry:2` service container. Then, for each package `./package.sh list`
prints, a job of its own runs `./package.sh publish --dry-run` with the
image repository `ghcr.io/educates/extension-packages`, which downloads the
package's upstream files, validates its layout and prints the digests a
publish would give. These jobs don't cancel each other, so a failing job
names its package and the others still report.

On a push to `main`, the Publish workflow publishes each package in a job
of its own as `ghcr.io/educates/extension-packages/<name>:<version>`. It
logs in with the workflow's own `GITHUB_TOKEN`, granted `packages: write`,
so publishing needs no stored secret, and GitHub links each package the
workflow creates to this repository. One publish run happens at a time.
Every run publishes every package: an unchanged package pushes an
identical image index, so its tag keeps its digest, and only a changed
package gets a new one.

Don't push a package to `ghcr.io/educates/extension-packages` by hand
before the workflow has published it: GitHub then doesn't link the package
to this repository, and the workflow's token can't push to it. After a new
package's first publish, check its visibility in its settings on GitHub
and make it public if it isn't, so that workshops pull it without
credentials.

### The educates CLI version

CI installs the `educates` CLI from the `educates-linux-amd64` asset of an
educates-training-platform release. The script that installs it,
`.github/actions/install-educates/install.sh`, checks the download against
the release's `checksums.txt`, and `test/install-educates.bats` tests it.
The release is set in one place, `EDUCATES_VERSION` in
`.github/actions/install-educates/action.yml`.

A package's digests depend on the CLI build that publishes it, so a new
CLI version can give every package a new digest though no package changed,
and the first publish with it then moves every tag. Bump the version in a
pull request of its own, and say in its description that every package's
digest may change when it merges.
