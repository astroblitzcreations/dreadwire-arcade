extends RefCounted
## Small lazy cache. Assets are looked up from the shipped manifest, never guessed/cropped heuristically.
const BASE = "res://arcade/twin_stick/"
var textures: Dictionary = {}
var records: Dictionary = {}

func _init() -> void:
    var file = FileAccess.open(BASE + "data/asset_manifest.json", FileAccess.READ)
    if file == null:
        push_error("Arena Brawl: asset_manifest.json missing")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        push_error("Arena Brawl: invalid asset manifest")
        return
    for entry in parsed.get("assets", []):
        records[entry["path"]] = entry

func texture(path: String) -> Texture2D:
    if textures.has(path):
        return textures[path]
    var tex = load(path) as Texture2D
    if tex == null:
        push_error("Arena Brawl missing texture: " + path)
    textures[path] = tex
    return tex

func record(path: String) -> Dictionary:
    return records.get(path, {})

func data(name: String):
    var path = BASE + "data/" + name + ".json"
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Arena Brawl missing data: " + path)
        return []
    return JSON.parse_string(file.get_as_text())
