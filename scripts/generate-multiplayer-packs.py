#!/usr/bin/env python3
"""Generate native EmulationStation collections grouped by supported players."""

from pathlib import Path
import re
import xml.etree.ElementTree as ET


ROMS = Path("/home/pi/RetroPie/roms")
COLLECTIONS = Path("/opt/retropie/configs/all/emulationstation/collections")
SETTINGS = Path("/opt/retropie/configs/all/emulationstation/es_settings.cfg")
PACKS = {
    2: "40 - 2 Player Games",
    3: "41 - 3 Player Games",
    4: "42 - 4 Player Games",
}


def player_count(text):
    numbers = [int(value) for value in re.findall(r"\d+", text or "")]
    return max(numbers) if numbers else 0


def installed_games():
    games = {players: [] for players in PACKS}
    for gamelist in ROMS.glob("*/gamelist.xml"):
        try:
            root = ET.parse(gamelist).getroot()
        except (OSError, ET.ParseError):
            continue
        for game in root.findall("game"):
            players = player_count(game.findtext("players", ""))
            if players not in games:
                continue
            raw_path = (game.findtext("path", "") or "").strip()
            if not raw_path:
                continue
            path = Path(raw_path)
            if not path.is_absolute():
                path = gamelist.parent / path
            try:
                path = path.resolve()
            except OSError:
                continue
            if path.is_file():
                games[players].append(str(path))
    return games


def enable_collections(names):
    text = SETTINGS.read_text(encoding="utf-8")
    pattern = r'(<string name="CollectionSystemsCustom" value=")([^"]*)("\s*/>)'
    match = re.search(pattern, text)
    existing = [item for item in (match.group(2).split(",") if match else []) if item]
    for name in names:
        if name not in existing:
            existing.append(name)
    value = ",".join(existing)
    replacement = rf'\g<1>{value}\g<3>'
    if match:
        text = re.sub(pattern, replacement, text, count=1)
    else:
        text = text.rstrip() + f'\n<string name="CollectionSystemsCustom" value="{value}" />\n'
    SETTINGS.write_text(text, encoding="utf-8")


def main():
    COLLECTIONS.mkdir(parents=True, exist_ok=True)
    games = installed_games()
    for players, name in PACKS.items():
        collection = COLLECTIONS / f"custom-{name}.cfg"
        collection.write_text("\n".join(sorted(set(games[players]), key=str.casefold)) + "\n", encoding="utf-8")
        print(f"{name}: {len(set(games[players]))} games")
    enable_collections(PACKS.values())


if __name__ == "__main__":
    main()
