#!/usr/bin/env bash
# Verify the installed desktop entry on a disposable X11 display.
set -euo pipefail

launcher=/usr/share/applications/com.fclaude.dinoscript.desktop
desktop-file-validate "$launcher"
grep -Fxq 'Icon=com.fclaude.dinoscript' "$launcher"
test -s /usr/share/icons/hicolor/128x128/apps/com.fclaude.dinoscript.png
test -s /usr/share/icons/hicolor/512x512@2/apps/com.fclaude.dinoscript.png
test -s /usr/share/dinoscript/Dinoscript-with-Pip.pdf

scratch=$(mktemp -d)
display_pid=
cleanup() {
    if [[ -n "$display_pid" ]] && kill -0 "$display_pid" 2>/dev/null; then
        kill "$display_pid"
        wait "$display_pid" || true
    fi
    rm -rf -- "$scratch"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

Xvfb -displayfd 3 -screen 0 1280x800x24 -nolisten tcp -ac 3>"$scratch/display" &
display_pid=$!
for ((attempt = 0; attempt < 100; attempt++)); do
    if [[ -s "$scratch/display" ]]; then break; fi
    kill -0 "$display_pid"
    sleep 0.1
done
test -s "$scratch/display"
export DISPLAY=":$(cat "$scratch/display")"
export XDG_CONFIG_HOME="$scratch/config"
export LIBGL_ALWAYS_SOFTWARE=1

gio launch "$launcher"
window=$(timeout 20s xdotool search --sync --limit 1 --onlyvisible --class '^com\.fclaude\.dinoscript$')
[[ "$(xdotool getwindowname "$window")" == *Dinoscript ]]
xdotool windowfocus --sync "$window" key ctrl+q
for ((attempt = 0; attempt < 50; attempt++)); do
    if ! xdotool getwindowname "$window" >/dev/null 2>&1; then exit 0; fi
    sleep 0.1
done
echo "Dinoscript did not close after Ctrl+Q" >&2
exit 1
