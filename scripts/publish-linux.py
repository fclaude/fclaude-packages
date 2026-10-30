#!/usr/bin/env python3
"""Publish only the package bytes that passed this workflow's native checks."""

import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import urllib.error
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def inventory(directory):
    files = {}
    for arch in ["amd64", "arm64"]:
        checksum = directory / f"linux-{arch}" / f"SHA256SUMS-linux-{arch}"
        if checksum.is_symlink():
            raise ValueError("checksum manifest must be a regular file")
        entries = {}
        for line in checksum.read_text().splitlines():
            match = re.fullmatch(r"([0-9a-f]{64})  ([A-Za-z0-9_.+-]+\.(deb|rpm))", line)
            if not match or match[2] in entries:
                raise ValueError("invalid/duplicate package checksum")
            entries[match[2]] = match[1]
        expected_count = 10 if arch == "amd64" else 8
        if len(entries) != expected_count:
            raise ValueError("package inventory is incomplete")
        for name, expected in entries.items():
            kind = name.rsplit(".", 1)[1]
            path = checksum.parent / kind / name
            if path.is_symlink() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
                raise ValueError("package checksum mismatch: " + name)
            if name in files:
                raise ValueError("duplicate package name across architectures")
            files[name] = path
        files[checksum.name] = checksum
    return files


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def main():
    repository = os.environ["GITHUB_REPOSITORY"]
    if repository != "fclaude/fclaude-packages" or os.environ["GITHUB_REF"] != "refs/heads/main":
        raise ValueError("publication is limited to the canonical main branch")
    commit = os.environ["GITHUB_SHA"]
    token = os.environ["GITHUB_TOKEN"]
    opener = urllib.request.build_opener(NoRedirect)

    def request(url, data=None, method="GET", content_type="application/json"):
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme != "https" or parsed.hostname not in ["api.github.com", "uploads.github.com"]:
            raise ValueError("unexpected publication endpoint")
        body = json.dumps(data).encode() if isinstance(data, dict) else data
        req = urllib.request.Request(url, data=body, method=method, headers={
            "Authorization": "Bearer " + token,
            "Content-Type": content_type,
            "Accept": "application/vnd.github+json",
            "User-Agent": "fclaude-packages",
        })
        with opener.open(req, timeout=180) as response:
            payload = response.read()
            return json.loads(payload) if payload else None

    base = f"https://api.github.com/repos/{repository}"
    if request(base + "/git/ref/heads/main")["object"]["sha"] != commit:
        raise ValueError("a newer packaging commit superseded this run")
    files = inventory(ROOT / "release-artifacts")
    date = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")
    tag = f"packages-{date}-{os.environ['GITHUB_RUN_NUMBER']}"
    # The unique run tag refuses replacement of an already published package set.
    try:
        existing = request(base + "/releases/tags/" + tag)
    except urllib.error.HTTPError as error:
        if error.code != 404:
            raise
        existing = None
    if existing:
        if not existing["draft"]:
            print("Package set already published: " + existing["html_url"])
            return
        # A retry may remove only its own draft, never a published release.
        request(base + "/releases/" + str(existing["id"]), method="DELETE")
    release = request(base + "/releases", {
        "tag_name": tag, "target_commitish": commit, "name": tag,
        "draft": True, "body": (ROOT / "packaging/linux/RELEASE_NOTES.md").read_text()
        + f"\n\nPackaging commit: `{commit}`. Native checks: "
        + f"https://github.com/{repository}/actions/runs/{os.environ['GITHUB_RUN_ID']}\n",
    }, "POST")
    upload = release["upload_url"].split("{", 1)[0]
    for name, path in sorted(files.items()):
        result = request(upload + "?" + urllib.parse.urlencode({"name": name}),
                         path.read_bytes(), "POST", "application/octet-stream")
        expected = "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()
        if result.get("digest") != expected or result["size"] != path.stat().st_size:
            raise ValueError("uploaded asset differs: " + name)
    assets = request(base + "/releases/" + str(release["id"]) + "/assets")
    if {item["name"] for item in assets} != set(files):
        raise ValueError("draft asset inventory differs")
    result = request(base + "/releases/" + str(release["id"]), {"draft": False}, "PATCH")
    print("Published " + result["html_url"])


if __name__ == "__main__":
    main()
