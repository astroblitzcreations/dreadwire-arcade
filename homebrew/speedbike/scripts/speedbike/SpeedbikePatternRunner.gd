extends Node
class_name SpeedbikePatternRunner

var mode: Node
var spawner
var stage_data: Dictionary = {}
var events: Array[Dictionary] = []
var next_index := 0
var elapsed := 0.0
var stage_duration := 0.0
var base_spawn_lead := 220.0


func configure(mode_ref: Node, spawner_ref, data: Dictionary) -> void:
	mode = mode_ref
	spawner = spawner_ref
	stage_data = data.duplicate(true)
	events.clear()
	var source_events: Variant = data.get("patterns", [])
	if source_events is Array:
		for row in source_events:
			if row is Dictionary:
				events.append((row as Dictionary).duplicate(true))
	stage_duration = float(data.get("duration", 0.0))
	if bool(stage_data.get("replace_with_fill_style", false)):
		_keep_only_stage_flow_events()
	_append_pressure_fillers()
	events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("t", 0.0)) < float(b.get("t", 0.0))
	)
	next_index = 0
	elapsed = 0.0
	base_spawn_lead = clampf(float(data.get("base_speed", 420.0)) * 0.52, 220.0, 420.0)


func reset_to_state(saved_elapsed: float, saved_next_index: int) -> void:
	elapsed = maxf(saved_elapsed, 0.0)
	next_index = clampi(saved_next_index, 0, events.size())


func snapshot() -> Dictionary:
	return {
		"elapsed": elapsed,
		"next_index": next_index
	}


func tick(delta: float) -> void:
	if mode == null or spawner == null:
		return
	elapsed += delta
	while next_index < events.size():
		var row := events[next_index]
		if float(row.get("t", 0.0)) > elapsed:
			break
		var spawn_row := row.duplicate(true)
		var kind := str(spawn_row.get("kind", ""))
		if _is_spawn_kind(kind):
			spawn_row["spawn_x"] = mode.speedbike_spawn_x(float(spawn_row.get("lead", _default_spawn_lead_for_kind(kind))))
		spawner.spawn_event(spawn_row)
		next_index += 1


func remaining_events() -> int:
	return maxi(events.size() - next_index, 0)


func is_stage_finished() -> bool:
	return next_index >= events.size() and elapsed >= maxf(stage_duration, 0.0)


func total_duration() -> float:
	return maxf(stage_duration, 1.0)


func _is_spawn_kind(kind: String) -> bool:
	return kind in [
		"block",
		"low_barricade",
		"pit",
		"laser_gate",
		"moving_gate",
		"mine",
		"oil_spill",
		"drone",
		"dropper_drone",
		"powerup_carrier"
	]


func _default_spawn_lead_for_kind(kind: String) -> float:
	var lead := base_spawn_lead
	match kind:
		"pit", "laser_gate", "moving_gate":
			lead += 54.0
		"block":
			lead += 40.0
		"low_barricade", "mine":
			lead += 28.0
		"oil_spill":
			lead += 34.0
		"drone", "dropper_drone", "powerup_carrier":
			lead += 78.0
	return clampf(lead, 220.0, 520.0)


func _append_pressure_fillers() -> void:
	if not bool(stage_data.get("auto_pressure", true)):
		return
	var end_time := maxf(stage_duration - 1.6, 2.0)
	for row in events:
		if str(row.get("kind", "")) == "boss_intro":
			end_time = minf(end_time, float(row.get("t", end_time)) - 1.1)
	if end_time <= 2.0:
		return
	var style := str(stage_data.get("fill_style", _signature_fill_style()))
	var interval := 1.34
	match style:
		"moving_gates":
			interval = 1.02
		"slit_wall":
			interval = 0.96
		"moving_slit":
			interval = 1.12
		"heavy":
			interval = 1.10
		_:
			interval = 1.34
	var stage_num := _event_stage_number()
	if stage_num >= 21:
		interval = maxf(interval - 0.12, 0.82)
	if stage_num >= 31:
		interval = maxf(interval - 0.08, 0.74)
	var t := 2.0
	var filler_index := 0
	while t < end_time:
		if not _has_spawn_near(t, interval * 0.66):
			events.append(_pressure_event_for(style, t, filler_index))
		t += interval
		filler_index += 1


func _signature_fill_style() -> String:
	var stage_num := _event_stage_number()
	var display_name := str(stage_data.get("display_name", "")).to_lower()
	if stage_num == 12 or display_name.contains("switch"):
		return "moving_gates"
	if stage_num == 25 or display_name.contains("needle"):
		return "slit_wall"
	if stage_num == 28 or stage_num == 37 or display_name.contains("lens"):
		return "moving_slit"
	if stage_num >= 31:
		return "heavy"
	return "mixed"


func _event_stage_number() -> int:
	var parts := str(stage_data.get("stage_id", "")).split("_")
	for part in parts:
		var piece := str(part)
		if piece.is_valid_int():
			return int(piece)
	return 0


func _has_spawn_near(time: float, radius: float) -> bool:
	for row in events:
		var kind := str(row.get("kind", ""))
		if not _is_spawn_kind(kind):
			continue
		if absf(float(row.get("t", 0.0)) - time) <= radius:
			return true
	return false


func _pressure_event_for(style: String, time: float, index: int) -> Dictionary:
	var lanes := [0, 1, 2, 3, 4]
	match style:
		"moving_gates":
			var lane := int(lanes[index % lanes.size()])
			return {
				"t": time,
				"kind": "moving_gate",
				"lane": lane,
				"width": 108 + (index % 2) * 10,
				"move_range": 104 + (index % 3) * 16,
				"move_speed": 2.7 + float(index % 4) * 0.18
			}
		"slit_wall":
			var gap_lanes := [1, 2, 3, 2]
			return {
				"t": time,
				"kind": "block",
				"shape": "center_gap",
				"gap_lane": int(gap_lanes[index % gap_lanes.size()]),
				"width": 138 + (index % 2) * 10
			}
		"moving_slit":
			var gap_lanes := [1, 2, 3, 2]
			return {
				"t": time,
				"kind": "moving_gate",
				"shape": "moving_gap",
				"gap_lane": int(gap_lanes[index % gap_lanes.size()]),
				"width": 146,
				"move_range": 86 + (index % 3) * 16,
				"move_speed": 2.4 + float(index % 3) * 0.22
			}
		"heavy":
			var heavy_cycle := index % 6
			if heavy_cycle == 0:
				return {"t": time, "kind": "block", "shape": "center_gap", "gap_lane": 1 + (index % 3), "width": 136}
			if heavy_cycle == 1:
				return {"t": time, "kind": "moving_gate", "lane": int(lanes[(index + 2) % lanes.size()]), "width": 112, "move_range": 118, "move_speed": 3.1}
			if heavy_cycle == 2:
				return {"t": time, "kind": "mine", "lane": int(lanes[(index + 1) % lanes.size()])}
			if heavy_cycle == 3:
				return {"t": time, "kind": "drone", "lane": int(lanes[(index + 3) % lanes.size()]), "enemy_type": "rifle_flyer", "shoot_interval": 0.8}
			if heavy_cycle == 4:
				return {"t": time, "kind": "low_barricade", "lane": 2, "width": 132}
			return {"t": time, "kind": "block", "shape": "top_bottom_gap", "width": 140}
		_:
			var cycle := index % 7
			if cycle == 0:
				return {"t": time, "kind": "block", "shape": "top", "width": 126}
			if cycle == 1:
				return {"t": time, "kind": "block", "shape": "bottom", "width": 126}
			if cycle == 2:
				return {"t": time, "kind": "block", "shape": "center_gap", "gap_lane": 1 + (index % 3), "width": 132}
			if cycle == 3:
				return {"t": time, "kind": "moving_gate", "lane": int(lanes[(index + 1) % lanes.size()]), "width": 102, "move_range": 88, "move_speed": 2.4}
			if cycle == 4:
				return {"t": time, "kind": "mine", "lane": int(lanes[(index + 2) % lanes.size()])}
			if cycle == 5:
				return {"t": time, "kind": "drone", "lane": int(lanes[(index + 3) % lanes.size()]), "enemy_type": "interceptor", "shoot_interval": 1.05}
			return {"t": time, "kind": "low_barricade", "lane": 2, "width": 124}


func _keep_only_stage_flow_events() -> void:
	var kept_events: Array[Dictionary] = []
	for row in events:
		var kind := str(row.get("kind", ""))
		if kind in ["warning", "tutorial_text", "checkpoint", "speed_boost", "speed_reset", "tip", "blackout_on", "blackout_off", "boss_intro"]:
			kept_events.append(row)
	events = kept_events
