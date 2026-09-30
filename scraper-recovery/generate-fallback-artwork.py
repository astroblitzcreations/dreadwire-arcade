#!/usr/bin/env python3
"""Give every unscraped ROM a polished, readable fallback cover."""

from __future__ import annotations

import hashlib
import random
import textwrap
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path("/home/pi/RetroPie/roms")
SYSTEMS = {
    "nes": ("NINTENDO", {".nes", ".zip", ".7z"}),
    "snes": ("SUPER NINTENDO", {".smc", ".sfc", ".zip", ".7z"}),
    "megadrive": ("MEGA DRIVE", {".bin", ".smd", ".md", ".gen", ".zip", ".7z"}),
    "mastersystem": ("MASTER SYSTEM", {".sms", ".zip", ".7z"}),
    "gamegear": ("GAME GEAR", {".gg", ".zip", ".7z"}),
    "gb": ("GAME BOY", {".gb", ".zip", ".7z"}),
    "gbc": ("GAME BOY COLOR", {".gbc", ".zip", ".7z"}),
    "gba": ("GAME BOY ADVANCE", {".gba", ".zip", ".7z"}),
    "n64": ("NINTENDO 64", {".n64", ".v64", ".z64", ".zip", ".7z"}),
    "neogeo": ("NEO GEO", {".zip", ".7z"}),
    "ngp": ("NEO GEO POCKET", {".ngp", ".ngf", ".zip", ".7z"}),
    "ngpc": ("NEO GEO POCKET COLOR", {".ngc", ".zip", ".7z"}),
    "pcengine": ("PC ENGINE", {".pce", ".zip", ".7z"}),
    "wonderswan": ("WONDERSWAN", {".ws", ".zip", ".7z"}),
    "wonderswancolor": ("WONDERSWAN COLOR", {".wsc", ".zip", ".7z"}),
    "arcade": ("ARCADE", {".zip", ".7z"}),
    "psx": ("PLAYSTATION", {".cue", ".pbp", ".m3u", ".chd"}),
    "dreamcast": ("DREAMCAST", {".cdi", ".gdi", ".m3u", ".chd"}),
    "pc": ("DOS PC", {".zip", ".dosz"}),
    "segacd": ("SEGA CD", {".m3u", ".chd"}),
}

FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_REG = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def clean_title(path: Path) -> str:
    title = path.stem.replace("_", " ").strip()
    while "  " in title:
        title = title.replace("  ", " ")
    return title


def make_cover(path: Path, system_name: str, title: str) -> None:
    width, height = 420, 560
    seed = int(hashlib.sha1((system_name + title).encode()).hexdigest()[:8], 16)
    rng = random.Random(seed)
    colors = [(9, 21, 53), (38, 8, 65), (4, 55, 69), (72, 12, 32)]
    base = colors[seed % len(colors)]
    image = Image.new("RGB", (width, height), base)
    draw = ImageDraw.Draw(image)
    for y in range(height):
        factor = y / height
        draw.line((0, y, width, y), fill=tuple(min(255, int(c + factor * 35)) for c in base))
    for _ in range(90):
        x, y = rng.randrange(width), rng.randrange(height)
        r = rng.choice((1, 1, 1, 2))
        draw.ellipse((x-r, y-r, x+r, y+r), fill=(120+rng.randrange(136), 180+rng.randrange(76), 255))
    accent = (48, 230, 255)
    draw.rounded_rectangle((22, 22, width-22, height-22), radius=24, outline=accent, width=4)
    draw.rounded_rectangle((35, 42, width-35, 108), radius=15, fill=(3, 8, 25), outline=(255, 75, 195), width=2)
    system_font = ImageFont.truetype(FONT_BOLD, 27)
    draw.text((width/2, 75), system_name, font=system_font, fill=accent, anchor="mm")
    wrapped = textwrap.wrap(title, width=20)[:5]
    size = 42 if len(wrapped) <= 3 else 34
    title_font = ImageFont.truetype(FONT_BOLD, size)
    line_height = size + 10
    top = 285 - (len(wrapped) * line_height) / 2
    for index, line in enumerate(wrapped):
        draw.text((width/2+2, top + index*line_height+2), line, font=title_font, fill=(0, 0, 0), anchor="mm")
        draw.text((width/2, top + index*line_height), line, font=title_font, fill=(255, 245, 218), anchor="mm")
    footer_font = ImageFont.truetype(FONT_REG, 18)
    draw.text((width/2, 505), "ARCADE 1UP COLLECTION", font=footer_font, fill=(255, 93, 199), anchor="mm")
    image.save(path, "JPEG", quality=88, optimize=True)


def process(system: str, system_name: str, extensions: set[str]) -> tuple[int, int]:
    folder = ROOT / system
    if not folder.exists():
        return 0, 0
    gamelist = folder / "gamelist.xml"
    try:
        tree = ET.parse(gamelist)
        root = tree.getroot()
    except (FileNotFoundError, ET.ParseError):
        root = ET.Element("gameList")
        tree = ET.ElementTree(root)
    entries = {}
    for game in root.findall("game"):
        item = game.findtext("path", "")
        # Skyscraper writes absolute ROM paths while the original importer used
        # ./relative paths.  Normalize both forms to the ROM basename so a
        # regeneration updates an existing entry instead of duplicating it.
        entries[Path(item).name] = game

    media = folder / "media" / "fallback"
    media.mkdir(parents=True, exist_ok=True)
    games = [p for p in folder.iterdir() if p.is_file() and p.suffix.lower() in extensions]
    generated = 0
    for rom in sorted(games):
        relative = rom.name
        game = entries.get(relative)
        if game is None:
            game = ET.SubElement(root, "game")
            ET.SubElement(game, "path").text = f"./{relative}"
            ET.SubElement(game, "name").text = clean_title(rom)
            entries[relative] = game
        image_node = game.find("image")
        if image_node is not None and image_node.text:
            continue
        safe = hashlib.sha1(relative.encode()).hexdigest()[:12]
        cover = media / f"{safe}.jpg"
        make_cover(cover, system_name, game.findtext("name", clean_title(rom)))
        if image_node is None:
            image_node = ET.SubElement(game, "image")
        image_node.text = f"./media/fallback/{cover.name}"
        generated += 1
    ET.indent(tree, space="  ")
    tree.write(gamelist, encoding="utf-8", xml_declaration=True)
    return len(games), generated


def main() -> None:
    total = generated = 0
    for system, (display, extensions) in SYSTEMS.items():
        count, made = process(system, display, extensions)
        total += count
        generated += made
        print(f"{system}: {count} games, {made} fallback covers")
    print(f"TOTAL: {total} games, {generated} fallback covers generated")


if __name__ == "__main__":
    main()
