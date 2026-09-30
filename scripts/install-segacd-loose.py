#!/usr/bin/env python3
"""Build Sega CD cue sheets/playlists from loose ISO and MP3 tracks."""

import re
import shutil
from pathlib import Path

STAGE = Path("/home/pi/sega-cd-loose")
DEST = Path("/home/pi/RetroPie/roms/segacd")
DISCS = DEST / ".discs"
DISCS.mkdir(parents=True, exist_ok=True)


def natural(path: Path):
    return [int(piece) if piece.isdigit() else piece.lower() for piece in re.split(r"(\d+)", path.name)]


groups: dict[str, list[Path]] = {}
for image in sorted(list(STAGE.glob("*.iso")) + list(STAGE.glob("*.ISO"))):
    base = image.stem
    folder = DISCS / base
    folder.mkdir(parents=True, exist_ok=True)
    installed_image = folder / image.name
    shutil.move(str(image), installed_image)

    audio = sorted(
        [p for p in STAGE.iterdir() if p.suffix.lower() == ".mp3" and (p.stem == base or p.stem.startswith(base + " "))],
        key=natural,
    )
    for track in audio:
        shutil.move(str(track), folder / track.name)

    source_cue = next(iter(STAGE.glob(base + ".cue")), None)
    if source_cue:
        cue = folder / source_cue.name
        shutil.move(str(source_cue), cue)
    else:
        cue = folder / f"{base}.cue"
        cue_lines = [f'FILE "{installed_image.name}" BINARY', "  TRACK 01 MODE1/2048", "    INDEX 01 00:00:00"]
        for sequence, track in enumerate(audio, 2):
            cue_lines.extend([f'FILE "{track.name}" MP3', f"  TRACK {sequence:02d} AUDIO", "    INDEX 01 00:00:00"])
        cue.write_text("\n".join(cue_lines) + "\n", encoding="utf-8")

    title = re.sub(r"\s+(?:disk|disc)\s*\d+\s*$", "", base, flags=re.I)
    groups.setdefault(title, []).append(cue)

for title, cue_files in groups.items():
    playlist = DEST / f"{title}.m3u"
    playlist.write_text("\n".join(c.relative_to(DEST).as_posix() for c in sorted(cue_files)) + "\n", encoding="utf-8")
    print(f"PLAYLIST {playlist.name}: {len(cue_files)} disc(s)")

print(f"Sega CD menu entries: {len(groups)}")
