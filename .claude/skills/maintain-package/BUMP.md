# Bumping a package

1. **Find out what changed upstream** from the current version to the new
   one. Read the release notes, and for a long range the project's own
   upgrade notes where it publishes them. Generated release notes miss
   changes, so also check each thing the package's README and validation
   page state against the new release: its `--help`, the commands check 3
   runs, or a diff of its source. Done when you can say, for each of
   these, whether it changed:
   - asset names and archive layout;
   - the completion command;
   - the output the validation page quotes;
   - network calls the tool makes on its own, such as telemetry or update
     checks, and the setting that turns each off;
   - workarounds that a setup script's comments describe, which may no
     longer be needed or may no longer work;
   - for an extension: its pre-release flag, its `engines.vscode`, its
     ID, a pack's member list, since a new member would need the network
     to install, and the project links its README gives;
   - what the tool needs in a session.

2. **Change `version` in `package.yaml`.** The Java pair moves together:
   - In vscode-java-tools and vscode-java-tools-oci-overlay the manifest's
     version is vscode-java-pack's, and the other six extensions' versions
     are set in `fetch.sh`. Bump both packages to the same set.
   - vscode-java-tools-oci-overlay's `common/extensions.json` records each
     extension as code-server's install records it, and its fetch fails
     when the folders it unpacked and that file disagree. Derive the new
     file from a real install rather than editing versions by hand:
     install the seven `.vsix` files with `code-server --install-extension`
     in the JDK workshop image, in the setup script's order, copy the
     `extensions.json` that writes, and indent it as the committed file is.

3. **Replace every sha256 in `fetch.sh`** with the new assets', found and
   confirmed as SKILL.md's "Upstream facts" says, and any URL or member
   path that changed.

4. **Update every other mention** of the old version: the package README's
   reference and example, the validation page where it quotes the version
   a program prints, and the README's Packages table row and, for argocd,
   its "Using a package" example. Done when
   `grep -rn -F '<old version>' packages/<name> README.md` prints nothing
   that should have moved.

5. **Run the checks** in SKILL.md. The dry run's digest differs from the
   published one, as it should.
