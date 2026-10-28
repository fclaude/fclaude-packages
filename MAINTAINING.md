# Maintaining packages

Keep packaging changes in this repository. Publish and validate an upstream release first, then update the corresponding package here. No extra repository secret or cross-repository token is required for validation.

## Updating a command-line tool

1. Inspect the upstream release and download both macOS release tarballs plus `SHA256SUMS`. Compare locally computed SHA256 values with the manifest and GitHub asset digests:

   ```sh
   gh api repos/fclaude/brote/releases/latest --jq '.assets[] | {name, digest}'
   gh release download v0.3.0 --repo fclaude/brote --pattern '*darwin*.tar.gz' --pattern SHA256SUMS
   shasum -a 256 brote_0.3.0_darwin_*.tar.gz
   ```

2. Inspect archive contents for both architectures. Update the versioned architecture-specific `url` and `sha256` in `Formula/<tool>.rb`, and the README version table. Keep URLs pinned to a version and retain SHA256 verification. Reset `revision` when upgrading the upstream version; increment it for packaging-only changes affecting installations.
3. Preserve the lightweight binary installation: no Go or Rust build dependency. Hoot uses `uses_from_macos "git"` because Apple's command-line tools supply Git; the executable invokes `git` through PATH. There is no asserted minimum Git version and no forced Homebrew Git upgrade.
4. Retain both Brote commands, Coigüe's `THIRD_PARTY_NOTICES.md`, and all licenses. Run functional tests on native Intel and Apple Silicon before publishing. Do not replace an existing upstream release asset silently: changed bytes require reviewed checksum and packaging-version changes.

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
brew install fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew linkage --test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
python3 scripts/pty-smoke.py
brew install --cask fclaude/fclaude-packages/sqlite-explorer
```

For already installed packages, use `brew reinstall <formula>` or `brew reinstall --cask <cask>` to test the changed definition. The pseudo-terminal checks use temporary homes and files; Hoot never starts an agent in these tests.

Homebrew 6 requires explicit trust before commands such as audit load third-party package definitions. CI trusts only the four packages under test. Fully qualified `brew install` commands grant the named package trust automatically; users do not need to trust the whole tap.

The workflow uses macOS 15 on native Apple Silicon and Intel runners, with a read-only `GITHUB_TOKEN`. Pushes to `main`, pull requests and manual dispatch run validation. It does not publish bottles, update upstream repositories, create credentials, or collect telemetry. Use `brew livecheck --tap=fclaude/fclaude-packages` to inspect newer releases when maintaining the tap; no scheduled updater is configured.
