#!/usr/bin/env python3
"""Extract Sega CD archives into hidden folders and create clean playlists."""

import re
import shutil
import subprocess
from pathlib import Path

STAGE = Path("/home/pi/sega-cd-import")
DEST = Path("/home/pi/RetroPie/roms/segacd")
DISCS = DEST / ".discs"
DISCS.mkdir(parents=True, exist_ok=True)

groups: dict[str, list[Path]] = {}

for archive in sorted(STAGE.glob("*.rar")):
    folder = DISCS / archive.stem
    folder.mkdir(parents=True, exist_ok=True)
    subprocess.run(["7z", "x", "-y", f"-o{folder}", str(archive)], check=True)
    candidates = []
    for extension in ("*.cue", "*.chd", "*.iso", "*.bin"):
        candidates.extend(folder.rglob(extension))
        candidates.extend(folder.rglob(extension.upper()))
        if candidates:
            break
    if not candidates:
        print(f"NO PLAYABLE IMAGE: {archive.name}")
        continue
    title = re.sub(r"\s+(?:disk|disc)\s*\d+\s*$", "", archive.stem, flags=re.I)
    groups.setdefault(title, []).append(candidates[0])

for title, entries in groups.items():
    playlist = DEST / f"{title}.m3u"
    relative = [entry.relative_to(DEST).as_posix() for entry in sorted(entries)]
    playlist.write_text("\n".join(relative) + "\n", encoding="utf-8")
    print(f"PLAYLIST {playlist.name}: {len(entries)} disc(s)")

print(f"Sega CD menu entries: {len(groups)}")
