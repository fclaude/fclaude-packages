# Maintaining the tap

Keep packaging changes in this repository. Publish and validate an upstream release first, then update the corresponding package here. No extra repository secret or cross-repository token is required for validation.

## Updating a command-line tool

1. Check out a branch in this repository and read the upstream release notes and build instructions. Verify that its toolchain requirements still match the formula and Homebrew's current Go/Rust versions.
2. Resolve the release tag to a full commit SHA. For example:

   ```sh
   gh api repos/fclaude/brote/releases/latest --jq '.tag_name'
   gh api repos/fclaude/brote/commits/v0.3.0 --jq '.sha'
   ```

3. Download the archive for that full commit and calculate its checksum. Substitute the new SHA below. Do not use the hash of a tag archive: the archive's directory name differs, so its checksum differs too.

   ```sh
   curl --fail --location --output /tmp/brote-source.tar.gz \
     https://github.com/fclaude/brote/archive/ad0da5b6e99c942221ff8c7b1bdc239921a95dcb.tar.gz
   shasum -a 256 /tmp/brote-source.tar.gz
   tar -tzf /tmp/brote-source.tar.gz | head
   ```

4. Change `url`, `version`, and `sha256` in `Formula/<tool>.rb`. For Brote and Coigüe, also change the `SourceCommit` linker value to the same full commit SHA. Keep `Cargo.lock` and the default locked Cargo build for Hoot. Homebrew's standard Go build arguments build the requested command only.
5. Check required binaries, licenses and notices. Brote must install both commands. Coigüe must retain `THIRD_PARTY_NOTICES.md`; its test helper and host-profile generator are not shipped. Update the README version table.
6. Run the checks below and push a branch. A pull request runs both Mac architectures. Review successful checks for the exact proposed commit before merging. The `main` workflow validates the published result again.

The formula archives are pinned to immutable commit identities and verified by SHA256. Go uses the upstream module manifest/checksums; Hoot uses the upstream Cargo lockfile. Replacing an existing release asset or moving a tag must not silently change an installed version. A packaging-only change that affects an installed CLI needs a Homebrew `revision` bump; reset that revision when upgrading the source version.

## Updating SQLite Explorer

1. Inspect the release assets and signing notes. Download the universal DMG and `SHA256SUMS`, and compare the locally calculated SHA256 with both the checksum manifest and GitHub's asset digest where available:

   ```sh
   gh release view v0.2.1 --repo fclaude/sqlite-explorer
   mkdir -p /tmp/sqlite-explorer-release
   gh release download v0.2.1 --repo fclaude/sqlite-explorer \
     --pattern '*.dmg' --pattern SHA256SUMS --dir /tmp/sqlite-explorer-release
   shasum -a 256 /tmp/sqlite-explorer-release/*.dmg
   cat /tmp/sqlite-explorer-release/SHA256SUMS
   gh api repos/fclaude/sqlite-explorer/releases/tags/v0.2.1 \
     --jq '.assets[] | {name, digest}'
   ```

2. On a Mac, mount the downloaded DMG read-only with `hdiutil attach -readonly -nobrowse <dmg>`. Inspect its actual `.app` path and `Contents/Info.plist`; do not assume an app rename from the marketing name. Detach the returned mount point when finished. Confirm both `x86_64` and `arm64` with `lipo -info` and validate the signature with `codesign --verify --deep --strict <app>`.
3. Update `version` and `sha256` in `Casks/sqlite-explorer.rb`; adjust the URL only if the upstream filename changes. Verify the minimum macOS requirement, app path, bundle identifier, and license. Update CI assertions and the README version table if those change.
4. Keep the unsigned/notarization caveat accurate. Only remove it once the published artifact has Developer ID signing and notarization. Do not disable quarantine or add Gatekeeper bypasses. The separate `codesign` check verifies the integrity of the ad-hoc signature; it does not establish Developer ID identity or notarization.
5. Run both Mac CI jobs before publishing an update. The workflow checks installation, bundle metadata, executable architecture, signature integrity, license, and uninstall. GUI behavior and Gatekeeper acceptance still require manual testing on a Mac.

## Local validation on macOS

With a development checkout tapped as `fclaude/fclaude-packages`:

```sh
brew trust --formula fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew trust --cask fclaude/fclaude-packages/sqlite-explorer
brew style fclaude/fclaude-packages
brew audit --strict --formula fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew audit --cask --online fclaude/fclaude-packages/sqlite-explorer
brew install --build-from-source fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew linkage --test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
python3 scripts/pty-smoke.py
brew install --cask fclaude/fclaude-packages/sqlite-explorer
```

For already installed packages, use `brew reinstall --build-from-source <formula>` or `brew reinstall --cask <cask>` to test the changed definition. The pseudo-terminal checks use temporary homes and files; Hoot never starts an agent in these tests.

Homebrew 6 requires explicit trust before commands such as audit load third-party package definitions. CI trusts only the four packages under test. Fully qualified `brew install` commands grant the named package trust automatically; users do not need to trust the whole tap.

The workflow uses macOS 15 on native Apple Silicon and Intel runners, with a read-only `GITHUB_TOKEN`. Pushes to `main`, pull requests and manual dispatch run validation. It does not publish bottles, update upstream repositories, create credentials, or collect telemetry. Use `brew livecheck --tap=fclaude/fclaude-packages` to inspect newer releases when maintaining the tap; no scheduled updater is configured.

## Current source identities

| Formula | Release tag | Source commit |
| --- | --- | --- |
| brote | v0.3.0 | ad0da5b6e99c942221ff8c7b1bdc239921a95dcb |
| coigue | v0.2.3 | d01df859582b26493c84c7419985e6ce2ff7898b |
| hoot | v0.1.2 | 7eee895dfc12cd84e23166b0363770f5590239ef |

Update this table with each source release.
