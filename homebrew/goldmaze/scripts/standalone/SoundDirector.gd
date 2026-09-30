extends Node

const NAMES := ["pac_eat", "pac_move", "pac_death", "pac_super", "pac_eatfruit", "pac_extrapac", "pac_ghost", "pac_nextlevel"]
var streams := {}
var players: Array[AudioStreamPlayer] = []
var next_player := 0
var super_player := AudioStreamPlayer.new()
var maze_music_player := AudioStreamPlayer.new()
var maze_music_playback: AudioStreamGeneratorPlayback
var maze_music_phase := 0.0
var maze_music_sample := 0
const MUSIC_RATE := 22050.0
const MUSIC_STEP_SECONDS := 0.18
# Four evolving original arcade-maze phrases. Zeroes create breathing room between runs.
const MAZE_MELODY := [
	261.63, 329.63, 392.0, 523.25, 0.0, 392.0, 329.63, 293.66,
	349.23, 440.0, 523.25, 659.25, 523.25, 440.0, 392.0, 0.0,
	246.94, 293.66, 369.99, 493.88, 369.99, 293.66, 220.0, 277.18,
	329.63, 415.30, 554.37, 415.30, 329.63, 277.18, 246.94, 0.0,
	392.0, 523.25, 659.25, 783.99, 659.25, 523.25, 440.0, 392.0,
	349.23, 466.16, 587.33, 698.46, 587.33, 466.16, 392.0, 0.0,
	293.66, 369.99, 440.0, 587.33, 0.0, 554.37, 440.0, 369.99,
	261.63, 329.63, 392.0, 523.25, 493.88, 392.0, 329.63, 0.0
]

func _ready() -> void:
	for name in NAMES:
		streams[name] = load("res://assets/sounds/%s.wav" % name)
	for i in 12:
		var player := AudioStreamPlayer.new()
		add_child(player)
		players.append(player)
	add_child(super_player)
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MUSIC_RATE
	generator.buffer_length = 0.35
	maze_music_player.stream = generator
	maze_music_player.volume_db = -18.0
	add_child(maze_music_player)
	set_process(true)

func _process(_delta: float) -> void:
	if maze_music_playback == null:
		return
	var frames := maze_music_playback.get_frames_available()
	for frame_index in range(frames):
		var note_index := int(float(maze_music_sample) / (MUSIC_RATE * MUSIC_STEP_SECONDS)) % MAZE_MELODY.size()
		var frequency: float = MAZE_MELODY[note_index]
		maze_music_phase = fmod(maze_music_phase + frequency / MUSIC_RATE, 1.0) if frequency > 0.0 else 0.0
		var square := (0.10 if maze_music_phase < 0.5 else -0.10) if frequency > 0.0 else 0.0
		var pulse := sin(maze_music_phase * TAU) * 0.045 if frequency > 0.0 else 0.0
		var bass_frequency: float = 65.41 * pow(2.0, float((note_index / 8) % 4) / 12.0)
		var bass_phase := fmod(float(maze_music_sample) * bass_frequency / MUSIC_RATE, 1.0)
		var bass := (0.035 if bass_phase < 0.5 else -0.035)
		var sample := clampf(square + pulse + bass, -0.22, 0.22)
		maze_music_playback.push_frame(Vector2(sample, sample))
		maze_music_sample += 1

func start_maze_music() -> void:
	if maze_music_player.playing:
		return
	maze_music_phase = 0.0
	maze_music_sample = 0
	maze_music_player.play()
	maze_music_playback = maze_music_player.get_stream_playback() as AudioStreamGeneratorPlayback

func stop_maze_music() -> void:
	maze_music_player.stop()
	maze_music_playback = null

func set_maze_music_enabled(enabled: bool) -> void:
	if enabled:
		start_maze_music()
	else:
		stop_maze_music()

func _play(name: String, volume_db := -5.0, pitch := 1.0) -> void:
	var player := players[next_player % players.size()]
	next_player += 1
	player.stream = streams.get(name)
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()

func play_pac_eat() -> void: _play("pac_eat", -6.5, randf_range(0.98, 1.02))
func play_pac_move() -> void: _play("pac_move", -10.5, randf_range(0.98, 1.02))
func play_pac_death() -> void: stop_pac_super(); _play("pac_death")
func play_pac_eatfruit() -> void: _play("pac_eatfruit")
func play_pac_extrapac() -> void: _play("pac_extrapac")
func play_pac_ghost() -> void: _play("pac_ghost", -1.5)
func play_pac_nextlevel() -> void: stop_pac_super(); _play("pac_nextlevel", -4.0)
func play_pac_super() -> void:
	super_player.stream = streams.get("pac_super")
	super_player.volume_db = -5.5
	super_player.play()
func stop_pac_super() -> void: super_player.stop()
