#!/usr/bin/env bash
# Run inside a disposable Ubuntu/Fedora container, with /packages and /workspace mounted read-only.
set -euo pipefail

format=${1:?usage: test-linux.sh deb|rpm amd64|arm64}
arch=${2:?usage: test-linux.sh deb|rpm amd64|arm64}
packages=(brote coigue hoot)
if [[ "${arch}" == amd64 ]]
then
  packages+=(sqlite-explorer)
fi

case "${format}" in
  deb)
    export DEBIAN_FRONTEND=noninteractive
    # Ubuntu's minimal container excludes docs by default; retain package notices for this check.
    printf 'path-include=/usr/share/doc/*\n' >/etc/dpkg/dpkg.cfg.d/zz-package-docs
    apt-get update -qq
    apt-get install -y --no-install-recommends python3 git binutils desktop-file-utils /packages/deb/*.deb
    dpkg-query -W "${packages[@]}"
    ;;
  rpm)
    dnf install -y python3 git binutils desktop-file-utils /packages/rpm/*.rpm
    rpm -V "${packages[@]}"
    ;;
  *)
    echo "unsupported format: ${format}" >&2
    exit 2
    ;;
esac

evaluation=$(brote -e '(+ 20 22)')
test "${evaluation}" = 42
brote-lsp --version
coigue --version
hoot --version
hoot --print-keymap >/tmp/hoot-keymap.md
grep -q Quit /tmp/hoot-keymap.md
test -f /usr/share/doc/brote/copyright
test -f /usr/share/doc/coigue/THIRD_PARTY_NOTICES.md
python3 /workspace/scripts/pty-smoke.py
python3 - <<'PY'
import json
import subprocess
messages = [
    {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}},
    {"jsonrpc": "2.0", "id": 2, "method": "shutdown"},
    {"jsonrpc": "2.0", "method": "exit"},
]
bodies = [json.dumps(message).encode() for message in messages]
data = b"".join(b"Content-Length: " + str(len(body)).encode() + b"\r\n\r\n" + body for body in bodies)
result = subprocess.run(["brote-lsp"], input=data, capture_output=True, check=True)
assert b"brote-lsp" in result.stdout
print("Brote LSP initialize/shutdown passed")
PY

if [[ "${arch}" == amd64 ]]
then
  test -x /usr/bin/sqlite-explorer
  desktop-file-validate /usr/share/applications/sqlite-explorer.desktop
  ldd /usr/bin/sqlite-explorer >/tmp/sqlite-explorer-linkage.txt
  cat /tmp/sqlite-explorer-linkage.txt
  if grep -q 'not found' /tmp/sqlite-explorer-linkage.txt
  then
    exit 1
  fi
  if [[ "${format}" == deb ]]
  then
    test -f /usr/share/doc/sqlite-explorer/copyright
  else
    test -f /usr/share/licenses/sqlite-explorer/LICENSE
  fi
fi

case "${format}" in
  deb) apt-get remove -y "${packages[@]}" ;;
  rpm) dnf remove -y "${packages[@]}" ;;
  *) exit 2 ;;
esac
hash -r
for package in brote brote-lsp coigue hoot
do
  if command -v "${package}"
  then
    echo "executable remains after uninstall: ${package}" >&2
    exit 1
  fi
done
if [[ "${arch}" == amd64 ]]
then
  test ! -e /usr/bin/sqlite-explorer
fi
echo "Install, functional checks, and uninstall passed: ${format} ${arch}"
