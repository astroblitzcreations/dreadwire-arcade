#!/usr/bin/env python3
from pathlib import Path
import xml.etree.ElementTree as ET
path=Path("/opt/retropie/configs/all/emulationstation/gamelists/homebrew/gamelist.xml")
root=ET.parse(path).getroot() if path.exists() else ET.Element("gameList")
for old in list(root.findall("game")):
    if old.findtext("path")=="./Trippy Gold Maze.sh": root.remove(old)
game=ET.SubElement(root,"game")
values={"path":"./Trippy Gold Maze.sh","name":"Trippy Gold Maze","desc":"Race through a hypnotic golden maze, devour every orb, outsmart four spectral hunters, and unleash reality-bending power modes.","image":"./images/trippy-gold-maze.png","developer":"Dreadwire Crew","publisher":"Dreadwire Crew","genre":"Psychedelic maze chase"}
for key,value in values.items(): ET.SubElement(game,key).text=value
ET.indent(root,space="\t"); ET.ElementTree(root).write(path,encoding="utf-8",xml_declaration=True)
