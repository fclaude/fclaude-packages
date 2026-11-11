Downloadable Ubuntu DEB, Fedora RPM and Nodwyn Arch Linux packages for Francisco's tools.

| Tool | Version | Linux architectures |
| --- | --- | --- |
| Brote | 0.9.1-1 | amd64 / x86_64, arm64 / aarch64 |
| Coigüe | 0.7.0-1 | amd64 / x86_64, arm64 / aarch64 |
| Nodwyn | 0.1.18-1 | amd64 / x86_64, arm64 / aarch64 |
| Hoot | 0.1.2-1 | amd64 / x86_64, arm64 / aarch64 |
| SQLite Explorer | 0.2.1 | amd64 / x86_64 only |

Nodwyn amd64 packages use its native GTK3/WebKitGTK 4.1 desktop release, with the matching GNOME launcher, hicolor icons and runtime dependencies. ARM64 DEB/RPM packages retain browser mode. The Arch x86_64 package is built with makepkg. All preserve the Linux MCP egress helper, Apache-2.0 license and NOTICE; DEB/RPM also retain source provenance. DEB/RPM cache hooks and Arch’s standard hooks refresh the desktop and icons. Installation does not start or restart a daemon. A running daemon must be deliberately upgraded and restarted before it can report the new account@host identity; older daemons show “identity unavailable”.

Brote packages include `brote` and `brote-lsp` and are assembled from checksum-verified upstream static binaries. Coigüe, Hoot and SQLite Explorer packages preserve the upstream release bytes. SHA256 manifests cover each architecture's DEB and RPM downloads.

The validation matrix installs, exercises and uninstalls packages natively on amd64 and ARM64 using Ubuntu 24.04 and Fedora 44 containers. SQLite Explorer's desktop entry and runtime shared-library resolution are checked on amd64; Nodwyn linkage, icons and desktop entries are checked too. Arch CI installs and removes its native package; GNOME GUI behaviour is not exercised. Hoot requires glibc 2.39 or newer, so its packages do not support Ubuntu 22.04.

These are unsigned local packages for `apt install ./file.deb` or `dnf install ./file.rpm`, hosted on GitHub. No signed APT/DNF repository or external hosting account is configured. See the README's Ubuntu and Fedora sections for architecture selection, checksum verification, installation and updates.

Mac users install the verified upstream binaries and universal app DMG through the Homebrew definitions in this same repository. CLI installs need no Go or Rust compiler and do not force a Homebrew Git upgrade. SQLite Explorer's Mac release is ad-hoc signed and unnotarized; Gatekeeper may block its first launch.
