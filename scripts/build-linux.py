#!/usr/bin/env python3
"""Verify upstream packages and build Brote/Nodwyn DEB/RPM from release binaries."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
from string import Template
import tarfile
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
NFPM_VERSION = "2.48.0"
NFPM_SHA256 = {
    "x86_64": "6d7f9a28b2f397934403950fcbba83f598b08d02edbe79a0815b3b4897341750",
    "arm64": "a9a75213763783b7669719e505474c748c5ad7dc66591a195619deb50f85c2f4",
}


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def fetch(url, expected, cache):
    destination = cache / url.rsplit("/", 1)[1]
    if destination.exists() and digest(destination) != expected:
        raise ValueError(f"cached checksum mismatch: {destination}")
    if not destination.exists():
        request = urllib.request.Request(url, headers={"User-Agent": "fclaude-packages"})
        temporary = destination.with_suffix(destination.suffix + ".partial")
        try:
            with urllib.request.urlopen(request, timeout=60) as response, temporary.open("wb") as output:
                shutil.copyfileobj(response, output)
            if digest(temporary) != expected:
                raise ValueError(f"download checksum mismatch: {url}")
            temporary.replace(destination)
        finally:
            temporary.unlink(missing_ok=True)
    return destination


def extract_file(archive, member, destination, executable=False):
    with tarfile.open(archive, "r:gz") as source:
        info = source.getmember(member)
        if not info.isfile():
            raise ValueError(f"not a regular file in archive: {member}")
        with source.extractfile(info) as stream, destination.open("wb") as output:
            shutil.copyfileobj(stream, output)
    destination.chmod(0o755 if executable else 0o644)
    os.utime(destination, (1793059200, 1793059200))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--arch", choices=["amd64", "arm64"], required=True)
    parser.add_argument("--output", type=Path, default=ROOT / "dist/linux")
    parser.add_argument("--cache", type=Path, default=ROOT / ".cache/downloads")
    args = parser.parse_args()
    if platform.system() != "Linux":
        parser.error("build Linux packages on Linux; no cross-platform installer is used")
    cache = args.cache.resolve()
    cache.mkdir(parents=True, exist_ok=True)
    output = args.output.resolve() / args.arch
    for kind in ["deb", "rpm"]:
        (output / kind).mkdir(parents=True, exist_ok=True)

    manifest = json.loads((ROOT / "packaging/linux/releases.json").read_text())
    if manifest["schema"] != 1:
        raise ValueError("unsupported manifest schema")
    artifacts = []
    for asset in manifest["assets"]:
        if asset["arch"] != args.arch:
            continue
        archive = fetch(asset["url"], asset["sha256"], cache)
        if asset["package"] not in ["brote", "nodwyn"]:
            destination = output / asset["format"] / archive.name
            shutil.copyfile(archive, destination)
            artifacts.append(destination)
            continue

        host = {"aarch64": "arm64", "x86_64": "x86_64"}.get(platform.machine())
        if host not in NFPM_SHA256:
            raise ValueError(f"unsupported packaging host: {platform.machine()}")
        nfpm_archive = fetch(
            f"https://github.com/goreleaser/nfpm/releases/download/v{NFPM_VERSION}/"
            f"nfpm_{NFPM_VERSION}_Linux_{host}.tar.gz", NFPM_SHA256[host], cache,
        )
        project = asset["package"]
        with tempfile.TemporaryDirectory(prefix=f"{project}-package-") as directory:
            stage = Path(directory)
            nfpm = stage / "nfpm"
            extract_file(nfpm_archive, "nfpm", nfpm, executable=True)
            if project == "brote":
                prefix = f"brote_{asset['version']}_linux_{args.arch}/"
                names = ["brote", "brote-lsp", "LICENSE"]
            else:
                prefix = ""
                names = ["nodwyn", "nodwyn-egress", "LICENSE", "NOTICE"]
                (stage / "github-release.json").write_text(json.dumps(asset, indent=2) + "\n")
                shutil.copyfile(ROOT / "packaging/nodwyn/com.nodwyn.app.desktop",
                                stage / "com.nodwyn.app.desktop")
            for name in names:
                extract_file(archive, prefix + name, stage / name,
                             name not in ["LICENSE", "NOTICE"])
            env = dict(os.environ, PACKAGE_ARCH=args.arch, SOURCE_DATE_EPOCH="1793059200")
            env[project.upper() + "_VERSION"] = asset["version"]
            env[project.upper() + "_STAGE"] = str(stage)
            config = stage / "nfpm.yaml"
            config.write_text(Template((ROOT / f"packaging/{project}/nfpm.yaml").read_text()).substitute(env))
            rpm_arch = "x86_64" if args.arch == "amd64" else "aarch64"
            for kind, filename in [
                ("deb", f"{project}_{asset['version']}-1_{args.arch}.deb"),
                ("rpm", f"{project}-{asset['version']}-1.{rpm_arch}.rpm"),
            ]:
                destination = output / kind / filename
                subprocess.run([
                    str(nfpm), "package", "--config", str(config),
                    "--packager", kind, "--target", str(destination),
                ], env=env, check=True)
                artifacts.append(destination)

    checksum_path = output / f"SHA256SUMS-linux-{args.arch}"
    checksum_path.write_text("".join(f"{digest(p)}  {p.name}\n" for p in sorted(artifacts)))
    print(f"Prepared {len(artifacts)} packages for {args.arch}: {output}")


if __name__ == "__main__":
    main()
