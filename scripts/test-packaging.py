#!/usr/bin/env python3
"""Offline checks for package integrity boundaries used before publication."""

import hashlib
import importlib.util
import io
from pathlib import Path
import tarfile
import tempfile
import unittest


def module(filename):
    spec = importlib.util.spec_from_file_location(filename, Path(__file__).with_name(filename))
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


build = module("build-linux.py")
publish = module("publish-linux.py")


class IntegrityTests(unittest.TestCase):
    def test_archive_symlink_is_never_extracted(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with tarfile.open(root / "archive.tar.gz", "w:gz") as archive:
                member = tarfile.TarInfo("nodwyn")
                member.type = tarfile.SYMTYPE
                member.linkname = "/etc/passwd"
                archive.addfile(member)
            with self.assertRaisesRegex(ValueError, "not a regular file"):
                build.extract_file(root / "archive.tar.gz", "nodwyn", root / "binary")
            self.assertFalse((root / "binary").exists())

    def test_archive_executable_bytes_and_mode_are_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with tarfile.open(root / "archive.tar.gz", "w:gz") as archive:
                member = tarfile.TarInfo("nodwyn-egress")
                member.size = 4
                archive.addfile(member, io.BytesIO(b"\x7fELF"))
            build.extract_file(root / "archive.tar.gz", "nodwyn-egress", root / "binary", True)
            self.assertEqual((root / "binary").read_bytes(), b"\x7fELF")
            self.assertEqual((root / "binary").stat().st_mode & 0o777, 0o755)

    def fixture(self, root):
        for arch, count in [("amd64", 10), ("arm64", 8)]:
            base = root / f"linux-{arch}"
            (base / "deb").mkdir(parents=True)
            entries = []
            for number in range(count):
                path = base / "deb" / f"fixture{number}_{arch}.deb"
                path.write_bytes(b"verified package")
                entries.append(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}\n")
            (base / f"SHA256SUMS-linux-{arch}").write_text("".join(entries))

    def test_publisher_accepts_both_complete_verified_inventories(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            self.assertEqual(len(publish.inventory(root)), 20)

    def test_publisher_rejects_modified_package(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.fixture(root)
            next((root / "linux-amd64/deb").iterdir()).write_bytes(b"modified")
            with self.assertRaisesRegex(ValueError, "checksum mismatch"):
                publish.inventory(root)

    def test_publisher_rejects_missing_architecture(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(FileNotFoundError):
                publish.inventory(Path(directory))


if __name__ == "__main__":
    unittest.main()
