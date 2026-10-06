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
var voice_queue: Array[AudioStream] = []
var voice_gap: float = 0.0
var sequence_gap: float = 0.65
var voice_was_playing := false
var voice_path_recent: Dictionary = {}
var music_muted: bool = false
var sfx_muted: bool = false
var voice_muted: bool = false
const SMASH = "res://arcade/twin_stick/assets/audio/smashtv/"

func _ready() -> void:
    for bus_name in ["BrawlSFX", "BrawlMusic", "BrawlVoice"]:
        if AudioServer.get_bus_index(bus_name) == -1:
            AudioServer.add_bus()
            var index = AudioServer.bus_count - 1
            AudioServer.set_bus_name(index, bus_name)
            AudioServer.set_bus_send(index, "Master")
    # Leave generous digital headroom on the Pi. Godot's native limiter can
    # crash the ALSA path on this ARM/Mesa build, while bus headroom is stable.
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BrawlSFX"), -6.0)
    for entry in _json("sfx_manifest").get("sounds", []):
        sound_map[entry["id"]] = entry
    for entry in _json("announcer_lines").get("lines", []):
        var category = entry["category"]
        if not voice_map.has(category):
            voice_map[category] = []
        voice_map[category].append(entry)
    for entry in _json("music_manifest").get("tracks", []):
        music_map[entry["id"]] = entry
    # User-supplied original arcade samples. The numbered source archive has
    # no semantic filenames, so these are curated by sound role and may be
    # adjusted later without changing gameplay code.
    var smash_sfx = {
        "pulse_fire": "sfx_01.wav", "automatic_fire": "sfx_02.wav",
        "shotgun_fire": "sfx_03.wav", "plasma_fire": "sfx_04.wav",
        "rail_fire": "sfx_05.wav", "rocket_launch": "sfx_06.wav",
        "flame_loop": "sfx_07.wav", "arc_discharge": "sfx_08.wav",
        "twin_pulse_fire": "sfx_09.wav", "orbit_fire": "sfx_10.wav",
        "bullet_hit_enemy": "sfx_12.wav", "bullet_hit_metal": "sfx_13.wav",
        "explosion_small": "sfx_16.wav", "explosion_medium": "sfx_17.wav",
        "explosion_large": "sfx_18.wav", "enemy_death": "sfx_19.wav",
        "player_hurt": "sfx_20.wav", "player_death": "sfx_21.wav",
        "health_pickup": "sfx_28.wav", "weapon_pickup": "sfx_29.wav",
        "credits_pickup": "sfx_30.wav", "extra_life": "sfx_31.wav",
        "jackpot": "sfx_32.wav", "prize_pickup": "sfx_33.wav",
        "door_open": "sfx_37.wav", "door_close": "sfx_38.wav",
        "wave_clear": "sfx_41.wav", "menu_move": "sfx_43.wav",
        "menu_select": "sfx_44.wav", "pause": "sfx_45.wav",
        "game_start": "sfx_47.wav", "game_over": "sfx_48.wav"
    }
    for id in smash_sfx:
        if sound_map.has(id):
            sound_map[id]["variants"] = [SMASH + smash_sfx[id]]
    var smash_voice = {
        "game_start": ["voice_good_luck.wav", "voice_go.wav", "voice_lets_go.wav"],
        "wave_start": ["voice_contestant_1.wav", "voice_contestant_2.wav"],
        "pickup": ["voice_big_money.wav", "voice_big_prizes.wav", "voice_i_love_it.wav"],
        "big_kill": ["voice_total_carnage.wav", "voice_yeah.wav"],
        "player_death": ["voice_aaargh.wav", "voice_urk.wav"],
        "jackpot": ["voice_bingo.wav", "voice_dollar.wav"],
        "room_clear": ["voice_whoo.wav", "voice_woo.wav"],
        "boss_start": ["voice_youll_need_it.wav"],
        "final_boss": ["voice_total_carnage.wav"],
        "victory": ["voice_big_money.wav", "voice_big_prizes.wav"]
    }
    for category in smash_voice:
        voice_map[category] = []
        for filename in smash_voice[category]:
            voice_map[category].append({"id": filename, "path": SMASH + filename, "cooldown_seconds": 4.0})
    for i in range(32):
        var player = AudioStreamPlayer.new()
        player.bus = "BrawlSFX"
        add_child(player)
        pool.append(player)
    music_player = AudioStreamPlayer.new()
    music_player.bus = "BrawlMusic"
    music_player.volume_db = -12.0
    add_child(music_player)
    voice_player = AudioStreamPlayer.new()
    voice_player.bus = "BrawlVoice"
    voice_player.volume_db = 1.5
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
    voice_gap = maxf(0.0, voice_gap - delta)
    if voice_was_playing and not voice_player.playing:
        voice_gap = sequence_gap
    voice_was_playing = voice_player.playing
    if not voice_player.playing and voice_gap <= 0.0 and not voice_queue.is_empty():
        voice_player.stream = voice_queue.pop_front()
        voice_player.play()
        voice_was_playing = true

func play_sfx(id: String, pitch: float = 1.0) -> void:
    if sfx_muted or not sound_map.has(id):
        return
    var now = Time.get_ticks_msec()
    # Per-effect voice limits stop overlapping automatic-fire samples from swamping the mix.
    var fire_limits = {"automatic_fire": 180, "flame_loop": 220, "orbit_fire": 180,
        "twin_pulse_fire": 170, "pulse_fire": 155, "arc_discharge": 190}
    var minimum_gap = int(fire_limits.get(id, 125 if id.contains("fire") else 45))
    if now - int(recent.get(id, -10000)) < minimum_gap:
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
            player.volume_db = float(entry.get("volume_db", -8)) + (4.0 if id.contains("fire") or id.contains("laser") else 2.0)
            if id == "flame_loop":
                player.volume_db = -18.0
            player.pitch_scale = clampf(pitch, 0.8, 1.2)
            player.play()
            return
    # Busy pool: skip this one-shot instead of allocating unlimited audio nodes.

func announce(category: String, priority: bool = false) -> void:
    if voice_muted or not voice_map.has(category):
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

func announce_sequence(paths: Array, priority: bool = true, cooldown: float = 8.0, force: bool = false) -> void:
    if voice_muted:
        return
    var now = Time.get_ticks_msec() / 1000.0
    if not force:
        for path in paths:
            if now - float(voice_path_recent.get(path, -999.0)) < cooldown:
                return
    if priority:
        voice_player.stop()
        voice_queue.clear()
    for path in paths:
        var stream = _stream(SMASH + path)
        if stream != null:
            voice_queue.append(stream)
            voice_path_recent[path] = now
    voice_delay = 0.0
    voice_gap = 0.0
    sequence_gap = 0.7

func play_music(id: String) -> void:
    if not music_map.has(id):
        return
    var stream = _stream(music_map[id]["path"])
    if stream == null:
        return
    if music_player.stream == stream and music_player.playing:
        return
    if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
        stream.loop = bool(music_map[id].get("loop", true))
    music_player.stream = stream
    music_player.play()
    music_player.stream_paused = music_muted

func toggle_music() -> void:
    music_muted = not music_muted
    music_player.stream_paused = music_muted

func set_music_enabled(enabled: bool) -> void:
    music_muted = not enabled
    music_player.stream_paused = music_muted

func set_sfx_enabled(enabled: bool) -> void:
    sfx_muted = not enabled
    if sfx_muted:
        for player in pool:
            player.stop()

func set_voice_enabled(enabled: bool) -> void:
    voice_muted = not enabled
    if voice_muted:
        voice_player.stop()
        voice_queue.clear()

func set_music_volume(percent: int) -> void:
    _set_bus_volume("BrawlMusic", percent)

func set_sfx_volume(percent: int) -> void:
    _set_bus_volume("BrawlSFX", percent)

func set_voice_volume(percent: int) -> void:
    _set_bus_volume("BrawlVoice", percent)

func _set_bus_volume(bus_name: String, percent: int) -> void:
    var index = AudioServer.get_bus_index(bus_name)
    if index < 0:
        return
    var amount = clampi(percent, 0, 100)
    AudioServer.set_bus_mute(index, amount == 0)
    var headroom = -6.0 if bus_name == "BrawlSFX" else -3.0 if bus_name == "BrawlMusic" else 0.0
    AudioServer.set_bus_volume_db(index, linear_to_db(maxf(float(amount) / 100.0, 0.001)) + headroom)

func stop_all() -> void:
    for player in pool:
        player.stop()
    if is_instance_valid(music_player):
        music_player.stop()
    if is_instance_valid(voice_player):
        voice_player.stop()
    voice_queue.clear()
