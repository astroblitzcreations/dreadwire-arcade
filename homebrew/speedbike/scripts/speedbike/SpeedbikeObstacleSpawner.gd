extends Node
class_name SpeedbikeObstacleSpawner

const SPEEDBIKE_OBSTACLE_SCRIPT := preload("res://scripts/speedbike/SpeedbikeObstacle.gd")
const SPEEDBIKE_DRONE_SCRIPT := preload("res://scripts/speedbike/SpeedbikeDrone.gd")
const SPEEDBIKE_CARRIER_SCRIPT := preload("res://scripts/speedbike/SpeedbikePowerupCarrier.gd")

var mode: Node


func configure(mode_ref: Node) -> void:
	mode = mode_ref


func spawn_event(event: Dictionary) -> void:
	if mode == null:
		return
	var kind := str(event.get("kind", ""))
	match kind:
		"block":
			_spawn_block(event)
		"ramp":
			_spawn_ramp(event)
		"low_barricade":
			_spawn_low_barricade(event)
		"pit":
			_spawn_pit(event)
		"laser_gate":
			_spawn_laser_gate(event)
		"moving_gate":
			_spawn_moving_gate(event)
		"mine":
			_spawn_mine(event)
		"oil_spill":
			_spawn_oil_spill(event)
		"drone":
			_spawn_drone(event)
		"dropper_drone":
			_spawn_dropper(event)
		"powerup_carrier":
			_spawn_powerup_carrier(event)
		_:
			if mode.has_method("handle_non_spawn_event"):
				mode.handle_non_spawn_event(event)


func _spawn_block(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var width := float(event.get("width", 112.0))
	var shape := str(event.get("shape", "center"))
	var rects: Array[Dictionary] = []
	match shape:
		"full":
			rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 18.0, width, mode.speedbike_bottom_bound() - mode.speedbike_top_bound() + 36.0))
		"top":
			rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 18.0, width, mode.speedbike_lane_bottom(1) - mode.speedbike_top_bound() + 28.0))
		"bottom":
			rects.append(_rect_dict(spawn_x, mode.speedbike_lane_top(3), width, mode.speedbike_bottom_bound() - mode.speedbike_lane_top(3) + 20.0))
		"center":
			rects.append(_rect_dict(spawn_x, mode.speedbike_lane_top(2) - 12.0, width, mode.speedbike_lane_span() + 24.0))
		"top_bottom_gap":
			var gap_pad := 22.0
			var top_h = mode.speedbike_lane_top(2) - mode.speedbike_top_bound() - gap_pad
			var bottom_y = mode.speedbike_lane_bottom(2) + gap_pad
			if top_h > 8.0:
				rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 16.0, width, top_h))
			rects.append(_rect_dict(spawn_x, bottom_y, width, mode.speedbike_bottom_bound() - bottom_y + 18.0))
		"center_gap":
			var gap_lane := clampi(int(event.get("gap_lane", 2)), 1, 3)
			var gap_pad := 22.0
			var top_h = mode.speedbike_lane_top(gap_lane) - mode.speedbike_top_bound() - gap_pad
			var bottom_y = mode.speedbike_lane_bottom(gap_lane) + gap_pad
			if top_h > 8.0:
				rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 16.0, width, top_h))
			rects.append(_rect_dict(spawn_x, bottom_y, width, mode.speedbike_bottom_bound() - bottom_y + 18.0))
		"vertical_slice":
			rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() + 24.0, width * 0.7, mode.speedbike_bottom_bound() - mode.speedbike_top_bound() - 48.0))
		_:
			rects.append(_rect_dict(spawn_x, mode.speedbike_lane_top(2) - 12.0, width, mode.speedbike_lane_span() + 24.0))
	_spawn_obstacle({
		"kind": "block",
		"shape": shape,
		"x": spawn_x,
		"destructible": bool(event.get("destructible", false)),
		"score_value": int(event.get("score_value", 100)),
		"rects": rects
	})


func _spawn_low_barricade(event: Dictionary) -> void:
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	var spawn_x := float(event.get("spawn_x", 0.0))
	var y: float = mode.speedbike_lane_y(lane) + 16.0
	_spawn_obstacle({
		"kind": "low_barricade",
		"x": spawn_x,
		"required_jump_height": float(event.get("required_jump_height", 26.0)),
		"destructible": bool(event.get("destructible", false)),
		"score_value": int(event.get("score_value", 100)),
		"rects": [_rect_dict(spawn_x, y, float(event.get("width", 124.0)), 34.0)]
	})


func _spawn_pit(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var pit_width := float(event.get("width", 148.0))
	var big_jump := bool(event.get("big_jump", pit_width >= 280.0))
	var use_ramp := bool(event.get("use_ramp", pit_width >= 150.0))
	var ramp_width := float(event.get("ramp_width", 140.0))
	var ramp_gap := float(event.get("ramp_gap", 10.0))
	if use_ramp:
		pit_width = maxf(pit_width, float(event.get("ramp_required_width", 360.0 if big_jump else 232.0)))
		ramp_width = maxf(ramp_width, 276.0 if big_jump else 176.0)
		ramp_gap = maxf(ramp_gap, 18.0)
		var ramp_lanes := [0, 2, 4]
		var ramp_lane := int(event.get("ramp_lane", -1))
		if ramp_lane < 0:
			ramp_lane = 2 if big_jump else int(ramp_lanes[randi() % ramp_lanes.size()])
		var ramp_count := int(event.get("ramp_count", 3 if big_jump else 1))
		if big_jump and ramp_count > 1:
			_spawn_big_jump_ramp_cluster(event, spawn_x, ramp_width, ramp_gap, ramp_lane, ramp_count)
		else:
			_spawn_ramp({
				"spawn_x": spawn_x - ramp_width - ramp_gap,
				"width": ramp_width,
				"height": clampf(float(event.get("ramp_height", 112.0 if big_jump else 84.0)), 74.0, 136.0),
				"lane": ramp_lane,
				"big_jump": big_jump,
				"ramp_count": ramp_count,
				"score_value": 0
			})
	var required_height_default := 56.0
	if big_jump:
		required_height_default = 190.0
	elif use_ramp:
		required_height_default = 190.0
	elif pit_width >= 170.0:
		required_height_default = 84.0
	elif pit_width >= 150.0:
		required_height_default = 72.0
	elif pit_width >= 138.0:
		required_height_default = 60.0
	_spawn_obstacle({
		"kind": "pit",
		"x": spawn_x,
		"ramp_assist": use_ramp,
		"big_jump": big_jump,
		"required_jump_height": float(event.get("required_jump_height", required_height_default)),
		"rects": [_rect_dict(spawn_x, mode.speedbike_top_bound() - 12.0, pit_width, mode.speedbike_bottom_bound() - mode.speedbike_top_bound() + 24.0)]
	})


func _spawn_big_jump_ramp_cluster(event: Dictionary, pit_x: float, ramp_width: float, ramp_gap: float, base_lane: int, ramp_count: int) -> void:
	var count := clampi(ramp_count, 2, 4)
	var segment_width := maxf(float(event.get("ramp_segment_width", ramp_width * 0.58)), 178.0)
	var ramp_height := clampf(float(event.get("ramp_height", 114.0)), 86.0, 138.0)
	var spacing := maxf(float(event.get("ramp_spacing", segment_width * 0.82)), 120.0)
	var first_x := pit_x - ramp_gap - segment_width - spacing * float(count - 1)
	for index in range(count):
		var lane := clampi(base_lane - index, 0, 4)
		_spawn_ramp({
			"spawn_x": first_x + spacing * float(index),
			"width": segment_width,
			"height": ramp_height + float(index) * 5.0,
			"lane": lane,
			"big_jump": true,
			"ramp_count": 1,
			"score_value": 0
		})


func _spawn_ramp(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var ramp_height := float(event.get("height", 72.0))
	var lane := clampi(int(event.get("lane", 4)), 0, 4)
	var lane_y: float = mode.speedbike_lane_y(lane)
	var ramp_y := lane_y - ramp_height * 0.46
	ramp_y = clampf(ramp_y, mode.speedbike_top_bound() - 4.0, mode.speedbike_bottom_bound() - ramp_height + 6.0)
	_spawn_obstacle({
		"kind": "ramp",
		"x": spawn_x,
		"big_jump": bool(event.get("big_jump", false)),
		"ramp_count": int(event.get("ramp_count", 1)),
		"score_value": int(event.get("score_value", 0)),
		"rects": [_rect_dict(spawn_x, ramp_y, maxf(float(event.get("width", 164.0)), 164.0), ramp_height)]
	})


func _spawn_laser_gate(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var shape := str(event.get("shape", "laser_single"))
	var rects: Array[Dictionary] = []
	if shape == "laser_double":
		rects.append(_rect_dict(spawn_x, mode.speedbike_lane_top(1), float(event.get("width", 108.0)), 12.0))
		rects.append(_rect_dict(spawn_x, mode.speedbike_lane_bottom(3), float(event.get("width", 108.0)), 12.0))
	else:
		rects.append(_rect_dict(spawn_x, mode.speedbike_lane_y(int(event.get("lane", 2))) - 6.0, float(event.get("width", 108.0)), 12.0))
	_spawn_obstacle({
		"kind": "laser_gate",
		"shape": shape,
		"x": spawn_x,
		"warning_time": float(event.get("warning_time", 0.44)),
		"active_time": float(event.get("active_time", 0.72)),
		"cooldown_time": float(event.get("cooldown_time", 0.38)),
		"rects": rects
	})


func _spawn_moving_gate(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	var width := float(event.get("width", 98.0))
	var shape := str(event.get("shape", "moving_gate"))
	var rects: Array[Dictionary] = []
	if shape in ["moving_gap", "moving_slit", "center_gap"]:
		var gap_lane := clampi(int(event.get("gap_lane", 2)), 1, 3)
		var gap_pad := float(event.get("gap_pad", 26.0))
		var top_h = mode.speedbike_lane_top(gap_lane) - mode.speedbike_top_bound() - gap_pad
		var bottom_y = mode.speedbike_lane_bottom(gap_lane) + gap_pad
		if top_h > 8.0:
			rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 16.0, width, top_h))
		rects.append(_rect_dict(spawn_x, bottom_y, width, mode.speedbike_bottom_bound() - bottom_y + 18.0))
	elif shape == "top_bottom_gap":
		var gap_pad := float(event.get("gap_pad", 26.0))
		var top_h = mode.speedbike_lane_top(2) - mode.speedbike_top_bound() - gap_pad
		var bottom_y = mode.speedbike_lane_bottom(2) + gap_pad
		if top_h > 8.0:
			rects.append(_rect_dict(spawn_x, mode.speedbike_top_bound() - 16.0, width, top_h))
		rects.append(_rect_dict(spawn_x, bottom_y, width, mode.speedbike_bottom_bound() - bottom_y + 18.0))
	else:
		rects.append(_rect_dict(spawn_x, mode.speedbike_lane_top(lane), width, mode.speedbike_lane_span() + 18.0))
	_spawn_obstacle({
		"kind": "moving_gate",
		"shape": shape,
		"x": spawn_x,
		"move_axis": str(event.get("move_axis", "vertical")),
		"move_range": float(event.get("move_range", 82.0)),
		"move_speed": float(event.get("move_speed", 2.2)),
		"rects": rects
	})


func _spawn_mine(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	_spawn_obstacle({
		"kind": "mine",
		"x": spawn_x,
		"destructible": true,
		"score_value": int(event.get("score_value", 150)),
		"rects": [_rect_dict(spawn_x, mode.speedbike_lane_y(lane) - 18.0, 40.0, 40.0)]
	})


func _spawn_oil_spill(event: Dictionary) -> void:
	var spawn_x := float(event.get("spawn_x", 0.0))
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	var y := float(event.get("y", mode.speedbike_lane_y(lane) + 18.0))
	_spawn_obstacle({
		"kind": "oil_spill",
		"x": spawn_x,
		"kill_on_touch": false,
		"score_value": 0,
		"rects": [_rect_dict(spawn_x, y - 15.0, float(event.get("width", 118.0)), 34.0)]
	})


func _spawn_drone(event: Dictionary) -> void:
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	var drone = SPEEDBIKE_DRONE_SCRIPT.new()
	drone.setup({
		"x": float(event.get("spawn_x", 0.0)),
		"y": mode.speedbike_lane_y(lane) - 20.0,
		"lane": lane,
		"enemy_type": str(event.get("enemy_type", "interceptor")),
		"health": int(event.get("health", 1)),
		"shoot_interval": float(event.get("shoot_interval", 1.65)),
		"score_value": int(event.get("score_value", 250)),
		"screen_hold_time": float(event.get("screen_hold_time", 5.0)),
		"drop_delay": float(event.get("drop_delay", 2.0))
	}, mode)
	mode.register_speedbike_drone(drone)


func _spawn_dropper(event: Dictionary) -> void:
	var dropper_event := event.duplicate(true)
	dropper_event["enemy_type"] = str(event.get("enemy_type", "dropper"))
	dropper_event["shoot_interval"] = 999.0
	_spawn_drone(dropper_event)


func _spawn_powerup_carrier(event: Dictionary) -> void:
	var lane := clampi(int(event.get("lane", 2)), 0, 4)
	var carrier = SPEEDBIKE_CARRIER_SCRIPT.new()
	carrier.setup({
		"x": float(event.get("spawn_x", 0.0)),
		"y": mode.speedbike_lane_y(lane) - 28.0,
		"lane": lane,
		"reward_kind": str(event.get("reward_kind", "")),
		"score_value": int(event.get("score_value", 300))
	}, mode)
	mode.register_speedbike_drone(carrier)


func _spawn_obstacle(row: Dictionary) -> void:
	var obstacle = SPEEDBIKE_OBSTACLE_SCRIPT.new()
	obstacle.setup(row, mode)
	mode.register_speedbike_obstacle(obstacle)


func _rect_dict(x: float, y: float, width: float, height: float) -> Dictionary:
	return {"x": x, "y": y, "w": width, "h": height}
