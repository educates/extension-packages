# Bumping a package

1. **Read upstream's release notes** from the current version to the new
   one, for anything the package relies on: asset names, archive layout,
   the completion command, extension IDs, and what the tool needs in a
   session. Done when you can say, for each of these, whether it changed.

2. **Change `version` in `package.yaml`.** The Java pair moves together:
   - In vscode-java-tools and vscode-java-tools-oci-overlay the manifest's
     version is vscode-java-pack's, and the other six extensions' versions
     are set in `fetch.sh`. Bump both packages to the same set.
   - vscode-java-tools-oci-overlay's `common/extensions.json` records each
     extension's folder name and version. Update it to match: its fetch
     fails when the folders it unpacked and that file disagree.

3. **Replace every sha256 in `fetch.sh`** with the new assets', found and
   confirmed as SKILL.md's "Upstream facts" says, and any URL or member
   path that the release notes say changed.

4. **Update every other mention** of the old version: the package README's
   reference and example, the validation page where it checks the version
   a program prints, and the README's Packages table row. Done when
   `grep -rn -F '<old version>' packages/<name> README.md` prints nothing
   that should have moved.

5. **Run the checks** in SKILL.md. The dry run's digest differs from the
   published one, as it should.
