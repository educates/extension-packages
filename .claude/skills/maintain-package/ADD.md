# Adding a package

1. **Gather the upstream facts** for each platform, as SKILL.md's "Upstream
   facts" says: the URL, its sha256 confirmed against upstream's, the
   member path when it comes in an archive, and the install name, mode and
   directory. Also find out, from the tool's own docs and help, the command
   that prints its bash completion, and what it needs in a session: the
   editor, more memory, a JDK or other workshop image, configuration the
   workshop must supply. Done when every platform has a complete row.

2. **Pick the closest package as the model**, and copy its shape, not its
   values:

   | Upstream ships | Model |
   |---|---|
   | a binary per platform | argocd, chainloop, vcluster |
   | a binary inside a tar archive per platform | crane, github, toolhive |
   | one universal `.vsix` | vscode-roo-code |
   | a `.vsix` per platform, and configuration to merge | vscode-continue-dev |
   | several `.vsix` files, installed when the session starts | vscode-java-tools |
   | several `.vsix` files, unpacked at fetch time | vscode-java-tools-oci-overlay |

   When the package needs a fetch helper `package.sh` lacks, add it to
   `package.sh` and its `FETCH_HELPERS` list, with a bats test that drives
   it through `./package.sh fetch` and a fixture package, as
   `test/extract-tar.bats` does for `extract_tar`.

3. **Create `packages/<name>/`.** The name is a DNS label, and it names the
   directory, the manifest and the image alike.
   - `package.yaml`: `name`, `version` (upstream's, without a leading `v`)
     and a one-line `description`.
   - `fetch.sh`, executable: the version from `manifest_version`, then one
     `download` and one install per platform.
   - `common/setup.d/NN-<what>.sh`, executable, for POSIX `sh`. For a CLI,
     copy argocd's `01-completion.sh` and change the tool's name and its
     completion command.
   - `README.md`: what the package provides, the workshop settings it
     needs, and how to declare it with `image:`, in the model's form.
   - `workshop.md`: the validation page, which runs the program in a
     terminal or opens the editor, using only what the package ships.

   Done when `git status` shows only the new directory and `ls -l` shows
   `fetch.sh` and each setup script executable.

4. **Add the package's row** to the README's Packages table, in name order,
   with its reference and the manifest's description.

5. **Run the checks** in SKILL.md.
