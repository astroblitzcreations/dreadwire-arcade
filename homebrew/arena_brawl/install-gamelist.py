#!/usr/bin/env python3
"""Add or refresh Arena Brawl in the cabinet Homebrew game list."""

from pathlib import Path
import xml.etree.ElementTree as ET

path = Path("/opt/retropie/configs/all/emulationstation/gamelists/homebrew/gamelist.xml")
root = ET.parse(path).getroot() if path.exists() else ET.Element("gameList")
for old in list(root.findall("game")):
    if old.findtext("path") == "./Arena Brawl.sh":
        root.remove(old)
game = ET.SubElement(root, "game")
values = {
    "path": "./Arena Brawl.sh",
    "name": "Arena Brawl",
    "desc": "A two-player neon twin-stick arena shooter with 20 escalating waves, bosses, weapon drops, and CRT arcade style.",
    "image": "./images/arena-brawl.png",
    "developer": "Dreadwire Crew",
    "publisher": "Dreadwire Crew",
    "genre": "Twin-stick arena shooter",
}
for key, value in values.items():
    ET.SubElement(game, key).text = value
ET.indent(root, space="\t")
ET.ElementTree(root).write(path, encoding="utf-8", xml_declaration=True)
