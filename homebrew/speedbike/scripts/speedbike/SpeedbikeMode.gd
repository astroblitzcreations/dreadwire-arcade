extends Node2D
class_name SpeedbikeMode

const SPEEDBIKE_STAGE_FILES := {
	"badlands_speedbike_01": "res://data/speedbike/speedbike_01_ignition_run.json",
	"badlands_speedbike_02": "res://data/speedbike/speedbike_02_white_knuckle_gates.json",
	"badlands_speedbike_03": "res://data/speedbike/speedbike_03_dropper_drone_alley.json",
	"badlands_speedbike_04": "res://data/speedbike/speedbike_04_blackout_tube.json",
	"badlands_speedbike_05": "res://data/speedbike/speedbike_05_pulse_grid.json",
	"badlands_speedbike_06": "res://data/speedbike/speedbike_06_minefield_rush.json",
	"badlands_speedbike_07": "res://data/speedbike/speedbike_07_split_shaft_switchback.json",
	"badlands_speedbike_08": "res://data/speedbike/speedbike_08_reverse_signal.json",
	"badlands_speedbike_09": "res://data/speedbike/speedbike_09_overdrive_no_brake.json",
	"badlands_speedbike_10": "res://data/speedbike/speedbike_10_voss_blaus_tunnel.json",
	"badlands_speedbike_11": "res://data/speedbike/speedbike_11_shatterline_reactor.json",
	"badlands_speedbike_12": "res://data/speedbike/speedbike_12_killswitch_narrows.json",
	"badlands_speedbike_13": "res://data/speedbike/speedbike_13_razorfall_relay.json",
	"badlands_speedbike_14": "res://data/speedbike/speedbike_14_headlight_grave.json",
	"badlands_speedbike_15": "res://data/speedbike/speedbike_15_burnwall_array.json",
	"badlands_speedbike_16": "res://data/speedbike/speedbike_16_crossfire_maw.json",
	"badlands_speedbike_17": "res://data/speedbike/speedbike_17_dead_rail_fracture.json",
	"badlands_speedbike_18": "res://data/speedbike/speedbike_18_signal_ruin.json",
	"badlands_speedbike_19": "res://data/speedbike/speedbike_19_zero_mercy_grid.json",
	"badlands_speedbike_20": "res://data/speedbike/speedbike_20_blaufall_escape.json",
	"badlands_speedbike_21": "res://data/speedbike/speedbike_21_curvebreak_causeway.json",
	"badlands_speedbike_22": "res://data/speedbike/speedbike_22_canyon_slalom.json",
	"badlands_speedbike_23": "res://data/speedbike/speedbike_23_sawtooth_overpass.json",
	"badlands_speedbike_24": "res://data/speedbike/speedbike_24_dustcoil_drop.json",
	"badlands_speedbike_25": "res://data/speedbike/speedbike_25_mirror_road.json",
	"badlands_speedbike_26": "res://data/speedbike/speedbike_26_railstorm_s_bend.json",
	"badlands_speedbike_27": "res://data/speedbike/speedbike_27_deadmans_switch.json",
	"badlands_speedbike_28": "res://data/speedbike/speedbike_28_afterburn_corkscrew.json",
	"badlands_speedbike_29": "res://data/speedbike/speedbike_29_blacktop_needle.json",
	"badlands_speedbike_30": "res://data/speedbike/speedbike_30_windscar_finale.json",
	"badlands_speedbike_31": "res://data/speedbike/speedbike_31_orbit_grave.json",
	"badlands_speedbike_32": "res://data/speedbike/speedbike_32_asteroid_keyhole.json",
	"badlands_speedbike_33": "res://data/speedbike/speedbike_33_satellite_skein.json",
	"badlands_speedbike_34": "res://data/speedbike/speedbike_34_nebula_razor.json",
	"badlands_speedbike_35": "res://data/speedbike/speedbike_35_comet_split.json",
	"badlands_speedbike_36": "res://data/speedbike/speedbike_36_void_mine_waltz.json",
	"badlands_speedbike_37": "res://data/speedbike/speedbike_37_gravity_lens.json",
	"badlands_speedbike_38": "res://data/speedbike/speedbike_38_starfall_chicane.json",
	"badlands_speedbike_39": "res://data/speedbike/speedbike_39_event_horizon_run.json",
	"badlands_speedbike_40": "res://data/speedbike/speedbike_40_beldars_last_tunnel.json"
}
const DEFAULT_STAGE_ID := "badlands_speedbike_01"
const MUSIC_FALLBACK_PATH := "res://assets/sounds/badlands_overdrive_ThunderlineDesert.ogg"
const MUSIC_PATHS := {
	"speedbike_desert": "res://assets/sounds/badlands_overdrive_ThunderlineDesert.ogg",
	"speedbike_scrap": "res://assets/sounds/badlands_overdrive_ScrapBounce.ogg",
	"speedbike_cavern": "res://assets/sounds/badlands_overdrive_CavernBreaker.ogg"
}
const STAGE_THEME_BACKGROUND_PATHS := {
	"badlands_ridge": "res://assets/sprites/Backgrounds/1/Day/3.png",
	"badlands_tunnel": "res://assets/sprites/Backgrounds/2/Day/3.png",
	"industrial_gates": "res://assets/sprites/Backgrounds/4/Day/5.png",
	"blackout_tube": "res://assets/sprites/Backgrounds/5/Night/2.png",
	"pulse_grid": "res://assets/sprites/Backgrounds/6/Night/3.png",
	"minefield_refinery": "res://assets/sprites/Backgrounds/7/Day/3.png",
	"split_shaft": "res://assets/sprites/Backgrounds/8/Day/2.png",
	"signal_tunnel": "res://assets/sprites/Backgrounds/5/Night/5.png",
	"overdrive_tunnel": "res://assets/sprites/Backgrounds/3/Day/5.png",
	"voss_tunnel": "res://assets/sprites/Backgrounds/8/Night/3.png"
}
const SHOT_SOUND_PATH := "res://assets/sounds/Ground_Rapid_Shot.wav"
const CRASH_SOUND_PATH := "res://assets/sounds/explosion.wav"
const WARNING_SOUND_PATH := "res://assets/sounds/warning_10s.wav"
const PICKUP_SOUND_PATH := "res://assets/sounds/Ground_Powerup_Pickup.wav"
const CARRIER_SOUND_PATH := "res://assets/sounds/Ground_Powerup_Spawn.wav"
const ENGINE_SOUND_PATH := "res://assets/sounds/badlands_rocket-loop.mp3"
const TYPEWRITER_SOUND_PATH := "res://assets/sounds/cutscene_typewriter_tick.wav"
const BOSS_INTRO_SOUND_PATH := "res://assets/sounds/speedbike_boss_intro.mp3"
const BOSS_LAUGH_SOUND_PATH := "res://assets/sounds/speedbike_boss_laugh.mp3"
const BOSS_MUSIC_PATHS := [
	"res://assets/sounds/speedbike_boss_music.mp3",
	"res://assets/sounds/speedbike_boss_music2.mp3",
	"res://assets/sounds/speedbike_boss_music3.mp3"
]
const BOSS_TEXTURE_PATH := "res://assets/sprites/speedbike/enemies/speedbike_boss_beldar.png"
const BOSS_MINION_TEXTURE_PATH := "res://assets/sprites/speedbike/enemies/speedbike_boss_minizorg.png"
const MERCHANT_SHIP_SHEET_PATH := "res://assets/sprites/speedbike/merchant/speedbike_merchant_sheet.png"
const MERCHANT_CAT_IDLE_PATH := "res://assets/sprites/speedbike/merchant/merchant_cats_idle.png"
const MERCHANT_CAT_REPAIR_PATH := "res://assets/sprites/speedbike/merchant/merchant_cats_repair.png"
const MERCHANT_CAT_FINISHED_PATH := "res://assets/sprites/speedbike/merchant/merchant_cats_finished.png"
const MERCHANT_REPAIR_SOUND_PATH := "res://assets/sounds/speedbike/repair_sound.wav"
const MERCHANT_LIFTOFF_SOUND_PATH := "res://assets/sounds/badlands_pod_liftoff.mp3"
const MERCHANT_TAKEOFF_SOUND_PATH := "res://assets/sounds/badlands_pod_takeoff.mp3"
const VIEW_TOP_PAD := 144.0
const VIEW_BOTTOM_PAD := 148.0
const LANE_COUNT := 5
const LANE_HALF_HEIGHT := 34.0
const PLAYER_START_X_OFFSET := 220.0
const PLAYER_BULLET_SPEED := 860.0
const ENEMY_BULLET_SPEED := 520.0
const DROPPER_WARNING_TEXT := "INCOMING BARRIER"
const CRASH_RESTART_DELAY := 0.75
const PICKUP_KINDS := ["shield", "slow_time", "repair", "health", "green", "blue", "purple", "gold", "extra_life", "rapid", "fireball", "laser", "machine", "spread", "rocket", "score_medal"]
const SPEEDBIKE_WEAPON_PICKUP_KINDS := ["rapid", "fireball", "laser", "machine", "spread", "rocket"]
const PICKUP_SCREEN_DRIFT_SPEED := 230.0
const COIN_SCREEN_DRIFT_SPEED := 214.0
const ENEMY_POWERUP_DROP_CHANCE := 0.30
const BOSS_MINION_POWERUP_DROP_CHANCE := 0.16
const GOLD_COIN_SCORE := 125
const BLUE_COIN_SCORE := 2500
const BLUE_COIN_TOTAL := 30
const BLUE_COINS_BEFORE_BOSS := 29
const GOLD_COIN_TEXTURE_PATH := "res://assets/sprites/speedbike/pickups/coin_gold.png"
const BLUE_COIN_TEXTURE_PATH := "res://assets/sprites/speedbike/pickups/coin_blue.png"
const SPEEDBIKE_WEAPON_PERSIST_TIME := 3600.0
const SPEEDBIKE_LIMITED_WEAPON_AMMO := {
	"spread": 44,
	"rocket": 14
}
const PICKUP_TEXTURE_PATHS := {
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
const ENEMY_BULLET_SCREEN_SPEED_MAX := 520.0
const ENEMY_BULLET_SCREEN_SPEED_MIN := 340.0
const CHECKPOINT_SPLASH_DURATION := 1.35
const SPAWN_WARNING_DISTANCE := 760.0
const STAGE_CHAIN_TRANSITION_DELAY := 0.18
const STAGE_CHAIN_SPEEDUP := 55.0
const STAGE_CHAIN_RESET_STAGES := [5, 15, 30]
const SPEEDBIKE_MIN_CHECKPOINT_INTERVAL := 18.0
const SPEEDBIKE_MAX_EVENT_CHECKPOINTS := 2
const RIDER_TYPEWRITER_CHARS_PER_SECOND := 18.0
const RIDER_TYPEWRITER_SOUND_STEP := 1
const RIDER_TYPEWRITER_SOUND_COOLDOWN := 0.04
const RIDER_TYPEWRITER_PLAYER_COUNT := 6
const MERCHANT_STOP_INTERVAL := 3
const MERCHANT_REPAIR_DURATION := 10.0
const MERCHANT_TYPEWRITER_CHARS_PER_SECOND := 34.0
const MERCHANT_BUY_QUANTITIES := [1, 3]
const SPEEDBIKE_MIN_HEALTH_HITS := 4
const MERCHANT_ITEM_CATALOG := [
	{"kind": "repair", "name": "Hull Patch", "cost": 4, "description": "Restores speedbike health. Repair bay takes ten seconds."},
	{"kind": "rapid", "name": "Rapid Coil", "cost": 4, "description": "Fast cannon rhythm for clearing drones and weak walls."},
	{"kind": "machine", "name": "Machine Feed", "cost": 5, "description": "Heavy bullet stream with steady forward damage."},
	{"kind": "laser", "name": "Laser Focuser", "cost": 6, "description": "Clean piercing shots for hard target windows."},
	{"kind": "spread", "name": "Scatter Pack", "cost": 7, "description": "Adds limited spread charges. Buy more to stack ammo."},
	{"kind": "rocket", "name": "Rocket Rack", "cost": 8, "description": "Adds limited rockets. Buy more to stack ammo."},
	{"kind": "shield", "name": "Crash Shield", "cost": 8, "description": "Adds one shield buffer before a bad impact."},
	{"kind": "purple", "name": "Overhaul Cell", "cost": 9, "description": "Adds a bonus health slot and repairs one point."}
]
const BOSS_DIALOG_CHARS_PER_SECOND := 32.0
const BOSS_MAX_HEALTH := 250
const BOSS_SHIELD_HEALTH := 90
const BOSS_CANNON_HEALTH := 75
const BOSS_DOME_HEALTH := 85
const BOSS_MINION_HEALTH := 16
const BOSS_TELEPORT_INTERVAL := 5.0
const BOSS_DOME_TELEPORT_INTERVAL := 3.0
const BOSS_ARENA_SCROLL_SPEED := 255.0
const BOSS_PORTAL_DURATION := 3.6
const BOSS_STAGE_ID := "badlands_speedbike_40"
const BOSS_DRAW_SCALE := 0.266
const BOSS_SCREEN_X_OFFSET := 150.0
const BOSS_CONTACT_HIT_INTERVAL := 0.55
const BOSS_LASER_CHARGE_DURATION := 1.55
const BOSS_LASER_SWEEP_DURATION := 2.35
const BOSS_LASER_COOLDOWN_MIN := 30.0
const BOSS_LASER_COOLDOWN_MAX := 180.0
const BOSS_LASER_WIDTH := 38.0
const BOSS_CHAIN_ATTACK_MIN_VOLLEYS := 5
const BOSS_CHAIN_ATTACK_MAX_VOLLEYS := 15
const BOSS_CHAIN_ATTACK_INTERVAL := 0.16
const BOSS_CHAIN_ATTACK_BULLETS := 8
const BOSS_CHAIN_ATTACK_SPEED := 520.0
const BOSS_EYE_CHARGE_STEP_DURATION := 2.0
const BOSS_EYE_CHARGE_TOTAL_DURATION := 6.0
const BOSS_EYE_BEAM_DURATION := 2.15
const BOSS_EYE_BEAM_WIDTH := 78.0
const BOSS_MINION_WAVE_COUNTS := [3, 5, 8]
const SPEEDBIKE_TOUCH_SETTINGS_PATH := "user://speedbike_touch.cfg"
const SPEEDBIKE_TOUCH_LAYOUT_VERSION := 3
const SPEEDBIKE_TOUCH_BUTTON_IDS := ["up", "down", "left", "right", "jump", "fire", "boost"]
const SPEEDBIKE_TOUCH_BUTTON_LABELS := {
	"up": "UP",
	"down": "DOWN",
	"left": "BACK",
	"right": "FWD",
	"jump": "JUMP",
	"fire": "ATTACK",
	"boost": "RUN"
}
const SPEEDBIKE_DIFFICULTY_DEFAULT := {
	"id": "veteran",
	"label": "Veteran",
	"speed_scale": 1.0,
	"warning_scale": 1.0,
	"hits": 2,
	"instant_crash": false
}
const RIDER_DEFS := {
	"female": {
		"label": "Engineer (Female)",
		"ride_path": "res://assets/sprites/speedbike/speedbike_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedbike_jump.png",
		"scale": 0.14,
		"vertical_mult": 1.0,
		"horizontal_mult": 1.0,
		"jump_height_add": 0.0,
		"jump_duration_mult": 1.0,
		"jump_cooldown_mult": 1.0,
		"shot_cooldown_mult": 1.0,
		"hurtbox_mult": 1.0,
		"armor_bonus_hits": 0,
		"stats": {"handle": 4, "jump": 3, "cannon": 3, "armor": 3},
		"description": "Balanced badlands rider with steady handling, clean jumps, and reliable all-round control."
	},
	"gunner": {
		"label": "Gunner",
		"ride_path": "res://assets/sprites/speedbike/speedbike_gunner_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedbike_gunner_jump.png",
		"scale": 0.155,
		"vertical_mult": 0.88,
		"horizontal_mult": 0.94,
		"jump_height_add": -4.0,
		"jump_duration_mult": 1.08,
		"jump_cooldown_mult": 1.04,
		"shot_cooldown_mult": 0.82,
		"hurtbox_mult": 1.05,
		"armor_bonus_hits": 1,
		"stats": {"handle": 2, "jump": 2, "cannon": 5, "armor": 4},
		"description": "Heavy cannon rider. Slower on sharp lane changes, but tougher in forgiving rules and faster on sustained fire."
	},
	"scout": {
		"label": "Scout",
		"ride_path": "res://assets/sprites/speedbike/speedbike_scout_ride.png",
		"jump_path": "res://assets/sprites/speedbike/speedbike_scout_jump.png",
		"scale": 0.145,
		"vertical_mult": 1.14,
		"horizontal_mult": 1.08,
		"jump_height_add": 10.0,
		"jump_duration_mult": 0.94,
		"jump_cooldown_mult": 0.92,
		"shot_cooldown_mult": 1.10,
		"hurtbox_mult": 0.88,
		"armor_bonus_hits": 0,
		"stats": {"handle": 5, "jump": 4, "cannon": 2, "armor": 2},
		"description": "Fastest lane changer with the lightest profile. Jumps cleaner than the others, but trades away cannon pace."
	}
}

@onready var speedbike_camera: Camera2D = $Camera2D
@onready var obstacle_layer: Node2D = $ObstacleLayer
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var pickup_layer: Node2D = $PickupLayer
@onready var player_speedbike = $PlayerSpeedbike
@onready var hud_layer: CanvasLayer = $HUD
@onready var speed_label: Label = $HUD/SpeedLabel
@onready var death_label: Label = $HUD/DeathCounter
@onready var progress_label: Label = $HUD/StageProgress
@onready var score_label: Label = $HUD/ScoreLabel
@onready var hit_label: Label = $HUD/HitLabel
@onready var boost_label: Label = $HUD/BoostLabel
@onready var boost_bar_back: ColorRect = $HUD/BoostBarBack
@onready var boost_bar_fill: ColorRect = $HUD/BoostBarFill
var speed_bar_back: ColorRect
var speed_bar_fill: ColorRect
var death_bar_back: ColorRect
var death_bar_fill: ColorRect
var score_bar_back: ColorRect
var score_bar_fill: ColorRect
var progress_bar_back: ColorRect
var progress_bar_fill: ColorRect
var health_bar_back: ColorRect
var health_bar_fill: ColorRect
@onready var warning_label: Label = $HUD/WarningText
@onready var tip_label: Label = $HUD/TipLabel
@onready var flash_rect: ColorRect = $HUD/FlashRect
@onready var character_select_shade: ColorRect = $HUD/CharacterSelectShade
@onready var character_select_panel: PanelContainer = $HUD/CharacterSelectPanel
@onready var character_female_button: Button = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/CharacterButtons/FemaleButton
@onready var character_gunner_button: Button = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/CharacterButtons/GunnerButton
@onready var character_scout_button: Button = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/CharacterButtons/ScoutButton
@onready var character_selected_name: Label = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/PreviewTopRow/PreviewInfoColumn/SelectedRiderName
@onready var character_selected_stats: RichTextLabel = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/PreviewTopRow/PreviewInfoColumn/SelectedRiderStats
@onready var character_preview_name: Label = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/PreviewName
@onready var character_preview_holder: Control = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/PreviewTopRow/PreviewImageHolder
@onready var character_preview_image: TextureRect = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/PreviewTopRow/PreviewImageHolder/PreviewImage
@onready var character_stats_scroll: ScrollContainer = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/StatsScroll
@onready var character_stats_label: RichTextLabel = $HUD/CharacterSelectPanel/SelectVBox/SelectBody/PreviewColumn/StatsScroll/StatsLabel
@onready var character_deploy_button: Button = $HUD/CharacterSelectPanel/SelectVBox/SelectButtons/DeployButton
@onready var character_return_button: Button = $HUD/CharacterSelectPanel/SelectVBox/SelectButtons/SelectWarRoomButton
@onready var pause_panel: PanelContainer = $HUD/PausePanel
@onready var pause_title: Label = $HUD/PausePanel/PauseVBox/PauseTitle
@onready var pause_resume_button: Button = $HUD/PausePanel/PauseVBox/ResumeButton
@onready var pause_restart_button: Button = $HUD/PausePanel/PauseVBox/RestartButton
@onready var pause_return_button: Button = $HUD/PausePanel/PauseVBox/WarRoomButton
@onready var result_panel: PanelContainer = $HUD/ResultPanel
@onready var result_title: Label = $HUD/ResultPanel/ResultVBox/ResultTitle
@onready var result_body: RichTextLabel = $HUD/ResultPanel/ResultVBox/ResultBody
@onready var result_continue_button: Button = $HUD/ResultPanel/ResultVBox/ResultButtons/ContinueButton
@onready var result_return_button: Button = $HUD/ResultPanel/ResultVBox/ResultButtons/ResultWarRoomButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

var obstacle_spawner
var pattern_runner
var lane_positions: Array[float] = []
var active_obstacles: Array = []
var active_drones: Array = []
var player_bullets: Array[Dictionary] = []
var enemy_bullets: Array[Dictionary] = []
var active_pickups: Array[Dictionary] = []
var active_fx: Array[Dictionary] = []
var sfx_pool: Array[AudioStreamPlayer] = []
var engine_player: AudioStreamPlayer
var sound_cache: Dictionary = {}
var texture_cache: Dictionary = {}
var screen_size := Vector2(1280.0, 720.0)
var stage_data: Dictionary = {}
var stage_map_id := DEFAULT_STAGE_ID
var stage_name := "IGNITION RUN"
var stage_theme := "badlands_tunnel"
var stage_visual_mode := "tunnel"
var stage_curve_strength := 1.0
var music_key := "speedbike_desert"
var active_music_path := ""
var stage_duration := 30.0
var stage_elapsed := 0.0
var stage_base_speed := 420.0
var stage_speed_ramp := 0.0
var stage_speed_bonus := 0.0
var camera_scroll_speed := 420.0
var deaths := 0
var crashes := 0
var drones_destroyed := 0
var pickups_collected := 0
var gold_coins_collected := 0
var blue_coins_collected := 0
var score := 0
var shield_hits := 0
var max_hits := 1
var remaining_hits := 1
var speedbike_bonus_health_slots := 0
var current_hits_flash := 0.0
var story_route := false
var practice_mode := false
var checkpoints_enabled := true
var speed_multiplier := 1.0
var difficulty_row: Dictionary = SPEEDBIKE_DIFFICULTY_DEFAULT.duplicate(true)
var stage_cleared := false
var stage_transition_live := false
var pause_open := false
var crash_restart_timer := -1.0
var invuln_timer := 0.0
var warning_text := ""
var warning_text_timer := 0.0
var tip_text := ""
var flash_alpha := 0.0
var blackout_strength := 0.0
var slow_time_timer := 0.0
var speedbike_weather_kind := "clear"
var speedbike_weather_timer := 0.0
var speedbike_lightning_timer := 0.0
var speedbike_lightning_flash := 0.0
var speedbike_lightning_points: PackedVector2Array = PackedVector2Array()
var speedbike_snow_coverage := 0.0
var speedbike_snowflakes: Array[Dictionary] = []
var section_hitless := true
var checkpoint_count := 0
var current_checkpoint: Dictionary = {}
var last_event_checkpoint_elapsed := -999.0
var last_safe_y := 360.0
var stage_started := false
var last_rank := "C"
var engine_pitch_target := 1.0
var engine_volume_target := -12.0
var result_ready_for_continue := false
var chapter_stage_ids: Array[String] = []
var chapter_start_stage_id := DEFAULT_STAGE_ID
var chapter_stage_index := 0
var chapter_transition_timer := -1.0
var chapter_elapsed_total := 0.0
var chapter_target_duration := 0.0
var stage_chain_carry_speed := 0.0
var stage_chain_carry_camera_x := 0.0
var stage_chain_carry_player_y := 0.0
var stage_chain_carry_player_x_offset := PLAYER_START_X_OFFSET
var stage_run_deaths := 0
var stage_run_crashes := 0
var selection_open := false
var selected_rider_id := "female"
var selection_preview_time := 0.0
var selection_preview_base_position := Vector2.ZERO
var rider_info_full_text := ""
var rider_info_visible_chars := 0
var rider_info_reveal_progress := 0.0
var rider_info_sound_timer := 0.0
var rider_info_audio_stream: AudioStream
var rider_info_audio_players: Array[AudioStreamPlayer] = []
var rider_info_audio_index := 0
var boost_bar_full_width := 186.0
var health_bar_full_width := 186.0
var speed_bar_full_width := 226.0
var death_bar_full_width := 226.0
var score_bar_full_width := 226.0
var progress_bar_full_width := 316.0
var checkpoint_splash_timer := 0.0
var checkpoint_splash_text := ""
var speedbike_weapon_kind := "normal"
var speedbike_weapon_timer := 0.0
var speedbike_weapon_ammo := -1
var merchant_shop_shade: ColorRect
var merchant_shop_panel: PanelContainer
var merchant_cat_image: TextureRect
var merchant_dialog_label: RichTextLabel
var merchant_status_label: Label
var merchant_wallet_label: Label
var merchant_repair_bar: ProgressBar
var merchant_repair_button: Button
var merchant_leave_button: Button
var merchant_item_buttons: Array[Button] = []
var merchant_item_rows: Array[PanelContainer] = []
var merchant_tab_buttons := {}
var merchant_item_list: VBoxContainer
var merchant_quantity_label: Label
var merchant_quantity_buttons: Array[Button] = []
var merchant_current_tab := "services"
var merchant_selected_kind := ""
var merchant_buy_quantity := 1
var merchant_state := "none"
var merchant_shop_open := false
var merchant_ship_position := Vector2.ZERO
var merchant_ship_open := true
var merchant_ship_alpha := 0.0
var merchant_beam_strength := 0.0
var merchant_timer := 0.0
var merchant_pending_next_stage := false
var merchant_repairing := false
var merchant_repair_timer := 0.0
var merchant_dialog_full_text := ""
var merchant_dialog_visible_chars := 0
var merchant_dialog_reveal_progress := 0.0
var merchant_dialog_sound_timer := 0.0
var merchant_ship_texture: Texture2D
var merchant_cat_idle_texture: Texture2D
var merchant_cat_repair_texture: Texture2D
var merchant_cat_finished_texture: Texture2D
var boss_dialog_shade: ColorRect
var boss_dialog_panel: PanelContainer
var boss_dialog_title_label: Label
var boss_dialog_text_label: RichTextLabel
var boss_dialog_continue_button: Button
var boss_dialog_hint_label: Label
var boss_intro_player: AudioStreamPlayer
var boss_laugh_player: AudioStreamPlayer
var boss_dialog_open := false
var boss_dialog_title := ""
var boss_dialog_pages: Array[String] = []
var boss_dialog_page_index := 0
var boss_dialog_full_text := ""
var boss_dialog_visible_chars := 0
var boss_dialog_reveal_progress := 0.0
var boss_dialog_sound_timer := 0.0
var boss_dialog_after_close := ""
var boss_intro_music_active := false
var boss_encounter_started := false
var boss_complete := false
var boss_cutscene_lock := false
var boss_state := "none"
var boss_arena_scroll_speed := BOSS_ARENA_SCROLL_SPEED
var boss_position := Vector2.ZERO
var boss_target_position := Vector2.ZERO
var boss_alpha := 0.0
var boss_health := 0
var boss_phase_timer := 0.0
var boss_phase_teleports_done := 0
var boss_attack_pattern_step := 0
var boss_damage_phase := "shield"
var boss_shield_health := BOSS_SHIELD_HEALTH
var boss_cannon_health := BOSS_CANNON_HEALTH
var boss_dome_health := BOSS_DOME_HEALTH
var boss_contact_hit_timer := 0.0
var boss_laser_cooldown := 999.0
var boss_laser_charge_timer := -1.0
var boss_laser_sweep_timer := -1.0
var boss_laser_from_top := false
var boss_regular_volley_count := 0
var boss_next_chain_attack_after := 8
var boss_chain_attack_timer := -1.0
var boss_chain_attack_shots_fired := 0
var boss_chain_attack_from_top := false
var boss_eye_charge_timer := -1.0
var boss_eye_beam_timer := -1.0
var boss_minion_spawn_index := 0
var boss_minion_wave_index := 0
var boss_minion_wave_count := 3
var boss_minion_intro_seen := false
var boss_minion_spawn_timer := 0.0
var boss_minion_spawn_visuals: Array[Dictionary] = []
var boss_return_timer := 0.0
var boss_portal_timer := 0.0
var boss_texture: Texture2D
var boss_minion_texture: Texture2D
var boss_music_cycle: Array[String] = []
var blue_coin_spawn_schedule: Array[Dictionary] = []
var blue_coin_ids_collected: Dictionary = {}
var mobile_menu_button: Button
var touch_controls_root: Control
var speedbike_touch_buttons: Dictionary = {}
var speedbike_touch_states := {
	"up": false,
	"down": false,
	"left": false,
	"right": false,
	"jump": false,
	"fire": false,
	"boost": false
}
var speedbike_touch_layout_positions: Dictionary = {}
var speedbike_touch_layout_edit_mode := false
var speedbike_touch_layout_snap_enabled := true
var speedbike_touch_screen_only_mode := false
var speedbike_touch_autofire_enabled := false
var speedbike_hud_buttons_hidden := false
var speedbike_hud_text_hidden := false
var speedbike_hud_text_alpha := 1.0
var oil_dropper_timer := 7.5
var speedbike_touch_drag_pointer := -1
var speedbike_touch_drag_id := ""
var speedbike_touch_drag_offset := Vector2.ZERO
var pause_touch_toggle_button: Button
var pause_touch_section: VBoxContainer
var pause_touch_controls_button: Button
var pause_touch_screen_only_button: Button
var pause_touch_autofire_button: Button
var pause_touch_layout_button: Button
var pause_touch_snap_button: Button
var pause_touch_reset_button: Button
var pause_hud_visibility_button: Button
var pause_hud_text_button: Button
var pause_hud_text_alpha_slider: HSlider
var pause_hud_text_alpha_value_label: Label
var pause_checkpoint_button: Button
var pause_tooltips_button: Button
var pause_controls_toggle_button: Button
var pause_controls_section: VBoxContainer
var pause_controls_binding_rows: Dictionary = {}
var pause_controls_message_label: Label
var pause_audio_toggle_button: Button
var pause_audio_section: VBoxContainer
var pause_main_section: VBoxContainer
var pause_gameplay_section: VBoxContainer
var pause_tab_row: HBoxContainer
var pause_page_host: VBoxContainer
var pause_tab_buttons: Dictionary = {}
var pause_current_tab := "main"
var pause_master_slider: HSlider
var pause_master_value_label: Label
var pause_music_slider: HSlider
var pause_music_value_label: Label
var pause_sfx_slider: HSlider
var pause_sfx_value_label: Label
var pause_touch_section_open := true
var pause_audio_section_open := false
var pause_settings_syncing := false
var pause_rebind_action := ""


func _ready() -> void:
	InputBindings.load_and_apply()
	screen_size = get_viewport_rect().size
	_stop_carryover_music()
	_build_lane_positions()
	_setup_audio_pool()
	_setup_ui()
	_connect_buttons()
	_setup_mode_context()
	_create_runtime_helpers()
	_load_stage_payload()
	_open_character_select()
	if get_viewport() != null and not get_viewport().size_changed.is_connected(_on_speedbike_viewport_resized):
		get_viewport().size_changed.connect(_on_speedbike_viewport_resized)
	if not AppState.settings_changed.is_connected(_on_speedbike_app_settings_changed):
		AppState.settings_changed.connect(_on_speedbike_app_settings_changed)
	set_physics_process(true)
	set_process(true)
	queue_redraw()


func _setup_audio_pool() -> void:
	for index in range(8):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.set_meta("base_volume_db", -8.0)
		add_child(player)
		sfx_pool.append(player)
	engine_player = AudioStreamPlayer.new()
	engine_player.bus = "Master"
	engine_player.stream = _load_audio_stream(ENGINE_SOUND_PATH)
	if engine_player.stream is AudioStreamMP3:
		(engine_player.stream as AudioStreamMP3).loop = true
	add_child(engine_player)
	_setup_rider_typewriter_audio()
	_setup_boss_audio_players()


func _setup_rider_typewriter_audio() -> void:
	if not rider_info_audio_players.is_empty():
		return
	var absolute_path := ProjectSettings.globalize_path(TYPEWRITER_SOUND_PATH)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Missing speedbike rider typewriter sound: %s" % TYPEWRITER_SOUND_PATH)
		return
	var extension := TYPEWRITER_SOUND_PATH.get_extension().to_lower()
	if extension == "wav" or extension == "wave":
		rider_info_audio_stream = AudioStreamWAV.load_from_file(absolute_path)
	else:
		rider_info_audio_stream = AudioStreamMP3.load_from_file(absolute_path)
	if rider_info_audio_stream == null:
		push_warning("Could not load speedbike rider typewriter sound: %s" % TYPEWRITER_SOUND_PATH)
		return
	for _i in range(RIDER_TYPEWRITER_PLAYER_COUNT):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.stream = rider_info_audio_stream
		player.pitch_scale = 1.0
		player.set_meta("base_volume_db", 10.0)
		player.volume_db = _speedbike_sfx_volume_db(10.0)
		add_child(player)
		rider_info_audio_players.append(player)


func _setup_boss_audio_players() -> void:
	if boss_intro_player == null or not is_instance_valid(boss_intro_player):
		boss_intro_player = AudioStreamPlayer.new()
		boss_intro_player.bus = "Master"
		boss_intro_player.process_mode = Node.PROCESS_MODE_ALWAYS
		boss_intro_player.stream = _load_direct_audio_stream(BOSS_INTRO_SOUND_PATH)
		boss_intro_player.set_meta("base_volume_db", -6.0)
		add_child(boss_intro_player)
	if boss_laugh_player == null or not is_instance_valid(boss_laugh_player):
		boss_laugh_player = AudioStreamPlayer.new()
		boss_laugh_player.bus = "Master"
		boss_laugh_player.process_mode = Node.PROCESS_MODE_ALWAYS
		boss_laugh_player.stream = _load_direct_audio_stream(BOSS_LAUGH_SOUND_PATH)
		boss_laugh_player.set_meta("base_volume_db", 2.0)
		add_child(boss_laugh_player)


func _setup_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	character_select_shade.process_mode = Node.PROCESS_MODE_ALWAYS
	character_select_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	result_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	flash_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	character_select_shade.visible = false
	character_select_panel.visible = false
	pause_panel.visible = false
	result_panel.visible = false
	flash_rect.visible = true
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	boost_bar_full_width = boost_bar_back.size.x
	_setup_health_bar_ui()
	character_female_button.focus_neighbor_bottom = character_gunner_button.get_path()
	character_gunner_button.focus_neighbor_top = character_female_button.get_path()
	character_gunner_button.focus_neighbor_bottom = character_scout_button.get_path()
	character_scout_button.focus_neighbor_top = character_gunner_button.get_path()
	character_scout_button.focus_neighbor_bottom = character_deploy_button.get_path()
	character_deploy_button.focus_neighbor_top = character_scout_button.get_path()
	character_deploy_button.focus_neighbor_right = character_return_button.get_path()
	character_return_button.focus_neighbor_left = character_deploy_button.get_path()
	character_return_button.focus_neighbor_top = character_scout_button.get_path()
	selection_preview_base_position = character_preview_image.position
	character_selected_stats.scroll_active = false
	character_stats_label.visible_characters = 0
	character_stats_scroll.scroll_vertical = 0
	tip_label.text = ""
	warning_label.text = ""
	_load_speedbike_touch_settings()
	_build_speedbike_mobile_ui()
	_build_speedbike_pause_options()
	_apply_speedbike_mobile_layout()
	_sync_speedbike_pause_controls()
	_setup_merchant_ui()
	_setup_boss_dialog_ui()


func _on_speedbike_viewport_resized() -> void:
	screen_size = get_viewport_rect().size
	_apply_speedbike_mobile_layout()
	_sync_speedbike_touch_controls()


func _on_speedbike_app_settings_changed() -> void:
	_refresh_speedbike_music_volume()
	_sync_speedbike_pause_controls()
	_sync_speedbike_touch_controls()


func _setup_health_bar_ui() -> void:
	if health_bar_back != null and is_instance_valid(health_bar_back):
		return
	speed_label.visible = false
	death_label.visible = false
	boost_label.visible = false
	speed_label.offset_left = 24.0
	speed_label.offset_top = 16.0
	speed_label.offset_right = 250.0
	speed_label.offset_bottom = 40.0
	death_label.offset_left = 24.0
	death_label.offset_top = 44.0
	death_label.offset_right = 250.0
	death_label.offset_bottom = 68.0
	score_label.offset_left = 24.0
	score_label.offset_top = 16.0
	score_label.offset_right = 250.0
	score_label.offset_bottom = 40.0
	progress_label.offset_left = 24.0
	progress_label.offset_top = 44.0
	progress_label.offset_right = 340.0
	progress_label.offset_bottom = 68.0
	hit_label.offset_left = 24.0
	hit_label.offset_top = 72.0
	hit_label.offset_right = 250.0
	hit_label.offset_bottom = 96.0
	boost_label.offset_left = 24.0
	boost_label.offset_top = 168.0
	boost_label.offset_right = 250.0
	boost_label.offset_bottom = 192.0
	score_bar_back = _create_speedbike_hud_bar("ScoreBar", 24.0, 16.0, 226.0, 24.0, Color(0.05, 0.05, 0.035, 0.82), Color(1.0, 0.74, 0.26, 0.80)).get("back") as ColorRect
	score_bar_fill = get_node_or_null("HUD/ScoreBarFill") as ColorRect
	progress_bar_back = _create_speedbike_hud_bar("ProgressBar", 24.0, 44.0, 316.0, 24.0, Color(0.04, 0.045, 0.05, 0.84), Color(0.38, 1.0, 0.54, 0.78)).get("back") as ColorRect
	progress_bar_fill = get_node_or_null("HUD/ProgressBarFill") as ColorRect
	health_bar_back = ColorRect.new()
	health_bar_back.name = "HealthBarBack"
	health_bar_back.offset_left = 24.0
	health_bar_back.offset_top = 72.0
	health_bar_back.offset_right = 250.0
	health_bar_back.offset_bottom = 96.0
	health_bar_back.color = Color(0.07, 0.08, 0.08, 0.86)
	hud_layer.add_child(health_bar_back)
	hud_layer.move_child(health_bar_back, 0)
	health_bar_fill = ColorRect.new()
	health_bar_fill.name = "HealthBarFill"
	health_bar_fill.offset_left = 24.0
	health_bar_fill.offset_top = 72.0
	health_bar_fill.offset_right = 250.0
	health_bar_fill.offset_bottom = 96.0
	health_bar_fill.color = Color(0.34, 1.0, 0.48, 0.95)
	hud_layer.add_child(health_bar_fill)
	hud_layer.move_child(health_bar_fill, 1)
	health_bar_full_width = health_bar_back.offset_right - health_bar_back.offset_left
	boost_bar_back.visible = false
	boost_bar_fill.visible = false
	boost_bar_full_width = boost_bar_back.offset_right - boost_bar_back.offset_left
	speed_bar_full_width = 0.0
	death_bar_full_width = 0.0
	score_bar_full_width = 226.0
	progress_bar_full_width = 316.0
	_bring_speedbike_hud_labels_forward()


func _create_speedbike_hud_bar(name_prefix: String, left: float, top: float, width: float, height: float, back_color: Color, fill_color: Color) -> Dictionary:
	var back := ColorRect.new()
	back.name = "%sBack" % name_prefix
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.offset_left = left
	back.offset_top = top
	back.offset_right = left + width
	back.offset_bottom = top + height
	back.color = back_color
	hud_layer.add_child(back)
	hud_layer.move_child(back, 0)
	var fill := ColorRect.new()
	fill.name = "%sFill" % name_prefix
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.offset_left = left
	fill.offset_top = top
	fill.offset_right = left + width
	fill.offset_bottom = top + height
	fill.color = fill_color
	hud_layer.add_child(fill)
	hud_layer.move_child(fill, 1)
	return {"back": back, "fill": fill}


func _bring_speedbike_hud_labels_forward() -> void:
	for control in [speed_label, death_label, score_label, progress_label, hit_label, boost_label, warning_label, tip_label, flash_rect]:
		if control != null and is_instance_valid(control) and control.get_parent() == hud_layer:
			hud_layer.move_child(control, hud_layer.get_child_count() - 1)


func _load_speedbike_touch_settings() -> void:
	speedbike_touch_layout_positions.clear()
	speedbike_touch_layout_snap_enabled = true
	speedbike_touch_screen_only_mode = false
	speedbike_touch_autofire_enabled = false
	speedbike_hud_buttons_hidden = false
	speedbike_hud_text_hidden = false
	speedbike_hud_text_alpha = 1.0
	var config := ConfigFile.new()
	if config.load(SPEEDBIKE_TOUCH_SETTINGS_PATH) != OK:
		return
	speedbike_touch_layout_snap_enabled = bool(config.get_value("touch", "snap_enabled", true))
	speedbike_touch_screen_only_mode = bool(config.get_value("touch", "screen_only_mode", false))
	speedbike_touch_autofire_enabled = bool(config.get_value("touch", "autofire_enabled", false))
	speedbike_hud_buttons_hidden = bool(config.get_value("hud", "buttons_hidden", false))
	speedbike_hud_text_hidden = bool(config.get_value("hud", "text_hidden", false))
	speedbike_hud_text_alpha = clampf(float(config.get_value("hud", "text_alpha", 1.0)), 0.25, 1.0)
	var layout_version := int(config.get_value("touch_layout", "version", 0))
	if layout_version < SPEEDBIKE_TOUCH_LAYOUT_VERSION:
		return
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		var saved: Variant = config.get_value("touch_layout", button_id, null)
		if saved is Vector2:
			speedbike_touch_layout_positions[button_id] = saved
		elif saved is Array and (saved as Array).size() >= 2:
			speedbike_touch_layout_positions[button_id] = Vector2(float(saved[0]), float(saved[1]))


func _save_speedbike_touch_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("touch", "snap_enabled", speedbike_touch_layout_snap_enabled)
	config.set_value("touch", "screen_only_mode", speedbike_touch_screen_only_mode)
	config.set_value("touch", "autofire_enabled", speedbike_touch_autofire_enabled)
	config.set_value("hud", "buttons_hidden", speedbike_hud_buttons_hidden)
	config.set_value("hud", "text_hidden", speedbike_hud_text_hidden)
	config.set_value("hud", "text_alpha", speedbike_hud_text_alpha)
	config.set_value("touch_layout", "version", SPEEDBIKE_TOUCH_LAYOUT_VERSION)
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		if speedbike_touch_layout_positions.has(button_id):
			config.set_value("touch_layout", button_id, speedbike_touch_layout_positions[button_id])
	config.save(SPEEDBIKE_TOUCH_SETTINGS_PATH)


func _build_speedbike_mobile_ui() -> void:
	if touch_controls_root == null or not is_instance_valid(touch_controls_root):
		touch_controls_root = Control.new()
		touch_controls_root.name = "TouchControlsRoot"
		touch_controls_root.process_mode = Node.PROCESS_MODE_ALWAYS
		touch_controls_root.mouse_filter = Control.MOUSE_FILTER_PASS
		touch_controls_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		hud_layer.add_child(touch_controls_root)
	if mobile_menu_button == null or not is_instance_valid(mobile_menu_button):
		mobile_menu_button = Button.new()
		mobile_menu_button.name = "MobileMenuButton"
		mobile_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
		mobile_menu_button.focus_mode = Control.FOCUS_NONE
		mobile_menu_button.text = "..."
		mobile_menu_button.custom_minimum_size = Vector2(72.0, 62.0)
		mobile_menu_button.pressed.connect(_toggle_pause)
		hud_layer.add_child(mobile_menu_button)
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		if speedbike_touch_buttons.has(button_id):
			continue
		var button := Button.new()
		button.name = "%sTouchButton" % button_id.capitalize()
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.focus_mode = Control.FOCUS_NONE
		button.text = str(SPEEDBIKE_TOUCH_BUTTON_LABELS.get(button_id, button_id.to_upper()))
		button.custom_minimum_size = Vector2(132.0, 72.0)
		button.button_down.connect(_set_speedbike_touch_state.bind(button_id, true))
		button.button_up.connect(_set_speedbike_touch_state.bind(button_id, false))
		button.mouse_exited.connect(_set_speedbike_touch_state.bind(button_id, false))
		touch_controls_root.add_child(button)
		speedbike_touch_buttons[button_id] = button


func _build_speedbike_pause_options() -> void:
	if pause_tab_row != null and is_instance_valid(pause_tab_row):
		return
	var pause_vbox := pause_title.get_parent() as VBoxContainer
	if pause_vbox == null:
		return

	pause_tab_buttons.clear()
	pause_tab_row = HBoxContainer.new()
	pause_tab_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_tab_row.add_theme_constant_override("separation", 6)
	pause_vbox.add_child(pause_tab_row)
	_create_speedbike_pause_tab_button("MAIN", "main")
	_create_speedbike_pause_tab_button("GAMEPLAY", "gameplay")
	pause_controls_toggle_button = _create_speedbike_pause_tab_button("CONTROLS", "controls")
	pause_touch_toggle_button = _create_speedbike_pause_tab_button("TOUCH / HUD", "touch")
	pause_audio_toggle_button = _create_speedbike_pause_tab_button("AUDIO", "audio")

	pause_page_host = VBoxContainer.new()
	pause_page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_page_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_page_host.add_theme_constant_override("separation", 8)
	pause_vbox.add_child(pause_page_host)

	pause_main_section = VBoxContainer.new()
	pause_main_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_main_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_main_section.add_theme_constant_override("separation", 10)
	pause_page_host.add_child(pause_main_section)
	for button in [pause_resume_button, pause_restart_button, pause_return_button]:
		if button.get_parent() != null:
			button.get_parent().remove_child(button)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pause_main_section.add_child(button)

	pause_gameplay_section = VBoxContainer.new()
	pause_gameplay_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_gameplay_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_gameplay_section.add_theme_constant_override("separation", 8)
	pause_page_host.add_child(pause_gameplay_section)

	var gameplay_hint := Label.new()
	gameplay_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gameplay_hint.add_theme_color_override("font_color", Color(0.86, 0.96, 0.9, 1.0))
	gameplay_hint.text = "Speedbike run rules. Checkpoints can be disabled for classic full-stage restarts."
	pause_gameplay_section.add_child(gameplay_hint)

	pause_checkpoint_button = Button.new()
	pause_checkpoint_button.pressed.connect(_toggle_speedbike_checkpoints)
	pause_gameplay_section.add_child(pause_checkpoint_button)

	pause_tooltips_button = Button.new()
	pause_tooltips_button.pressed.connect(_toggle_speedbike_tooltips)
	pause_gameplay_section.add_child(pause_tooltips_button)

	pause_controls_section = VBoxContainer.new()
	pause_controls_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_controls_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_controls_section.add_theme_constant_override("separation", 8)
	pause_page_host.add_child(pause_controls_section)

	var controls_hint := Label.new()
	controls_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_hint.add_theme_color_override("font_color", Color(0.86, 0.96, 0.9, 1.0))
	controls_hint.text = "Keyboard and controller setup. Select a row, then press the key, button, or stick direction you want to use."
	pause_controls_section.add_child(controls_hint)
	_build_speedbike_binding_rows(pause_controls_section)

	pause_touch_section = VBoxContainer.new()
	pause_touch_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_touch_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_touch_section.add_theme_constant_override("separation", 8)
	pause_page_host.add_child(pause_touch_section)

	var touch_hint := Label.new()
	touch_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	touch_hint.add_theme_color_override("font_color", Color(0.86, 0.96, 0.9, 1.0))
	touch_hint.text = "Android, tablet, Steam Deck, and Windows HUD controls. Move buttons here, then lock the layout."
	pause_touch_section.add_child(touch_hint)

	pause_touch_controls_button = Button.new()
	pause_touch_controls_button.pressed.connect(_cycle_speedbike_touch_controls_mode)
	pause_touch_section.add_child(pause_touch_controls_button)

	pause_touch_screen_only_button = Button.new()
	pause_touch_screen_only_button.pressed.connect(_toggle_speedbike_touch_screen_only)
	pause_touch_section.add_child(pause_touch_screen_only_button)

	pause_touch_autofire_button = Button.new()
	pause_touch_autofire_button.pressed.connect(_toggle_speedbike_touch_autofire)
	pause_touch_section.add_child(pause_touch_autofire_button)

	pause_touch_layout_button = Button.new()
	pause_touch_layout_button.pressed.connect(_toggle_speedbike_touch_layout_edit_mode)
	pause_touch_section.add_child(pause_touch_layout_button)

	pause_touch_snap_button = Button.new()
	pause_touch_snap_button.pressed.connect(_toggle_speedbike_touch_layout_snap)
	pause_touch_section.add_child(pause_touch_snap_button)

	pause_touch_reset_button = Button.new()
	pause_touch_reset_button.pressed.connect(_reset_speedbike_touch_layout)
	pause_touch_section.add_child(pause_touch_reset_button)

	pause_hud_visibility_button = Button.new()
	pause_hud_visibility_button.pressed.connect(_toggle_speedbike_hud_buttons_hidden)
	pause_touch_section.add_child(pause_hud_visibility_button)

	pause_hud_text_button = Button.new()
	pause_hud_text_button.pressed.connect(_toggle_speedbike_hud_text_hidden)
	pause_touch_section.add_child(pause_hud_text_button)

	var hud_alpha_row := _create_speedbike_pause_slider_row(pause_touch_section, "TEXT OPACITY")
	pause_hud_text_alpha_slider = hud_alpha_row.get("slider") as HSlider
	pause_hud_text_alpha_value_label = hud_alpha_row.get("value") as Label
	pause_hud_text_alpha_slider.min_value = 25.0
	pause_hud_text_alpha_slider.max_value = 100.0
	pause_hud_text_alpha_slider.value_changed.connect(_on_speedbike_pause_hud_text_alpha_changed)

	pause_audio_section = VBoxContainer.new()
	pause_audio_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_audio_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_audio_section.add_theme_constant_override("separation", 8)
	pause_page_host.add_child(pause_audio_section)

	var audio_hint := Label.new()
	audio_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	audio_hint.add_theme_color_override("font_color", Color(0.86, 0.96, 0.9, 1.0))
	audio_hint.text = "Tune master, music, and effects volume without leaving the run."
	pause_audio_section.add_child(audio_hint)

	var master_row := _create_speedbike_pause_slider_row(pause_audio_section, "MASTER")
	pause_master_slider = master_row.get("slider") as HSlider
	pause_master_value_label = master_row.get("value") as Label
	pause_master_slider.value_changed.connect(_on_speedbike_pause_master_slider_changed)

	var music_row := _create_speedbike_pause_slider_row(pause_audio_section, "MUSIC")
	pause_music_slider = music_row.get("slider") as HSlider
	pause_music_value_label = music_row.get("value") as Label
	pause_music_slider.value_changed.connect(_on_speedbike_pause_music_slider_changed)

	var sfx_row := _create_speedbike_pause_slider_row(pause_audio_section, "SFX")
	pause_sfx_slider = sfx_row.get("slider") as HSlider
	pause_sfx_value_label = sfx_row.get("value") as Label
	pause_sfx_slider.value_changed.connect(_on_speedbike_pause_sfx_slider_changed)


func _create_speedbike_pause_tab_button(label_text: String, tab_id: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(_select_speedbike_pause_tab.bind(tab_id))
	pause_tab_row.add_child(button)
	pause_tab_buttons[tab_id] = button
	return button


func _select_speedbike_pause_tab(tab_id: String) -> void:
	pause_current_tab = tab_id
	pause_touch_section_open = tab_id == "touch"
	pause_audio_section_open = tab_id == "audio"
	_sync_speedbike_pause_controls()
	call_deferred("_focus_speedbike_pause_default_control")


func _speedbike_pause_tab_display_name(tab_id: String) -> String:
	match tab_id:
		"main":
			return "MAIN"
		"gameplay":
			return "GAMEPLAY"
		"controls":
			return "CONTROLS"
		"touch":
			return "TOUCH / HUD"
		"audio":
			return "AUDIO"
		_:
			return tab_id.to_upper()


func _create_speedbike_pause_slider_row(parent: VBoxContainer, label_text: String) -> Dictionary:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(74.0, 0.0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(58.0, 0.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)
	return {"slider": slider, "value": value_label}


func _build_speedbike_binding_rows(parent: VBoxContainer) -> void:
	pause_controls_binding_rows.clear()
	for row_data in InputBindings.binding_rows():
		var action_id := str(row_data.get("id", ""))
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 10)
		parent.add_child(row)
		var label := Label.new()
		label.text = str(row_data.get("label", action_id.capitalize()))
		label.custom_minimum_size = Vector2(190.0, 0.0)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_begin_speedbike_rebind_action.bind(action_id))
		row.add_child(button)
		pause_controls_binding_rows[action_id] = button
	var reset_button := Button.new()
	reset_button.text = "RESET CONTROLS TO DEFAULTS"
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(_reset_speedbike_bindings)
	parent.add_child(reset_button)
	pause_controls_message_label = Label.new()
	pause_controls_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_controls_message_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.44, 1.0))
	parent.add_child(pause_controls_message_label)
	_refresh_speedbike_binding_rows()


func _refresh_speedbike_binding_rows() -> void:
	for row_data in InputBindings.binding_rows():
		var action_id := str(row_data.get("id", ""))
		var button := pause_controls_binding_rows.get(action_id) as Button
		if button == null:
			continue
		var prefix := "PRESS INPUT FOR " if pause_rebind_action == action_id else ""
		button.text = "%s%s" % [prefix, InputBindings.describe_binding(action_id)]
	if pause_controls_message_label != null:
		if pause_rebind_action.is_empty():
			pause_controls_message_label.text = "Tip: movement still supports the normal menu/D-pad directions. Rebind Jump, Attack, Run, and Pause here for each device."
		else:
			pause_controls_message_label.text = "Waiting for %s. Press Esc / B to cancel." % InputBindings.label_for(pause_rebind_action)


func _begin_speedbike_rebind_action(action_id: String) -> void:
	pause_rebind_action = action_id
	_refresh_speedbike_binding_rows()
	if pause_controls_message_label != null:
		pause_controls_message_label.text = "Press a key, controller button, or stick direction for %s." % InputBindings.label_for(action_id)


func _handle_speedbike_rebind_input(event: InputEvent) -> bool:
	if pause_rebind_action.is_empty():
		return false
	if _menu_back_pressed(event):
		pause_rebind_action = ""
		_refresh_speedbike_binding_rows()
		return true
	if InputBindings.set_binding_from_event(pause_rebind_action, event):
		var label := InputBindings.label_for(pause_rebind_action)
		pause_rebind_action = ""
		_refresh_speedbike_binding_rows()
		if pause_controls_message_label != null:
			pause_controls_message_label.text = "%s updated." % label
		return true
	return false


func _reset_speedbike_bindings() -> void:
	InputBindings.reset_to_defaults()
	pause_rebind_action = ""
	_refresh_speedbike_binding_rows()
	if pause_controls_message_label != null:
		pause_controls_message_label.text = "Controls restored to the default keyboard and controller layout."


func _speedbike_mobile_available() -> bool:
	return AppState.is_mobile_platform() or AppState.touch_controls_mode() == "on"


func _speedbike_touch_controls_enabled() -> bool:
	return AppState.use_touch_controls()


func _speedbike_touch_button_size(viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 980.0 or viewport_size.y <= 560.0:
		return Vector2(108.0, 62.0)
	if viewport_size.x >= 1500.0 and viewport_size.y >= 760.0:
		return Vector2(146.0, 78.0)
	return Vector2(132.0, 72.0)


func _default_speedbike_touch_position(button_id: String, viewport_size: Vector2) -> Vector2:
	var button_size := _speedbike_touch_button_size(viewport_size)
	var gap := clampf(button_size.x * 0.12, 10.0, 18.0)
	var side_margin := clampf(viewport_size.x * 0.035, 28.0, 54.0)
	var bottom_margin := clampf(viewport_size.y * 0.055, 22.0, 42.0)
	var dpad_top := viewport_size.y - (button_size.y * 3.0 + gap * 2.0) - bottom_margin
	var dpad_left := side_margin
	var action_top := viewport_size.y - (button_size.y * 2.0 + gap) - bottom_margin
	var action_left := viewport_size.x - (button_size.x * 3.0 + gap * 2.0) - side_margin
	match button_id:
		"up":
			return Vector2(dpad_left + button_size.x + gap, dpad_top)
		"down":
			return Vector2(dpad_left + button_size.x + gap, dpad_top + (button_size.y + gap) * 2.0)
		"left":
			return Vector2(dpad_left, dpad_top + button_size.y + gap)
		"right":
			return Vector2(dpad_left + (button_size.x + gap) * 2.0, dpad_top + button_size.y + gap)
		"jump":
			return Vector2(action_left, action_top + button_size.y + gap)
		"fire":
			return Vector2(action_left + button_size.x + gap, action_top)
		"boost":
			return Vector2(action_left + (button_size.x + gap) * 2.0, action_top + button_size.y + gap)
		_:
			return Vector2(0.0, 0.0)


func _speedbike_touch_button_position(button_id: String, control_size: Vector2, viewport_size: Vector2) -> Vector2:
	var saved: Variant = speedbike_touch_layout_positions.get(button_id, null)
	var desired := _default_speedbike_touch_position(button_id, viewport_size)
	if saved is Vector2:
		desired = Vector2((saved as Vector2).x * viewport_size.x, (saved as Vector2).y * viewport_size.y)
	return _clamped_speedbike_touch_position(desired, control_size, viewport_size)


func _clamped_speedbike_touch_position(desired: Vector2, control_size: Vector2, viewport_size: Vector2) -> Vector2:
	var clamped := Vector2(
		clampf(desired.x, 12.0, viewport_size.x - control_size.x - 12.0),
		clampf(desired.y, 12.0, viewport_size.y - control_size.y - 12.0)
	)
	if speedbike_touch_layout_snap_enabled:
		var snap := 12.0
		clamped.x = round(clamped.x / snap) * snap
		clamped.y = round(clamped.y / snap) * snap
	return clamped


func _store_speedbike_touch_button_position(button_id: String) -> void:
	var button := speedbike_touch_buttons.get(button_id) as Control
	if button == null:
		return
	var viewport_size := get_viewport_rect().size
	button.position = _clamped_speedbike_touch_position(button.position, button.size, viewport_size)
	speedbike_touch_layout_positions[button_id] = Vector2(
		button.position.x / maxf(viewport_size.x, 1.0),
		button.position.y / maxf(viewport_size.y, 1.0)
	)
	_save_speedbike_touch_settings()


func _apply_speedbike_mobile_layout() -> void:
	var viewport_size := get_viewport_rect().size
	screen_size = viewport_size
	if mobile_menu_button != null:
		mobile_menu_button.position = Vector2(viewport_size.x - mobile_menu_button.size.x - 18.0, 18.0)
	if touch_controls_root != null:
		var touch_button_size := _speedbike_touch_button_size(viewport_size)
		for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
			var button := speedbike_touch_buttons.get(button_id) as Button
			if button == null:
				continue
			button.custom_minimum_size = touch_button_size
			button.size = touch_button_size
			button.position = _speedbike_touch_button_position(button_id, button.size, viewport_size)
	if pause_panel != null:
		var mobile := _speedbike_mobile_available() or viewport_size.x < 1100.0
		if mobile:
			pause_panel.offset_left = maxf(30.0, viewport_size.x * 0.05)
			pause_panel.offset_top = maxf(36.0, viewport_size.y * 0.06)
			pause_panel.offset_right = viewport_size.x - maxf(30.0, viewport_size.x * 0.05)
			pause_panel.offset_bottom = viewport_size.y - maxf(32.0, viewport_size.y * 0.06)
		else:
			var panel_size := Vector2(760.0, 520.0)
			pause_panel.offset_left = (viewport_size.x - panel_size.x) * 0.5
			pause_panel.offset_top = (viewport_size.y - panel_size.y) * 0.5
			pause_panel.offset_right = pause_panel.offset_left + panel_size.x
			pause_panel.offset_bottom = pause_panel.offset_top + panel_size.y


func _sync_speedbike_touch_controls() -> void:
	var show_mobile := _speedbike_mobile_available()
	if mobile_menu_button != null:
		mobile_menu_button.visible = show_mobile and (not speedbike_hud_buttons_hidden or pause_open or speedbike_touch_layout_edit_mode)
	if touch_controls_root == null:
		return
	var allow_touch_buttons := not selection_open and not stage_cleared
	var show_buttons := show_mobile and (allow_touch_buttons or speedbike_touch_layout_edit_mode) and (_speedbike_touch_controls_enabled() or speedbike_touch_layout_edit_mode) and (not pause_open or speedbike_touch_layout_edit_mode)
	touch_controls_root.visible = show_buttons and (not speedbike_hud_buttons_hidden or speedbike_touch_layout_edit_mode)
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		var button := speedbike_touch_buttons.get(button_id) as Button
		if button == null:
			continue
		button.disabled = speedbike_touch_layout_edit_mode
		button.modulate = Color(0.96, 0.82, 0.38, 0.92) if speedbike_touch_layout_edit_mode else (Color(1.0, 0.58, 0.28, 0.94) if bool(speedbike_touch_states.get(button_id, false)) else Color(1.0, 1.0, 1.0, 0.86))


func _sync_speedbike_pause_controls() -> void:
	pause_settings_syncing = true
	for tab_id in pause_tab_buttons.keys():
		var tab_button := pause_tab_buttons.get(tab_id) as Button
		if tab_button == null:
			continue
		var selected := str(tab_id) == pause_current_tab
		tab_button.text = "%s%s" % ["> " if selected else "", _speedbike_pause_tab_display_name(str(tab_id))]
	if pause_main_section != null:
		pause_main_section.visible = pause_current_tab == "main"
	if pause_gameplay_section != null:
		pause_gameplay_section.visible = pause_current_tab == "gameplay"
	if pause_controls_section != null:
		pause_controls_section.visible = pause_current_tab == "controls"
	if pause_touch_section != null:
		pause_touch_section.visible = pause_current_tab == "touch"
	if pause_audio_section != null:
		pause_audio_section.visible = pause_current_tab == "audio"
	if pause_checkpoint_button != null:
		pause_checkpoint_button.text = "CHECKPOINTS: %s" % ("ON" if checkpoints_enabled else "OFF - RESTART STAGE")
	if pause_tooltips_button != null:
		pause_tooltips_button.text = "BOTTOM TIPS: %s" % ("ON" if AppState.show_tooltips else "OFF")
	_refresh_speedbike_binding_rows()
	if pause_touch_controls_button != null:
		pause_touch_controls_button.text = "TOUCH CONTROLS: %s" % AppState.touch_controls_mode().to_upper()
	if pause_touch_screen_only_button != null:
		pause_touch_screen_only_button.text = "TOUCH SCREEN ONLY: %s" % ("ON" if speedbike_touch_screen_only_mode else "OFF")
	if pause_touch_autofire_button != null:
		pause_touch_autofire_button.text = "AUTO FIRE: %s" % ("ON" if speedbike_touch_autofire_enabled else "OFF")
	if pause_touch_layout_button != null:
		pause_touch_layout_button.text = "MOVE TOUCH BUTTONS: %s" % ("ON" if speedbike_touch_layout_edit_mode else "OFF")
	if pause_touch_snap_button != null:
		pause_touch_snap_button.text = "TOUCH SNAP: %s" % ("ON" if speedbike_touch_layout_snap_enabled else "OFF")
	if pause_touch_reset_button != null:
		pause_touch_reset_button.text = "RESET TOUCH LAYOUT"
	if pause_hud_visibility_button != null:
		pause_hud_visibility_button.text = "HUD BUTTONS: %s" % ("HIDDEN" if speedbike_hud_buttons_hidden else "VISIBLE")
	if pause_hud_text_button != null:
		pause_hud_text_button.text = "HUD TEXT: %s" % ("HIDDEN" if speedbike_hud_text_hidden else "VISIBLE")
	if pause_hud_text_alpha_slider != null:
		pause_hud_text_alpha_slider.value = roundi(speedbike_hud_text_alpha * 100.0)
	if pause_hud_text_alpha_value_label != null:
		pause_hud_text_alpha_value_label.text = "%d%%" % int(round(speedbike_hud_text_alpha * 100.0))
	if pause_master_slider != null:
		pause_master_slider.value = roundi(AppState.master_volume * 100.0)
	if pause_master_value_label != null:
		pause_master_value_label.text = "%d%%" % int(round(AppState.master_volume * 100.0))
	if pause_music_slider != null:
		pause_music_slider.value = roundi(AppState.music_volume * 100.0)
	if pause_music_value_label != null:
		pause_music_value_label.text = "%d%%" % int(round(AppState.music_volume * 100.0))
	if pause_sfx_slider != null:
		pause_sfx_slider.value = roundi(AppState.sfx_volume * 100.0)
	if pause_sfx_value_label != null:
		pause_sfx_value_label.text = "%d%%" % int(round(AppState.sfx_volume * 100.0))
	pause_settings_syncing = false


func _set_speedbike_touch_state(button_id: String, pressed: bool) -> void:
	if speedbike_touch_layout_edit_mode:
		return
	if not speedbike_touch_states.has(button_id):
		return
	speedbike_touch_states[button_id] = pressed
	_sync_speedbike_touch_controls()


func _clear_speedbike_touch_states() -> void:
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		speedbike_touch_states[button_id] = false


func _toggle_speedbike_pause_touch_section() -> void:
	_select_speedbike_pause_tab("touch")


func _toggle_speedbike_pause_audio_section() -> void:
	_select_speedbike_pause_tab("audio")


func _focus_speedbike_pause_default_control() -> void:
	match pause_current_tab:
		"gameplay":
			if pause_checkpoint_button != null and pause_checkpoint_button.visible and not pause_checkpoint_button.disabled:
				pause_checkpoint_button.call_deferred("grab_focus")
				return
		"controls":
			var first_button := pause_controls_binding_rows.get("move_up") as Button
			if first_button != null and first_button.visible and not first_button.disabled:
				first_button.call_deferred("grab_focus")
				return
		"touch":
			if pause_touch_controls_button != null and pause_touch_controls_button.visible and not pause_touch_controls_button.disabled:
				pause_touch_controls_button.call_deferred("grab_focus")
				return
		"audio":
			if pause_master_slider != null and pause_master_slider.visible and pause_master_slider.editable:
				pause_master_slider.call_deferred("grab_focus")
				return
	if pause_resume_button != null and pause_resume_button.visible and not pause_resume_button.disabled:
		pause_resume_button.call_deferred("grab_focus")
		return
	if pause_restart_button != null and pause_restart_button.visible and not pause_restart_button.disabled:
		pause_restart_button.call_deferred("grab_focus")
		return
	if pause_return_button != null and pause_return_button.visible and not pause_return_button.disabled:
		pause_return_button.call_deferred("grab_focus")
		return


func _toggle_speedbike_checkpoints() -> void:
	checkpoints_enabled = not checkpoints_enabled
	if PlayState.has_method("set_speedbike_checkpoints_enabled"):
		PlayState.set_speedbike_checkpoints_enabled(checkpoints_enabled)
	else:
		PlayState.speedbike_checkpoints_enabled = checkpoints_enabled
		PlayState.flush_progress()
	_sync_speedbike_pause_controls()
	_show_warning(
		"CHECKPOINTS ON" if checkpoints_enabled else "CHECKPOINTS OFF - CRASH RESTARTS STAGE",
		1.0
	)


func _toggle_speedbike_tooltips() -> void:
	AppState.set_show_tooltips(not AppState.show_tooltips)
	_sync_speedbike_pause_controls()
	_update_hud()
	_show_warning("BOTTOM TIPS %s" % ("ON" if AppState.show_tooltips else "OFF"), 0.8)


func _cycle_speedbike_touch_controls_mode() -> void:
	var current := AppState.touch_controls_mode()
	var next_mode := "off"
	match current:
		"off":
			next_mode = "auto"
		"auto":
			next_mode = "on"
		_:
			next_mode = "off"
	AppState.set_touch_controls_mode(next_mode)
	_show_warning("TOUCH CONTROLS %s" % next_mode.to_upper(), 0.8)
	_sync_speedbike_touch_controls()


func _toggle_speedbike_touch_screen_only() -> void:
	speedbike_touch_screen_only_mode = not speedbike_touch_screen_only_mode
	_save_speedbike_touch_settings()
	_sync_speedbike_pause_controls()
	_update_hud()


func _toggle_speedbike_touch_autofire() -> void:
	speedbike_touch_autofire_enabled = not speedbike_touch_autofire_enabled
	_save_speedbike_touch_settings()
	_sync_speedbike_pause_controls()


func _toggle_speedbike_touch_layout_edit_mode() -> void:
	speedbike_touch_layout_edit_mode = not speedbike_touch_layout_edit_mode
	speedbike_touch_drag_pointer = -1
	speedbike_touch_drag_id = ""
	speedbike_touch_drag_offset = Vector2.ZERO
	_clear_speedbike_touch_states()
	_sync_speedbike_pause_controls()
	_sync_speedbike_touch_controls()
	if speedbike_touch_layout_edit_mode:
		_show_warning("DRAG TOUCH BUTTONS", 0.9)
	else:
		_save_speedbike_touch_settings()
		_show_warning("TOUCH BUTTONS LOCKED", 0.8)


func _toggle_speedbike_touch_layout_snap() -> void:
	speedbike_touch_layout_snap_enabled = not speedbike_touch_layout_snap_enabled
	_apply_speedbike_mobile_layout()
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		_store_speedbike_touch_button_position(button_id)
	_save_speedbike_touch_settings()
	_sync_speedbike_pause_controls()
	_sync_speedbike_touch_controls()


func _reset_speedbike_touch_layout() -> void:
	speedbike_touch_layout_positions.clear()
	speedbike_touch_drag_pointer = -1
	speedbike_touch_drag_id = ""
	speedbike_touch_drag_offset = Vector2.ZERO
	_clear_speedbike_touch_states()
	_apply_speedbike_mobile_layout()
	_save_speedbike_touch_settings()
	_sync_speedbike_pause_controls()
	_sync_speedbike_touch_controls()
	_show_warning("TOUCH LAYOUT RESET", 0.85)


func _toggle_speedbike_hud_buttons_hidden() -> void:
	speedbike_hud_buttons_hidden = not speedbike_hud_buttons_hidden
	_save_speedbike_touch_settings()
	_sync_speedbike_pause_controls()
	_sync_speedbike_touch_controls()


func _toggle_speedbike_hud_text_hidden() -> void:
	speedbike_hud_text_hidden = not speedbike_hud_text_hidden
	_save_speedbike_touch_settings()
	_update_hud()
	_sync_speedbike_pause_controls()


func _on_speedbike_pause_hud_text_alpha_changed(value: float) -> void:
	if pause_settings_syncing:
		return
	speedbike_hud_text_alpha = clampf(value / 100.0, 0.25, 1.0)
	if pause_hud_text_alpha_value_label != null:
		pause_hud_text_alpha_value_label.text = "%d%%" % int(round(speedbike_hud_text_alpha * 100.0))
	_save_speedbike_touch_settings()
	_update_hud()


func _on_speedbike_pause_master_slider_changed(value: float) -> void:
	if pause_settings_syncing:
		return
	if pause_master_value_label != null:
		pause_master_value_label.text = "%d%%" % int(round(value))
	AppState.set_master_volume(value / 100.0)


func _on_speedbike_pause_music_slider_changed(value: float) -> void:
	if pause_settings_syncing:
		return
	if pause_music_value_label != null:
		pause_music_value_label.text = "%d%%" % int(round(value))
	AppState.set_music_volume(value / 100.0)
	_refresh_speedbike_music_volume()


func _on_speedbike_pause_sfx_slider_changed(value: float) -> void:
	if pause_settings_syncing:
		return
	if pause_sfx_value_label != null:
		pause_sfx_value_label.text = "%d%%" % int(round(value))
	AppState.set_sfx_volume(value / 100.0)
	_refresh_speedbike_sfx_volume()


func _refresh_speedbike_music_volume() -> void:
	if music_player != null:
		var base_db := float(music_player.get_meta("base_volume_db", -9.0))
		music_player.volume_db = _speedbike_music_volume_db(base_db)
	if boss_intro_player != null:
		var intro_base_db := float(boss_intro_player.get_meta("base_volume_db", -6.0))
		boss_intro_player.volume_db = _speedbike_music_volume_db(intro_base_db)
	_refresh_speedbike_sfx_volume()


func _refresh_speedbike_sfx_volume() -> void:
	for player in sfx_pool:
		if player == null:
			continue
		var base_db := float(player.get_meta("base_volume_db", -8.0))
		player.volume_db = _speedbike_sfx_volume_db(base_db)
	if sfx_player != null:
		var fallback_base_db := float(sfx_player.get_meta("base_volume_db", -8.0))
		sfx_player.volume_db = _speedbike_sfx_volume_db(fallback_base_db)
	if boss_laugh_player != null:
		var laugh_base_db := float(boss_laugh_player.get_meta("base_volume_db", 2.0))
		boss_laugh_player.volume_db = _speedbike_sfx_volume_db(laugh_base_db)
	for player in rider_info_audio_players:
		if player != null:
			var rider_base_db := float(player.get_meta("base_volume_db", 10.0))
			player.volume_db = _speedbike_sfx_volume_db(rider_base_db)
	if engine_player != null:
		engine_player.volume_db = _speedbike_sfx_volume_db(engine_volume_target)


func _speedbike_music_volume_db(base_db: float) -> float:
	if AppState.music_volume <= 0.0001:
		return -80.0
	return base_db + linear_to_db(maxf(AppState.music_volume, 0.001))


func _speedbike_sfx_volume_db(base_db: float) -> float:
	if AppState.sfx_volume <= 0.0001:
		return -80.0
	return base_db + linear_to_db(maxf(AppState.sfx_volume, 0.001))


func _handle_speedbike_touch_layout_touch(event: InputEventScreenTouch) -> void:
	if not speedbike_touch_layout_edit_mode:
		return
	if not event.pressed:
		if event.index == speedbike_touch_drag_pointer:
			_store_speedbike_touch_button_position(speedbike_touch_drag_id)
			speedbike_touch_drag_pointer = -1
			speedbike_touch_drag_id = ""
			speedbike_touch_drag_offset = Vector2.ZERO
		return
	var button_id := _speedbike_touch_button_id_from_screen_position(event.position)
	if button_id.is_empty():
		return
	var button := speedbike_touch_buttons.get(button_id) as Button
	if button == null:
		return
	speedbike_touch_drag_pointer = event.index
	speedbike_touch_drag_id = button_id
	speedbike_touch_drag_offset = event.position - button.position


func _handle_speedbike_touch_layout_drag(event: InputEventScreenDrag) -> void:
	if not speedbike_touch_layout_edit_mode or event.index != speedbike_touch_drag_pointer:
		return
	var button := speedbike_touch_buttons.get(speedbike_touch_drag_id) as Button
	if button == null:
		return
	button.position = _clamped_speedbike_touch_position(event.position - speedbike_touch_drag_offset, button.size, get_viewport_rect().size)
	_store_speedbike_touch_button_position(speedbike_touch_drag_id)


func _speedbike_touch_button_id_from_screen_position(screen_position: Vector2) -> String:
	for button_id in SPEEDBIKE_TOUCH_BUTTON_IDS:
		var button := speedbike_touch_buttons.get(button_id) as Button
		if button != null and button.visible and button.get_global_rect().has_point(screen_position):
			return button_id
	return ""


func _setup_boss_dialog_ui() -> void:
	if boss_dialog_panel != null and is_instance_valid(boss_dialog_panel):
		return
	boss_dialog_shade = ColorRect.new()
	boss_dialog_shade.name = "BossDialogShade"
	boss_dialog_shade.process_mode = Node.PROCESS_MODE_ALWAYS
	boss_dialog_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_dialog_shade.color = Color(0.02, 0.01, 0.04, 0.78)
	boss_dialog_shade.visible = false
	hud_layer.add_child(boss_dialog_shade)

	boss_dialog_panel = PanelContainer.new()
	boss_dialog_panel.name = "BossDialogPanel"
	boss_dialog_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	boss_dialog_panel.custom_minimum_size = Vector2(820.0, 300.0)
	boss_dialog_panel.anchor_left = 0.5
	boss_dialog_panel.anchor_top = 0.5
	boss_dialog_panel.anchor_right = 0.5
	boss_dialog_panel.anchor_bottom = 0.5
	boss_dialog_panel.offset_left = -410.0
	boss_dialog_panel.offset_top = -150.0
	boss_dialog_panel.offset_right = 410.0
	boss_dialog_panel.offset_bottom = 150.0
	boss_dialog_panel.visible = false
	boss_dialog_shade.add_child(boss_dialog_panel)

	var dialog_vbox := VBoxContainer.new()
	dialog_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialog_vbox.add_theme_constant_override("separation", 10)
	boss_dialog_panel.add_child(dialog_vbox)

	boss_dialog_title_label = Label.new()
	boss_dialog_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_dialog_title_label.add_theme_font_size_override("font_size", 24)
	dialog_vbox.add_child(boss_dialog_title_label)

	boss_dialog_text_label = RichTextLabel.new()
	boss_dialog_text_label.bbcode_enabled = false
	boss_dialog_text_label.scroll_active = false
	boss_dialog_text_label.fit_content = false
	boss_dialog_text_label.custom_minimum_size = Vector2(0.0, 170.0)
	boss_dialog_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	boss_dialog_text_label.add_theme_font_size_override("normal_font_size", 20)
	dialog_vbox.add_child(boss_dialog_text_label)

	boss_dialog_hint_label = Label.new()
	boss_dialog_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_dialog_hint_label.add_theme_font_size_override("font_size", 15)
	boss_dialog_hint_label.text = "ENTER / A advances  ESC / B skips line"
	dialog_vbox.add_child(boss_dialog_hint_label)

	boss_dialog_continue_button = Button.new()
	boss_dialog_continue_button.text = "CONTINUE"
	boss_dialog_continue_button.focus_mode = Control.FOCUS_ALL
	boss_dialog_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boss_dialog_continue_button.pressed.connect(_advance_boss_dialog)
	dialog_vbox.add_child(boss_dialog_continue_button)


func _setup_merchant_ui() -> void:
	if merchant_shop_panel != null and is_instance_valid(merchant_shop_panel):
		return
	merchant_shop_shade = ColorRect.new()
	merchant_shop_shade.name = "SpeedbikeMerchantShade"
	merchant_shop_shade.process_mode = Node.PROCESS_MODE_ALWAYS
	merchant_shop_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	merchant_shop_shade.color = Color(0.015, 0.012, 0.016, 0.82)
	merchant_shop_shade.visible = false
	hud_layer.add_child(merchant_shop_shade)

	merchant_shop_panel = PanelContainer.new()
	merchant_shop_panel.name = "SpeedbikeMerchantPanel"
	merchant_shop_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	merchant_shop_panel.anchor_left = 0.5
	merchant_shop_panel.anchor_top = 0.5
	merchant_shop_panel.anchor_right = 0.5
	merchant_shop_panel.anchor_bottom = 0.5
	merchant_shop_panel.offset_left = -520.0
	merchant_shop_panel.offset_top = -300.0
	merchant_shop_panel.offset_right = 520.0
	merchant_shop_panel.offset_bottom = 300.0
	merchant_shop_panel.visible = false
	merchant_shop_panel.add_theme_stylebox_override("panel", _merchant_panel_style(Color(0.025, 0.027, 0.032, 0.96), Color(0.92, 0.64, 0.26, 0.72), 2.0))
	merchant_shop_shade.add_child(merchant_shop_panel)

	var panel_margin := MarginContainer.new()
	panel_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_margin.add_theme_constant_override("margin_left", 18)
	panel_margin.add_theme_constant_override("margin_right", 18)
	panel_margin.add_theme_constant_override("margin_top", 14)
	panel_margin.add_theme_constant_override("margin_bottom", 14)
	merchant_shop_panel.add_child(panel_margin)

	var root_hbox := HBoxContainer.new()
	root_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_hbox.add_theme_constant_override("separation", 18)
	panel_margin.add_child(root_hbox)

	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(330.0, 0.0)
	left_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_theme_constant_override("separation", 10)
	root_hbox.add_child(left_column)

	merchant_cat_image = TextureRect.new()
	merchant_cat_image.custom_minimum_size = Vector2(260.0, 148.0)
	merchant_cat_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	merchant_cat_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	merchant_cat_image.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_column.add_child(merchant_cat_image)

	merchant_dialog_label = RichTextLabel.new()
	merchant_dialog_label.bbcode_enabled = false
	merchant_dialog_label.fit_content = false
	merchant_dialog_label.scroll_active = false
	merchant_dialog_label.custom_minimum_size = Vector2(320.0, 210.0)
	merchant_dialog_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	merchant_dialog_label.add_theme_font_size_override("normal_font_size", 19)
	left_column.add_child(merchant_dialog_label)

	merchant_wallet_label = Label.new()
	merchant_wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	merchant_wallet_label.add_theme_font_size_override("font_size", 18)
	left_column.add_child(merchant_wallet_label)

	merchant_status_label = Label.new()
	merchant_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	merchant_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	merchant_status_label.add_theme_font_size_override("font_size", 16)
	left_column.add_child(merchant_status_label)

	var right_column := VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_column.add_theme_constant_override("separation", 10)
	root_hbox.add_child(right_column)

	var title := Label.new()
	title.text = "FLYING MERCHANT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	right_column.add_child(title)

	var tab_row := HBoxContainer.new()
	tab_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_row.add_theme_constant_override("separation", 8)
	right_column.add_child(tab_row)
	for tab_id in ["services", "weapons", "defense"]:
		var tab_button := Button.new()
		tab_button.text = _merchant_tab_label(tab_id)
		tab_button.toggle_mode = true
		tab_button.focus_mode = Control.FOCUS_ALL
		tab_button.custom_minimum_size = Vector2(128.0, 36.0)
		tab_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_merchant_button_style(tab_button)
		tab_button.pressed.connect(func() -> void: _set_merchant_tab(tab_id))
		tab_row.add_child(tab_button)
		merchant_tab_buttons[tab_id] = tab_button

	var qty_row := HBoxContainer.new()
	qty_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qty_row.add_theme_constant_override("separation", 8)
	right_column.add_child(qty_row)

	merchant_quantity_label = Label.new()
	merchant_quantity_label.text = "BUY QTY"
	merchant_quantity_label.custom_minimum_size = Vector2(86.0, 0.0)
	merchant_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	merchant_quantity_label.add_theme_font_size_override("font_size", 14)
	merchant_quantity_label.modulate = Color(0.96, 0.84, 0.58, 0.95)
	qty_row.add_child(merchant_quantity_label)

	for qty in MERCHANT_BUY_QUANTITIES:
		var qty_button := Button.new()
		qty_button.text = "x%d" % qty
		qty_button.toggle_mode = true
		qty_button.focus_mode = Control.FOCUS_ALL
		qty_button.custom_minimum_size = Vector2(70.0, 30.0)
		_apply_merchant_button_style(qty_button)
		qty_button.pressed.connect(func() -> void: _set_merchant_buy_quantity(qty))
		qty_row.add_child(qty_button)
		merchant_quantity_buttons.append(qty_button)

	var max_button := Button.new()
	max_button.text = "MAX"
	max_button.toggle_mode = true
	max_button.focus_mode = Control.FOCUS_ALL
	max_button.custom_minimum_size = Vector2(78.0, 30.0)
	_apply_merchant_button_style(max_button)
	max_button.pressed.connect(func() -> void: _set_merchant_buy_quantity(0))
	qty_row.add_child(max_button)
	merchant_quantity_buttons.append(max_button)

	var item_scroll := ScrollContainer.new()
	item_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	item_scroll.custom_minimum_size = Vector2(0.0, 330.0)
	item_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_column.add_child(item_scroll)

	merchant_item_list = VBoxContainer.new()
	merchant_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	merchant_item_list.add_theme_constant_override("separation", 8)
	item_scroll.add_child(merchant_item_list)
	_set_merchant_tab("services")

	merchant_repair_bar = ProgressBar.new()
	merchant_repair_bar.min_value = 0.0
	merchant_repair_bar.max_value = 1.0
	merchant_repair_bar.value = 0.0
	merchant_repair_bar.show_percentage = false
	merchant_repair_bar.custom_minimum_size = Vector2(0.0, 22.0)
	right_column.add_child(merchant_repair_bar)

	merchant_leave_button = Button.new()
	merchant_leave_button.text = "LEAVE SHOP"
	merchant_leave_button.focus_mode = Control.FOCUS_ALL
	merchant_leave_button.custom_minimum_size = Vector2(220.0, 42.0)
	merchant_leave_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_apply_merchant_button_style(merchant_leave_button)
	merchant_leave_button.pressed.connect(_close_merchant_shop_and_depart)
	right_column.add_child(merchant_leave_button)


func _merchant_item_icon(kind: String) -> Texture2D:
	return _load_texture(str(PICKUP_TEXTURE_PATHS.get(kind, "")))


func _merchant_tab_label(tab_id: String) -> String:
	match tab_id:
		"services":
			return "SERVICES"
		"weapons":
			return "WEAPONS"
		"defense":
			return "DEFENSE"
		_:
			return tab_id.to_upper()


func _merchant_tab_for_item(kind: String) -> String:
	match kind:
		"repair":
			return "services"
		"rapid", "machine", "laser", "fireball", "spread", "rocket":
			return "weapons"
		_:
			return "defense"


func _set_merchant_tab(tab_id: String) -> void:
	merchant_current_tab = tab_id
	merchant_selected_kind = ""
	for key in merchant_tab_buttons.keys():
		var tab_button := merchant_tab_buttons.get(key) as Button
		if tab_button != null:
			tab_button.button_pressed = str(key) == merchant_current_tab
	_populate_merchant_item_list()
	_refresh_merchant_shop_ui()


func _populate_merchant_item_list() -> void:
	if merchant_item_list == null or not is_instance_valid(merchant_item_list):
		return
	for child in merchant_item_list.get_children():
		child.queue_free()
	merchant_item_buttons.clear()
	merchant_item_rows.clear()
	merchant_repair_button = null
	for item in MERCHANT_ITEM_CATALOG:
		var item_kind := str(item.get("kind", ""))
		if _merchant_tab_for_item(item_kind) != merchant_current_tab:
			continue
		merchant_item_list.add_child(_create_merchant_item_row(item))
	if merchant_selected_kind.is_empty() and merchant_item_buttons.size() > 0:
		merchant_selected_kind = str(merchant_item_buttons[0].get_meta("merchant_kind", ""))


func _create_merchant_item_row(item: Dictionary) -> Control:
	var item_kind := str(item.get("kind", ""))
	var item_name := str(item.get("name", item_kind.to_upper()))
	var item_cost := int(item.get("cost", 0))
	var item_desc := str(item.get("description", ""))
	var row_panel := PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0.0, 92.0)
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_panel.set_meta("merchant_kind", item_kind)
	row_panel.add_theme_stylebox_override("panel", _merchant_row_style(false, gold_coins_collected >= item_cost))
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	var row_margin := MarginContainer.new()
	row_margin.add_theme_constant_override("margin_left", 8)
	row_margin.add_theme_constant_override("margin_right", 8)
	row_margin.add_theme_constant_override("margin_top", 6)
	row_margin.add_theme_constant_override("margin_bottom", 6)
	row_panel.add_child(row_margin)
	row_margin.add_child(row)

	var icon_holder := TextureRect.new()
	icon_holder.custom_minimum_size = Vector2(58.0, 58.0)
	icon_holder.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_holder.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_holder.texture = _merchant_item_icon(item_kind)
	row.add_child(icon_holder)

	var info_column := VBoxContainer.new()
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.add_theme_constant_override("separation", 2)
	row.add_child(info_column)

	var name_label := Label.new()
	name_label.text = "%s  -  %d COINS" % [item_name, item_cost]
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.clip_text = true
	info_column.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = item_desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.custom_minimum_size = Vector2(0.0, 34.0)
	info_column.add_child(desc_label)

	var stat_label := Label.new()
	stat_label.text = _merchant_item_stat_line(item_kind)
	stat_label.add_theme_font_size_override("font_size", 12)
	stat_label.modulate = Color(0.78, 0.92, 1.0, 0.92)
	stat_label.clip_text = true
	info_column.add_child(stat_label)

	var action_button := Button.new()
	action_button.focus_mode = Control.FOCUS_ALL
	action_button.custom_minimum_size = Vector2(126.0, 62.0)
	action_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_apply_merchant_button_style(action_button)
	action_button.set_meta("merchant_kind", item_kind)
	_update_merchant_action_button_text(action_button, item)
	action_button.tooltip_text = item_desc
	var bound_kind := item_kind
	action_button.focus_entered.connect(func() -> void: _select_merchant_item(bound_kind))
	action_button.mouse_entered.connect(func() -> void: _select_merchant_item(bound_kind))
	action_button.pressed.connect(func() -> void: _on_merchant_item_pressed(bound_kind))
	row.add_child(action_button)
	merchant_item_buttons.append(action_button)
	merchant_item_rows.append(row_panel)
	if item_kind == "repair":
		merchant_repair_button = action_button
	return row_panel


func _select_merchant_item(kind: String) -> void:
	if merchant_selected_kind == kind:
		return
	merchant_selected_kind = kind
	var item := _merchant_catalog_item(kind)
	if not item.is_empty():
		var item_name := str(item.get("name", kind.to_upper()))
		var item_desc := str(item.get("description", ""))
		merchant_status_label.text = "%s selected. %s" % [item_name, item_desc]
	_refresh_merchant_shop_ui()


func _set_merchant_buy_quantity(quantity: int) -> void:
	merchant_buy_quantity = quantity
	_refresh_merchant_shop_ui()


func _merchant_requested_quantity(kind: String, cost: int) -> int:
	if kind == "repair":
		return 1
	if merchant_buy_quantity > 0:
		return merchant_buy_quantity
	return maxi(int(floor(float(gold_coins_collected) / maxf(float(cost), 1.0))), 1)


func _update_merchant_action_button_text(button: Button, item: Dictionary) -> void:
	var item_kind := str(item.get("kind", ""))
	var item_cost := int(item.get("cost", 0))
	var quantity := _merchant_requested_quantity(item_kind, item_cost)
	var total_cost := item_cost * quantity
	if item_kind == "repair":
		button.text = "REPAIR SHIP\n%d COINS" % item_cost
	else:
		button.text = "BUY x%d\n%d COINS" % [quantity, total_cost]


func _merchant_item_stat_line(kind: String) -> String:
	match kind:
		"repair":
			return "Restores health after a 10 second repair bay sequence."
		"spread":
			return "Limited ammo. Current charges: %d" % (speedbike_weapon_ammo if speedbike_weapon_kind == "spread" else 0)
		"rocket":
			return "Limited ammo. Current rockets: %d" % (speedbike_weapon_ammo if speedbike_weapon_kind == "rocket" else 0)
		"shield":
			return "Crash shields held: %d" % shield_hits
		"purple":
			return "Health slots: %d" % max_hits
		"rapid", "machine", "laser", "fireball":
			return "Equips until replaced or the chapter ends."
		_:
			return "Speedbike upgrade."


func _merchant_catalog_item(kind: String) -> Dictionary:
	for item in MERCHANT_ITEM_CATALOG:
		if str(item.get("kind", "")) == kind:
			return item
	return {}


func _should_show_merchant_stop() -> bool:
	if not _chapter_has_next_stage():
		return false
	if stage_map_id == BOSS_STAGE_ID:
		return false
	var completed_stage := _chapter_stage_number()
	return completed_stage > 0 and completed_stage % MERCHANT_STOP_INTERVAL == 0


func _reset_merchant_state() -> void:
	merchant_state = "none"
	merchant_shop_open = false
	merchant_ship_position = Vector2.ZERO
	merchant_ship_open = true
	merchant_ship_alpha = 0.0
	merchant_beam_strength = 0.0
	merchant_timer = 0.0
	merchant_pending_next_stage = false
	merchant_repairing = false
	merchant_repair_timer = 0.0
	merchant_dialog_full_text = ""
	merchant_dialog_visible_chars = 0
	merchant_dialog_reveal_progress = 0.0
	merchant_dialog_sound_timer = 0.0
	if merchant_shop_shade != null and is_instance_valid(merchant_shop_shade):
		merchant_shop_shade.visible = false
	if merchant_shop_panel != null and is_instance_valid(merchant_shop_panel):
		merchant_shop_panel.visible = false
	if player_speedbike != null and is_instance_valid(player_speedbike):
		player_speedbike.visible = true


func _begin_merchant_transition(next_label: String) -> void:
	chapter_transition_timer = -1.0
	merchant_pending_next_stage = true
	merchant_state = "approach"
	merchant_shop_open = false
	merchant_ship_open = true
	merchant_ship_alpha = 0.0
	merchant_beam_strength = 0.0
	merchant_timer = 0.0
	merchant_ship_position = Vector2(_camera_right() + 440.0, speedbike_lane_y(2) - 86.0)
	player_speedbike.set_control_locked(true)
	player_speedbike.set_crashed(false)
	player_speedbike.visible = true
	warning_text = "MERCHANT SIGNAL"
	warning_text_timer = 1.5
	tip_text = "CAT CREW INBOUND  CLEAR SKIES UNTIL %s" % next_label
	_play_sfx(MERCHANT_LIFTOFF_SOUND_PATH, -7.0, 0.96)


func _tick_merchant_transition(delta: float) -> void:
	if merchant_state == "none":
		return
	if merchant_shop_open:
		return
	merchant_timer += delta
	var ship_center := Vector2(_camera_left() + screen_size.x * 0.64, speedbike_lane_y(2) - 88.0)
	var hatch_position := merchant_ship_position + Vector2(-114.0, 52.0)
	match merchant_state:
		"approach":
			merchant_ship_alpha = clampf(merchant_ship_alpha + delta * 1.7, 0.0, 1.0)
			merchant_ship_position = merchant_ship_position.lerp(ship_center, clampf(delta * 2.0, 0.0, 1.0))
			player_speedbike.tick(delta, _camera_left(), camera_scroll_speed * 0.22)
			if merchant_ship_position.distance_to(ship_center) < 18.0 or merchant_timer >= 2.4:
				merchant_state = "beam_in"
				merchant_timer = 0.0
				merchant_beam_strength = 0.0
				_play_sfx(WARNING_SOUND_PATH, -12.0, 1.22)
		"beam_in":
			merchant_beam_strength = clampf(sin(clampf(merchant_timer / 1.35, 0.0, 1.0) * PI), 0.0, 1.0)
			player_speedbike.position = player_speedbike.position.lerp(hatch_position, clampf(delta * 3.2, 0.0, 1.0))
			if merchant_timer >= 1.35:
				player_speedbike.visible = false
				merchant_ship_open = false
				merchant_beam_strength = 0.0
				merchant_state = "shop_depart"
				merchant_timer = 0.0
				_play_sfx(MERCHANT_TAKEOFF_SOUND_PATH, -6.0, 1.0)
		"shop_depart":
			merchant_ship_position.x += 760.0 * delta
			merchant_ship_alpha = clampf(merchant_ship_alpha - delta * 0.35, 0.0, 1.0)
			if merchant_ship_position.x > _camera_right() + 560.0 or merchant_timer >= 1.25:
				_open_merchant_shop()
		"dropoff_arrive":
			merchant_ship_open = false
			merchant_ship_alpha = clampf(merchant_ship_alpha + delta * 1.6, 0.0, 1.0)
			merchant_ship_position = merchant_ship_position.lerp(ship_center, clampf(delta * 2.3, 0.0, 1.0))
			if merchant_ship_position.distance_to(ship_center) < 20.0 or merchant_timer >= 2.0:
				merchant_state = "dropoff_beam"
				merchant_ship_open = true
				merchant_timer = 0.0
				merchant_beam_strength = 0.0
				player_speedbike.visible = true
				player_speedbike.position = hatch_position
				_play_sfx(WARNING_SOUND_PATH, -13.0, 1.18)
		"dropoff_beam":
			merchant_beam_strength = clampf(sin(clampf(merchant_timer / 1.25, 0.0, 1.0) * PI), 0.0, 1.0)
			var return_y := clampf(stage_chain_carry_player_y, speedbike_top_bound(), speedbike_bottom_bound())
			var return_x := _camera_left() + clampf(stage_chain_carry_player_x_offset, 140.0, screen_size.x - 160.0)
			player_speedbike.position = player_speedbike.position.lerp(Vector2(return_x, return_y), clampf(delta * 3.0, 0.0, 1.0))
			if merchant_timer >= 1.25:
				merchant_ship_open = false
				merchant_beam_strength = 0.0
				merchant_state = "exit"
				merchant_timer = 0.0
				_play_sfx(MERCHANT_TAKEOFF_SOUND_PATH, -6.0, 1.04)
		"exit":
			merchant_ship_position.x += 820.0 * delta
			merchant_ship_alpha = clampf(merchant_ship_alpha - delta * 0.75, 0.0, 1.0)
			if merchant_ship_position.x > _camera_right() + 620.0 or merchant_timer >= 1.2:
				merchant_state = "none"
				merchant_pending_next_stage = false
				merchant_ship_alpha = 0.0
				merchant_beam_strength = 0.0
				player_speedbike.visible = true
				_advance_to_next_stage()


func _open_merchant_shop() -> void:
	merchant_state = "shop"
	merchant_shop_open = true
	merchant_ship_alpha = 0.0
	merchant_beam_strength = 0.0
	if merchant_shop_shade != null and is_instance_valid(merchant_shop_shade):
		merchant_shop_shade.visible = true
	if merchant_shop_panel != null and is_instance_valid(merchant_shop_panel):
		merchant_shop_panel.visible = true
	merchant_cat_idle_texture = _load_texture(MERCHANT_CAT_IDLE_PATH)
	merchant_cat_repair_texture = _load_texture(MERCHANT_CAT_REPAIR_PATH)
	merchant_cat_finished_texture = _load_texture(MERCHANT_CAT_FINISHED_PATH)
	if merchant_cat_image != null:
		merchant_cat_image.texture = merchant_cat_idle_texture
	merchant_repairing = false
	merchant_repair_timer = 0.0
	if merchant_repair_bar != null:
		merchant_repair_bar.value = 0.0
	if merchant_status_label != null:
		merchant_status_label.text = ""
	_set_merchant_tab("services")
	_merchant_set_dialog("Welcome aboard, rider. We patched this junker out of scrap, prayer, and questionable cat math. Spend gold coins to repair, reload, or stack limited weapon packs before the tunnel bites back.")
	if merchant_item_buttons.size() > 0:
		merchant_item_buttons[0].grab_focus()


func _refresh_merchant_shop_ui() -> void:
	if merchant_wallet_label != null:
		merchant_wallet_label.text = "GOLD COINS: %d" % gold_coins_collected
	if merchant_status_label != null and merchant_status_label.text.is_empty():
		merchant_status_label.text = "Choose a service. Repairs restore the health bar; rockets and scatter packs stack charges."
	for qty_button in merchant_quantity_buttons:
		if qty_button == null:
			continue
		var qty_text := qty_button.text
		var active := (qty_text == "MAX" and merchant_buy_quantity == 0) or (qty_text.begins_with("x") and int(qty_text.substr(1)) == merchant_buy_quantity)
		qty_button.button_pressed = active
		qty_button.disabled = merchant_repairing
	for button in merchant_item_buttons:
		if button == null:
			continue
		var kind := str(button.get_meta("merchant_kind", ""))
		var item := _merchant_catalog_item(kind)
		var cost := int(item.get("cost", 0))
		var quantity := _merchant_requested_quantity(kind, cost)
		var total_cost := cost * quantity
		_update_merchant_action_button_text(button, item)
		button.disabled = merchant_repairing or gold_coins_collected < total_cost or (kind == "repair" and remaining_hits >= max_hits)
		button.modulate = Color(1.0, 0.92, 0.64, 1.0) if kind == merchant_selected_kind else Color(1.0, 1.0, 1.0, 1.0)
	for row_panel in merchant_item_rows:
		if row_panel == null:
			continue
		var row_kind := str(row_panel.get_meta("merchant_kind", ""))
		var row_item := _merchant_catalog_item(row_kind)
		var row_cost := int(row_item.get("cost", 0))
		var row_quantity := _merchant_requested_quantity(row_kind, row_cost)
		var row_affordable := gold_coins_collected >= row_cost * row_quantity
		row_panel.add_theme_stylebox_override("panel", _merchant_row_style(row_kind == merchant_selected_kind, row_affordable))
	for tab_button_value in merchant_tab_buttons.values():
		var tab_button := tab_button_value as Button
		if tab_button != null:
			tab_button.disabled = merchant_repairing
			tab_button.modulate = Color(1.0, 0.84, 0.48, 1.0) if tab_button.button_pressed else Color(0.84, 0.90, 1.0, 0.92)
	if merchant_leave_button != null:
		merchant_leave_button.disabled = merchant_repairing


func _merchant_set_dialog(text: String) -> void:
	merchant_dialog_full_text = text
	merchant_dialog_visible_chars = 0
	merchant_dialog_reveal_progress = 0.0
	merchant_dialog_sound_timer = 0.0
	if merchant_dialog_label != null:
		merchant_dialog_label.text = merchant_dialog_full_text
		merchant_dialog_label.visible_characters = 0


func _update_merchant_shop(delta: float) -> void:
	if not merchant_shop_open:
		return
	var pulse := 0.82 + sin(Time.get_ticks_msec() / 1000.0 * 5.8) * 0.18
	for button in merchant_item_buttons:
		if button != null and button.has_focus():
			button.modulate = Color(1.0, 0.86 + pulse * 0.10, 0.48, 1.0)
	for qty_button in merchant_quantity_buttons:
		if qty_button != null and qty_button.button_pressed:
			qty_button.modulate = Color(1.0, 0.78 + pulse * 0.12, 0.34, 1.0)
	merchant_dialog_sound_timer = maxf(merchant_dialog_sound_timer - delta, 0.0)
	if merchant_dialog_visible_chars < merchant_dialog_full_text.length():
		merchant_dialog_reveal_progress += delta * MERCHANT_TYPEWRITER_CHARS_PER_SECOND
		var next_chars := mini(merchant_dialog_full_text.length(), int(floor(merchant_dialog_reveal_progress)))
		if next_chars > merchant_dialog_visible_chars:
			_play_merchant_typewriter_sounds(merchant_dialog_visible_chars, next_chars)
			merchant_dialog_visible_chars = next_chars
			if merchant_dialog_label != null:
				merchant_dialog_label.visible_characters = merchant_dialog_visible_chars
	if merchant_repairing:
		merchant_repair_timer = minf(merchant_repair_timer + delta, MERCHANT_REPAIR_DURATION)
		if merchant_repair_bar != null:
			merchant_repair_bar.value = merchant_repair_timer / MERCHANT_REPAIR_DURATION
		if merchant_repair_timer >= MERCHANT_REPAIR_DURATION:
			merchant_repairing = false
			remaining_hits = max_hits
			if merchant_cat_image != null:
				merchant_cat_image.texture = merchant_cat_finished_texture
			if merchant_status_label != null:
				merchant_status_label.text = "Repair complete. Health restored."
			_merchant_set_dialog("All patched up. The frame is straight, the coils are singing, and the hatch only smells like ozone a little bit.")
			_play_sfx(PICKUP_SOUND_PATH, -4.0, 1.08)
			_refresh_merchant_shop_ui()
	_update_hud()


func _play_merchant_typewriter_sounds(from_char: int, to_char: int) -> void:
	for char_index in range(from_char, to_char):
		if char_index < 0 or char_index >= merchant_dialog_full_text.length():
			continue
		if merchant_dialog_full_text.substr(char_index, 1).strip_edges().is_empty():
			continue
		if merchant_dialog_sound_timer > 0.0:
			continue
		merchant_dialog_sound_timer = RIDER_TYPEWRITER_SOUND_COOLDOWN
		_play_rider_typewriter_tick()


func _on_merchant_item_pressed(kind: String) -> void:
	merchant_selected_kind = kind
	if merchant_repairing:
		if merchant_status_label != null:
			merchant_status_label.text = "Repair crew is still working."
		return
	var item := _merchant_catalog_item(kind)
	if item.is_empty():
		return
	var cost := int(item.get("cost", 0))
	var item_name := str(item.get("name", kind.to_upper()))
	var quantity := _merchant_requested_quantity(kind, cost)
	var total_cost := cost * quantity
	if gold_coins_collected < total_cost:
		if merchant_status_label != null:
			merchant_status_label.text = "Need %d gold coins for %s." % [total_cost, item_name]
		_play_sfx(WARNING_SOUND_PATH, -14.0, 0.78)
		return
	if kind == "repair":
		if remaining_hits >= max_hits:
			if merchant_status_label != null:
				merchant_status_label.text = "Hull is already at full health."
			_play_sfx(WARNING_SOUND_PATH, -15.0, 0.72)
			return
		gold_coins_collected -= cost
		_start_merchant_repair()
		return
	gold_coins_collected -= total_cost
	for buy_index in range(quantity):
		match kind:
			"rapid", "machine", "laser", "fireball", "spread", "rocket":
				_grant_speedbike_shop_weapon(kind)
			"shield":
				shield_hits += 1
			"purple":
				speedbike_bonus_health_slots += 1
				max_hits += 1
				remaining_hits = mini(remaining_hits + 1, max_hits)
			_:
				_apply_pickup(kind)
	if merchant_status_label != null:
		merchant_status_label.text = "%s loaded%s." % [item_name, " x%d" % quantity if quantity > 1 else ""]
	_merchant_set_dialog("%s is yours%s. Keep it smooth, keep it fast, and do not argue with the walls." % [item_name, " times %d" % quantity if quantity > 1 else ""])
	_play_sfx(PICKUP_SOUND_PATH, -7.0, 1.02)
	_populate_merchant_item_list()
	_refresh_merchant_shop_ui()


func _start_merchant_repair() -> void:
	merchant_repairing = true
	merchant_repair_timer = 0.0
	if merchant_repair_bar != null:
		merchant_repair_bar.value = 0.0
	if merchant_cat_image != null:
		merchant_cat_image.texture = merchant_cat_repair_texture
	if merchant_status_label != null:
		merchant_status_label.text = "Repairing hull..."
	_merchant_set_dialog("Hold still. We are welding, singing, and pretending that last scorch mark was already there.")
	_play_sfx(MERCHANT_REPAIR_SOUND_PATH, -3.0, 1.0)
	_refresh_merchant_shop_ui()


func _grant_speedbike_shop_weapon(kind: String) -> void:
	if SPEEDBIKE_LIMITED_WEAPON_AMMO.has(kind) and speedbike_weapon_kind == kind and speedbike_weapon_ammo > 0:
		speedbike_weapon_ammo += int(SPEEDBIKE_LIMITED_WEAPON_AMMO.get(kind, 0))
		speedbike_weapon_timer = SPEEDBIKE_WEAPON_PERSIST_TIME
		_refresh_speedbike_weapon_controller_boost()
		return
	_activate_speedbike_weapon(kind, SPEEDBIKE_WEAPON_PERSIST_TIME)


func _merchant_panel_style(bg: Color, border: Color, border_width: float = 1.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(int(border_width))
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.46)
	style.shadow_size = 10
	return style


func _merchant_row_style(selected: bool, affordable: bool) -> StyleBoxFlat:
	var bg := Color(0.06, 0.065, 0.075, 0.88)
	var border := Color(0.32, 0.38, 0.46, 0.58)
	var width := 1.0
	if selected:
		bg = Color(0.12, 0.095, 0.045, 0.95)
		border = Color(1.0, 0.72, 0.26, 0.92)
		width = 2.0
	elif not affordable:
		bg = Color(0.045, 0.04, 0.045, 0.78)
		border = Color(0.48, 0.16, 0.14, 0.50)
	return _merchant_panel_style(bg, border, width)


func _apply_merchant_button_style(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", _merchant_panel_style(Color(0.07, 0.085, 0.10, 0.94), Color(0.42, 0.50, 0.58, 0.62), 1.0))
	button.add_theme_stylebox_override("hover", _merchant_panel_style(Color(0.12, 0.13, 0.12, 0.98), Color(1.0, 0.78, 0.32, 0.92), 2.0))
	button.add_theme_stylebox_override("focus", _merchant_panel_style(Color(0.12, 0.10, 0.055, 0.98), Color(1.0, 0.86, 0.36, 1.0), 2.0))
	button.add_theme_stylebox_override("pressed", _merchant_panel_style(Color(0.18, 0.12, 0.045, 0.98), Color(1.0, 0.58, 0.16, 1.0), 2.0))
	button.add_theme_stylebox_override("disabled", _merchant_panel_style(Color(0.035, 0.037, 0.042, 0.72), Color(0.22, 0.22, 0.24, 0.42), 1.0))


func _close_merchant_shop_and_depart() -> void:
	if merchant_repairing:
		if merchant_status_label != null:
			merchant_status_label.text = "Repair crew is still working."
		return
	merchant_shop_open = false
	if merchant_shop_shade != null and is_instance_valid(merchant_shop_shade):
		merchant_shop_shade.visible = false
	if merchant_shop_panel != null and is_instance_valid(merchant_shop_panel):
		merchant_shop_panel.visible = false
	merchant_state = "dropoff_arrive"
	merchant_timer = 0.0
	merchant_ship_alpha = 0.0
	merchant_ship_open = false
	merchant_beam_strength = 0.0
	merchant_ship_position = Vector2(_camera_left() - 440.0, speedbike_lane_y(2) - 88.0)
	player_speedbike.visible = false
	player_speedbike.set_control_locked(true)
	_play_sfx(MERCHANT_LIFTOFF_SOUND_PATH, -7.0, 0.98)


func _connect_buttons() -> void:
	if not player_speedbike.shot_fired.is_connected(_on_speedbike_shot_fired):
		player_speedbike.shot_fired.connect(_on_speedbike_shot_fired)
	character_female_button.pressed.connect(func() -> void: _set_speedbike_rider("female"))
	character_gunner_button.pressed.connect(func() -> void: _set_speedbike_rider("gunner"))
	character_scout_button.pressed.connect(func() -> void: _set_speedbike_rider("scout"))
	character_deploy_button.pressed.connect(_deploy_selected_rider)
	character_return_button.pressed.connect(_return_to_war_room)
	pause_resume_button.pressed.connect(_resume_from_pause)
	pause_restart_button.pressed.connect(_restart_from_checkpoint)
	pause_return_button.pressed.connect(_exit_to_emulationstation)
	result_continue_button.pressed.connect(_on_results_continue_pressed)
	result_return_button.pressed.connect(_return_to_war_room)


func _setup_mode_context() -> void:
	story_route = PlayState.is_story_mode() and str(PlayState.current_campaign_id) == "operation_badlands_speedbike"
	stage_map_id = str(PlayState.current_map_id if story_route else PlayState.skirmish_map_id)
	if not SPEEDBIKE_STAGE_FILES.has(stage_map_id):
		stage_map_id = DEFAULT_STAGE_ID
	chapter_start_stage_id = stage_map_id
	if story_route:
		difficulty_row = SPEEDBIKE_DIFFICULTY_DEFAULT.duplicate(true)
		practice_mode = false
		checkpoints_enabled = bool(PlayState.speedbike_checkpoints_enabled)
		speed_multiplier = 1.0
	else:
		if PlayState.has_method("speedbike_difficulty"):
			difficulty_row = PlayState.speedbike_difficulty()
		else:
			difficulty_row = SPEEDBIKE_DIFFICULTY_DEFAULT.duplicate(true)
		practice_mode = bool(PlayState.speedbike_practice_mode)
		checkpoints_enabled = bool(PlayState.speedbike_checkpoints_enabled)
		speed_multiplier = float(PlayState.speedbike_speed_multiplier)
	selected_rider_id = str(PlayState.speedbike_rider_id).strip_edges().to_lower()
	if not RIDER_DEFS.has(selected_rider_id):
		selected_rider_id = "female"
	max_hits = maxi(int(difficulty_row.get("hits", 1)), 1)
	remaining_hits = max_hits
	_build_stage_sequence()
	_sync_active_stage_state()


func _build_stage_sequence() -> void:
	chapter_stage_ids.clear()
	if PlayState != null and PlayState.BADLANDS_SPEEDBIKE_STAGE_IDS is Array:
		for entry in PlayState.BADLANDS_SPEEDBIKE_STAGE_IDS:
			var stage_id := str(entry)
			if SPEEDBIKE_STAGE_FILES.has(stage_id):
				chapter_stage_ids.append(stage_id)
	if chapter_stage_ids.is_empty():
		chapter_stage_ids = [
			"badlands_speedbike_01",
			"badlands_speedbike_02",
			"badlands_speedbike_03",
			"badlands_speedbike_04",
			"badlands_speedbike_05",
			"badlands_speedbike_06",
			"badlands_speedbike_07",
			"badlands_speedbike_08",
			"badlands_speedbike_09",
			"badlands_speedbike_10",
			"badlands_speedbike_11",
			"badlands_speedbike_12",
			"badlands_speedbike_13",
			"badlands_speedbike_14",
			"badlands_speedbike_15",
			"badlands_speedbike_16",
			"badlands_speedbike_17",
			"badlands_speedbike_18",
			"badlands_speedbike_19",
			"badlands_speedbike_20",
			"badlands_speedbike_21",
			"badlands_speedbike_22",
			"badlands_speedbike_23",
			"badlands_speedbike_24",
			"badlands_speedbike_25",
			"badlands_speedbike_26",
			"badlands_speedbike_27",
			"badlands_speedbike_28",
			"badlands_speedbike_29",
			"badlands_speedbike_30",
			"badlands_speedbike_31",
			"badlands_speedbike_32",
			"badlands_speedbike_33",
			"badlands_speedbike_34",
			"badlands_speedbike_35",
			"badlands_speedbike_36",
			"badlands_speedbike_37",
			"badlands_speedbike_38",
			"badlands_speedbike_39",
			"badlands_speedbike_40"
		]
	chapter_stage_index = maxi(chapter_stage_ids.find(stage_map_id), 0)
	stage_map_id = chapter_stage_ids[chapter_stage_index]
	chapter_target_duration = 0.0
	for stage_offset in range(chapter_stage_index, chapter_stage_ids.size()):
		chapter_target_duration += _stage_duration_for_id(chapter_stage_ids[stage_offset])


func _stage_duration_for_id(stage_id: String) -> float:
	var stage_path := str(SPEEDBIKE_STAGE_FILES.get(stage_id, ""))
	if stage_path.is_empty() or not FileAccess.file_exists(stage_path):
		return 24.0
	var raw := FileAccess.get_file_as_string(stage_path)
	var parsed: Variant = JSON.parse_string(raw)
	if parsed is Dictionary:
		return maxf(float((parsed as Dictionary).get("duration", 24.0)), 8.0)
	return 24.0


func _chapter_stage_number() -> int:
	return clampi(chapter_stage_index + 1, 1, maxi(chapter_stage_ids.size(), 1))


func _chapter_stage_total() -> int:
	return maxi(chapter_stage_ids.size(), 1)


func _chapter_has_next_stage() -> bool:
	return chapter_stage_index >= 0 and chapter_stage_index < chapter_stage_ids.size() - 1


func _next_chapter_stage_id() -> String:
	if not _chapter_has_next_stage():
		return ""
	return str(chapter_stage_ids[chapter_stage_index + 1])


func _stage_display_label(stage_id: String) -> String:
	if PlayState != null and PlayState.has_method("speedbike_stage_label"):
		return str(PlayState.speedbike_stage_label(stage_id))
	var fallback_labels := {
		"badlands_speedbike_01": "Stage 1: Ignition Run",
		"badlands_speedbike_02": "Stage 2: White-Knuckle Gates",
		"badlands_speedbike_03": "Stage 3: Dropper Drone Alley",
		"badlands_speedbike_04": "Stage 4: Blackout Tube",
		"badlands_speedbike_05": "Stage 5: Pulse Grid",
		"badlands_speedbike_06": "Stage 6: Minefield Rush",
		"badlands_speedbike_07": "Stage 7: Split-Shaft Switchback",
		"badlands_speedbike_08": "Stage 8: Signal Surge",
		"badlands_speedbike_09": "Stage 9: Overdrive No-Brake",
		"badlands_speedbike_10": "Stage 10: Tunnel Collapse",
		"badlands_speedbike_11": "Stage 11: Shatterline Reactor",
		"badlands_speedbike_12": "Stage 12: Killswitch Narrows",
		"badlands_speedbike_13": "Stage 13: Razorfall Relay",
		"badlands_speedbike_14": "Stage 14: Headlight Grave",
		"badlands_speedbike_15": "Stage 15: Burnwall Array",
		"badlands_speedbike_16": "Stage 16: Crossfire Maw",
		"badlands_speedbike_17": "Stage 17: Dead Rail Fracture",
		"badlands_speedbike_18": "Stage 18: Signal Ruin",
		"badlands_speedbike_19": "Stage 19: Zero Mercy Grid",
		"badlands_speedbike_20": "Stage 20: Blaufall Escape",
		"badlands_speedbike_21": "Stage 21: Curvebreak Causeway",
		"badlands_speedbike_22": "Stage 22: Canyon Slalom",
		"badlands_speedbike_23": "Stage 23: Sawtooth Overpass",
		"badlands_speedbike_24": "Stage 24: Dustcoil Drop",
		"badlands_speedbike_25": "Stage 25: Mirror Road",
		"badlands_speedbike_26": "Stage 26: Railstorm S-Bend",
		"badlands_speedbike_27": "Stage 27: Deadman's Switch",
		"badlands_speedbike_28": "Stage 28: Afterburn Corkscrew",
		"badlands_speedbike_29": "Stage 29: Blacktop Needle",
		"badlands_speedbike_30": "Stage 30: Windscar Finale",
		"badlands_speedbike_31": "Stage 31: Orbit Grave",
		"badlands_speedbike_32": "Stage 32: Asteroid Keyhole",
		"badlands_speedbike_33": "Stage 33: Satellite Skein",
		"badlands_speedbike_34": "Stage 34: Nebula Razor",
		"badlands_speedbike_35": "Stage 35: Comet Split",
		"badlands_speedbike_36": "Stage 36: Void Mine Waltz",
		"badlands_speedbike_37": "Stage 37: Gravity Lens",
		"badlands_speedbike_38": "Stage 38: Starfall Chicane",
		"badlands_speedbike_39": "Stage 39: Event Horizon Run",
		"badlands_speedbike_40": "Stage 40: Beldar's Last Tunnel"
	}
	return str(fallback_labels.get(stage_id, stage_id))


func _sync_active_stage_state() -> void:
	if PlayState == null:
		return
	if story_route:
		PlayState.current_map_id = stage_map_id
		PlayState.current_segment_index = chapter_stage_index
	else:
		PlayState.skirmish_map_id = stage_map_id
		PlayState.current_map_id = stage_map_id
	PlayState.flush_progress()


func _create_runtime_helpers() -> void:
	obstacle_spawner = load("res://scripts/speedbike/SpeedbikeObstacleSpawner.gd").new()
	add_child(obstacle_spawner)
	obstacle_spawner.configure(self)
	pattern_runner = load("res://scripts/speedbike/SpeedbikePatternRunner.gd").new()
	add_child(pattern_runner)


func _load_stage_payload() -> void:
	stage_data.clear()
	var stage_path := str(SPEEDBIKE_STAGE_FILES.get(stage_map_id, SPEEDBIKE_STAGE_FILES[DEFAULT_STAGE_ID]))
	if FileAccess.file_exists(stage_path):
		var raw := FileAccess.get_file_as_string(stage_path)
		var parsed: Variant = JSON.parse_string(raw)
		if parsed is Dictionary:
			stage_data = (parsed as Dictionary).duplicate(true)
	if stage_data.is_empty():
		stage_data = {
			"display_name": "Ignition Run",
			"music": "speedbike_desert",
			"background": "badlands_tunnel",
			"base_speed": 420.0,
			"speed_ramp": 4.0,
			"duration": 24.0,
			"patterns": []
		}
	stage_name = str(stage_data.get("display_name", "Ignition Run")).to_upper()
	stage_theme = str(stage_data.get("background", "badlands_tunnel"))
	stage_visual_mode = str(stage_data.get("visual_mode", "tunnel"))
	stage_curve_strength = clampf(float(stage_data.get("road_curve_strength", 1.0)), 0.2, 2.4)
	music_key = str(stage_data.get("music", "speedbike_desert"))
	stage_duration = maxf(float(stage_data.get("duration", 24.0)), 8.0)
	stage_base_speed = float(stage_data.get("base_speed", 420.0))
	stage_speed_ramp = float(stage_data.get("speed_ramp", 0.0))
	boss_texture = _load_texture(BOSS_TEXTURE_PATH)
	boss_minion_texture = _load_texture(BOSS_MINION_TEXTURE_PATH)
	_reset_boss_state()
	pattern_runner.configure(self, obstacle_spawner, stage_data)
	_start_music()


func _open_character_select() -> void:
	selection_open = true
	selection_preview_time = 0.0
	stage_started = false
	stage_cleared = false
	pause_open = false
	speedbike_touch_layout_edit_mode = false
	_clear_speedbike_touch_states()
	character_select_shade.visible = true
	character_select_panel.visible = true
	pause_panel.visible = false
	result_panel.visible = false
	player_speedbike.set_control_locked(true)
	player_speedbike.reset_for_stage(_camera_left(), speedbike_lane_y(2))
	player_speedbike.configure_play_window(_camera_left(), speedbike_top_bound(), speedbike_bottom_bound())
	_stop_carryover_music()
	_start_music(true)
	_set_speedbike_rider(selected_rider_id)
	_focus_selected_rider_button()
	_sync_speedbike_touch_controls()
	_update_hud()


func _focus_selected_rider_button() -> void:
	match selected_rider_id:
		"gunner":
			character_gunner_button.grab_focus()
		"scout":
			character_scout_button.grab_focus()
		_:
			character_female_button.grab_focus()


func _selected_rider_def() -> Dictionary:
	var rider_def: Dictionary = RIDER_DEFS.get(selected_rider_id, RIDER_DEFS["female"])
	return rider_def.duplicate(true)


func _set_speedbike_rider(rider_id: String) -> void:
	selected_rider_id = rider_id if RIDER_DEFS.has(rider_id) else "female"
	var rider_def := _selected_rider_def()
	character_selected_name.text = str(rider_def.get("label", "Engineer (Female)")).to_upper()
	character_selected_stats.text = _speedbike_rider_summary_text(rider_def)
	character_preview_name.text = ""
	character_preview_image.texture = _load_texture(str(rider_def.get("ride_path", "")))
	character_preview_image.position = selection_preview_base_position
	character_preview_image.rotation = 0.0
	_begin_rider_info_typewriter(_speedbike_rider_detail_text(rider_def))
	character_female_button.text = "ENGINEER (FEMALE)" + ("  [SELECTED]" if selected_rider_id == "female" else "")
	character_gunner_button.text = "GUNNER" + ("  [SELECTED]" if selected_rider_id == "gunner" else "")
	character_scout_button.text = "SCOUT" + ("  [SELECTED]" if selected_rider_id == "scout" else "")


func _speedbike_rider_summary_text(rider_def: Dictionary) -> String:
	var stats: Dictionary = rider_def.get("stats", {})
	var handle_rating := int(stats.get("handle", 3))
	var jump_rating := int(stats.get("jump", 3))
	var cannon_rating := int(stats.get("cannon", 3))
	var armor_rating := int(stats.get("armor", 3))
	return "[b]HANDLE[/b]   %d / 5\n[b]JUMP[/b]   %d / 5\n[b]CANNON[/b]   %d / 5\n[b]ARMOR[/b]   %d / 5" % [
		handle_rating,
		jump_rating,
		cannon_rating,
		armor_rating
	]


func _speedbike_rider_detail_text(rider_def: Dictionary) -> String:
	var description := str(rider_def.get("description", "Balanced speedbike rider."))
	var stats: Dictionary = rider_def.get("stats", {})
	var handle_rating := int(stats.get("handle", 3))
	var jump_rating := int(stats.get("jump", 3))
	var cannon_rating := int(stats.get("cannon", 3))
	var armor_rating := int(stats.get("armor", 3))
	var field_notes := "Balanced thrust curve and reliable landing window."
	var run_profile := "This rider keeps the tunnel line steady and gives you a dependable read on jump timing."
	var tactical_use := "Use this rider to learn a stage, then tighten your route once the obstacle rhythm starts living in your hands."
	if selected_rider_id == "gunner":
		field_notes = "Heavy chassis. Strongest cannon bite, but it leans harder in tight tunnel switches."
		run_profile = "Momentum carries deeper before each correction, but the cannon can tear weak-point walls apart once you line up the mark."
		tactical_use = "Best choice when the run mixes drones, blast walls, and late panic shots in narrow space."
	elif selected_rider_id == "scout":
		field_notes = "Lightest profile. Reads lanes fast and hangs in the air longer over bad gaps."
		run_profile = "Quick lane changes and a cleaner jump arc make the scout bike better at recovering from late reads."
		tactical_use = "Best choice for pit chains, lane swaps, and sections where survival depends on staying light."
	var performance_note := "Control balance: handle %d, jump %d, cannon %d, armor %d." % [handle_rating, jump_rating, cannon_rating, armor_rating]
	return "%s\n\n%s\n\nRUN PROFILE\n%s\n\nTACTICAL USE\n%s\n\n%s" % [
		description,
		field_notes,
		run_profile,
		tactical_use,
		performance_note
	]


func _begin_rider_info_typewriter(text: String) -> void:
	rider_info_full_text = text
	rider_info_visible_chars = 0
	rider_info_reveal_progress = 0.0
	rider_info_sound_timer = 0.0
	character_stats_label.bbcode_enabled = false
	character_stats_label.text = rider_info_full_text
	character_stats_label.visible_characters = 0
	character_stats_scroll.scroll_vertical = 0


func _update_rider_select_presentation(delta: float) -> void:
	selection_preview_time += delta
	var hover_wave := sin(selection_preview_time * 1.8)
	character_preview_image.position = selection_preview_base_position + Vector2(0.0, hover_wave * 8.0)
	character_preview_image.rotation = hover_wave * 0.018
	rider_info_sound_timer = maxf(rider_info_sound_timer - delta, 0.0)
	if rider_info_visible_chars >= rider_info_full_text.length():
		return
	rider_info_reveal_progress += delta * RIDER_TYPEWRITER_CHARS_PER_SECOND
	var next_chars := mini(rider_info_full_text.length(), int(floor(rider_info_reveal_progress)))
	if next_chars <= rider_info_visible_chars:
		return
	_play_typewriter_reveal_sounds(rider_info_full_text, rider_info_visible_chars, next_chars)
	rider_info_visible_chars = next_chars
	character_stats_label.visible_characters = rider_info_visible_chars


func _play_typewriter_reveal_sounds(source_text: String, from_char: int, to_char: int) -> void:
	var revealed_since_tick := 0
	for char_index in range(from_char, to_char):
		if char_index < 0 or char_index >= source_text.length():
			continue
		var glyph := source_text.substr(char_index, 1)
		if glyph.strip_edges().is_empty():
			continue
		revealed_since_tick += 1
		if revealed_since_tick < RIDER_TYPEWRITER_SOUND_STEP:
			continue
		if rider_info_sound_timer > 0.0:
			continue
		revealed_since_tick = 0
		rider_info_sound_timer = RIDER_TYPEWRITER_SOUND_COOLDOWN
		_play_rider_typewriter_tick()


func _play_rider_typewriter_tick() -> void:
	if rider_info_audio_players.is_empty() or rider_info_audio_stream == null:
		return
	var player := rider_info_audio_players[rider_info_audio_index]
	rider_info_audio_index = (rider_info_audio_index + 1) % rider_info_audio_players.size()
	player.stream_paused = false
	player.pitch_scale = randf_range(0.97, 1.03)
	player.set_meta("base_volume_db", 10.0)
	player.volume_db = _speedbike_sfx_volume_db(10.0)
	if player.playing:
		player.stop()
	player.play(0.0)


func _reset_boss_state() -> void:
	boss_dialog_open = false
	boss_dialog_title = ""
	boss_dialog_pages.clear()
	boss_dialog_page_index = 0
	boss_dialog_full_text = ""
	boss_dialog_visible_chars = 0
	boss_dialog_reveal_progress = 0.0
	boss_dialog_sound_timer = 0.0
	boss_dialog_after_close = ""
	boss_intro_music_active = false
	boss_encounter_started = false
	boss_complete = false
	boss_cutscene_lock = false
	boss_state = "none"
	boss_arena_scroll_speed = BOSS_ARENA_SCROLL_SPEED
	boss_position = Vector2.ZERO
	boss_target_position = Vector2.ZERO
	boss_alpha = 0.0
	boss_health = BOSS_MAX_HEALTH
	boss_phase_timer = 0.0
	boss_phase_teleports_done = 0
	boss_attack_pattern_step = 0
	boss_damage_phase = "shield"
	boss_shield_health = BOSS_SHIELD_HEALTH
	boss_cannon_health = BOSS_CANNON_HEALTH
	boss_dome_health = BOSS_DOME_HEALTH
	boss_contact_hit_timer = 0.0
	boss_laser_cooldown = 999.0
	boss_laser_charge_timer = -1.0
	boss_laser_sweep_timer = -1.0
	boss_laser_from_top = false
	boss_regular_volley_count = 0
	boss_next_chain_attack_after = randi_range(BOSS_CHAIN_ATTACK_MIN_VOLLEYS, BOSS_CHAIN_ATTACK_MAX_VOLLEYS)
	boss_chain_attack_timer = -1.0
	boss_chain_attack_shots_fired = 0
	boss_chain_attack_from_top = false
	boss_eye_charge_timer = -1.0
	boss_eye_beam_timer = -1.0
	boss_minion_spawn_index = 0
	boss_minion_wave_index = 0
	boss_minion_wave_count = 3
	boss_minion_intro_seen = false
	boss_minion_spawn_timer = 0.0
	boss_minion_spawn_visuals.clear()
	boss_return_timer = 0.0
	boss_portal_timer = 0.0
	boss_music_cycle.clear()
	if boss_dialog_shade != null and is_instance_valid(boss_dialog_shade):
		boss_dialog_shade.visible = false
	if boss_dialog_panel != null and is_instance_valid(boss_dialog_panel):
		boss_dialog_panel.visible = false
	if boss_intro_player != null and is_instance_valid(boss_intro_player):
		boss_intro_player.stop()
	if boss_laugh_player != null and is_instance_valid(boss_laugh_player):
		boss_laugh_player.stop()


func _open_boss_dialog(title: String, pages: Array[String], after_close: String, play_intro_music: bool) -> void:
	boss_dialog_title = title
	boss_dialog_pages = pages.duplicate()
	boss_dialog_after_close = after_close
	boss_dialog_page_index = 0
	boss_dialog_open = true
	boss_cutscene_lock = true
	boss_intro_music_active = play_intro_music
	if boss_dialog_title_label != null:
		boss_dialog_title_label.text = title.to_upper()
	if boss_dialog_shade != null:
		boss_dialog_shade.visible = true
	if boss_dialog_panel != null:
		boss_dialog_panel.visible = true
	if boss_dialog_continue_button != null:
		boss_dialog_continue_button.text = "NEXT"
		boss_dialog_continue_button.grab_focus()
	if play_intro_music and boss_intro_player != null and is_instance_valid(boss_intro_player):
		boss_intro_player.stop()
		boss_intro_player.set_meta("base_volume_db", -6.0)
		boss_intro_player.volume_db = _speedbike_music_volume_db(-6.0)
		boss_intro_player.play()
		if music_player != null:
			music_player.set_meta("base_volume_db", -16.0)
			music_player.volume_db = _speedbike_music_volume_db(-16.0)
	_begin_boss_dialog_page()


func _begin_boss_dialog_page() -> void:
	if boss_dialog_pages.is_empty():
		return
	boss_dialog_full_text = boss_dialog_pages[clampi(boss_dialog_page_index, 0, boss_dialog_pages.size() - 1)]
	boss_dialog_visible_chars = 0
	boss_dialog_reveal_progress = 0.0
	boss_dialog_sound_timer = 0.0
	rider_info_sound_timer = 0.0
	if boss_dialog_text_label != null:
		boss_dialog_text_label.bbcode_enabled = false
		boss_dialog_text_label.text = boss_dialog_full_text
		boss_dialog_text_label.visible_characters = 0
	if boss_dialog_continue_button != null:
		boss_dialog_continue_button.text = "START BATTLE" if boss_dialog_page_index >= boss_dialog_pages.size() - 1 and boss_dialog_after_close == "start_boss_battle" else "CONTINUE"


func _update_boss_dialog(delta: float) -> void:
	if not boss_dialog_open:
		return
	if boss_state == "dialog_intro":
		boss_target_position = Vector2(_boss_anchor_x(), speedbike_lane_y(2) - 24.0)
		boss_position = boss_position.lerp(boss_target_position, delta * 0.72)
	elif boss_state == "summon_dialog":
		boss_position.x = _boss_anchor_x()
		boss_position.y = lerpf(boss_position.y, speedbike_lane_y(2) - 24.0, delta * 1.8)
	rider_info_sound_timer = maxf(rider_info_sound_timer - delta, 0.0)
	if boss_dialog_visible_chars >= boss_dialog_full_text.length():
		return
	boss_dialog_reveal_progress += delta * BOSS_DIALOG_CHARS_PER_SECOND
	var next_chars := mini(boss_dialog_full_text.length(), int(floor(boss_dialog_reveal_progress)))
	if next_chars <= boss_dialog_visible_chars:
		return
	_play_typewriter_reveal_sounds(boss_dialog_full_text, boss_dialog_visible_chars, next_chars)
	boss_dialog_visible_chars = next_chars
	if boss_dialog_text_label != null:
		boss_dialog_text_label.visible_characters = boss_dialog_visible_chars


func _advance_boss_dialog() -> void:
	if not boss_dialog_open:
		return
	if boss_dialog_visible_chars < boss_dialog_full_text.length():
		boss_dialog_visible_chars = boss_dialog_full_text.length()
		boss_dialog_reveal_progress = float(boss_dialog_visible_chars)
		if boss_dialog_text_label != null:
			boss_dialog_text_label.visible_characters = boss_dialog_visible_chars
		return
	boss_dialog_page_index += 1
	if boss_dialog_page_index >= boss_dialog_pages.size():
		_close_boss_dialog()
		return
	_begin_boss_dialog_page()


func _close_boss_dialog() -> void:
	boss_dialog_open = false
	if boss_dialog_shade != null:
		boss_dialog_shade.visible = false
	if boss_dialog_panel != null:
		boss_dialog_panel.visible = false
	if boss_intro_music_active:
		boss_intro_music_active = false
		if boss_intro_player != null and is_instance_valid(boss_intro_player):
			boss_intro_player.stop()
		if music_player != null:
			music_player.set_meta("base_volume_db", -9.0)
			music_player.volume_db = _speedbike_music_volume_db(-9.0)
	match boss_dialog_after_close:
		"start_boss_battle":
			_start_boss_entrance()
		"start_boss_summon_wave":
			_begin_boss_summon_wave()
		"start_boss_death":
			_start_boss_death_portal()
		_:
			boss_cutscene_lock = false


func _stage_has_boss() -> bool:
	return stage_map_id == BOSS_STAGE_ID


func _begin_boss_intro() -> void:
	if boss_encounter_started or not _stage_has_boss():
		return
	_clear_runtime_objects()
	boss_encounter_started = true
	boss_complete = false
	boss_cutscene_lock = true
	boss_state = "dialog_intro"
	boss_arena_scroll_speed = maxf(camera_scroll_speed, BOSS_ARENA_SCROLL_SPEED)
	boss_health = BOSS_MAX_HEALTH
	boss_damage_phase = "shield"
	boss_shield_health = BOSS_SHIELD_HEALTH
	boss_cannon_health = BOSS_CANNON_HEALTH
	boss_dome_health = BOSS_DOME_HEALTH
	boss_phase_timer = 0.0
	boss_phase_teleports_done = 0
	boss_attack_pattern_step = 0
	player_speedbike.set_control_locked(true)
	player_speedbike.set_vertical_inverted(false)
	boss_position = Vector2(_camera_right() + 420.0, speedbike_lane_y(2) - 24.0)
	boss_target_position = Vector2(_camera_right() - BOSS_SCREEN_X_OFFSET, speedbike_lane_y(2) - 24.0)
	boss_alpha = 1.0
	enemy_bullets.clear()
	_commit_checkpoint()
	var intro_pages: Array[String] = [
	"So... the badlands rider made it all the way to the mouth of my tunnel. I am BELDAR, and this is where your legend dies.",
	"You broke through gates built to stop armies. You crossed ground that swallowed entire columns. But now you face the engine that built this nightmare.",
	"Watch the beam. Fear the brood. And when the tunnel goes dark, remember this: you were not chasing me... I was leading you here."
	]
	_open_boss_dialog("BELDAR", intro_pages, "start_boss_battle", true)
	_show_warning("BELDAR LOCKED ON", 1.1)


func _start_boss_entrance() -> void:
	boss_state = "entrance"
	boss_cutscene_lock = true
	player_speedbike.set_control_locked(true)
	boss_phase_timer = 0.0
	boss_phase_teleports_done = 0
	boss_attack_pattern_step = 0
	boss_contact_hit_timer = 0.0
	boss_chain_attack_timer = -1.0
	boss_chain_attack_shots_fired = 0
	boss_eye_charge_timer = -1.0
	boss_eye_beam_timer = -1.0
	boss_alpha = maxf(boss_alpha, 1.0)
	boss_position.x = _boss_anchor_x()
	boss_target_position = Vector2(_boss_anchor_x(), speedbike_lane_y(2) - 24.0)
	_refill_boss_music_cycle()
	_play_next_boss_music_track()
	_show_warning("BOSS CONTACT", 1.0)


func _boss_target_position() -> Vector2:
	var lane_choices: Array[int] = [1, 2, 3]
	var lane_index: int = lane_choices[randi() % lane_choices.size()]
	return Vector2(_boss_anchor_x(), speedbike_lane_y(lane_index) - 24.0)


func _boss_anchor_x() -> float:
	return _camera_right() - BOSS_SCREEN_X_OFFSET


func speedbike_boss_minion_anchor(slot_index: int) -> Vector2:
	var target_slots: Array[Vector2] = [
		Vector2(_camera_right() - 520.0, speedbike_lane_y(1)),
		Vector2(_camera_right() - 448.0, speedbike_lane_y(2)),
		Vector2(_camera_right() - 520.0, speedbike_lane_y(3)),
		Vector2(_camera_right() - 360.0, speedbike_lane_y(1)),
		Vector2(_camera_right() - 340.0, speedbike_lane_y(3)),
		Vector2(_camera_right() - 610.0, speedbike_lane_y(2)),
		Vector2(_camera_right() - 395.0, speedbike_lane_y(0)),
		Vector2(_camera_right() - 395.0, speedbike_lane_y(4))
	]
	return target_slots[clampi(slot_index, 0, target_slots.size() - 1)]


func speedbike_boss_minion_slot_count() -> int:
	return 8


func speedbike_boss_damage_phase() -> String:
	return boss_damage_phase


func _boss_draw_size() -> Vector2:
	if boss_texture == null:
		return Vector2(520.0, 360.0) * BOSS_DRAW_SCALE
	return boss_texture.get_size() * BOSS_DRAW_SCALE


func _boss_body_rect() -> Rect2:
	var size := _boss_draw_size()
	return Rect2(boss_position - size * 0.5, size)


func _boss_contact_rect() -> Rect2:
	var size := _boss_draw_size()
	var rect_size := Vector2(size.x * 0.34, size.y * 0.52)
	var center := boss_position + Vector2(size.x * 0.08, size.y * 0.04)
	return Rect2(center - rect_size * 0.5, rect_size)


func _boss_part_rect(part: String) -> Rect2:
	var size := _boss_draw_size()
	match part:
		"shield":
			return _boss_body_rect()
		"cannons":
			var part_size := Vector2(size.x * 0.50, size.y * 0.32)
			var center := boss_position + Vector2(-size.x * 0.20, size.y * 0.18)
			return Rect2(center - part_size * 0.5, part_size)
		"dome":
			var part_size := Vector2(size.x * 0.40, size.y * 0.28)
			var center := boss_position + Vector2(-size.x * 0.10, -size.y * 0.25)
			return Rect2(center - part_size * 0.5, part_size)
		_:
			return Rect2()


func _boss_active_parts() -> Array[String]:
	var parts: Array[String] = []
	match boss_damage_phase:
		"shield":
			if boss_shield_health > 0:
				parts.append("shield")
		"cannons":
			if boss_cannon_health > 0:
				parts.append("cannons")
		"dome":
			if boss_dome_health > 0:
				parts.append("dome")
		_:
			pass
	return parts


func _refresh_boss_damage_phase(show_warning: bool = true) -> void:
	var previous_phase := boss_damage_phase
	if boss_shield_health > 0:
		boss_damage_phase = "shield"
	elif boss_cannon_health > 0:
		boss_damage_phase = "cannons"
	elif boss_dome_health > 0:
		boss_damage_phase = "dome"
	else:
		boss_damage_phase = "dead"
	boss_health = max(boss_shield_health + boss_cannon_health + boss_dome_health, 0)
	if not show_warning or previous_phase == boss_damage_phase:
		return
	match boss_damage_phase:
		"cannons":
			_show_warning("LOWER CANNONS EXPOSED", 0.9)
		"dome":
			boss_laser_cooldown = randf_range(BOSS_LASER_COOLDOWN_MIN, BOSS_LASER_COOLDOWN_MAX)
			boss_laser_charge_timer = -1.0
			boss_laser_sweep_timer = -1.0
			_show_warning("DOME BREACHED", 0.9)
		"dead":
			_show_warning("BELDAR EXPOSED", 0.9)


func _start_boss_attack_round() -> void:
	boss_state = "attack"
	boss_cutscene_lock = false
	player_speedbike.set_control_locked(false)
	boss_phase_timer = 0.0
	boss_attack_pattern_step = 0
	boss_alpha = 1.0
	boss_contact_hit_timer = 0.0
	if boss_damage_phase == "dome" and boss_laser_cooldown > BOSS_LASER_COOLDOWN_MAX:
		boss_laser_cooldown = randf_range(BOSS_LASER_COOLDOWN_MIN, BOSS_LASER_COOLDOWN_MAX)


func _start_boss_summon() -> void:
	if not boss_minion_intro_seen:
		boss_minion_intro_seen = true
		boss_state = "summon_dialog"
		boss_cutscene_lock = true
		player_speedbike.set_control_locked(true)
		boss_alpha = 1.0
		boss_position.x = _boss_anchor_x()
		boss_phase_timer = 0.0
		enemy_bullets.clear()
		var minion_pages: Array[String] = [
			"You have been shooting at the shell of my empire. Now meet the teeth that live inside it.",
			"The Minizorg were grown in the heat under this tunnel. They know no retreat, no mercy, no little soldier superstition about courage.",
			"Rise, my small horrors. Circle the rider. Black out the lanes. Destroy them."
		]
		_open_boss_dialog("BELDAR", minion_pages, "start_boss_summon_wave", false)
		_show_warning("MINIZORG RELEASE", 1.0)
		return
	_begin_boss_summon_wave()


func _begin_boss_summon_wave() -> void:
	boss_state = "summon"
	boss_cutscene_lock = true
	player_speedbike.set_control_locked(true)
	boss_phase_timer = 0.0
	boss_minion_spawn_index = 0
	boss_minion_wave_count = int(BOSS_MINION_WAVE_COUNTS[mini(boss_minion_wave_index, BOSS_MINION_WAVE_COUNTS.size() - 1)])
	boss_minion_wave_index = mini(boss_minion_wave_index + 1, BOSS_MINION_WAVE_COUNTS.size() - 1)
	boss_minion_spawn_timer = 0.0
	boss_laser_charge_timer = -1.0
	boss_laser_sweep_timer = -1.0
	boss_chain_attack_timer = -1.0
	boss_chain_attack_shots_fired = 0
	boss_eye_charge_timer = -1.0
	boss_eye_beam_timer = -1.0
	boss_minion_spawn_visuals.clear()
	_spawn_next_boss_minion_visual()
	_show_warning("DESCENT BEAM", 1.0)


func _spawn_next_boss_minion_visual() -> void:
	if boss_minion_spawn_index >= boss_minion_wave_count:
		return
	var slot_index := boss_minion_spawn_index
	var target := speedbike_boss_minion_anchor(slot_index)
	boss_minion_spawn_visuals.append({
		"progress": 0.0,
		"start": boss_position + Vector2(0.0, 56.0),
		"target": target,
		"slot": slot_index
	})
	boss_minion_spawn_index += 1


func _spawn_boss_minion_from_visual(visual: Dictionary) -> void:
	var drone_scene = load("res://scripts/speedbike/SpeedbikeDrone.gd")
	if drone_scene == null:
		return
	var drone = drone_scene.new()
	register_speedbike_drone(drone)
	drone.setup({
		"enemy_type": "minizorg",
		"x": float((visual.get("target", Vector2.ZERO) as Vector2).x),
		"y": float((visual.get("target", Vector2.ZERO) as Vector2).y),
		"health": BOSS_MINION_HEALTH,
		"boss_slot": int(visual.get("slot", 0)),
		"shoot_interval": 1.02 if boss_damage_phase == "dome" else 1.20,
		"bob_speed": 2.4,
		"bob_amount": 18.0,
		"score_value": 1200
	}, self)
	if drone.has_method("refresh_boss_minion_anchor"):
		drone.refresh_boss_minion_anchor(0.0)
	_spawn_burst_fx(drone.position, Color(0.72, 0.38, 1.0, 0.84), 0.55)


func _start_boss_death_dialog() -> void:
	if boss_complete or boss_state == "death_dialog" or boss_state == "death_portal":
		return
	boss_state = "death_dialog"
	boss_cutscene_lock = true
	player_speedbike.set_control_locked(true)
	enemy_bullets.clear()
	var death_pages: Array[String] = [
		"No... the tunnel should have closed. The hunt should have ended in my dark, not under your fire.",
		"This was not the fate written for BELDAR. If I fall, then the pit below can keep the part of me that still burns."
	]
	_open_boss_dialog("BELDAR", death_pages, "start_boss_death", false)
	_show_warning("BELDAR BROKEN", 1.0)


func _start_boss_death_portal() -> void:
	boss_state = "death_portal"
	boss_cutscene_lock = true
	player_speedbike.set_control_locked(true)
	boss_portal_timer = 0.0
	enemy_bullets.clear()
	_show_warning("THE GROUND ANSWERS", 1.1)


func _tick_boss(delta: float) -> void:
	if not boss_encounter_started or boss_complete:
		return
	boss_contact_hit_timer = maxf(boss_contact_hit_timer - delta, 0.0)
	match boss_state:
		"entrance":
			boss_phase_timer += delta
			boss_alpha = minf(boss_alpha + delta * 1.2, 1.0)
			boss_target_position.x = _boss_anchor_x()
			boss_position = boss_position.lerp(boss_target_position, delta * 1.8)
			if boss_phase_timer >= 1.2:
				_start_boss_attack_round()
		"attack":
			boss_target_position.x = _boss_anchor_x()
			var boss_move_speed := 5.8 if boss_damage_phase == "dome" else 2.8
			boss_position.y = lerpf(boss_position.y, boss_target_position.y, delta * boss_move_speed)
			boss_position.x = boss_target_position.x
			if boss_damage_phase == "dome":
				boss_position += Vector2(sin(stage_elapsed * 39.0) * 2.2, sin(stage_elapsed * 31.0) * 2.8)
			if not _tick_boss_special_attack(delta):
				boss_phase_timer += delta
				_tick_boss_laser(delta)
				if boss_attack_pattern_step == 0 and boss_phase_timer >= 1.05:
					boss_attack_pattern_step = 1
					_spawn_boss_regular_burst(2)
				elif boss_attack_pattern_step == 1 and boss_phase_timer >= 2.65:
					boss_attack_pattern_step = 2
					if boss_damage_phase == "dome":
						spawn_enemy_homing_missile(boss_position + Vector2(-76.0, -22.0), speedbike_boss_bullet_speed(360.0), true)
						spawn_enemy_homing_missile(boss_position + Vector2(-72.0, 18.0), speedbike_boss_bullet_speed(370.0), true)
						_show_warning("ROCKETS", 0.5)
					else:
						_spawn_boss_regular_burst(2)
				elif boss_attack_pattern_step == 2 and boss_phase_timer >= 4.05:
					boss_attack_pattern_step = 3
					_spawn_boss_regular_burst(3)
					if boss_damage_phase == "dome":
						spawn_enemy_homing_missile(boss_position + Vector2(-78.0, 0.0), speedbike_boss_bullet_speed(380.0), true)
				var teleport_interval := BOSS_DOME_TELEPORT_INTERVAL if boss_damage_phase == "dome" else BOSS_TELEPORT_INTERVAL
				if boss_phase_timer >= teleport_interval:
					boss_phase_teleports_done += 1
					if boss_phase_teleports_done >= 3:
						_start_boss_summon()
					else:
						boss_phase_timer = 0.0
						boss_attack_pattern_step = 0
						boss_target_position = _boss_target_position()
						boss_position = boss_target_position + Vector2(0.0, randf_range(-30.0, 30.0))
						_spawn_burst_fx(boss_target_position, Color(0.74, 0.42, 1.0, 0.78), 0.48)
						_show_warning("BELDAR SHIFT", 0.5)
		"summon":
			var summon_target := Vector2(_boss_anchor_x(), speedbike_lane_y(2) - 24.0)
			boss_position.y = lerpf(boss_position.y, summon_target.y, delta * 2.0)
			boss_position.x = summon_target.x
			if not boss_minion_spawn_visuals.is_empty():
				var active_visual := boss_minion_spawn_visuals[boss_minion_spawn_visuals.size() - 1]
				active_visual["target"] = speedbike_boss_minion_anchor(int(active_visual.get("slot", 0)))
				active_visual["progress"] = clampf(float(active_visual.get("progress", 0.0)) + delta / 1.15, 0.0, 1.0)
				boss_minion_spawn_visuals[boss_minion_spawn_visuals.size() - 1] = active_visual
				if float(active_visual.get("progress", 0.0)) >= 1.0:
					_spawn_boss_minion_from_visual(active_visual)
					boss_minion_spawn_visuals.clear()
					boss_minion_spawn_timer = 0.45
			else:
				boss_minion_spawn_timer -= delta
				if boss_minion_spawn_index < boss_minion_wave_count and boss_minion_spawn_timer <= 0.0:
					_spawn_next_boss_minion_visual()
				elif boss_minion_spawn_index >= boss_minion_wave_count and boss_minion_spawn_timer <= 0.0:
					boss_state = "laugh"
					boss_phase_timer = 0.0
					if boss_laugh_player != null and is_instance_valid(boss_laugh_player):
						boss_laugh_player.stop()
						boss_laugh_player.set_meta("base_volume_db", 2.0)
						boss_laugh_player.volume_db = _speedbike_sfx_volume_db(2.0)
						boss_laugh_player.play()
		"laugh":
			boss_position.x = _boss_anchor_x()
			boss_phase_timer += delta
			if boss_phase_timer >= 2.0:
				boss_state = "fade_out"
				boss_phase_timer = 0.0
		"fade_out":
			boss_position.x = _boss_anchor_x()
			boss_phase_timer += delta
			boss_alpha = maxf(1.0 - boss_phase_timer / 0.9, 0.0)
			if boss_phase_timer >= 0.9:
				boss_state = "minion_fight"
				boss_cutscene_lock = false
				player_speedbike.set_control_locked(false)
				boss_alpha = 0.0
				_show_warning("MINIZORG SWARM", 0.8)
		"minion_fight":
			boss_position.x = _boss_anchor_x()
			if not _has_active_minizorg():
				boss_state = "returning"
				boss_cutscene_lock = true
				player_speedbike.set_control_locked(true)
				boss_phase_timer = 0.0
				boss_phase_teleports_done = 0
				boss_attack_pattern_step = 0
				boss_alpha = 0.0
				boss_target_position = _boss_target_position()
				boss_position = boss_target_position + Vector2(0.0, -64.0)
		"returning":
			boss_phase_timer += delta
			boss_alpha = minf(boss_alpha + delta * 1.65, 1.0)
			boss_target_position.x = _boss_anchor_x()
			boss_position.y = lerpf(boss_position.y, boss_target_position.y, delta * 2.4)
			boss_position.x = boss_target_position.x
			if boss_phase_timer >= 1.1:
				_start_boss_attack_round()
		"death_portal":
			boss_portal_timer += delta
			if int(floor(boss_portal_timer * 8.0)) != int(floor((boss_portal_timer - delta) * 8.0)):
				_spawn_burst_fx(boss_position + Vector2(randf_range(-120.0, 120.0), randf_range(-86.0, 96.0)), Color(1.0, 0.42, 0.18, 0.92), 0.65)
			boss_position.y += delta * 26.0
			boss_alpha = maxf(1.0 - maxf(boss_portal_timer - 1.6, 0.0) / 1.6, 0.0)
			if boss_portal_timer >= BOSS_PORTAL_DURATION:
				_award_blue_coin(BLUE_COIN_TOTAL, boss_position)
				boss_complete = true
				boss_state = "none"
				boss_cutscene_lock = false
				boss_alpha = 0.0
				enemy_bullets.clear()
	if boss_state in ["attack", "returning"] and boss_alpha > 0.2:
		_resolve_boss_contact()


func _boss_special_active() -> bool:
	return boss_chain_attack_timer >= 0.0 or boss_eye_charge_timer >= 0.0 or boss_eye_beam_timer >= 0.0


func _tick_boss_special_attack(delta: float) -> bool:
	if boss_chain_attack_timer >= 0.0:
		_tick_boss_chain_attack(delta)
		return true
	if boss_eye_charge_timer >= 0.0 or boss_eye_beam_timer >= 0.0:
		_tick_boss_eye_attack(delta)
		return true
	return false


func _spawn_boss_regular_burst(shots: int) -> void:
	_spawn_boss_burst(shots)
	_record_boss_regular_volley()


func _record_boss_regular_volley() -> void:
	if _boss_special_active():
		return
	boss_regular_volley_count += 1
	if boss_regular_volley_count < boss_next_chain_attack_after:
		return
	if boss_damage_phase == "shield" or randf() < 0.55:
		_start_boss_chain_attack()
	else:
		_start_boss_eye_charge()


func _reset_boss_special_counter() -> void:
	boss_regular_volley_count = 0
	boss_next_chain_attack_after = randi_range(BOSS_CHAIN_ATTACK_MIN_VOLLEYS, BOSS_CHAIN_ATTACK_MAX_VOLLEYS)


func _start_boss_chain_attack() -> void:
	boss_chain_attack_timer = 0.0
	boss_chain_attack_shots_fired = 0
	boss_chain_attack_from_top = randf() < 0.5
	boss_eye_charge_timer = -1.0
	boss_eye_beam_timer = -1.0
	_show_warning("CHAIN FAN", 0.9)
	_play_sfx(WARNING_SOUND_PATH, -6.0, 0.78)


func _tick_boss_chain_attack(delta: float) -> void:
	boss_chain_attack_timer += delta
	var chain_interval := maxf(BOSS_CHAIN_ATTACK_INTERVAL * _boss_fire_interval_mult(), 0.075)
	while boss_chain_attack_timer >= chain_interval and boss_chain_attack_shots_fired < BOSS_CHAIN_ATTACK_BULLETS:
		boss_chain_attack_timer -= chain_interval
		_fire_boss_chain_bullet(boss_chain_attack_shots_fired)
		boss_chain_attack_shots_fired += 1
	if boss_chain_attack_shots_fired >= BOSS_CHAIN_ATTACK_BULLETS:
		boss_chain_attack_timer = -1.0
		boss_chain_attack_shots_fired = 0
		_reset_boss_special_counter()


func _fire_boss_chain_bullet(index: int) -> void:
	var t := float(index) / maxf(float(BOSS_CHAIN_ATTACK_BULLETS - 1), 1.0)
	var top_y := speedbike_top_bound() + 24.0
	var mid_y := speedbike_lane_y(2)
	var bottom_y := speedbike_bottom_bound() - 24.0
	var target_y := lerpf(top_y, mid_y, t) if boss_chain_attack_from_top else lerpf(bottom_y, mid_y, t)
	var origin := _boss_laser_eye_position() + Vector2(-12.0, 0.0)
	var target := Vector2(_camera_left() + 160.0, target_y)
	var aim := (target - origin).normalized()
	if aim.length_squared() <= 0.1:
		aim = Vector2.LEFT
	spawn_enemy_bullet(origin, aim, speedbike_boss_bullet_speed(BOSS_CHAIN_ATTACK_SPEED), 10.0, "boss_chain_bullet", true)
	_spawn_burst_fx(origin, Color(0.42, 0.74, 1.0, 0.54), 0.18)


func _start_boss_eye_charge() -> void:
	boss_eye_charge_timer = 0.0
	boss_eye_beam_timer = -1.0
	boss_chain_attack_timer = -1.0
	boss_chain_attack_shots_fired = 0
	_show_warning("EYE CHARGING", 1.1)
	_play_sfx(WARNING_SOUND_PATH, -4.0, 0.68)


func _tick_boss_eye_attack(delta: float) -> void:
	if boss_eye_charge_timer >= 0.0:
		var previous_step := int(floor(boss_eye_charge_timer / BOSS_EYE_CHARGE_STEP_DURATION))
		boss_eye_charge_timer += delta
		var current_step := int(floor(boss_eye_charge_timer / BOSS_EYE_CHARGE_STEP_DURATION))
		if current_step != previous_step:
			match current_step:
				1:
					_show_warning("EYE GREEN", 0.75)
				2:
					_show_warning("EYE RED", 0.75)
				_:
					pass
		if boss_eye_charge_timer >= BOSS_EYE_CHARGE_TOTAL_DURATION:
			boss_eye_charge_timer = -1.0
			boss_eye_beam_timer = 0.0
			_show_warning("DISINTEGRATOR BEAM", 0.8)
			_play_sfx(WARNING_SOUND_PATH, -2.0, 0.52)
		return
	if boss_eye_beam_timer >= 0.0:
		boss_eye_beam_timer += delta
		if boss_eye_beam_timer >= BOSS_EYE_BEAM_DURATION:
			boss_eye_beam_timer = -1.0
			_reset_boss_special_counter()


func _boss_eye_beam_rect() -> Rect2:
	if boss_eye_beam_timer < 0.0:
		return Rect2()
	var eye := _boss_laser_eye_position()
	var left := _camera_left() - 40.0
	return Rect2(left, eye.y - BOSS_EYE_BEAM_WIDTH * 0.5, maxf(eye.x - left, 1.0), BOSS_EYE_BEAM_WIDTH)


func _boss_eye_beam_player_hit(player_rect: Rect2) -> bool:
	return boss_eye_beam_timer >= 0.0 and _boss_eye_beam_rect().intersects(player_rect)


func _tick_boss_laser(delta: float) -> void:
	if boss_damage_phase != "dome" or boss_state != "attack":
		return
	if boss_laser_sweep_timer >= 0.0:
		boss_laser_sweep_timer += delta
		if boss_laser_sweep_timer >= BOSS_LASER_SWEEP_DURATION:
			boss_laser_sweep_timer = -1.0
			boss_laser_cooldown = randf_range(BOSS_LASER_COOLDOWN_MIN, BOSS_LASER_COOLDOWN_MAX)
		return
	if boss_laser_charge_timer >= 0.0:
		boss_laser_charge_timer += delta
		if boss_laser_charge_timer >= BOSS_LASER_CHARGE_DURATION:
			boss_laser_charge_timer = -1.0
			boss_laser_sweep_timer = 0.0
			_show_warning("EYE LASER", 0.65)
		return
	boss_laser_cooldown -= delta
	if boss_laser_cooldown <= 0.0:
		boss_laser_from_top = randf() < 0.5
		boss_laser_charge_timer = 0.0
		_play_sfx(WARNING_SOUND_PATH, -5.0, 0.82)
		_show_warning("BELDAR CHARGING", 1.0)


func _boss_laser_eye_position() -> Vector2:
	var size := _boss_draw_size()
	return boss_position + Vector2(-size.x * 0.24, -size.y * 0.04)


func _boss_laser_y(progress: float) -> float:
	var top_y := speedbike_top_bound() + 30.0
	var middle_y := speedbike_lane_y(2)
	var bottom_y := speedbike_bottom_bound() - 30.0
	return lerpf(top_y, middle_y, progress) if boss_laser_from_top else lerpf(bottom_y, middle_y, progress)


func _boss_laser_active_rect() -> Rect2:
	if boss_laser_sweep_timer < 0.0:
		return Rect2()
	var progress := clampf(boss_laser_sweep_timer / maxf(BOSS_LASER_SWEEP_DURATION, 0.01), 0.0, 1.0)
	var beam_y := _boss_laser_y(progress)
	var eye := _boss_laser_eye_position()
	var left := _camera_left() - 40.0
	return Rect2(left, beam_y - BOSS_LASER_WIDTH * 0.5, maxf(eye.x - left, 1.0), BOSS_LASER_WIDTH)


func _boss_laser_player_hit(player_rect: Rect2) -> bool:
	return boss_laser_sweep_timer >= 0.0 and _boss_laser_active_rect().intersects(player_rect)


func _has_active_minizorg() -> bool:
	for drone in active_drones:
		if not drone.destroyed and str(drone.drone_type) == "minizorg":
			return true
	return false


func _resolve_boss_contact() -> void:
	var player_rect: Rect2 = player_speedbike.hurtbox_rect()
	var boss_rect := _boss_contact_rect().grow_individual(8.0, 6.0, 18.0, 12.0)
	if not boss_rect.intersects(player_rect):
		return
	var safe_x := boss_rect.position.x - player_rect.size.x * 0.62
	player_speedbike.position.x = minf(player_speedbike.position.x, safe_x)
	if boss_contact_hit_timer > 0.0:
		return
	boss_contact_hit_timer = BOSS_CONTACT_HIT_INTERVAL
	_handle_player_hit("boss_ram", player_rect.get_center())


func _boss_hit_part_for_bullet(bullet_rect: Rect2) -> String:
	for part in _boss_active_parts():
		var part_rect := _boss_part_rect(part).grow(24.0)
		if part == "shield" and _boss_body_rect().intersects(bullet_rect):
			return part
		if part_rect.intersects(bullet_rect):
			return part
		var body_rect := _boss_body_rect()
		var bullet_center := bullet_rect.get_center()
		if part == "cannons" and body_rect.intersects(bullet_rect) and bullet_center.y >= boss_position.y - _boss_draw_size().y * 0.08:
			return part
		if part == "dome" and body_rect.intersects(bullet_rect) and bullet_center.y <= boss_position.y + _boss_draw_size().y * 0.04:
			return part
	return ""


func _boss_body_hit_without_weakpoint(bullet_rect: Rect2) -> bool:
	return _boss_body_rect().intersects(bullet_rect)


func _damage_boss_part(part: String, damage: int, hit_position: Vector2) -> void:
	match part:
		"shield":
			boss_shield_health = max(boss_shield_health - damage, 0)
			if boss_shield_health == 0:
				_show_warning("SHIELD COLLAPSED", 0.7)
		"cannons":
			boss_cannon_health = max(boss_cannon_health - damage, 0)
			if boss_cannon_health == 0:
				_show_warning("CANNON BATTERY DOWN", 0.7)
		"dome":
			boss_dome_health = max(boss_dome_health - damage, 0)
			if boss_dome_health == 0:
				_show_warning("BELDAR EXPOSED", 0.7)
		_:
			return
	_spawn_burst_fx(hit_position, Color(0.92, 0.38, 1.0, 0.94), 0.42)
	_refresh_boss_damage_phase()
	if boss_damage_phase == "dead" or boss_health <= 0:
		_start_boss_death_dialog()


func _spawn_boss_burst(shots: int) -> void:
	var adjusted_shots := shots + _boss_extra_shots_per_volley()
	var bullet_speed := speedbike_boss_bullet_speed(560.0 if adjusted_shots <= 2 else 610.0)
	var spreads: Array[float] = [0.0]
	if adjusted_shots >= 5:
		spreads = [-0.18, -0.06, 0.06, 0.18]
	elif adjusted_shots >= 4:
		spreads = [-0.14, 0.0, 0.14]
	elif adjusted_shots >= 3:
		spreads = [-0.10, 0.10]
	var origins: Array[Vector2] = []
	if boss_cannon_health > 0:
		var cannon_rect := _boss_part_rect("cannons")
		origins.append(cannon_rect.get_center() + Vector2(-22.0, -10.0))
		origins.append(cannon_rect.get_center() + Vector2(-18.0, 10.0))
	if origins.is_empty():
		origins.append(_boss_part_rect("dome").get_center() + Vector2(-14.0, 12.0))
	for origin in origins:
		var target: Vector2 = player_speedbike.bike_midpoint()
		var aim: Vector2 = (target - origin).normalized()
		if aim.length_squared() <= 0.1:
			aim = Vector2.LEFT
		for spread in spreads:
			spawn_enemy_bullet(origin, aim.rotated(spread), bullet_speed, 9.0, "boss_bullet", true)


func _refill_boss_music_cycle() -> void:
	boss_music_cycle.clear()
	for path in BOSS_MUSIC_PATHS:
		boss_music_cycle.append(path)
	boss_music_cycle.shuffle()


func _play_next_boss_music_track() -> void:
	if boss_music_cycle.is_empty():
		_refill_boss_music_cycle()
	if boss_music_cycle.is_empty():
		return
	var path := boss_music_cycle[0]
	boss_music_cycle.remove_at(0)
	var stream := _load_direct_audio_stream(path)
	if stream == null or music_player == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = false
	music_player.stop()
	music_player.stream = stream
	music_player.set_meta("base_volume_db", -6.0)
	music_player.volume_db = _speedbike_music_volume_db(-6.0)
	music_player.play()


func _apply_selected_rider_profile() -> void:
	var rider_def := _selected_rider_def()
	var speed_hits := maxi(int(difficulty_row.get("hits", 1)), 1)
	if bool(difficulty_row.get("instant_crash", false)):
		max_hits = 1
	else:
		max_hits = maxi(speed_hits + int(rider_def.get("armor_bonus_hits", 0)) + speedbike_bonus_health_slots, SPEEDBIKE_MIN_HEALTH_HITS)
	if not stage_started:
		remaining_hits = max_hits
	else:
		remaining_hits = clampi(remaining_hits, 1, max_hits)
	var hurtbox_mult := float(rider_def.get("hurtbox_mult", 1.0))
	var profile := {
		"ride_texture": _load_texture(str(rider_def.get("ride_path", ""))),
		"jump_texture": _load_texture(str(rider_def.get("jump_path", ""))),
		"scale": float(rider_def.get("scale", 0.14)),
		"vertical_speed": 420.0 * float(rider_def.get("vertical_mult", 1.0)),
		"horizontal_speed": 340.0 * float(rider_def.get("horizontal_mult", 1.0)),
		"jump_duration": 0.62 * float(rider_def.get("jump_duration_mult", 1.0)),
		"jump_height": 72.0 + float(rider_def.get("jump_height_add", 0.0)),
		"jump_cooldown": 0.12 * float(rider_def.get("jump_cooldown_mult", 1.0)),
		"shot_cooldown": 0.12 * float(rider_def.get("shot_cooldown_mult", 1.0)),
		"hurtbox_size": Vector2(156.0 * hurtbox_mult, 54.0 * hurtbox_mult)
	}
	player_speedbike.apply_rider_profile(profile)


func _deploy_selected_rider() -> void:
	PlayState.speedbike_rider_id = selected_rider_id
	PlayState.flush_progress()
	speedbike_bonus_health_slots = 0
	selection_open = false
	character_select_shade.visible = false
	character_select_panel.visible = false
	_start_stage()


func _start_stage(carry_chain: bool = false) -> void:
	_apply_selected_rider_profile()
	_clear_runtime_objects()
	_reset_boss_state()
	stage_elapsed = 0.0
	var speed_factor := speed_multiplier * float(difficulty_row.get("speed_scale", 1.0))
	if carry_chain:
		var carried_speed := maxf(stage_chain_carry_speed, 0.0)
		var reset_chain_speed := _stage_uses_chain_speed_reset()
		var target_speed := stage_base_speed * speed_factor if reset_chain_speed else maxf(carried_speed + STAGE_CHAIN_SPEEDUP, stage_base_speed * speed_factor)
		stage_speed_bonus = maxf((target_speed / maxf(speed_factor, 0.01)) - stage_base_speed, 0.0)
		camera_scroll_speed = target_speed
		speedbike_camera.position = Vector2(maxf(stage_chain_carry_camera_x, screen_size.x * 0.5), screen_size.y * 0.5)
	else:
		stage_speed_bonus = 0.0
		camera_scroll_speed = stage_base_speed * speed_factor
		speedbike_camera.position = Vector2(screen_size.x * 0.5, screen_size.y * 0.5)
	player_speedbike.set_control_locked(false)
	player_speedbike.set_vertical_inverted(false)
	player_speedbike.reset_for_stage(_camera_left(), speedbike_lane_y(2))
	if carry_chain:
		var carried_offset := clampf(stage_chain_carry_player_x_offset, 120.0, maxf(screen_size.x - 170.0, 420.0))
		var carried_y := clampf(stage_chain_carry_player_y, speedbike_top_bound(), speedbike_bottom_bound())
		player_speedbike.position = Vector2(_camera_left() + carried_offset, carried_y)
	player_speedbike.configure_play_window(_camera_left(), speedbike_top_bound(), speedbike_bottom_bound())
	last_safe_y = player_speedbike.position.y if carry_chain else speedbike_lane_y(2)
	shield_hits = 0
	remaining_hits = max_hits
	section_hitless = true
	stage_run_deaths = 0
	stage_run_crashes = 0
	checkpoint_count = 0
	last_event_checkpoint_elapsed = -999.0
	chapter_transition_timer = -1.0
	crash_restart_timer = -1.0
	invuln_timer = 0.0
	flash_alpha = 0.0
	blackout_strength = 0.0
	slow_time_timer = 0.0
	oil_dropper_timer = randf_range(7.0, 13.0)
	_configure_speedbike_weather()
	if not stage_started:
		gold_coins_collected = 0
		blue_coins_collected = 0
		blue_coin_ids_collected.clear()
	_prepare_blue_coin_stage_schedule()
	if not carry_chain:
		speedbike_weapon_kind = "normal"
		speedbike_weapon_timer = 0.0
		speedbike_weapon_ammo = -1
		checkpoint_splash_timer = 0.0
		checkpoint_splash_text = ""
	else:
		_refresh_speedbike_weapon_controller_boost()
	deaths = 0 if not stage_started else deaths
	crashes = 0 if not stage_started else crashes
	drones_destroyed = 0 if not stage_started else drones_destroyed
	pickups_collected = 0 if not stage_started else pickups_collected
	score = 0 if not stage_started else score
	chapter_elapsed_total = 0.0 if not stage_started else chapter_elapsed_total
	stage_cleared = false
	stage_transition_live = false
	pause_open = false
	if not carry_chain:
		_reset_merchant_state()
	speedbike_touch_layout_edit_mode = false
	_clear_speedbike_touch_states()
	result_panel.visible = false
	pause_panel.visible = false
	result_ready_for_continue = false
	warning_text = stage_name
	warning_text_timer = 1.8
	tip_text = str(stage_data.get("start_tip", "SPACE CLEARS SHORT GAPS  RAMPS BOOST BIG PITS  BLAST RED WALLS"))
	pattern_runner.reset_to_state(0.0, 0)
	_commit_checkpoint()
	stage_started = true
	_sync_speedbike_touch_controls()
	_update_hud()


func _stage_uses_chain_speed_reset() -> bool:
	if PlayState != null and bool(PlayState.speedbike_skill_mode_enabled):
		return false
	return STAGE_CHAIN_RESET_STAGES.has(_chapter_stage_number())


func _should_accept_event_checkpoint() -> bool:
	if checkpoint_count >= SPEEDBIKE_MAX_EVENT_CHECKPOINTS:
		return false
	if stage_elapsed - last_event_checkpoint_elapsed < SPEEDBIKE_MIN_CHECKPOINT_INTERVAL:
		return false
	return true


func _physics_process(delta: float) -> void:
	screen_size = get_viewport_rect().size
	_build_lane_positions()
	player_speedbike.configure_play_window(_camera_left(), speedbike_top_bound(), speedbike_bottom_bound())
	if boss_dialog_open:
		_tick_flash_and_audio(delta)
		_update_hud()
		queue_redraw()
		return
	if merchant_state != "none" or merchant_shop_open:
		_tick_merchant_transition(delta)
		_tick_flash_and_audio(delta)
		_update_hud()
		queue_redraw()
		return
	if selection_open or pause_open or stage_cleared:
		if stage_cleared and chapter_transition_timer > 0.0:
			chapter_transition_timer -= delta
			if chapter_transition_timer <= 0.0 and not result_panel.visible:
				_advance_to_next_stage()
		_tick_flash_and_audio(delta)
		_update_hud()
		queue_redraw()
		return
	if crash_restart_timer > 0.0:
		crash_restart_timer -= delta
		_tick_flash_and_audio(delta)
		if crash_restart_timer <= 0.0:
			_restart_from_checkpoint()
		queue_redraw()
		return

	stage_elapsed += delta
	chapter_elapsed_total += delta
	invuln_timer = maxf(invuln_timer - delta, 0.0)
	slow_time_timer = maxf(slow_time_timer - delta, 0.0)
	speedbike_weapon_timer = maxf(speedbike_weapon_timer - delta, 0.0)
	current_hits_flash = maxf(current_hits_flash - delta, 0.0)
	_refresh_player_weapon_glow()
	if stage_transition_live and chapter_transition_timer > 0.0:
		chapter_transition_timer -= delta
		if chapter_transition_timer <= 0.0:
			_advance_to_next_stage()
			return
	var speed_factor := speed_multiplier * float(difficulty_row.get("speed_scale", 1.0))
	var slowdown: float = 0.70 if slow_time_timer > 0.0 else 1.0
	var stage_boost: float = player_speedbike.afterburner_stage_speed_bonus() if player_speedbike != null else 0.0
	camera_scroll_speed = (stage_base_speed + stage_speed_ramp * stage_elapsed + stage_speed_bonus + stage_boost) * speed_factor * slowdown
	if boss_encounter_started and not boss_complete:
		camera_scroll_speed = maxf(boss_arena_scroll_speed + stage_boost, BOSS_ARENA_SCROLL_SPEED)
	speedbike_camera.position.x += camera_scroll_speed * delta
	var touch_attack := bool(speedbike_touch_states.get("fire", false))
	if speedbike_touch_autofire_enabled and (bool(speedbike_touch_states.get("left", false)) or bool(speedbike_touch_states.get("right", false))):
		touch_attack = true
	player_speedbike.set_virtual_input_states(
		bool(speedbike_touch_states.get("up", false)),
		bool(speedbike_touch_states.get("down", false)),
		bool(speedbike_touch_states.get("left", false)),
		bool(speedbike_touch_states.get("right", false)),
		bool(speedbike_touch_states.get("jump", false)),
		touch_attack,
		bool(speedbike_touch_states.get("boost", false))
	)
	player_speedbike.tick(delta, _camera_left(), camera_scroll_speed)
	_refresh_player_weapon_glow()
	last_safe_y = clampf(player_speedbike.position.y, speedbike_top_bound(), speedbike_bottom_bound())
	pattern_runner.tick(delta)
	_tick_boss(delta)
	if boss_cutscene_lock:
		_refresh_boss_minion_slots(delta)
		_tick_fx(delta)
		_update_camera_motion(delta)
		_cleanup_runtime_objects()
		_tick_flash_and_audio(delta)
		_update_hud()
		queue_redraw()
		return
	_tick_obstacles(delta)
	_tick_drones(delta)
	_tick_oil_dropper_pressure(delta)
	_tick_projectiles(delta)
	_tick_blue_coin_route()
	_tick_pickups(delta)
	_tick_speedbike_weather(delta)
	_tick_fx(delta)
	_update_camera_motion(delta)
	_resolve_collisions()
	_cleanup_runtime_objects()
	_apply_headlight_visibility_to_runtime()
	_check_stage_clear()
	_tick_flash_and_audio(delta)
	_update_hud()
	queue_redraw()


func _process(delta: float) -> void:
	if selection_open:
		_update_rider_select_presentation(delta)
	if boss_dialog_open:
		_update_boss_dialog(delta)
	if merchant_shop_open:
		_update_merchant_shop(delta)
	if warning_text_timer > 0.0:
		warning_text_timer = maxf(warning_text_timer - delta, 0.0)
		if warning_text_timer <= 0.0:
			warning_text = ""
	if flash_alpha > 0.0:
		flash_alpha = maxf(flash_alpha - delta * 2.4, 0.0)
	if checkpoint_splash_timer > 0.0:
		checkpoint_splash_timer = maxf(checkpoint_splash_timer - delta, 0.0)
	flash_rect.color = Color(1.0, 1.0, 1.0, flash_alpha)
	_sync_speedbike_touch_controls()
	if boss_encounter_started and not boss_complete and not boss_dialog_open and music_player != null and not music_player.playing:
		_play_next_boss_music_track()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_speedbike_touch_layout_touch(event)
	elif event is InputEventScreenDrag:
		_handle_speedbike_touch_layout_drag(event)


func _unhandled_input(event: InputEvent) -> void:
	if not pause_rebind_action.is_empty():
		if _handle_speedbike_rebind_input(event):
			var viewport := get_viewport()
			if viewport != null:
				viewport.set_input_as_handled()
		return
	if boss_dialog_open:
		if _menu_confirm_pressed(event):
			_advance_boss_dialog()
			return
		if _menu_back_pressed(event):
			_advance_boss_dialog()
			return
		return
	if merchant_shop_open:
		if _menu_confirm_pressed(event):
			var fallback := merchant_leave_button
			if merchant_item_buttons.size() > 0:
				fallback = merchant_item_buttons[0]
			_activate_focused_button(fallback)
			return
		if _menu_back_pressed(event):
			_close_merchant_shop_and_depart()
			return
		return
	if selection_open:
		if _menu_confirm_pressed(event):
			_activate_focused_button(character_deploy_button)
			return
		if _menu_back_pressed(event):
			_activate_focused_button(character_return_button)
			return
	if stage_cleared:
		if _menu_confirm_pressed(event):
			_activate_focused_button(result_continue_button)
			return
		if _menu_back_pressed(event):
			_activate_focused_button(result_return_button)
			return
	if pause_open:
		if _menu_confirm_pressed(event):
			_activate_focused_button(pause_resume_button)
			return
		if _menu_back_pressed(event):
			_resume_from_pause()
			return
	if _pause_pressed(event):
		_toggle_pause()
		return


func _pause_pressed(event: InputEvent) -> bool:
	if event.is_action_pressed(InputBindings.action_name("pause")):
		return true
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		return true
	return event is InputEventJoypadButton and event.pressed and (event.button_index == JOY_BUTTON_START or event.button_index == JOY_BUTTON_BACK)


func _menu_confirm_pressed(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE):
		return true
	return event is InputEventJoypadButton and event.pressed and (event.button_index == JOY_BUTTON_A or event.button_index == JOY_BUTTON_START)


func _menu_back_pressed(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_cancel"):
		return true
	return event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B


func _activate_focused_button(fallback: Button) -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var focus_owner := viewport.gui_get_focus_owner()
	if focus_owner is Button:
		(focus_owner as Button).pressed.emit()
		viewport.set_input_as_handled()
		return
	if fallback != null:
		fallback.grab_focus()
		fallback.pressed.emit()
		viewport.set_input_as_handled()


func speedbike_player_midpoint() -> Vector2:
	return player_speedbike.bike_midpoint()


func speedbike_player_y() -> float:
	return player_speedbike.position.y


func speedbike_view_width() -> float:
	return maxf(screen_size.x, 640.0)


func speedbike_spawn_x(lead: float) -> float:
	return _camera_right() + lead


func speedbike_enemy_fire_interval_scale() -> float:
	if boss_encounter_started and not boss_complete:
		return _boss_fire_interval_mult()
	var speed_ratio := clampf((camera_scroll_speed - 700.0) / 650.0, 0.0, 1.0)
	return lerpf(1.0, 0.78, speed_ratio)


func speedbike_enemy_health_scale() -> float:
	match str(difficulty_row.get("id", "veteran")):
		"recruit":
			return 0.92
		"nightmare":
			return 1.42
		"classic":
			return 1.58
		_:
			return 1.16


func speedbike_boss_bullet_speed(base_speed: float) -> float:
	return base_speed * _boss_bullet_speed_mult()


func _boss_bullet_speed_mult() -> float:
	match str(difficulty_row.get("id", "veteran")):
		"recruit":
			return 0.95
		"nightmare":
			return 1.45
		"classic":
			return 1.58
		_:
			return 1.25


func _boss_fire_interval_mult() -> float:
	match str(difficulty_row.get("id", "veteran")):
		"recruit":
			return 1.12
		"nightmare":
			return 0.68
		"classic":
			return 0.60
		_:
			return 0.82


func _boss_extra_shots_per_volley() -> int:
	match str(difficulty_row.get("id", "veteran")):
		"nightmare":
			return 1
		"classic":
			return 2
		_:
			return 0


func speedbike_top_bound() -> float:
	return lane_positions[0] - LANE_HALF_HEIGHT


func speedbike_bottom_bound() -> float:
	return lane_positions[LANE_COUNT - 1] + LANE_HALF_HEIGHT


func speedbike_lane_y(index: int) -> float:
	return lane_positions[clampi(index, 0, lane_positions.size() - 1)]


func speedbike_lane_top(index: int) -> float:
	return speedbike_lane_y(index) - LANE_HALF_HEIGHT


func speedbike_lane_bottom(index: int) -> float:
	return speedbike_lane_y(index) + LANE_HALF_HEIGHT


func speedbike_lane_span() -> float:
	return LANE_HALF_HEIGHT * 2.0


func register_speedbike_obstacle(obstacle) -> void:
	obstacle_layer.add_child(obstacle)
	active_obstacles.append(obstacle)


func register_speedbike_drone(drone) -> void:
	enemy_layer.add_child(drone)
	active_drones.append(drone)


func spawn_enemy_bullet(origin: Vector2, direction: Vector2 = Vector2.LEFT, speed: float = ENEMY_BULLET_SPEED, radius: float = 9.0, kind: String = "bullet", screen_relative: bool = false) -> void:
	var effective_speed := _enemy_bullet_screen_speed(speed, kind, screen_relative)
	var velocity := direction.normalized() * effective_speed
	if velocity.length_squared() <= 1.0:
		velocity = Vector2(-effective_speed, 0.0)
	if screen_relative:
		velocity.x += camera_scroll_speed
	elif velocity.x < 0.0:
		velocity.x += camera_scroll_speed
	enemy_bullets.append({
		"position": origin,
		"velocity": velocity,
		"radius": radius,
		"kind": kind,
		"health": 3 if kind == "missile" else 1,
		"speed": effective_speed,
		"turn_rate": 2.6 if kind == "missile" else 0.0,
		"screen_relative": screen_relative
	})


func spawn_enemy_powerup_shot(origin: Vector2, direction: Vector2 = Vector2.LEFT, speed: float = 420.0, pickup_kind: String = "") -> void:
	var hazard_kind := pickup_kind
	if hazard_kind.is_empty():
		hazard_kind = str(PICKUP_KINDS[randi() % PICKUP_KINDS.size()])
	# If it looks like a powerup, it should be fair: no more hidden bomb pickups.
	var drift := clampf(speed * 0.42, PICKUP_SCREEN_DRIFT_SPEED, COIN_SCREEN_DRIFT_SPEED + 90.0)
	_spawn_pickup_at(hazard_kind, origin, drift)


func _enemy_bullet_screen_speed(base_speed: float, kind: String, screen_relative: bool) -> float:
	if screen_relative:
		return base_speed
	match kind:
		"missile":
			return clampf(base_speed, 320.0, 460.0)
		"boss_bullet", "boss_chain_bullet":
			return clampf(base_speed, 380.0, 560.0)
		_:
			return clampf(base_speed, ENEMY_BULLET_SCREEN_SPEED_MIN, ENEMY_BULLET_SCREEN_SPEED_MAX)


func spawn_enemy_homing_missile(origin: Vector2, speed: float = 430.0, screen_relative: bool = false) -> void:
	var target: Vector2 = player_speedbike.bike_midpoint()
	var direction: Vector2 = (target - origin).normalized()
	if direction.length_squared() <= 0.1:
		direction = Vector2.LEFT
	spawn_enemy_bullet(origin, direction, speed, 16.0, "missile", screen_relative)


func spawn_dropper_barrier(drone) -> void:
	var shape := str(drone.payload.get("drop_shape", "center"))
	var lane := clampi(int(drone.payload.get("drop_lane", drone.lane)), 0, 4)
	_show_warning(DROPPER_WARNING_TEXT, 0.8)
	_play_sfx(WARNING_SOUND_PATH, -8.0, 1.0)
	if shape == "low":
		obstacle_spawner.spawn_event({
			"kind": "low_barricade",
			"spawn_x": drone.position.x - 24.0,
			"lane": lane,
			"width": 124.0
		})
		return
	obstacle_spawner.spawn_event({
		"kind": "block",
		"shape": shape,
		"spawn_x": drone.position.x - 24.0,
		"gap_lane": clampi(int(drone.payload.get("gap_lane", 2)), 1, 3),
		"width": float(drone.payload.get("barrier_width", 106.0))
	})


func spawn_oil_spill(drone) -> void:
	if drone == null or not is_instance_valid(drone):
		return
	var lane := _nearest_speedbike_lane(drone.position.y)
	obstacle_spawner.spawn_event({
		"kind": "oil_spill",
		"spawn_x": drone.position.x - 42.0,
		"lane": lane,
		"y": clampf(drone.position.y + 30.0, speedbike_top_bound() + 8.0, speedbike_bottom_bound() + 12.0),
		"width": 128.0
	})
	_show_warning("OIL DROP", 0.7)
	_spawn_burst_fx(drone.position + Vector2(-18.0, 26.0), Color(0.08, 0.08, 0.05, 0.72), 0.36)


func _nearest_speedbike_lane(world_y: float) -> int:
	var best_lane := 0
	var best_dist := INF
	for lane_index in range(lane_positions.size()):
		var dist := absf(world_y - lane_positions[lane_index])
		if dist < best_dist:
			best_dist = dist
			best_lane = lane_index
	return best_lane


func handle_non_spawn_event(event: Dictionary) -> void:
	var kind := str(event.get("kind", ""))
	match kind:
		"warning", "tutorial_text":
			_show_warning(str(event.get("message", event.get("text", "MOVE"))), float(event.get("duration", 1.5)))
		"checkpoint":
			if checkpoints_enabled and _should_accept_event_checkpoint():
				_commit_checkpoint(pattern_runner.next_index + 1)
				score += 500
				checkpoint_count += 1
				last_event_checkpoint_elapsed = stage_elapsed
				if section_hitless:
					score += 1000
					_spawn_text_popup("NO-HIT SECTION", player_speedbike.bike_midpoint() + Vector2(0.0, -48.0), Color(1.0, 0.94, 0.62, 0.96))
				section_hitless = true
		"invert_on":
			player_speedbike.set_vertical_inverted(false)
			_show_warning("SIGNAL SURGE", 1.0)
		"invert_off":
			player_speedbike.set_vertical_inverted(false)
			_show_warning("SIGNAL CLEAR", 0.8)
		"blackout_on":
			blackout_strength = clampf(float(event.get("strength", 0.78)), 0.0, 1.0)
			_show_warning(str(event.get("message", "BLACKOUT TUBE")), 1.0)
		"blackout_off":
			blackout_strength = 0.0
		"speed_boost":
			stage_speed_bonus = maxf(stage_speed_bonus, float(event.get("bonus", 120.0)))
			_show_warning(str(event.get("message", "OVERDRIVE")), 0.9)
		"speed_reset":
			stage_speed_bonus = 0.0
		"tip":
			tip_text = str(event.get("text", tip_text))
		"boss_intro":
			_begin_boss_intro()
		_:
			pass


func _tick_obstacles(delta: float) -> void:
	for obstacle in active_obstacles:
		obstacle.tick(delta)


func _tick_drones(delta: float) -> void:
	for drone in active_drones:
		if not is_instance_valid(drone):
			continue
		drone.tick(delta, _camera_left(), camera_scroll_speed)
		if not drone.destroyed and _drone_hits_runtime_hazard(drone):
			drone.destroyed = true
			_spawn_burst_fx(drone.position, Color(1.0, 0.42, 0.18, 0.88), 0.52)
			_play_sfx(CRASH_SOUND_PATH, -12.0, 1.12)


func _tick_oil_dropper_pressure(delta: float) -> void:
	if not stage_started or stage_cleared or stage_transition_live or boss_encounter_started:
		return
	oil_dropper_timer -= delta
	if oil_dropper_timer > 0.0:
		return
	var speed_ratio := clampf((camera_scroll_speed - 720.0) / 720.0, 0.0, 1.0)
	oil_dropper_timer = randf_range(12.0 - speed_ratio * 4.0, 22.0 - speed_ratio * 8.0)
	if randf() > lerpf(0.38, 0.68, speed_ratio):
		return
	var player_lane := _nearest_speedbike_lane(player_speedbike.position.y)
	var lane := clampi(player_lane + randi_range(-1, 1), 0, LANE_COUNT - 1)
	obstacle_spawner.spawn_event({
		"kind": "drone",
		"spawn_x": _camera_right() + 560.0,
		"lane": lane,
		"enemy_type": "oil_dropper",
		"health": 3,
		"shoot_interval": 999.0,
		"screen_hold_time": 5.5,
		"drop_delay": 2.0,
		"score_value": 400
	})
	_show_warning("OIL FLYER", 0.8)


func _drone_hits_runtime_hazard(drone) -> bool:
	if drone == null or not is_instance_valid(drone) or drone.destroyed:
		return false
	var drone_type := str(drone.drone_type)
	if drone_type in ["powerup", "minizorg"]:
		return false
	var drone_rect: Rect2 = drone.hurtbox_rect()
	for obstacle in active_obstacles:
		if not is_instance_valid(obstacle) or obstacle.destroyed:
			continue
		if str(obstacle.obstacle_type) == "ramp":
			continue
		if str(obstacle.obstacle_type) == "oil_spill":
			continue
		if obstacle.has_method("collides_with_rect") and bool(obstacle.call("collides_with_rect", drone_rect)):
			return true
	return false


func _refresh_boss_minion_slots(delta: float) -> void:
	for drone in active_drones:
		if not is_instance_valid(drone):
			continue
		if str(drone.drone_type) != "minizorg":
			continue
		if drone.has_method("refresh_boss_minion_anchor"):
			drone.refresh_boss_minion_anchor(delta)


func _tick_projectiles(delta: float) -> void:
	for bullet in player_bullets:
		bullet["position"] = (bullet.get("position", Vector2.ZERO) as Vector2) + (bullet.get("velocity", Vector2.ZERO) as Vector2) * delta
	for bullet in enemy_bullets:
		var kind := str(bullet.get("kind", "bullet"))
		var bullet_position := bullet.get("position", Vector2.ZERO) as Vector2
		var bullet_velocity := bullet.get("velocity", Vector2.ZERO) as Vector2
		bullet["time"] = float(bullet.get("time", 0.0)) + delta
		if kind == "missile":
			var target: Vector2 = player_speedbike.bike_midpoint()
			var desired: Vector2 = (target - bullet_position).normalized()
			if desired.length_squared() <= 0.1:
				desired = Vector2.LEFT
			var desired_velocity: Vector2 = desired * float(bullet.get("speed", 430.0))
			if bool(bullet.get("screen_relative", false)):
				desired_velocity.x += camera_scroll_speed
			elif desired_velocity.x < 0.0:
				desired_velocity.x += camera_scroll_speed
			bullet_velocity = bullet_velocity.lerp(desired_velocity, clampf(float(bullet.get("turn_rate", 2.6)) * delta, 0.0, 1.0))
			bullet["velocity"] = bullet_velocity
		bullet["position"] = bullet_position + bullet_velocity * delta

	for bullet_index in range(player_bullets.size() - 1, -1, -1):
		var bullet := player_bullets[bullet_index]
		var bullet_position := bullet.get("position", Vector2.ZERO) as Vector2
		var bullet_kind := str(bullet.get("kind", "normal"))
		var bullet_radius := maxf(float(bullet.get("radius", 10.0)), 4.0)
		var bullet_damage := maxi(int(bullet.get("damage", 1)), 1)
		var bullet_rect := Rect2(bullet_position - Vector2(bullet_radius, bullet_radius * 0.55), Vector2(bullet_radius * 2.0, bullet_radius * 1.1))
		if bullet_kind in ["rocket", "fireball"]:
			bullet_rect = Rect2(bullet_position - Vector2(bullet_radius, bullet_radius), Vector2(bullet_radius * 2.0, bullet_radius * 2.0))
		var consumed := false
		for enemy_index in range(enemy_bullets.size() - 1, -1, -1):
			var enemy_bullet := enemy_bullets[enemy_index]
			if str(enemy_bullet.get("kind", "bullet")) != "missile":
				continue
			var missile_pos := enemy_bullet.get("position", Vector2.ZERO) as Vector2
			var missile_rect := Rect2(missile_pos - Vector2(18.0, 14.0), Vector2(36.0, 28.0))
			if not missile_rect.intersects(bullet_rect):
				continue
			consumed = true
			enemy_bullet["health"] = int(enemy_bullet.get("health", 1)) - bullet_damage
			if int(enemy_bullet.get("health", 0)) <= 0:
				enemy_bullets.remove_at(enemy_index)
				score += 160
				_spawn_burst_fx(missile_pos, Color(1.0, 0.48, 0.18, 0.92), 0.42)
			else:
				enemy_bullets[enemy_index] = enemy_bullet
			break
		if consumed:
			player_bullets.remove_at(bullet_index)
			continue
		for drone_index in range(active_drones.size() - 1, -1, -1):
			var drone = active_drones[drone_index]
			if drone.hit_by_projectile(bullet_rect):
				consumed = true
				for extra_hit in range(bullet_damage - 1):
					if drone.destroyed:
						break
					drone.hit_by_projectile(bullet_rect)
				if drone.destroyed:
					drones_destroyed += 1
					score += drone.score_value
					_spawn_burst_fx(drone.position, Color(1.0, 0.54, 0.18, 0.84), 0.55)
					if drone.drone_type == "powerup":
						_spawn_pickup_from_carrier(drone)
						_play_sfx(CARRIER_SOUND_PATH, -8.0, 1.0)
					else:
						_maybe_spawn_pickup_from_destroyed_enemy(drone)
				break
		if not consumed and boss_encounter_started and not boss_complete and boss_alpha > 0.35 and boss_state in ["entrance", "attack", "returning"]:
			var hit_part := _boss_hit_part_for_bullet(bullet_rect)
			if not hit_part.is_empty():
				consumed = true
				_damage_boss_part(hit_part, bullet_damage, bullet_rect.get_center())
			elif _boss_body_hit_without_weakpoint(bullet_rect):
				consumed = true
				_spawn_burst_fx(bullet_rect.get_center(), Color(0.72, 0.72, 0.82, 0.42), 0.22)
		if not consumed:
			for obstacle in active_obstacles:
				if obstacle.hit_by_projectile(bullet_rect, bullet_kind, bullet_damage):
					consumed = true
					if obstacle.destroyed:
						score += obstacle.score_value
						_spawn_burst_fx(bullet_rect.get_center(), Color(1.0, 0.64, 0.28, 0.84), 0.42)
					else:
						_spawn_burst_fx(bullet_rect.get_center(), Color(1.0, 0.78, 0.34, 0.54), 0.20)
					break
		if consumed or bullet_rect.position.x > _camera_right() + 120.0:
			player_bullets.remove_at(bullet_index)

	for bullet_index in range(enemy_bullets.size() - 1, -1, -1):
		var bullet := enemy_bullets[bullet_index]
		var bullet_position := bullet.get("position", Vector2.ZERO) as Vector2
		var bullet_kind := str(bullet.get("kind", "bullet"))
		var bullet_rect := Rect2(bullet_position - Vector2(16.0, 12.0), Vector2(32.0, 24.0)) if bullet_kind == "missile" else Rect2(bullet_position - Vector2(8.0, 8.0), Vector2(16.0, 16.0))
		if bullet_kind == "enemy_powerup":
			bullet_rect = Rect2(bullet_position - Vector2(18.0, 18.0), Vector2(36.0, 36.0))
		if bullet_rect.position.x < _camera_left() - 80.0:
			enemy_bullets.remove_at(bullet_index)
			continue
		if bullet_rect.intersects(player_speedbike.hurtbox_rect()):
			enemy_bullets.remove_at(bullet_index)
			if bullet_kind == "enemy_powerup":
				_apply_pickup(str(bullet.get("pickup_kind", "score_medal")))
				pickups_collected += 1
				continue
			var hit_source := bullet_kind
			if bullet_kind not in ["missile", "boss_bullet", "boss_chain_bullet"]:
				hit_source = "bullet"
			_handle_player_hit(hit_source, bullet_position)


func _tick_pickups(delta: float) -> void:
	for pickup_index in range(active_pickups.size() - 1, -1, -1):
		var pickup := active_pickups[pickup_index]
		var pos := pickup.get("position", Vector2.ZERO) as Vector2
		var age := float(pickup.get("time", 0.0)) + delta
		var base_y := float(pickup.get("base_y", pos.y))
		var drift_speed := float(pickup.get("drift_speed", PICKUP_SCREEN_DRIFT_SPEED))
		pos.x += (camera_scroll_speed - drift_speed) * delta
		pos.y = base_y + sin(age * 5.2) * 10.0
		pickup["time"] = age
		pickup["position"] = pos
		active_pickups[pickup_index] = pickup
		var pickup_rect := Rect2(pos - Vector2(29.0, 29.0), Vector2(58.0, 58.0))
		if pickup_rect.intersects(player_speedbike.hurtbox_rect()):
			_apply_pickup(str(pickup.get("kind", "score_medal")), pickup)
			pickups_collected += 1
			_play_sfx(PICKUP_SOUND_PATH, -7.0, 1.0)
			active_pickups.remove_at(pickup_index)
		elif pickup_rect.position.x < _camera_left() - 96.0:
			active_pickups.remove_at(pickup_index)


func _tick_fx(delta: float) -> void:
	for fx_index in range(active_fx.size() - 1, -1, -1):
		var fx := active_fx[fx_index]
		fx["time"] = float(fx.get("time", 0.0)) + delta
		if str(fx.get("kind", "burst")) == "ash":
			var position := fx.get("position", Vector2.ZERO) as Vector2
			var velocity := fx.get("velocity", Vector2.ZERO) as Vector2
			velocity += Vector2(-18.0, 16.0) * delta
			fx["velocity"] = velocity
			fx["position"] = position + velocity * delta
			active_fx[fx_index] = fx
		if float(fx.get("time", 0.0)) >= float(fx.get("life", 0.3)):
			active_fx.remove_at(fx_index)


func _resolve_collisions() -> void:
	var player_rect: Rect2 = player_speedbike.hurtbox_rect()
	if _boss_eye_beam_player_hit(player_rect):
		_handle_player_hit("boss_eye_beam", player_rect.get_center())
		return
	if _boss_laser_player_hit(player_rect):
		_handle_player_hit("boss_laser", player_rect.get_center())
		return
	for obstacle in active_obstacles:
		var report: Dictionary = obstacle.hit_report(player_rect, player_speedbike.jump_z)
		if bool(report.get("launch", false)):
			var big_jump := bool(report.get("big_jump", false))
			player_speedbike.launch_from_ramp(big_jump)
			_spawn_burst_fx(player_rect.get_center() + Vector2(-12.0, 24.0), Color(1.0, 0.72, 0.26, 0.58), 0.44 if big_jump else 0.28)
			continue
		if bool(report.get("spinout", false)):
			player_speedbike.apply_spinout(2.15)
			section_hitless = false
			_spawn_burst_fx(player_rect.get_center() + Vector2(0.0, 18.0), Color(0.08, 0.08, 0.05, 0.62), 0.44)
			_show_warning("OIL SPINOUT", 0.8)
			continue
		if bool(report.get("hit", false)):
			_handle_player_hit(obstacle.obstacle_type, player_rect.get_center())
			return
		if obstacle.near_miss_ready(player_rect):
			obstacle.mark_near_miss_awarded()
			score += 50
			_spawn_text_popup("NEAR MISS", player_rect.get_center() + Vector2(0.0, -36.0), Color(1.0, 0.88, 0.62, 0.94))
	for drone in active_drones:
		if drone.player_hit(player_rect):
			_handle_player_hit("drone", drone.position)
			return


func _cleanup_runtime_objects() -> void:
	for obstacle_index in range(active_obstacles.size() - 1, -1, -1):
		var obstacle = active_obstacles[obstacle_index]
		if obstacle.destroyed:
			obstacle.queue_free()
			active_obstacles.remove_at(obstacle_index)
			continue
		if obstacle.is_finished(_camera_left(), screen_size.x):
			if not obstacle.scored:
				score += obstacle.score_value
				obstacle.scored = true
			obstacle.queue_free()
			active_obstacles.remove_at(obstacle_index)
	for drone_index in range(active_drones.size() - 1, -1, -1):
		var drone = active_drones[drone_index]
		if drone.destroyed or drone.is_finished(_camera_left()):
			drone.queue_free()
			active_drones.remove_at(drone_index)


func _check_stage_clear() -> void:
	if stage_cleared or stage_transition_live:
		return
	if _stage_has_boss() and not boss_complete:
		return
	if pattern_runner.is_stage_finished() and active_obstacles.is_empty() and active_drones.is_empty() and enemy_bullets.is_empty():
		_complete_stage()


func _handle_player_hit(source: String, hit_position: Vector2) -> void:
	if invuln_timer > 0.0 or crash_restart_timer > 0.0 or stage_cleared or stage_transition_live:
		return
	section_hitless = false
	if source == "boss_eye_beam":
		_trigger_disintegration_crash(hit_position)
		return
	if shield_hits > 0:
		shield_hits -= 1
		invuln_timer = 0.8
		current_hits_flash = 0.5
		_spawn_burst_fx(hit_position, Color(0.58, 0.92, 1.0, 0.76), 0.45)
		_show_warning("SHIELD BURNED OFF", 0.7)
		return
	var hard_crash := source in ["pit", "block", "laser_gate", "moving_gate", "low_barricade", "boss_laser", "boss_eye_beam"]
	var projectile_hit := source in ["bullet", "boss_bullet", "boss_chain_bullet", "missile", "powerup_blast"]
	var instant_crash := bool(difficulty_row.get("instant_crash", false))
	var damage := _speedbike_projectile_damage(source)
	if hard_crash or (instant_crash and not projectile_hit):
		_trigger_crash(hit_position)
		return
	if remaining_hits <= damage:
		_trigger_crash(hit_position)
		return
	remaining_hits = max(remaining_hits - damage, 1)
	invuln_timer = 1.0
	current_hits_flash = 0.6
	player_speedbike.position.x = maxf(player_speedbike.position.x - 84.0, _camera_left() + 120.0)
	_spawn_burst_fx(hit_position, Color(1.0, 0.72, 0.22, 0.78), 0.4)
	_show_warning("BIKE ARMOR STRIPPED", 0.6)


func _speedbike_projectile_damage(source: String) -> int:
	match source:
		"missile", "powerup_blast":
			return 2
		"boss_bullet", "boss_chain_bullet":
			return 1
		_:
			return 1


func _trigger_crash(hit_position: Vector2) -> void:
	if crash_restart_timer > 0.0:
		return
	player_speedbike.set_control_locked(true)
	player_speedbike.set_crashed(true)
	crashes += 1
	deaths += 1
	stage_run_crashes += 1
	stage_run_deaths += 1
	crash_restart_timer = CRASH_RESTART_DELAY
	flash_alpha = 0.82
	_spawn_burst_fx(hit_position, Color(1.0, 0.34, 0.18, 0.94), 0.85)
	_play_sfx(CRASH_SOUND_PATH, -4.0, 1.0)
	_show_warning("BIKE LOST - RESETTING", 0.7)


func _trigger_disintegration_crash(hit_position: Vector2) -> void:
	if crash_restart_timer > 0.0:
		return
	player_speedbike.set_control_locked(true)
	player_speedbike.set_crashed(true)
	crashes += 1
	deaths += 1
	stage_run_crashes += 1
	stage_run_deaths += 1
	crash_restart_timer = CRASH_RESTART_DELAY
	flash_alpha = 0.95
	_spawn_ash_fx(hit_position)
	_play_sfx(CRASH_SOUND_PATH, -2.0, 0.62)
	_show_warning("DISINTEGRATED", 0.85)


func _restart_from_checkpoint() -> void:
	if not checkpoints_enabled:
		var saved_stage_run_deaths := stage_run_deaths
		var saved_stage_run_crashes := stage_run_crashes
		var saved_weapon_kind := speedbike_weapon_kind
		var saved_weapon_timer := speedbike_weapon_timer
		var saved_weapon_ammo := speedbike_weapon_ammo
		var saved_gold_coins := gold_coins_collected
		var saved_blue_coins := blue_coins_collected
		var saved_blue_coin_ids := blue_coin_ids_collected.duplicate(true)
		_start_stage()
		stage_run_deaths = saved_stage_run_deaths
		stage_run_crashes = saved_stage_run_crashes
		speedbike_weapon_kind = saved_weapon_kind
		speedbike_weapon_timer = saved_weapon_timer
		speedbike_weapon_ammo = saved_weapon_ammo
		gold_coins_collected = saved_gold_coins
		blue_coins_collected = saved_blue_coins
		blue_coin_ids_collected = saved_blue_coin_ids
		_refresh_speedbike_weapon_controller_boost()
		invuln_timer = 0.9
		flash_alpha = 0.24
		_show_warning("RESTARTED FROM STAGE START", 0.8)
		return
	_clear_runtime_objects()
	var camera_x := float(current_checkpoint.get("camera_x", screen_size.x * 0.5))
	speedbike_camera.position = Vector2(camera_x, screen_size.y * 0.5)
	stage_elapsed = float(current_checkpoint.get("elapsed", 0.0))
	stage_speed_bonus = float(current_checkpoint.get("speed_bonus", 0.0))
	score = int(current_checkpoint.get("score", score))
	speedbike_bonus_health_slots = int(current_checkpoint.get("bonus_health_slots", speedbike_bonus_health_slots))
	_apply_selected_rider_profile()
	remaining_hits = int(current_checkpoint.get("remaining_hits", max_hits))
	shield_hits = int(current_checkpoint.get("shield_hits", shield_hits))
	pattern_runner.reset_to_state(stage_elapsed, int(current_checkpoint.get("next_index", 0)))
	player_speedbike.set_crashed(false)
	player_speedbike.set_control_locked(false)
	player_speedbike.set_vertical_inverted(false)
	player_speedbike.reset_for_stage(_camera_left(), float(current_checkpoint.get("player_y", speedbike_lane_y(2))))
	speedbike_weapon_kind = str(current_checkpoint.get("weapon_kind", speedbike_weapon_kind))
	speedbike_weapon_timer = float(current_checkpoint.get("weapon_timer", speedbike_weapon_timer))
	speedbike_weapon_ammo = int(current_checkpoint.get("weapon_ammo", speedbike_weapon_ammo))
	_refresh_speedbike_weapon_controller_boost()
	last_safe_y = player_speedbike.position.y
	crash_restart_timer = -1.0
	invuln_timer = 0.9
	flash_alpha = 0.24
	checkpoint_splash_timer = 0.0
	checkpoint_splash_text = ""
	section_hitless = false
	_prepare_blue_coin_stage_schedule()
	_mark_past_blue_coins_spawned(stage_elapsed)
	if bool(current_checkpoint.get("boss_encounter_started", false)) and not bool(current_checkpoint.get("boss_complete", false)):
		_restore_boss_from_checkpoint()
	_update_hud()


func _commit_checkpoint(next_event_index: int = -1) -> void:
	var saved_next_index: int = pattern_runner.next_index if next_event_index < 0 else next_event_index
	current_checkpoint = {
		"camera_x": speedbike_camera.position.x,
		"player_y": last_safe_y,
		"elapsed": stage_elapsed,
		"next_index": saved_next_index,
		"score": score,
		"gold_coins": gold_coins_collected,
		"blue_coins": blue_coins_collected,
		"blue_coin_ids": blue_coin_ids_collected.duplicate(true),
		"bonus_health_slots": speedbike_bonus_health_slots,
		"remaining_hits": remaining_hits,
		"shield_hits": shield_hits,
		"weapon_kind": speedbike_weapon_kind,
		"weapon_timer": speedbike_weapon_timer,
		"weapon_ammo": speedbike_weapon_ammo,
		"speed_bonus": stage_speed_bonus,
		"boss_encounter_started": boss_encounter_started,
		"boss_complete": boss_complete,
		"boss_health": boss_health,
		"boss_phase": boss_damage_phase,
		"boss_arena_scroll_speed": boss_arena_scroll_speed,
		"boss_shield_health": boss_shield_health,
		"boss_cannon_health": boss_cannon_health,
		"boss_dome_health": boss_dome_health
	}


func _restore_boss_from_checkpoint() -> void:
	boss_encounter_started = true
	boss_complete = false
	boss_health = maxi(int(current_checkpoint.get("boss_health", BOSS_MAX_HEALTH)), 1)
	boss_damage_phase = str(current_checkpoint.get("boss_phase", "shield"))
	boss_arena_scroll_speed = maxf(float(current_checkpoint.get("boss_arena_scroll_speed", camera_scroll_speed)), BOSS_ARENA_SCROLL_SPEED)
	boss_shield_health = maxi(int(current_checkpoint.get("boss_shield_health", BOSS_SHIELD_HEALTH)), 0)
	boss_cannon_health = maxi(int(current_checkpoint.get("boss_cannon_health", BOSS_CANNON_HEALTH)), 0)
	boss_dome_health = maxi(int(current_checkpoint.get("boss_dome_health", BOSS_DOME_HEALTH)), 0)
	boss_cutscene_lock = true
	boss_dialog_open = false
	boss_state = "returning"
	boss_alpha = 0.0
	boss_phase_timer = 0.0
	boss_phase_teleports_done = 0
	boss_attack_pattern_step = 0
	boss_contact_hit_timer = 0.0
	boss_position = Vector2(_camera_right() - BOSS_SCREEN_X_OFFSET, speedbike_lane_y(2) - 40.0)
	boss_target_position = _boss_target_position()
	player_speedbike.set_control_locked(true)
	enemy_bullets.clear()
	boss_minion_spawn_visuals.clear()
	_refill_boss_music_cycle()
	_play_next_boss_music_track()
	_refresh_boss_damage_phase(false)


func _boss_hurtbox_rect() -> Rect2:
	var size := Vector2(360.0, 212.0)
	return Rect2(boss_position.x - size.x * 0.5, boss_position.y - size.y * 0.5, size.x, size.y)


func _complete_stage() -> void:
	var perfect_bonus: int = 5000 if stage_run_deaths == 0 else 0
	score += perfect_bonus
	if _chapter_has_next_stage():
		stage_transition_live = true
		player_speedbike.set_control_locked(false)
		player_speedbike.set_crashed(false)
		_begin_next_stage_transition()
		return
	stage_cleared = true
	player_speedbike.set_control_locked(true)
	player_speedbike.set_crashed(false)
	last_rank = _compute_rank(chapter_elapsed_total, deaths, maxf(chapter_target_duration, stage_duration))
	result_title.text = "CHAPTER CLEAR"
	result_body.text = "[center][b]CHAPTER CLEAR[/b]\n%s\n\nTIME  %s\nDEATHS  %d\nCRASHES  %d\nDRONES DESTROYED  %d\nPICKUPS  %d\nGOLD COINS  %d\nBLUE COINS  %d/%d\nSCORE  %d\nRANK  %s\n\nCLIP THIS:\n\"%s\"[/center]" % [
		_stage_display_label(stage_map_id),
		_time_text(chapter_elapsed_total),
		deaths,
		crashes,
		drones_destroyed,
		pickups_collected,
		gold_coins_collected,
		blue_coins_collected,
		BLUE_COIN_TOTAL,
		score,
		last_rank,
		"I survived Beldar's Last Tunnel." if stage_map_id == BOSS_STAGE_ID else "I cleared the Badlands Speedbike Gauntlet."
	]
	result_panel.visible = true
	result_ready_for_continue = true
	if story_route:
		result_continue_button.text = "CONTINUE OP"
	else:
		result_continue_button.text = "RUN CHAPTER AGAIN"
	result_continue_button.grab_focus()
	_play_sfx(PICKUP_SOUND_PATH, -6.0, 0.92)


func _begin_next_stage_transition() -> void:
	var next_stage_id := _next_chapter_stage_id()
	var next_label := _stage_display_label(next_stage_id).to_upper()
	stage_chain_carry_speed = camera_scroll_speed
	stage_chain_carry_camera_x = speedbike_camera.position.x
	stage_chain_carry_player_y = player_speedbike.position.y
	stage_chain_carry_player_x_offset = player_speedbike.position.x - _camera_left()
	flash_alpha = maxf(flash_alpha, 0.32)
	_clear_runtime_objects()
	result_panel.visible = false
	result_ready_for_continue = false
	if _should_show_merchant_stop():
		_begin_merchant_transition(next_label)
		return
	chapter_transition_timer = STAGE_CHAIN_TRANSITION_DELAY
	warning_text = "NEXT STAGE"
	warning_text_timer = STAGE_CHAIN_TRANSITION_DELAY
	tip_text = "NEXT UP  %s" % next_label
	_play_sfx(PICKUP_SOUND_PATH, -7.0, 0.94)


func _advance_to_next_stage() -> void:
	if not _chapter_has_next_stage():
		chapter_transition_timer = -1.0
		return
	stage_chain_carry_speed = camera_scroll_speed
	stage_chain_carry_camera_x = speedbike_camera.position.x
	stage_chain_carry_player_y = player_speedbike.position.y
	stage_chain_carry_player_x_offset = player_speedbike.position.x - _camera_left()
	stage_transition_live = false
	chapter_stage_index += 1
	stage_map_id = str(chapter_stage_ids[chapter_stage_index])
	_sync_active_stage_state()
	_load_stage_payload()
	_start_stage(true)


func _compute_rank(elapsed: float, death_count: int, target_duration: float) -> String:
	if death_count == 0 and crashes == 0:
		return "S+"
	var time_ratio := elapsed / maxf(target_duration, 1.0)
	if death_count <= 1 and time_ratio <= 1.05:
		return "S"
	if death_count <= 3 and time_ratio <= 1.18:
		return "A"
	if death_count <= 6:
		return "B"
	return "C"


func _on_results_continue_pressed() -> void:
	if story_route:
		var progress: Dictionary = PlayState.advance_story_segment()
		if bool(progress.get("advanced", false)):
			var target_scene := str(PlayState.selected_story_launch_scene())
			get_tree().change_scene_to_file(target_scene)
			return
		_return_to_war_room()
		return
	_restart_chapter_run()


func _reload_current_stage() -> void:
	get_tree().reload_current_scene()


func _restart_chapter_run() -> void:
	stage_map_id = chapter_start_stage_id
	chapter_stage_index = maxi(chapter_stage_ids.find(stage_map_id), 0)
	chapter_elapsed_total = 0.0
	deaths = 0
	crashes = 0
	drones_destroyed = 0
	pickups_collected = 0
	score = 0
	stage_started = false
	stage_cleared = false
	stage_transition_live = false
	chapter_transition_timer = -1.0
	stage_run_deaths = 0
	stage_run_crashes = 0
	_sync_active_stage_state()
	_load_stage_payload()
	_open_character_select()


func _toggle_pause() -> void:
	pause_open = not pause_open
	pause_panel.visible = pause_open
	_clear_speedbike_touch_states()
	player_speedbike.set_control_locked(pause_open)
	get_tree().paused = pause_open
	if pause_open:
		pause_current_tab = "main"
		if selection_open:
			pause_title.text = "SPEEDBIKE OPTIONS\nRIDER SELECT"
			pause_resume_button.text = "BACK TO RIDERS"
		elif stage_cleared:
			pause_title.text = "SPEEDBIKE OPTIONS\nRESULTS"
			pause_resume_button.text = "BACK TO RESULTS"
		else:
			pause_title.text = "SPEEDBIKE PAUSED\n%s" % stage_name
			pause_resume_button.text = "RESUME RUN"
		_sync_speedbike_pause_controls()
		_apply_speedbike_mobile_layout()
		_focus_speedbike_pause_default_control()
	else:
		get_tree().paused = false
		speedbike_touch_layout_edit_mode = false
		_sync_speedbike_touch_controls()


func _resume_from_pause() -> void:
	get_tree().paused = false
	pause_open = false
	pause_panel.visible = false
	speedbike_touch_layout_edit_mode = false
	_clear_speedbike_touch_states()
	player_speedbike.set_control_locked(false)
	_sync_speedbike_touch_controls()


func _return_to_war_room() -> void:
	get_tree().paused = false
	selection_open = false
	pause_open = false
	speedbike_touch_layout_edit_mode = false
	_clear_speedbike_touch_states()
	character_select_panel.visible = false
	character_select_shade.visible = false
	result_panel.visible = false
	get_tree().change_scene_to_file(PlayState.APP_SHELL_SCENE)


func _exit_to_emulationstation() -> void:
	get_tree().paused = false
	get_tree().quit()


func _prepare_blue_coin_stage_schedule() -> void:
	blue_coin_spawn_schedule.clear()
	if _stage_has_boss():
		return
	var stage_number := _chapter_stage_number()
	for coin_id in _blue_coin_ids_for_stage(stage_number):
		if blue_coin_ids_collected.has(str(coin_id)):
			continue
		var seed_text := "%s:%d:%d" % [chapter_start_stage_id, stage_number, coin_id]
		var raw_hash := int(hash(seed_text))
		if raw_hash < 0:
			raw_hash = -raw_hash
		var time_ratio := float(raw_hash % 1000) / 999.0
		var lane_index := int(raw_hash / 1000) % LANE_COUNT
		var spawn_time := lerpf(stage_duration * 0.22, stage_duration * 0.82, time_ratio)
		var y_jitter_index := int(raw_hash / 7000) % 5
		var lane_y := speedbike_lane_y(lane_index) + float(y_jitter_index - 2) * 7.0
		blue_coin_spawn_schedule.append({
			"id": coin_id,
			"time": spawn_time,
			"y": clampf(lane_y, speedbike_top_bound() + 18.0, speedbike_bottom_bound() - 18.0),
			"spawned": false
		})
	blue_coin_spawn_schedule.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("time", 0.0)) < float(b.get("time", 0.0))
	)


func _blue_coin_ids_for_stage(stage_number: int) -> Array[int]:
	var ids: Array[int] = []
	var stage_span := maxi(_chapter_stage_total() - 1, 1)
	var denominator := maxi(BLUE_COINS_BEFORE_BOSS - 1, 1)
	for coin_id in range(1, BLUE_COINS_BEFORE_BOSS + 1):
		var coin_stage := 1 + int(round(float(coin_id - 1) * float(stage_span - 1) / float(denominator)))
		if coin_stage == stage_number:
			ids.append(coin_id)
	return ids


func _mark_past_blue_coins_spawned(elapsed: float) -> void:
	for index in range(blue_coin_spawn_schedule.size()):
		var row := blue_coin_spawn_schedule[index]
		if float(row.get("time", 0.0)) <= elapsed:
			row["spawned"] = true
			blue_coin_spawn_schedule[index] = row


func _tick_blue_coin_route() -> void:
	if blue_coin_spawn_schedule.is_empty() or stage_cleared or stage_transition_live:
		return
	for index in range(blue_coin_spawn_schedule.size()):
		var row := blue_coin_spawn_schedule[index]
		if bool(row.get("spawned", false)):
			continue
		if stage_elapsed < float(row.get("time", 0.0)):
			continue
		row["spawned"] = true
		blue_coin_spawn_schedule[index] = row
		_spawn_pickup_at(
			"blue_coin",
			Vector2(_camera_right() + 90.0, float(row.get("y", speedbike_lane_y(2)))),
			COIN_SCREEN_DRIFT_SPEED,
			{"collection_id": int(row.get("id", 0))}
		)
		_show_warning("RARE BLUE COIN", 0.8)
		break


func _spawn_pickup_at(kind: String, spawn_pos: Vector2, drift_speed: float = PICKUP_SCREEN_DRIFT_SPEED, extra_data: Dictionary = {}) -> void:
	var screen_x := clampf(spawn_pos.x - _camera_left(), 160.0, maxf(screen_size.x - 160.0, 360.0))
	var pickup := {
		"kind": kind,
		"position": Vector2(_camera_left() + screen_x, spawn_pos.y),
		"base_y": spawn_pos.y,
		"screen_x": screen_x,
		"drift_speed": drift_speed,
		"time": 0.0
	}
	for key in extra_data.keys():
		pickup[key] = extra_data[key]
	active_pickups.append(pickup)


func _spawn_pickup_from_carrier(drone) -> void:
	var kind: String = drone.reward_kind if not drone.reward_kind.is_empty() else _random_speedbike_pickup_kind(true)
	var spawn_pos: Vector2 = drone.position + Vector2(-18.0, 22.0)
	_spawn_pickup_at(kind, spawn_pos, PICKUP_SCREEN_DRIFT_SPEED)


func _random_speedbike_pickup_kind(prefer_weapon: bool = false) -> String:
	if prefer_weapon and randf() <= 0.68:
		return str(SPEEDBIKE_WEAPON_PICKUP_KINDS[randi() % SPEEDBIKE_WEAPON_PICKUP_KINDS.size()])
	return str(PICKUP_KINDS[randi() % PICKUP_KINDS.size()])


func _maybe_spawn_pickup_from_destroyed_enemy(drone) -> void:
	if drone == null or not is_instance_valid(drone):
		return
	var powerup_chance := BOSS_MINION_POWERUP_DROP_CHANCE if str(drone.drone_type) == "minizorg" else ENEMY_POWERUP_DROP_CHANCE
	if randf() <= powerup_chance:
		_spawn_pickup_from_carrier(drone)
		_play_sfx(CARRIER_SOUND_PATH, -10.0, 1.05)
		return
	_spawn_pickup_at("gold_coin", drone.position + Vector2(-14.0, 10.0), COIN_SCREEN_DRIFT_SPEED)


func _apply_pickup(kind: String, pickup_data: Dictionary = {}) -> void:
	match kind:
		"gold_coin":
			gold_coins_collected += 1
			score += GOLD_COIN_SCORE
			_show_warning("PICKED UP 1 GOLD COIN", 0.9)
			_spawn_text_popup("GOLD COIN +1", player_speedbike.bike_midpoint() + Vector2(0.0, -42.0), Color(1.0, 0.82, 0.24, 0.92))
		"blue_coin", "final_blue_coin":
			var collection_id := int(pickup_data.get("collection_id", BLUE_COIN_TOTAL if kind == "final_blue_coin" else 0))
			_award_blue_coin(collection_id, player_speedbike.bike_midpoint())
		"shield":
			shield_hits += 1
			_show_warning("SHIELD ONLINE", 0.8)
		"slow_time":
			slow_time_timer = 3.0
			_show_warning("TIME DRAG ENGAGED", 0.8)
		"repair", "health", "green", "blue":
			remaining_hits = mini(remaining_hits + 1, max_hits)
			_show_warning("HEALTH RESTORED", 0.8)
		"purple":
			remaining_hits = mini(remaining_hits + 2, max_hits)
			_show_warning("HEALTH SURGE", 0.8)
		"gold":
			remaining_hits = max_hits
			_show_warning("FULL HEALTH", 0.8)
		"extra_life", "1up", "one_up", "life":
			speedbike_bonus_health_slots += 1
			max_hits += 1
			remaining_hits = mini(remaining_hits + 1, max_hits)
			_show_warning("ARMOR CORE ADDED", 0.8)
		"cannon_boost":
			_activate_speedbike_weapon("rapid", SPEEDBIKE_WEAPON_PERSIST_TIME)
			_show_warning("CANNON BOOST", 0.8)
		"rapid", "machine", "spread", "laser", "rocket", "fireball":
			_activate_speedbike_weapon(kind, SPEEDBIKE_WEAPON_PERSIST_TIME)
			if SPEEDBIKE_LIMITED_WEAPON_AMMO.has(kind):
				_show_warning("%s READY  %d SHOTS" % [kind.replace("_", " ").to_upper(), speedbike_weapon_ammo], 0.9)
			else:
				_show_warning("%s READY" % kind.replace("_", " ").to_upper(), 0.8)
		"powerup_roulette":
			_activate_speedbike_weapon(str(SPEEDBIKE_WEAPON_PICKUP_KINDS[randi() % SPEEDBIKE_WEAPON_PICKUP_KINDS.size()]), SPEEDBIKE_WEAPON_PERSIST_TIME)
			_show_warning("WEAPON ROULETTE", 0.8)
		_:
			score += 1200
			_show_warning("MEDAL SECURED", 0.8)
	_spawn_burst_fx(player_speedbike.bike_midpoint(), Color(0.62, 1.0, 0.64, 0.72), 0.55)


func _award_blue_coin(collection_id: int, world_pos: Vector2) -> void:
	var safe_id := clampi(collection_id, 1, BLUE_COIN_TOTAL)
	var key := str(safe_id)
	if blue_coin_ids_collected.has(key):
		score += int(BLUE_COIN_SCORE / 4)
		_spawn_text_popup("BLUE BONUS", world_pos + Vector2(0.0, -52.0), Color(0.45, 0.86, 1.0, 0.92))
		return
	blue_coin_ids_collected[key] = true
	blue_coins_collected = clampi(blue_coin_ids_collected.size(), 0, BLUE_COIN_TOTAL)
	score += BLUE_COIN_SCORE
	_show_warning("PICKED UP 1 BLUE COIN  %d/%d" % [blue_coins_collected, BLUE_COIN_TOTAL], 1.15)
	_spawn_text_popup("BLUE COIN +1", world_pos + Vector2(0.0, -56.0), Color(0.42, 0.88, 1.0, 0.96))


func _activate_speedbike_weapon(kind: String, duration: float) -> void:
	speedbike_weapon_kind = kind
	speedbike_weapon_timer = maxf(speedbike_weapon_timer, duration)
	speedbike_weapon_ammo = int(SPEEDBIKE_LIMITED_WEAPON_AMMO.get(kind, -1))
	player_speedbike.grant_cannon_boost(duration)
	_refresh_player_weapon_glow()


func _refresh_speedbike_weapon_controller_boost() -> void:
	if player_speedbike == null:
		return
	if _speedbike_weapon_is_active():
		player_speedbike.grant_cannon_boost(speedbike_weapon_timer)
	_refresh_player_weapon_glow()


func _refresh_player_weapon_glow() -> void:
	if player_speedbike == null or not is_instance_valid(player_speedbike) or not player_speedbike.has_method("set_weapon_glow"):
		return
	var weapon := _active_speedbike_weapon()
	if weapon == "normal":
		player_speedbike.call("set_weapon_glow", Color(0.0, 0.0, 0.0, 0.0), false)
	else:
		player_speedbike.call("set_weapon_glow", _speedbike_weapon_color(weapon), true)


func _spawn_text_popup(text: String, world_pos: Vector2, color: Color) -> void:
	active_fx.append({
		"kind": "text",
		"text": text,
		"position": world_pos,
		"color": color,
		"time": 0.0,
		"life": 0.7
	})


func _trigger_checkpoint_splash(text: String) -> void:
	checkpoint_splash_text = text.to_upper()
	checkpoint_splash_timer = CHECKPOINT_SPLASH_DURATION
	flash_alpha = maxf(flash_alpha, 0.16)
	_spawn_text_popup(checkpoint_splash_text, player_speedbike.bike_midpoint() + Vector2(0.0, -64.0), Color(1.0, 0.86, 0.42, 0.98))
	_play_sfx(PICKUP_SOUND_PATH, -7.0, 0.82)


func _spawn_burst_fx(world_pos: Vector2, color: Color, life: float) -> void:
	active_fx.append({
		"kind": "burst",
		"position": world_pos,
		"color": color,
		"time": 0.0,
		"life": life
	})


func _spawn_ash_fx(world_pos: Vector2) -> void:
	for index in range(20):
		active_fx.append({
			"kind": "ash",
			"position": world_pos + Vector2(randf_range(-18.0, 18.0), randf_range(-18.0, 18.0)),
			"velocity": Vector2(randf_range(-170.0, 80.0), randf_range(-90.0, 42.0)),
			"color": Color(0.16, 0.14, 0.12, randf_range(0.52, 0.86)),
			"time": 0.0,
			"life": randf_range(0.7, 1.25),
			"radius": randf_range(2.0, 6.0)
		})


func _tick_flash_and_audio(delta: float) -> void:
	if engine_player == null:
		return
	var target_pitch = 1.0 + clampf((camera_scroll_speed - stage_base_speed) / 760.0, -0.08, 0.22)
	var boost_pressure = player_speedbike.boost_ratio() if player_speedbike != null else 0.0
	target_pitch += boost_pressure * 0.18
	var target_volume = -13.0
	if crash_restart_timer > 0.0 or selection_open or pause_open or stage_cleared or merchant_shop_open:
		target_volume = -40.0
	elif merchant_state != "none":
		target_volume = -18.0
	elif player_speedbike.is_airborne():
		target_pitch += 0.04
		target_volume = -10.0
	elif player_speedbike.is_afterburner_active():
		target_volume = -9.0
	engine_pitch_target = target_pitch
	engine_volume_target = target_volume
	engine_player.pitch_scale = lerpf(engine_player.pitch_scale, engine_pitch_target, delta * 5.0)
	engine_player.volume_db = lerpf(engine_player.volume_db, _speedbike_sfx_volume_db(engine_volume_target), delta * 5.0)
	if crash_restart_timer <= 0.0 and not selection_open and not pause_open and not stage_cleared and not merchant_shop_open:
		if not engine_player.playing and engine_player.stream != null:
			engine_player.play()
	else:
		if engine_player.playing and engine_player.volume_db <= -36.0:
			engine_player.stop()


func _update_camera_motion(delta: float) -> void:
	var center_y := (speedbike_top_bound() + speedbike_bottom_bound()) * 0.5
	var desired_offset_y: float = (player_speedbike.position.y - center_y) * 0.08
	speedbike_camera.offset.y = lerpf(speedbike_camera.offset.y, desired_offset_y, delta * 4.0)
	speedbike_camera.offset.x = 0.0


func _update_hud() -> void:
	var speed_ratio := clampf((camera_scroll_speed - 600.0) / 1300.0, 0.0, 1.0)
	var progress_ratio := clampf(stage_elapsed / maxf(stage_duration, 1.0), 0.0, 1.0)
	progress_label.text = "STAGE %d/%d  %s" % [_chapter_stage_number(), _chapter_stage_total(), stage_name]
	score_label.text = "SCORE %d  BLUE %d/%d" % [score, blue_coins_collected, BLUE_COIN_TOTAL]
	hit_label.text = "HEALTH"
	if speed_bar_fill != null and is_instance_valid(speed_bar_fill):
		_set_hud_bar_fill(speed_bar_fill, speed_bar_full_width, speed_ratio)
		speed_bar_fill.color = Color(0.26, 0.68, 1.0, 0.78).lerp(Color(1.0, 0.28, 0.16, 0.92), speed_ratio)
	if death_bar_fill != null and is_instance_valid(death_bar_fill):
		_set_hud_bar_fill(death_bar_fill, death_bar_full_width, clampf(float(deaths) / 12.0, 0.05 if deaths > 0 else 0.0, 1.0))
	if score_bar_fill != null and is_instance_valid(score_bar_fill):
		_set_hud_bar_fill(score_bar_fill, score_bar_full_width, clampf(float(score % 6000) / 6000.0, 0.08 if score > 0 else 0.0, 1.0))
	if progress_bar_fill != null and is_instance_valid(progress_bar_fill):
		_set_hud_bar_fill(progress_bar_fill, progress_bar_full_width, progress_ratio)
	if health_bar_fill != null and is_instance_valid(health_bar_fill):
		var health_ratio := clampf(float(remaining_hits) / maxf(float(max_hits), 1.0), 0.0, 1.0)
		_set_hud_bar_fill(health_bar_fill, health_bar_full_width, health_ratio)
		if health_ratio <= 0.34:
			health_bar_fill.color = Color(1.0, 0.24, 0.18, 0.96)
		elif health_ratio <= 0.67:
			health_bar_fill.color = Color(1.0, 0.76, 0.20, 0.96)
		else:
			health_bar_fill.color = Color(0.34, 1.0, 0.48, 0.95)
	var boost_ratio: float = player_speedbike.boost_ratio()
	_set_hud_bar_fill(boost_bar_fill, boost_bar_full_width, boost_ratio)
	boost_bar_fill.color = _speedbike_boost_color(boost_ratio)
	warning_label.text = warning_text
	if selection_open:
		tip_label.text = "PICK A RIDER  ENTER / A = DEPLOY  ESC / B = RETURN"
	else:
		tip_label.text = tip_text
	var hide_text := speedbike_hud_text_hidden or (speedbike_touch_screen_only_mode and _speedbike_mobile_available())
	speed_label.visible = false
	death_label.visible = false
	progress_label.visible = not hide_text
	score_label.visible = not hide_text
	hit_label.visible = not hide_text
	boost_label.visible = false
	if health_bar_back != null and is_instance_valid(health_bar_back):
		health_bar_back.visible = not hide_text
	if health_bar_fill != null and is_instance_valid(health_bar_fill):
		health_bar_fill.visible = not hide_text
	boost_bar_back.visible = false
	boost_bar_fill.visible = false
	if speed_bar_back != null and is_instance_valid(speed_bar_back):
		speed_bar_back.visible = false
	if speed_bar_fill != null and is_instance_valid(speed_bar_fill):
		speed_bar_fill.visible = false
	if death_bar_back != null and is_instance_valid(death_bar_back):
		death_bar_back.visible = false
	if death_bar_fill != null and is_instance_valid(death_bar_fill):
		death_bar_fill.visible = false
	if score_bar_back != null and is_instance_valid(score_bar_back):
		score_bar_back.visible = not hide_text
	if score_bar_fill != null and is_instance_valid(score_bar_fill):
		score_bar_fill.visible = not hide_text
	if progress_bar_back != null and is_instance_valid(progress_bar_back):
		progress_bar_back.visible = not hide_text
	if progress_bar_fill != null and is_instance_valid(progress_bar_fill):
		progress_bar_fill.visible = not hide_text
	warning_label.visible = not hide_text
	tip_label.visible = not hide_text and (selection_open or AppState.show_tooltips) and not tip_label.text.strip_edges().is_empty()
	var hud_alpha := 0.0 if hide_text else speedbike_hud_text_alpha
	for label in [progress_label, score_label, hit_label, tip_label]:
		if label != null and is_instance_valid(label):
			label.modulate.a = hud_alpha
	warning_label.modulate.a = 0.0 if hide_text else 1.0
	_sync_speedbike_touch_controls()


func _set_hud_bar_fill(fill: ColorRect, full_width: float, ratio: float) -> void:
	if fill == null:
		return
	fill.offset_right = fill.offset_left + maxf(full_width, 1.0) * clampf(ratio, 0.0, 1.0)


func _speedbike_boost_color(ratio: float) -> Color:
	var t := clampf(ratio, 0.0, 1.0)
	if t < 0.34:
		return Color(0.96, 0.76, 0.24, 0.88).lerp(Color(1.0, 0.54, 0.18, 0.94), t / 0.34)
	if t < 0.70:
		return Color(1.0, 0.54, 0.18, 0.94).lerp(Color(1.0, 0.16, 0.08, 0.98), (t - 0.34) / 0.36)
	return Color(1.0, 0.16, 0.08, 0.98).lerp(Color(0.38, 0.82, 1.0, 0.98), (t - 0.70) / 0.30)


func _speedbike_weapon_color(kind: String) -> Color:
	match kind:
		"rapid", "cannon_boost":
			return Color(1.0, 0.64, 0.22, 1.0)
		"machine":
			return Color(1.0, 0.88, 0.34, 1.0)
		"spread":
			return Color(1.0, 0.28, 0.14, 1.0)
		"laser":
			return Color(0.28, 0.86, 1.0, 1.0)
		"rocket":
			return Color(1.0, 0.38, 0.12, 1.0)
		"fireball":
			return Color(1.0, 0.12, 0.05, 1.0)
		_:
			return Color(0.72, 0.94, 1.0, 1.0)


func _show_warning(text: String, duration: float) -> void:
	warning_text = text.to_upper()
	warning_text_timer = duration
	_play_sfx(WARNING_SOUND_PATH, -14.0, 1.0)


func _start_music(force_restart: bool = false) -> void:
	var next_path := str(MUSIC_PATHS.get(music_key, MUSIC_FALLBACK_PATH))
	if force_restart:
		_stop_carryover_music()
	elif music_player != null and is_instance_valid(music_player) and music_player.playing and active_music_path == next_path and not next_path.is_empty():
		music_player.set_meta("base_volume_db", -9.0)
		music_player.volume_db = _speedbike_music_volume_db(-9.0)
		return
	else:
		_stop_carryover_music()
	var stream := _load_audio_stream(next_path)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	music_player.stream = stream
	music_player.set_meta("base_volume_db", -9.0)
	music_player.volume_db = _speedbike_music_volume_db(-9.0)
	active_music_path = next_path
	music_player.play()


func _stop_carryover_music() -> void:
	if music_player != null and is_instance_valid(music_player):
		music_player.stop()
	SoundDirector.stop_music()
	SoundDirector.stop_sleep_song()
	SoundDirector.set_rain_music_intensity(0.0)
	if get_tree() != null and get_tree().root != null:
		_stop_external_music_nodes(get_tree().root)


func _stop_external_music_nodes(node: Node) -> void:
	if node == null or node == self:
		return
	if self.is_ancestor_of(node):
		return
	if node.has_method("_stop_menu_audio_for_launch"):
		node.call("_stop_menu_audio_for_launch")
	if node is AudioStreamPlayer:
		var audio_node := node as AudioStreamPlayer
		var node_name := StringName(audio_node.name)
		var name_text := str(node_name).to_lower()
		if name_text.contains("music") or name_text.contains("theme"):
			audio_node.stop()
	for child in node.get_children():
		if child is Node:
			_stop_external_music_nodes(child)


func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if texture_cache.has(path):
		return texture_cache[path]
	var texture := load(path)
	if texture is Texture2D:
		texture_cache[path] = texture
		return texture
	return null


func _load_audio_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if sound_cache.has(path):
		return sound_cache[path]
	var stream := load(path)
	if stream is AudioStream:
		sound_cache[path] = stream
		return stream
	return null


func _load_direct_audio_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	var cache_key := "direct::%s" % path
	if sound_cache.has(cache_key):
		return sound_cache[cache_key]
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var extension := path.get_extension().to_lower()
	var stream: AudioStream = null
	if extension == "mp3":
		stream = AudioStreamMP3.load_from_file(absolute_path)
	elif extension == "wav" or extension == "wave":
		stream = AudioStreamWAV.load_from_file(absolute_path)
	else:
		stream = _load_audio_stream(path)
	if stream != null:
		sound_cache[cache_key] = stream
	return stream


func _play_sfx(path: String, volume_db: float, pitch: float) -> void:
	var stream := _load_audio_stream(path)
	if stream == null:
		return
	for player in sfx_pool:
		if not player.playing:
			player.stream = stream
			player.set_meta("base_volume_db", volume_db)
			player.volume_db = _speedbike_sfx_volume_db(volume_db)
			player.pitch_scale = pitch
			player.play()
			return
	sfx_player.stream = stream
	sfx_player.set_meta("base_volume_db", volume_db)
	sfx_player.volume_db = _speedbike_sfx_volume_db(volume_db)
	sfx_player.pitch_scale = pitch
	sfx_player.play()


func _on_speedbike_shot_fired(origin: Vector2, direction: Vector2) -> void:
	var weapon := _active_speedbike_weapon()
	match weapon:
		"spread":
			for angle in [-0.18, 0.0, 0.18]:
				_spawn_player_bullet(origin, direction.rotated(angle), "spread", PLAYER_BULLET_SPEED * 0.96, 9.0, 1)
		"laser":
			_spawn_player_bullet(origin, direction, "laser", PLAYER_BULLET_SPEED * 1.18, 15.0, 2)
		"rocket":
			_spawn_player_bullet(origin, direction, "rocket", PLAYER_BULLET_SPEED * 0.82, 20.0, 3)
		"fireball":
			_spawn_player_bullet(origin, direction, "fireball", PLAYER_BULLET_SPEED * 1.02, 17.0, 2)
		"machine":
			_spawn_player_bullet(origin, direction, "machine", PLAYER_BULLET_SPEED * 1.08, 10.0, 1)
		"rapid":
			_spawn_player_bullet(origin, direction, "rapid", PLAYER_BULLET_SPEED * 1.10, 10.0, 1)
		_:
			_spawn_player_bullet(origin, direction, "normal", PLAYER_BULLET_SPEED, 10.0, 1)
	var pitch := 1.0
	if weapon == "laser":
		pitch = 1.14
	elif weapon in ["rocket", "fireball"]:
		pitch = 0.86
	elif weapon != "normal":
		pitch = 1.08
	_play_sfx(SHOT_SOUND_PATH, -13.0, pitch)
	_consume_speedbike_weapon_charge(weapon)


func _active_speedbike_weapon() -> String:
	if _speedbike_weapon_is_active():
		return speedbike_weapon_kind
	if player_speedbike.cannon_boost_timer > 0.0:
		return "rapid"
	return "normal"


func _speedbike_weapon_is_active() -> bool:
	if speedbike_weapon_timer <= 0.0 or speedbike_weapon_kind.is_empty() or speedbike_weapon_kind == "normal":
		return false
	if SPEEDBIKE_LIMITED_WEAPON_AMMO.has(speedbike_weapon_kind) and speedbike_weapon_ammo <= 0:
		return false
	return true


func _consume_speedbike_weapon_charge(weapon: String) -> void:
	if not SPEEDBIKE_LIMITED_WEAPON_AMMO.has(weapon):
		return
	speedbike_weapon_ammo = maxi(speedbike_weapon_ammo - 1, 0)
	if speedbike_weapon_ammo > 0:
		return
	speedbike_weapon_kind = "normal"
	speedbike_weapon_timer = 0.0
	if player_speedbike != null:
		player_speedbike.cannon_boost_timer = 0.0
	_show_warning("%s EMPTY" % weapon.to_upper(), 0.85)


func _spawn_player_bullet(origin: Vector2, direction: Vector2, kind: String, speed: float, radius: float, damage: int) -> void:
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.01:
		shot_direction = Vector2.RIGHT
	var shot_velocity := shot_direction * speed
	shot_velocity.x += maxf(camera_scroll_speed, 0.0)
	player_bullets.append({
		"position": origin,
		"velocity": shot_velocity,
		"kind": kind,
		"radius": radius,
		"damage": damage
	})


func _build_lane_positions() -> void:
	if screen_size.y <= 0.0:
		screen_size = Vector2(1280.0, 720.0)
	var top := clampf(screen_size.y * 0.22, 128.0, 176.0)
	var bottom := screen_size.y - clampf(screen_size.y * 0.22, 132.0, 184.0)
	lane_positions.clear()
	for index in range(LANE_COUNT):
		var t := float(index) / float(LANE_COUNT - 1)
		lane_positions.append(lerpf(top, bottom, t))


func _camera_left() -> float:
	return speedbike_camera.position.x - screen_size.x * 0.5


func _camera_right() -> float:
	return speedbike_camera.position.x + screen_size.x * 0.5


func _clear_runtime_objects() -> void:
	for obstacle in active_obstacles:
		if is_instance_valid(obstacle):
			obstacle.queue_free()
	active_obstacles.clear()
	for drone in active_drones:
		if is_instance_valid(drone):
			drone.queue_free()
	active_drones.clear()
	player_bullets.clear()
	enemy_bullets.clear()
	active_pickups.clear()
	active_fx.clear()
	boss_minion_spawn_visuals.clear()


func _time_text(seconds: float) -> String:
	var total = maxi(int(round(seconds)), 0)
	var minutes = total / 60
	var secs = total % 60
	return "%02d:%02d" % [minutes, secs]


func _draw() -> void:
	var left := _camera_left() - 220.0
	var width := screen_size.x + 440.0
	# Tuned for the cabinet LCD: preserve the night atmosphere without crushing
	# hazards and lane geometry into black.
	var background_color := Color(0.30, 0.24, 0.19, 1.0)
	var track_color := Color(0.25, 0.26, 0.30, 1.0)
	var _side_glow := Color(1.0, 0.54, 0.18, 0.12)
	match stage_theme:
		"blackout_tube":
			background_color = Color(0.10, 0.13, 0.18, 1.0)
			track_color = Color(0.18, 0.21, 0.28, 1.0)
			_side_glow = Color(0.66, 0.80, 1.0, 0.10)
		"pulse_grid":
			background_color = Color(0.22, 0.10, 0.10, 1.0)
			track_color = Color(0.28, 0.16, 0.16, 1.0)
			_side_glow = Color(1.0, 0.28, 0.18, 0.12)
		"minefield_refinery":
			background_color = Color(0.23, 0.20, 0.16, 1.0)
			track_color = Color(0.29, 0.25, 0.22, 1.0)
			_side_glow = Color(1.0, 0.78, 0.28, 0.12)
		"signal_tunnel":
			background_color = Color(0.16, 0.12, 0.23, 1.0)
			track_color = Color(0.21, 0.20, 0.29, 1.0)
			_side_glow = Color(0.68, 0.48, 1.0, 0.12)
		"voss_tunnel":
			background_color = Color(0.27, 0.14, 0.12, 1.0)
			track_color = Color(0.31, 0.19, 0.16, 1.0)
			_side_glow = Color(1.0, 0.36, 0.16, 0.14)
		_:
			pass
	var background_texture := _load_texture(str(STAGE_THEME_BACKGROUND_PATHS.get(stage_theme, "")))
	if background_texture != null:
		var texture_size := background_texture.get_size()
		var tile_width := maxf(texture_size.x, 64.0)
		var parallax_offset := fposmod(_camera_left() * 0.18, tile_width)
		var draw_x := left - parallax_offset
		while draw_x < left + width:
			draw_texture_rect(background_texture, Rect2(draw_x, 0.0, tile_width, screen_size.y), false, Color(1.18, 1.14, 1.08, 0.94))
			draw_x += tile_width
		draw_rect(Rect2(left, 0.0, width, screen_size.y), Color(background_color.r, background_color.g, background_color.b, 0.20), true)
	else:
		draw_rect(Rect2(left, 0.0, width, screen_size.y), background_color, true)
	var rib_offset := fposmod(_camera_left() * 0.44, 124.0)
	for rib in range(16):
		var rib_x := left + rib * 124.0 - rib_offset
		draw_rect(Rect2(rib_x, 0.0, 26.0, screen_size.y), Color(0.0, 0.0, 0.0, 0.10), true)
	var track_top := speedbike_top_bound() - 44.0
	var track_height := speedbike_bottom_bound() - speedbike_top_bound() + 88.0
	draw_rect(Rect2(left, track_top, width, track_height), track_color, true)
	draw_rect(Rect2(left, track_top, width, 14.0), Color(1.0, 0.74, 0.24, 0.72), true)
	draw_rect(Rect2(left, track_top + track_height - 14.0, width, 14.0), Color(1.0, 0.74, 0.24, 0.72), true)
	var floor_y := speedbike_bottom_bound() - 18.0
	draw_rect(Rect2(left, floor_y, width, 38.0), Color(0.34, 0.31, 0.28, 0.98), true)
	draw_rect(Rect2(left, floor_y, width, 6.0), Color(1.0, 0.72, 0.22, 0.78), true)
	_draw_speedbike_snow_cover(left, width, track_top, track_height)
	var line_offset := fposmod(_camera_left() * 0.86, 168.0)
	for line in range(12):
		var line_x := left + line * 168.0 - line_offset
		draw_rect(Rect2(line_x, floor_y + 12.0, 82.0, 6.0), Color(0.86, 0.88, 0.96, 0.56), true)
		draw_rect(Rect2(line_x + 18.0, speedbike_lane_y(2) - 58.0, 48.0, 4.0), Color(1.0, 0.76, 0.30, 0.38), true)
	_draw_speedbike_grounding_pass()
	if stage_visual_mode == "winding_road":
		_draw_winding_road_overlay(left, width)
	elif stage_visual_mode == "space_run":
		_draw_space_run_overlay(left, width)
	var speed_ratio := clampf((camera_scroll_speed - 420.0) / 520.0, 0.0, 1.0)
	for streak in range(16):
		var streak_y := 88.0 + streak * 34.0
		var streak_length := 24.0 + speed_ratio * 112.0
		var streak_x := left + fposmod(_camera_left() * (1.8 + streak * 0.03), width + 240.0)
		draw_line(Vector2(streak_x, streak_y), Vector2(streak_x - streak_length, streak_y), Color(1.0, 1.0, 1.0, 0.05 + speed_ratio * 0.12), 2.0, true)
	_draw_merchant_ship()
	for pickup in active_pickups:
		_draw_pickup_icon(pickup)
	for bullet in player_bullets:
		_draw_player_bullet(bullet)
	for bullet in enemy_bullets:
		var enemy_point := bullet.get("position", Vector2.ZERO) as Vector2
		var enemy_bullet_kind := str(bullet.get("kind", "bullet"))
		if enemy_bullet_kind == "missile":
			_draw_speedbike_enemy_missile(bullet)
		elif enemy_bullet_kind == "enemy_powerup":
			draw_circle(enemy_point, 22.0, Color(1.0, 0.14, 0.08, 0.20))
			_draw_pickup_icon({
				"position": enemy_point,
				"kind": str(bullet.get("pickup_kind", "rocket")),
				"time": float(bullet.get("time", 0.0))
			})
		else:
			draw_circle(enemy_point, 5.0, Color(1.0, 0.28, 0.18, 0.88))
	for fx in active_fx:
		_draw_fx_entry(fx)
	_draw_speedbike_weather(left, width)
	_draw_boss_encounter()
	_draw_incoming_warning_markers()
	if practice_mode:
		_draw_practice_markers()
	if blackout_strength > 0.0:
		_draw_blackout_headlight(left, width)
	_draw_speedbike_hud_gauges()
	_draw_checkpoint_splash()


func _draw_merchant_ship() -> void:
	if merchant_state == "none" or merchant_shop_open:
		return
	if merchant_ship_texture == null:
		merchant_ship_texture = _load_texture(MERCHANT_SHIP_SHEET_PATH)
	if merchant_ship_texture == null:
		return
	var texture_width := float(merchant_ship_texture.get_width())
	var source_height := float(merchant_ship_texture.get_height()) * 0.5
	if texture_width <= 0.0 or source_height <= 0.0:
		return
	var source_y := 0.0 if merchant_ship_open else source_height
	var source_rect := Rect2(0.0, source_y, texture_width, source_height)
	var draw_width := clampf(screen_size.x * 0.36, 380.0, 520.0)
	var draw_size := Vector2(draw_width, draw_width * source_height / texture_width)
	var draw_rect := Rect2(merchant_ship_position - draw_size * 0.5, draw_size)
	var alpha := clampf(merchant_ship_alpha, 0.0, 1.0)
	_draw_speedbike_ellipse(merchant_ship_position + Vector2(-8.0, draw_size.y * 0.36), Vector2(draw_size.x * 0.42, 16.0), Color(0.0, 0.0, 0.0, 0.20 * alpha))
	if merchant_beam_strength > 0.0:
		var hatch: Vector2 = merchant_ship_position + Vector2(-draw_size.x * 0.25, draw_size.y * 0.18)
		var bike_pos: Vector2 = player_speedbike.position if player_speedbike != null else hatch + Vector2(-120.0, 40.0)
		var beam_points := PackedVector2Array([
			hatch + Vector2(-18.0, -12.0),
			hatch + Vector2(18.0, -12.0),
			bike_pos + Vector2(50.0, 42.0),
			bike_pos + Vector2(-50.0, 42.0)
		])
		draw_colored_polygon(beam_points, Color(0.28, 1.0, 0.96, 0.20 * merchant_beam_strength))
		draw_polyline(beam_points + PackedVector2Array([beam_points[0]]), Color(0.70, 1.0, 1.0, 0.38 * merchant_beam_strength), 2.0, true)
		for ring in range(3):
			var t := fposmod(merchant_timer * 2.8 + float(ring) * 0.33, 1.0)
			var radius := lerpf(18.0, 74.0, t)
			_draw_speedbike_ellipse(bike_pos, Vector2(radius, radius * 0.28), Color(0.42, 1.0, 0.92, (1.0 - t) * 0.34 * merchant_beam_strength))
	draw_texture_rect_region(merchant_ship_texture, draw_rect, source_rect, Color(1.0, 1.0, 1.0, alpha))


func _draw_speedbike_hud_gauges() -> void:
	var hide_text := speedbike_hud_text_hidden or (speedbike_touch_screen_only_mode and _speedbike_mobile_available())
	if hide_text:
		return
	var alpha := clampf(speedbike_hud_text_alpha, 0.25, 1.0)
	var speed_center := Vector2(_camera_right() - 118.0, 92.0)
	var speed_ratio := clampf((camera_scroll_speed - 600.0) / 1300.0, 0.0, 1.0)
	var start_angle := PI * 0.78
	var end_angle := PI * 2.22
	var speed_color := Color(0.32, 0.74, 1.0, 0.72 * alpha).lerp(Color(1.0, 0.18, 0.10, 0.94 * alpha), speed_ratio)
	draw_circle(speed_center, 64.0, Color(0.02, 0.025, 0.03, 0.52 * alpha))
	draw_arc(speed_center, 54.0, start_angle, end_angle, 42, Color(0.92, 0.86, 0.62, 0.30 * alpha), 5.0, true)
	draw_arc(speed_center, 54.0, start_angle, lerpf(start_angle, end_angle, speed_ratio), 42, speed_color, 6.0, true)
	for tick in range(8):
		var tick_t = float(tick) / 7.0
		var angle = lerpf(start_angle, end_angle, tick_t)
		var outer = speed_center + Vector2(cos(angle), sin(angle)) * 57.0
		var inner = speed_center + Vector2(cos(angle), sin(angle)) * (45.0 if tick % 2 == 0 else 49.0)
		draw_line(inner, outer, Color(1.0, 0.90, 0.62, 0.46 * alpha), 2.0, true)
	var needle_angle = lerpf(start_angle, end_angle, speed_ratio)
	draw_line(speed_center, speed_center + Vector2(cos(needle_angle), sin(needle_angle)) * 43.0, Color(1.0, 0.24, 0.12, 0.94 * alpha), 4.0, true)
	draw_circle(speed_center, 7.0, Color(1.0, 0.84, 0.36, 0.90 * alpha))
	var boost_center = speed_center + Vector2(-150.0, 0.0)
	var boost_ratio = player_speedbike.boost_ratio()
	draw_circle(boost_center, 42.0, Color(0.025, 0.02, 0.014, 0.48 * alpha))
	draw_arc(boost_center, 34.0, start_angle, end_angle, 28, Color(1.0, 0.80, 0.36, 0.22 * alpha), 4.0, true)
	draw_arc(boost_center, 34.0, start_angle, lerpf(start_angle, end_angle, boost_ratio), 28, _speedbike_boost_color(boost_ratio), 5.0, true)
	var boost_angle = lerpf(start_angle, end_angle, boost_ratio)
	draw_line(boost_center, boost_center + Vector2(cos(boost_angle), sin(boost_angle)) * 27.0, Color(1.0, 0.88, 0.42, 0.88 * alpha), 3.0, true)
	draw_circle(boost_center, 5.0, Color(1.0, 0.60, 0.22, 0.88 * alpha))
	var font = ThemeDB.fallback_font
	if font != null:
		draw_string(font, speed_center + Vector2(-44.0, 78.0), "%d" % int(round(camera_scroll_speed)), HORIZONTAL_ALIGNMENT_CENTER, 88.0, 18, Color(1.0, 0.92, 0.72, 0.90 * alpha))
		draw_string(font, boost_center + Vector2(-36.0, 56.0), "BOOST", HORIZONTAL_ALIGNMENT_CENTER, 72.0, 13, Color(1.0, 0.82, 0.50, 0.76 * alpha))


func _configure_speedbike_weather() -> void:
	speedbike_weather_kind = "clear"
	var stage_number := _chapter_stage_number()
	if stage_theme in ["blackout_tube", "signal_tunnel"] or stage_number in [14, 18, 26, 34, 38, 51, 55, 57, 60]:
		speedbike_weather_kind = "storm"
	elif stage_number in [31, 32, 37, 52, 54, 58]:
		speedbike_weather_kind = "snow"
	elif randf() < 0.18:
		speedbike_weather_kind = "storm" if randf() < 0.55 else "snow"
	speedbike_weather_timer = 0.0
	speedbike_lightning_flash = 0.0
	speedbike_lightning_points = PackedVector2Array()
	speedbike_snow_coverage = 0.0
	speedbike_snowflakes.clear()
	if speedbike_weather_kind == "storm":
		speedbike_lightning_timer = randf_range(3.0, 7.5)
	elif speedbike_weather_kind == "snow":
		for _i in range(72):
			speedbike_snowflakes.append(_new_speedbike_snowflake(true))
	else:
		speedbike_lightning_timer = 0.0


func _tick_speedbike_weather(delta: float) -> void:
	if speedbike_weather_kind == "clear":
		return
	speedbike_weather_timer += delta
	if speedbike_weather_kind == "storm":
		speedbike_lightning_timer -= delta
		speedbike_lightning_flash = maxf(speedbike_lightning_flash - delta * 2.8, 0.0)
		if speedbike_lightning_timer <= 0.0:
			_spawn_speedbike_lightning_strike()
			speedbike_lightning_timer = randf_range(4.0, 9.0)
	elif speedbike_weather_kind == "snow":
		speedbike_snow_coverage = clampf(speedbike_snow_coverage + delta * 0.014, 0.0, 0.72)
		for index in range(speedbike_snowflakes.size()):
			var flake := speedbike_snowflakes[index]
			var pos := flake.get("pos", Vector2.ZERO) as Vector2
			var speed_value := float(flake.get("speed", 70.0))
			var drift := float(flake.get("drift", -28.0))
			pos.x += (drift - camera_scroll_speed * 0.08) * delta
			pos.y += speed_value * delta
			if pos.y > screen_size.y + 28.0 or pos.x < _camera_left() - 80.0:
				flake = _new_speedbike_snowflake(false)
			else:
				flake["pos"] = pos
			speedbike_snowflakes[index] = flake


func _spawn_speedbike_lightning_strike() -> void:
	var road_y := randf_range(speedbike_top_bound() + 24.0, speedbike_bottom_bound() + 6.0)
	var strike_x := randf_range(_camera_left() + screen_size.x * 0.34, _camera_right() - screen_size.x * 0.18)
	var points := PackedVector2Array()
	var start := Vector2(strike_x + randf_range(-80.0, 80.0), 0.0)
	points.append(start)
	var segments := 7
	for step in range(1, segments + 1):
		var t := float(step) / float(segments)
		points.append(Vector2(
			lerpf(start.x, strike_x, t) + randf_range(-28.0, 28.0),
			lerpf(0.0, road_y, t)
		))
	speedbike_lightning_points = points
	speedbike_lightning_flash = 1.0
	flash_alpha = maxf(flash_alpha, 0.12)
	_spawn_burst_fx(Vector2(strike_x, road_y), Color(0.65, 0.85, 1.0, 0.70), 0.34)
	_show_warning("LIGHTNING ON THE ROAD", 0.75)


func _new_speedbike_snowflake(initial: bool) -> Dictionary:
	var left := _camera_left()
	return {
		"pos": Vector2(
			randf_range(left, left + screen_size.x + 80.0),
			randf_range(-40.0, screen_size.y) if initial else randf_range(-60.0, -8.0)
		),
		"speed": randf_range(36.0, 104.0),
		"drift": randf_range(-52.0, -10.0),
		"size": randf_range(1.4, 4.2),
		"alpha": randf_range(0.28, 0.74)
	}


func _draw_speedbike_snow_cover(left: float, width: float, track_top: float, track_height: float) -> void:
	if speedbike_weather_kind != "snow" or speedbike_snow_coverage <= 0.0:
		return
	var alpha := 0.18 * speedbike_snow_coverage
	var lane_top := speedbike_top_bound() - 18.0
	var lane_height := speedbike_bottom_bound() - speedbike_top_bound() + 48.0
	draw_rect(Rect2(left, lane_top, width, lane_height), Color(0.82, 0.90, 0.96, alpha), true)
	var patch_offset := fposmod(_camera_left() * 0.48, 116.0)
	for patch in range(18):
		var x := left + float(patch) * 116.0 - patch_offset
		var y := track_top + 12.0 + fmod(float(patch * 37), maxf(track_height - 34.0, 24.0))
		_draw_speedbike_ellipse(Vector2(x, y), Vector2(34.0, 5.0), Color(0.92, 0.97, 1.0, alpha * 1.6))


func _draw_speedbike_weather(left: float, width: float) -> void:
	if speedbike_weather_kind == "storm":
		var rain_color := Color(0.58, 0.74, 0.92, 0.18)
		var rain_offset := fposmod(speedbike_weather_timer * 620.0 + _camera_left() * 0.10, 48.0)
		for index in range(34):
			var x := left + fmod(float(index) * 53.0 + rain_offset, width + 80.0) - 40.0
			var y := fmod(float(index * 43) + speedbike_weather_timer * 430.0, screen_size.y + 80.0) - 40.0
			draw_line(Vector2(x, y), Vector2(x - 18.0, y + 42.0), rain_color, 1.4, true)
		if speedbike_lightning_flash > 0.0 and speedbike_lightning_points.size() >= 2:
			draw_polyline(speedbike_lightning_points, Color(0.86, 0.96, 1.0, 0.92 * speedbike_lightning_flash), 5.0, true)
			draw_polyline(speedbike_lightning_points, Color(0.25, 0.62, 1.0, 0.52 * speedbike_lightning_flash), 13.0, true)
			draw_rect(Rect2(left, 0.0, width, screen_size.y), Color(0.70, 0.86, 1.0, 0.10 * speedbike_lightning_flash), true)
	elif speedbike_weather_kind == "snow":
		for flake in speedbike_snowflakes:
			var pos := flake.get("pos", Vector2.ZERO) as Vector2
			var radius := float(flake.get("size", 2.0))
			var alpha := float(flake.get("alpha", 0.5))
			draw_circle(pos, radius, Color(0.92, 0.97, 1.0, alpha))


func _draw_speedbike_velocity_waves() -> void:
	return


func _draw_speedbike_grounding_pass() -> void:
	if player_speedbike != null and is_instance_valid(player_speedbike):
		var bike_pos := to_local(player_speedbike.global_position)
		var safe_jump_height := maxf(player_speedbike.jump_height, 1.0)
		var jump_ratio := clampf(player_speedbike.jump_z / safe_jump_height, 0.0, 1.0)
		var radius := Vector2(100.0 * lerpf(1.0, 0.58, jump_ratio), 14.0 * lerpf(1.0, 0.72, jump_ratio))
		_draw_speedbike_ellipse(bike_pos + Vector2(-8.0, 34.0), radius, Color(0.0, 0.0, 0.0, lerpf(0.22, 0.07, jump_ratio)))
	for pickup in active_pickups:
		var pickup_pos := pickup.get("position", Vector2.ZERO) as Vector2
		_draw_speedbike_ellipse(pickup_pos + Vector2(0.0, 18.0), Vector2(19.0, 4.5), Color(0.0, 0.0, 0.0, 0.18))
	for drone in active_drones:
		if not is_instance_valid(drone) or drone.destroyed:
			continue
		var drone_pos := to_local(drone.global_position)
		var display_size: Vector2 = drone.display_size
		var shadow_alpha := 0.18 * clampf(drone.modulate.a, 0.0, 1.0)
		if drone.drone_type == "minizorg":
			shadow_alpha = 0.24 * clampf(drone.modulate.a, 0.0, 1.0)
		_draw_speedbike_ellipse(
			drone_pos + Vector2(0.0, display_size.y * 0.36),
			Vector2(display_size.x * 0.31, 7.0 if drone.drone_type != "minizorg" else 10.0),
			Color(0.0, 0.0, 0.0, shadow_alpha)
		)


func _draw_speedbike_ellipse(center: Vector2, radius: Vector2, color: Color, segments: int = 24) -> void:
	var point_count := maxi(segments, 8)
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _draw_player_bullet(bullet: Dictionary) -> void:
	var point := bullet.get("position", Vector2.ZERO) as Vector2
	var kind := str(bullet.get("kind", "normal"))
	match kind:
		"laser":
			draw_line(point, point - Vector2(46.0, 0.0), Color(0.42, 0.94, 1.0, 0.34), 12.0, true)
			draw_line(point, point - Vector2(56.0, 0.0), Color(0.88, 1.0, 1.0, 0.94), 4.0, true)
		"rocket":
			draw_line(point - Vector2(8.0, 0.0), point - Vector2(34.0, 0.0), Color(1.0, 0.42, 0.14, 0.72), 9.0, true)
			draw_circle(point, 8.0, Color(0.88, 0.82, 0.66, 0.96))
			draw_circle(point + Vector2(8.0, 0.0), 4.0, Color(1.0, 0.24, 0.14, 0.90))
		"fireball":
			draw_circle(point, 9.5, Color(1.0, 0.32, 0.12, 0.82))
			draw_circle(point, 5.5, Color(1.0, 0.88, 0.34, 0.94))
			draw_line(point - Vector2(4.0, 0.0), point - Vector2(34.0, 0.0), Color(1.0, 0.28, 0.08, 0.48), 8.0, true)
		"spread":
			draw_line(point, point - Vector2(20.0, 0.0), Color(1.0, 0.68, 0.32, 0.84), 3.0, true)
		"machine":
			draw_line(point, point - Vector2(28.0, 0.0), Color(1.0, 0.92, 0.58, 0.90), 3.5, true)
		_:
			draw_line(point, point - Vector2(22.0, 0.0), Color(1.0, 0.84, 0.42, 0.88), 4.0, true)


func _draw_checkpoint_splash() -> void:
	if checkpoint_splash_timer <= 0.0:
		return
	var duration := maxf(CHECKPOINT_SPLASH_DURATION, 0.01)
	var progress := 1.0 - checkpoint_splash_timer / duration
	var alpha := sin(clampf(progress, 0.0, 1.0) * PI)
	var center := Vector2(_camera_left() + screen_size.x * 0.5, screen_size.y * 0.30)
	var width := 500.0 + alpha * 74.0
	var height := 88.0
	var plate := Rect2(center - Vector2(width * 0.5, height * 0.5), Vector2(width, height))
	var gold := Color(1.0, 0.70, 0.22, 0.28 + alpha * 0.48)
	draw_rect(plate.grow(18.0), Color(0.0, 0.0, 0.0, 0.18 * alpha), true)
	draw_rect(plate, Color(0.06, 0.045, 0.025, 0.74 * alpha), true)
	draw_rect(plate, gold, false, 4.0)
	for line in range(7):
		var y := plate.position.y + 10.0 + line * 11.0
		var x_offset := fposmod(stage_elapsed * 160.0 + line * 23.0, 80.0)
		draw_line(Vector2(plate.position.x + x_offset, y), Vector2(plate.end.x - 18.0, y), Color(1.0, 0.82, 0.36, 0.07 * alpha), 2.0, true)
	draw_rect(Rect2(plate.position.x - 32.0, plate.position.y + 16.0, 22.0 + alpha * 42.0, 10.0), Color(1.0, 0.24, 0.12, 0.44 * alpha), true)
	draw_rect(Rect2(plate.end.x - 32.0 - alpha * 42.0, plate.end.y - 26.0, 22.0 + alpha * 42.0, 10.0), Color(1.0, 0.24, 0.12, 0.44 * alpha), true)
	var font := ThemeDB.fallback_font
	if font != null:
		draw_string(font, plate.position + Vector2(0.0, 57.0), checkpoint_splash_text, HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 44, Color(1.0, 0.88, 0.42, 0.96 * alpha))
		draw_string(font, plate.position + Vector2(0.0, 80.0), "ROUTE SYNCED - KEEP MOVING", HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 15, Color(0.96, 0.92, 0.76, 0.72 * alpha))


func _draw_speedbike_enemy_missile(bullet: Dictionary) -> void:
	var enemy_point := bullet.get("position", Vector2.ZERO) as Vector2
	var velocity := bullet.get("velocity", Vector2.LEFT * 440.0) as Vector2
	var direction := velocity.normalized()
	if direction.length_squared() <= 0.01:
		direction = Vector2.LEFT
	var right := Vector2(-direction.y, direction.x)
	var nose := enemy_point + direction * 18.0
	var body_front_left := enemy_point + direction * 6.0 + right * 7.0
	var body_front_right := enemy_point + direction * 6.0 - right * 7.0
	var body_back_left := enemy_point - direction * 12.0 + right * 6.0
	var body_back_right := enemy_point - direction * 12.0 - right * 6.0
	var tail := enemy_point - direction * 22.0
	var fin_top := enemy_point - direction * 4.0 + right * 12.0
	var fin_bottom := enemy_point - direction * 4.0 - right * 12.0
	draw_colored_polygon(PackedVector2Array([
		nose,
		body_front_left,
		body_back_left,
		tail,
		body_back_right,
		body_front_right
	]), Color(0.96, 0.66, 0.22, 0.96))
	draw_line(body_back_left, fin_top, Color(0.92, 0.82, 0.42, 0.88), 3.0, true)
	draw_line(body_back_right, fin_bottom, Color(0.92, 0.82, 0.42, 0.88), 3.0, true)
	draw_line(enemy_point - direction * 10.0, enemy_point - direction * 26.0, Color(0.28, 0.28, 0.32, 0.46), 10.0, true)
	draw_line(enemy_point - direction * 10.0, enemy_point - direction * 24.0, Color(1.0, 0.78, 0.24, 0.88), 4.0, true)
	draw_circle(enemy_point - direction * 3.0, 4.8, Color(1.0, 0.95, 0.72, 0.74))
	draw_circle(enemy_point - direction * 20.0, 6.0, Color(1.0, 0.56, 0.18, 0.22))


func _draw_winding_road_overlay(left: float, width: float) -> void:
	var horizon_y := speedbike_top_bound() + 24.0
	var bottom_y := speedbike_bottom_bound() + 54.0
	var center_x := left + width * 0.52 + sin(stage_elapsed * 0.72) * 48.0 * stage_curve_strength
	var near_half := width * 0.48
	var far_half := 42.0
	var road_poly := PackedVector2Array([
		Vector2(center_x - far_half, horizon_y),
		Vector2(center_x + far_half, horizon_y),
		Vector2(left + width * 0.5 + near_half, bottom_y),
		Vector2(left + width * 0.5 - near_half, bottom_y)
	])
	draw_colored_polygon(road_poly, Color(0.06, 0.055, 0.052, 0.82))
	draw_polyline(PackedVector2Array([road_poly[0], road_poly[1], road_poly[2], road_poly[3], road_poly[0]]), Color(1.0, 0.72, 0.24, 0.30), 3.0, true)
	for band in range(1, 11):
		var t := float(band) / 11.0
		var curve := sin(stage_elapsed * 1.1 + t * 5.4) * 44.0 * stage_curve_strength * t
		var y := lerpf(horizon_y, bottom_y, t)
		var half := lerpf(far_half, near_half, t)
		var lane_center := lerpf(center_x, left + width * 0.5, t) + curve
		var alpha := 0.10 + t * 0.20
		draw_line(Vector2(lane_center - half, y), Vector2(lane_center + half, y), Color(0.92, 0.66, 0.22, alpha), maxf(1.0, t * 4.0), true)
		if band % 2 == 0:
			draw_line(Vector2(lane_center, y), Vector2(lane_center + curve * 0.12, y + 26.0 * t), Color(0.92, 0.86, 0.58, alpha + 0.08), 3.0, true)


func _draw_space_run_overlay(left: float, width: float) -> void:
	draw_rect(Rect2(left, 0.0, width, screen_size.y), Color(0.0, 0.0, 0.02, 0.38), true)
	var warp := clampf((camera_scroll_speed - 700.0) / 720.0, 0.0, 1.0)
	for star in range(44):
		var seed := float(star) * 37.31
		var x := left + fposmod(seed * 19.0 - _camera_left() * (0.45 + fposmod(seed, 5.0) * 0.08), width + 180.0)
		var y := 36.0 + fposmod(seed * 23.0, screen_size.y - 72.0)
		var len := 8.0 + warp * 54.0 + fposmod(seed, 17.0)
		var alpha := 0.12 + fposmod(seed, 9.0) * 0.026
		draw_line(Vector2(x, y), Vector2(x - len, y), Color(0.70, 0.88, 1.0, alpha), 1.5 + warp * 1.5, true)
	var grid_top := speedbike_top_bound() - 24.0
	var grid_bottom := speedbike_bottom_bound() + 44.0
	var grid_offset := fposmod(_camera_left() * 0.70, 96.0)
	for grid in range(18):
		var gx := left + grid * 96.0 - grid_offset
		draw_line(Vector2(gx, grid_top), Vector2(gx - 44.0, grid_bottom), Color(0.34, 0.72, 1.0, 0.10), 1.5, true)
	for lane in range(LANE_COUNT):
		var y := speedbike_lane_y(lane)
		draw_line(Vector2(left, y), Vector2(left + width, y), Color(0.58, 0.88, 1.0, 0.07), 1.0, true)


func _draw_boss_encounter() -> void:
	if not boss_encounter_started or boss_complete:
		return
	if boss_state in ["summon", "laugh", "fade_out", "minion_fight", "death_portal", "death_dialog"] or boss_alpha > 0.0:
		_draw_boss_body()
	if boss_state == "summon" or boss_state == "laugh":
		_draw_boss_beam()
	if boss_state == "attack" and boss_damage_phase == "dome":
		_draw_boss_laser()
	if boss_state == "attack":
		_draw_boss_eye_attack()
	if boss_state == "death_portal":
		_draw_boss_portal()


func _draw_boss_body() -> void:
	if boss_texture == null or boss_alpha <= 0.0:
		return
	var size := _boss_draw_size()
	var rect := _boss_body_rect()
	draw_circle(boss_position + Vector2(0.0, size.y * 0.24), size.x * 0.22, Color(0.0, 0.0, 0.0, 0.22 * boss_alpha))
	draw_texture_rect(boss_texture, rect, false, Color(1.0, 1.0, 1.0, boss_alpha))
	if boss_state in ["attack", "returning", "entrance"] and boss_health > 0:
		var bar_width := 260.0
		var ratio := clampf(float(boss_health) / float(BOSS_MAX_HEALTH), 0.0, 1.0)
		var top_left := boss_position + Vector2(-bar_width * 0.5, -size.y * 0.46)
		draw_rect(Rect2(top_left, Vector2(bar_width, 14.0)), Color(0.08, 0.02, 0.02, 0.74 * boss_alpha), true)
		draw_rect(Rect2(top_left + Vector2(2.0, 2.0), Vector2((bar_width - 4.0) * ratio, 10.0)), Color(0.84, 0.18, 0.18, 0.92 * boss_alpha), true)
		var target_label := "TARGET SHIELD"
		match boss_damage_phase:
			"cannons":
				target_label = "TARGET CANNONS"
			"dome":
				target_label = "TARGET DOME"
			"dead":
				target_label = "BELDAR FALLING"
		draw_string(ThemeDB.fallback_font, top_left + Vector2(48.0, -4.0), target_label, HORIZONTAL_ALIGNMENT_LEFT, bar_width, 15, Color(1.0, 0.92, 0.82, 0.94 * boss_alpha))
	_draw_boss_part_status("shield", boss_shield_health, BOSS_SHIELD_HEALTH, boss_damage_phase == "shield")
	_draw_boss_part_status("cannons", boss_cannon_health, BOSS_CANNON_HEALTH, boss_damage_phase == "cannons")
	_draw_boss_part_status("dome", boss_dome_health, BOSS_DOME_HEALTH, boss_damage_phase == "dome")


func _boss_part_name(part: String) -> String:
	match part:
		"shield":
			return "SHIELD"
		"cannons":
			return "CANNONS"
		"dome":
			return "DOME"
		_:
			return part.to_upper()


func _draw_boss_target_reticle(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center, radius, Color(color.r, color.g, color.b, 0.0), false, 2.0, true)
	draw_line(center + Vector2(-radius - 10.0, 0.0), center + Vector2(-radius + 4.0, 0.0), color, 2.0, true)
	draw_line(center + Vector2(radius - 4.0, 0.0), center + Vector2(radius + 10.0, 0.0), color, 2.0, true)
	draw_line(center + Vector2(0.0, -radius - 10.0), center + Vector2(0.0, -radius + 4.0), color, 2.0, true)
	draw_line(center + Vector2(0.0, radius - 4.0), center + Vector2(0.0, radius + 10.0), color, 2.0, true)
	draw_circle(center, 2.5, color)


func _draw_boss_part_status(part: String, health: int, max_health: int, active: bool) -> void:
	var rect := _boss_part_rect(part)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var center := rect.get_center()
	var bar_width := maxf(rect.size.x + 14.0, 62.0)
	var bar_rect := Rect2(center.x - bar_width * 0.5, rect.position.y - 16.0, bar_width, 5.0)
	draw_rect(bar_rect, Color(0.04, 0.01, 0.01, 0.74 * boss_alpha), true)
	var ratio := clampf(float(max(health, 0)) / float(max(max_health, 1)), 0.0, 1.0)
	draw_rect(Rect2(bar_rect.position + Vector2(1.0, 1.0), Vector2((bar_rect.size.x - 2.0) * ratio, bar_rect.size.y - 2.0)), Color(1.0, 0.30, 0.22, 0.94 * boss_alpha) if active else Color(0.80, 0.38, 0.96, 0.74 * boss_alpha), true)
	var label_color := Color(1.0, 0.90, 0.70, 0.94 * boss_alpha) if active else Color(0.82, 0.78, 0.94, 0.76 * boss_alpha)
	draw_string(ThemeDB.fallback_font, Vector2(center.x - bar_width * 0.5, bar_rect.position.y - 4.0), _boss_part_name(part), HORIZONTAL_ALIGNMENT_LEFT, bar_width, 12, label_color)
	if health <= 0:
		return
	var reticle_color := Color(1.0, 0.84, 0.40, 0.92 * boss_alpha) if active else Color(0.72, 0.44, 1.0, 0.52 * boss_alpha)
	var reticle_radius := maxf(rect.size.x, rect.size.y) * (0.44 if active else 0.34)
	_draw_boss_target_reticle(center, reticle_radius, reticle_color)


func _draw_boss_laser() -> void:
	var eye := _boss_laser_eye_position()
	if boss_laser_charge_timer >= 0.0:
		var charge_t := clampf(boss_laser_charge_timer / maxf(BOSS_LASER_CHARGE_DURATION, 0.01), 0.0, 1.0)
		var preview_y := _boss_laser_y(0.0)
		draw_circle(eye, 12.0 + charge_t * 22.0, Color(1.0, 0.18, 0.12, 0.15 + charge_t * 0.26), false, 3.0, true)
		draw_circle(eye, 5.0 + charge_t * 8.0, Color(1.0, 0.88, 0.64, 0.70 + charge_t * 0.24))
		draw_line(Vector2(_camera_left() - 30.0, preview_y), Vector2(eye.x, preview_y), Color(1.0, 0.18, 0.12, 0.18 + charge_t * 0.30), 8.0 + charge_t * 8.0, true)
		return
	if boss_laser_sweep_timer < 0.0:
		return
	var beam_rect := _boss_laser_active_rect()
	var y := beam_rect.get_center().y
	var left := beam_rect.position.x
	var right := beam_rect.end.x
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.10, 0.05, 0.24), BOSS_LASER_WIDTH * 2.6, true)
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.24, 0.12, 0.58), BOSS_LASER_WIDTH * 1.45, true)
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.92, 0.68, 0.96), BOSS_LASER_WIDTH * 0.42, true)
	draw_circle(eye, 18.0, Color(1.0, 0.28, 0.14, 0.54))
	draw_circle(eye, 8.0, Color(1.0, 0.94, 0.72, 0.94))


func _draw_boss_eye_attack() -> void:
	var eye := _boss_laser_eye_position()
	if boss_eye_charge_timer >= 0.0:
		var step := clampi(int(floor(boss_eye_charge_timer / BOSS_EYE_CHARGE_STEP_DURATION)), 0, 2)
		var step_t := fposmod(boss_eye_charge_timer, BOSS_EYE_CHARGE_STEP_DURATION) / BOSS_EYE_CHARGE_STEP_DURATION
		var colors := [
			Color(0.22, 0.58, 1.0, 0.94),
			Color(0.18, 1.0, 0.36, 0.94),
			Color(1.0, 0.16, 0.08, 0.98)
		]
		var glow = colors[step]
		var radius = 20.0 + step * 9.0 + step_t * 14.0
		draw_circle(eye, radius * 1.7, Color(glow.r, glow.g, glow.b, 0.16 + step_t * 0.12))
		draw_circle(eye, radius, Color(glow.r, glow.g, glow.b, 0.36 + step_t * 0.24))
		draw_circle(eye, 8.0 + radius * 0.18, Color(1.0, 0.96, 0.82, 0.76))
		var line_alpha = 0.12 + step_t * 0.16
		draw_line(Vector2(_camera_left() - 24.0, eye.y), eye, Color(glow.r, glow.g, glow.b, line_alpha), 10.0 + step * 5.0, true)
		return
	if boss_eye_beam_timer < 0.0:
		return
	var beam_rect := _boss_eye_beam_rect()
	var y := beam_rect.get_center().y
	var left := beam_rect.position.x
	var right := beam_rect.end.x
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.05, 0.02, 0.28), BOSS_EYE_BEAM_WIDTH * 2.2, true)
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.24, 0.10, 0.74), BOSS_EYE_BEAM_WIDTH * 1.2, true)
	draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 0.95, 0.72, 0.98), BOSS_EYE_BEAM_WIDTH * 0.42, true)
	draw_circle(eye, 34.0, Color(1.0, 0.12, 0.04, 0.42))
	draw_circle(eye, 13.0, Color(1.0, 0.96, 0.72, 0.95))


func _draw_boss_beam() -> void:
	var beam_top := boss_position + Vector2(0.0, 54.0)
	var beam_bottom := boss_position + Vector2(0.0, 214.0)
	draw_line(beam_top, beam_bottom, Color(0.74, 1.0, 0.76, 0.56), 22.0, true)
	draw_line(beam_top, beam_bottom, Color(0.90, 1.0, 0.92, 0.28), 42.0, true)
	for visual in boss_minion_spawn_visuals:
		var progress := float(visual.get("progress", 0.0))
		var start := visual.get("start", Vector2.ZERO) as Vector2
		var target := visual.get("target", Vector2.ZERO) as Vector2
		var draw_pos := start.lerp(target, progress)
		var scale := lerpf(0.03, 0.09, progress)
		if boss_minion_texture != null:
			var size := boss_minion_texture.get_size() * scale
			draw_texture_rect(boss_minion_texture, Rect2(draw_pos - size * 0.5, size), false)


func _draw_boss_portal() -> void:
	var portal_center := boss_position + Vector2(0.0, 148.0)
	var portal_radius_x := 160.0
	var portal_radius_y := 44.0 + sin(boss_portal_timer * 8.0) * 4.0
	var portal_points := PackedVector2Array()
	for index in range(24):
		var angle := float(index) / 24.0 * TAU
		portal_points.append(portal_center + Vector2(cos(angle) * portal_radius_x, sin(angle) * portal_radius_y))
	draw_colored_polygon(portal_points, Color(0.34, 0.02, 0.02, 0.86))
	draw_polyline(portal_points + PackedVector2Array([portal_points[0]]), Color(1.0, 0.42, 0.18, 0.72), 3.0, true)
	var hand_base := portal_center + Vector2(0.0, -4.0)
	var hand_height := 86.0 + boss_portal_timer * 26.0
	draw_line(hand_base, hand_base + Vector2(0.0, -hand_height), Color(0.18, 0.02, 0.02, 0.92), 18.0, true)
	for finger in [-36.0, -12.0, 12.0, 36.0]:
		draw_line(hand_base + Vector2(finger * 0.4, -hand_height * 0.74), hand_base + Vector2(finger, -hand_height), Color(0.98, 0.38, 0.14, 0.82), 10.0, true)


func _draw_pickup_icon(pickup: Dictionary) -> void:
	var pos := pickup.get("position", Vector2.ZERO) as Vector2
	var kind := str(pickup.get("kind", "score_medal"))
	if kind == "gold_coin":
		_draw_speedbike_coin(pos, false, float(pickup.get("time", 0.0)))
		return
	if kind in ["blue_coin", "final_blue_coin"]:
		_draw_speedbike_coin(pos, true, float(pickup.get("time", 0.0)))
		return
	var texture_path := str(PICKUP_TEXTURE_PATHS.get(kind, ""))
	if not texture_path.is_empty():
		var texture := _load_texture(texture_path)
		if texture != null:
			var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
			var draw_height := 52.0
			var draw_size := texture_size * (draw_height / maxf(texture_size.y, 1.0))
			draw_circle(pos + Vector2(0.0, 15.0), 19.0, Color(0.0, 0.0, 0.0, 0.26))
			draw_texture_rect(texture, Rect2(pos - draw_size * 0.5, draw_size), false, Color(1.0, 1.0, 1.0, 0.96))
			return
	var color := Color(0.94, 0.86, 0.34, 0.92)
	match kind:
		"shield":
			color = Color(0.52, 0.88, 1.0, 0.92)
		"slow_time":
			color = Color(0.72, 0.62, 1.0, 0.92)
		"repair", "health", "green", "blue":
			color = Color(0.52, 1.0, 0.62, 0.92)
		"purple":
			color = Color(0.70, 0.42, 1.0, 0.92)
		"gold", "extra_life", "1up", "one_up", "life":
			color = Color(1.0, 0.84, 0.24, 0.92)
		"rapid", "cannon_boost":
			color = Color(1.0, 0.68, 0.28, 0.92)
		"machine":
			color = Color(1.0, 0.92, 0.46, 0.92)
		"spread":
			color = Color(1.0, 0.48, 0.32, 0.92)
		"laser":
			color = Color(0.36, 0.92, 1.0, 0.92)
		"rocket":
			color = Color(0.94, 0.42, 0.22, 0.92)
		"fireball":
			color = Color(1.0, 0.24, 0.10, 0.92)
		_:
			pass
	draw_circle(pos, 14.0, Color(0.0, 0.0, 0.0, 0.24))
	draw_circle(pos, 12.0, color)
	if kind in ["repair", "health", "green", "blue", "purple", "gold"]:
		draw_line(pos + Vector2(-6.0, 0.0), pos + Vector2(6.0, 0.0), Color(0.12, 0.12, 0.16, 0.72), 2.0, true)
		draw_line(pos + Vector2(0.0, -6.0), pos + Vector2(0.0, 6.0), Color(0.12, 0.12, 0.16, 0.72), 2.0, true)
	else:
		var label := kind.substr(0, 1).to_upper()
		draw_string(ThemeDB.fallback_font, pos + Vector2(-6.0, 5.0), label, HORIZONTAL_ALIGNMENT_LEFT, 20.0, 13, Color(0.08, 0.06, 0.04, 0.84))


func _draw_speedbike_coin(pos: Vector2, rare_blue: bool, age: float) -> void:
	var texture := _load_texture(BLUE_COIN_TEXTURE_PATH if rare_blue else GOLD_COIN_TEXTURE_PATH)
	if texture != null:
		var pulse_size := 44.0 + sin(age * 6.0) * 2.0
		var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
		var draw_size := texture_size * (pulse_size / maxf(texture_size.y, 1.0))
		draw_circle(pos + Vector2(0.0, 16.0), 16.0, Color(0.0, 0.0, 0.0, 0.24))
		draw_circle(pos, 23.0 + sin(age * 7.0) * 2.0, Color(0.14, 0.72, 1.0, 0.14) if rare_blue else Color(1.0, 0.74, 0.16, 0.12))
		draw_texture_rect(texture, Rect2(pos - draw_size * 0.5, draw_size), false, Color(1.0, 1.0, 1.0, 0.98))
		return
	var pulse := 0.5 + sin(age * 6.0) * 0.5
	var outer := Color(0.18, 0.72, 1.0, 0.88) if rare_blue else Color(1.0, 0.74, 0.18, 0.92)
	var inner := Color(0.72, 0.94, 1.0, 0.96) if rare_blue else Color(1.0, 0.94, 0.44, 0.96)
	var dark := Color(0.04, 0.09, 0.16, 0.78) if rare_blue else Color(0.24, 0.12, 0.02, 0.78)
	draw_circle(pos + Vector2(0.0, 16.0), 15.0, Color(0.0, 0.0, 0.0, 0.22))
	draw_circle(pos, 16.0 + pulse * 1.8, Color(outer.r, outer.g, outer.b, 0.18 + pulse * 0.10))
	draw_circle(pos, 14.0, outer)
	draw_circle(pos, 9.0, inner)
	draw_arc(pos, 11.0, -1.15, 1.15, 18, dark, 2.2, true)
	if rare_blue:
		var star := PackedVector2Array()
		for index in range(8):
			var radius := 7.0 if index % 2 == 0 else 3.2
			var angle := -PI * 0.5 + float(index) * TAU / 8.0
			star.append(pos + Vector2(cos(angle) * radius, sin(angle) * radius))
		draw_colored_polygon(star, Color(0.06, 0.32, 0.62, 0.82))
	else:
		draw_line(pos + Vector2(-4.0, -6.0), pos + Vector2(4.0, 6.0), dark, 2.2, true)
		draw_line(pos + Vector2(-5.0, 0.0), pos + Vector2(5.0, 0.0), dark, 2.0, true)


func _using_headlight_visibility() -> bool:
	return blackout_strength > 0.01


func _headlight_beam_geometry() -> Dictionary:
	var beam_origin: Vector2 = player_speedbike.bike_midpoint() + Vector2(72.0, -8.0)
	var near_half := 62.0
	var far_x := minf(_camera_right() + 64.0, beam_origin.x + 448.0)
	var far_half := 156.0
	return {
		"origin": beam_origin,
		"near_half": near_half,
		"far_x": far_x,
		"far_half": far_half
	}


func _headlight_visibility_alpha(world_pos: Vector2, radius_y: float = 0.0, radius_x: float = 0.0) -> float:
	if not _using_headlight_visibility():
		return 1.0
	var beam := _headlight_beam_geometry()
	var beam_origin := beam.get("origin", world_pos) as Vector2
	var near_half := float(beam.get("near_half", 62.0))
	var far_x := float(beam.get("far_x", beam_origin.x + 448.0))
	var far_half := float(beam.get("far_half", 156.0))
	if world_pos.x < beam_origin.x - 54.0 - radius_x:
		return 0.02
	if world_pos.x > far_x + 26.0 + radius_x:
		return 0.02
	var t := clampf((world_pos.x - beam_origin.x) / maxf(far_x - beam_origin.x, 1.0), 0.0, 1.0)
	var beam_half := lerpf(near_half, far_half, t) + radius_y
	var dy := absf(world_pos.y - beam_origin.y)
	if dy <= beam_half:
		var inner_ratio := 1.0 - clampf(dy / maxf(beam_half, 1.0), 0.0, 1.0)
		return clampf(0.84 + inner_ratio * 0.16, 0.0, 1.0)
	var fade_half := beam_half + 38.0 + radius_y * 0.35
	if dy <= fade_half:
		var fade_ratio := 1.0 - clampf((dy - beam_half) / maxf(fade_half - beam_half, 1.0), 0.0, 1.0)
		return lerpf(0.03, 0.28, fade_ratio)
	return 0.02


func _apply_headlight_visibility_to_runtime() -> void:
	var using_blackout := _using_headlight_visibility()
	for obstacle in active_obstacles:
		if not is_instance_valid(obstacle):
			continue
		if not using_blackout:
			obstacle.modulate = Color(1.0, 1.0, 1.0, 1.0)
			continue
		var leading_x: float = obstacle.leading_x()
		var trailing_x: float = obstacle.trailing_x()
		var sample_x := leading_x + minf((trailing_x - leading_x) * 0.34, 42.0)
		var sample_y := speedbike_lane_y(2)
		var entries: Array = obstacle.warning_entries()
		if not entries.is_empty():
			sample_y = float((entries[0] as Dictionary).get("y", sample_y))
		var alpha := _headlight_visibility_alpha(
			Vector2(sample_x, sample_y),
			52.0,
			maxf((trailing_x - leading_x) * 0.20, 18.0)
		)
		obstacle.modulate = Color(1.0, 1.0, 1.0, alpha)
	for drone in active_drones:
		if not is_instance_valid(drone):
			continue
		if not using_blackout:
			drone.modulate = Color(1.0, 1.0, 1.0, 1.0)
			continue
		var drone_box: Rect2 = drone.hurtbox_rect()
		var alpha := _headlight_visibility_alpha(
			drone_box.get_center(),
			drone_box.size.y * 0.52,
			drone_box.size.x * 0.34
		)
		drone.modulate = Color(1.0, 1.0, 1.0, alpha)


func _draw_blackout_headlight(left: float, width: float) -> void:
	var dark := Color(0.0, 0.0, 0.0, blackout_strength)
	var soft_dark := Color(0.0, 0.0, 0.0, blackout_strength * 0.56)
	var beam := _headlight_beam_geometry()
	var beam_origin := beam.get("origin", player_speedbike.bike_midpoint()) as Vector2
	var near_half := float(beam.get("near_half", 62.0))
	var far_x := minf(left + width, float(beam.get("far_x", beam_origin.x + 448.0)))
	var far_half := float(beam.get("far_half", 156.0))
	var beam_top_near: float = beam_origin.y - near_half
	var beam_bottom_near: float = beam_origin.y + near_half
	var beam_top_far: float = beam_origin.y - far_half
	var beam_bottom_far: float = beam_origin.y + far_half
	draw_colored_polygon(PackedVector2Array([
		Vector2(left, 0.0),
		Vector2(left + width, 0.0),
		Vector2(far_x, beam_top_far),
		Vector2(beam_origin.x, beam_top_near),
		Vector2(left, beam_top_near)
	]), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(left, beam_bottom_near),
		Vector2(beam_origin.x, beam_bottom_near),
		Vector2(far_x, beam_bottom_far),
		Vector2(left + width, screen_size.y),
		Vector2(left, screen_size.y)
	]), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(left, beam_top_near),
		Vector2(beam_origin.x - 38.0, beam_top_near),
		Vector2(beam_origin.x - 14.0, beam_origin.y - 20.0),
		Vector2(beam_origin.x - 14.0, beam_origin.y + 20.0),
		Vector2(beam_origin.x - 38.0, beam_bottom_near),
		Vector2(left, beam_bottom_near)
	]), soft_dark)
	draw_polygon(PackedVector2Array([
		Vector2(beam_origin.x, beam_top_near),
		Vector2(far_x, beam_top_far),
		Vector2(far_x, beam_bottom_far),
		Vector2(beam_origin.x, beam_bottom_near)
	]), PackedColorArray([
		Color(1.0, 0.94, 0.76, 0.10 + blackout_strength * 0.08),
		Color(1.0, 0.92, 0.68, 0.03 + blackout_strength * 0.04),
		Color(1.0, 0.92, 0.68, 0.03 + blackout_strength * 0.04),
		Color(1.0, 0.94, 0.76, 0.10 + blackout_strength * 0.08)
	]))
	draw_circle(beam_origin, 38.0, Color(1.0, 0.92, 0.68, 0.12 + blackout_strength * 0.10))
	draw_circle(beam_origin + Vector2(36.0, 0.0), 24.0, Color(1.0, 0.94, 0.72, 0.10 + blackout_strength * 0.08))


func _draw_fx_entry(fx: Dictionary) -> void:
	var kind := str(fx.get("kind", "burst"))
	var t := clampf(float(fx.get("time", 0.0)) / maxf(float(fx.get("life", 0.3)), 0.01), 0.0, 1.0)
	var pos := fx.get("position", Vector2.ZERO) as Vector2
	var color := fx.get("color", Color.WHITE) as Color
	if kind == "text":
		var font := ThemeDB.fallback_font
		if font != null:
			var alpha_color := Color(color.r, color.g, color.b, (1.0 - t) * color.a)
			draw_string(font, pos + Vector2(0.0, -t * 18.0), str(fx.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, 240.0, 18, alpha_color)
		return
	if kind == "ash":
		var radius := float(fx.get("radius", 4.0)) * (1.0 - t * 0.55)
		draw_circle(pos, maxf(radius, 0.8), Color(color.r, color.g, color.b, (1.0 - t) * color.a))
		return
	var radius := lerpf(16.0, 54.0, t)
	draw_circle(pos, radius, Color(color.r, color.g, color.b, (1.0 - t) * color.a * 0.22))
	for spark in range(8):
		var angle := float(spark) / 8.0 * TAU
		var start := pos + Vector2(cos(angle), sin(angle)) * radius * 0.28
		var finish := pos + Vector2(cos(angle), sin(angle)) * radius
		draw_line(start, finish, Color(color.r, color.g, color.b, (1.0 - t) * color.a * 0.92), 2.0, true)


func _draw_practice_markers() -> void:
	for obstacle in active_obstacles:
		if obstacle.destroyed:
			continue
		var x: float = obstacle.leading_x()
		if x < _camera_left() or x > _camera_right() + 220.0:
			continue
		draw_line(Vector2(x, speedbike_top_bound() - 26.0), Vector2(x, speedbike_bottom_bound() + 26.0), Color(0.54, 0.88, 1.0, 0.14), 3.0, true)
	for drone in active_drones:
		if drone.destroyed:
			continue
		if drone.position.x < _camera_left() or drone.position.x > _camera_right() + 220.0:
			continue
		draw_circle(drone.position, 26.0, Color(0.54, 0.88, 1.0, 0.08))


func _draw_incoming_warning_markers() -> void:
	var right_edge := _camera_right() - 20.0
	for obstacle in active_obstacles:
		if obstacle.destroyed:
			continue
		var obstacle_x: float = obstacle.leading_x()
		if obstacle_x < _camera_right() - 18.0 or obstacle_x > _camera_right() + SPAWN_WARNING_DISTANCE:
			continue
		var strength := 1.0 - clampf((obstacle_x - _camera_right()) / SPAWN_WARNING_DISTANCE, 0.0, 1.0)
		_draw_incoming_obstacle_preview(obstacle, right_edge, strength)
	for drone in active_drones:
		if drone.destroyed:
			continue
		if drone.position.x < _camera_right() - 18.0 or drone.position.x > _camera_right() + SPAWN_WARNING_DISTANCE:
			continue
		var strength := 1.0 - clampf((drone.position.x - _camera_right()) / SPAWN_WARNING_DISTANCE, 0.0, 1.0)
		_draw_incoming_drone_preview(drone, right_edge, strength)


func _incoming_preview_alpha(strength: float) -> float:
	var pulse := 0.5 + sin(strength * TAU * 3.0) * 0.5
	return (0.18 + pulse * 0.62) * (0.46 + strength * 0.54)


func _incoming_preview_color(kind: String, destructible: bool, alpha: float) -> Color:
	if kind == "pit":
		return Color(0.03, 0.03, 0.04, alpha)
	if kind == "oil_spill":
		return Color(0.02, 0.055, 0.04, alpha)
	if kind == "ramp":
		return Color(0.94, 0.62, 0.18, alpha)
	if kind == "laser_gate":
		return Color(1.0, 0.18, 0.15, alpha)
	if kind == "mine" or destructible:
		return Color(0.96, 0.20, 0.16, alpha)
	if kind == "low_barricade":
		return Color(0.96, 0.48, 0.18, alpha)
	return Color(0.76, 0.78, 0.86, alpha)


func _draw_incoming_texture_preview_entry(entry: Dictionary, alpha: float) -> bool:
	var path := str(entry.get("path", ""))
	if path.is_empty():
		return false
	var texture := _load_texture(path)
	if texture == null:
		return false
	var rect := entry.get("rect", Rect2()) as Rect2
	if bool(entry.get("tile_pit", false)):
		draw_rect(rect, Color(0.008, 0.007, 0.008, alpha), true)
		_draw_speedbike_tiled_preview_texture(texture, rect, Color(1.0, 1.0, 1.0, alpha))
		_draw_incoming_preview_frame(rect, alpha)
		return true
	if bool(entry.get("flip_h", false)):
		draw_set_transform(Vector2(rect.position.x + rect.size.x, rect.position.y), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(texture, Rect2(Vector2.ZERO, rect.size), false, Color(1.0, 1.0, 1.0, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_draw_incoming_preview_frame(rect, alpha)
		return true
	draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))
	_draw_incoming_preview_frame(rect, alpha)
	return true


func _draw_incoming_preview_frame(rect: Rect2, alpha: float) -> void:
	var frame_alpha := clampf(alpha * 0.86, 0.0, 0.82)
	var glow_rect := rect.grow(6.0)
	draw_rect(glow_rect, Color(1.0, 0.72, 0.24, frame_alpha * 0.10), false, 4.0)
	draw_rect(glow_rect.grow(5.0), Color(0.18, 0.72, 1.0, frame_alpha * 0.08), false, 2.0)
	var scan_count := clampi(int(rect.size.y / 28.0), 2, 8)
	for scan in range(scan_count):
		var t := float(scan + 1) / float(scan_count + 1)
		var y := lerpf(rect.position.y + 6.0, rect.end.y - 6.0, t)
		draw_line(Vector2(rect.position.x + 4.0, y), Vector2(rect.end.x - 4.0, y), Color(1.0, 0.92, 0.64, frame_alpha * 0.18), 1.0, true)


func _draw_speedbike_tiled_preview_texture(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
		return
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	var draw_height := clampf(rect.size.x * texture_size.y / maxf(texture_size.x, 1.0), 54.0, minf(rect.size.y * 0.72, 116.0))
	var pit_rect := Rect2(rect.position.x, rect.get_center().y - draw_height * 0.5, rect.size.x, draw_height)
	var tile_width := pit_rect.size.y * texture_size.x / maxf(texture_size.y, 1.0)
	if pit_rect.size.x <= tile_width * 1.08:
		var scale := minf(pit_rect.size.x / texture_size.x, pit_rect.size.y / texture_size.y)
		var draw_size := texture_size * scale
		draw_texture_rect(texture, Rect2(pit_rect.get_center() - draw_size * 0.5, draw_size), false, tint)
		return
	var x := pit_rect.position.x
	var end_x := pit_rect.end.x
	while x < end_x - 1.0:
		var draw_width := minf(tile_width, end_x - x)
		var source_width := texture_size.x * draw_width / maxf(tile_width, 1.0)
		draw_texture_rect_region(
			texture,
			Rect2(x, pit_rect.position.y, draw_width, pit_rect.size.y),
			Rect2(0.0, 0.0, source_width, texture_size.y),
			tint
		)
		x += tile_width * 0.96


func _draw_incoming_obstacle_preview(obstacle, right_edge: float, strength: float) -> void:
	if not obstacle.has_method("preview_rects"):
		return
	var rects: Array = obstacle.preview_rects(right_edge)
	if rects.is_empty():
		return
	var alpha := _incoming_preview_alpha(strength)
	var kind := str(obstacle.obstacle_type)
	var destructible := bool(obstacle.destructible)
	if obstacle.has_method("preview_texture_entries"):
		var drew_texture := false
		var entries: Array = obstacle.preview_texture_entries(right_edge)
		for entry_value in entries:
			var entry := entry_value as Dictionary
			drew_texture = _draw_incoming_texture_preview_entry(entry, alpha) or drew_texture
		if drew_texture:
			var label_pos_texture := Vector2(right_edge - 120.0, clampf((rects[0] as Rect2).position.y - 16.0, speedbike_top_bound() - 34.0, speedbike_bottom_bound() + 18.0))
			draw_string(ThemeDB.fallback_font, label_pos_texture, "INCOMING", HORIZONTAL_ALIGNMENT_RIGHT, 110.0, 12, Color(1.0, 0.82, 0.54, alpha))
			return
	var fill := _incoming_preview_color(kind, destructible, alpha)
	var edge := Color(1.0, 0.90, 0.66, clampf(alpha + 0.16, 0.0, 0.9))
	for rect_value in rects:
		var rect := rect_value as Rect2
		if kind == "ramp":
			var base_y := rect.position.y + rect.size.y
			var plate_h := minf(rect.size.y * 0.42, 34.0)
			var track_y := base_y - plate_h
			var ramp_poly := PackedVector2Array([
				Vector2(rect.position.x, base_y),
				Vector2(rect.position.x + rect.size.x * 0.20, base_y),
				Vector2(rect.end.x - 10.0, track_y),
				Vector2(rect.end.x, base_y)
			])
			draw_colored_polygon(ramp_poly, fill)
			draw_polyline(PackedVector2Array([ramp_poly[0], ramp_poly[1], ramp_poly[2], ramp_poly[3], ramp_poly[0]]), edge, 3.0, true)
			draw_line(Vector2(rect.position.x + 10.0, base_y - 4.0), Vector2(rect.end.x - 12.0, track_y + 2.0), Color(1.0, 0.90, 0.36, alpha), 4.0, true)
			draw_rect(Rect2(rect.position.x - 8.0, base_y - 16.0, rect.size.x + 22.0, 16.0), Color(0.0, 0.0, 0.0, alpha * 0.20), true)
		elif kind == "mine":
			draw_circle(rect.get_center(), rect.size.x * 0.44, fill)
			draw_circle(rect.get_center(), rect.size.x * 0.18, Color(1.0, 0.72, 0.26, alpha))
		elif kind == "oil_spill":
			_draw_speedbike_ellipse(rect.get_center(), Vector2(rect.size.x * 0.48, rect.size.y * 0.45), fill)
			draw_line(rect.get_center() + Vector2(-rect.size.x * 0.32, -2.0), rect.get_center() + Vector2(rect.size.x * 0.28, -5.0), Color(0.42, 1.0, 0.62, alpha * 0.62), 3.0, true)
		else:
			draw_rect(rect, fill, true)
			draw_rect(rect, edge, false, 3.0)
			if destructible:
				var center := rect.get_center()
				draw_circle(center, minf(rect.size.x, rect.size.y) * 0.16, Color(1.0, 0.82, 0.22, alpha))
				draw_line(center + Vector2(-10.0, 0.0), center + Vector2(10.0, 0.0), Color(0.18, 0.08, 0.06, alpha), 2.0, true)
				draw_line(center + Vector2(0.0, -10.0), center + Vector2(0.0, 10.0), Color(0.18, 0.08, 0.06, alpha), 2.0, true)
	var label_pos := Vector2(right_edge - 120.0, clampf((rects[0] as Rect2).position.y - 16.0, speedbike_top_bound() - 34.0, speedbike_bottom_bound() + 18.0))
	draw_string(ThemeDB.fallback_font, label_pos, "INCOMING", HORIZONTAL_ALIGNMENT_RIGHT, 110.0, 12, Color(1.0, 0.82, 0.54, alpha))


func _draw_incoming_drone_preview(drone, right_edge: float, strength: float) -> void:
	var alpha := _incoming_preview_alpha(strength)
	var display_size: Vector2 = drone.display_size
	var center := Vector2(right_edge - display_size.x * 0.5 - 6.0, drone.position.y)
	var rect := Rect2(center - display_size * 0.5, display_size)
	draw_circle(center + Vector2(-display_size.x * 0.10, display_size.y * 0.32), display_size.x * 0.20, Color(0.0, 0.0, 0.0, alpha * 0.24))
	if drone.drone_texture != null:
		draw_texture_rect(drone.drone_texture, rect, false, Color(1.0, 1.0, 1.0, alpha))
	else:
		draw_rect(rect, Color(0.36, 0.34, 0.40, alpha), true)
	draw_rect(rect.grow(4.0), Color(1.0, 0.24, 0.18, clampf(alpha + 0.10, 0.0, 0.9)), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(-8.0, -8.0), "HOSTILE", HORIZONTAL_ALIGNMENT_RIGHT, display_size.x + 8.0, 12, Color(1.0, 0.78, 0.62, alpha))
