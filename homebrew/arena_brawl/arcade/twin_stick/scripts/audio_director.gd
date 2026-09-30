extends Node
## Dedicated per-minigame players; no global volume or parent-game audio is modified.
const BASE = "res://arcade/twin_stick/"
var sound_map: Dictionary = {}
var voice_map: Dictionary = {}
var music_map: Dictionary = {}
var cache: Dictionary = {}
var recent: Dictionary = {}
var pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var voice_delay: float = 0.0
var last_voice: String = ""
var music_muted: bool = false

func _ready() -> void:
    for bus_name in ["BrawlSFX", "BrawlMusic", "BrawlVoice"]:
        if AudioServer.get_bus_index(bus_name) == -1:
            AudioServer.add_bus()
            var index = AudioServer.bus_count - 1
            AudioServer.set_bus_name(index, bus_name)
            AudioServer.set_bus_send(index, "Master")
    for entry in _json("sfx_manifest").get("sounds", []):
        sound_map[entry["id"]] = entry
    for entry in _json("announcer_lines").get("lines", []):
        var category = entry["category"]
        if not voice_map.has(category):
            voice_map[category] = []
        voice_map[category].append(entry)
    for entry in _json("music_manifest").get("tracks", []):
        music_map[entry["id"]] = entry
    for i in range(20):
        var player = AudioStreamPlayer.new()
        player.bus = "BrawlSFX"
        add_child(player)
        pool.append(player)
    music_player = AudioStreamPlayer.new()
    music_player.bus = "BrawlMusic"
    music_player.volume_db = -16.0
    add_child(music_player)
    voice_player = AudioStreamPlayer.new()
    voice_player.bus = "BrawlVoice"
    voice_player.volume_db = -6.0
    add_child(voice_player)

func _json(id: String) -> Dictionary:
    var file = FileAccess.open(BASE + "data/" + id + ".json", FileAccess.READ)
    if file == null:
        push_error("Missing audio manifest: " + id)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if parsed is Dictionary else {}

func _stream(path: String) -> AudioStream:
    if not cache.has(path):
        cache[path] = load(path) as AudioStream
    return cache[path]

func _process(delta: float) -> void:
    voice_delay = maxf(0.0, voice_delay - delta)

func play_sfx(id: String, pitch: float = 1.0) -> void:
    if not sound_map.has(id):
        return
    var now = Time.get_ticks_msec()
    # Per-effect voice limits stop overlapping automatic-fire samples from swamping the mix.
    if now - int(recent.get(id, -10000)) < (95 if id.contains("fire") else 45):
        return
    recent[id] = now
    var entry = sound_map[id]
    var variants = entry["variants"]
    var stream = _stream(variants[randi() % variants.size()])
    if stream == null:
        return
    for player in pool:
        if not player.playing:
            player.stream = stream
            player.volume_db = float(entry.get("volume_db", -8))
            if id == "flame_loop":
                player.volume_db = -18.0
            player.pitch_scale = clampf(pitch, 0.8, 1.2)
            player.play()
            return
    # Busy pool: skip this one-shot instead of allocating unlimited audio nodes.

func announce(category: String, priority: bool = false) -> void:
    if not voice_map.has(category):
        return
    if not priority and (voice_delay > 0.0 or voice_player.playing):
        return
    var options: Array = voice_map[category]
    var chosen: Dictionary = options[randi() % options.size()]
    if options.size() > 1 and chosen["id"] == last_voice:
        for alternate in options:
            if alternate["id"] != last_voice:
                chosen = alternate
                break
    voice_player.stream = _stream(chosen["path"])
    if voice_player.stream == null:
        return
    voice_player.play()
    last_voice = chosen["id"]
    voice_delay = float(chosen.get("cooldown_seconds", 4.0))

func play_music(id: String) -> void:
    if not music_map.has(id):
        return
    var stream = _stream(music_map[id]["path"])
    if stream == null:
        return
    if music_player.stream == stream and music_player.playing:
        return
    if stream is AudioStreamOggVorbis:
        stream.loop = true
    music_player.stream = stream
    music_player.play()
    music_player.stream_paused = music_muted

func toggle_music() -> void:
    music_muted = not music_muted
    music_player.stream_paused = music_muted

func stop_all() -> void:
    for player in pool:
        player.stop()
    if is_instance_valid(music_player):
        music_player.stop()
    if is_instance_valid(voice_player):
        voice_player.stop()
