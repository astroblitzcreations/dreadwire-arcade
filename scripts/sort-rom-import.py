#!/usr/bin/env python3
"""Validate, deduplicate, and sort the cabinet ROM import staging tree."""

from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
from pathlib import Path

SRC = Path("/home/pi/rom-import")
ROMS = Path("/home/pi/RetroPie/roms")
REPORT = Path("/home/pi/rom-import-report.txt")

BAD_MARKERS = re.compile(
    r"(?:\bhack\b|\[h\d*\]|\[b\d*\]|\[o\d*\]|\[t[+\-]?\d*\]|"
    r"\(beta\)|\(proto(?:type)?\)|\(sample\)|trainer)", re.I
)
TAGS = re.compile(r"\s*[\[(][^\])]*[\])]\s*")
NON_ALNUM = re.compile(r"[^a-z0-9]+")

lines: list[str] = []
copied = 0
duplicates = 0
excluded = 0
failures: list[str] = []


def log(message: str) -> None:
    print(message, flush=True)
    lines.append(message)


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def title_key(path: Path) -> str:
    name = TAGS.sub(" ", path.stem).lower()
    name = re.sub(r"\b(?:rev(?:ision)?|v)\s*[0-9.]+\b", "", name)
    return NON_ALNUM.sub("", name)


def validate_archives() -> set[Path]:
    archives = sorted(list(SRC.rglob("*.zip")) + list(SRC.rglob("*.7z")))
    good: set[Path] = set()
    log(f"ARCHIVE VALIDATION: {len(archives)} files")
    for index, archive in enumerate(archives, 1):
        result = subprocess.run(
            ["7z", "t", "-bso0", "-bsp0", "--", str(archive)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if result.returncode == 0:
            good.add(archive)
        else:
            failures.append(str(archive.relative_to(SRC)))
        if index % 250 == 0:
            log(f"  tested {index}/{len(archives)}")
    log(f"ARCHIVES GOOD: {len(good)}; FAILED: {len(failures)}")
    return good


def copy_sets(good_archives: set[Path]) -> None:
    global copied, duplicates, excluded
    mappings = [
        ("nes", ["NES", "FC"], {".nes"}),
        ("snes", ["SNES", "SFC"], {".smc", ".sfc"}),
        ("gb", ["gb"], {".gb"}),
        ("gbc", ["gbc"], {".gbc"}),
        ("gba", ["gba"], {".gba"}),
        ("gamegear", ["gg"], {".gg"}),
        ("mastersystem", ["MS"], {".zip"}),
        ("n64", ["n64"], {".n64", ".v64", ".z64", ".zip"}),
        ("neogeo", ["neogeo"], {".zip"}),
        ("ngp", ["NGP"], {".ngp", ".ngf"}),
        ("ngpc", ["NGP"], {".ngc"}),
        ("pcengine", ["PCE"], {".pce"}),
        ("wonderswan", ["WS"], {".ws"}),
        ("wonderswancolor", ["WS"], {".wsc"}),
        ("megadrive", ["genesis", "MD", "Sega"], {".zip", ".bin", ".smd", ".md"}),
    ]
    for system, folders, extensions in mappings:
        destination = ROMS / system
        destination.mkdir(parents=True, exist_ok=True)
        seen_titles: set[str] = set()
        seen_hashes: set[str] = set()
        for existing in destination.iterdir():
            if existing.is_file():
                seen_titles.add(title_key(existing))
        for folder in folders:
            root = SRC / folder
            if not root.exists():
                continue
            for source in sorted(root.rglob("*")):
                if not source.is_file() or source.suffix.lower() not in extensions:
                    continue
                if source.suffix.lower() in {".zip", ".7z"} and source not in good_archives:
                    excluded += 1
                    continue
                if BAD_MARKERS.search(source.name):
                    excluded += 1
                    continue
                key = title_key(source)
                file_hash = digest(source)
                if key in seen_titles or file_hash in seen_hashes:
                    duplicates += 1
                    continue
                target = destination / source.name
                if target.exists():
                    target = destination / f"{source.stem} ({folder}){source.suffix}"
                shutil.copy2(source, target)
                seen_titles.add(key)
                seen_hashes.add(file_hash)
                copied += 1
        log(f"SORTED {system}: {len(seen_titles)} menu titles")


def extract_goodmerged(good_archives: set[Path]) -> None:
    """Extract one clean preferred dump from each GoodMerged title archive."""
    global copied, duplicates, excluded
    root = SRC / "FULL Sega Genesis -- Mega Drive -- 32X (GoodGen 3.00)[GoodMerged]"
    destination = ROMS / "megadrive"
    seen = {title_key(item) for item in destination.iterdir() if item.is_file()}
    added = 0
    for archive in sorted(root.glob("*.7z")):
        if archive not in good_archives or BAD_MARKERS.search(archive.name):
            excluded += 1
            continue
        key = title_key(archive)
        if key in seen:
            duplicates += 1
            continue
        listing = subprocess.run(
            ["7z", "l", "-slt", "--", str(archive)], capture_output=True, text=True
        ).stdout.splitlines()
        members = [line[7:] for line in listing if line.startswith("Path = ")]
        members = [m for m in members if Path(m).suffix.lower() in {".bin", ".gen", ".md", ".smd"}]
        clean = [m for m in members if not BAD_MARKERS.search(m)]
        if not clean:
            excluded += 1
            continue
        def rank(name: str) -> tuple[int, int, str]:
            good_dump = 0 if "[!]" in name else 1
            region = 0 if re.search(r"\((?:U|USA|W|World)\)", name, re.I) else 1 if re.search(r"\((?:E|Europe)\)", name, re.I) else 2
            return good_dump, region, name.lower()
        member = min(clean, key=rank)
        suffix = Path(member).suffix.lower() or ".bin"
        target = destination / f"{archive.stem}{suffix}"
        with target.open("wb") as output:
            result = subprocess.run(["7z", "e", "-so", "--", str(archive), member], stdout=output)
        if result.returncode != 0 or target.stat().st_size == 0:
            target.unlink(missing_ok=True)
            failures.append(str(archive.relative_to(SRC)) + " [extract]")
            continue
        seen.add(key)
        copied += 1
        added += 1
    log(f"GOODMERGED: extracted {added} additional clean Mega Drive titles")


def copy_arcade(good_archives: set[Path]) -> None:
    global copied, duplicates, excluded
    destination = ROMS / "arcade"
    destination.mkdir(parents=True, exist_ok=True)
    hashes: set[str] = set()
    for folder in ("FBA", "cps", "maime"):
        root = SRC / folder
        for source in sorted(root.glob("*.zip")):
            if source not in good_archives:
                excluded += 1
                continue
            target = destination / source.name.lower()
            file_hash = digest(source)
            if target.exists() or file_hash in hashes:
                duplicates += 1
                continue
            shutil.copy2(source, target)
            hashes.add(file_hash)
            copied += 1
    log(f"SORTED arcade: {len(list(destination.glob('*.zip')))} archives")


def main() -> None:
    good = validate_archives()
    copy_sets(good)
    extract_goodmerged(good)
    copy_arcade(good)
    log(f"COPIED: {copied}")
    log(f"DUPLICATES SKIPPED: {duplicates}")
    log(f"HACKS/BAD/UNSUPPORTED SKIPPED: {excluded}")
    if failures:
        log("FAILURES:")
        lines.extend(f"  {item}" for item in failures)
    REPORT.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
