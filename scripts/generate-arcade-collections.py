#!/usr/bin/env python3
"""Build clean, useful EmulationStation collections from the installed library."""

from pathlib import Path
import argparse
import html
import random
import re
import xml.etree.ElementTree as ET

ROMS = Path("/home/pi/RetroPie/roms")
COLLECTIONS = Path("/opt/retropie/configs/all/emulationstation/collections")
SETTINGS = Path("/opt/retropie/configs/all/emulationstation/es_settings.cfg")
LIBRARY = Path("/opt/dreadwire/collections/library.tsv")

KEEP = ["40 - 2 Player Games", "41 - 3 Player Games", "42 - 4 Player Games"]
FEATURED = [
    "50 - Pinball Arcade",
    "51 - Top 20 Games of All Time",
    "52 - Top Multiplayer Games",
    "53 - Bible and Christian Games",
    "54 - Family Game Night",
    "55 - Quick Play - Pick Up and Play",
    "56 - Hidden Gems",
    "57 - Mystery Game",
    "58 - Random 10",
]

SYSTEMS = [
    "arcade", "dreamcast", "gamegear", "gb", "gba", "gbc", "mastersystem",
    "megadrive", "n64", "neogeo", "nes", "ngp", "ngpc", "pcengine", "psx",
    "segacd", "snes", "wonderswan", "wonderswancolor",
]
SYSTEM_LABELS = {
    "arcade":"Arcade", "dreamcast":"Dreamcast", "gamegear":"Game Gear", "gb":"Game Boy",
    "gba":"Game Boy Advance", "gbc":"Game Boy Color", "mastersystem":"Master System",
    "megadrive":"Genesis and Mega Drive", "n64":"Nintendo 64", "neogeo":"Neo Geo", "nes":"NES",
    "ngp":"Neo Geo Pocket", "ngpc":"Neo Geo Pocket Color", "pcengine":"PC Engine",
    "psx":"PlayStation", "segacd":"Sega CD", "snes":"SNES", "wonderswan":"WonderSwan",
    "wonderswancolor":"WonderSwan Color",
}

# Ordered, recognizable favorites. Missing titles are simply skipped and the list is filled
# from highly rated/play-counted games already present on the cabinet.
SYSTEM_FAVORITES = {
    "arcade": ["pac-man","ms. pac-man","galaga","donkey kong","frogger","1942","dig dug","q*bert","joust","defender","asteroids","centipede","mortal kombat","street fighter ii","nba jam","metal slug","the simpsons","teenage mutant ninja turtles","gauntlet","outrun"],
    "dreamcast": ["soulcalibur","crazy taxi","power stone","sonic adventure","jet grind radio","shenmue","marvel vs. capcom 2","resident evil code veronica","skies of arcadia","virtua tennis"],
    "gamegear": ["sonic the hedgehog","sonic chaos","columns","shining force","streets of rage","castle of illusion","ristar","gunstar heroes","dragon crystal","shinobi"],
    "gb": ["tetris","super mario land 2","the legend of zelda: link's awakening","pokemon red","pokemon blue","kirby's dream land","metroid ii","donkey kong","wario land","dr. mario","mole mania","gargoyle's quest"],
    "gba": ["the legend of zelda: the minish cap","metroid fusion","advance wars","castlevania: aria of sorrow","mario & luigi: superstar saga","pokemon emerald","golden sun","warioware","mario kart: super circuit","fire emblem","astro boy","final fantasy tactics advance"],
    "gbc": ["the legend of zelda: oracle of ages","the legend of zelda: oracle of seasons","pokemon crystal","super mario bros. deluxe","shantae","metal gear solid","dragon warrior iii","wario land 3","pokemon pinball","tetris dx"],
    "mastersystem": ["alex kidd in miracle world","wonder boy iii","phantasy star","sonic the hedgehog","castle of illusion","shinobi","r-type","golden axe warrior","power strike ii","streets of rage"],
    "megadrive": ["sonic the hedgehog 2","streets of rage 2","gunstar heroes","contra: hard corps","castlevania: bloodlines","shining force ii","phantasy star iv","rocket knight adventures","comix zone","golden axe","mortal kombat ii","nba jam","earthworm jim","toejam & earl","road rash ii","sonic 3 & knuckles","ristar","light crusader","beyond oasis","thunder force iv"],
    "n64": ["super mario 64","the legend of zelda: ocarina of time","mario kart 64","goldeneye 007","super smash bros.","perfect dark","banjo-kazooie","star fox 64","f-zero x","paper mario","wave race 64","diddy kong racing","mario party 2","pokemon snap","1080 snowboarding"],
    "neogeo": ["metal slug","metal slug 3","the king of fighters '98","samurai shodown ii","garou: mark of the wolves","blazing star","neo turf masters","windjammers","shock troopers","pulstar"],
    "nes": ["super mario bros. 3","the legend of zelda","mega man 2","contra","castlevania iii","metroid","kirby's adventure","punch-out!!","ninja gaiden","duck tales","river city ransom","final fantasy","dragon warrior iv","blaster master","bionic commando","tecmo super bowl","bubble bobble","chip 'n dale","life force","tetris"],
    "pcengine": ["bonk's revenge","castlevania: rondo of blood","devil's crush","soldier blade","blazing lazers","r-type","ys book i & ii","splatterhouse","military madness","air zonk"],
    "psx": ["castlevania: symphony of the night","metal gear solid","final fantasy vii","crash bandicoot 2","tekken 3","resident evil 2","gran turismo 2","tony hawk's pro skater 2","spyro the dragon","vagrant story","wipeout 3","oddworld: abe's oddysee"],
    "segacd": ["sonic cd","lunar: eternal blue","lunar: the silver star","snatcher","shining force cd","final fight cd","popful mail"],
    "snes": ["the legend of zelda: a link to the past","super metroid","super mario world","chrono trigger","final fantasy vi","donkey kong country 2","super mario kart","earthbound","mega man x","super castlevania iv","f-zero","secret of mana","contra iii","street fighter ii turbo","kirby super star","star fox","turtles in time","super punch-out!!","actraiser","pilotwings"],
}

ALL_TIME = [
    ("arcade","pac-man"), ("arcade","galaga"), ("arcade","donkey kong"),
    ("nes","super mario bros. 3"), ("nes","the legend of zelda"), ("nes","mega man 2"),
    ("snes","super mario world"), ("snes","the legend of zelda: a link to the past"),
    ("snes","super metroid"), ("snes","chrono trigger"), ("megadrive","sonic the hedgehog 2"),
    ("megadrive","streets of rage 2"), ("gb","tetris"), ("gb","the legend of zelda: link's awakening"),
    ("n64","super mario 64"), ("n64","the legend of zelda: ocarina of time"),
    ("n64","mario kart 64"), ("psx","metal gear solid"),
    ("psx","castlevania: symphony of the night"), ("dreamcast","soulcalibur"),
]


def norm(value):
    value = html.unescape(value or "").lower().replace("&", "and")
    value = re.sub(r"^\d+\s*[-._)]*\s*", "", value)
    return re.sub(r"[^a-z0-9]+", " ", value).strip()


def load_games():
    result = []
    seen = set()
    for system in SYSTEMS:
        gamelist = ROMS / system / "gamelist.xml"
        if not gamelist.exists():
            continue
        try:
            games = ET.parse(gamelist).getroot().findall("game")
        except (OSError, ET.ParseError):
            continue
        for game in games:
            raw = (game.findtext("path") or "").strip()
            if not raw:
                continue
            path = Path(raw)
            if not path.is_absolute():
                path = gamelist.parent / path
            path = path.resolve()
            if not path.is_file() or str(path) in seen:
                continue
            seen.add(str(path))
            result.append({
                "system": system, "name": game.findtext("name") or path.stem,
                "key": norm(game.findtext("name") or path.stem), "path": str(path),
                "players": game.findtext("players") or "", "genre": game.findtext("genre") or "",
                "rating": float(game.findtext("rating") or 0),
                "plays": int(game.findtext("playcount") or 0),
            })
    return result


def find_title(games, system, title):
    wanted = norm(title)
    pool = [g for g in games if g["system"] == system]
    exact = next((g for g in pool if g["key"] == wanted), None)
    if exact:
        return exact
    return next((g for g in pool if wanted in g["key"] or g["key"] in wanted), None)


def ranked_system(games, system):
    pool = [g for g in games if g["system"] == system]
    chosen = []
    for title in SYSTEM_FAVORITES.get(system, []):
        game = find_title(games, system, title)
        if game and game not in chosen:
            chosen.append(game)
    remainder = sorted(pool, key=lambda g: (-g["rating"], -g["plays"], g["name"].casefold()))
    chosen.extend(g for g in remainder if g not in chosen)
    return chosen[:20]


def write_collection(name, games):
    path = COLLECTIONS / f"custom-{name}.cfg"
    unique = list(dict.fromkeys(g["path"] if isinstance(g, dict) else str(g) for g in games))
    path.write_text("\n".join(unique) + ("\n" if unique else ""), encoding="utf-8")
    return len(unique)


def set_enabled(names):
    text = SETTINGS.read_text(encoding="utf-8")
    custom = ",".join(names)
    text = re.sub(r'(<string name="CollectionSystemsCustom" value=")[^"]*("\s*/>)', rf'\g<1>{custom}\g<2>', text)
    text = re.sub(r'(<string name="CollectionSystemsAuto" value=")[^"]*("\s*/>)', r'\g<1>\g<2>', text)
    SETTINGS.write_text(text, encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--shuffle-only", action="store_true")
    args = parser.parse_args()
    COLLECTIONS.mkdir(parents=True, exist_ok=True)
    LIBRARY.parent.mkdir(parents=True, exist_ok=True)
    games = load_games()
    playable = [g for g in games if g["system"] not in {"companion", "controllers", "jukebox"}]
    LIBRARY.write_text("".join(f'{g["system"]}\t{g["path"]}\n' for g in playable), encoding="utf-8")

    random_ten = random.sample(playable, min(10, len(playable)))
    if args.shuffle_only:
        write_collection("58 - Random 10", random_ten)
        return

    # Remove every old custom collection except the three requested player packs.
    keep_files = {f"custom-{name}.cfg" for name in KEEP}
    for old in COLLECTIONS.glob("custom-*.cfg"):
        if old.name not in keep_files:
            old.unlink()

    write_collection("58 - Random 10", random_ten)

    pinball = [g for g in playable if "pinball" in g["key"] or "spinball" in g["key"]]
    christian_terms = ("bible", "exodus journey", "joshua", "noah s ark", "spiritual warfare", "king of kings")
    christian = [g for g in playable if any(term in g["key"] for term in christian_terms)]
    multiplayer_terms = ("mario kart", "smash bros", "nba jam", "street fighter", "mortal kombat", "worms", "gauntlet", "metal slug", "bomberman", "contra", "turtles", "simpsons", "streets of rage", "goldeneye", "tekken", "windjammers")
    multiplayer = [g for g in playable if any(term in g["key"] for term in multiplayer_terms)][:40]
    family_terms = ("mario", "sonic", "kirby", "tetris", "pokemon", "donkey kong", "bubble bobble", "bomberman", "pac man", "frogger", "columns")
    family = [g for g in playable if any(term in g["key"] for term in family_terms)][:50]
    quick_genres = ("arcade", "puzzle", "platform", "shooter", "racing")
    quick = [g for g in playable if any(term in g["genre"].lower() for term in quick_genres)][:50]
    hidden = [g for g in playable if g["system"] in {"gamegear","ngp","ngpc","pcengine","segacd","wonderswan","wonderswancolor"}]
    random.Random(1983).shuffle(hidden)

    all_time = [game for system, title in ALL_TIME if (game := find_title(games, system, title))]
    all_time = list({game["path"]: game for game in all_time}.values())
    for system in ("arcade", "nes", "snes", "megadrive", "gb", "n64", "psx", "dreamcast"):
        for game in ranked_system(games, system):
            if game not in all_time:
                all_time.append(game)
            if len(all_time) >= 20:
                break
        if len(all_time) >= 20:
            break
    if len(all_time) < 20:
        for game in sorted(playable, key=lambda g: (-g["rating"], -g["plays"], g["name"].casefold())):
            if game not in all_time:
                all_time.append(game)
            if len(all_time) >= 20:
                break
    write_collection("50 - Pinball Arcade", sorted(pinball, key=lambda g:g["name"].casefold()))
    write_collection("51 - Top 20 Games of All Time", all_time)
    write_collection("52 - Top Multiplayer Games", multiplayer)
    write_collection("53 - Bible and Christian Games", christian)
    write_collection("54 - Family Game Night", family)
    write_collection("55 - Quick Play - Pick Up and Play", quick)
    write_collection("56 - Hidden Gems", hidden[:30])
    write_collection("57 - Mystery Game", ["/home/pi/RetroPie/roms/companion/08-mystery-game.sh"])

    top_names = []
    for index, system in enumerate(SYSTEMS, start=70):
        top = ranked_system(games, system)
        if len(top) < 5:
            continue
        name = f"{index} - Top 20 - {SYSTEM_LABELS[system]}"
        write_collection(name, top)
        top_names.append(name)
    set_enabled(KEEP + FEATURED + top_names)


if __name__ == "__main__":
    main()
