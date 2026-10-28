# Francisco's Homebrew tap

[![Validate tap](https://github.com/fclaude/homebrew-tap/actions/workflows/validate.yml/badge.svg)](https://github.com/fclaude/homebrew-tap/actions/workflows/validate.yml)

Install my tools on macOS with [Homebrew](https://brew.sh). This tap supports native Intel and Apple Silicon installations.

| Package | Version | What it installs |
| --- | --- | --- |
| [Brote](https://github.com/fclaude/brote) | 0.3.0 | `brote` Scheme interpreter and `brote-lsp` language server |
| [Coigüe](https://github.com/fclaude/coigue) | 0.2.3 | `coigue` modal terminal editor, with embedded Brote |
| [Hoot](https://github.com/fclaude/hoot) | 0.1.2 | `hoot` terminal UI for reviewing Git changes |
| [SQLite Explorer](https://github.com/fclaude/sqlite-explorer) | 0.2.1 | `sqlite-explorer.app`, a universal desktop app |

## Install

```sh
brew tap fclaude/tap
brew install fclaude/tap/brote fclaude/tap/coigue fclaude/tap/hoot
brew install --cask fclaude/tap/sqlite-explorer
```

Each command can also be used independently. Fully qualified package names automatically add the tap when needed.

The three command-line tools build from pinned source archives. Homebrew installs Go or Rust as needed; initial installation takes longer than downloading a prebuilt binary. This tap does not publish bottles yet. Use a macOS release supported by Homebrew and its build tools. SQLite Explorer itself requires macOS 12 or newer.

```sh
brote -e '(+ 20 22)'
coigue notes.txt
hoot --demo
open -a /Applications/sqlite-explorer.app
```

Coigüe embeds the Brote interpreter. Install the separate Brote package for standalone Scheme use or its optional language server. Other language servers are optional. Hoot installs Git as a dependency; its agent features need a separately installed `opencode` or `pi`.

SQLite Explorer 0.2.1 is ad-hoc signed and is not notarized by Apple. macOS Gatekeeper may block its first launch. See the project's [signing notes](https://github.com/fclaude/sqlite-explorer/blob/v0.2.1/docs/RELEASING.md#macos-signing). The cask preserves Homebrew's normal quarantine behavior.

## Upgrade

```sh
brew update
brew outdated
brew upgrade fclaude/tap/brote fclaude/tap/coigue fclaude/tap/hoot
brew upgrade --cask fclaude/tap/sqlite-explorer
```

## Uninstall

```sh
brew uninstall fclaude/tap/brote fclaude/tap/coigue fclaude/tap/hoot
brew uninstall --cask fclaude/tap/sqlite-explorer
brew untap fclaude/tap
```

Only uninstall the packages you installed. Uninstalling does not delete your documents, databases, or application preferences.

## Maintenance and validation

See [MAINTAINING.md](MAINTAINING.md) for release updates, checksum verification, local checks, and the CI coverage. CI builds and tests both Mac architectures, exercises Coigüe and Hoot in real pseudo-terminals, and checks the universal SQLite Explorer bundle. It does not launch the GUI or prove Gatekeeper acceptance.

## Adoption signals

[Homebrew's public aggregate reports](https://formulae.brew.sh/analytics/) and [analytics API](https://formulae.brew.sh/docs/api/) can provide install trends for public third-party taps; look for `fclaude/tap/` entries. Results depend on users' analytics settings and report publication. GitHub's release asset download counts provide another signal, especially for SQLite Explorer's DMG. Source archive installs do not increment the CLI release-binary asset counters.

These counts represent events, not unique people or active users. This tap adds no application telemetry. Its CI sets `HOMEBREW_NO_ANALYTICS=1` so validation does not contribute Homebrew install events.

## License

Tap definitions and supporting scripts are [MIT licensed](LICENSE). Each upstream project retains its own license and notices; those are included in the installed packages.
