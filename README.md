# Francisco's packages

[![Validate packages](https://github.com/fclaude/fclaude-packages/actions/workflows/validate.yml/badge.svg)](https://github.com/fclaude/fclaude-packages/actions/workflows/validate.yml)

Packages for my tools on Mac, Ubuntu, and Fedora. Distribution uses this repository and [GitHub Releases](https://github.com/fclaude/fclaude-packages/releases).

| Tool | Version | Installs |
| --- | --- | --- |
| [Brote](https://github.com/fclaude/brote) | 0.8.0 | `brote` Scheme interpreter and `brote-lsp` language server |
| [Coigüe](https://github.com/fclaude/coigue) | 0.4.0 | `coigue` modal terminal editor, with embedded Brote |
| [Hoot](https://github.com/fclaude/hoot) | 0.1.2 | `hoot` terminal UI for reviewing Git changes |
| [SQLite Explorer](https://github.com/fclaude/sqlite-explorer) | 0.2.1 | Desktop browser and editor for SQLite databases |

## Mac

Supports native Apple Silicon and Intel installations using [Homebrew](https://brew.sh). All three CLI formulas install checksum-verified upstream binaries. No Go or Rust compiler is needed. Hoot runs the Git on your PATH, including Apple's command-line tools Git; it does not force installation or upgrading of Homebrew Git.

### Install

```sh
brew tap fclaude/fclaude-packages https://github.com/fclaude/fclaude-packages.git
brew update
brew install fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew install --cask fclaude/fclaude-packages/sqlite-explorer
```

Run the explicit `brew tap` command first: this repository's neutral name requires its Git URL. Install whichever tools you need. Use a macOS version supported by Homebrew; SQLite Explorer itself requires macOS 12 or newer.

```sh
brote -e '(+ 20 22)'
coigue notes.txt
hoot --demo
open -a /Applications/sqlite-explorer.app
```

SQLite Explorer's universal DMG supports Intel and Apple Silicon. Version 0.2.1 is ad-hoc signed and not notarized by Apple, so Gatekeeper may block its first launch. See the upstream [signing notes](https://github.com/fclaude/sqlite-explorer/blob/v0.2.1/docs/RELEASING.md#macos-signing). This cask preserves Homebrew's normal quarantine behavior.

### Upgrade

```sh
brew update
brew upgrade fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew upgrade --cask fclaude/fclaude-packages/sqlite-explorer
```

The Hoot formula has packaging revision 1 so installations made with the earlier source-build definitions can upgrade to the binary packages without changing the upstream version.

### Uninstall

```sh
brew uninstall fclaude/fclaude-packages/brote fclaude/fclaude-packages/coigue fclaude/fclaude-packages/hoot
brew uninstall --cask fclaude/fclaude-packages/sqlite-explorer
brew untap fclaude/fclaude-packages
```

Uninstall only the tools you installed. Documents, databases, and application preferences are retained.

## Ubuntu

Tested on Ubuntu 24.04. Brote, Coigüe, and Hoot support amd64 and arm64. SQLite Explorer is available only for amd64. Hoot requires glibc 2.39 or newer; these Hoot packages do not support Ubuntu 22.04.

Download the matching `.deb` files and checksum manifest from [GitHub Releases](https://github.com/fclaude/fclaude-packages/releases). With the GitHub CLI, run in a new download directory:

```sh
arch=$(dpkg --print-architecture)
gh release download packages-2026-10-29-2 --repo fclaude/fclaude-packages \
  --pattern "*${arch}.deb" --pattern "SHA256SUMS-linux-${arch}"
sha256sum --check --ignore-missing "SHA256SUMS-linux-${arch}"
sudo apt install ./*.deb
```

This installs all available tools for that architecture, resolving dependencies through Ubuntu's package manager. You can instead download selected files in a browser and install just those files with `sudo apt install ./filename.deb`.

These are unsigned local packages hosted on GitHub, not a configured signed APT repository. To upgrade, download and verify a newer package set and repeat the local installation. To uninstall selected tools:

```sh
sudo apt remove brote coigue hoot sqlite-explorer
```

Omit tools you did not install; arm64 has no SQLite Explorer package.

## Fedora

Tested on Fedora 44. Brote, Coigüe, and Hoot support x86_64 and aarch64. SQLite Explorer is available only for x86_64.

Download the matching `.rpm` files and checksum manifest from [GitHub Releases](https://github.com/fclaude/fclaude-packages/releases). With the GitHub CLI, run in a new download directory:

```sh
arch=$(uname -m)
if [ "$arch" = aarch64 ]; then checksum_arch=arm64; else checksum_arch=amd64; fi
gh release download packages-2026-10-29-2 --repo fclaude/fclaude-packages \
  --pattern "*.${arch}.rpm" --pattern "SHA256SUMS-linux-${checksum_arch}"
sha256sum --check --ignore-missing "SHA256SUMS-linux-${checksum_arch}"
sudo dnf install ./*.rpm
```

This installs all available tools for that architecture, resolving dependencies through Fedora's package manager. You can instead download selected files in a browser and install just those files with `sudo dnf install ./filename.rpm`.

These are unsigned local packages hosted on GitHub, not a configured signed DNF repository. To upgrade, download and verify a newer package set and repeat the local installation. To uninstall selected tools:

```sh
sudo dnf remove brote coigue hoot sqlite-explorer
```

Omit tools you did not install; aarch64 has no SQLite Explorer package.

## Optional integrations

Coigüe embeds Brote. Install the separate Brote package for standalone Scheme use or its optional language server. Other language servers are optional. Hoot's agent features need a separately installed `opencode` or `pi`.

## Validation and maintenance

CI tests native Intel and Apple Silicon Mac installs, CLI behavior, pseudo-terminal editing and Git review, the universal app bundle, and uninstall. Native amd64 and arm64 Linux jobs test installation, CLI behavior, and uninstall in Ubuntu 24.04 and Fedora 44 containers. SQLite Explorer's Linux shared-library resolution and desktop entry are checked on amd64. CI does not launch the GUI or prove Gatekeeper acceptance.

Brote's Linux packages are assembled here from verified static upstream binaries. Other Linux packages are reused byte-for-byte from upstream. Licenses and Coigüe's third-party notices are preserved. See [MAINTAINING.md](MAINTAINING.md) for release updates and checks.

## Adoption signals

[Homebrew's public aggregate reports](https://formulae.brew.sh/analytics/) and [analytics API](https://formulae.brew.sh/docs/api/) provide install trends for public third-party taps; look for `fclaude/fclaude-packages/` entries. Results depend on users' analytics settings and report publication. GitHub release asset counts provide another download signal; Mac CLI installs download upstream release assets.

These are events, not unique people or active users. This repository adds no application telemetry. CI sets `HOMEBREW_NO_ANALYTICS=1` so its validation does not contribute Homebrew install events.

## License

Package definitions and supporting scripts are [MIT licensed](LICENSE). Upstream tools retain their own licenses and notices, included in installed packages.
