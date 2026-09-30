extends Node2D

const PLAYER_COLLISION_OFFSET := 80.0
const COLLISION_WINDOW := 54.0
const WINDING_SELECT_MUSIC := "res://assets/sounds/speedwind_hoshizora_wo_koete.mp3"
const WINDING_INTRO_MUSIC := "res://assets/sounds/speedwind_1.mp3"
const WINDING_LOOP_MUSIC := ["res://assets/sounds/speedwind_2.mp3", "res://assets/sounds/speedwind_3.mp3"]
const WINDING_SELECT_LYRIC_SOURCE_SECONDS := 280.0
const WINDING_SELECT_TRACK_SECONDS := 351.624
const WINDING_SELECT_LYRICS := [
	{"t": 0.8, "speaker": "f", "text": "The shining wind is calling"},
	{"t": 4.1, "speaker": "f", "text": "Toward the far side of the sky"},
	{"t": 7.4, "speaker": "f", "text": "If I spread the wings of dreams"},
	{"t": 10.8, "speaker": "f", "text": "There is no turning back"},
	{"t": 15.0, "speaker": "f", "text": "I race across the sea of galaxies"},
	{"t": 18.6, "speaker": "f", "text": "Wrapped in blue sparks"},
	{"t": 21.7, "speaker": "f", "text": "Deep inside my heart awakens"},
	{"t": 25.0, "speaker": "f", "text": "A small courage"},
	{"t": 28.6, "speaker": "f", "text": "Even the unseen tomorrow"},
	{"t": 32.0, "speaker": "f", "text": "I will dive into without fear"},
	{"t": 35.3, "speaker": "f", "text": "Faster than a shooting star"},
	{"t": 38.6, "speaker": "f", "text": "Beyond this world"},
	{"t": 43.0, "speaker": "m", "text": "Burning in the darkness"},
	{"t": 46.1, "speaker": "m", "text": "I gaze at a red star"},
	{"t": 49.5, "speaker": "m", "text": "The broken pieces of fallen dreams"},
	{"t": 53.0, "speaker": "m", "text": "I will protect with these hands"},
	{"t": 56.5, "speaker": "m", "text": "Beyond the screaming sky"},
	{"t": 59.8, "speaker": "m", "text": "The shadows of enemies draw near"},
	{"t": 63.2, "speaker": "m", "text": "Even so, your voice"},
	{"t": 66.4, "speaker": "m", "text": "Lights the way"},
	{"t": 70.3, "speaker": "f", "text": "Wind, blow stronger"},
	{"t": 73.2, "speaker": "f", "text": "Carry me away"},
	{"t": 76.2, "speaker": "m", "text": "Flame, rise higher"},
	{"t": 79.2, "speaker": "m", "text": "Reach all the way to the future"},
	{"t": 83.0, "speaker": "d", "text": "Fly beyond the starry sky"},
	{"t": 86.3, "speaker": "d", "text": "Become an arrow of light"},
	{"t": 89.7, "speaker": "d", "text": "The dream is still burning"},
	{"t": 93.0, "speaker": "d", "text": "Toward the endless sky"},
	{"t": 96.5, "speaker": "d", "text": "Go, pierce through the galaxy"},
	{"t": 100.0, "speaker": "d", "text": "Hold hope close"},
	{"t": 103.0, "speaker": "d", "text": "With you, I am not afraid"},
	{"t": 106.5, "speaker": "d", "text": "We can fly all the way to a miracle"},
	{"t": 111.5, "speaker": "f", "text": "Ah, to the sparkling world"},
	{"t": 115.0, "speaker": "m", "text": "Ah, beyond destiny"},
	{"t": 119.0, "speaker": "f", "text": "Inside the rainbow-colored clouds"},
	{"t": 122.5, "speaker": "f", "text": "A sleeping dragon awakens"},
	{"t": 126.0, "speaker": "f", "text": "Even if the shaking earth breaks apart"},
	{"t": 129.6, "speaker": "f", "text": "I will keep moving forward"},
	{"t": 133.2, "speaker": "f", "text": "Even tears can now"},
	{"t": 136.2, "speaker": "f", "text": "Be changed into light"},
	{"t": 139.2, "speaker": "f", "text": "The melody deep inside my heart"},
	{"t": 142.8, "speaker": "f", "text": "Echo into the sky"},
	{"t": 147.0, "speaker": "m", "text": "Let the steel wings ring out"},
	{"t": 150.3, "speaker": "m", "text": "Overtaking the thunder"},
	{"t": 153.6, "speaker": "m", "text": "Cutting through the approaching shadows"},
	{"t": 157.0, "speaker": "m", "text": "Like a hero"},
	{"t": 160.5, "speaker": "m", "text": "If you believe"},
	{"t": 163.2, "speaker": "m", "text": "Limits will disappear"},
	{"t": 166.4, "speaker": "m", "text": "Do not let go of this hand"},
	{"t": 169.8, "speaker": "m", "text": "Let us break through the night"},
	{"t": 174.0, "speaker": "f", "text": "Even if the world falls apart"},
	{"t": 177.4, "speaker": "f", "text": "I will search for your voice"},
	{"t": 181.0, "speaker": "m", "text": "Even if the sky is closed off"},
	{"t": 184.4, "speaker": "m", "text": "The fire in my chest will not go out"},
	{"t": 188.5, "speaker": "d", "text": "Even if thousands of stars fall"},
	{"t": 192.2, "speaker": "d", "text": "Even if tens of thousands of darknesses come"},
	{"t": 196.2, "speaker": "d", "text": "Together, we can fly"},
	{"t": 199.4, "speaker": "d", "text": "Toward the future"},
	{"t": 203.6, "speaker": "d", "text": "Fly beyond the starry sky"},
	{"t": 207.0, "speaker": "d", "text": "Become an arrow of light"},
	{"t": 210.4, "speaker": "d", "text": "The dream is still burning"},
	{"t": 213.8, "speaker": "d", "text": "Toward the endless sky"},
	{"t": 217.4, "speaker": "d", "text": "Go, pierce through the galaxy"},
	{"t": 220.8, "speaker": "d", "text": "Hold hope close"},
	{"t": 224.0, "speaker": "d", "text": "With you, I am not afraid"},
	{"t": 227.6, "speaker": "d", "text": "We can fly all the way to a miracle"},
	{"t": 232.0, "speaker": "d", "text": "Fly, even beyond time and space"},
	{"t": 235.6, "speaker": "d", "text": "Until the dazzling morning"},
	{"t": 239.0, "speaker": "d", "text": "With love and dreams as our weapons"},
	{"t": 242.8, "speaker": "d", "text": "We will keep fighting"},
	{"t": 246.5, "speaker": "d", "text": "Go, let your life shine"},
	{"t": 249.8, "speaker": "d", "text": "Take back tomorrow"},
	{"t": 253.0, "speaker": "d", "text": "Let us make it echo through this sky"},
	{"t": 257.0, "speaker": "d", "text": "The melody of victory"},
	{"t": 262.0, "speaker": "f", "text": "The shining wind is calling"},
	{"t": 265.6, "speaker": "f", "text": "Toward the far side of the sky"},
	{"t": 269.3, "speaker": "m", "text": "With you, I can go anywhere"},
	{"t": 272.7, "speaker": "m", "text": "I can fly"},
	{"t": 276.0, "speaker": "d", "text": "Beyond the starry sky"},
	{"t": 279.6, "speaker": "d", "text": "Toward the future"}
]
const SFX_PLAYER_SHOT := "res://assets/sounds/Ground_Rifle_Shot.wav"
const SFX_PLAYER_FIREBALL := "res://assets/sounds/Ground_Fireball_Shot.wav"
const SFX_PLAYER_LASER := "res://assets/sounds/Ground_Laser_Shot.wav"
const SFX_PLAYER_MACHINE := "res://assets/sounds/Ground_MachineGun_Shot.wav"
const SFX_PLAYER_RAPID := "res://assets/sounds/Ground_Rapid_Shot.wav"
const SFX_PLAYER_ROCKET := "res://assets/sounds/Ground_RocketLauncher_Shot.wav"
const SFX_PLAYER_SPREAD := "res://assets/sounds/Ground_Spread_Shot.wav"
const SFX_ENEMY_SHOT := "res://assets/sounds/Ground_Rapid_Shot.wav"
const SFX_EXPLOSION := "res://assets/sounds/explosion.wav"
const SFX_POWERUP := "res://assets/sounds/Ground_Powerup_Pickup.wav"
const SFX_CARRIER := "res://assets/sounds/Ground_Powerup_Spawn.wav"
const SFX_COUNTDOWN := "res://assets/sounds/countdown.wav"
const SFX_WINDING_ENGINE_LOOP := "res://assets/sounds/badlands_rocket-loop.mp3"
const SFX_WINDING_FLYBY := "res://assets/sounds/airstrike_flyby.mp3"
const SFX_WINDING_BULLET_WHIZ := "res://assets/sounds/Ground_Rapid_Shot.wav"
const SFX_WINDING_TUNNEL_ECHO := "res://assets/sounds/badlands_rocket-loop.mp3"
const WINDING_PICKUP_SCREEN_DRIFT_SPEED := 250.0
const WINDING_COIN_TEXTURE_PATH := "res://assets/sprites/speedbike/pickups/coin_gold.png"
const WINDING_COIN_CHAIN_COLLISION_Z := 118.0
const WINDING_COIN_CHAIN_COLLISION_LANE := 0.52
const WINDING_COIN_CHAIN_COLLISION_Y := 132.0
const WINDING_COMBAT_FOCUS_NO_ROAD_OBJECTS := true
const WINDING_ENEMY_SMOKE_HEALTH_RATIO := 0.42
const HARRIER_PERSPECTIVE_STRENGTH := 680.0
const HARRIER_NEAR_DEPTH := 95.0
const HARRIER_FAR_DEPTH := 1900.0
const HARRIER_MAX_ENEMIES := 7
const HARRIER_MAX_BULLETS := 4
const HARRIER_ENEMY_TEXTURE_PATHS := {
	"straight_charger": "res://assets/sprites/speedbike/enemies/speedbike_interceptor_drone.png",
	"side_waver": "res://assets/sprites/speedbike/enemies/speedbike_enemy_khoudri.png",
	"shooter": "res://assets/sprites/speedbike/enemies/speedbike_enemy_garthok.png",
	"swarm": "res://assets/sprites/speedbike/enemies/speedbike_enemy_beep.png",
	"powerup_carrier": "res://assets/sprites/speedbike/enemies/speedbike_powerup_carrier.png"
}
const WINDING_PICKUP_TEXTURE_PATHS := {
	"rapid": "res://assets/sprites/speedbike/pickups/pickup_rapid.png",
	"cannon_boost": "res://assets/sprites/speedbike/pickups/pickup_rapid.png",
	"fireball": "res://assets/sprites/speedbike/pickups/pickup_fireball.png",
	"laser": "res://assets/sprites/speedbike/pickups/pickup_laser.png",
	"machine": "res://assets/sprites/speedbike/pickups/pickup_machine.png",
	"spread": "res://assets/sprites/speedbike/pickups/pickup_spread.png",
	"rocket": "res://assets/sprites/speedbike/pickups/pickup_rocket.png",
	"repair": "res://assets/sprites/speedbike/pickups/pickup_health_green.png",
	"health": "res://assets/sprites/speedbike/pickups/pickup_health_green.png",
	"green": "res://assets/sprites/speedbike/pickups/pickup_health_green.png",
	"blue": "res://assets/sprites/speedbike/pickups/pickup_health_blue.png",
	"purple": "res://assets/sprites/speedbike/pickups/pickup_health_purple.png",
	"gold": "res://assets/sprites/speedbike/pickups/pickup_health_gold.png",
	"extra_life": "res://assets/sprites/speedbike/pickups/pickup_extra_life.png",
	"1up": "res://assets/sprites/speedbike/pickups/pickup_extra_life.png",
	"one_up": "res://assets/sprites/speedbike/pickups/pickup_extra_life.png",
	"life": "res://assets/sprites/speedbike/pickups/pickup_extra_life.png"
}
const WINDING_BIKE_CONTROLLER_SCRIPT := preload("res://scripts/speedbike/WindingBikeController.gd")
const WINDING_OBSTACLE_SCRIPT := preload("res://scripts/speedbike/WindingObstacle.gd")
const WINDING_PATTERN_RUNNER_SCRIPT := preload("res://scripts/speedbike/WindingPatternRunner.gd")
const RIDER_DEFS := {
	"female": {
		"label": "Engineer",
		"ride_path": "res://assets/sprites/speedbike/speedwind_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedwind_jump.png",
		"horizontal_mult": 1.0,
		"jump_height_add": 0.0,
		"jump_duration_mult": 1.0,
		"shot_cooldown_mult": 1.0,
		"winding_scale_mult": 1.0,
		"start_weapon": "machine",
		"stats": "Balanced handling, clean jumps, steady cannon."
	},
	"gunner": {
		"label": "Gunner",
		"ride_path": "res://assets/sprites/speedbike/speedwind_gunner_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedwind_gunner_jump.png",
		"horizontal_mult": 0.94,
		"jump_height_add": -4.0,
		"jump_duration_mult": 1.08,
		"shot_cooldown_mult": 0.82,
		"winding_scale_mult": 1.04,
		"start_weapon": "spread",
		"stats": "Heavier turn-in, tougher cannon rhythm, steadier fire."
	},
	"scout": {
		"label": "Scout",
		"ride_path": "res://assets/sprites/speedbike/speedwind_scout_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedwind_scout_jump.png",
		"horizontal_mult": 1.12,
		"jump_height_add": 10.0,
		"jump_duration_mult": 0.94,
		"shot_cooldown_mult": 1.10,
		"winding_scale_mult": 0.96,
		"start_weapon": "laser",
		"stats": "Fast lane cuts, high jump arc, lighter cannon pace."
	}
}

var level_data: Dictionary = {}
var stage_id := "badlands_speedbike_50"
var camera_z := 0.0
var stage_origin_z := 0.0
var checkpoint_z := 0.0
var speed := 720.0
var deaths := 0
var lives := 3
var score := 0
var elapsed := 0.0
var run_elapsed := 0.0
var stage_clear := false
var restart_timer := 0.0
var pause_open := false
var pause_confirm_action := ""
var pause_confirm_timer := 0.0
var rider_select_open := false
var selected_rider_id := "female"
var checkpoint_message_timer := 0.0
var warning_timer := 5.0
var perf_baseline := true
var countdown_timer := 0.0
var countdown_active := false
var countdown_started_run := false
var countdown_last_label := ""
var countdown_delay_timer := 0.0
var go_flash_timer := 0.0
var weather_kind := "clear"
var lightning_timer := 0.0
var lightning_flash := 0.0
var lightning_points: PackedVector2Array = PackedVector2Array()
var snow_coverage := 0.0
var snowflakes: Array[Dictionary] = []
var screen_impact_flash := 0.0
var screen_impact_anchor := Vector2(0.5, 0.46)

var renderer: Pseudo3DRoadRenderer
var player: Node2D
var pattern_runner: RefCounted = WINDING_PATTERN_RUNNER_SCRIPT.new()
var obstacles: Array[Node] = []
var obstacle_rows: Array[Dictionary] = []
var next_obstacle_index := 0
var player_shots: Array[Dictionary] = []
var enemy_shots: Array[Dictionary] = []
var active_pickups: Array[Dictionary] = []
var active_coin_chains: Array[Dictionary] = []
var coin_collect_fx: Array[Dictionary] = []
var coin_chain_cooldown := 2.2
var coin_chain_serial := 0
var coin_sfx_step := 0
var coin_combo_count := 0
var coin_combo_display_timer := 0.0
var coin_combo_bank_timer := 0.0
var coin_combo_bank_amount := 0
var harrier_enemies: Array[Dictionary] = []
var harrier_enemy_bullets: Array[Dictionary] = []
var harrier_wave_timer := 1.4
var harrier_wave_index := 0
var enemy_fire_timers: Dictionary = {}
var player_shot_sfx_timer := 0.0
var winding_weapon_kind := "rifle"
var winding_spread_ammo := 0
var winding_rocket_ammo := 0
var hit_combo_timer := 0.0
var hit_combo_count := 0
var next_harrier_wave_id := 1
var harrier_wave_stats: Dictionary = {}
var hit_pops: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var weather_overlay: Node2D
var camera: Camera2D
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var engine_loop_player: AudioStreamPlayer
var tunnel_echo_player: AudioStreamPlayer
var winding_sfx_players: Array[AudioStreamPlayer] = []
var winding_sfx_index := 0
var spatial_sfx_players: Array[AudioStreamPlayer2D] = []
var spatial_sfx_index := 0
var enemy_audio_state: Dictionary = {}
var bullet_whiz_cooldown := 0.0
var skid_sfx_cooldown := 0.0
var music_loop_index := 0
var winding_music_cache: Dictionary = {}
var winding_sfx_cache: Dictionary = {}
var winding_pickup_texture_cache: Dictionary = {}
var winding_coin_texture: Texture2D
var harrier_texture_cache: Dictionary = {}
var select_fx_overlay: Node2D

var obstacle_layer: Node2D
var hud_layer: CanvasLayer
var speed_label: Label
var score_label: Label
var stage_label: Label
var lives_label: Label
var weapon_label: Label
var coin_combo_label: Label
var health_bar: WindingHealthTube
var progress_bar: ProgressBar
var message_label: Label
var countdown_label: Label
var result_panel: PanelContainer
var pause_panel: PanelContainer
var rider_select_panel: PanelContainer
var ship_view_panel: PanelContainer
var ship_preview: Control
var ship_info_label: Label
var karaoke_overlay: Node2D
var gauge_overlay: Node2D
var bullet_overlay: Node2D
var select_music_started_msec := 0


func _ready() -> void:
	_resolve_stage()
	_ensure_nodes()
	_load_stage(stage_id, true)
	_show_rider_select()
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if rider_select_open:
		if event.is_action_pressed("ui_accept"):
			_deploy_winding_rider()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if stage_clear:
		return
	if rider_select_open:
		_tick_rider_select_backdrop(delta)
		return
	if pause_open:
		return
	if restart_timer > 0.0:
		restart_timer -= delta
		if restart_timer <= 0.0:
			_restart_from_checkpoint()
		_update_hud()
		return

	elapsed += delta
	run_elapsed += delta
	var difficulty := _speedbike_difficulty()
	var speed_scale := float(difficulty.get("speed_scale", 1.0))
	var multiplier := float(PlayState.speedbike_speed_multiplier)
	var base_speed := float(level_data.get("base_speed", 720.0))
	var target_speed := minf(base_speed + elapsed * float(level_data.get("speed_gain", 28.0)), base_speed * 1.62)
	speed = lerpf(speed, target_speed, clampf(delta * 1.8, 0.0, 1.0))
	var effective_speed := speed * speed_scale * multiplier
	if player != null and is_instance_valid(player) and (float(player.flight_y) < -72.0 or float(player.jump_z) > 18.0):
		effective_speed *= 0.82
	if player != null and is_instance_valid(player):
		effective_speed *= clampf(float(player.speed_drag_factor), 0.36, 1.0)
		effective_speed *= clampf(float(player.speed_thrust_factor), 1.0, 1.55)
	camera_z += effective_speed * delta
	_update_dynamic_road_scale()
	renderer.set_camera_z(camera_z)
	screen_impact_flash = maxf(screen_impact_flash - delta, 0.0)
	player_shot_sfx_timer = maxf(player_shot_sfx_timer - delta, 0.0)
	bullet_whiz_cooldown = maxf(bullet_whiz_cooldown - delta, 0.0)
	skid_sfx_cooldown = maxf(skid_sfx_cooldown - delta, 0.0)
	pause_confirm_timer = maxf(pause_confirm_timer - delta, 0.0)
	if pause_confirm_timer <= 0.0:
		pause_confirm_action = ""
	coin_combo_display_timer = maxf(coin_combo_display_timer - delta, 0.0)
	coin_combo_bank_timer = maxf(coin_combo_bank_timer - delta, 0.0)
	if winding_spread_ammo <= 0 and winding_rocket_ammo <= 0 and winding_weapon_kind in ["spread", "rocket"]:
		winding_weapon_kind = "rifle"
	hit_combo_timer = maxf(hit_combo_timer - delta, 0.0)
	if hit_combo_timer <= 0.0:
		hit_combo_count = 0
	if weather_overlay != null:
		weather_overlay.queue_redraw()
	if not perf_baseline:
		_tick_weather(delta)
	if countdown_delay_timer > 0.0:
		countdown_delay_timer -= delta
		if countdown_delay_timer <= 0.0:
			_begin_winding_countdown()
		_update_hud()
		return
	if countdown_active:
		_tick_countdown(delta)
		_update_hud()
		return
	_tick_winding_audio(delta, effective_speed)

	var force_scale := float(level_data.get("curve_force", 0.6))
	if _player_in_gravity_zone():
		force_scale *= 1.28
		player.jump_duration = 0.78
	else:
		player.jump_duration = 0.58
	player.set("fire_cooldown", _winding_fire_cooldown_for_weapon())
	if player.has_method("set_weapon_glow"):
		player.set_weapon_glow(_winding_weapon_color(_active_winding_weapon()), _winding_weapon_glow_strength())
	player.max_flight_height = 82.0 if str(level_data.get("theme_id", "")) == "red_tunnel" else 430.0
	player.tick(delta, renderer, camera_z, effective_speed, force_scale)
	if player.has_method("consume_spinout_request") and player.consume_spinout_request():
		_crash("E-BRAKE SPINOUT")
		return

	_update_obstacles()
	_tick_winding_combat(delta, effective_speed)
	_handle_collisions()
	_handle_checkpoints()
	_handle_stage_clear()
	_update_hud()


func _resolve_stage() -> void:
	stage_id = str(PlayState.skirmish_map_id if PlayState.is_speedbike_map(PlayState.skirmish_map_id) else PlayState.current_map_id)
	if not WindingLevelData.is_winding_stage(stage_id):
		stage_id = WindingLevelData.stage_id(WindingLevelData.FIRST_STAGE)
	PlayState.current_map_id = stage_id
	PlayState.skirmish_map_id = stage_id


func _load_stage(map_id: String, reset_run := false, carried_speed := 0.0, seamless := false) -> void:
	level_data = WindingLevelData.get_level(map_id)
	stage_id = str(level_data.get("stage_id", map_id))
	if reset_run:
		camera_z = 0.0
		stage_origin_z = 0.0
	elif seamless:
		stage_origin_z = camera_z
	else:
		camera_z = 0.0
		stage_origin_z = 0.0
	checkpoint_z = stage_origin_z
	speed = maxf(float(level_data.get("base_speed", 720.0)), carried_speed)
	if reset_run:
		deaths = 0
		lives = 3
		score = 0
		run_elapsed = 0.0
		winding_weapon_kind = "rifle"
		winding_spread_ammo = 0
		winding_rocket_ammo = 0
		coin_combo_count = 0
		coin_combo_display_timer = 0.0
		coin_combo_bank_timer = 0.0
		coin_combo_bank_amount = 0
	elapsed = 0.0
	stage_clear = false
	restart_timer = 0.0
	checkpoint_message_timer = 0.0
	warning_timer = 5.0
	renderer.perf_baseline = perf_baseline
	renderer.stage_origin_z = stage_origin_z
	renderer.configure(level_data)
	_configure_weather()
	pattern_runner.configure(level_data)
	if not seamless:
		_clear_obstacles()
	obstacle_rows.clear()
	for row in level_data.get("obstacles", []):
		var shifted := (row as Dictionary).duplicate(true)
		shifted["z"] = float(shifted.get("z", 0.0)) + stage_origin_z
		obstacle_rows.append(shifted)
	obstacle_rows.sort_custom(_sort_obstacle_rows)
	next_obstacle_index = 0
	if not seamless:
		player_shots.clear()
		enemy_shots.clear()
		active_coin_chains.clear()
		coin_collect_fx.clear()
		coin_chain_cooldown = 2.2
		harrier_enemies.clear()
		harrier_enemy_bullets.clear()
		harrier_wave_stats.clear()
		enemy_audio_state.clear()
	harrier_wave_timer = 1.25
	harrier_wave_index = 0
	next_harrier_wave_id = 1
	if not seamless:
		enemy_fire_timers.clear()
		hit_pops.clear()
		explosions.clear()
	_spawn_obstacles_near()
	var difficulty := _speedbike_difficulty()
	if reset_run:
		player.setup_hits(int(difficulty.get("hits", 4)) if not bool(difficulty.get("instant_crash", false)) else 1)
		player.reset()
	_apply_selected_rider_profile()
	_update_hud()
	_show_message(str(level_data.get("warning", "")), 4.0)


func _ensure_nodes() -> void:
	camera = get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.enabled = false
	renderer = get_node_or_null("RoadRenderer") as Pseudo3DRoadRenderer
	if renderer == null:
		renderer = Pseudo3DRoadRenderer.new()
		renderer.name = "RoadRenderer"
		add_child(renderer)
	obstacle_layer = get_node_or_null("ObstacleLayer") as Node2D
	if obstacle_layer == null:
		obstacle_layer = Node2D.new()
		obstacle_layer.name = "ObstacleLayer"
		add_child(obstacle_layer)
	weather_overlay = get_node_or_null("WeatherOverlay") as Node2D
	if weather_overlay == null:
		weather_overlay = WeatherOverlay.new()
		weather_overlay.name = "WeatherOverlay"
		weather_overlay.z_index = 30
		add_child(weather_overlay)
	weather_overlay.visible = true
	if weather_overlay is WeatherOverlay:
		(weather_overlay as WeatherOverlay).mode = self
	player = get_node_or_null("PlayerBike") as Node2D
	if player == null:
		player = WINDING_BIKE_CONTROLLER_SCRIPT.new()
		player.name = "PlayerBike"
		add_child(player)
	if not player.shot_fired.is_connected(_on_player_shot):
		player.shot_fired.connect(_on_player_shot)
	music_player = get_node_or_null("Music") as AudioStreamPlayer
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.name = "Music"
		add_child(music_player)
	if not music_player.finished.is_connected(_on_winding_music_finished):
		music_player.finished.connect(_on_winding_music_finished)
	_cache_winding_music()
	sfx_player = get_node_or_null("Sfx") as AudioStreamPlayer
	if sfx_player == null:
		sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "Sfx"
		add_child(sfx_player)
	engine_loop_player = get_node_or_null("WindingEngineLoop") as AudioStreamPlayer
	if engine_loop_player == null:
		engine_loop_player = AudioStreamPlayer.new()
		engine_loop_player.name = "WindingEngineLoop"
		add_child(engine_loop_player)
	tunnel_echo_player = get_node_or_null("WindingTunnelEcho") as AudioStreamPlayer
	if tunnel_echo_player == null:
		tunnel_echo_player = AudioStreamPlayer.new()
		tunnel_echo_player.name = "WindingTunnelEcho"
		add_child(tunnel_echo_player)
	_ensure_winding_sfx_pool()
	_ensure_spatial_sfx_pool()
	_cache_winding_sfx()
	hud_layer = get_node_or_null("Hud") as CanvasLayer
	if hud_layer == null:
		hud_layer = CanvasLayer.new()
		hud_layer.name = "Hud"
		add_child(hud_layer)
	_build_hud()


func _build_hud() -> void:
	for child in hud_layer.get_children():
		child.queue_free()
	var root := Control.new()
	root.name = "HudRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(root)

	var top_bar := HBoxContainer.new()
	top_bar.position = Vector2(24.0, 18.0)
	top_bar.size = Vector2(1180.0, 44.0)
	top_bar.add_theme_constant_override("separation", 14)
	root.add_child(top_bar)

	stage_label = _hud_label("STAGE 50")
	top_bar.add_child(stage_label)
	score_label = _hud_label("SCORE 0")
	top_bar.add_child(score_label)
	speed_label = _hud_label("SPD 0000")
	top_bar.add_child(speed_label)
	lives_label = _hud_label("LIVES 3")
	top_bar.add_child(lives_label)
	weapon_label = _hud_label("RIFLE")
	weapon_label.add_theme_font_size_override("font_size", 17)
	top_bar.add_child(weapon_label)
	coin_combo_label = _hud_label("")
	coin_combo_label.custom_minimum_size = Vector2(210.0, 26.0)
	coin_combo_label.add_theme_font_size_override("font_size", 18)
	coin_combo_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.24))
	top_bar.add_child(coin_combo_label)

	health_bar = WindingHealthTube.new()
	health_bar.custom_minimum_size = Vector2(210.0, 22.0)
	top_bar.add_child(health_bar)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(24.0, 66.0)
	progress_bar.size = Vector2(420.0, 18.0)
	progress_bar.max_value = 1.0
	progress_bar.show_percentage = false
	root.add_child(progress_bar)

	message_label = Label.new()
	message_label.position = Vector2(24.0, 96.0)
	message_label.size = Vector2(740.0, 56.0)
	message_label.add_theme_font_size_override("font_size", 22)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.34))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(message_label)
	countdown_label = Label.new()
	countdown_label.visible = false
	countdown_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 96)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.20))
	countdown_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	countdown_label.add_theme_constant_override("shadow_offset_x", 4)
	countdown_label.add_theme_constant_override("shadow_offset_y", 5)
	root.add_child(countdown_label)
	gauge_overlay = WindingHudGaugeOverlay.new()
	gauge_overlay.name = "WindingHudGaugeOverlay"
	gauge_overlay.set("mode", self)
	root.add_child(gauge_overlay)
	bullet_overlay = WindingBulletOverlay.new()
	bullet_overlay.name = "WindingBulletOverlay"
	bullet_overlay.set("mode", self)
	root.add_child(bullet_overlay)
	select_fx_overlay = WindingSelectFxOverlay.new()
	select_fx_overlay.name = "WindingSelectFxOverlay"
	select_fx_overlay.set("mode", self)
	select_fx_overlay.visible = false
	root.add_child(select_fx_overlay)

	result_panel = _modal_panel("Winding Run Complete", true)
	result_panel.visible = false
	root.add_child(result_panel)
	pause_panel = _modal_panel("Paused", false)
	pause_panel.visible = false
	root.add_child(pause_panel)
	rider_select_panel = _build_rider_select_panel()
	rider_select_panel.visible = false
	root.add_child(rider_select_panel)
	ship_view_panel = _build_ship_view_panel()
	ship_view_panel.visible = false
	root.add_child(ship_view_panel)
	karaoke_overlay = WindingKaraokeOverlay.new()
	karaoke_overlay.name = "WindingKaraokeOverlay"
	karaoke_overlay.set("mode", self)
	karaoke_overlay.visible = false
	root.add_child(karaoke_overlay)


func _hud_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(152.0, 26.0)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.94, 0.86, 0.70))
	return label


func _modal_panel(title: String, is_result: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2(320.0, 96.0 if not is_result else 150.0)
	panel.custom_minimum_size = Vector2(660.0 if not is_result else 560.0, 520.0 if not is_result else 300.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.018, 0.012, 0.92)
	panel_style.border_color = Color(0.92, 0.66, 0.34, 0.88)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	var heading := Label.new()
	heading.name = "Heading"
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 30)
	box.add_child(heading)
	var body := Label.new()
	body.name = "Body"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 18)
	box.add_child(body)
	var button := Button.new()
	button.text = "Continue" if is_result else "Continue Run"
	if is_result:
		button.pressed.connect(_on_modal_button_pressed.bind(panel, is_result))
	else:
		button.pressed.connect(_resume_winding_pause)
	box.add_child(button)
	if not is_result:
		box.add_child(_pause_option_button("Restart From Checkpoint", _confirm_pause_restart.bind("checkpoint")))
		box.add_child(_pause_option_button("Restart Level From Beginning", _confirm_pause_restart.bind("beginning")))
		var options_label := Label.new()
		options_label.text = "OPTIONS"
		options_label.add_theme_font_size_override("font_size", 18)
		options_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.44))
		box.add_child(options_label)
		box.add_child(_pause_option_button("CHECKPOINTS: %s" % ("ON" if _checkpoints_enabled() else "OFF"), _toggle_winding_checkpoints))
		box.add_child(_pause_option_button("BOTTOM TIPS: %s" % ("ON" if AppState.show_tooltips else "OFF"), _toggle_winding_tooltips))
		var controls := Label.new()
		controls.text = "Controls: W/A/S/D or D-pad steer/fly, Shift/LB brakes on-road, Space/A is the emergency brake on-road, Enter/X or mouse fires."
		controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		controls.add_theme_font_size_override("font_size", 14)
		box.add_child(controls)
		box.add_child(_pause_slider_row("MASTER", AppState.master_volume, _on_winding_master_volume_changed))
		box.add_child(_pause_slider_row("MUSIC", AppState.music_volume, _on_winding_music_volume_changed))
		box.add_child(_pause_slider_row("SFX", AppState.sfx_volume, _on_winding_sfx_volume_changed))
	var exit_button := Button.new()
	exit_button.text = "Return To War Room"
	exit_button.pressed.connect(_return_to_menu)
	box.add_child(exit_button)
	return panel


func _pause_option_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button


func _pause_slider_row(label_text: String, value: float, callback: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(78.0, 24.0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = roundi(clampf(value, 0.0, 1.0) * 100.0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	row.add_child(slider)
	return row


func _update_obstacles() -> void:
	_spawn_obstacles_near()
	for index in range(obstacles.size() - 1, -1, -1):
		var obstacle: Node = obstacles[index]
		if not is_instance_valid(obstacle):
			obstacles.remove_at(index)
			continue
		var rel_z := float(obstacle.world_z) - camera_z
		var is_air := str(obstacle.obstacle_type) in ["drone", "dropper_drone", "powerup_carrier"]
		var behind_limit := -1450.0 if is_air else -520.0
		if rel_z < behind_limit:
			obstacle.queue_free()
			obstacles.remove_at(index)
			continue
		if (not is_air and rel_z < -180.0) or rel_z > renderer.visible_distance + 520.0:
			obstacle.visible = false
			continue
		obstacle.tick(renderer, camera_z)


func _tick_countdown(delta: float) -> void:
	countdown_timer -= delta
	var label := "3"
	if countdown_timer <= 1.0:
		label = "1"
	elif countdown_timer <= 2.0:
		label = "2"
	if label != countdown_last_label:
		countdown_last_label = label
		_set_countdown_text(label)
	if countdown_timer <= 0.0:
		countdown_active = false
		countdown_started_run = true
		countdown_last_label = ""
		go_flash_timer = 0.72
		_set_countdown_text("GO!")
		_show_message("GO!", 0.8)


func _tick_winding_combat(delta: float, effective_speed: float) -> void:
	_tick_harrier_waves(delta)
	_tick_harrier_enemies(delta)
	_tick_harrier_enemy_bullets(delta)
	_tick_player_shots(delta, effective_speed)
	enemy_shots.clear()
	_tick_winding_pickups(delta, effective_speed)
	_tick_winding_coin_chains(delta)
	_tick_coin_collect_fx(delta)
	_tick_hit_pops(delta)
	_tick_explosions(delta)
	if bullet_overlay != null:
		bullet_overlay.queue_redraw()


func _tick_harrier_waves(delta: float) -> void:
	if harrier_enemies.size() >= HARRIER_MAX_ENEMIES:
		return
	harrier_wave_timer -= delta
	if harrier_wave_timer > 0.0:
		return
	var stage := int(level_data.get("stage", 50))
	var pattern := harrier_wave_index % 5
	match pattern:
		0:
			_spawn_harrier_wave("straight_charger", "horizontal_line", 3)
		1:
			_spawn_harrier_wave("side_waver", "v_shape", 4)
		2:
			_spawn_harrier_wave("shooter", "left_center_right", 3)
		3:
			_spawn_harrier_wave("swarm", "diagonal", 4)
		_:
			if stage >= 54:
				_spawn_harrier_wave("shooter", "circle", 5)
			else:
				_spawn_harrier_wave("powerup_carrier", "center", 1)
	harrier_wave_index += 1
	harrier_wave_timer = randf_range(5.2, 8.2)


func _spawn_harrier_wave(enemy_type: String, pattern: String, count: int) -> void:
	var positions := _harrier_pattern_positions(pattern, count)
	var wave_id := next_harrier_wave_id
	next_harrier_wave_id += 1
	harrier_wave_stats[wave_id] = {"total": positions.size(), "killed": 0, "escaped": 0, "rewarded": false}
	for i in range(positions.size()):
		if harrier_enemies.size() >= HARRIER_MAX_ENEMIES:
			return
		var pos := positions[i] as Vector2
		var far_depth := randf_range(1620.0, HARRIER_FAR_DEPTH)
		var speed_base := randf_range(230.0, 330.0) + float(int(level_data.get("stage", 50)) - 50) * 4.0
		var hp := 2
		if enemy_type == "shooter":
			hp = 3
		elif enemy_type == "powerup_carrier":
			hp = 2
		harrier_enemies.append({
			"type": enemy_type,
			"lane_x": pos.x,
			"lane_y": pos.y,
			"z_depth": far_depth + float(i) * 42.0,
			"speed": speed_base,
			"life": 0.0,
			"hp": hp,
			"max_hp": hp,
			"state": "enter",
			"aim_timer": randf_range(0.68, 0.92),
			"has_shot": false,
			"wave_phase": randf() * TAU,
			"hit_flash": 0.0,
			"hit_kick": 0.0,
			"smoking": false,
			"smoke_phase": randf() * TAU,
			"fall_roll": 0.0,
			"audio_id": "%d_%d" % [wave_id, i],
			"wave_id": wave_id
		})


func _harrier_pattern_positions(pattern: String, count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	match pattern:
		"horizontal_line":
			for i in range(count):
				var t := 0.0 if count <= 1 else float(i) / float(count - 1)
				positions.append(Vector2(lerpf(-520.0, 520.0, t), randf_range(-70.0, 110.0)))
		"left_center_right":
			for x in [-420.0, 0.0, 420.0]:
				positions.append(Vector2(x, randf_range(-40.0, 120.0)))
		"v_shape":
			var mid := float(count - 1) * 0.5
			for i in range(count):
				var offset := float(i) - mid
				positions.append(Vector2(offset * 190.0, absf(offset) * -52.0 + 70.0))
		"circle":
			for i in range(count):
				var angle := float(i) / float(count) * TAU
				positions.append(Vector2(cos(angle) * 360.0, sin(angle) * 150.0 + 20.0))
		"diagonal":
			for i in range(count):
				positions.append(Vector2(-480.0 + float(i) * 230.0, -150.0 + float(i) * 72.0))
		_:
			positions.append(Vector2(0.0, 0.0))
	return positions


func _tick_harrier_enemies(delta: float) -> void:
	for index in range(harrier_enemies.size() - 1, -1, -1):
		var enemy := harrier_enemies[index]
		var enemy_type := str(enemy.get("type", "straight_charger"))
		var z_depth := float(enemy.get("z_depth", HARRIER_FAR_DEPTH))
		var speed_value := float(enemy.get("speed", 300.0))
		var life := float(enemy.get("life", 0.0)) + delta
		var state := str(enemy.get("state", "enter"))
		if enemy_type == "side_waver" or enemy_type == "swarm":
			var phase := float(enemy.get("wave_phase", 0.0))
			enemy["lane_x"] = float(enemy.get("lane_x", 0.0)) + sin(life * 2.15 + phase) * 46.0 * delta
		if bool(enemy.get("smoking", false)):
			var smoke_phase := float(enemy.get("smoke_phase", 0.0))
			enemy["lane_y"] = float(enemy.get("lane_y", 0.0)) + (52.0 + clampf(life, 0.0, 4.0) * 10.0) * delta
			enemy["lane_x"] = float(enemy.get("lane_x", 0.0)) + sin(life * 5.1 + smoke_phase) * 34.0 * delta
			enemy["fall_roll"] = float(enemy.get("fall_roll", 0.0)) + delta * 4.0
		if enemy_type == "shooter":
			if state == "enter" and z_depth < 1040.0:
				state = "aim"
			if state == "aim":
				speed_value *= 0.42
				enemy["aim_timer"] = float(enemy.get("aim_timer", 0.4)) - delta
				if float(enemy.get("aim_timer", 0.0)) <= 0.0:
					state = "fire"
			if state == "fire":
				_spawn_harrier_bullet(enemy)
				enemy["has_shot"] = true
				state = "exit"
		z_depth -= speed_value * delta
		enemy["z_depth"] = z_depth
		enemy["life"] = life
		enemy["state"] = state
		enemy["hit_flash"] = maxf(float(enemy.get("hit_flash", 0.0)) - delta, 0.0)
		enemy["hit_kick"] = maxf(float(enemy.get("hit_kick", 0.0)) - delta, 0.0)
		if z_depth <= HARRIER_NEAR_DEPTH:
			if _harrier_enemy_hits_player(enemy):
				_add_explosion(camera_z + PLAYER_COLLISION_OFFSET, player.lane_pos, player.flight_y)
				_apply_screen_impact("CANOPY IMPACT")
			_mark_harrier_wave_escape(int(enemy.get("wave_id", 0)))
			harrier_enemies.remove_at(index)
		else:
			harrier_enemies[index] = enemy
	harrier_enemies.sort_custom(_sort_harrier_enemies)


func _sort_harrier_enemies(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("z_depth", 0.0)) > float(b.get("z_depth", 0.0))


func _spawn_harrier_bullet(enemy: Dictionary) -> void:
	if bool(enemy.get("has_shot", false)):
		return
	var center_punch := randf() < 0.42
	harrier_enemy_bullets.append({
		"z_depth": float(enemy.get("z_depth", 900.0)),
		"lane_x": float(enemy.get("lane_x", 0.0)),
		"lane_y": float(enemy.get("lane_y", 0.0)),
		"target_x": player.lane_pos * 250.0 + (randf_range(-28.0, 28.0) if center_punch else randf_range(-120.0, 120.0)),
		"target_y": player.flight_y + (randf_range(-22.0, 22.0) if center_punch else randf_range(-86.0, 86.0)),
		"speed": randf_range(520.0, 660.0) if center_punch else randf_range(460.0, 560.0),
		"turn": randf_range(1.35, 1.85) if center_punch else randf_range(0.85, 1.35),
		"center_punch": center_punch,
		"life": 2.8
	})


func _tick_harrier_enemy_bullets(delta: float) -> void:
	for index in range(harrier_enemy_bullets.size() - 1, -1, -1):
		var bullet := harrier_enemy_bullets[index]
		bullet["prev_z_depth"] = float(bullet.get("z_depth", 900.0))
		bullet["prev_lane_x"] = float(bullet.get("lane_x", 0.0))
		bullet["prev_lane_y"] = float(bullet.get("lane_y", 0.0))
		bullet["z_depth"] = float(bullet.get("z_depth", 900.0)) - float(bullet.get("speed", 500.0)) * delta
		bullet["lane_x"] = lerpf(float(bullet.get("lane_x", 0.0)), float(bullet.get("target_x", 0.0)), float(bullet.get("turn", 1.0)) * delta)
		bullet["lane_y"] = lerpf(float(bullet.get("lane_y", 0.0)), float(bullet.get("target_y", 0.0)), float(bullet.get("turn", 1.0)) * delta)
		bullet["life"] = float(bullet.get("life", 1.0)) - delta
		_maybe_play_bullet_whiz(bullet)
		if float(bullet.get("z_depth", 0.0)) <= HARRIER_NEAR_DEPTH:
			if _harrier_bullet_hits_player(bullet):
				_apply_screen_impact("CANOPY SHOT", float(bullet.get("lane_x", 0.0)) / 250.0, float(bullet.get("lane_y", 0.0)))
			harrier_enemy_bullets.remove_at(index)
		elif float(bullet.get("life", 0.0)) <= 0.0:
			harrier_enemy_bullets.remove_at(index)
		else:
			harrier_enemy_bullets[index] = bullet


func _harrier_enemy_hits_player(enemy: Dictionary) -> bool:
	var dx := absf(float(enemy.get("lane_x", 0.0)) - player.lane_pos * 250.0)
	var dy := absf(float(enemy.get("lane_y", 0.0)) - player.flight_y)
	return dx < 145.0 and dy < 112.0


func _harrier_bullet_hits_player(bullet: Dictionary) -> bool:
	var dx := absf(float(bullet.get("lane_x", 0.0)) - player.lane_pos * 250.0)
	var dy := absf(float(bullet.get("lane_y", 0.0)) - player.flight_y)
	return dx < 92.0 and dy < 82.0


func _apply_screen_impact(reason: String, source_lane := 999.0, source_flight_y := 9999.0) -> void:
	screen_impact_flash = 3.0
	if player != null and is_instance_valid(player) and source_lane < 900.0:
		var lane_delta := clampf(source_lane - float(player.lane_pos), -2.0, 2.0)
		var height_delta := clampf((source_flight_y - float(player.flight_y)) / 430.0, -1.0, 1.0)
		screen_impact_anchor = Vector2(clampf(0.50 + lane_delta * 0.22, 0.18, 0.82), clampf(0.46 + height_delta * 0.22, 0.22, 0.72))
	else:
		screen_impact_anchor = Vector2(0.5, 0.46)
	_play_winding_sfx(SFX_EXPLOSION, -8.0)
	if player.apply_hit(1):
		_crash(reason)
		return
	_show_message("%s - HULL -25%%" % reason, 1.15)
	_update_hud()


func _tick_player_shots(delta: float, effective_speed: float) -> void:
	for index in range(player_shots.size() - 1, -1, -1):
		var shot := player_shots[index]
		shot["z"] = float(shot.get("z", camera_z)) + maxf(effective_speed * float(shot.get("speed_mult", 1.95)), float(shot.get("min_speed", 2100.0))) * delta
		shot["lane"] = float(shot.get("lane", 0.0)) + float(shot.get("lane_velocity", 0.0)) * delta
		shot["flight_y"] = float(shot.get("flight_y", 0.0)) + float(shot.get("flight_velocity", 0.0)) * delta
		if bool(shot.get("homing", false)):
			_apply_winding_shot_assist(shot, delta)
		shot["life"] = float(shot.get("life", 1.0)) - delta
		var hit := false
		for enemy_index in range(harrier_enemies.size() - 1, -1, -1):
			if _player_shot_hits_harrier_enemy(shot, harrier_enemies[enemy_index]):
				var enemy := harrier_enemies[enemy_index]
				enemy["hp"] = int(enemy.get("hp", 1)) - int(shot.get("damage", 1))
				enemy["hit_flash"] = 0.14
				enemy["hit_kick"] = 0.14 + float(shot.get("kick", 0.14)) + _winding_weapon_power() * 0.08
				var enemy_max_hp := maxi(int(enemy.get("max_hp", 1)), 1)
				var enemy_hp := int(enemy.get("hp", 0))
				if enemy_hp > 0 and float(enemy_hp) / float(enemy_max_hp) <= WINDING_ENEMY_SMOKE_HEALTH_RATIO:
					enemy["smoking"] = true
				_play_winding_hit_sfx()
				_add_hit_pop(camera_z + float(enemy.get("z_depth", 800.0)), clampf(float(enemy.get("lane_x", 0.0)) / 250.0, -2.0, 2.0), float(enemy.get("lane_y", 0.0)), "HIT")
				if enemy_hp <= 0:
					score += 420
					_add_explosion(camera_z + float(enemy.get("z_depth", 800.0)), clampf(float(enemy.get("lane_x", 0.0)) / 250.0, -2.0, 2.0), float(enemy.get("lane_y", 0.0)))
					_play_winding_sfx(SFX_EXPLOSION, -8.0)
					if str(enemy.get("type", "")) == "powerup_carrier":
						_spawn_winding_pickup(_random_winding_pickup_kind(), camera_z + PLAYER_COLLISION_OFFSET + 340.0, clampf(float(enemy.get("lane_x", 0.0)) / 250.0, -1.8, 1.8), float(enemy.get("lane_y", 0.0)))
					_mark_harrier_wave_kill(int(enemy.get("wave_id", 0)), enemy)
					harrier_enemies.remove_at(enemy_index)
				else:
					harrier_enemies[enemy_index] = enemy
				hit = true
				if str(shot.get("weapon", "rifle")) in ["rocket", "fireball"]:
					_add_explosion(float(shot.get("z", camera_z)), float(shot.get("lane", 0.0)), float(shot.get("flight_y", 0.0)))
				break
		if not hit:
			for obstacle in obstacles:
				if obstacle.has_method("hit_by_winding_shot") and obstacle.hit_by_winding_shot(float(shot.get("lane", 0.0)), float(shot.get("z", 0.0)), float(shot.get("flight_y", 0.0)), int(shot.get("damage", 1))):
					score += 320
					_play_winding_hit_sfx()
					_add_hit_pop(float(obstacle.world_z), float(obstacle.current_lane_value), float(obstacle.flight_y), "HIT")
					if str(obstacle.obstacle_type) == "powerup_carrier":
						_spawn_winding_pickup(_random_winding_pickup_kind(), float(obstacle.world_z), float(obstacle.current_lane_value), float(obstacle.flight_y))
					elif bool(obstacle.destroyed):
						_add_hit_pop(float(obstacle.world_z), float(obstacle.current_lane_value), float(obstacle.flight_y), "BOOM")
						_add_explosion(float(obstacle.world_z), float(obstacle.current_lane_value), float(obstacle.flight_y))
						_play_winding_sfx(SFX_EXPLOSION, -7.0)
					hit = true
					break
		if hit or float(shot.get("life", 0.0)) <= 0.0 or float(shot.get("z", 0.0)) > camera_z + renderer.visible_distance:
			player_shots.remove_at(index)
		else:
			player_shots[index] = shot


func _player_shot_hits_harrier_enemy(shot: Dictionary, enemy: Dictionary) -> bool:
	var shot_depth := float(shot.get("z", camera_z)) - camera_z
	var z_depth := float(enemy.get("z_depth", HARRIER_FAR_DEPTH))
	var grounded_bonus := 28.0 if bool(shot.get("grounded_source", false)) else 0.0
	if absf(shot_depth - z_depth) > float(shot.get("depth_radius", 125.0)) + grounded_bonus:
		return false
	var shot_x := float(shot.get("lane", 0.0)) * 250.0
	var shot_y := float(shot.get("flight_y", 0.0))
	var enemy_x := float(enemy.get("lane_x", 0.0))
	var enemy_y := float(enemy.get("lane_y", 0.0))
	var near_bonus := clampf(1.0 - z_depth / HARRIER_FAR_DEPTH, 0.0, 1.0)
	var enemy_bonus := 1.0
	match str(enemy.get("type", "")):
		"powerup_carrier":
			enemy_bonus = 1.22
		"shooter":
			enemy_bonus = 1.12
		"straight_charger":
			enemy_bonus = 1.08
	var hit_radius := lerpf(78.0, 158.0, near_bonus) * float(shot.get("radius_mult", 1.0)) * enemy_bonus
	if bool(shot.get("grounded_source", false)):
		hit_radius += lerpf(24.0, 44.0, near_bonus)
	return Vector2(shot_x, shot_y).distance_to(Vector2(enemy_x, enemy_y)) <= hit_radius


func _apply_winding_shot_assist(shot: Dictionary, delta: float) -> void:
	var assist := float(shot.get("assist", 0.0))
	if assist <= 0.01 or harrier_enemies.is_empty():
		return
	var shot_depth := float(shot.get("z", camera_z)) - camera_z
	var shot_pos := Vector2(float(shot.get("lane", 0.0)) * 250.0, float(shot.get("flight_y", 0.0)))
	var best_index := -1
	var best_score := INF
	for enemy_index in range(harrier_enemies.size()):
		var enemy := harrier_enemies[enemy_index]
		var z_depth := float(enemy.get("z_depth", HARRIER_FAR_DEPTH))
		var ahead := z_depth - shot_depth
		if ahead < 70.0 or ahead > float(shot.get("assist_depth", 980.0)):
			continue
		var enemy_pos := Vector2(float(enemy.get("lane_x", 0.0)), float(enemy.get("lane_y", 0.0)))
		var delta_pos := enemy_pos - shot_pos
		var horizontal_limit := float(shot.get("assist_horizontal", 340.0))
		var vertical_limit := float(shot.get("assist_vertical", 190.0))
		if absf(delta_pos.x) > horizontal_limit or absf(delta_pos.y) > vertical_limit:
			continue
		var score := delta_pos.length() + ahead * 0.08
		if score < best_score:
			best_score = score
			best_index = enemy_index
	if best_index < 0:
		return
	var target := harrier_enemies[best_index]
	var target_lane := clampf(float(target.get("lane_x", 0.0)) / 250.0, -2.5, 2.5)
	var target_y := float(target.get("lane_y", 0.0))
	var steer := clampf(delta * assist, 0.0, 1.0)
	shot["lane"] = lerpf(float(shot.get("lane", 0.0)), target_lane, steer * 2.6)
	shot["flight_y"] = lerpf(float(shot.get("flight_y", 0.0)), target_y, steer * 2.0)


func _winding_weapon_power() -> float:
	if player == null or not is_instance_valid(player):
		return 1.0
	var boost := 1.0
	if float(player.get("cannon_boost_timer")) > 0.0:
		boost += 0.75
	boost += float(player.get("thrust_charge")) * 0.35
	return boost


func _play_winding_hit_sfx() -> void:
	hit_combo_count += 1
	hit_combo_timer = 0.75
	var pitch_boost := clampf(float(hit_combo_count - 1) * 0.04, 0.0, 0.28)
	_play_winding_sfx(SFX_PLAYER_LASER, -17.0 + minf(float(hit_combo_count), 6.0) * 0.75, 0.78 + pitch_boost)


func _mark_harrier_wave_kill(wave_id: int, enemy: Dictionary) -> void:
	if wave_id <= 0 or not harrier_wave_stats.has(wave_id):
		return
	var stats := harrier_wave_stats[wave_id] as Dictionary
	stats["killed"] = int(stats.get("killed", 0)) + 1
	harrier_wave_stats[wave_id] = stats
	_try_reward_harrier_wave(wave_id, enemy)


func _mark_harrier_wave_escape(wave_id: int) -> void:
	if wave_id <= 0 or not harrier_wave_stats.has(wave_id):
		return
	var stats := harrier_wave_stats[wave_id] as Dictionary
	stats["escaped"] = int(stats.get("escaped", 0)) + 1
	harrier_wave_stats[wave_id] = stats


func _try_reward_harrier_wave(wave_id: int, last_enemy: Dictionary) -> void:
	var stats := harrier_wave_stats.get(wave_id, {}) as Dictionary
	if bool(stats.get("rewarded", false)):
		return
	if int(stats.get("escaped", 0)) > 0:
		return
	var total := int(stats.get("total", 0))
	var killed := int(stats.get("killed", 0))
	if total <= 1 or killed < total:
		return
	stats["rewarded"] = true
	harrier_wave_stats[wave_id] = stats
	score += 1800 + total * 350
	var reward_kind := "extra_life" if total >= 5 and randf() < 0.32 else _random_winding_pickup_kind()
	_spawn_winding_pickup(reward_kind, camera_z + PLAYER_COLLISION_OFFSET + 360.0, clampf(float(last_enemy.get("lane_x", 0.0)) / 250.0, -1.7, 1.7), float(last_enemy.get("lane_y", 0.0)))
	_add_hit_pop(camera_z + PLAYER_COLLISION_OFFSET + 320.0, 0.0, -90.0, "FORMATION CLEAR")
	_show_message("FORMATION CLEAR + BONUS", 1.1)


func _tick_winding_pickups(delta: float, effective_speed: float) -> void:
	var player_z := camera_z + PLAYER_COLLISION_OFFSET
	for index in range(active_pickups.size() - 1, -1, -1):
		var pickup := active_pickups[index]
		pickup["z"] = float(pickup.get("z", camera_z)) + (effective_speed - WINDING_PICKUP_SCREEN_DRIFT_SPEED) * delta
		pickup["life"] = float(pickup.get("life", 4.0)) - delta
		var z_delta := absf(float(pickup.get("z", 0.0)) - player_z)
		var lane_delta := absf(float(pickup.get("lane", 0.0)) - player.lane_pos)
		var y_delta := absf(float(pickup.get("flight_y", 0.0)) - player.flight_y)
		if z_delta < 92.0 and lane_delta < 0.62 and y_delta < 118.0:
			_grant_winding_powerup(str(pickup.get("kind", "rapid")))
			active_pickups.remove_at(index)
			continue
		if float(pickup.get("life", 0.0)) <= 0.0 or float(pickup.get("z", 0.0)) < camera_z - 180.0:
			active_pickups.remove_at(index)
		else:
			active_pickups[index] = pickup


func _tick_winding_coin_chains(delta: float) -> void:
	coin_chain_cooldown -= delta
	if coin_chain_cooldown <= 0.0:
		_spawn_winding_coin_chain()
	var player_z := camera_z + PLAYER_COLLISION_OFFSET
	for chain_index in range(active_coin_chains.size() - 1, -1, -1):
		var chain := active_coin_chains[chain_index]
		var coins: Array = chain.get("coins", [])
		for coin_index in range(coins.size()):
			var coin := coins[coin_index] as Dictionary
			if bool(coin.get("collected", false)) or bool(coin.get("missed", false)):
				continue
			var coin_z := float(coin.get("z", 0.0))
			var z_delta := absf(coin_z - player_z)
			var lane_delta := absf(float(coin.get("lane", 0.0)) - float(player.lane_pos))
			var y_delta := absf(float(coin.get("flight_y", 0.0)) - float(player.flight_y))
			if z_delta <= WINDING_COIN_CHAIN_COLLISION_Z and lane_delta <= WINDING_COIN_CHAIN_COLLISION_LANE and y_delta <= WINDING_COIN_CHAIN_COLLISION_Y:
				coin["collected"] = true
				chain["collected"] = int(chain.get("collected", 0)) + 1
				coin_combo_count = int(chain.get("collected", 0))
				coin_combo_display_timer = 1.25
				score += 80 + int(chain.get("collected", 0)) * 12
				_spawn_coin_collect_fx(coin_z, float(coin.get("lane", 0.0)), float(coin.get("flight_y", 0.0)), int(chain.get("collected", 0)))
				_play_winding_coin_sfx(int(chain.get("collected", 0)))
			elif coin_z < player_z - 150.0:
				coin["missed"] = true
			coins[coin_index] = coin
		chain["coins"] = coins
		if _coin_chain_finished(coins):
			chain["settle_timer"] = float(chain.get("settle_timer", 0.55)) - delta
			if float(chain.get("settle_timer", 0.0)) <= 0.0:
				_finish_winding_coin_chain(chain)
				active_coin_chains.remove_at(chain_index)
				continue
		active_coin_chains[chain_index] = chain


func _spawn_winding_coin_chain() -> void:
	if player == null or not is_instance_valid(player):
		return
	if active_coin_chains.size() >= 1:
		coin_chain_cooldown = 1.35
		return
	var stage := int(level_data.get("stage", 50))
	var stage_pressure := clampf(float(stage - 50) / 20.0, 0.0, 1.0)
	var speed_pressure := clampf((speed - 900.0) / 1600.0, 0.0, 1.0)
	var count := clampi(5 + int(stage_pressure * 3.0) + randi_range(0, 2), 5, 10)
	var spacing := lerpf(360.0, 270.0, stage_pressure) + speed_pressure * 120.0
	if stage >= 62:
		spacing += 80.0
	var start_z := camera_z + PLAYER_COLLISION_OFFSET + 960.0 + speed_pressure * 260.0
	var lane_choices := [-1.0, 0.0, 1.0]
	var base_lane := float(lane_choices.pick_random())
	var flight_choices := [-120.0, -54.0, 0.0, 54.0]
	var base_flight_y := 0.0 if str(level_data.get("theme_id", "")) == "red_tunnel" else float(flight_choices.pick_random())
	var pattern_choices := ["line", "line", "stair"]
	if stage >= 54:
		pattern_choices.append_array(["arc", "slalom"])
	if stage >= 62:
		pattern_choices.append_array(["split", "slalom"])
	var pattern_kind := str(pattern_choices.pick_random())
	var lane_direction := -1.0 if randf() < 0.5 else 1.0
	var coins: Array[Dictionary] = []
	for index in range(count):
		var lane_offset := 0.0
		var flight_offset := 0.0
		match pattern_kind:
			"stair":
				lane_offset = lane_direction * floor(float(index) / 2.0) * 0.22
			"arc":
				lane_offset = lane_direction * sin(float(index) / maxf(float(count - 1), 1.0) * PI) * 0.76
				flight_offset = -sin(float(index) / maxf(float(count - 1), 1.0) * PI) * 42.0
			"slalom":
				lane_offset = sin(float(index) * 0.82) * 0.72
			"split":
				lane_offset = lane_direction * (0.54 if index % 2 == 0 else -0.10)
				flight_offset = -24.0 if index % 2 == 0 else 18.0
			_:
				lane_offset = 0.0
		coins.append({
			"z": start_z + float(index) * spacing,
			"lane": clampf(base_lane + lane_offset, -1.85, 1.85),
			"flight_y": base_flight_y + flight_offset,
			"collected": false,
			"missed": false,
			"phase": randf() * TAU
		})
	coin_chain_serial += 1
	active_coin_chains.append({
		"id": coin_chain_serial,
		"coins": coins,
		"collected": 0,
		"total": count,
		"settle_timer": 0.55
	})
	coin_chain_cooldown = randf_range(4.1, 6.6) if stage < 60 else randf_range(3.2, 5.4)


func _coin_chain_finished(coins: Array) -> bool:
	for coin_value in coins:
		var coin := coin_value as Dictionary
		if not bool(coin.get("collected", false)) and not bool(coin.get("missed", false)):
			return false
	return true


func _finish_winding_coin_chain(chain: Dictionary) -> void:
	var collected := int(chain.get("collected", 0))
	if collected <= 0:
		return
	PlayState.adjust_village_coins(collected, "Winding road coin combo x%d." % collected, true)
	var bonus_score := collected * collected * 18
	score += bonus_score
	coin_combo_bank_amount = collected
	coin_combo_bank_timer = 1.6
	coin_combo_display_timer = maxf(coin_combo_display_timer, 1.6)
	_show_message("COIN COMBO x%d  +%d COINS" % [collected, collected], 1.35)


func _spawn_coin_collect_fx(world_z: float, lane_value: float, flight_y: float, combo: int) -> void:
	coin_collect_fx.append({
		"z": world_z,
		"lane": lane_value,
		"flight_y": flight_y,
		"combo": combo,
		"life": 0.52,
		"max_life": 0.52,
		"phase": randf() * TAU
	})


func _tick_coin_collect_fx(delta: float) -> void:
	for index in range(coin_collect_fx.size() - 1, -1, -1):
		var fx := coin_collect_fx[index]
		fx["life"] = float(fx.get("life", 0.0)) - delta
		fx["flight_y"] = float(fx.get("flight_y", 0.0)) - 44.0 * delta
		if float(fx.get("life", 0.0)) <= 0.0:
			coin_collect_fx.remove_at(index)
		else:
			coin_collect_fx[index] = fx


func _play_winding_coin_sfx(combo_count: int) -> void:
	coin_sfx_step = clampi(combo_count, 1, 16)
	var pitch := clampf(0.82 + float(coin_sfx_step) * 0.055, 0.86, 1.62)
	var db := -10.5 + minf(float(coin_sfx_step) * 0.55, 5.5)
	_play_winding_sfx(SFX_POWERUP, db, pitch)


func _tick_enemy_fire(delta: float) -> void:
	for obstacle in obstacles:
		if obstacle.destroyed or not obstacle.visible:
			continue
		if not (str(obstacle.obstacle_type) in ["drone", "dropper_drone"]):
			continue
		if not bool(obstacle.fires):
			continue
		var rel_z := float(obstacle.world_z) - camera_z
		if rel_z < 520.0 or rel_z > 1950.0:
			continue
		var id := obstacle.get_instance_id()
		var timer := float(enemy_fire_timers.get(id, randf_range(1.0, 2.4))) - delta
		if timer <= 0.0:
			var shot_z := maxf(float(obstacle.world_z) - 40.0, camera_z + 360.0)
			enemy_shots.append({
				"z": shot_z,
				"lane": lerpf(float(obstacle.current_lane_value), player.lane_pos, 0.34),
				"flight_y": lerpf(float(obstacle.flight_y), player.flight_y, 0.44),
				"life": 2.2
			})
			_play_winding_sfx(SFX_ENEMY_SHOT, -18.0)
			var difficulty := _speedbike_difficulty()
			var stage_pressure := 1.0 + maxf(0.0, float(int(level_data.get("stage", 50)) - 50)) * 0.035
			var fire_scale := clampf(float(difficulty.get("speed_scale", 1.0)) * stage_pressure, 0.85, 1.55)
			timer = randf_range(1.85, 3.20) / fire_scale
		enemy_fire_timers[id] = timer


func _tick_enemy_shots(delta: float, effective_speed: float) -> void:
	var player_z := camera_z + PLAYER_COLLISION_OFFSET
	for index in range(enemy_shots.size() - 1, -1, -1):
		var shot := enemy_shots[index]
		shot["z"] = float(shot.get("z", camera_z)) - maxf(effective_speed * 0.38, 520.0) * delta
		shot["life"] = float(shot.get("life", 1.0)) - delta
		var lane_delta := absf(float(shot.get("lane", 0.0)) - player.lane_pos)
		var y_delta := absf(float(shot.get("flight_y", 0.0)) - player.flight_y)
		if absf(float(shot.get("z", 0.0)) - player_z) < 64.0 and lane_delta < 0.44 and y_delta < 72.0:
			enemy_shots.remove_at(index)
			_crash("ENEMY FIRE")
			continue
		if float(shot.get("life", 0.0)) <= 0.0 or float(shot.get("z", 0.0)) < camera_z - 160.0:
			enemy_shots.remove_at(index)
		else:
			enemy_shots[index] = shot


func _tick_hit_pops(delta: float) -> void:
	for index in range(hit_pops.size() - 1, -1, -1):
		var pop := hit_pops[index]
		pop["life"] = float(pop.get("life", 0.0)) - delta
		pop["rise"] = float(pop.get("rise", 0.0)) + 34.0 * delta
		if float(pop.get("life", 0.0)) <= 0.0:
			hit_pops.remove_at(index)
		else:
			hit_pops[index] = pop


func _add_hit_pop(world_z: float, lane_value: float, flight_y: float, text: String) -> void:
	hit_pops.append({
		"z": world_z,
		"lane": lane_value,
		"flight_y": flight_y,
		"text": text,
		"life": 0.38,
		"rise": 0.0
	})


func _tick_explosions(delta: float) -> void:
	for index in range(explosions.size() - 1, -1, -1):
		var boom := explosions[index]
		boom["life"] = float(boom.get("life", 0.0)) - delta
		if float(boom.get("life", 0.0)) <= 0.0:
			explosions.remove_at(index)
		else:
			explosions[index] = boom


func _add_explosion(world_z: float, lane_value: float, flight_y: float) -> void:
	explosions.append({
		"z": world_z,
		"lane": lane_value,
		"flight_y": flight_y,
		"life": 0.42,
		"max_life": 0.42
	})


func _random_winding_pickup_kind() -> String:
	var kinds := ["rapid", "machine", "laser", "spread", "rocket", "repair", "blue", "purple"]
	return kinds[randi() % kinds.size()]


func _spawn_winding_pickup(kind: String, world_z: float, lane_value: float, flight_y: float) -> void:
	active_pickups.append({
		"kind": kind,
		"z": world_z,
		"lane": lane_value,
		"flight_y": flight_y,
		"life": 4.2,
		"phase": randf() * TAU
	})
	_play_winding_sfx(SFX_CARRIER, -9.0)


func _grant_winding_powerup(kind := "rapid") -> void:
	score += 650
	match kind:
		"repair", "health", "green":
			player.health = mini(player.health + 1, player.max_health)
			_show_message("POWERUP: HEALTH RESTORED", 1.2)
		"blue":
			player.health = mini(player.health + 1, player.max_health)
			if player.has_method("grant_cannon_boost"):
				player.grant_cannon_boost(6.0)
			_show_message("POWERUP: BLUE REPAIR + RAPID", 1.2)
		"purple":
			if player.has_method("grant_cannon_boost"):
				player.grant_cannon_boost(14.0)
			_show_message("POWERUP: OVERCHARGED CANNON", 1.2)
		"extra_life", "1up", "one_up", "life":
			player.max_health = maxi(player.max_health + 1, 1)
			player.health = player.max_health
			_show_message("POWERUP: HULL UPGRADE", 1.2)
		"spread":
			winding_weapon_kind = "spread"
			winding_spread_ammo += 90
			_show_message("POWERUP: SPREAD FAN +%d" % winding_spread_ammo, 1.2)
		"rocket":
			winding_weapon_kind = "rocket"
			winding_rocket_ammo += 18
			_show_message("POWERUP: ROCKET POD +%d" % winding_rocket_ammo, 1.2)
		"fireball", "laser", "machine", "rapid", "cannon_boost":
			winding_weapon_kind = "rapid" if kind == "cannon_boost" else kind
			if player.has_method("grant_cannon_boost"):
				player.grant_cannon_boost(10.0)
			_show_message("POWERUP: %s CANNON" % winding_weapon_kind.replace("_", " ").to_upper(), 1.2)
		_:
			if player.has_method("grant_cannon_boost"):
				player.grant_cannon_boost(10.0)
			_show_message("POWERUP: %s" % kind.replace("_", " ").to_upper(), 1.2)
	_play_winding_sfx(SFX_POWERUP, -7.0)


func _winding_pickup_texture(kind: String) -> Texture2D:
	var texture_path := str(WINDING_PICKUP_TEXTURE_PATHS.get(kind, WINDING_PICKUP_TEXTURE_PATHS.get("rapid", "")))
	if texture_path.is_empty():
		return null
	if winding_pickup_texture_cache.has(texture_path):
		return winding_pickup_texture_cache[texture_path] as Texture2D
	var texture := load(texture_path) as Texture2D
	if texture != null:
		winding_pickup_texture_cache[texture_path] = texture
	return texture


func _winding_coin_texture() -> Texture2D:
	if winding_coin_texture == null:
		winding_coin_texture = load(WINDING_COIN_TEXTURE_PATH) as Texture2D
	return winding_coin_texture


func _harrier_texture(enemy_type: String) -> Texture2D:
	var texture_path := str(HARRIER_ENEMY_TEXTURE_PATHS.get(enemy_type, HARRIER_ENEMY_TEXTURE_PATHS.get("straight_charger", "")))
	if texture_path.is_empty():
		return null
	if harrier_texture_cache.has(texture_path):
		return harrier_texture_cache[texture_path] as Texture2D
	var texture := load(texture_path) as Texture2D
	if texture != null:
		harrier_texture_cache[texture_path] = texture
	return texture


func _project_harrier(lane_x: float, lane_y: float, z_depth: float) -> Dictionary:
	var safe_z := maxf(z_depth, HARRIER_NEAR_DEPTH)
	var perspective := HARRIER_PERSPECTIVE_STRENGTH / safe_z
	var center_x := renderer.screen_size.x * 0.5
	var x := center_x + lane_x * perspective
	var y := renderer.horizon_y + renderer.road_y_offset + 16.0 + lane_y * perspective + (1.0 - clampf(safe_z / HARRIER_FAR_DEPTH, 0.0, 1.0)) * renderer.screen_size.y * 0.42
	var scale_value := clampf(perspective * 0.33, 0.08, 1.25)
	return {
		"visible": x > -180.0 and x < renderer.screen_size.x + 180.0 and y > renderer.horizon_y - 120.0 and y < renderer.screen_size.y + 220.0,
		"x": x,
		"y": y,
		"scale": scale_value,
		"near": 1.0 - clampf(safe_z / HARRIER_FAR_DEPTH, 0.0, 1.0)
	}


func _handle_collisions() -> void:
	if player.crashed:
		return
	var collision_z := camera_z + PLAYER_COLLISION_OFFSET
	for obstacle in obstacles:
		if obstacle.can_collect(player.lane_pos, collision_z, COLLISION_WINDOW):
			obstacle.destroyed = true
			score += 450
			_grant_winding_powerup(_random_winding_pickup_kind())
			continue
		if obstacle.collides_with(player.lane_pos, player.jump_z, collision_z, COLLISION_WINDOW, player.flight_y):
			_crash(_crash_label_for(obstacle.obstacle_type))
			return


func _handle_checkpoints() -> void:
	if not _checkpoints_enabled():
		return
	var reached: float = pattern_runner.poll_checkpoint(camera_z - stage_origin_z)
	if reached < 0.0:
		return
	checkpoint_z = stage_origin_z + reached
	score += 600
	_show_message("CHECKPOINT", 1.4)


func _handle_stage_clear() -> void:
	var length := float(level_data.get("length", 6000.0))
	if camera_z - stage_origin_z < length:
		return
	score += max(1000, int(length / maxf(elapsed, 1.0)) * 12)
	var stage := int(level_data.get("stage", WindingLevelData.FIRST_STAGE))
	if stage < WindingLevelData.LAST_STAGE:
		var next_stage := stage + 1
		_load_stage(WindingLevelData.stage_id(next_stage), false, speed + 70.0, true)
		_show_message("ROLLING INTO STAGE %d - %s" % [next_stage, str(level_data.get("display_name", "Winding Road"))], 1.35)
		return
	stage_clear = true
	_show_result_panel()


func _crash(reason: String) -> void:
	var difficulty := _speedbike_difficulty()
	if bool(difficulty.get("instant_crash", false)) or player.apply_hit(1):
		deaths += 1
		lives = maxi(lives - 1, 0)
		player.mark_crashed()
		restart_timer = 0.75
		_add_explosion(camera_z + PLAYER_COLLISION_OFFSET, player.lane_pos, player.flight_y)
		_play_winding_sfx(SFX_EXPLOSION, -5.0)
		var restart_text := "%s - RESTARTING" % reason
		if lives <= 0:
			restart_text = "%s - LAST CHANCE" % reason
		_show_message(restart_text, 0.9)
	else:
		_show_message("%s - ARMOR HIT" % reason, 1.1)
	_update_hud()


func _restart_from_checkpoint() -> void:
	camera_z = maxf(checkpoint_z - 220.0, 0.0) if _checkpoints_enabled() else 0.0
	pattern_runner.reset_to_checkpoint(checkpoint_z - stage_origin_z if _checkpoints_enabled() else 0.0)
	_clear_obstacles()
	next_obstacle_index = 0
	while next_obstacle_index < obstacle_rows.size() and float(obstacle_rows[next_obstacle_index].get("z", 0.0)) < camera_z - 520.0:
		next_obstacle_index += 1
	_spawn_obstacles_near()
	player.reset()
	player.health = player.max_health
	_show_message("BACK ON THE ROAD", 1.1)


func _on_player_shot(lane_pos: float, flight_y: float) -> void:
	_spawn_winding_player_projectiles(lane_pos, flight_y)


func _spawn_winding_player_projectiles(lane_pos: float, flight_y: float) -> void:
	var weapon := _active_winding_weapon()
	var spawn_z := camera_z + PLAYER_COLLISION_OFFSET + 28.0
	var shots: Array[Dictionary] = []
	match weapon:
		"spread":
			var spread_offsets := [-0.54, -0.27, 0.0, 0.27, 0.54]
			for i in spread_offsets.size():
				var offset := float(spread_offsets[i])
				shots.append(_make_winding_player_shot(spawn_z, lane_pos + offset * 0.22, flight_y + offset * 42.0, weapon, {
					"lane_velocity": offset * 0.38,
					"flight_velocity": offset * 48.0,
					"damage": 1,
					"radius_mult": 1.02,
					"draw_radius": 3.6,
					"depth_radius": 142.0
				}))
			winding_spread_ammo = maxi(winding_spread_ammo - 1, 0)
		"rocket":
			shots.append(_make_winding_player_shot(spawn_z, lane_pos, flight_y, weapon, {
				"damage": 4,
				"radius_mult": 1.65,
				"depth_radius": 165.0,
				"draw_radius": 7.2,
				"speed_mult": 1.55,
				"min_speed": 1850.0,
				"kick": 0.42,
				"assist": 0.86,
				"assist_horizontal": 470.0,
				"assist_vertical": 250.0,
				"homing": true
			}))
			winding_rocket_ammo = maxi(winding_rocket_ammo - 1, 0)
		"machine":
			var jitter := randf_range(-0.04, 0.04)
			shots.append(_make_winding_player_shot(spawn_z, lane_pos + jitter, flight_y + randf_range(-8.0, 8.0), weapon, {
				"damage": 1,
				"draw_radius": 3.2,
				"speed_mult": 2.16,
				"min_speed": 2350.0,
				"radius_mult": 1.02,
				"depth_radius": 132.0
			}))
		"laser":
			shots.append(_make_winding_player_shot(spawn_z, lane_pos, flight_y, weapon, {
				"damage": 2,
				"draw_radius": 4.0,
				"speed_mult": 2.55,
				"min_speed": 2850.0,
				"kick": 0.22,
				"radius_mult": 1.08,
				"depth_radius": 148.0
			}))
		"fireball":
			shots.append(_make_winding_player_shot(spawn_z, lane_pos, flight_y, weapon, {
				"damage": 3,
				"draw_radius": 6.2,
				"speed_mult": 1.72,
				"min_speed": 2050.0,
				"kick": 0.34,
				"radius_mult": 1.30,
				"depth_radius": 158.0
			}))
		"rapid":
			shots.append(_make_winding_player_shot(spawn_z, lane_pos, flight_y, weapon, {
				"damage": 1,
				"draw_radius": 3.7,
				"speed_mult": 2.25,
				"min_speed": 2500.0,
				"radius_mult": 1.04,
				"depth_radius": 136.0
			}))
		_:
			shots.append(_make_winding_player_shot(spawn_z, lane_pos, flight_y, "rifle", {
				"damage": 1,
				"draw_radius": 3.4,
				"speed_mult": 2.05,
				"min_speed": 2300.0,
				"radius_mult": 1.05,
				"depth_radius": 138.0
			}))
	for shot in shots:
		player_shots.append(shot)
	_play_winding_player_shot_sfx(weapon)
	if weapon == "spread" and winding_spread_ammo <= 0:
		winding_weapon_kind = "rifle"
	if weapon == "rocket" and winding_rocket_ammo <= 0:
		winding_weapon_kind = "rifle"


func _make_winding_player_shot(spawn_z: float, lane_pos: float, flight_y: float, weapon: String, overrides := {}) -> Dictionary:
	var shot := {
		"z": spawn_z,
		"lane": lane_pos,
		"flight_y": flight_y,
		"weapon": weapon,
		"life": 1.18,
		"damage": 1,
		"radius_mult": 0.85,
		"depth_radius": 120.0,
		"draw_radius": 3.4,
		"speed_mult": 2.05,
		"min_speed": 2250.0,
		"lane_velocity": 0.0,
		"flight_velocity": 0.0,
		"homing": false,
		"kick": 0.12,
		"phase": randf() * TAU
	}
	for key in overrides.keys():
		shot[key] = overrides[key]
	if absf(flight_y) < 42.0:
		shot["grounded_source"] = true
		shot["radius_mult"] = float(shot.get("radius_mult", 0.85)) + 0.10
		shot["depth_radius"] = float(shot.get("depth_radius", 120.0)) + 18.0
		if bool(shot.get("homing", false)):
			shot["assist"] = float(shot.get("assist", 0.0)) + 0.25
			shot["assist_horizontal"] = float(shot.get("assist_horizontal", 340.0)) + 90.0
			shot["assist_vertical"] = float(shot.get("assist_vertical", 190.0)) + 52.0
	return shot


func _active_winding_weapon() -> String:
	if winding_weapon_kind == "spread" and winding_spread_ammo <= 0:
		return "rifle"
	if winding_weapon_kind == "rocket" and winding_rocket_ammo <= 0:
		return "rifle"
	return winding_weapon_kind


func _winding_fire_cooldown_for_weapon() -> float:
	var weapon := _active_winding_weapon()
	var profile_mult := 1.0
	if selected_rider_id != "" and RIDER_DEFS.has(selected_rider_id):
		var rider = RIDER_DEFS[selected_rider_id]
		profile_mult = float(rider.get("shot_cooldown_mult", 1.0))
	match weapon:
		"machine":
			return 0.072 * profile_mult
		"rapid":
			return 0.082 * profile_mult
		"laser":
			return 0.118 * profile_mult
		"spread":
			return 0.172 * profile_mult
		"rocket":
			return 0.315 * profile_mult
		"fireball":
			return 0.205 * profile_mult
		_:
			return 0.145 * profile_mult


func _winding_weapon_color(weapon: String) -> Color:
	match weapon:
		"spread":
			return Color(1.0, 0.72, 0.22, 1.0)
		"rocket":
			return Color(1.0, 0.24, 0.08, 1.0)
		"machine":
			return Color(0.48, 1.0, 0.28, 1.0)
		"laser":
			return Color(0.18, 0.82, 1.0, 1.0)
		"fireball":
			return Color(1.0, 0.36, 0.06, 1.0)
		"rapid":
			return Color(0.40, 0.95, 1.0, 1.0)
		_:
			return Color(0.86, 0.96, 1.0, 1.0)


func _winding_weapon_glow_strength() -> float:
	var weapon := _active_winding_weapon()
	if weapon == "rifle":
		return 0.18
	if weapon in ["rocket", "spread", "fireball"]:
		return 0.56
	return 0.40


func _winding_weapon_label_text() -> String:
	var weapon := _active_winding_weapon()
	match weapon:
		"spread":
			return "SPREAD %d" % winding_spread_ammo
		"rocket":
			return "ROCKET %d" % winding_rocket_ammo
		"machine":
			return "MACHINE"
		"laser":
			return "LASER"
		"fireball":
			return "FIREBALL"
		"rapid":
			return "RAPID"
		_:
			return "RIFLE"


func _play_winding_player_shot_sfx(weapon: String) -> void:
	var interval := 0.12
	var volume := -14.0
	var pitch_min := 1.02
	var pitch_max := 1.10
	var path := SFX_PLAYER_SHOT
	match weapon:
		"spread":
			path = SFX_PLAYER_SPREAD
			interval = 0.14
			volume = -12.0
			pitch_min = 0.92
			pitch_max = 1.04
		"rocket":
			path = SFX_PLAYER_ROCKET
			interval = 0.22
			volume = -9.0
			pitch_min = 0.86
			pitch_max = 0.94
		"machine":
			path = SFX_PLAYER_MACHINE
			interval = 0.13
			volume = -15.5
			pitch_min = 1.00
			pitch_max = 1.08
		"laser":
			path = SFX_PLAYER_LASER
			interval = 0.11
			volume = -13.0
			pitch_min = 1.04
			pitch_max = 1.16
		"fireball":
			path = SFX_PLAYER_FIREBALL
			interval = 0.16
			volume = -11.0
			pitch_min = 0.86
			pitch_max = 0.98
		"rapid":
			path = SFX_PLAYER_RAPID
			interval = 0.10
			volume = -15.5
			pitch_min = 0.98
			pitch_max = 1.08
	if player_shot_sfx_timer <= 0.0:
		player_shot_sfx_timer = interval
		_play_winding_sfx(path, volume, randf_range(pitch_min, pitch_max))


func _legacy_winding_player_shot(lane_pos: float, flight_y: float) -> void:
	player_shots.append({
		"z": camera_z + PLAYER_COLLISION_OFFSET + 24.0,
		"lane": lane_pos,
		"flight_y": flight_y,
		"life": 1.25
	})
	if player_shot_sfx_timer <= 0.0:
		player_shot_sfx_timer = 0.075
		_play_winding_sfx(SFX_PLAYER_SHOT, -16.0, randf_range(0.88, 0.96))


func _show_result_panel() -> void:
	var rank := "C"
	if deaths <= 4:
		rank = "B"
	if deaths <= 2:
		rank = "A"
	if deaths == 0:
		rank = "S+"
	var body := result_panel.get_node_or_null("MarginContainer/VBoxContainer/Body") as Label
	if body != null:
		body.text = "Winding Road Set cleared.\nTime: %.1fs\nDeaths: %d\nScore: %d\nRank: %s\n\nCLIP THIS: I survived the Badlands Winding Road Set." % [run_elapsed, deaths, score, rank]
	result_panel.visible = true


func _toggle_pause() -> void:
	if stage_clear or rider_select_open:
		return
	pause_open = not pause_open
	pause_panel.visible = pause_open
	if not pause_open:
		_resume_winding_pause()
		return
	var body := pause_panel.get_node_or_null("MarginContainer/VBoxContainer/Body") as Label
	if body != null:
		body.text = "Winding Road Set\n%s\n\nContinue returns to the run. Restart options ask for confirmation first. Fire breaks mines and drones." % str(level_data.get("display_name", "Stage"))


func _resume_winding_pause() -> void:
	pause_open = false
	pause_confirm_action = ""
	pause_confirm_timer = 0.0
	if pause_panel != null and is_instance_valid(pause_panel):
		pause_panel.visible = false


func _confirm_pause_restart(action: String) -> void:
	var label := "checkpoint" if action == "checkpoint" else "beginning"
	if pause_confirm_action == action:
		_restart_winding_run(action == "beginning")
		return
	pause_confirm_action = action
	pause_confirm_timer = 4.0
	var body := pause_panel.get_node_or_null("MarginContainer/VBoxContainer/Body") as Label
	if body != null:
		body.text = "Restart from %s?\n\nPress the same restart button again to confirm.\nThis keeps the match fair and avoids accidental restarts." % label
	_play_winding_sfx(SFX_CARRIER, -14.0, 0.82)


func _restart_winding_run(from_beginning: bool) -> void:
	pause_open = false
	pause_confirm_action = ""
	pause_confirm_timer = 0.0
	if pause_panel != null:
		pause_panel.visible = false
	if from_beginning:
		checkpoint_z = stage_origin_z
		camera_z = stage_origin_z
		pattern_runner.reset_to_checkpoint(0.0)
		_clear_obstacles()
		next_obstacle_index = 0
		player_shots.clear()
		enemy_shots.clear()
		harrier_enemies.clear()
		harrier_enemy_bullets.clear()
		active_coin_chains.clear()
		active_pickups.clear()
		player.reset()
		player.health = player.max_health
		_show_message("RESTARTED FROM BEGINNING", 1.2)
	else:
		_restart_from_checkpoint()
		_show_message("RESTARTED FROM CHECKPOINT", 1.2)


func _toggle_winding_checkpoints() -> void:
	var enabled := not _checkpoints_enabled()
	if PlayState.has_method("set_speedbike_checkpoints_enabled"):
		PlayState.set_speedbike_checkpoints_enabled(enabled)
	else:
		PlayState.speedbike_checkpoints_enabled = enabled
	_show_message("CHECKPOINTS %s" % ("ON" if enabled else "OFF"), 0.8)


func _toggle_winding_tooltips() -> void:
	AppState.set_show_tooltips(not AppState.show_tooltips)
	_show_message("BOTTOM TIPS %s" % ("ON" if AppState.show_tooltips else "OFF"), 0.8)


func _on_winding_master_volume_changed(value: float) -> void:
	AppState.set_master_volume(value / 100.0)


func _on_winding_music_volume_changed(value: float) -> void:
	AppState.set_music_volume(value / 100.0)
	if music_player != null:
		music_player.volume_db = _winding_music_volume_db(-2.0)


func _on_winding_sfx_volume_changed(value: float) -> void:
	AppState.set_sfx_volume(value / 100.0)


func _start_winding_intro_music() -> void:
	music_loop_index = 0
	_play_winding_music(WINDING_INTRO_MUSIC, false, -1.5)


func _start_winding_select_music() -> void:
	select_music_started_msec = Time.get_ticks_msec()
	if karaoke_overlay != null:
		karaoke_overlay.visible = true
	_play_winding_music(WINDING_SELECT_MUSIC, true, -3.0)


func _select_music_time() -> float:
	if music_player != null and music_player.playing and str(music_player.stream.resource_path) == WINDING_SELECT_MUSIC:
		return music_player.get_playback_position()
	return float(Time.get_ticks_msec() - select_music_started_msec) * 0.001


func _select_lyric_time() -> float:
	var song_time := _select_music_time()
	var anchors := [
		Vector2(0.0, 0.0),
		Vector2(18.0, 15.0),
		Vector2(54.0, 43.0),
		Vector2(94.0, 83.0),
		Vector2(145.0, 119.0),
		Vector2(205.0, 174.0),
		Vector2(252.0, 203.6),
		Vector2(326.0, 262.0),
		Vector2(WINDING_SELECT_TRACK_SECONDS, WINDING_SELECT_LYRIC_SOURCE_SECONDS)
	]
	for i in range(anchors.size() - 1):
		var a: Vector2 = anchors[i]
		var b: Vector2 = anchors[i + 1]
		if song_time <= b.x:
			var section_t := clampf((song_time - a.x) / maxf(b.x - a.x, 0.01), 0.0, 1.0)
			return lerpf(a.y, b.y, section_t)
	return WINDING_SELECT_LYRIC_SOURCE_SECONDS


func _select_lyric_index(song_time: float) -> int:
	var index := 0
	for i in range(WINDING_SELECT_LYRICS.size()):
		if song_time >= float(WINDING_SELECT_LYRICS[i].get("t", 0.0)):
			index = i
		else:
			break
	return index


func _select_lyric_progress(index: int, song_time: float) -> float:
	if index < 0 or index >= WINDING_SELECT_LYRICS.size():
		return 0.0
	var start := float(WINDING_SELECT_LYRICS[index].get("t", 0.0))
	var next := start + 3.25
	if index + 1 < WINDING_SELECT_LYRICS.size():
		next = float(WINDING_SELECT_LYRICS[index + 1].get("t", next))
	return clampf((song_time - start) / maxf(next - start, 0.2), 0.0, 1.0)


func _select_beat_pulse(song_time: float) -> float:
	var bpm := 142.0
	var beat_phase := fmod(song_time * bpm / 60.0, 1.0)
	var main_hit := pow(1.0 - beat_phase, 3.6)
	var off_hit := pow(1.0 - absf(beat_phase - 0.5) * 2.0, 5.0) * 0.32
	return clampf(main_hit + off_hit, 0.0, 1.0)


func _select_singer_color(speaker: String, alpha := 1.0) -> Color:
	match speaker:
		"f":
			return Color(1.0, 0.45, 0.88, alpha)
		"m":
			return Color(0.34, 0.82, 1.0, alpha)
		_:
			return Color(1.0, 0.82, 0.28, alpha)


func _on_winding_music_finished() -> void:
	if music_player == null:
		return
	var path := str(WINDING_LOOP_MUSIC[music_loop_index % WINDING_LOOP_MUSIC.size()])
	music_loop_index += 1
	_play_winding_music(path, false)


func _play_winding_music(path: String, loop_stream := false, base_db := -8.0) -> void:
	if music_player == null or path.strip_edges().is_empty():
		return
	var stream := winding_music_cache.get(path) as AudioStream
	if stream == null:
		stream = load(path) as AudioStream
		if stream != null:
			winding_music_cache[path] = stream
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop_stream
	music_player.stream = stream
	music_player.volume_db = _winding_music_volume_db(base_db)
	music_player.play()


func _begin_winding_countdown() -> void:
	countdown_active = true
	countdown_started_run = false
	countdown_last_label = ""
	go_flash_timer = 0.0
	countdown_timer = 3.0
	_play_winding_sfx(SFX_COUNTDOWN, -4.0)
	_set_countdown_text("3")


func _cache_winding_music() -> void:
	var paths: Array[String] = [WINDING_SELECT_MUSIC, WINDING_INTRO_MUSIC]
	for loop_path in WINDING_LOOP_MUSIC:
		paths.append(str(loop_path))
	for path in paths:
		if winding_music_cache.has(path):
			continue
		var stream := load(path) as AudioStream
		if stream != null:
			winding_music_cache[path] = stream


func _cache_winding_sfx() -> void:
	for path in [SFX_PLAYER_SHOT, SFX_PLAYER_FIREBALL, SFX_PLAYER_LASER, SFX_PLAYER_MACHINE, SFX_PLAYER_RAPID, SFX_PLAYER_ROCKET, SFX_PLAYER_SPREAD, SFX_ENEMY_SHOT, SFX_EXPLOSION, SFX_POWERUP, SFX_CARRIER, SFX_COUNTDOWN, SFX_WINDING_ENGINE_LOOP, SFX_WINDING_FLYBY, SFX_WINDING_BULLET_WHIZ, SFX_WINDING_TUNNEL_ECHO]:
		if winding_sfx_cache.has(path):
			continue
		var stream := load(path) as AudioStream
		if stream != null:
			winding_sfx_cache[path] = stream


func _ensure_winding_sfx_pool() -> void:
	if winding_sfx_players.size() > 0:
		return
	for index in range(10):
		var player_node := AudioStreamPlayer.new()
		player_node.name = "WindingSfx%d" % index
		add_child(player_node)
		winding_sfx_players.append(player_node)


func _ensure_spatial_sfx_pool() -> void:
	if spatial_sfx_players.size() > 0:
		return
	for index in range(8):
		var player_2d := AudioStreamPlayer2D.new()
		player_2d.name = "WindingSpatialSfx%d" % index
		player_2d.max_distance = 1700.0
		player_2d.attenuation = 0.75
		add_child(player_2d)
		spatial_sfx_players.append(player_2d)


func _play_winding_sfx(path: String, base_db := -10.0, pitch := -1.0) -> void:
	if AppState.sfx_volume <= 0.0001:
		return
	var stream := winding_sfx_cache.get(path) as AudioStream
	if stream == null:
		stream = load(path) as AudioStream
		if stream != null:
			winding_sfx_cache[path] = stream
	if stream == null:
		return
	var player_node := sfx_player
	if not winding_sfx_players.is_empty():
		player_node = winding_sfx_players[winding_sfx_index % winding_sfx_players.size()]
		winding_sfx_index += 1
	if player_node == null:
		return
	player_node.stream = stream
	player_node.volume_db = base_db + linear_to_db(maxf(AppState.sfx_volume, 0.001)) + (1.5 if _winding_is_tunnel_theme() else 0.0)
	player_node.pitch_scale = pitch if pitch > 0.0 else randf_range(0.96, 1.04)
	player_node.play()


func _tick_winding_audio(_delta: float, effective_speed: float) -> void:
	_update_winding_engine_loop(effective_speed)
	_update_winding_enemy_flybys()
	_update_winding_skid_sfx()


func _update_winding_engine_loop(effective_speed: float) -> void:
	var sfx_volume := maxf(AppState.sfx_volume, 0.0)
	if sfx_volume <= 0.0001:
		if engine_loop_player != null:
			engine_loop_player.stop()
		if tunnel_echo_player != null:
			tunnel_echo_player.stop()
		return
	var engine_stream := _winding_sfx_stream(SFX_WINDING_ENGINE_LOOP)
	if engine_loop_player != null and engine_stream != null:
		if engine_loop_player.stream != engine_stream:
			engine_loop_player.stream = engine_stream
		engine_loop_player.volume_db = lerpf(-24.0, -11.0, clampf((effective_speed - 700.0) / 1800.0, 0.0, 1.0)) + linear_to_db(maxf(sfx_volume, 0.001))
		engine_loop_player.pitch_scale = lerpf(0.84, 1.28, clampf(effective_speed / 2700.0, 0.0, 1.0))
		if not engine_loop_player.playing:
			engine_loop_player.play()
	var tunnel_stream := _winding_sfx_stream(SFX_WINDING_TUNNEL_ECHO)
	if tunnel_echo_player == null or tunnel_stream == null:
		return
	var tunnel_amount := 1.0 if _winding_is_tunnel_theme() else 0.0
	if tunnel_amount <= 0.0:
		tunnel_echo_player.stop()
		return
	if tunnel_echo_player.stream != tunnel_stream:
		tunnel_echo_player.stream = tunnel_stream
	tunnel_echo_player.volume_db = -27.0 + linear_to_db(maxf(sfx_volume, 0.001))
	tunnel_echo_player.pitch_scale = 0.62
	if not tunnel_echo_player.playing:
		tunnel_echo_player.play()


func _update_winding_enemy_flybys() -> void:
	for enemy in harrier_enemies:
		var audio_id := str(enemy.get("audio_id", ""))
		if audio_id.is_empty() or bool(enemy_audio_state.get(audio_id, false)):
			continue
		var projected := _project_harrier(float(enemy.get("lane_x", 0.0)), float(enemy.get("lane_y", 0.0)), float(enemy.get("z_depth", 1000.0)))
		if not bool(projected.get("visible", false)):
			continue
		var near := float(projected.get("near", 0.0))
		if near < 0.64:
			continue
		enemy_audio_state[audio_id] = true
		var screen_x := float(projected.get("x", renderer.screen_size.x * 0.5))
		var side := clampf((screen_x - renderer.screen_size.x * 0.5) / maxf(renderer.screen_size.x * 0.5, 1.0), -1.0, 1.0)
		_play_winding_spatial_sfx(SFX_WINDING_FLYBY, screen_x, -22.0 + near * 10.0, 0.82 + near * 0.35 + absf(side) * 0.08)


func _maybe_play_bullet_whiz(bullet: Dictionary) -> void:
	if bullet_whiz_cooldown > 0.0:
		return
	var projected := _project_harrier(float(bullet.get("lane_x", 0.0)), float(bullet.get("lane_y", 0.0)), float(bullet.get("z_depth", 1000.0)))
	if not bool(projected.get("visible", false)):
		return
	var near := float(projected.get("near", 0.0))
	if near < 0.70:
		return
	var lane_delta := absf(float(bullet.get("lane_x", 0.0)) / 250.0 - float(player.lane_pos))
	var height_delta := absf(float(bullet.get("lane_y", 0.0)) - float(player.flight_y))
	if lane_delta > 1.15 or height_delta > 180.0:
		return
	bullet_whiz_cooldown = randf_range(0.10, 0.18)
	_play_winding_spatial_sfx(SFX_WINDING_BULLET_WHIZ, float(projected.get("x", renderer.screen_size.x * 0.5)), -24.0 + near * 9.0, randf_range(1.26, 1.52))


func _update_winding_skid_sfx() -> void:
	if skid_sfx_cooldown > 0.0 or player == null or not is_instance_valid(player):
		return
	var skid_amount := float(player.get("skid_amount"))
	if skid_amount < 0.26:
		return
	skid_sfx_cooldown = lerpf(0.34, 0.18, clampf(skid_amount, 0.0, 1.0))
	_play_winding_spatial_sfx(SFX_PLAYER_LASER, float(player.position.x), -28.0 + skid_amount * 8.0, 0.50 + skid_amount * 0.26)


func _play_winding_spatial_sfx(path: String, screen_x: float, base_db := -14.0, pitch := 1.0) -> void:
	if spatial_sfx_players.is_empty() or AppState.sfx_volume <= 0.0001:
		return
	var stream := _winding_sfx_stream(path)
	if stream == null:
		return
	var player_2d := spatial_sfx_players[spatial_sfx_index % spatial_sfx_players.size()]
	spatial_sfx_index += 1
	player_2d.stream = stream
	player_2d.position = Vector2(screen_x, renderer.screen_size.y * 0.50)
	player_2d.volume_db = base_db + linear_to_db(maxf(AppState.sfx_volume, 0.001)) + (2.0 if _winding_is_tunnel_theme() else 0.0)
	player_2d.pitch_scale = pitch
	player_2d.play()


func _winding_sfx_stream(path: String) -> AudioStream:
	var stream := winding_sfx_cache.get(path) as AudioStream
	if stream == null:
		stream = load(path) as AudioStream
		if stream != null:
			winding_sfx_cache[path] = stream
	return stream


func _winding_is_tunnel_theme() -> bool:
	var theme_id := str(level_data.get("theme_id", ""))
	return theme_id in ["red_tunnel", "enemy_tunnel", "glass_tunnel", "industrial_pipe"]


func _winding_music_volume_db(base_db: float) -> float:
	if AppState.music_volume <= 0.0001:
		return -80.0
	return base_db + linear_to_db(maxf(AppState.music_volume, 0.001))


func _on_modal_button_pressed(panel: PanelContainer, is_result: bool) -> void:
	if is_result:
		_return_to_menu()
		return
	_resume_winding_pause()


func _build_rider_select_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2(180.0, 96.0)
	panel.custom_minimum_size = Vector2(900.0, 520.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	var title := Label.new()
	title.text = "SELECT WINDING ROAD RIDER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	box.add_child(title)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	box.add_child(cards)
	for rider_id in ["female", "gunner", "scout"]:
		cards.add_child(_build_rider_card(rider_id))
	var start_button := Button.new()
	start_button.name = "StartButton"
	start_button.text = "START WINDING ROAD RUN"
	start_button.custom_minimum_size = Vector2(0.0, 46.0)
	start_button.pressed.connect(_deploy_winding_rider)
	box.add_child(start_button)
	return panel


func _build_rider_card(rider_id: String) -> Button:
	var rider_def: Dictionary = RIDER_DEFS.get(rider_id, RIDER_DEFS["female"])
	var button := Button.new()
	button.name = "%sRiderButton" % rider_id.capitalize()
	button.custom_minimum_size = Vector2(270.0, 350.0)
	button.toggle_mode = true
	button.pressed.connect(_on_rider_card_pressed.bind(rider_id))
	var layout := VBoxContainer.new()
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_theme_constant_override("separation", 8)
	button.add_child(layout)
	var image := HoveringRiderPreview.new()
	image.custom_minimum_size = Vector2(250.0, 150.0)
	image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture = _load_texture(str(rider_def.get("ride_path", "")))
	image.set("phase_offset", float(abs(rider_id.hash() % 100)) * 0.07)
	layout.add_child(image)
	var name := Label.new()
	name.name = "NameLabel"
	name.text = str(rider_def.get("label", "Rider")).to_upper()
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 22)
	layout.add_child(name)
	var stats := Label.new()
	stats.name = "StatsLabel"
	stats.text = str(rider_def.get("stats", "Balanced rider."))
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 16)
	layout.add_child(stats)
	var view_hint := Label.new()
	view_hint.text = "VIEW SHIP"
	view_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	view_hint.add_theme_font_size_override("font_size", 14)
	view_hint.add_theme_color_override("font_color", Color(0.52, 0.88, 1.0))
	layout.add_child(view_hint)
	return button


func _build_ship_view_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = Vector2(130.0, 70.0)
	panel.custom_minimum_size = Vector2(1020.0, 610.0)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	margin.add_child(row)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(660.0, 0.0)
	left.add_theme_constant_override("separation", 12)
	row.add_child(left)
	var title := Label.new()
	title.text = "SHIP INSPECTION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	left.add_child(title)
	ship_preview = ShipSpinPreview.new()
	ship_preview.custom_minimum_size = Vector2(650.0, 440.0)
	left.add_child(ship_preview)
	var hint := Label.new()
	hint.text = "Drag to spin. Mouse wheel zooms the ship view."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.74, 0.86, 0.94))
	left.add_child(hint)

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(300.0, 0.0)
	right.add_theme_constant_override("separation", 14)
	row.add_child(right)
	var info_title := Label.new()
	info_title.text = "SHIP DOSSIER"
	info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_title.add_theme_font_size_override("font_size", 22)
	right.add_child(info_title)
	ship_info_label = Label.new()
	ship_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ship_info_label.add_theme_font_size_override("font_size", 16)
	ship_info_label.custom_minimum_size = Vector2(0.0, 350.0)
	right.add_child(ship_info_label)
	var back_button := Button.new()
	back_button.text = "BACK TO RIDERS"
	back_button.custom_minimum_size = Vector2(0.0, 44.0)
	back_button.pressed.connect(_close_ship_viewer)
	right.add_child(back_button)
	var start_button := Button.new()
	start_button.text = "START GAME"
	start_button.custom_minimum_size = Vector2(0.0, 48.0)
	start_button.pressed.connect(_deploy_winding_rider)
	right.add_child(start_button)
	return panel


func _show_rider_select() -> void:
	selected_rider_id = str(PlayState.speedbike_rider_id).strip_edges().to_lower()
	if not RIDER_DEFS.has(selected_rider_id):
		selected_rider_id = "female"
	rider_select_open = true
	if rider_select_panel != null:
		rider_select_panel.visible = true
	if ship_view_panel != null:
		ship_view_panel.visible = false
	if select_fx_overlay != null:
		select_fx_overlay.visible = true
	_update_rider_select_buttons()
	_apply_selected_rider_profile()
	_set_countdown_text("")
	_start_winding_select_music()


func _set_winding_rider(rider_id: String) -> void:
	selected_rider_id = rider_id if RIDER_DEFS.has(rider_id) else "female"
	PlayState.speedbike_rider_id = selected_rider_id
	if PlayState.has_method("flush_progress"):
		PlayState.flush_progress()
	_update_rider_select_buttons()
	_apply_selected_rider_profile()


func _on_rider_card_pressed(rider_id: String) -> void:
	_set_winding_rider(rider_id)
	_open_ship_viewer()


func _open_ship_viewer() -> void:
	if ship_view_panel == null:
		return
	if rider_select_panel != null:
		rider_select_panel.visible = false
	if karaoke_overlay != null:
		karaoke_overlay.visible = false
	var rider_def: Dictionary = RIDER_DEFS.get(selected_rider_id, RIDER_DEFS["female"])
	var texture := _load_texture(str(rider_def.get("ride_path", "")))
	if ship_preview != null:
		ship_preview.set("texture", texture)
		ship_preview.set("ship_name", str(rider_def.get("label", "Rider")))
	if ship_info_label != null:
		ship_info_label.text = _ship_dossier_text(selected_rider_id)
	ship_view_panel.visible = true


func _close_ship_viewer() -> void:
	if ship_view_panel != null:
		ship_view_panel.visible = false
	if rider_select_panel != null:
		rider_select_panel.visible = true
	if karaoke_overlay != null:
		karaoke_overlay.visible = true
	_update_rider_select_buttons()


func _ship_dossier_text(rider_id: String) -> String:
	var rider_def: Dictionary = RIDER_DEFS.get(rider_id, RIDER_DEFS["female"])
	var label := str(rider_def.get("label", "Rider")).to_upper()
	var handling := "Balanced"
	var jump_profile := "Standard lift"
	var cannon := "Steady cannon"
	if rider_id == "gunner":
		handling = "Heavy, stable turn-in"
		jump_profile = "Lower arc, strong road grip"
		cannon = "Tougher cannon rhythm"
	elif rider_id == "scout":
		handling = "Fast lane cuts"
		jump_profile = "High arc, light frame"
		cannon = "Quick but lighter fire"
	return "%s\n\n%s\n\nHandling: %s\nLift profile: %s\nWeapons: %s\nRoad role: %s\n\nThis craft is tuned for the winding Badlands road set. Keep it on the road for full braking control, go airborne for risky side kills, and use the emergency brake only when you mean it." % [
		label,
		str(rider_def.get("stats", "Balanced rider.")),
		handling,
		jump_profile,
		cannon,
		"Precision survival"
	]


func _deploy_winding_rider() -> void:
	_set_winding_rider(selected_rider_id)
	_apply_rider_starting_weapon()
	rider_select_open = false
	if rider_select_panel != null:
		rider_select_panel.visible = false
	if ship_view_panel != null:
		ship_view_panel.visible = false
	if select_fx_overlay != null:
		select_fx_overlay.visible = false
	if karaoke_overlay != null:
		karaoke_overlay.visible = false
	countdown_active = false
	countdown_started_run = false
	countdown_last_label = ""
	countdown_delay_timer = 4.0
	go_flash_timer = 0.0
	countdown_timer = 0.0
	_start_winding_intro_music()
	_set_countdown_text("")


func _tick_rider_select_backdrop(delta: float) -> void:
	var select_speed := maxf(float(level_data.get("base_speed", 720.0)) * 0.42, 360.0)
	camera_z += select_speed * delta
	renderer.set_road_scale_factor(1.0)
	renderer.set_camera_z(camera_z)
	if select_fx_overlay != null:
		select_fx_overlay.queue_redraw()
	if karaoke_overlay != null:
		karaoke_overlay.queue_redraw()


func _update_dynamic_road_scale() -> void:
	if renderer == null or player == null or not is_instance_valid(player):
		return
	var altitude := maxf(-float(player.flight_y), float(player.jump_z))
	var air_t := clampf(altitude / 520.0, 0.0, 1.0)
	var ground_scale := 2.0
	if str(level_data.get("theme_id", "")) == "red_tunnel":
		ground_scale = 1.55
	var target_scale := lerpf(ground_scale, 0.50, pow(air_t, 0.70))
	renderer.set_road_scale_factor(target_scale)


func _update_rider_select_buttons() -> void:
	if rider_select_panel == null:
		return
	for rider_id in ["female", "gunner", "scout"]:
		var button := rider_select_panel.find_child("%sRiderButton" % rider_id.capitalize(), true, false) as Button
		if button != null:
			var rider_def: Dictionary = RIDER_DEFS.get(rider_id, RIDER_DEFS["female"])
			button.text = ""
			button.button_pressed = rider_id == selected_rider_id
			button.tooltip_text = "%s - %s" % [str(rider_def.get("label", "Rider")), str(rider_def.get("stats", ""))]
			var name_label := button.find_child("NameLabel", true, false) as Label
			if name_label != null:
				name_label.text = "%s%s" % ["> " if rider_id == selected_rider_id else "", str(rider_def.get("label", "Rider")).to_upper()]


func _apply_selected_rider_profile() -> void:
	if player == null or not player.has_method("apply_rider_profile"):
		return
	var rider_def: Dictionary = RIDER_DEFS.get(selected_rider_id, RIDER_DEFS["female"])
	player.apply_rider_profile({
		"ride_texture": _load_texture(str(rider_def.get("ride_path", ""))),
		"jump_texture": _load_texture(str(rider_def.get("jump_path", ""))),
		"horizontal_mult": float(rider_def.get("horizontal_mult", 1.0)),
		"jump_height_add": float(rider_def.get("jump_height_add", 0.0)),
		"jump_duration_mult": float(rider_def.get("jump_duration_mult", 1.0)),
		"shot_cooldown_mult": float(rider_def.get("shot_cooldown_mult", 1.0)),
		"winding_scale_mult": float(rider_def.get("winding_scale_mult", 1.0))
	})


func _apply_rider_starting_weapon() -> void:
	var rider_def: Dictionary = RIDER_DEFS.get(selected_rider_id, RIDER_DEFS["female"])
	var start_weapon := str(rider_def.get("start_weapon", "rifle")).strip_edges().to_lower()
	winding_weapon_kind = "rifle"
	winding_spread_ammo = 0
	winding_rocket_ammo = 0
	match start_weapon:
		"spread":
			winding_weapon_kind = "spread"
			winding_spread_ammo = 240
		"rocket":
			winding_weapon_kind = "rocket"
			winding_rocket_ammo = 24
		"laser", "machine", "rapid", "fireball":
			winding_weapon_kind = start_weapon
		_:
			winding_weapon_kind = "rifle"


func _load_texture(path: String) -> Texture2D:
	if path.strip_edges().is_empty():
		return null
	var texture := load(path)
	return texture as Texture2D


func _return_to_menu() -> void:
	get_tree().change_scene_to_file(PlayState.APP_SHELL_SCENE)


func _update_hud() -> void:
	if stage_label == null:
		return
	stage_label.text = "STAGE %d" % int(level_data.get("stage", 50))
	score_label.text = "SCORE %d" % score
	speed_label.text = "SPD %04d" % int(speed)
	if lives_label != null:
		lives_label.text = "LIVES %d" % lives
	if weapon_label != null:
		var weapon_color := _winding_weapon_color(_active_winding_weapon())
		weapon_label.text = _winding_weapon_label_text()
		weapon_label.add_theme_color_override("font_color", Color(weapon_color.r, weapon_color.g, weapon_color.b, 0.94))
	if coin_combo_label != null:
		if coin_combo_bank_timer > 0.0 and coin_combo_bank_amount > 0:
			var bank_pulse := 0.55 + sin(run_elapsed * 18.0) * 0.45
			coin_combo_label.text = "BANKED +%d COINS" % coin_combo_bank_amount
			coin_combo_label.add_theme_color_override("font_color", Color(1.0, 0.58 + bank_pulse * 0.32, 0.16, 0.96))
		elif coin_combo_display_timer > 0.0 and coin_combo_count > 0:
			var live_pulse := 0.55 + sin(run_elapsed * 14.0) * 0.45
			coin_combo_label.text = "COIN COMBO x%d" % coin_combo_count
			coin_combo_label.add_theme_color_override("font_color", Color(1.0, 0.76 + live_pulse * 0.20, 0.24, 0.94))
		else:
			coin_combo_label.text = ""
	health_bar.set_health(float(player.health), maxf(float(player.max_health), 1.0))
	var length := maxf(float(level_data.get("length", 6000.0)), 1.0)
	progress_bar.value = clampf((camera_z - stage_origin_z) / length, 0.0, 1.0)
	if gauge_overlay != null:
		gauge_overlay.queue_redraw()
	if checkpoint_message_timer > 0.0:
		checkpoint_message_timer -= get_physics_process_delta_time()
		if checkpoint_message_timer <= 0.0:
			message_label.text = ""
	if go_flash_timer > 0.0:
		go_flash_timer -= get_physics_process_delta_time()
		if go_flash_timer <= 0.0 and not countdown_active:
			_set_countdown_text("")



func _show_message(text: String, duration: float) -> void:
	message_label.text = text
	checkpoint_message_timer = duration


func _set_countdown_text(text: String) -> void:
	if countdown_label == null:
		return
	countdown_label.text = text
	countdown_label.add_theme_font_size_override("font_size", 126 if text == "GO!" else 96)
	countdown_label.visible = not text.strip_edges().is_empty()


func _clear_obstacles() -> void:
	for obstacle in obstacles:
		if is_instance_valid(obstacle):
			obstacle.queue_free()
	obstacles.clear()


func _spawn_obstacles_near() -> void:
	if WINDING_COMBAT_FOCUS_NO_ROAD_OBJECTS:
		next_obstacle_index = obstacle_rows.size()
		return
	var spawn_until := camera_z + renderer.visible_distance + 720.0
	while next_obstacle_index < obstacle_rows.size():
		var row := obstacle_rows[next_obstacle_index]
		if float(row.get("z", 0.0)) > spawn_until:
			break
		if str(row.get("type", "")) in ["drone", "dropper_drone", "powerup_carrier"]:
			next_obstacle_index += 1
			continue
		var obstacle: Node = WINDING_OBSTACLE_SCRIPT.new()
		obstacle.setup(_prepare_winding_obstacle_row(row))
		obstacle_layer.add_child(obstacle)
		obstacles.append(obstacle)
		next_obstacle_index += 1


func _prepare_winding_obstacle_row(row: Dictionary) -> Dictionary:
	var next := row.duplicate(true)
	var kind := str(next.get("type", ""))
	if not bool(next.get("shootable", false)):
		return next
	var base_hp := int(next.get("hp", 1))
	var stage := int(level_data.get("stage", WindingLevelData.FIRST_STAGE))
	var stage_mult := 1.0 + maxf(0.0, float(stage - WindingLevelData.FIRST_STAGE)) * 0.10
	var difficulty_mult := clampf(float(_speedbike_difficulty().get("speed_scale", 1.0)), 0.75, 1.65)
	match kind:
		"powerup_carrier":
			next["hp"] = maxi(2, int(ceil(float(base_hp) * 0.75 * difficulty_mult)))
		"mine":
			next["hp"] = maxi(2, int(ceil(float(base_hp) * minf(stage_mult, 1.45))))
		"dropper_drone":
			next["hp"] = maxi(5, int(ceil(float(base_hp) * stage_mult * difficulty_mult * 1.20)))
		"drone":
			next["hp"] = maxi(4, int(ceil(float(base_hp) * stage_mult * difficulty_mult)))
		_:
			next["hp"] = maxi(base_hp, int(ceil(float(base_hp) * stage_mult)))
	return next


func _sort_obstacle_rows(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("z", 0.0)) < float(b.get("z", 0.0))


func _configure_weather() -> void:
	weather_kind = "clear"
	if perf_baseline:
		lightning_flash = 0.0
		lightning_points = PackedVector2Array()
		lightning_timer = 0.0
		snow_coverage = 0.0
		snowflakes.clear()
		if weather_overlay != null:
			weather_overlay.visible = true
		return
	var stage := int(level_data.get("stage", 50))
	var theme_id := str(level_data.get("theme_id", ""))
	if theme_id in ["sandstorm", "enemy_tunnel"] or stage in [51, 55, 57, 59, 60]:
		weather_kind = "storm"
	elif theme_id in ["glass_tunnel"] or stage in [52, 54, 58]:
		weather_kind = "snow"
	elif randf() < 0.16:
		weather_kind = "snow" if randf() < 0.45 else "storm"
	lightning_flash = 0.0
	lightning_points = PackedVector2Array()
	lightning_timer = randf_range(3.0, 7.0) if weather_kind == "storm" else 0.0
	snow_coverage = 0.0
	snowflakes.clear()
	if weather_kind == "snow":
		for _i in range(88):
			snowflakes.append(_new_snowflake(true))


func _tick_weather(delta: float) -> void:
	if weather_kind == "storm":
		lightning_timer -= delta
		lightning_flash = maxf(lightning_flash - delta * 2.6, 0.0)
		if lightning_timer <= 0.0:
			_spawn_winding_lightning()
			lightning_timer = randf_range(4.0, 9.0)
	elif weather_kind == "snow":
		snow_coverage = clampf(snow_coverage + delta * 0.012, 0.0, 0.68)
		for index in range(snowflakes.size()):
			var flake := snowflakes[index]
			var pos := flake.get("pos", Vector2.ZERO) as Vector2
			pos.x += float(flake.get("drift", -24.0)) * delta
			pos.y += float(flake.get("speed", 70.0)) * delta
			if pos.y > renderer.screen_size.y + 20.0 or pos.x < -40.0:
				flake = _new_snowflake(false)
			else:
				flake["pos"] = pos
			snowflakes[index] = flake
	if weather_overlay != null:
		weather_overlay.queue_redraw()


func _spawn_winding_lightning() -> void:
	var lane := randf_range(-1.6, 1.6)
	var projected := renderer.project(camera_z + randf_range(520.0, 1180.0), lane)
	var target := Vector2(float(projected.get("x", renderer.screen_size.x * 0.5)), float(projected.get("y", renderer.screen_size.y * 0.55)))
	var start := Vector2(target.x + randf_range(-100.0, 100.0), 0.0)
	var points := PackedVector2Array([start])
	for step in range(1, 8):
		var t := float(step) / 7.0
		points.append(Vector2(lerpf(start.x, target.x, t) + randf_range(-24.0, 24.0), lerpf(start.y, target.y, t)))
	lightning_points = points
	lightning_flash = 1.0
	_show_message("LIGHTNING STRIKE", 0.7)


func _new_snowflake(initial: bool) -> Dictionary:
	return {
		"pos": Vector2(randf_range(0.0, renderer.screen_size.x + 40.0), randf_range(-40.0, renderer.screen_size.y) if initial else randf_range(-60.0, -6.0)),
		"speed": randf_range(34.0, 98.0),
		"drift": randf_range(-38.0, -6.0),
		"size": randf_range(1.2, 4.0),
		"alpha": randf_range(0.26, 0.70)
	}


func _player_in_gravity_zone() -> bool:
	for obstacle in obstacles:
		if obstacle.is_gravity_zone(camera_z + PLAYER_COLLISION_OFFSET):
			return true
	return false


func _crash_label_for(kind: String) -> String:
	match kind:
		"pit":
			return "BROKEN ROAD"
		"low_barricade":
			return "JUMP MISSED"
		"laser_gate":
			return "LASER HIT"
		"mine":
			return "MINE HIT"
		"drone", "dropper_drone":
			return "DRONE IMPACT"
	return "CRASH"


func _speedbike_difficulty() -> Dictionary:
	if PlayState.has_method("speedbike_difficulty"):
		return PlayState.speedbike_difficulty()
	return {"hits": 2, "instant_crash": false, "speed_scale": 1.0}


func _checkpoints_enabled() -> bool:
	return bool(PlayState.speedbike_checkpoints_enabled)


class WeatherOverlay:
	extends Node2D

	var mode: Node

	func _draw() -> void:
		if mode == null:
			return
		var renderer_ref: Pseudo3DRoadRenderer = mode.renderer
		if renderer_ref == null:
			return
		_draw_headlight(renderer_ref)
		if float(mode.screen_impact_flash) > 0.0:
			var impact_alpha := clampf(float(mode.screen_impact_flash) / 3.0, 0.0, 1.0)
			var screen_rect := Rect2(Vector2.ZERO, renderer_ref.screen_size)
			draw_rect(screen_rect, Color(1.0, 0.02, 0.0, 0.16 * impact_alpha), true)
			draw_rect(screen_rect, Color(0.95, 0.98, 1.0, 0.08 * impact_alpha), true)
			var crack_color := Color(1.0, 0.92, 0.78, 0.84 * impact_alpha)
			var crack_shadow := Color(0.05, 0.02, 0.015, 0.34 * impact_alpha)
			var center := Vector2(renderer_ref.screen_size.x * float(mode.screen_impact_anchor.x), renderer_ref.screen_size.y * float(mode.screen_impact_anchor.y))
			draw_circle(center, 42.0 + 16.0 * impact_alpha, Color(1.0, 0.92, 0.72, 0.055 * impact_alpha))
			for arm in range(9):
				var angle := -PI + float(arm) * TAU / 9.0 + sin(float(arm) * 2.1) * 0.13
				var start := center + Vector2(cos(angle), sin(angle)) * (18.0 + float(arm % 2) * 9.0)
				var finish := center + Vector2(cos(angle), sin(angle)) * (72.0 + float(arm % 4) * 35.0) * (0.70 + impact_alpha * 0.32)
				draw_line(start + Vector2(1.5, 1.5), finish + Vector2(1.5, 1.5), crack_shadow, 3.2)
				draw_line(start, finish, crack_color, 1.75)
				for branch in range(2):
					var branch_t := 0.42 + float(branch) * 0.22
					var branch_start := start.lerp(finish, branch_t)
					var branch_angle := angle + (0.48 if branch == 0 else -0.54) + sin(float(arm + branch)) * 0.16
					var branch_finish := branch_start + Vector2(cos(branch_angle), sin(branch_angle)) * (16.0 + float((arm + branch) % 3) * 10.0) * impact_alpha
					draw_line(branch_start + Vector2(1.0, 1.0), branch_finish + Vector2(1.0, 1.0), crack_shadow, 1.8)
					draw_line(branch_start, branch_finish, crack_color, 0.95)
		if mode.weather_kind == "snow":
			var screen := renderer_ref.screen_size
			var alpha := 0.18 * float(mode.snow_coverage)
			var road_y := screen.y * 0.52
			draw_rect(Rect2(0.0, road_y, screen.x, screen.y - road_y), Color(0.88, 0.95, 1.0, alpha), true)
			for flake in mode.snowflakes:
				var pos := flake.get("pos", Vector2.ZERO) as Vector2
				draw_circle(pos, float(flake.get("size", 2.0)), Color(0.92, 0.98, 1.0, float(flake.get("alpha", 0.5))))
		elif mode.weather_kind == "storm":
			var screen := renderer_ref.screen_size
			var rain_color := Color(0.58, 0.74, 0.94, 0.16)
			for index in range(40):
				var x := fmod(float(index) * 47.0 + mode.camera_z * 0.20, screen.x + 90.0) - 45.0
				var y := fmod(float(index * 39) + mode.elapsed * 430.0, screen.y + 80.0) - 40.0
				draw_line(Vector2(x, y), Vector2(x - 18.0, y + 40.0), rain_color, 1.4, true)
			if mode.lightning_flash > 0.0 and mode.lightning_points.size() >= 2:
				draw_polyline(mode.lightning_points, Color(0.88, 0.96, 1.0, 0.92 * mode.lightning_flash), 5.0, true)
				draw_polyline(mode.lightning_points, Color(0.25, 0.58, 1.0, 0.45 * mode.lightning_flash), 13.0, true)
				draw_rect(Rect2(Vector2.ZERO, screen), Color(0.70, 0.86, 1.0, 0.10 * mode.lightning_flash), true)

	func _draw_headlight(renderer_ref: Pseudo3DRoadRenderer) -> void:
		if mode.player == null or not is_instance_valid(mode.player):
			return
		if bool(mode.rider_select_open) or bool(mode.stage_clear):
			return
		var strength := _headlight_strength()
		if strength <= 0.01:
			return
		var lane := float(mode.player.lane_pos)
		var player_pos = mode.player.position + Vector2(0.0, -14.0)
		var near := renderer_ref.project(float(mode.camera_z) + 420.0, lane)
		var mid := renderer_ref.project(float(mode.camera_z) + 1050.0, lane)
		var far := renderer_ref.project(float(mode.camera_z) + 1820.0, lane)
		if not bool(mid.get("visible", false)) or not bool(far.get("visible", false)):
			return
		var near_pos := Vector2(float(near.get("x", player_pos.x)), float(near.get("y", player_pos.y)))
		var mid_pos := Vector2(float(mid.get("x", player_pos.x)), float(mid.get("y", player_pos.y)))
		var far_pos := Vector2(float(far.get("x", player_pos.x)), float(far.get("y", player_pos.y)))
		var near_width := float(near.get("width", 520.0)) * 0.11
		var mid_width := float(mid.get("width", 320.0)) * 0.28
		var far_width := float(far.get("width", 110.0)) * 0.82
		var beam_color := Color(0.68, 0.88, 1.0, 0.09 * strength)
		var core_color := Color(0.98, 1.0, 0.82, 0.12 * strength)
		var glow_color := Color(0.20, 0.76, 1.0, 0.06 * strength)
		var source = player_pos + Vector2(0.0, 4.0)
		var beam_right := mid_pos + Vector2(mid_width * 0.92, 0.0)
		var beam_far_right := far_pos + Vector2(far_width * 1.15, -8.0)
		var beam_far_left := far_pos + Vector2(-far_width * 1.15, -8.0)
		var beam_left := mid_pos + Vector2(-mid_width * 0.92, 0.0)
		_draw_safe_triangle(source, beam_right, beam_far_right, beam_color)
		_draw_safe_triangle(source, beam_far_right, beam_far_left, beam_color)
		_draw_safe_triangle(source, beam_far_left, beam_left, beam_color)
		var core_source = source + Vector2(0.0, -2.0)
		var core_right := mid_pos + Vector2(mid_width * 0.28, 0.0)
		var core_far_right := far_pos + Vector2(far_width * 0.22, -2.0)
		var core_far_left := far_pos + Vector2(-far_width * 0.22, -2.0)
		var core_left := mid_pos + Vector2(-mid_width * 0.34, 0.0)
		_draw_safe_triangle(core_source, core_right, core_far_right, core_color)
		_draw_safe_triangle(core_source, core_far_right, core_far_left, core_color)
		_draw_safe_triangle(core_source, core_far_left, core_left, core_color)
		var pulse := 0.5 + sin(float(mode.elapsed) * 7.0) * 0.5
		draw_circle(player_pos, 12.0 + pulse * 4.0, Color(0.88, 1.0, 0.82, 0.26 * strength))
		for index in range(3):
			var t := fmod(float(mode.camera_z) * 0.0015 + float(index) * 0.33, 1.0)
			var stripe_pos := near_pos.lerp(far_pos, t)
			var stripe_half := lerpf(near_width * 0.28, far_width * 0.70, t)
			var stripe_alpha := (0.07 + (1.0 - t) * 0.05) * strength
			draw_line(stripe_pos + Vector2(-stripe_half, 0.0), stripe_pos + Vector2(stripe_half, 0.0), Color(glow_color.r, glow_color.g, glow_color.b, stripe_alpha), 1.4, true)

	func _draw_safe_triangle(a: Vector2, b: Vector2, c: Vector2, color: Color) -> void:
		if color.a <= 0.001:
			return
		var area := absf((b - a).cross(c - a))
		if area < 1.0:
			return
		draw_colored_polygon(PackedVector2Array([a, b, c]), color)

	func _headlight_strength() -> float:
		var theme_id := str(mode.level_data.get("theme_id", ""))
		var base := 0.18
		if theme_id in ["enemy_tunnel", "neon_mine", "glass_tunnel", "industrial_pipe"]:
			base = 0.88
		elif theme_id == "sandstorm":
			base = 0.62
		if mode.weather_kind in ["storm", "snow"]:
			base = maxf(base, 0.72)
		var sky_time := clampf(float(mode.camera_z) / 12000.0, 0.0, 1.0)
		return clampf(base + sky_time * 0.18, 0.0, 1.0)


class WindingHudGaugeOverlay:
	extends Node2D

	var mode: Node

	func _draw() -> void:
		if mode == null:
			return
		var viewport := get_viewport()
		if viewport == null:
			return
		var screen := viewport.get_visible_rect().size
		var alpha := 0.92
		var center := Vector2(screen.x - 118.0, 122.0)
		var speed_value := float(mode.speed)
		var speed_ratio := clampf((speed_value - 700.0) / 2300.0, 0.0, 1.0)
		var start_angle := deg_to_rad(142.0)
		var end_angle := deg_to_rad(398.0)
		draw_circle(center, 58.0, Color(0.025, 0.020, 0.014, 0.48 * alpha))
		draw_arc(center, 47.0, start_angle, end_angle, 40, Color(1.0, 0.80, 0.36, 0.22 * alpha), 5.0, true)
		draw_arc(center, 47.0, start_angle, lerpf(start_angle, end_angle, speed_ratio), 40, _speed_color(speed_ratio, alpha), 6.0, true)
		var needle_angle := lerpf(start_angle, end_angle, speed_ratio)
		draw_line(center, center + Vector2(cos(needle_angle), sin(needle_angle)) * 39.0, Color(1.0, 0.88, 0.42, 0.90 * alpha), 4.0, true)
		draw_circle(center, 7.0, Color(1.0, 0.58, 0.16, 0.90 * alpha))
		var font := ThemeDB.fallback_font
		if font != null:
			draw_string(font, center + Vector2(-42.0, 78.0), "SPEED", HORIZONTAL_ALIGNMENT_CENTER, 84.0, 14, Color(1.0, 0.82, 0.50, 0.82 * alpha))
			draw_string(font, center + Vector2(-50.0, 20.0), "%04d" % int(speed_value), HORIZONTAL_ALIGNMENT_CENTER, 100.0, 17, Color(0.94, 0.86, 0.70, 0.92 * alpha))

	func _speed_color(ratio: float, alpha: float) -> Color:
		if ratio > 0.78:
			return Color(1.0, 0.15, 0.08, 0.92 * alpha)
		if ratio > 0.52:
			return Color(1.0, 0.62, 0.12, 0.90 * alpha)
		return Color(0.18, 0.78, 1.0, 0.88 * alpha)


class WindingHealthTube:
	extends Control

	var max_health := 1.0
	var target_health := 1.0
	var displayed_health := 1.0
	var pulse_time := 0.0

	func _ready() -> void:
		custom_minimum_size = Vector2(210.0, 22.0)

	func set_health(value: float, maximum: float) -> void:
		max_health = maxf(maximum, 1.0)
		target_health = clampf(value, 0.0, max_health)
		queue_redraw()

	func _process(delta: float) -> void:
		pulse_time += delta
		displayed_health = lerpf(displayed_health, target_health, clampf(delta * 7.0, 0.0, 1.0))
		queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			rect.size = custom_minimum_size
		var ratio := clampf(displayed_health / maxf(max_health, 1.0), 0.0, 1.0)
		var target_ratio := clampf(target_health / maxf(max_health, 1.0), 0.0, 1.0)
		var danger_pulse := 0.5 + sin(pulse_time * 9.0) * 0.5
		var frame_color := Color(0.16, 1.0, 0.42, 0.82)
		if ratio <= 0.25:
			frame_color = Color(0.72, 0.02, 0.02, 0.62 + danger_pulse * 0.34)
		elif ratio <= 0.50:
			frame_color = Color(0.94, 0.74, 0.10, 0.86)
		var tube := rect.grow(-1.0)
		draw_rect(rect.grow(4.0), Color(frame_color.r, frame_color.g, frame_color.b, 0.11), true)
		draw_rect(rect, Color(0.015, 0.025, 0.015, 0.88), true)
		draw_rect(tube, Color(0.02, 0.07, 0.035, 0.92), true)
		var fill_rect := Rect2(tube.position + Vector2(3.0, 3.0), Vector2(maxf(0.0, (tube.size.x - 6.0) * ratio), tube.size.y - 6.0))
		var delayed_rect := Rect2(tube.position + Vector2(3.0, 3.0), Vector2(maxf(0.0, (tube.size.x - 6.0) * target_ratio), tube.size.y - 6.0))
		if fill_rect.size.x > 0.0:
			var fill_color := Color(0.12, 0.94, 0.34, 0.92)
			var deep_color := Color(0.02, 0.34, 0.12, 0.82)
			draw_rect(fill_rect, fill_color, true)
			var wave_x := fmod(pulse_time * 24.0, 48.0)
			for x in range(-48, int(fill_rect.size.x) + 48, 24):
				var smoke_t := 0.5 + sin(pulse_time * 2.6 + float(x) * 0.08) * 0.5
				var smoke_rect := Rect2(fill_rect.position + Vector2(float(x) + wave_x, fill_rect.size.y * 0.18), Vector2(18.0 + smoke_t * 9.0, fill_rect.size.y * 0.58))
				draw_rect(fill_rect.intersection(smoke_rect), Color(deep_color.r, deep_color.g, deep_color.b, 0.16 + smoke_t * 0.10), true)
			for puff in range(5):
				var puff_t := fmod(pulse_time * 0.38 + float(puff) * 0.21, 1.0)
				var puff_x := fill_rect.position.x + fill_rect.size.x * puff_t
				var puff_y := fill_rect.position.y + fill_rect.size.y * (0.38 + sin(pulse_time * 1.7 + float(puff)) * 0.18)
				draw_circle(Vector2(puff_x, puff_y), fill_rect.size.y * (0.22 + puff_t * 0.12), Color(0.62, 1.0, 0.56, 0.10 * (1.0 - puff_t)))
			draw_line(fill_rect.position + Vector2(0.0, 2.0), fill_rect.position + Vector2(fill_rect.size.x, 2.0), Color(0.88, 1.0, 0.74, 0.48), 2.0, true)
		if displayed_health > target_health + 0.04:
			var ghost := Rect2(delayed_rect.position + Vector2(delayed_rect.size.x, 0.0), Vector2(maxf(0.0, fill_rect.end.x - delayed_rect.end.x), delayed_rect.size.y))
			draw_rect(ghost, Color(0.80, 1.0, 0.42, 0.18), true)
		draw_rect(rect, frame_color, false, 2.0)
		draw_rect(rect.grow(-3.0), Color(0.76, 1.0, 0.52, 0.16), false, 1.0)


class WindingBulletOverlay:
	extends Node2D

	var mode: Node

	func _draw() -> void:
		if mode == null or mode.renderer == null:
			return
		_draw_player_skid_marks()
		for enemy in mode.harrier_enemies:
			var projected_enemy: Dictionary = mode._project_harrier(float(enemy.get("lane_x", 0.0)), float(enemy.get("lane_y", 0.0)), float(enemy.get("z_depth", 1000.0)))
			if not bool(projected_enemy.get("visible", false)):
				continue
			var enemy_texture := mode._harrier_texture(str(enemy.get("type", "straight_charger"))) as Texture2D
			if enemy_texture == null:
				continue
			var enemy_scale := float(projected_enemy.get("scale", 0.2))
			var enemy_pos := Vector2(float(projected_enemy.get("x", 0.0)), float(projected_enemy.get("y", 0.0)))
			var kick := float(enemy.get("hit_kick", 0.0))
			if kick > 0.0:
				enemy_pos += Vector2(sin(float(Time.get_ticks_msec()) * 0.055) * 9.0 * kick, 34.0 * kick)
			var tex_size := Vector2(float(enemy_texture.get_width()), float(enemy_texture.get_height()))
			var draw_height := 116.0 * enemy_scale
			var draw_size := tex_size * (draw_height / maxf(tex_size.y, 1.0))
			var near := float(projected_enemy.get("near", 0.0))
			draw_set_transform(enemy_pos + Vector2(0.0, draw_size.y * 0.36), 0.0, Vector2(1.8, 0.36))
			draw_circle(Vector2.ZERO, draw_size.y * 0.22, Color(0.0, 0.0, 0.0, 0.14 + near * 0.20))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			if bool(enemy.get("smoking", false)):
				var smoke_phase := float(enemy.get("smoke_phase", 0.0)) + float(Time.get_ticks_msec()) * 0.0022
				for puff in range(6):
					var puff_t := float(puff) / 5.0
					var puff_pos := enemy_pos + Vector2(-draw_size.x * (0.22 + puff_t * 0.28) + sin(smoke_phase + puff_t * 4.7) * draw_size.x * 0.06, draw_size.y * (0.14 + puff_t * 0.20))
					var puff_radius := draw_size.y * lerpf(0.07, 0.16, puff_t)
					var puff_alpha := (0.24 - puff_t * 0.12) * (0.65 + near * 0.35)
					draw_circle(puff_pos, puff_radius * 1.35, Color(0.03, 0.025, 0.024, puff_alpha))
					draw_circle(puff_pos + Vector2(0.0, -puff_radius * 0.25), puff_radius * 0.54, Color(1.0, 0.35, 0.08, puff_alpha * 0.34))
			var tint := Color(1.0, 0.78, 0.50, 1.0) if float(enemy.get("hit_flash", 0.0)) > 0.0 else Color(1.0, 1.0, 1.0, 0.96)
			draw_texture_rect(enemy_texture, Rect2(enemy_pos - draw_size * 0.5, draw_size), false, tint)
			var hit_flash := float(enemy.get("hit_flash", 0.0))
			if hit_flash > 0.0:
				var spark_phase := float(Time.get_ticks_msec()) * 0.018 + float(enemy.get("wave_phase", 0.0))
				var spark_alpha := clampf(hit_flash / 0.14, 0.0, 1.0)
				for spark in range(9):
					var angle := spark_phase + float(spark) / 9.0 * TAU
					var spark_from := enemy_pos + Vector2(cos(angle), sin(angle)) * draw_size.y * 0.10
					var spark_to := enemy_pos + Vector2(cos(angle), sin(angle)) * draw_size.y * (0.22 + near * 0.10)
					draw_line(spark_from, spark_to, Color(1.0, 0.78, 0.22, 0.82 * spark_alpha), maxf(1.0, 2.0 * enemy_scale), true)
				draw_circle(enemy_pos, draw_size.y * 0.28, Color(1.0, 0.48, 0.10, 0.18 * spark_alpha))
			var hp := int(enemy.get("hp", 1))
			var max_hp := maxi(int(enemy.get("max_hp", hp)), 1)
			if max_hp > 1 and hp > 0:
				var bar_w := draw_size.x * 0.54
				var bar_pos := enemy_pos + Vector2(-bar_w * 0.5, -draw_size.y * 0.58)
				draw_rect(Rect2(bar_pos, Vector2(bar_w, maxf(3.0, 7.0 * enemy_scale))), Color(0.04, 0.02, 0.01, 0.70), true)
				draw_rect(Rect2(bar_pos + Vector2(1.0, 1.0), Vector2((bar_w - 2.0) * clampf(float(hp) / float(max_hp), 0.0, 1.0), maxf(1.5, 5.0 * enemy_scale))), Color(0.95, 0.18, 0.08, 0.86), true)
		for bullet in mode.harrier_enemy_bullets:
			var projected_bullet: Dictionary = mode._project_harrier(float(bullet.get("lane_x", 0.0)), float(bullet.get("lane_y", 0.0)), float(bullet.get("z_depth", 1000.0)))
			if not bool(projected_bullet.get("visible", false)):
				continue
			var bullet_pos := Vector2(float(projected_bullet.get("x", 0.0)), float(projected_bullet.get("y", 0.0)))
			var bullet_scale := float(projected_bullet.get("scale", 0.2))
			var prev_projected: Dictionary = mode._project_harrier(float(bullet.get("prev_lane_x", bullet.get("lane_x", 0.0))), float(bullet.get("prev_lane_y", bullet.get("lane_y", 0.0))), float(bullet.get("prev_z_depth", bullet.get("z_depth", 1000.0))) + 150.0)
			var trail_from := bullet_pos
			if bool(prev_projected.get("visible", false)):
				trail_from = Vector2(float(prev_projected.get("x", bullet_pos.x)), float(prev_projected.get("y", bullet_pos.y)))
			var near := float(projected_bullet.get("near", 0.0))
			var radius := maxf(4.0, lerpf(8.0, 34.0, near) * maxf(bullet_scale, 0.18))
			var travel_vec := bullet_pos - trail_from
			var travel_dir := travel_vec.normalized() if travel_vec.length() > 0.1 else Vector2(0.0, 1.0)
			var tail := minf(travel_vec.length() * 0.34, radius * 2.4)
			var tail_center := bullet_pos - travel_dir * tail
			var tail_side := Vector2(-travel_dir.y, travel_dir.x) * radius * 0.42
			draw_colored_polygon(PackedVector2Array([
				bullet_pos + tail_side * 0.42,
				tail_center + tail_side,
				tail_center - tail_side,
				bullet_pos - tail_side * 0.42
			]), Color(1.0, 0.42, 0.08, 0.20 + near * 0.20))
			draw_circle(bullet_pos, radius * 1.45, Color(1.0, 0.20, 0.04, 0.14 + near * 0.24))
			draw_circle(bullet_pos, radius * 0.84, Color(1.0, 0.42, 0.08, 0.80))
			draw_circle(bullet_pos, radius * 0.36, Color(1.0, 0.96, 0.46, 0.98))
			draw_arc(bullet_pos, radius * (1.55 + near * 0.55), 0.0, TAU, 28, Color(1.0, 0.72, 0.16, 0.16 + near * 0.18), maxf(1.0, radius * 0.10), true)
		_draw_coin_chains()
		_draw_coin_collect_fx()
		for pickup in mode.active_pickups:
			var projected_pickup: Dictionary = mode.renderer.project(float(pickup.get("z", 0.0)), float(pickup.get("lane", 0.0)))
			if not bool(projected_pickup.get("visible", false)):
				continue
			var texture := mode._winding_pickup_texture(str(pickup.get("kind", "rapid"))) as Texture2D
			if texture == null:
				continue
			var phase := float(pickup.get("phase", 0.0)) + Time.get_ticks_msec() * 0.006
			var scale_pickup := clampf(float(projected_pickup.get("scale", 1.0)) * 1.08, 0.20, 0.82)
			var ground_pickup := Vector2(float(projected_pickup.get("x", 0.0)), float(projected_pickup.get("y", 0.0)))
			var pos_pickup := ground_pickup + Vector2(0.0, float(pickup.get("flight_y", 0.0)) + sin(phase) * 7.0)
			var draw_height := 62.0 * scale_pickup
			var tex_size := Vector2(float(texture.get_width()), float(texture.get_height()))
			var draw_size := tex_size * (draw_height / maxf(tex_size.y, 1.0))
			draw_set_transform(ground_pickup + Vector2(0.0, draw_size.y * 0.32), 0.0, Vector2(1.9, 0.42))
			draw_circle(Vector2.ZERO, draw_size.y * 0.22, Color(0.0, 0.0, 0.0, 0.22))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			draw_circle(pos_pickup, draw_size.y * 0.46, Color(0.26, 0.78, 1.0, 0.12 + sin(phase * 1.4) * 0.04))
			draw_texture_rect(texture, Rect2(pos_pickup - draw_size * 0.5, draw_size), false, Color(1.0, 1.0, 1.0, 0.97))
		for shot in mode.player_shots:
			_draw_player_depth_shot(shot)
		for shot in mode.enemy_shots:
			var projected: Dictionary = mode.renderer.project(float(shot.get("z", 0.0)), float(shot.get("lane", 0.0)))
			if not bool(projected.get("visible", false)):
				continue
			var pos := Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)) + float(shot.get("flight_y", 0.0)))
			var scale := float(projected.get("scale", 1.0))
			draw_circle(pos, maxf(4.0, 11.0 * scale), Color(1.0, 0.22, 0.10, 0.96))
			draw_circle(pos, maxf(2.0, 5.0 * scale), Color(1.0, 0.82, 0.36, 0.92))
		for boom in mode.explosions:
			var projected: Dictionary = mode.renderer.project(float(boom.get("z", 0.0)), float(boom.get("lane", 0.0)))
			if not bool(projected.get("visible", false)):
				continue
			var life_ratio := clampf(float(boom.get("life", 0.0)) / maxf(float(boom.get("max_life", 0.42)), 0.01), 0.0, 1.0)
			var pos := Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)) + float(boom.get("flight_y", 0.0)))
			var radius := lerpf(54.0, 12.0, life_ratio) * maxf(float(projected.get("scale", 1.0)), 0.18)
			draw_circle(pos, radius * 1.2, Color(1.0, 0.16, 0.05, 0.28 * life_ratio))
			draw_circle(pos, radius * 0.74, Color(1.0, 0.52, 0.08, 0.58 * life_ratio))
			draw_circle(pos, radius * 0.36, Color(1.0, 0.92, 0.42, 0.80 * life_ratio))
		var font := ThemeDB.fallback_font
		if font == null:
			return
		for pop in mode.hit_pops:
			var projected: Dictionary = mode.renderer.project(float(pop.get("z", 0.0)), float(pop.get("lane", 0.0)))
			if not bool(projected.get("visible", false)):
				continue
			var life := clampf(float(pop.get("life", 0.0)) / 0.38, 0.0, 1.0)
			var pos := Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)) + float(pop.get("flight_y", 0.0)) - float(pop.get("rise", 0.0)))
			var color := Color(1.0, 0.86, 0.25, life)
			draw_string(font, pos + Vector2(-30.0, -36.0), str(pop.get("text", "HIT")), HORIZONTAL_ALIGNMENT_CENTER, 60.0, 16, color)

	func _draw_coin_chains() -> void:
		var texture := mode._winding_coin_texture() as Texture2D
		if texture == null:
			return
		for chain in mode.active_coin_chains:
			var coins: Array = chain.get("coins", [])
			for coin_value in coins:
				var coin := coin_value as Dictionary
				if bool(coin.get("collected", false)) or bool(coin.get("missed", false)):
					continue
				var projected_coin: Dictionary = mode.renderer.project(float(coin.get("z", 0.0)), float(coin.get("lane", 0.0)))
				if not bool(projected_coin.get("visible", false)):
					continue
				var phase := float(coin.get("phase", 0.0)) + Time.get_ticks_msec() * 0.006
				var near := float(projected_coin.get("near", 0.0))
				var scale_coin := clampf(float(projected_coin.get("scale", 1.0)) * 0.88, 0.16, 0.72)
				var ground := Vector2(float(projected_coin.get("x", 0.0)), float(projected_coin.get("y", 0.0)))
				var pos := ground + Vector2(0.0, float(coin.get("flight_y", 0.0)) + sin(phase) * 5.0)
				var tex_size := Vector2(float(texture.get_width()), float(texture.get_height()))
				var draw_height := lerpf(24.0, 58.0, near) * scale_coin
				var draw_size := tex_size * (draw_height / maxf(tex_size.y, 1.0))
				if near > 0.30:
					draw_set_transform(ground + Vector2(0.0, draw_size.y * 0.30), 0.0, Vector2(1.7, 0.32))
					draw_circle(Vector2.ZERO, draw_size.y * 0.20, Color(0.0, 0.0, 0.0, 0.17))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
					draw_circle(pos, draw_size.y * 0.48, Color(1.0, 0.72, 0.16, 0.08))
				draw_texture_rect(texture, Rect2(pos - draw_size * 0.5, draw_size), false, Color(1.0, 1.0, 1.0, 0.98))

	func _draw_coin_collect_fx() -> void:
		var font := ThemeDB.fallback_font
		for fx in mode.coin_collect_fx:
			var projected_fx: Dictionary = mode.renderer.project(float(fx.get("z", 0.0)), float(fx.get("lane", 0.0)))
			if not bool(projected_fx.get("visible", false)):
				continue
			var max_life := maxf(float(fx.get("max_life", 0.52)), 0.01)
			var life_ratio := clampf(float(fx.get("life", 0.0)) / max_life, 0.0, 1.0)
			var age := 1.0 - life_ratio
			var near := float(projected_fx.get("near", 0.0))
			var scale_fx := clampf(float(projected_fx.get("scale", 1.0)), 0.18, 0.86)
			var pos := Vector2(float(projected_fx.get("x", 0.0)), float(projected_fx.get("y", 0.0)) + float(fx.get("flight_y", 0.0)))
			var radius := lerpf(10.0, 48.0, age) * scale_fx * (0.75 + near * 0.45)
			var alpha := life_ratio
			draw_arc(pos, radius, 0.0, TAU, 32, Color(1.0, 0.84, 0.18, 0.86 * alpha), maxf(1.0, 3.0 * scale_fx), true)
			draw_arc(pos, radius * 1.28, -PI * 0.2, PI * 1.2, 20, Color(1.0, 0.98, 0.58, 0.44 * alpha), maxf(1.0, 1.6 * scale_fx), true)
			var phase := float(fx.get("phase", 0.0)) + float(Time.get_ticks_msec()) * 0.012
			for spark in range(8):
				var angle := phase + float(spark) / 8.0 * TAU
				var spark_pos := pos + Vector2(cos(angle), sin(angle)) * radius * 0.78
				draw_circle(spark_pos, maxf(1.5, 3.2 * scale_fx * life_ratio), Color(1.0, 0.92, 0.24, 0.86 * alpha))
			if font != null and int(fx.get("combo", 1)) > 1:
				draw_string(font, pos + Vector2(-28.0, -radius - 8.0), "x%d" % int(fx.get("combo", 1)), HORIZONTAL_ALIGNMENT_CENTER, 56.0, 14, Color(1.0, 0.92, 0.36, alpha))

	func _draw_player_depth_shot(shot: Dictionary) -> void:
		var projected: Dictionary = mode.renderer.project(float(shot.get("z", 0.0)), float(shot.get("lane", 0.0)))
		if not bool(projected.get("visible", false)):
			return
		var weapon := str(shot.get("weapon", "rifle"))
		var near := float(projected.get("near", 0.0))
		var scale := maxf(float(projected.get("scale", 1.0)), 0.18)
		var visual_flight_y := float(shot.get("flight_y", 0.0)) * (0.24 + near * 0.76)
		var pos := Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)) + visual_flight_y)
		var radius := maxf(1.8, float(shot.get("draw_radius", 3.4)) * (0.45 + near * 0.95) * scale)
		var phase := float(shot.get("phase", 0.0)) + float(Time.get_ticks_msec()) * 0.008
		var core := Color(0.88, 0.98, 1.0, 0.98)
		var glow := Color(0.20, 0.86, 1.0, 0.28)
		var rim := Color(1.0, 1.0, 1.0, 0.92)
		match weapon:
			"spread":
				core = Color(1.0, 0.92, 0.50, 0.98)
				glow = Color(1.0, 0.48, 0.12, 0.25)
				rim = Color(1.0, 0.98, 0.72, 0.94)
			"rocket":
				core = Color(1.0, 0.66, 0.18, 0.98)
				glow = Color(1.0, 0.18, 0.05, 0.34)
				rim = Color(1.0, 0.88, 0.36, 0.98)
			"machine":
				core = Color(0.92, 1.0, 0.74, 0.98)
				glow = Color(0.34, 1.0, 0.22, 0.22)
				rim = Color(0.94, 1.0, 0.80, 0.94)
			"laser":
				core = Color(0.72, 1.0, 1.0, 0.98)
				glow = Color(0.10, 0.64, 1.0, 0.38)
				rim = Color(0.88, 1.0, 1.0, 0.96)
			"fireball":
				core = Color(1.0, 0.74, 0.22, 0.98)
				glow = Color(1.0, 0.12, 0.02, 0.36)
				rim = Color(1.0, 0.92, 0.44, 0.96)
			"rapid":
				core = Color(0.70, 0.98, 1.0, 0.98)
				glow = Color(0.14, 0.78, 1.0, 0.28)
				rim = Color(0.86, 1.0, 1.0, 0.94)
		var muzzle = mode.player.position + Vector2(0.0, -18.0)
		var travel_vec = pos - muzzle
		var travel_dir = travel_vec.normalized() if travel_vec.length() > 0.1 else Vector2(0.0, -1.0)
		var trail_pos = pos - travel_dir * maxf(18.0, radius * 4.2)
		var side := Vector2(-travel_dir.y, travel_dir.x)
		if weapon == "rocket":
			for puff in range(3):
				var t := (float(puff) + 1.0) / 4.0
				var smoke_pos := pos.lerp(trail_pos, t) + side * sin(phase + float(puff)) * radius * 0.45
				draw_circle(smoke_pos, radius * (1.25 - t * 0.28), Color(0.14, 0.12, 0.13, 0.20 * (1.0 - t)))
				draw_circle(smoke_pos + Vector2(0.0, -radius * 0.18), radius * 0.62, Color(1.0, 0.42, 0.10, 0.18 * (1.0 - t)))
			draw_circle(pos, radius * 2.15, glow)
			draw_circle(pos, radius * 1.15, Color(0.12, 0.10, 0.08, 0.88))
			draw_circle(pos, radius * 0.62, core)
			return
		if weapon == "laser":
			# Keep winding-road shots pellet-like. Long beams look like they are sliding up the screen.
			var nose = pos + travel_dir * radius * 0.92
			var tail = pos - travel_dir * radius * 0.92
			draw_colored_polygon(PackedVector2Array([
				nose,
				pos + side * radius * 0.62,
				tail,
				pos - side * radius * 0.62
			]), glow)
			draw_colored_polygon(PackedVector2Array([
				nose - travel_dir * radius * 0.24,
				pos + side * radius * 0.28,
				tail + travel_dir * radius * 0.24,
				pos - side * radius * 0.28
			]), core)
			draw_circle(pos, radius * 0.42, rim)
			return
		if weapon == "fireball":
			draw_circle(pos, radius * 2.0, glow)
			draw_circle(pos + Vector2(sin(phase) * radius * 0.28, cos(phase * 1.3) * radius * 0.20), radius * 1.05, Color(1.0, 0.28, 0.03, 0.76))
			draw_circle(pos, radius * 0.55, Color(1.0, 0.95, 0.48, 0.96))
			return
		var speed_flatten := clampf(near, 0.0, 1.0)
		var pellet_r := radius * (0.78 if weapon in ["rapid", "machine"] else 0.92)
		var pellet_front = pos + travel_dir * pellet_r * 0.34
		draw_circle(pos, pellet_r * 1.55, Color(glow.r, glow.g, glow.b, glow.a * (0.72 + speed_flatten * 0.18)))
		draw_circle(pos, pellet_r * 0.92, Color(core.r * 0.68, core.g * 0.68, core.b * 0.68, 0.94))
		draw_circle(pellet_front, pellet_r * 0.64, core)
		draw_circle(pellet_front - side * pellet_r * 0.18, pellet_r * 0.24, rim)

	func _draw_player_skid_marks() -> void:
		if mode.player == null or not is_instance_valid(mode.player):
			return
		for mark in mode.player.skid_marks:
			var local_pos := mark.get("local_pos", Vector2.ZERO) as Vector2
			var life := clampf(float(mark.get("life", 0.0)) / 0.62, 0.0, 1.0)
			var age := float(mark.get("age", 0.0))
			var length := float(mark.get("length", 40.0))
			var width := float(mark.get("width", 3.0))
			var start = mode.player.position + local_pos + Vector2(0.0, age * 96.0)
			var finish = start + Vector2(0.0, length)
			draw_line(start + Vector2(1.5, 1.5), finish + Vector2(1.5, 1.5), Color(0.0, 0.0, 0.0, 0.16 * life), width + 2.0, true)
			draw_line(start, finish, Color(0.02, 0.018, 0.015, 0.58 * life), width, true)
			if age < 0.22:
				var smoke_alpha := (1.0 - age / 0.22) * 0.22
				draw_circle(start + Vector2(sin(age * 38.0) * 8.0, -8.0), width * 3.2, Color(0.06, 0.055, 0.05, smoke_alpha))


class WindingKaraokeOverlay:
	extends Node2D

	var mode: Node

	func _process(_delta: float) -> void:
		if visible:
			queue_redraw()

	func _draw() -> void:
		if mode == null or mode.renderer == null:
			return
		if mode.ship_view_panel != null and mode.ship_view_panel.visible:
			return
		var screen: Vector2 = mode.renderer.screen_size
		var song_time := float(mode._select_music_time())
		var lyric_time := float(mode._select_lyric_time())
		var lyric_index := int(mode._select_lyric_index(lyric_time))
		var progress := float(mode._select_lyric_progress(lyric_index, lyric_time))
		var beat := float(mode._select_beat_pulse(song_time))
		var speaker := str(mode.WINDING_SELECT_LYRICS[lyric_index].get("speaker", "d"))
		var singer_color = mode._select_singer_color(speaker, 1.0)
		_draw_beat_borders(beat, song_time, singer_color)
		_draw_karaoke_strip(screen, lyric_index, progress, beat, song_time)

	func _draw_beat_borders(beat: float, song_time: float, singer_color: Color) -> void:
		var panels: Array = []
		if mode.rider_select_panel != null and mode.rider_select_panel.visible:
			panels.append(mode.rider_select_panel)
		if mode.ship_view_panel != null and mode.ship_view_panel.visible:
			panels.append(mode.ship_view_panel)
		for panel in panels:
			var rect := Rect2(panel.position, panel.custom_minimum_size)
			var pad := 4.0 + beat * 5.0
			var outer := Rect2(rect.position - Vector2(pad, pad), rect.size + Vector2(pad * 2.0, pad * 2.0))
			var glow := Color(singer_color.r, singer_color.g, singer_color.b, 0.12 + beat * 0.26)
			var gold := Color(1.0, 0.66, 0.22, 0.20 + beat * 0.24)
			draw_rect(outer, glow, false, 1.4 + beat * 2.0)
			var corner := 54.0 + beat * 18.0
			var width := 2.0 + beat * 3.2
			_draw_corner_accent(outer.position, Vector2(1.0, 1.0), corner, width, singer_color)
			_draw_corner_accent(outer.position + Vector2(outer.size.x, 0.0), Vector2(-1.0, 1.0), corner, width, gold)
			_draw_corner_accent(outer.position + Vector2(0.0, outer.size.y), Vector2(1.0, -1.0), corner, width, gold)
			_draw_corner_accent(outer.position + outer.size, Vector2(-1.0, -1.0), corner, width, singer_color)
			if beat > 0.35:
				draw_rect(Rect2(outer.position + Vector2(10.0, outer.size.y - 4.0), Vector2((outer.size.x - 20.0) * beat, 3.0)), gold, true)

	func _draw_corner_accent(origin: Vector2, dir: Vector2, length: float, width: float, color: Color) -> void:
		draw_line(origin, origin + Vector2(dir.x * length, 0.0), color, width, true)
		draw_line(origin, origin + Vector2(0.0, dir.y * length), color, width, true)

	func _draw_karaoke_strip(screen: Vector2, lyric_index: int, progress: float, beat: float, song_time: float) -> void:
		var font := ThemeDB.fallback_font
		if font == null:
			return
		var compact = mode.rider_select_panel != null and mode.rider_select_panel.visible
		var strip_h := 76.0 if compact else 122.0
		var strip := Rect2(Vector2(170.0, 12.0), Vector2(screen.x - 340.0, strip_h)) if compact else Rect2(Vector2(38.0, screen.y - strip_h - 24.0), Vector2(screen.x - 76.0, strip_h))
		var pulse := 0.5 + sin(song_time * 8.0) * 0.5
		var current: Dictionary = mode.WINDING_SELECT_LYRICS[lyric_index]
		var speaker := str(current.get("speaker", "d"))
		var speaker_color = mode._select_singer_color(speaker, 1.0)
		draw_rect(strip, Color(0.015, 0.018, 0.030, 0.70), true)
		draw_rect(strip, Color(speaker_color.r, speaker_color.g, speaker_color.b, 0.22 + beat * 0.20), false, 2.0 + beat * 2.6)
		draw_rect(Rect2(strip.position + Vector2(0.0, strip.size.y - 5.0), Vector2(strip.size.x * progress, 5.0)), Color(1.0, 0.66, 0.12, 0.78), true)
		var sparkle_count := 9 if compact else 14
		for i in range(sparkle_count):
			var x := strip.position.x + fmod(song_time * (70.0 if compact else 110.0) + float(i) * 73.0, strip.size.x)
			var y := strip.position.y + 10.0 + fmod(float(i) * 23.0 + sin(song_time + float(i)) * 10.0, strip.size.y - 20.0)
			draw_circle(Vector2(x, y), 1.2 + pulse * 1.4, Color(speaker_color.r, speaker_color.g, speaker_color.b, 0.08 + beat * 0.08))
		var speaker_name := "DUET"
		if speaker == "f":
			speaker_name = "FEMALE"
		elif speaker == "m":
			speaker_name = "MALE"
		var active_text := str(current.get("text", ""))
		var prev_text := ""
		var next_text := ""
		if lyric_index > 0:
			prev_text = str(mode.WINDING_SELECT_LYRICS[lyric_index - 1].get("text", ""))
		if lyric_index + 1 < mode.WINDING_SELECT_LYRICS.size():
			next_text = str(mode.WINDING_SELECT_LYRICS[lyric_index + 1].get("text", ""))

		draw_string(font, strip.position + Vector2(18.0, 23.0), "HOSHIZORA WO KOETE  //  %s" % speaker_name, HORIZONTAL_ALIGNMENT_LEFT, strip.size.x - 36.0, 13 if compact else 14, Color(speaker_color.r, speaker_color.g, speaker_color.b, 0.86))
		if not compact and not prev_text.is_empty():
			draw_string(font, strip.position + Vector2(22.0, 54.0), prev_text, HORIZONTAL_ALIGNMENT_LEFT, strip.size.x - 44.0, 15, Color(0.78, 0.82, 0.90, 0.42))
		var active_y := strip.position.y + (54.0 if compact else 82.0)
		var text_w := strip.size.x - 44.0
		var active_size := 19 if compact else 25
		var highlight_y := 38.0 if compact else 61.0
		var highlight_h := 24.0 if compact else 33.0
		draw_rect(Rect2(strip.position + Vector2(20.0, highlight_y), Vector2((strip.size.x - 40.0) * progress, highlight_h)), Color(speaker_color.r, speaker_color.g, speaker_color.b, 0.16 + beat * 0.12), true)
		draw_string(font, strip.position + Vector2(24.0 + beat * 2.0, active_y + 2.0), active_text, HORIZONTAL_ALIGNMENT_CENTER, text_w, active_size, Color(0.0, 0.0, 0.0, 0.60))
		draw_string(font, Vector2(strip.position.x + 22.0, active_y), active_text, HORIZONTAL_ALIGNMENT_CENTER, text_w, active_size, Color(1.0, 0.96, 0.82, 0.96))
		draw_string(font, Vector2(strip.position.x + 22.0, active_y), active_text, HORIZONTAL_ALIGNMENT_CENTER, text_w * progress, active_size, speaker_color)
		if not compact and not next_text.is_empty():
			draw_string(font, strip.position + Vector2(22.0, 113.0), next_text, HORIZONTAL_ALIGNMENT_CENTER, strip.size.x - 44.0, 14, Color(0.78, 0.82, 0.90, 0.38))


class ShipSpinPreview:
	extends Control

	var texture: Texture2D
	var ship_name := ""
	var yaw := 0.0
	var pitch := 0.0
	var zoom := 1.0
	var _dragging := false
	var _auto_turn := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		set_process(true)

	func _process(delta: float) -> void:
		if not _dragging:
			_auto_turn += delta * 0.62
			yaw = lerpf(yaw, sin(_auto_turn) * 0.34, delta * 0.82)
			pitch = lerpf(pitch, sin(_auto_turn * 0.58) * 0.08, delta * 0.55)
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				_dragging = mouse_event.pressed
			elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom = clampf(zoom + 0.08, 0.72, 1.35)
				queue_redraw()
			elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom = clampf(zoom - 0.08, 0.72, 1.35)
				queue_redraw()
		elif event is InputEventMouseMotion and _dragging:
			var motion := event as InputEventMouseMotion
			yaw += motion.relative.x * 0.015
			pitch = clampf(pitch + motion.relative.y * 0.007, -0.42, 0.42)
			queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, Color(0.015, 0.026, 0.035, 0.88), true)
		var center := size * 0.5 + Vector2(0.0, 16.0)
		var t := Time.get_ticks_msec() * 0.001
		var yaw_sin := sin(yaw)
		var yaw_cos := cos(yaw)
		for ring in range(4):
			var radius := 120.0 + float(ring) * 58.0 + sin(t * 1.2 + float(ring)) * 5.0
			draw_arc(center, radius, 0.0, TAU, 96, Color(0.18, 0.80, 1.0, 0.08), 2.0, true)
		draw_line(Vector2(42.0, center.y), Vector2(size.x - 42.0, center.y), Color(0.36, 0.76, 1.0, 0.12), 2.0, true)
		draw_line(Vector2(center.x, 50.0), Vector2(center.x, size.y - 54.0), Color(0.36, 0.76, 1.0, 0.08), 2.0, true)
		var platform_center := center + Vector2(0.0, 142.0)
		draw_set_transform(platform_center, 0.0, Vector2(1.85, 0.34))
		draw_circle(Vector2.ZERO, 112.0, Color(0.0, 0.0, 0.0, 0.36))
		draw_arc(Vector2.ZERO, 126.0, 0.0, TAU, 96, Color(0.16, 0.88, 1.0, 0.20), 5.0, true)
		draw_arc(Vector2.ZERO, 82.0, -yaw, PI - yaw, 64, Color(1.0, 0.58, 0.16, 0.30), 4.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if texture != null:
			var tex_size := texture.get_size()
			var fit_scale := minf(size.x * 0.78 / maxf(tex_size.x, 1.0), size.y * 0.62 / maxf(tex_size.y, 1.0)) * zoom
			var side_squash := clampf(0.50 + absf(yaw_cos) * 0.50, 0.36, 1.0)
			var bob := sin(t * 2.0) * 6.0
			var ship_center := center + Vector2(yaw_sin * 80.0, pitch * 86.0 + bob)
			var draw_size := Vector2(tex_size.x * fit_scale * side_squash, tex_size.y * fit_scale * (1.0 - absf(pitch) * 0.16))
			var lean := yaw_sin * 0.10 + pitch * 0.08
			var shadow_size := Vector2(draw_size.x * 0.62, draw_size.y * 0.18)
			draw_set_transform(platform_center + Vector2(yaw_sin * 34.0, 4.0), lean * 0.25, Vector2(1.0, 0.46))
			draw_circle(Vector2.ZERO, maxf(shadow_size.x, shadow_size.y) * 0.44, Color(0.0, 0.0, 0.0, 0.42))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			for glow_index in range(3):
				var glow_size := draw_size * (1.0 + float(glow_index) * 0.045)
				var glow_pos := ship_center - glow_size * 0.5
				draw_set_transform(ship_center, lean, Vector2.ONE)
				draw_texture_rect(texture, Rect2(-glow_size * 0.5, glow_size), false, Color(0.12, 0.70, 1.0, 0.06))
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			draw_set_transform(ship_center + Vector2(10.0, 16.0), lean, Vector2.ONE)
			draw_texture_rect(texture, Rect2(-draw_size * 0.5, draw_size), false, Color(0.0, 0.0, 0.0, 0.26))
			draw_set_transform(ship_center, lean, Vector2.ONE)
			var front_light := Color(1.0, 1.0, 1.0, 0.98)
			var side_dim := clampf(0.72 + absf(yaw_cos) * 0.28, 0.72, 1.0)
			draw_texture_rect(texture, Rect2(-draw_size * 0.5, draw_size), false, Color(front_light.r * side_dim, front_light.g * side_dim, front_light.b * side_dim, front_light.a))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			var nose_offset := Vector2(yaw_sin * draw_size.x * 0.25, pitch * draw_size.y * 0.12)
			draw_circle(ship_center + nose_offset, 10.0 + absf(yaw_sin) * 7.0, Color(0.42, 0.88, 1.0, 0.18))
			draw_arc(ship_center, maxf(draw_size.x, draw_size.y) * 0.56, -0.5 + yaw, 0.5 + yaw, 42, Color(0.42, 0.92, 1.0, 0.22), 5.0, true)
			draw_arc(ship_center, maxf(draw_size.x, draw_size.y) * 0.62, PI - 0.4 + yaw, PI + 0.4 + yaw, 42, Color(1.0, 0.58, 0.16, 0.18), 4.0, true)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(24.0, 34.0), str(ship_name).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, size.x - 48.0, 20, Color(0.92, 0.96, 1.0, 0.94))
		draw_string(font, Vector2(24.0, size.y - 30.0), "INSPECTION TURN: %.0f  ZOOM: %.0fx" % [rad_to_deg(yaw), zoom], HORIZONTAL_ALIGNMENT_LEFT, size.x - 48.0, 14, Color(0.55, 0.88, 1.0, 0.72))


class HoveringRiderPreview:
	extends TextureRect

	var phase_offset := 0.0
	var _base_position := Vector2.ZERO
	var _ready_to_hover := false

	func _ready() -> void:
		_base_position = position
		_ready_to_hover = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		pivot_offset = size * 0.5

	func _process(delta: float) -> void:
		if not _ready_to_hover:
			_base_position = position
			_ready_to_hover = true
		var t := Time.get_ticks_msec() * 0.001 + phase_offset
		position = _base_position + Vector2(0.0, sin(t * 2.2) * 8.0)
		rotation_degrees = sin(t * 1.6) * 1.6
		modulate = Color(1.0, 1.0, 1.0, 0.94 + sin(t * 3.0) * 0.06)


class WindingSelectFxOverlay:
	extends Node2D

	var mode: Node

	func _process(_delta: float) -> void:
		if visible:
			queue_redraw()

	func _draw() -> void:
		if mode == null or mode.renderer == null:
			return
		var screen: Vector2 = mode.renderer.screen_size
		var t := Time.get_ticks_msec() * 0.001
		draw_rect(Rect2(Vector2.ZERO, screen), Color(0.02, 0.04, 0.08, 0.18), true)
		for index in range(10):
			var y := fmod(t * 80.0 + float(index) * 74.0, screen.y + 80.0) - 40.0
			var alpha := 0.035 + sin(t * 2.0 + float(index)) * 0.015
			draw_line(Vector2(0.0, y), Vector2(screen.x, y + 18.0), Color(0.20, 0.82, 1.0, alpha), 2.0, true)
		var beat := 0.5 + sin(t * 5.6) * 0.5
		var ring_center := Vector2(screen.x * 0.5, screen.y * 0.48)
		draw_arc(ring_center, 210.0 + beat * 28.0, 0.0, TAU, 96, Color(1.0, 0.42, 0.16, 0.10 + beat * 0.08), 5.0, true)
		draw_arc(ring_center, 300.0 + beat * 42.0, 0.0, TAU, 96, Color(0.22, 0.88, 1.0, 0.07 + beat * 0.05), 3.0, true)
