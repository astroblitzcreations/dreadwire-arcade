#!/usr/bin/env python3
"""Validate user splash videos and build a Pi-friendly randomized playlist."""

import json
import random
import subprocess
from pathlib import Path

SOURCE = Path("/home/pi/RetroPie/splashscreens")
CACHE = SOURCE / ".converted"
PLAYLIST = Path("/etc/splashscreen.list")
VIDEO_EXTENSIONS = {".mp4", ".mkv", ".mov", ".avi", ".webm", ".mpg", ".mpeg"}


def probe(path):
    result = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "stream=codec_type,codec_name,pix_fmt,width,height", "-of", "json", str(path)],
        text=True, capture_output=True, timeout=20, check=False,
    )
    try:
        return json.loads(result.stdout).get("streams", [])
    except (ValueError, TypeError):
        return []


def compatible(streams):
    video = next((s for s in streams if s.get("codec_type") == "video"), {})
    audio = next((s for s in streams if s.get("codec_type") == "audio"), {})
    return video.get("codec_name") == "h264" and video.get("pix_fmt") == "yuv420p" and audio.get("codec_name") in (None, "aac", "mp3")


def converted_path(source):
    return CACHE / f"{source.stem}-pi.mp4"


def convert(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = target.with_suffix(".tmp.mp4")
    overlay = (
        "scale=1024:768:force_original_aspect_ratio=decrease,"
        "pad=1024:768:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p,"
        "drawbox=x=690:y=684:w=310:h=62:color=black@0.55:t=fill,"
        "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf:"
        "text='RASPBERRY PI 4  •  RETROPIE':x=708:y=698:fontsize=14:fontcolor=white@0.92,"
        "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf:"
        "text='DREADWIRE SYSTEM STARTING...':x=708:y=720:fontsize=12:fontcolor=0x62F5FFFF"
    )
    result = subprocess.run(
        ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(source), "-vf", overlay,
         "-c:v", "libx264", "-preset", "veryfast", "-profile:v", "main", "-level", "4.0", "-crf", "21",
         "-c:a", "aac", "-b:a", "160k", "-ar", "48000", "-movflags", "+faststart", str(temporary)],
        timeout=900, check=False,
    )
    if result.returncode == 0:
        temporary.replace(target)
        return target
    temporary.unlink(missing_ok=True)
    return source


def main():
    SOURCE.mkdir(parents=True, exist_ok=True)
    videos = sorted(p for p in SOURCE.iterdir() if p.is_file() and p.suffix.lower() in VIDEO_EXTENSIONS)
    playable = []
    for source in videos:
        target = converted_path(source)
        needs_overlay = not target.exists() or target.stat().st_mtime < source.stat().st_mtime
        if needs_overlay:
            playable.append(convert(source, target))
        else:
            playable.append(target)
    if not playable:
        return
    if len(playable) > 1:
        random.shuffle(playable)
    PLAYLIST.write_text("\n".join(map(str, playable)) + "\n")


if __name__ == "__main__":
    main()
