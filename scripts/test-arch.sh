#!/usr/bin/env bash
# Run only in a disposable Arch container, with the checkout mounted read-only.
set -euo pipefail
pacman -Syu --noconfirm --needed base-devel git ca-certificates gtk3 webkit2gtk-4.1 \
  libayatana-appindicator libnotify xdg-utils hicolor-icon-theme desktop-file-utils
useradd --create-home builder
build=$(mktemp -d)
cp /workspace/packaging/nodwyn/PKGBUILD "$build/PKGBUILD"
cp /workspace/.cache/downloads/nodwyn-linux-amd64-desktop.tar.gz "$build/"
chown -R builder:builder "$build"
cd "$build"
runuser -u builder -- makepkg --nodeps --nocheck --cleanbuild
package=nodwyn-0.1.13-1-x86_64.pkg.tar.zst
pacman -U --noconfirm "$package"
for binary in nodwyn nodwyn-egress; do
  expected=$(tar -xOf nodwyn-linux-amd64-desktop.tar.gz "$binary" | sha256sum | cut -d ' ' -f 1)
  printf '%s  /usr/bin/%s\n' "$expected" "$binary" | sha256sum --check -
done
test "$(nodwyn version)" = 'nodwyn fb1e9b5581883bea5307d174f4621425875c3116'
desktop-file-validate /usr/share/applications/com.nodwyn.app.desktop
test -s /usr/share/icons/hicolor/scalable/apps/com.nodwyn.app.svg
test -s /usr/share/icons/hicolor/512x512/apps/com.nodwyn.app.png
ldd /usr/bin/nodwyn >linkage.txt
cat linkage.txt
if grep -q 'not found' linkage.txt; then exit 1; fi
grep -q libwebkit2gtk-4.1 linkage.txt
pacman -R --noconfirm nodwyn
test ! -e /usr/bin/nodwyn
test ! -e /usr/share/applications/com.nodwyn.app.desktop
test ! -e /usr/share/icons/hicolor/scalable/apps/com.nodwyn.app.svg
mkdir -p /packages/arch
cp "$package" /packages/arch/
cd /packages/arch
sha256sum "$package" >../SHA256SUMS-archlinux-x86_64
