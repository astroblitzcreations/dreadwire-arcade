#!/usr/bin/env python3
"""Preserve one already-running pre-leaderboard Arena Brawl session."""
import os
import re
import shutil
import sys
import time
from pathlib import Path


def section_value(text: str, section: str, key: str, default: int = 0) -> int:
    match = re.search(rf"\[{re.escape(section)}\](.*?)(?=\n\[|\Z)", text, re.S)
    if not match:
        return default
    value = re.search(rf"^{re.escape(key)}=(-?\d+)", match.group(1), re.M)
    return int(value.group(1)) if value else default


def main() -> int:
    if len(sys.argv) != 4:
        return 2
    pid = int(sys.argv[1])
    source = Path(sys.argv[2])
    pending = Path(sys.argv[3])
    snapshot = pending.with_suffix(".snapshot")
    last_change = time.monotonic()
    last_mtime = 0
    if source.exists():
        shutil.copy2(source, snapshot)
        last_mtime = source.stat().st_mtime_ns
    while Path(f"/proc/{pid}").exists():
        try:
            mtime = source.stat().st_mtime_ns
            if mtime != last_mtime:
                shutil.copy2(source, snapshot)
                last_mtime = mtime
                last_change = time.monotonic()
            # Recovery writes stop at Game Over/victory in the older build.
            if snapshot.exists() and time.monotonic() - last_change >= 15:
                break
        except FileNotFoundError:
            pass
        time.sleep(2)
    if not snapshot.exists():
        return 1
    text = snapshot.read_text(encoding="utf-8")
    candidates = []
    for player in (0, 1):
        section = f"player_{player}"
        candidates.append({
            "name": f"P{player + 1}",
            "score": section_value(text, section, "score"),
            "cash": section_value(text, section, "cash"),
            "gold": section_value(text, section, "gold"),
        })
    winner = max(candidates, key=lambda item: item["score"])
    winner["level"] = section_value(text, "campaign", "wave_index") + 1
    winner["floor"] = section_value(text, "campaign", "floor_in_room", 1)
    winner["stamp"] = section_value(text, "recovery", "saved_unix", int(time.time()))
    temporary = pending.with_suffix(".tmp")
    temporary.write_text(
        "[pending]\n\n"
        f'name="{winner["name"]}"\n'
        f'score={winner["score"]}\n'
        f'cash={winner["cash"]}\n'
        f'gold={winner["gold"]}\n'
        f'level={winner["level"]}\n'
        f'floor={winner["floor"]}\n'
        f'stamp={winner["stamp"]}\n',
        encoding="utf-8",
    )
    os.replace(temporary, pending)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
