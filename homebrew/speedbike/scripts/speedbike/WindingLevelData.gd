extends RefCounted
class_name WindingLevelData

const FIRST_STAGE := 50
const LAST_STAGE := 70

const STAGE_NAMES := {
	50: "Dust Serpent Road",
	51: "Canyon S-Curves",
	52: "Broken Pipeway",
	53: "Razor Ridge Descent",
	54: "Glass Tunnel Bend",
	55: "Sandstorm Switchback",
	56: "Neon Mine Road",
	57: "Dropper Drone Corkscrew",
	58: "Gravity Wobble Run",
	59: "No-Brake Death Spiral",
	60: "Voss Blau Winding Tunnel",
	61: "Redline Entry",
	62: "Crimson Light Rail",
	63: "Bloodglass Service Tube",
	64: "Ember Fan Corridor",
	65: "Black Furnace Sprint",
	66: "Siren Rib Passage",
	67: "Molten Switchback",
	68: "Red Pulse Underpass",
	69: "Overheat Kill Tube",
	70: "Voss Blau Redline Core"
}

const THEMES := {
	"badlands_canyon": {
		"sky_top": Color(0.18, 0.13, 0.10),
		"sky_bottom": Color(0.55, 0.30, 0.12),
		"road": Color(0.20, 0.18, 0.16),
		"road_alt": Color(0.16, 0.14, 0.13),
		"edge": Color(0.95, 0.47, 0.12),
		"lane": Color(0.96, 0.72, 0.34),
		"fog": Color(0.80, 0.43, 0.18, 0.18)
	},
	"industrial_pipe": {
		"sky_top": Color(0.08, 0.10, 0.12),
		"sky_bottom": Color(0.27, 0.21, 0.16),
		"road": Color(0.15, 0.17, 0.18),
		"road_alt": Color(0.11, 0.12, 0.13),
		"edge": Color(0.16, 0.62, 0.86),
		"lane": Color(0.86, 0.56, 0.20),
		"fog": Color(0.20, 0.60, 0.85, 0.12)
	},
	"glass_tunnel": {
		"sky_top": Color(0.06, 0.12, 0.20),
		"sky_bottom": Color(0.26, 0.52, 0.72),
		"road": Color(0.10, 0.18, 0.25),
		"road_alt": Color(0.08, 0.14, 0.20),
		"edge": Color(0.30, 0.90, 1.00),
		"lane": Color(0.80, 0.96, 1.00),
		"fog": Color(0.55, 0.90, 1.00, 0.13)
	},
	"sandstorm": {
		"sky_top": Color(0.33, 0.22, 0.12),
		"sky_bottom": Color(0.78, 0.50, 0.19),
		"road": Color(0.22, 0.18, 0.13),
		"road_alt": Color(0.18, 0.14, 0.10),
		"edge": Color(1.00, 0.64, 0.18),
		"lane": Color(1.00, 0.80, 0.35),
		"fog": Color(0.95, 0.56, 0.18, 0.26)
	},
	"neon_mine": {
		"sky_top": Color(0.04, 0.06, 0.10),
		"sky_bottom": Color(0.08, 0.16, 0.22),
		"road": Color(0.08, 0.10, 0.14),
		"road_alt": Color(0.06, 0.08, 0.12),
		"edge": Color(0.14, 0.90, 0.72),
		"lane": Color(0.94, 0.25, 0.18),
		"fog": Color(0.00, 0.95, 0.75, 0.11)
	},
	"enemy_tunnel": {
		"sky_top": Color(0.08, 0.02, 0.03),
		"sky_bottom": Color(0.36, 0.03, 0.04),
		"road": Color(0.16, 0.06, 0.06),
		"road_alt": Color(0.10, 0.03, 0.04),
		"edge": Color(1.00, 0.12, 0.05),
		"lane": Color(1.00, 0.48, 0.18),
		"fog": Color(0.95, 0.04, 0.04, 0.16)
	},
	"red_tunnel": {
		"sky_top": Color(0.015, 0.002, 0.004),
		"sky_bottom": Color(0.19, 0.010, 0.018),
		"road": Color(0.105, 0.018, 0.020),
		"road_alt": Color(0.060, 0.010, 0.014),
		"edge": Color(1.00, 0.055, 0.030),
		"lane": Color(1.00, 0.30, 0.12),
		"fog": Color(1.00, 0.02, 0.02, 0.20)
	}
}

static func stage_ids() -> Array[String]:
	var rows: Array[String] = []
	for stage in range(FIRST_STAGE, LAST_STAGE + 1):
		rows.append(stage_id(stage))
	return rows


static func stage_id(stage: int) -> String:
	return "badlands_speedbike_%02d" % stage


static func is_winding_stage(map_id: String) -> bool:
	var stage := stage_number(map_id)
	return stage >= FIRST_STAGE and stage <= LAST_STAGE


static func stage_number(map_id: String) -> int:
	var clean_id := map_id.strip_edges()
	if clean_id.is_empty():
		return 0
	return int(clean_id.get_slice("_", 2))


static func stage_label(map_id: String) -> String:
	var stage := stage_number(map_id)
	var name := str(STAGE_NAMES.get(stage, "Winding Road"))
	return "Winding Road Set - Stage %d: %s" % [stage, name]


static func get_level(map_id: String) -> Dictionary:
	var stage := clampi(stage_number(map_id), FIRST_STAGE, LAST_STAGE)
	var data := _base_level(stage)
	var section_length := float(data.get("length", 6100.0))
	var section_count := 2
	data["length"] = section_length * float(section_count)
	data["curves"] = _repeat_world_rows(_curves_for_stage(stage), section_length, section_count, false)
	data["hills"] = _repeat_world_rows(_hills_for_stage(stage), section_length, section_count, false)
	data["obstacles"] = _repeat_world_rows(_obstacles_for_stage(stage), section_length, section_count, true)
	var checkpoint_seed: Array[float] = [1500.0, 3000.0, 4500.0]
	if stage >= 59:
		checkpoint_seed = [1350.0, 2700.0, 4050.0, 5400.0]
	data["checkpoints"] = _repeat_checkpoints(checkpoint_seed, section_length, section_count)
	return data


static func get_chapter_level(map_id: String) -> Dictionary:
	var start_stage := clampi(stage_number(map_id), FIRST_STAGE, LAST_STAGE)
	var chapter := get_level(stage_id(start_stage))
	var curves: Array[Dictionary] = []
	var hills: Array[Dictionary] = []
	var obstacles: Array[Dictionary] = []
	var checkpoints: Array[float] = []
	var stage_segments: Array[Dictionary] = []
	var offset := 0.0
	for stage in range(start_stage, LAST_STAGE + 1):
		var section := get_level(stage_id(stage))
		var section_length := float(section.get("length", 6000.0))
		stage_segments.append({
			"stage": stage,
			"name": str(section.get("display_name", "Winding Road")),
			"start": offset,
			"end": offset + section_length
		})
		for row in section.get("curves", []):
			var next := (row as Dictionary).duplicate(true)
			next["z"] = float(next.get("z", 0.0)) + offset
			curves.append(next)
		for row in section.get("hills", []):
			var next := (row as Dictionary).duplicate(true)
			next["z"] = float(next.get("z", 0.0)) + offset
			hills.append(next)
		for row in section.get("obstacles", []):
			var next := (row as Dictionary).duplicate(true)
			next["z"] = float(next.get("z", 0.0)) + offset
			obstacles.append(next)
		for checkpoint in section.get("checkpoints", []):
			checkpoints.append(float(checkpoint) + offset)
		offset += section_length
	chapter["length"] = offset
	chapter["curves"] = curves
	chapter["hills"] = hills
	chapter["obstacles"] = obstacles
	chapter["checkpoints"] = checkpoints
	chapter["stage_segments"] = stage_segments
	chapter["continuous_run"] = true
	chapter["display_name"] = "Winding Road Set %d-%d" % [start_stage, LAST_STAGE]
	chapter["warning"] = "Continuous winding road run. Survive every bend without the road stopping."
	return chapter


static func _base_level(stage: int) -> Dictionary:
	var theme := "badlands_canyon"
	var length := 6100.0
	var base_speed := 1040.0 + float(stage - FIRST_STAGE) * 74.0
	var curve_force := 0.58 + float(stage - FIRST_STAGE) * 0.035
	if stage >= 61:
		theme = "red_tunnel"
		length = 6900.0 + float(stage - 61) * 120.0
		base_speed = 1660.0 + float(stage - 61) * 82.0
		curve_force = 0.78 + float(stage - 61) * 0.035
	match stage:
		52:
			theme = "industrial_pipe"
		54:
			theme = "glass_tunnel"
		55:
			theme = "sandstorm"
		56:
			theme = "neon_mine"
		57:
			theme = "industrial_pipe"
		58:
			theme = "glass_tunnel"
			curve_force += 0.10
		59:
			theme = "enemy_tunnel"
			length = 6800.0
			base_speed = 1720.0
			curve_force += 0.18
		60:
			theme = "enemy_tunnel"
			length = 7200.0
			base_speed = 1640.0
			curve_force += 0.12
	return {
		"stage": stage,
		"stage_id": stage_id(stage),
		"display_name": str(STAGE_NAMES.get(stage, "Winding Road")),
		"theme_id": theme,
		"theme": THEMES.get(theme, THEMES["badlands_canyon"]),
		"length": length,
		"base_speed": base_speed,
		"speed_gain": 28.0 + float(stage - FIRST_STAGE) * 4.5,
		"curve_force": curve_force,
		"warning": _warning_for_stage(stage)
	}


static func _warning_for_stage(stage: int) -> String:
	match stage:
		50:
			return "Read the bend. The road pulls against you."
		51:
			return "S-curves punish over-correction."
		52:
			return "Broken pipe gaps need clean jump timing."
		53:
			return "Descent speed rises fast. Watch the edge."
		54:
			return "Glass bends hide laser timing. Stay readable."
		55:
			return "Sand gusts shove the bike sideways."
		56:
			return "Mines are safer shot early than dodged late."
		57:
			return "Dropper drones can close your safest lane."
		58:
			return "Gravity wobble makes jumps float longer."
		59:
			return "No brakes. No panic taps."
		60:
			return "Survive Voss Blau's winding tunnel engine."
		61:
			return "The tunnel goes full red. Read the overhead lights and stay calm."
		62:
			return "Crimson rails strobe fast. Do not chase every light."
		63:
			return "Bloodglass panels hide tight split gates."
		64:
			return "Ember fans shove the bike through hot rib turns."
		65:
			return "The furnace sprint stacks ramps, mines, and red fog."
		66:
			return "Siren ribs mark the safe lane half a second early."
		67:
			return "Molten switchbacks pull hard against your steering."
		68:
			return "Red pulse gates cycle with the ceiling lights."
		69:
			return "Overheat speed. Short reactions. No sleepy hands."
		70:
			return "Break through the Redline Core before the tunnel seals."
	return "Winding road."


static func _curves_for_stage(stage: int) -> Array[Dictionary]:
	match stage:
		50:
			return [_curve(520, 1180, -0.42), _curve(2160, 1320, 0.52), _curve(3920, 1480, -0.48)]
		51:
			return [_curve(360, 1080, -0.66), _curve(1880, 1240, 0.74), _curve(3540, 1320, -0.78), _curve(5260, 980, 0.58)]
		52:
			return [_curve(620, 1280, 0.50), _curve(2440, 1180, -0.58), _curve(4160, 1360, 0.62)]
		53:
			return [_curve(560, 1420, -0.54), _curve(2360, 1260, 0.72), _curve(4120, 1480, -0.76)]
		54:
			return [_curve(480, 1200, 0.62), _curve(2200, 1320, -0.72), _curve(3960, 1500, 0.70), _curve(5800, 760, -0.50)]
		55:
			return [_curve(540, 1240, -0.62), _curve(2300, 1460, 0.78), _curve(4300, 1360, -0.74)]
		56:
			return [_curve(620, 1180, 0.52), _curve(2260, 1300, -0.66), _curve(4020, 1420, 0.72)]
		57:
			return [_curve(420, 1160, -0.70), _curve(2040, 1400, 0.88), _curve(3980, 1380, -0.86), _curve(5840, 820, 0.62)]
		58:
			return [_curve(560, 1280, 0.58), _curve(2440, 1480, -0.76), _curve(4520, 1280, 0.72)]
		59:
			return [_curve(360, 1120, -0.86), _curve(1900, 1240, 0.96), _curve(3600, 1360, -1.02), _curve(5440, 1160, 0.88)]
		60:
			return [_curve(460, 1320, 0.76), _curve(2300, 1440, -0.92), _curve(4320, 1540, 1.02), _curve(6340, 980, -0.78)]
		61:
			return [_curve(440, 1500, -0.58), _curve(2460, 1580, 0.64), _curve(4660, 1420, -0.70), _curve(6220, 860, 0.46)]
		62:
			return [_curve(360, 1320, 0.72), _curve(2060, 1500, -0.76), _curve(3960, 1640, 0.80), _curve(6160, 980, -0.58)]
		63:
			return [_curve(520, 1560, -0.68), _curve(2700, 1280, 0.82), _curve(4380, 1680, -0.88), _curve(6540, 900, 0.62)]
		64:
			return [_curve(430, 1180, 0.84), _curve(1840, 1180, -0.86), _curve(3300, 1420, 0.92), _curve(5240, 1580, -0.78), _curve(7040, 760, 0.52)]
		65:
			return [_curve(580, 1640, -0.74), _curve(2840, 1500, 0.88), _curve(4940, 1560, -0.92), _curve(6920, 920, 0.70)]
		66:
			return [_curve(360, 1320, 0.78), _curve(2160, 1320, -0.92), _curve(3980, 1320, 0.96), _curve(5780, 1320, -0.86)]
		67:
			return [_curve(480, 1480, -0.90), _curve(2460, 1660, 0.98), _curve(4740, 1480, -1.02), _curve(6760, 860, 0.74)]
		68:
			return [_curve(400, 1240, 0.72), _curve(1860, 1280, -0.76), _curve(3520, 1680, 1.04), _curve(5900, 1380, -0.96)]
		69:
			return [_curve(300, 1120, -0.98), _curve(1780, 1240, 1.08), _curve(3420, 1320, -1.12), _curve(5180, 1380, 1.02), _curve(7040, 820, -0.72)]
		70:
			return [_curve(420, 1460, 0.96), _curve(2500, 1580, -1.12), _curve(4740, 1660, 1.18), _curve(7100, 940, -0.92)]
	return []


static func _hills_for_stage(stage: int) -> Array[Dictionary]:
	match stage:
		53:
			return [_hill(850, 1150, 26.0), _hill(2450, 1200, -32.0), _hill(4300, 1100, 24.0)]
		58:
			return [_hill(700, 900, -28.0), _hill(2100, 1100, 32.0), _hill(3900, 1000, -34.0)]
		60:
			return [_hill(1100, 850, 18.0), _hill(3000, 1000, -26.0), _hill(5300, 900, 30.0)]
		61, 62, 63, 64, 65, 66, 67, 68, 69, 70:
			return [_hill(980, 880, -14.0), _hill(2920, 920, 18.0), _hill(5060, 1040, -20.0), _hill(6740, 780, 16.0)]
	return [_hill(1600, 900, 14.0), _hill(3900, 1000, -16.0)]


static func _obstacles_for_stage(stage: int) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	match stage:
		50:
			rows = [_obs(760, "road_block", -1), _obs(1120, "road_block", 1), _obs(1560, "low_barricade", 0), _obs(2050, "pit", 0, 3), _obs(2580, "mine", 2), _obs(3200, "drone", -1), _obs(3780, "road_block", -2), _obs(4300, "low_barricade", 1), _obs(5050, "road_block", 0)]
		51:
			rows = [_obs(640, "edge_wall", -2), _obs(980, "road_block", 2), _obs(1420, "mine", 0), _obs(1900, "pit", -1, 2), _obs(2380, "road_block", 1), _obs(2860, "road_block", -1), _obs(3400, "low_barricade", 0), _obs(3920, "mine", 2), _obs(4580, "road_block", -2), _obs(5200, "pit", 1, 2)]
		52:
			rows = [_obs(720, "pit", 0, 3), _obs(1260, "low_barricade", -1), _obs(1780, "pit", 1, 2), _obs(2300, "road_block", -2), _obs(2820, "drone", 0), _obs(3300, "pit", -1, 3), _obs(3960, "low_barricade", 2), _obs(4480, "road_block", 1), _obs(5120, "pit", 0, 4)]
		53:
			rows = [_obs(680, "road_block", -1), _obs(1040, "mine", 1), _obs(1560, "low_barricade", 0), _obs(2140, "pit", 1, 2), _obs(2700, "road_block", -2), _obs(3260, "drone", 2), _obs(3860, "pit", 0, 3), _obs(4520, "mine", -1), _obs(5140, "road_block", 1)]
		54:
			rows = [_obs(820, "laser_gate", 0, 5), _obs(1360, "road_block", -1), _obs(1880, "laser_gate", 1, 2), _obs(2440, "moving_gate", 0, 2), _obs(3060, "low_barricade", -1), _obs(3640, "laser_gate", -2, 2), _obs(4200, "mine", 0), _obs(4860, "pit", 1, 2), _obs(5480, "laser_gate", 0, 3)]
		55:
			rows = [_obs(700, "road_block", 2), _obs(1140, "low_barricade", -1), _obs(1660, "mine", 0), _obs(2180, "pit", 1, 2), _obs(2760, "road_block", -2), _obs(3380, "dropper_drone", 0), _obs(3920, "low_barricade", 2), _obs(4520, "mine", -1), _obs(5120, "pit", 0, 3)]
		56:
			rows = [_obs(620, "mine", -2), _obs(900, "mine", 0), _obs(1180, "mine", 2), _obs(1640, "powerup_carrier", -1), _obs(2100, "mine", 1), _obs(2620, "road_block", 0), _obs(3180, "mine", -1), _obs(3720, "low_barricade", 2), _obs(4280, "mine", 0), _obs(5000, "drone", 1)]
		57:
			rows = [_obs(720, "dropper_drone", -1), _obs(1240, "road_block", 1), _obs(1760, "dropper_drone", 2), _obs(2320, "pit", 0, 2), _obs(2860, "dropper_drone", 0), _obs(3440, "mine", -2), _obs(3980, "low_barricade", 1), _obs(4540, "dropper_drone", -1), _obs(5200, "pit", 1, 3)]
		58:
			rows = [_obs(780, "gravity_field", 0, 5), _obs(1360, "road_block", -1), _obs(1880, "low_barricade", 1), _obs(2440, "pit", 0, 3), _obs(3120, "gravity_field", 0, 5), _obs(3700, "mine", 2), _obs(4240, "road_block", -2), _obs(4820, "pit", 1, 2), _obs(5460, "laser_gate", 0, 3)]
		59:
			rows = [_obs(520, "road_block", -2), _obs(860, "pit", 0, 2), _obs(1240, "road_block", 2), _obs(1660, "low_barricade", -1), _obs(2100, "laser_gate", 0, 3), _obs(2600, "mine", 1), _obs(3180, "pit", -1, 2), _obs(3720, "moving_gate", 1, 2), _obs(4320, "road_block", 0), _obs(4900, "laser_gate", -1, 3), _obs(5520, "pit", 0, 4), _obs(6100, "road_block", 2)]
		60:
			rows = [_obs(700, "drone", 0), _obs(1160, "laser_gate", -1, 3), _obs(1680, "dropper_drone", 2), _obs(2260, "mine", -2), _obs(2820, "pit", 0, 3), _obs(3440, "moving_gate", 1, 2), _obs(4060, "dropper_drone", -1), _obs(4680, "laser_gate", 0, 5), _obs(5320, "mine", 2), _obs(5900, "road_block", -2), _obs(6480, "pit", 0, 4)]
		61:
			rows = [_obs(700, "road_block", -1), _obs(1120, "low_barricade", 1), _obs(1640, "laser_gate", 0, 3), _obs(2240, "mine", -2), _obs(2820, "pit", 0, 2), _obs(3440, "drone", 1), _obs(4100, "moving_gate", -1, 2), _obs(4800, "road_block", 2), _obs(5520, "laser_gate", 0, 5), _obs(6260, "powerup_carrier", 0)]
		62:
			rows = [_obs(620, "laser_gate", -1, 2), _obs(1040, "road_block", 2), _obs(1540, "mine", 0), _obs(2080, "low_barricade", -2), _obs(2660, "pit", 1, 2), _obs(3300, "dropper_drone", 0), _obs(3960, "laser_gate", 1, 3), _obs(4680, "moving_gate", -1, 2), _obs(5400, "mine", 2), _obs(6200, "road_block", 0)]
		63:
			rows = [_obs(760, "road_block", 0), _obs(1260, "laser_gate", -2, 2), _obs(1840, "pit", -1, 3), _obs(2460, "mine", 1), _obs(3040, "drone", -1), _obs(3680, "moving_gate", 0, 3), _obs(4420, "low_barricade", 2), _obs(5100, "laser_gate", 0, 5), _obs(5860, "dropper_drone", -2), _obs(6620, "pit", 0, 3)]
		64:
			rows = [_obs(540, "low_barricade", 0), _obs(940, "mine", -1), _obs(1380, "road_block", 1), _obs(1880, "laser_gate", 0, 3), _obs(2420, "pit", 0, 2), _obs(3020, "dropper_drone", 2), _obs(3660, "moving_gate", -2, 2), _obs(4380, "laser_gate", 1, 2), _obs(5160, "mine", 0), _obs(6040, "road_block", -1), _obs(6900, "powerup_carrier", 1)]
		65:
			rows = [_obs(680, "mine", -2), _obs(1040, "mine", 0), _obs(1420, "mine", 2), _obs(1960, "laser_gate", 0, 5), _obs(2560, "pit", -1, 2), _obs(3160, "road_block", 1), _obs(3820, "drone", 0), _obs(4480, "low_barricade", -2), _obs(5200, "moving_gate", 1, 2), _obs(6020, "laser_gate", -1, 3), _obs(6840, "pit", 0, 4)]
		66:
			rows = [_obs(580, "laser_gate", 0, 2), _obs(980, "road_block", -2), _obs(1420, "road_block", 2), _obs(1940, "low_barricade", 0), _obs(2480, "dropper_drone", -1), _obs(3120, "mine", 1), _obs(3780, "laser_gate", 0, 3), _obs(4540, "moving_gate", -1, 2), _obs(5280, "pit", 1, 2), _obs(6160, "drone", 2), _obs(7000, "laser_gate", -1, 3)]
		67:
			rows = [_obs(640, "road_block", 1), _obs(1100, "laser_gate", -1, 3), _obs(1660, "mine", -2), _obs(2260, "pit", 0, 3), _obs(2920, "dropper_drone", 1), _obs(3600, "moving_gate", 0, 2), _obs(4320, "low_barricade", -1), _obs(5080, "laser_gate", 1, 3), _obs(5860, "road_block", -2), _obs(6700, "pit", 0, 4)]
		68:
			rows = [_obs(700, "laser_gate", 0, 5), _obs(1260, "moving_gate", -1, 2), _obs(1840, "laser_gate", 2, 2), _obs(2440, "mine", 0), _obs(3040, "road_block", -2), _obs(3700, "pit", 1, 2), _obs(4400, "dropper_drone", 0), _obs(5160, "laser_gate", -1, 3), _obs(5960, "low_barricade", 2), _obs(6820, "powerup_carrier", -1)]
		69:
			rows = [_obs(520, "road_block", -2), _obs(860, "laser_gate", 0, 3), _obs(1280, "pit", 1, 2), _obs(1740, "mine", -1), _obs(2260, "moving_gate", 1, 2), _obs(2860, "dropper_drone", -2), _obs(3540, "laser_gate", 0, 5), _obs(4300, "road_block", 2), _obs(5060, "pit", 0, 3), _obs(5860, "drone", 1), _obs(6660, "laser_gate", -1, 3), _obs(7460, "mine", 2)]
		70:
			rows = [_obs(680, "dropper_drone", 0), _obs(1160, "laser_gate", -2, 2), _obs(1660, "road_block", 2), _obs(2200, "mine", -1), _obs(2820, "pit", 0, 3), _obs(3500, "moving_gate", 1, 3), _obs(4260, "laser_gate", 0, 5), _obs(5040, "drone", -2), _obs(5820, "low_barricade", 1), _obs(6600, "laser_gate", -1, 3), _obs(7360, "pit", 0, 4), _obs(7840, "powerup_carrier", 0)]
	rows.append_array(_arcade_flyers_for_stage(stage))
	return rows


static func _curve(z: float, length: float, amount: float) -> Dictionary:
	return {"z": z, "length": length, "curve": amount}


static func _hill(z: float, length: float, amount: float) -> Dictionary:
	return {"z": z, "length": length, "hill": amount}


static func _obs(z: float, kind: String, lane: int, width_lanes := 1) -> Dictionary:
	var row := {"z": z, "type": kind, "lane": lane, "width_lanes": width_lanes}
	if kind in ["low_barricade", "pit"]:
		row["requires_jump"] = true
		row["required_jump_height"] = 38.0 if kind == "low_barricade" else 52.0
	if kind in ["drone", "dropper_drone", "powerup_carrier", "mine"]:
		row["shootable"] = true
		row["hp"] = 2 if kind == "mine" else 4
	if kind == "road_block":
		row["hp"] = 0
	if kind == "laser_gate":
		row["pulse"] = 1.45
	return row


static func _air_obs(z: float, kind: String, lane: int, flight_y: float, pattern := "straight", fires := true) -> Dictionary:
	var row := _obs(z, kind, lane)
	row["flight_y"] = flight_y
	row["attack_pattern"] = pattern
	row["fires"] = fires
	return row


static func _arcade_flyers_for_stage(stage: int) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var offset := float(stage - FIRST_STAGE) * 34.0
	rows.append(_air_obs(1780.0 + offset, "drone", -1, -118.0, "straight", stage >= 52))
	rows.append(_air_obs(3960.0 + offset, "powerup_carrier", 1, -166.0, "straight", false))
	if stage >= 54:
		rows.append(_air_obs(5600.0 + offset, "dropper_drone", 0, -82.0, "sweep", true))
	if stage >= 58:
		rows.append(_air_obs(6460.0 + offset, "drone", 1, -198.0, "straight", true))
	return rows


static func _repeat_world_rows(rows: Array[Dictionary], section_length: float, section_count: int, vary_lanes: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for section in range(section_count):
		var offset := section_length * float(section)
		for row_index in range(rows.size()):
			var row := rows[row_index]
			var is_air := row.has("flight_y")
			if vary_lanes and section > 0 and is_air:
				continue
			if vary_lanes and section > 0 and not is_air and row_index % 2 == 1:
				continue
			var next := row.duplicate(true)
			next["z"] = float(next.get("z", 0.0)) + offset
			if vary_lanes and section > 0 and next.has("lane"):
				var lane_shift := (section % 3) - 1
				next["lane"] = clampi(int(next.get("lane", 0)) + lane_shift, -2, 2)
			if vary_lanes and section > 0 and next.has("flight_y"):
				var height_shift := float((section % 3) - 1) * 34.0
				next["flight_y"] = clampf(float(next.get("flight_y", 0.0)) + height_shift, -230.0, 54.0)
			result.append(next)
	return result


static func _repeat_checkpoints(points: Array[float], section_length: float, section_count: int) -> Array[float]:
	var result: Array[float] = []
	for section in range(section_count):
		var offset := section_length * float(section)
		for point in points:
			result.append(float(point) + offset)
	return result
