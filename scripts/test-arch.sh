#!/usr/bin/env bash
# Run only in a disposable Arch container, with the checkout mounted read-only.
set -euo pipefail
pacman -Syu --noconfirm --needed base-devel git ca-certificates gtk3 webkit2gtk-4.1 \
  libayatana-appindicator libnotify xdg-utils hicolor-icon-theme desktop-file-utils \
  glib2 xorg-server-xvfb xdotool
useradd --create-home builder
build=$(mktemp -d)
cp /workspace/packaging/nodwyn/PKGBUILD "$build/PKGBUILD"
cp /workspace/.cache/downloads/nodwyn-linux-amd64-desktop.tar.gz "$build/"
chown -R builder:builder "$build"
cd "$build"
runuser -u builder -- makepkg --nodeps --nocheck --cleanbuild
package=nodwyn-0.1.18-1-x86_64.pkg.tar.zst
pacman -U --noconfirm "$package"
for binary in nodwyn nodwyn-egress; do
  expected=$(tar -xOf nodwyn-linux-amd64-desktop.tar.gz "$binary" | sha256sum | cut -d ' ' -f 1)
  printf '%s  /usr/bin/%s\n' "$expected" "$binary" | sha256sum --check -
done
test "$(nodwyn version)" = 'nodwyn 6bb19a4619958c2b4fde0a760fb30ec785eaf90b'
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
dinoscript=(dinoscript-*-x86_64.pkg.tar.zst)
test "${#dinoscript[@]}" -eq 1
test -f "${dinoscript[0]}"
pacman -U --noconfirm "${dinoscript[0]}"
bash /workspace/scripts/test-dinoscript.sh
for file in LICENSE NOTICE THIRD-PARTY-NOTICES.txt; do
  test -s "/usr/share/licenses/dinoscript/$file"
done
pacman -R --noconfirm dinoscript
test ! -e /usr/bin/dinoscript
test ! -e /usr/share/applications/com.fclaude.dinoscript.desktop
test ! -e /usr/share/icons/hicolor/128x128/apps/com.fclaude.dinoscript.png
test ! -e /usr/share/icons/hicolor/512x512@2/apps/com.fclaude.dinoscript.png
test ! -e /usr/share/dinoscript/Dinoscript-with-Pip.pdf
sha256sum "${dinoscript[0]}" "$package" >../SHA256SUMS-archlinux-x86_64
