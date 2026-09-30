extends Node2D
class_name WindingBikeController

signal shot_fired(lane_pos: float, flight_y: float)

const RIDE_TEXTURE := preload("res://assets/sprites/speedbike/speedbike_ride.png")
const JUMP_TEXTURE := preload("res://assets/sprites/speedbike/speedbike_jump.png")

@export var lane_speed := 4.6
@export var jump_duration := 0.58
@export var jump_height := 72.0
@export var fire_cooldown := 0.13
@export var flight_speed := 390.0
@export var max_flight_height := 430.0

var lane_pos := 0.0
var flight_y := 0.0
var jump_z := 0.0
var jumping := false
var jump_timer := 0.0
var fire_timer := 0.0
var cannon_boost_timer := 0.0
var invuln_timer := 0.0
var health := 4
var max_health := 4
var crashed := false
var player_world_offset := 80.0
var speed_drag_factor := 1.0
var speed_thrust_factor := 1.0
var thrust_charge := 0.0
var skid_amount := 0.0
var skid_marks: Array[Dictionary] = []

var _sprite: Sprite2D
var _engine_glow: Node2D
var _weapon_aura: Node2D
var _shadow: Node2D
var _smoke: Node2D
var _hover_time := 0.0
var _last_flight_y := 0.0
var _lift_velocity := 0.0
var _ride_texture: Texture2D = RIDE_TEXTURE
var _jump_texture: Texture2D = JUMP_TEXTURE
var _rider_scale := 0.16
var _visual_rotation_offset := 0.0
var _crash_side := -1.0
var _spinout_requested := false
var _weapon_glow_color := Color(0.86, 0.96, 1.0, 1.0)
var _weapon_glow_strength := 0.18


func _ready() -> void:
	InputBindings.load_and_apply()
	_ensure_nodes()
	reset()


func setup_hits(hit_count: int) -> void:
	max_health = maxi(hit_count, 1)
	health = max_health


func reset() -> void:
	lane_pos = 0.0
	flight_y = 0.0
	jump_z = 0.0
	jump_timer = 0.0
	fire_timer = 0.0
	speed_drag_factor = 1.0
	speed_thrust_factor = 1.0
	thrust_charge = 0.0
	skid_amount = 0.0
	skid_marks.clear()
	invuln_timer = 0.45
	jumping = false
	crashed = false
	_crash_side = -1.0
	_spinout_requested = false
	_ensure_nodes()
	_sprite.texture = _ride_texture
	_sprite.scale = Vector2(0.22, 0.22)
	modulate = Color.WHITE


func set_weapon_glow(color: Color, strength: float) -> void:
	_weapon_glow_color = color
	_weapon_glow_strength = clampf(strength, 0.0, 1.0)
	if _weapon_aura != null and is_instance_valid(_weapon_aura):
		_weapon_aura.set("glow_color", _weapon_glow_color)
		_weapon_aura.set("strength", _weapon_glow_strength)


func apply_rider_profile(profile: Dictionary) -> void:
	_ensure_nodes()
	var ride: Variant = profile.get("ride_texture", null)
	var jump: Variant = profile.get("jump_texture", null)
	if ride is Texture2D:
		_ride_texture = ride
	if jump is Texture2D:
		_jump_texture = jump
	lane_speed = 4.6 * float(profile.get("horizontal_mult", 1.0))
	jump_height = 72.0 + float(profile.get("jump_height_add", 0.0))
	jump_duration = 0.58 * float(profile.get("jump_duration_mult", 1.0))
	fire_cooldown = 0.13 * float(profile.get("shot_cooldown_mult", 1.0))
	_rider_scale = 0.16 * float(profile.get("winding_scale_mult", 1.0))
	_sprite.texture = _ride_texture


func tick(delta: float, renderer: Pseudo3DRoadRenderer, camera_z: float, speed: float, force_scale: float) -> void:
	_ensure_nodes()
	_hover_time += delta
	fire_timer = maxf(0.0, fire_timer - delta)
	cannon_boost_timer = maxf(0.0, cannon_boost_timer - delta)
	invuln_timer = maxf(0.0, invuln_timer - delta)
	if crashed:
		rotation_degrees = lerpf(rotation_degrees, _crash_side * 78.0, delta * 5.0)
		position.x += _crash_side * 330.0 * delta
		position.y += 155.0 * delta
		return

	var input_x := _winding_horizontal_axis()
	var input_y := _winding_vertical_axis()
	input_x = clampf(input_x, -1.0, 1.0)
	input_y = clampf(input_y, -1.0, 1.0)
	var grounded := flight_y >= -4.0 and jump_z <= 1.0
	var ebraking := grounded and _winding_ebrake_pressed()
	var thrusting := _winding_thrust_pressed()
	speed_drag_factor = 1.0
	if thrusting:
		thrust_charge = clampf(thrust_charge + delta * 0.34, 0.0, 1.0)
	else:
		thrust_charge = maxf(thrust_charge - delta * 0.22, 0.0)
	speed_thrust_factor = 1.0 + thrust_charge * 0.48
	if ebraking:
		speed_drag_factor = 0.48
		skid_amount = clampf(skid_amount + delta * 0.30, 0.0, 1.35)
	else:
		skid_amount = maxf(skid_amount - delta * (0.68 if grounded else 0.90), 0.0)
	if ebraking:
		var skid_drift := sin(_hover_time * 5.4) * (0.16 + skid_amount * 0.18)
		lane_pos += skid_drift * delta
	if skid_amount >= 1.18:
		_spinout_requested = true
	var curve_force := renderer.curve_at(camera_z + player_world_offset) * speed * 0.00105 * force_scale
	lane_pos += input_x * lane_speed * delta
	lane_pos -= curve_force * delta
	var airborne := flight_y < -52.0 or jump_z > 14.0
	var lane_limit := 2.72 if airborne else renderer.road_lane_limit_at_rel(player_world_offset)
	lane_pos = clampf(lane_pos, -lane_limit, lane_limit)
	flight_y += input_y * flight_speed * delta
	flight_y = clampf(flight_y, -maxf(max_flight_height, 0.0), 0.0)
	if input_y > 0.15 and flight_y > -10.0:
		flight_y = 0.0
	_lift_velocity = (flight_y - _last_flight_y) / maxf(delta, 0.001)
	_last_flight_y = flight_y

	# Space/A is an emergency brake on the road in winding mode.
	_update_jump(delta)
	if _winding_attack_pressed():
		_fire()

	var projected := renderer.project(camera_z + player_world_offset, lane_pos)
	var ground_pos := Vector2(float(projected.get("x", 0.0)), float(projected.get("y", 0.0)))
	position = ground_pos + Vector2(0.0, flight_y - jump_z)
	var scale_value := float(projected.get("scale", 1.0)) * _rider_scale
	_sprite.scale = Vector2(scale_value, scale_value)
	_sprite.texture = _jump_texture if jumping else _ride_texture
	_sprite.rotation_degrees = _visual_rotation_offset
	var curve_now := renderer.curve_at(camera_z + player_world_offset)
	var skid_tilt := skid_amount * sin(_hover_time * 17.0) * 10.0
	var road_grip_tilt := -curve_now * (13.0 if grounded else 7.0)
	var lane_counter_lean := input_x * (11.0 if grounded else 7.0)
	rotation_degrees = lerpf(rotation_degrees, lane_counter_lean + input_y * 4.0 + road_grip_tilt + skid_tilt, delta * 8.0)
	var pulse := 0.74 + sin(_hover_time * 14.0) * 0.18
	_engine_glow.scale = Vector2(scale_value * (210.0 + thrust_charge * 170.0) * pulse, scale_value * (30.0 + thrust_charge * 24.0) * pulse)
	_engine_glow.position = Vector2(-140.0 * scale_value, 30.0 * scale_value)
	_engine_glow.set("charge", thrust_charge)
	_weapon_aura.scale = Vector2(scale_value * 185.0, scale_value * 118.0)
	_weapon_aura.set("glow_color", _weapon_glow_color)
	_weapon_aura.set("strength", _weapon_glow_strength)
	_update_flight_fx(scale_value, ground_pos)
	_update_skid_marks(delta, ebraking, scale_value)
	modulate = Color(1.0, 1.0, 1.0, 0.48 + sin(_hover_time * 36.0) * 0.28) if invuln_timer > 0.0 else Color.WHITE


func is_airborne_enough(required_height: float) -> bool:
	return jump_z >= required_height


func apply_hit(amount := 1) -> bool:
	if invuln_timer > 0.0 or crashed:
		return false
	health = maxi(health - amount, 0)
	invuln_timer = 0.75
	return health <= 0


func mark_crashed() -> void:
	crashed = true
	jumping = false
	jump_z = 0.0
	speed_drag_factor = 1.0
	_crash_side = -1.0 if lane_pos <= 0.0 else 1.0


func consume_spinout_request() -> bool:
	if not _spinout_requested:
		return false
	_spinout_requested = false
	return true


func _start_jump() -> void:
	jumping = true
	jump_timer = 0.0


func _update_jump(delta: float) -> void:
	if not jumping:
		jump_z = 0.0
		return
	jump_timer += delta
	var t := jump_timer / jump_duration
	if t >= 1.0:
		jumping = false
		jump_z = 0.0
		return
	jump_z = sin(t * PI) * jump_height


func _fire() -> void:
	if fire_timer > 0.0:
		return
	fire_timer = fire_cooldown * (0.62 if cannon_boost_timer > 0.0 else 1.0)
	shot_fired.emit(lane_pos, flight_y)


func _axis(negative: String, positive: String) -> float:
	var value := 0.0
	if InputMap.has_action(negative) and Input.is_action_pressed(negative):
		value -= 1.0
	if InputMap.has_action(positive) and Input.is_action_pressed(positive):
		value += 1.0
	return value


func _winding_horizontal_axis() -> float:
	var value := 0.0
	if InputBindings.is_action_pressed("move_left", "ui_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		value -= 1.0
	if InputBindings.is_action_pressed("move_right", "ui_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		value += 1.0
	return value


func _winding_vertical_axis() -> float:
	var value := 0.0
	if InputBindings.is_action_pressed("move_up", "ui_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		value -= 1.0
	if InputBindings.is_action_pressed("move_down", "ui_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		value += 1.0
	return value


func grant_cannon_boost(duration: float) -> void:
	cannon_boost_timer = maxf(cannon_boost_timer, duration)


func _winding_jump_pressed() -> bool:
	return InputBindings.is_action_just_pressed("jump", "ui_accept") or Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)


func _winding_thrust_pressed() -> bool:
	return Input.is_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_SHOULDER)


func _winding_ebrake_pressed() -> bool:
	return InputBindings.is_action_pressed("jump") or Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)


func _winding_attack_pressed() -> bool:
	return InputBindings.is_action_just_pressed("attack") or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_X)


func _pressed_any(actions: Array[String]) -> bool:
	for action in actions:
		if InputMap.has_action(action) and Input.is_action_just_pressed(action):
			return true
	return false


func _ensure_nodes() -> void:
	if _sprite == null or not is_instance_valid(_sprite):
		_sprite = get_node_or_null("Sprite2D") as Sprite2D
		if _sprite == null:
			_sprite = Sprite2D.new()
			_sprite.name = "Sprite2D"
			add_child(_sprite)
		_sprite.texture = RIDE_TEXTURE
		_sprite.centered = true
	if _engine_glow == null or not is_instance_valid(_engine_glow):
		_engine_glow = get_node_or_null("EngineGlow") as Node2D
		if _engine_glow == null:
			_engine_glow = EngineGlowDrawer.new()
			_engine_glow.name = "EngineGlow"
			add_child(_engine_glow)
			move_child(_engine_glow, 0)
	if _weapon_aura == null or not is_instance_valid(_weapon_aura):
		_weapon_aura = get_node_or_null("WeaponAura") as Node2D
		if _weapon_aura == null:
			_weapon_aura = WeaponAuraDrawer.new()
			_weapon_aura.name = "WeaponAura"
			add_child(_weapon_aura)
			move_child(_weapon_aura, 1)
	if _shadow == null or not is_instance_valid(_shadow):
		_shadow = get_node_or_null("RoadShadow") as Node2D
		if _shadow == null:
			_shadow = FlightShadowDrawer.new()
			_shadow.name = "RoadShadow"
			add_child(_shadow)
			move_child(_shadow, 0)
	if _smoke == null or not is_instance_valid(_smoke):
		_smoke = get_node_or_null("FlightSmoke") as Node2D
		if _smoke == null:
			_smoke = FlightSmokeDrawer.new()
			_smoke.name = "FlightSmoke"
			add_child(_smoke)
			move_child(_smoke, 1)


func _update_flight_fx(scale_value: float, ground_pos: Vector2) -> void:
	var altitude := clampf((-flight_y + jump_z) / 430.0, 0.0, 1.0)
	var lift_power := clampf(absf(_lift_velocity) / 360.0, 0.0, 1.0)
	var thrust := 0.58 + lift_power * 0.42 + altitude * 0.18 + skid_amount * 0.70 + thrust_charge * 0.80
	_shadow.global_position = ground_pos + Vector2(0.0, 18.0 * scale_value)
	_shadow.scale = Vector2(scale_value * (1.35 - altitude * 0.42), scale_value * (0.50 - altitude * 0.16))
	_shadow.modulate = Color(1.0, 1.0, 1.0, 0.34 - altitude * 0.20)
	_smoke.position = Vector2(0.0, 132.0 * scale_value)
	_smoke.scale = Vector2(scale_value * 150.0, scale_value * 150.0)
	_smoke.set("thrust", thrust)
	_smoke.set("lift", clampf(-_lift_velocity / 420.0, -1.0, 1.0))
	_smoke.set("skid", skid_amount)
	_smoke.set("charge", thrust_charge)


func _update_skid_marks(delta: float, ebraking: bool, scale_value: float) -> void:
	for index in range(skid_marks.size() - 1, -1, -1):
		var mark := skid_marks[index]
		mark["life"] = float(mark.get("life", 0.0)) - delta
		mark["age"] = float(mark.get("age", 0.0)) + delta
		if float(mark.get("life", 0.0)) <= 0.0:
			skid_marks.remove_at(index)
		else:
			skid_marks[index] = mark
	if not ebraking or scale_value <= 0.0:
		return
	if skid_marks.size() > 28:
		skid_marks.remove_at(0)
	var side_sway := sin(_hover_time * 11.0) * 8.0 * scale_value
	for side in [-1.0, 1.0]:
		skid_marks.append({
			"local_pos": Vector2(side * 46.0 * scale_value + side_sway, 96.0 * scale_value),
			"length": 74.0 * scale_value * (0.65 + skid_amount * 0.38),
			"width": maxf(1.8, 7.0 * scale_value),
			"side": side,
			"life": 0.62,
			"age": 0.0
		})


class WeaponAuraDrawer:
	extends Node2D

	var glow_color := Color(0.86, 0.96, 1.0, 1.0)
	var strength := 0.18
	var time_accum := 0.0

	func _process(delta: float) -> void:
		time_accum += delta
		queue_redraw()

	func _draw() -> void:
		if strength <= 0.01:
			return
		var pulse := 0.5 + sin(time_accum * 8.5) * 0.5
		var alpha := (0.055 + pulse * 0.055) * strength
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.28, 0.64))
		draw_circle(Vector2.ZERO, 1.0, Color(glow_color.r, glow_color.g, glow_color.b, alpha))
		draw_circle(Vector2.ZERO, 0.72, Color(glow_color.r, glow_color.g, glow_color.b, alpha * 0.55))
		draw_arc(Vector2.ZERO, 1.04 + pulse * 0.06, time_accum * 1.7, time_accum * 1.7 + PI * 1.55, 28, Color(glow_color.r, glow_color.g, glow_color.b, alpha * 2.2), 0.025, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class EngineGlowDrawer:
	extends Node2D

	var charge := 0.0
	var time_accum := 0.0

	func _process(_delta: float) -> void:
		time_accum += _delta
		queue_redraw()

	func _draw() -> void:
		var blue_t := smoothstep(0.62, 1.0, charge)
		var gold_t := clampf(charge * 1.35, 0.0, 1.0)
		var pulse := 0.5 + sin(time_accum * 12.0) * 0.5
		draw_circle(Vector2.ZERO, 0.50 + gold_t * 0.24, Color(0.18, 0.52, 1.0, 0.16 + blue_t * 0.18))
		draw_circle(Vector2.ZERO, 0.42 + gold_t * 0.42, Color(1.0, 0.76, 0.10, 0.16 * gold_t))
		if blue_t > 0.0:
			draw_circle(Vector2.ZERO, 0.58 + blue_t * 0.52 + pulse * 0.08, Color(0.10, 0.72, 1.0, 0.18 * blue_t))
			draw_arc(Vector2.ZERO, 0.62 + blue_t * 0.38, time_accum * 2.8, time_accum * 2.8 + PI * 1.25, 32, Color(0.55, 0.92, 1.0, 0.34 * blue_t), 0.035, true)
		elif gold_t > 0.0:
			draw_arc(Vector2.ZERO, 0.55 + gold_t * 0.36, -time_accum * 2.2, -time_accum * 2.2 + PI * 1.1, 32, Color(1.0, 0.86, 0.24, 0.32 * gold_t), 0.035, true)
		draw_circle(Vector2.ZERO, 0.36, Color(0.95, 0.50, 0.12, 0.26 + gold_t * 0.16))


class FlightShadowDrawer:
	extends Node2D

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(2.9, 0.72))
		draw_circle(Vector2.ZERO, 26.0, Color(0.0, 0.0, 0.0, 0.42))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.8, 0.42))
		draw_circle(Vector2.ZERO, 21.0, Color(0.0, 0.0, 0.0, 0.22))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class FlightSmokeDrawer:
	extends Node2D

	var thrust := 0.6
	var lift := 0.0
	var skid := 0.0
	var charge := 0.0
	var time_accum := 0.0

	func _process(delta: float) -> void:
		time_accum += delta
		queue_redraw()

	func _draw() -> void:
		var flame_len := 0.34 + thrust * 0.34
		var sway := lift * 0.16 + sin(time_accum * 8.0) * 0.05
		var flame := PackedVector2Array([
			Vector2(-0.20, -0.16),
			Vector2(0.20, -0.16),
			Vector2(0.10 + sway, flame_len),
			Vector2(0.00 + sway * 0.6, flame_len + 0.20),
			Vector2(-0.10 + sway, flame_len)
		])
		var blue_t := smoothstep(0.62, 1.0, charge)
		var flame_color := Color(1.0, 0.48, 0.08, 0.58).lerp(Color(0.22, 0.74, 1.0, 0.68), blue_t)
		draw_colored_polygon(flame, flame_color)
		draw_colored_polygon(PackedVector2Array([
			Vector2(-0.10, -0.10),
			Vector2(0.10, -0.10),
			Vector2(0.04 + sway * 0.5, flame_len * 0.72),
			Vector2(-0.04 + sway * 0.5, flame_len * 0.72)
		]), Color(1.0, 0.86, 0.34, 0.62).lerp(Color(0.82, 1.0, 1.0, 0.72), blue_t))
		for index in range(5):
			var t := float(index) / 4.0
			var drift := sin(time_accum * 2.4 + float(index)) * 0.18 + sway * 0.8 + sin(time_accum * 9.0 + float(index) * 1.7) * 0.05 * skid
			var pos := Vector2(drift, flame_len + 0.10 + t * 0.72)
			var radius := 0.10 + t * 0.12 + skid * 0.08
			var smoke_color := Color(0.10, 0.09, 0.12, (0.22 + thrust * 0.08 + skid * 0.20) * (1.0 - t))
			draw_circle(pos, radius, smoke_color)
