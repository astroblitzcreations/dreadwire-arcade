extends Node2D
class_name WindingObstacle

const TEXTURES := {
	"road_block": preload("res://assets/sprites/speedbike/obstacles/full_wall_block.png"),
	"low_barricade": preload("res://assets/sprites/speedbike/obstacles/low_barricade.png"),
	"pit": preload("res://assets/sprites/speedbike/obstacles/pit_large.png"),
	"mine": preload("res://assets/sprites/speedbike/obstacles/mine.png"),
	"laser_gate": preload("res://assets/sprites/speedbike/obstacles/laser_gate_active.png"),
	"moving_gate": preload("res://assets/sprites/speedbike/obstacles/moving_gate.png"),
	"drone": preload("res://assets/sprites/speedbike/enemies/speedbike_interceptor_drone.png"),
	"dropper_drone": preload("res://assets/sprites/speedbike/enemies/speedbike_dropper_drone.png"),
	"powerup_carrier": preload("res://assets/sprites/speedbike/enemies/speedbike_powerup_carrier.png")
}

var data: Dictionary = {}
var world_z := 0.0
var obstacle_type := "road_block"
var lane := 0
var width_lanes := 1
var required_jump_height := 0.0
var requires_jump := false
var shootable := false
var hp := 0
var passed := false
var destroyed := false
var active := true
var flight_y := 0.0
var fires := true
var attack_pattern := "straight"
var current_lane_value := 0.0
var hit_flash_timer := 0.0

var _sprite: Sprite2D
var _shadow: Node2D
var _health_back: ColorRect
var _health_fill: ColorRect
var _max_hp := 0


func setup(row: Dictionary) -> void:
	data = row.duplicate(true)
	world_z = float(data.get("z", 0.0))
	obstacle_type = str(data.get("type", "road_block"))
	lane = int(data.get("lane", 0))
	width_lanes = maxi(int(data.get("width_lanes", 1)), 1)
	requires_jump = bool(data.get("requires_jump", false))
	required_jump_height = float(data.get("required_jump_height", 0.0))
	shootable = bool(data.get("shootable", false))
	hp = int(data.get("hp", 0))
	_max_hp = hp
	flight_y = float(data.get("flight_y", 0.0))
	fires = bool(data.get("fires", true))
	attack_pattern = str(data.get("attack_pattern", "straight"))
	current_lane_value = float(lane)
	_ensure_nodes()
	_sprite.texture = TEXTURES.get(obstacle_type, TEXTURES["road_block"])
	_sprite.centered = true
	_sprite.flip_h = obstacle_type == "edge_wall"
	_refresh_health_bar()


func tick(renderer: Pseudo3DRoadRenderer, camera_z: float) -> void:
	if destroyed:
		visible = false
		return
	var lane_value := float(lane)
	var rel_z := world_z - camera_z
	if obstacle_type in ["drone", "dropper_drone", "powerup_carrier"]:
		lane_value = _flyer_lane(camera_z, rel_z)
	current_lane_value = lane_value
	var projected := renderer.project(world_z, lane_value)
	visible = bool(projected.get("visible", false))
	if not visible:
		return
	hit_flash_timer = maxf(hit_flash_timer - get_process_delta_time(), 0.0)
	modulate = Color(1.0, 0.92, 0.55, 1.0) if hit_flash_timer > 0.0 else Color.WHITE
	position = Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)))
	var scale_value := float(projected.get("scale", 1.0))
	match obstacle_type:
		"pit":
			scale = Vector2(scale_value * maxf(float(width_lanes) * 0.20, 0.34), scale_value * 0.24)
		"laser_gate":
			scale = Vector2(scale_value * maxf(float(width_lanes) * 0.28, 0.36), scale_value * 0.28)
			active = false
			modulate = Color(0.35, 0.75, 1.0, 0.24)
		"drone", "dropper_drone", "powerup_carrier":
			scale = Vector2(scale_value * 0.24, scale_value * 0.24)
			position.y += flight_y + _flyer_bob(camera_z, rel_z, scale_value)
			_update_air_shadow(scale_value)
		"mine":
			scale = Vector2(scale_value * 0.20, scale_value * 0.20)
			position.y += flight_y * 0.55 - 24.0 * scale_value
			_update_air_shadow(scale_value)
		"gravity_field":
			scale = Vector2(scale_value * maxf(float(width_lanes) * 0.32, 0.42), scale_value * 0.14)
			modulate = Color(0.42, 0.92, 1.0, 0.42)
			if _shadow != null:
				_shadow.visible = false
		_:
			scale = Vector2(scale_value * maxf(float(width_lanes) * 0.22, 0.24), scale_value * 0.24)
			if _shadow != null:
				_shadow.visible = false
	_refresh_health_bar()


func _flyer_lane(camera_z: float, rel_z: float) -> float:
	var phase := (camera_z + world_z) * 0.004
	match attack_pattern:
		"sweep":
			return clampf(float(lane) + sin(phase) * 0.22, -2.0, 2.0)
		"formation":
			return clampf(float(lane) + sin(phase * 0.65) * 0.12, -2.0, 2.0)
		_:
			return float(lane)


func _flyer_bob(camera_z: float, rel_z: float, scale_value: float) -> float:
	return 0.0


func collides_with(player_lane: float, jump_z: float, camera_z: float, window: float, player_flight_y := 0.0) -> bool:
	if destroyed or passed or not active or obstacle_type in ["powerup_carrier", "gravity_field", "laser_gate"]:
		return false
	if absf(world_z - camera_z) > window:
		return false
	if not lane_overlaps(player_lane):
		return false
	if obstacle_type in ["drone", "dropper_drone"]:
		return false
	if obstacle_type == "mine" and absf(player_flight_y - flight_y) > 96.0:
		return false
	if not (obstacle_type in ["drone", "dropper_drone", "mine", "laser_gate"]) and player_flight_y < -62.0:
		passed = true
		return false
	if requires_jump and jump_z >= required_jump_height:
		passed = true
		return false
	passed = true
	return true


func can_collect(player_lane: float, camera_z: float, window: float) -> bool:
	if destroyed or obstacle_type != "powerup_carrier":
		return false
	return absf(world_z - camera_z) <= window and lane_overlaps(player_lane)


func lane_overlaps(player_lane: float) -> bool:
	var half_width := maxf(float(width_lanes) * 0.44, 0.42)
	return absf(player_lane - current_lane_value) <= half_width


func hit_by_shot(shot_lane: float, shot_z: float) -> bool:
	if destroyed or not shootable:
		return false
	if absf(world_z - shot_z) > 760.0:
		return false
	if not lane_overlaps(shot_lane):
		return false
	hp -= 1
	if hp <= 0:
		destroyed = true
		visible = false
		return true
	_refresh_health_bar()
	return true


func hit_by_winding_shot(shot_lane: float, shot_z: float, shot_flight_y: float, damage := 1) -> bool:
	if destroyed or not shootable:
		return false
	if absf(world_z - shot_z) > 155.0:
		return false
	if not lane_overlaps(shot_lane):
		return false
	if obstacle_type in ["drone", "dropper_drone", "powerup_carrier", "mine"] and absf(shot_flight_y - flight_y) > 155.0:
		return false
	hp -= maxi(int(damage), 1)
	hit_flash_timer = 0.12
	modulate = Color(1.0, 0.92, 0.55, 1.0)
	if hp <= 0:
		destroyed = true
		visible = false
		return true
	_refresh_health_bar()
	return true


func is_gravity_zone(camera_z: float) -> bool:
	return obstacle_type == "gravity_field" and absf(world_z - camera_z) < 260.0


func _laser_is_active(camera_z: float) -> bool:
	var pulse := maxf(float(data.get("pulse", 1.45)), 0.5)
	var phase := fmod((camera_z - world_z + 360.0) / 220.0, pulse)
	return phase > pulse * 0.46


func _ensure_nodes() -> void:
	if _sprite == null or not is_instance_valid(_sprite):
		_sprite = get_node_or_null("Sprite2D") as Sprite2D
		if _sprite == null:
			_sprite = Sprite2D.new()
			_sprite.name = "Sprite2D"
			add_child(_sprite)
	if _shadow == null or not is_instance_valid(_shadow):
		_shadow = get_node_or_null("AirShadow") as Node2D
		if _shadow == null:
			_shadow = WindingAirShadow.new()
			_shadow.name = "AirShadow"
			add_child(_shadow)
			move_child(_shadow, 0)
	if _health_back == null or not is_instance_valid(_health_back):
		_health_back = get_node_or_null("HealthBack") as ColorRect
		if _health_back == null:
			_health_back = ColorRect.new()
			_health_back.name = "HealthBack"
			add_child(_health_back)
	if _health_fill == null or not is_instance_valid(_health_fill):
		_health_fill = get_node_or_null("HealthFill") as ColorRect
		if _health_fill == null:
			_health_fill = ColorRect.new()
			_health_fill.name = "HealthFill"
			add_child(_health_fill)


func _refresh_health_bar() -> void:
	if _health_back == null or _health_fill == null:
		return
	var show_bar := shootable and _max_hp > 1 and hp > 0
	_health_back.visible = show_bar
	_health_fill.visible = show_bar
	if not show_bar:
		return
	_health_back.color = Color(0.04, 0.02, 0.01, 0.82)
	_health_fill.color = Color(0.95, 0.20, 0.08, 0.90)
	_health_back.position = Vector2(-44.0, -54.0)
	_health_back.size = Vector2(88.0, 7.0)
	_health_fill.position = _health_back.position + Vector2(1.0, 1.0)
	_health_fill.size = Vector2(86.0 * clampf(float(hp) / float(_max_hp), 0.0, 1.0), 5.0)


func _update_air_shadow(scale_value: float) -> void:
	if _shadow == null:
		return
	var altitude := clampf(absf(flight_y) / 260.0, 0.0, 1.0)
	_shadow.visible = true
	_shadow.position = Vector2(0.0, -flight_y + 18.0 * scale_value)
	_shadow.scale = Vector2(scale_value * (2.1 - altitude * 0.65), scale_value * (0.58 - altitude * 0.22))
	_shadow.modulate = Color(1.0, 1.0, 1.0, 0.34 - altitude * 0.18)


class WindingAirShadow:
	extends Node2D

	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(2.8, 0.55))
		draw_circle(Vector2.ZERO, 24.0, Color(0.0, 0.0, 0.0, 0.42))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
