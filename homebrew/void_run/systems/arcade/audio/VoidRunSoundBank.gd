extends Node
class_name VoidRunSoundBank
## Optional Godot 4 reference helper. Keep this node UNDER the minigame overlay.
## Inherits its process mode. Never changes SceneTree.paused or the arena's audio.
## Runtime validation in your project's exact Godot version is still required.

@export_file("*.json") var manifest_path: String = "res://audio/void_run/sound_manifest.json"
@export_range(4, 64) var max_total_voices: int = 32

var _events: Dictionary = {}
var _streams: Dictionary = {}
var _last_index: Dictionary = {}
var _last_play_ms: Dictionary = {}
var _loops: Dictionary = {}
var _voices: Array[Dictionary] = []
var _audio_root: String = "res://audio/void_run/"
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	if not FileAccess.file_exists(manifest_path):
		push_error("Void Run audio manifest is missing: " + manifest_path)
		return
	var parser := JSON.new()
	var status: Error = parser.parse(FileAccess.get_file_as_string(manifest_path))
	if status != OK or typeof(parser.data) != TYPE_DICTIONARY:
		push_error("Invalid Void Run audio manifest.")
		return
	var manifest: Dictionary = parser.data
	if typeof(manifest.get("events")) != TYPE_DICTIONARY:
		push_error("Void Run manifest has no event dictionary.")
		return
	_audio_root = manifest_path.get_base_dir() + "/"
	_events = manifest["events"]
	_ensure_buses(manifest)

func _ensure_buses(manifest: Dictionary) -> void:
	var master: String = str(manifest.get("master_bus", "VoidRun"))
	# Add only missing buses. Never reset an existing bus or touch the Master bus.
	if AudioServer.get_bus_index(master) < 0:
		AudioServer.add_bus()
		var index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, master)
		AudioServer.set_bus_send(index, "Master")
		AudioServer.set_bus_volume_db(index, float(manifest.get("master_gain_db", -6.0)))
	var buses: Dictionary = manifest.get("buses", {})
	for name in buses:
		if AudioServer.get_bus_index(str(name)) >= 0:
			continue
		AudioServer.add_bus()
		var index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, str(name))
		AudioServer.set_bus_send(index, master)
		AudioServer.set_bus_volume_db(index, float(buses[name]))

func preload_all() -> void:
	## Call after _ready, during minigame loading rather than the first hectic wave.
	for event_name in _events:
		var config: Dictionary = _events[event_name]
		for relative_path in config.get("files", []):
			_get_stream(str(relative_path))

func _get_stream(relative_path: String) -> AudioStream:
	var full_path: String = _audio_root + relative_path
	if _streams.has(full_path):
		return _streams[full_path] as AudioStream
	if not ResourceLoader.exists(full_path):
		push_warning("Missing Void Run sound: " + full_path)
		return null
	var stream: AudioStream = load(full_path) as AudioStream
	if stream != null:
		_streams[full_path] = stream
	return stream

func _pick_stream(event_name: String, config: Dictionary) -> AudioStream:
	var files: Array = config.get("files", [])
	if files.is_empty():
		return null
	var index: int = _rng.randi_range(0, files.size() - 1)
	if files.size() > 1 and index == int(_last_index.get(event_name, -1)):
		index = (index + _rng.randi_range(1, files.size() - 1)) % files.size()
	_last_index[event_name] = index
	return _get_stream(str(files[index]))

func _prune_voices() -> void:
	for index in range(_voices.size() - 1, -1, -1):
		var player = _voices[index].get("player")
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			_voices.remove_at(index)

func _can_allocate(event_name: String, config: Dictionary) -> bool:
	_prune_voices()
	var event_count: int = 0
	for voice in _voices:
		if str(voice["event"]) == event_name and not bool(voice["player"].get_meta("vr_stopping", false)):
			event_count += 1
	if event_count >= int(config.get("max_voices", 4)):
		return false
	if _voices.size() < max_total_voices:
		return true
	var lowest_index: int = -1
	var lowest_priority: int = 100000
	# Sustained loops keep their own lifetime. Steal only a low-priority one-shot.
	for index in range(_voices.size()):
		var voice: Dictionary = _voices[index]
		if bool(voice.get("loop", false)):
			continue
		var priority: int = int(voice.get("priority", 0))
		if priority < lowest_priority:
			lowest_priority = priority
			lowest_index = index
	if lowest_index < 0 or int(config.get("priority", 40)) < lowest_priority:
		return false
	_free_player(_voices[lowest_index]["player"] as AudioStreamPlayer)
	_voices.remove_at(lowest_index)
	return true

func _new_player(event_name: String, config: Dictionary, stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = StringName(str(config.get("bus", "VoidRun")))
	player.volume_db = float(config.get("gain_db", -3.0))
	player.pitch_scale = _rng.randf_range(float(config.get("pitch_min", 1.0)), float(config.get("pitch_max", 1.0)))
	player.max_polyphony = 1
	add_child(player)
	player.finished.connect(_free_player.bind(player))
	_voices.append({"player": player, "event": event_name, "priority": int(config.get("priority", 40)), "loop": bool(config.get("loop", false))})
	return player

func play_event(event_name: String, extra_gain_db: float = 0.0) -> AudioStreamPlayer:
	if not _events.has(event_name):
		push_warning("Unknown Void Run sound event: " + event_name)
		return null
	var config: Dictionary = _events[event_name]
	if bool(config.get("loop", false)):
		push_warning("Use start_loop() for " + event_name)
		return null
	var now: int = Time.get_ticks_msec()
	if now - int(_last_play_ms.get(event_name, -1000000)) < int(config.get("cooldown_ms", 0)):
		return null
	var stream: AudioStream = _pick_stream(event_name, config)
	if stream == null or not _can_allocate(event_name, config):
		return null
	var player: AudioStreamPlayer = _new_player(event_name, config, stream)
	player.volume_db += extra_gain_db
	_last_play_ms[event_name] = now
	player.play()
	return player

func start_loop(event_name: String, key: String, fade_seconds: float = 0.12) -> AudioStreamPlayer:
	if not _events.has(event_name):
		push_warning("Unknown Void Run loop: " + event_name)
		return null
	var config: Dictionary = _events[event_name]
	if not bool(config.get("loop", false)):
		push_warning("Use play_event() for " + event_name)
		return null
	if _loops.has(key):
		var previous: Dictionary = _loops[key]
		var previous_player = previous.get("player")
		if str(previous.get("event", "")) == event_name and is_instance_valid(previous_player) and not previous_player.is_queued_for_deletion():
			return previous_player # Idempotent: do not restart a held beam or engine.
	var source: AudioStream = _pick_stream(event_name, config)
	if source == null:
		return null
	# Use a private WAV copy so loop flags never mutate a shared resource.
	var stream: AudioStreamWAV = source.duplicate() as AudioStreamWAV
	if stream == null:
		push_warning("Expected WAV loop: " + event_name)
		return null
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = int(round(stream.get_length() * stream.mix_rate))
	stop_loop(key, fade_seconds)
	if not _can_allocate(event_name, config):
		return null
	var player: AudioStreamPlayer = _new_player(event_name, config, stream)
	var target: float = player.volume_db
	player.volume_db = -60.0 if fade_seconds > 0.0 else target
	_loops[key] = {"player": player, "event": event_name}
	player.play()
	if fade_seconds > 0.0:
		_fade(player, target, fade_seconds, false)
	return player

func stop_loop(key: String, fade_seconds: float = 0.12) -> void:
	if not _loops.has(key):
		return
	var entry: Dictionary = _loops[key]
	_loops.erase(key)
	var player = entry.get("player")
	if not is_instance_valid(player):
		return
	if fade_seconds <= 0.0:
		_free_player(player)
	else:
		_fade(player, -60.0, fade_seconds, true)

func _fade(player: AudioStreamPlayer, target: float, duration: float, free_after: bool) -> void:
	if not is_instance_valid(player) or player.is_queued_for_deletion():
		return
	var old_tween: Tween = player.get_meta("vr_fade") as Tween if player.has_meta("vr_fade") else null
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	var tween: Tween = player.create_tween()
	player.set_meta("vr_fade", tween)
	tween.tween_property(player, "volume_db", target, maxf(duration, 0.01))
	if free_after:
		player.set_meta("vr_stopping", true)
		tween.tween_callback(_free_player.bind(player))

func _free_player(player: AudioStreamPlayer) -> void:
	if is_instance_valid(player) and not player.is_queued_for_deletion():
		player.stop()
		player.queue_free()

func stop_all() -> void:
	for voice in _voices:
		var player = voice.get("player")
		if is_instance_valid(player):
			_free_player(player)
	_voices.clear()
	_loops.clear()
	_last_play_ms.clear()

func _exit_tree() -> void:
	stop_all()
