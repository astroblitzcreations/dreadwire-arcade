#!/usr/bin/env python3
"""Install the curated PSX batch with quick cue-reference checks."""

import re
import shutil
import subprocess
from pathlib import Path

STAGE = Path("/home/pi/rom-import-disc")
DEST = Path("/home/pi/RetroPie/roms/psx")
DEST.mkdir(parents=True, exist_ok=True)

# Copy root BIN/CUE sets. Only cue sheets appear in EmulationStation.
for item in (STAGE / "psx-root").iterdir():
    if item.suffix.lower() in {".bin", ".cue"}:
        shutil.copy2(item, DEST / item.name)

cue_failures = []
for cue in DEST.glob("*.cue"):
    text = cue.read_text(encoding="utf-8-sig", errors="replace")
    tracks = re.findall(r'^\s*FILE\s+"([^"]+)"', text, flags=re.I | re.M)
    missing = [name for name in tracks if not (cue.parent / name).is_file()]
    if missing:
        cue_failures.append(f"{cue.name}: missing {', '.join(missing)}")

# Prefer the clearer BIN/CUE versions of these duplicate PBP titles.
skip_pbp = {"02. Legend of sacred sword legend of mana.PBP", "10. Rockman X6.PBP"}
for item in (STAGE / "psx-pbp").glob("*.PBP"):
    if item.name not in skip_pbp:
        shutil.copy2(item, DEST / item.name)

# Extract the three FFVII discs, then create one playlist menu entry.
ff7_dir = DEST / ".ff7-discs"
ff7_dir.mkdir(exist_ok=True)
for archive in sorted((STAGE / "ff7").glob("*.7z")):
    subprocess.run(["7z", "x", "-y", f"-o{ff7_dir}", str(archive)], check=True)

disc_entries = sorted(
    list(ff7_dir.glob("*.cue")) + list(ff7_dir.glob("*.chd")) + list(ff7_dir.glob("*.pbp"))
)
if disc_entries:
    playlist = DEST / "Final Fantasy VII.m3u"
    playlist.write_text("\n".join(f".ff7-discs/{p.name}" for p in disc_entries) + "\n")

print(f"PSX cue sheets: {len(list(DEST.glob('*.cue')))}")
print(f"PSX PBP files: {len(list(DEST.glob('*.PBP')))}")
print(f"FFVII discs: {len(disc_entries)}")
print(f"Cue failures: {len(cue_failures)}")
for failure in cue_failures:
    print(f"  {failure}")
