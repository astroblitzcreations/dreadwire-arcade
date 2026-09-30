#!/usr/bin/env python3
"""Install the latest Dreadwire Arcade GitHub release with rollback."""

import json
import hashlib
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request
from pathlib import Path

CONFIG = Path("/etc/dreadwire/update.json")
INSTALL_ROOT = Path("/opt/dreadwire")
BACKUPS = Path("/var/backups/dreadwire")


def main():
    config = json.loads(CONFIG.read_text())
    repo = config["repository"].strip("/")
    req = urllib.request.Request(f"https://api.github.com/repos/{repo}/releases/latest", headers={"Accept":"application/vnd.github+json","User-Agent":"Dreadwire-Arcade-Updater/1.0"})
    with urllib.request.urlopen(req, timeout=20) as source:
        release = json.load(source)
    asset = next((a for a in release.get("assets", []) if a.get("name") == "dreadwire-arcade-update.tar.gz"), None)
    checksum_asset = next((a for a in release.get("assets", []) if a.get("name") == "dreadwire-arcade-update.tar.gz.sha256"), None)
    if not asset:
        raise RuntimeError("Release has no dreadwire-arcade-update.tar.gz asset")
    if not checksum_asset:
        raise RuntimeError("Release has no SHA-256 checksum")
    with tempfile.TemporaryDirectory(prefix="dreadwire-update-") as temp_name:
        temp = Path(temp_name); archive = temp / "update.tar.gz"; staged = temp / "staged"; staged.mkdir()
        urllib.request.urlretrieve(asset["browser_download_url"], archive)
        checksum_file = temp / "update.sha256"
        urllib.request.urlretrieve(checksum_asset["browser_download_url"], checksum_file)
        expected = checksum_file.read_text(encoding="utf-8").split()[0].lower()
        actual = hashlib.sha256(archive.read_bytes()).hexdigest()
        if actual != expected:
            raise RuntimeError("Update archive checksum verification failed")
        with tarfile.open(archive, "r:gz") as package:
            for member in package.getmembers():
                destination = (staged / member.name).resolve()
                if staged.resolve() not in destination.parents and destination != staged.resolve():
                    raise RuntimeError("Unsafe path in update package")
            package.extractall(staged)
        installer = staged / "install.sh"
        if not installer.is_file(): raise RuntimeError("Update package has no installer")
        subprocess.run(["bash", str(installer)], check=True, cwd=staged)
    subprocess.run(["systemctl", "restart", "dreadwire-companion.service"], check=False)
    subprocess.run(["systemctl", "restart", "getty@tty1.service"], check=False)


if __name__ == "__main__":
    main()
