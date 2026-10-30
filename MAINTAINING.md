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

From this repository checkout, tapped as `fclaude/fclaude-packages`:

```sh
brew trust --formula fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew trust --cask fclaude/fclaude-packages/sqlite-explorer fclaude/fclaude-packages/nodwyn
brew style Formula Casks .github/workflows/validate.yml scripts/test-linux.sh
brew audit --strict --formula fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew audit --cask --online fclaude/fclaude-packages/sqlite-explorer fclaude/fclaude-packages/nodwyn
brew install fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew linkage --test fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
python3 scripts/pty-smoke.py
brew install --cask fclaude/fclaude-packages/sqlite-explorer fclaude/fclaude-packages/nodwyn
```

For already installed packages, use `brew reinstall <formula>` or `brew reinstall --cask <cask>` to test the changed definition. The pseudo-terminal checks use temporary homes and files; Hoot never starts an agent in these tests.

Homebrew 6 requires explicit trust before commands such as audit load third-party package definitions. CI trusts only the five packages under test. Fully qualified `brew install` commands grant the named package trust automatically; users do not need to trust the whole tap.

The workflow uses macOS 15 on native Apple Silicon and Intel runners, with a read-only `GITHUB_TOKEN` for validation. Pushes to `main`, pull requests and manual dispatch run validation. After all native checks pass on a main push, a separate publication job with contents-write permission publishes the exact tested Linux artifacts and checksum manifests as a new GitHub release. It does not publish bottles or update upstream repositories. Use `brew livecheck --tap=fclaude/fclaude-packages` to inspect newer releases when maintaining the tap; no scheduled updater is configured.

## Linux packages

`packaging/linux/releases.json` pins versioned upstream assets and SHA256 checksums. Keep Coigüe, Hoot and SQLite Explorer DEB/RPM files unchanged; Brote and Nodwyn are packaged from their portable Linux tarballs using their respective nFPM recipes. Nodwyn preserves both executables next to each other, LICENSE, NOTICE and source provenance. Its Linux browser launcher is packaging-owned. The build script downloads a pinned, checksum-verified nFPM 2.48.0 binary into the ignored local cache. No system installation, signing key, or external hosting account is needed.

Run on Linux with Python 3.11 or newer:

```sh
python3 scripts/build-linux.py --arch amd64
python3 scripts/build-linux.py --arch arm64
```

Output is `dist/linux/<arch>/{deb,rpm}/` plus `SHA256SUMS-linux-<arch>`. Brote includes both commands and its MIT license. File metadata uses a fixed source date for package builds. SQLite Explorer is omitted on ARM64 because no upstream package exists.

For an update, verify the upstream `SHA256SUMS` and GitHub asset digests against actual downloaded files, update the manifest URLs/checksums/versions, and review the package metadata, dependencies, architecture and installed license paths. Never silently accept changed bytes under an old release. A packaging-only Brote update also needs an incremented `release` in the nFPM recipe and corresponding output filenames in the build script. Update the README package-set tag when publishing a new set.

CI uses native Ubuntu amd64 and ARM64 runners. Each creates that architecture's packages, then tests install, CLI behavior, terminal restoration, and uninstall in Ubuntu 24.04 and Fedora 44 containers. The amd64 jobs additionally validate SQLite Explorer's desktop entry, license and shared-library resolution; they do not launch its GUI. Ubuntu container tests explicitly retain package documentation, which minimal Ubuntu images otherwise exclude. The same tests can be run locally:

```sh
docker run --rm -v "$PWD:/workspace:ro" -v "$PWD/dist/linux/amd64:/packages:ro" \
  ubuntu:24.04 bash /workspace/scripts/test-linux.sh deb amd64
docker run --rm -v "$PWD:/workspace:ro" -v "$PWD/dist/linux/amd64:/packages:ro" \
  fedora:44 bash /workspace/scripts/test-linux.sh rpm amd64
```

Use a native ARM64 Docker host and change the mounted output path and final argument to `arm64` to repeat on ARM64. Do not treat metadata inspection or emulation alone as proof of a native install.

Successful CI uploads `linux-amd64` and `linux-arm64` artifacts. Main pushes publish a new `packages-YYYY-MM-DD-RUN` release only after both Mac and both Linux matrix jobs pass. The publisher checks artifact inventory and checksums, refuses a superseded main commit, uploads a draft, verifies GitHub asset hashes, and then publishes. Previously published assets are never replaced. A retry can replace only its own draft. README download commands select the latest published set.

Hosting signed APT/DNF repositories, adding signing keys, and configuring external accounts are separate work. Public GitHub releases provide downloadable local packages without those services.

## Nodwyn release contract

Nodwyn portable archives have flat `nodwyn`, `nodwyn-egress`, `LICENSE` and `NOTICE` members; Linux packages are built from them. On a Mac, `Casks/nodwyn.rb` installs the release's `Nodwyn-macos-universal.zip`: `Nodwyn.app` with the webview build, universal, ad-hoc signed, its icon and `nodwyn-egress-linux-amd64`/`-arm64` beside the executable. `nodwyn version` reports the full source commit, not the release tag; update the expected commit in the cask and container checks with the pinned URLs and hashes, and the bundle version in CI. The cask's `nodwyn` command is a wrapper that `exec`s the app's executable by its path, because nodwyn finds its egress helper next to the executable it was started as, and a symlink on PATH would be that executable. The egress helper is always Linux. Native CI executes the main binary and checks the helpers' ELF headers; it never executes a Linux helper on macOS. Nodwyn was a formula until 0.1.3; `tap_migrations.json` moves an installed formula to the cask on `brew update`. Preserve the unsigned/notarization caveat.
