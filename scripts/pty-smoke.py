#!/usr/bin/env python3
"""Exercise installed terminal apps in isolated homes; standard library only."""

import errno
import fcntl
import os
from pathlib import Path
import pty
import select
import shutil
import struct
import subprocess
import tempfile
import termios
import time


def session(command, cwd, home, steps):
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 120, 0, 0))
    original = termios.tcgetattr(slave)
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / ".config"), TERM="xterm-256color")
    proc = subprocess.Popen(command, cwd=cwd, env=env, stdin=slave, stdout=slave, stderr=slave)
    output = bytearray()

    def drain(seconds=0.3):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            if select.select([master], [], [], 0.02)[0]:
                try:
                    chunk = os.read(master, 65536)
                except OSError as error:
                    if error.errno == errno.EIO:
                        break
                    raise
                if not chunk:
                    break
                output.extend(chunk)

    try:
        drain(1)
        assert proc.poll() is None, output.decode(errors="replace")
        for keys in steps:
            os.write(master, keys)
            drain()
        deadline = time.monotonic() + 10
        while proc.poll() is None and time.monotonic() < deadline:
            drain(0.1)
        assert proc.poll() == 0, output.decode(errors="replace")
        drain()
        restored = termios.tcgetattr(slave)
        # macOS may transiently set PENDIN while replaying input after raw mode.
        for settings in (original, restored):
            settings[3] &= ~getattr(termios, "PENDIN", 0)
        assert original == restored, "terminal settings were not restored"
        assert b"\x1b[?1049l" in output, "alternate screen was not restored"
        return bytes(output)
    finally:
        if proc.poll() is None:
            proc.kill()
        proc.wait()
        os.close(master)
        os.close(slave)


def main():
    coigue = shutil.which("coigue")
    hoot = shutil.which("hoot")
    assert coigue and hoot, "install coigue and hoot first"
    with tempfile.TemporaryDirectory(prefix="tap-pty-") as directory:
        root = Path(directory)
        home = root / "home"
        home.mkdir()
        document = root / "fixture.txt"
        document.write_text("original\n", encoding="utf-8")
        session([coigue, str(document)], root, home, [b"iHomebrew ", b"\x1b", b":wq\r"])
        assert document.read_text(encoding="utf-8") == "Homebrew original\n"
        session([coigue, str(document)], root, home, [b":q\r"])
        print("Coigue: edit, save, reopen, quit, and terminal restoration passed")

        repo = root / "repo"
        repo.mkdir()
        subprocess.run(["git", "init", "-q", str(repo)], check=True)
        (repo / "fixture.txt").write_text("tap smoke fixture\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(repo), "add", "fixture.txt"], check=True)
        subprocess.run([
            "git", "-C", str(repo), "-c", "user.name=Tap Test", "-c", "user.email=test@example.invalid",
            "-c", "commit.gpgsign=false", "commit", "-qm", "Fixture",
        ], check=True)
        (repo / "fixture.txt").write_text("changed fixture\n", encoding="utf-8")
        before = subprocess.check_output(["git", "-C", str(repo), "diff"])
        output = session([hoot, str(repo)], root, home, [b"q"])
        assert b"fixture.txt" in output, "Hoot did not render the changed file"
        assert subprocess.check_output(["git", "-C", str(repo), "diff"]) == before
        print("Hoot: Git diff rendering, quit, unchanged worktree, and terminal restoration passed")


if __name__ == "__main__":
    main()
