extends Node

const APP_SHELL_SCENE := "res://scenes/speedbike/SpeedbikeMode.tscn"
const BADLANDS_SPEEDBIKE_STAGE_IDS := [
	"speedbike_01_ignition_run", "speedbike_02_white_knuckle_gates",
	"speedbike_03_dropper_drone_alley", "speedbike_04_blackout_tube",
	"speedbike_05_pulse_grid", "speedbike_06_minefield_rush",
	"speedbike_07_split_shaft_switchback", "speedbike_08_reverse_signal",
	"speedbike_09_overdrive_no_brake", "speedbike_10_voss_blaus_tunnel"
]

var current_campaign_id := "standalone_speedbike"
var current_map_id := BADLANDS_SPEEDBIKE_STAGE_IDS[0]
var skirmish_map_id := BADLANDS_SPEEDBIKE_STAGE_IDS[0]
var current_segment_index := 0
var speedbike_checkpoints_enabled := true
var speedbike_practice_mode := false
var speedbike_speed_multiplier := 1.0
var speedbike_rider_id := "speedbike"
var speedbike_skill_mode_enabled := false

func is_story_mode() -> bool: return false
func is_speedbike_map(value: String) -> bool: return value.begins_with("speedbike_")
func speedbike_difficulty() -> Dictionary: return {"id":"normal", "label":"NORMAL"}
func speedbike_stage_label(stage_id: String) -> String: return stage_id.trim_prefix("speedbike_").replace("_", " ").capitalize()
func set_speedbike_checkpoints_enabled(value: bool) -> void: speedbike_checkpoints_enabled = value
func flush_progress() -> void: pass
func adjust_village_coins(_amount: int, _reason: String = "", _save: bool = true) -> void: pass
func advance_story_segment() -> Dictionary: return {}
func selected_story_launch_scene() -> String: return APP_SHELL_SCENE

