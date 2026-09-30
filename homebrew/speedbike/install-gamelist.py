#!/usr/bin/env python3
"""Add or refresh Speedbike in the cabinet Homebrew game list."""

from pathlib import Path
import xml.etree.ElementTree as ET

path = Path("/opt/retropie/configs/all/emulationstation/gamelists/homebrew/gamelist.xml")
root = ET.parse(path).getroot() if path.exists() else ET.Element("gameList")
for old in list(root.findall("game")):
    if old.findtext("path") == "./Speedbike.sh":
        root.remove(old)
game = ET.SubElement(root, "game")
values = {
    "path": "./Speedbike.sh",
    "name": "Speedbike",
    "desc": "Race through the alien badlands in Chain of Command's original high-speed combat bike campaign.",
    "image": "./images/speedbike.png",
    "developer": "Dreadwire Crew",
    "publisher": "Dreadwire Crew",
    "genre": "Arcade racing / combat",
}
for key, value in values.items():
    ET.SubElement(game, key).text = value
ET.indent(root, space="\t")
ET.ElementTree(root).write(path, encoding="utf-8", xml_declaration=True)
