extends Area2D
class_name SpeedbikeController

signal shot_fired(origin: Vector2, direction: Vector2)

const RIDE_TEXTURE_PATH := "res://assets/sprites/speedbike/speedbike_ride.png"
const JUMP_TEXTURE_PATH := "res://assets/sprites/speedbike/speedbike_jump.png"

@export var ride_texture: Texture2D = preload(RIDE_TEXTURE_PATH)
@export var jump_texture: Texture2D = preload(JUMP_TEXTURE_PATH)
@export var base_scale := 0.14
@export var vertical_speed := 420.0
@export var horizontal_speed := 340.0
@export var jump_duration := 0.62
@export var jump_height := 72.0
@export var jump_cooldown := 0.12
@export var shot_cooldown := 0.12
@export var bike_hurtbox_size := Vector2(156.0, 54.0)
@export var hover_bob_amount := 5.0
@export var hover_bob_speed := 4.8
@export var afterburner_forward_speed := 210.0
@export var afterburner_horizontal_bonus := 140.0
@export var afterburner_max := 100.0
@export var afterburner_drain_per_sec := 34.0
@export var afterburner_recharge_per_sec := 18.0
@export var afterburner_idle_recharge_per_sec := 28.0
@export var afterburner_restart_threshold := 14.0
@export var afterburner_scroll_bonus := 360.0
@export var window_left_margin := 120.0
@export var window_right_margin := 170.0
@export var minimum_window_width := 440.0

@onready var bike_sprite: Sprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var engine_trail: Marker2D = $EngineTrail

var play_window_left := 110.0
var play_window_right := 500.0
var top_bound := 112.0
var bottom_bound := 584.0
var jump_z := 0.0
var jump_velocity_z := 0.0
var jump_gravity_up := 0.0
var jump_gravity_down := 0.0
var jump_cooldown_timer := 0.0
var shot_cooldown_timer := 0.0
var engine_time := 0.0
var bike_tilt := 0.0
var jumping := false
var jump_blocked := false
var crashed := false
var control_locked := false
var vertical_inverted := false
var cannon_boost_timer := 0.0
var _jump_prev := false
var _attack_prev := false
var _cached_left := 0.0
var _input_x := 0.0
var _input_y := 0.0
var _hover_offset := 0.0
var _visual_scroll_speed := 0.0
var _virtual_up := false
var _virtual_down := false
var _virtual_left := false
var _virtual_right := false
var _virtual_jump := false
var _virtual_attack := false
var _virtual_boost := false
var _default_base_scale := 0.14
var _default_vertical_speed := 420.0
var _default_horizontal_speed := 340.0
var _default_jump_duration := 0.62
var _default_jump_height := 72.0
var _default_jump_cooldown := 0.12
var _default_shot_cooldown := 0.12
var _default_bike_hurtbox_size := Vector2(156.0, 54.0)
var _active_jump_height := 72.0
var _active_jump_duration := 0.62
var afterburner_meter := 0.0
var afterburner_empty_lock := false
var afterburner_active := false
var spinout_timer := 0.0
var spinout_duration := 0.0
var weapon_glow_active := false
var weapon_glow_color := Color(0.0, 0.0, 0.0, 0.0)


func _ready() -> void:
	InputBindings.load_and_apply()
	_default_base_scale = base_scale
	_default_vertical_speed = vertical_speed
	_default_horizontal_speed = horizontal_speed
	_default_jump_duration = jump_duration
	_default_jump_height = jump_height
	_default_jump_cooldown = jump_cooldown
	_default_shot_cooldown = shot_cooldown
	_default_bike_hurtbox_size = bike_hurtbox_size
	_active_jump_height = jump_height
	_active_jump_duration = jump_duration
	if bike_sprite != null:
		bike_sprite.texture = ride_texture
		bike_sprite.scale = Vector2(base_scale, base_scale)
	queue_redraw()


func apply_rider_profile(profile: Dictionary) -> void:
	ride_texture = profile.get("ride_texture", ride_texture)
	jump_texture = profile.get("jump_texture", jump_texture)
	base_scale = float(profile.get("scale", _default_base_scale))
	vertical_speed = float(profile.get("vertical_speed", _default_vertical_speed))
	horizontal_speed = float(profile.get("horizontal_speed", _default_horizontal_speed))
	jump_duration = float(profile.get("jump_duration", _default_jump_duration))
	jump_height = float(profile.get("jump_height", _default_jump_height))
	jump_cooldown = float(profile.get("jump_cooldown", _default_jump_cooldown))
	shot_cooldown = float(profile.get("shot_cooldown", _default_shot_cooldown))
	bike_hurtbox_size = profile.get("hurtbox_size", _default_bike_hurtbox_size)
	if bike_sprite != null:
		bike_sprite.texture = ride_texture
		bike_sprite.scale = Vector2(base_scale, base_scale)
	queue_redraw()


func configure_play_window(camera_left: float, top_y: float, bottom_y: float) -> void:
	_cached_left = camera_left
	_refresh_play_window(camera_left)
	top_bound = top_y
	bottom_bound = bottom_y


func reset_for_stage(camera_left: float, start_y: float) -> void:
	_cached_left = camera_left
	_refresh_play_window(camera_left)
	position = Vector2(camera_left + 220.0, start_y)
	jump_z = 0.0
	jump_velocity_z = 0.0
	jump_gravity_up = 0.0
	jump_gravity_down = 0.0
	jump_cooldown_timer = 0.0
	shot_cooldown_timer = 0.0
	engine_time = 0.0
	bike_tilt = 0.0
	jumping = false
	_active_jump_height = jump_height
	_active_jump_duration = jump_duration
	afterburner_meter = 0.0
	afterburner_empty_lock = false
	afterburner_active = false
	spinout_timer = 0.0
	spinout_duration = 0.0
	jump_blocked = false
	crashed = false
	control_locked = false
	vertical_inverted = false
	cannon_boost_timer = 0.0
	_jump_prev = false
	_attack_prev = false
	_input_x = 0.0
	_input_y = 0.0
	_hover_offset = 0.0
	if bike_sprite != null:
		bike_sprite.texture = ride_texture
		bike_sprite.position = Vector2.ZERO
		bike_sprite.rotation = 0.0
	queue_redraw()


func set_control_locked(value: bool) -> void:
	control_locked = value
	if value:
		afterburner_active = false


func set_crashed(value: bool) -> void:
	crashed = value
	control_locked = value
	if value:
		afterburner_active = false


func set_vertical_inverted(value: bool) -> void:
	vertical_inverted = value


func set_virtual_input_states(up: bool, down: bool, left: bool, right: bool, jump: bool, attack: bool, boost: bool) -> void:
	_virtual_up = up
	_virtual_down = down
	_virtual_left = left
	_virtual_right = right
	_virtual_jump = jump
	_virtual_attack = attack
	_virtual_boost = boost


func grant_cannon_boost(duration: float) -> void:
	cannon_boost_timer = maxf(cannon_boost_timer, duration)


func set_weapon_glow(color: Color, active: bool = true) -> void:
	weapon_glow_color = color
	weapon_glow_active = active


func bike_midpoint() -> Vector2:
	return global_position + Vector2(0.0, -18.0)


func hurtbox_rect() -> Rect2:
	return Rect2(
		global_position.x - bike_hurtbox_size.x * 0.5,
		global_position.y - bike_hurtbox_size.y * 0.5 - 18.0,
		bike_hurtbox_size.x,
		bike_hurtbox_size.y
	)


func is_airborne() -> bool:
	return jumping or jump_z > 0.0


func boost_ratio() -> float:
	return clampf(afterburner_meter / maxf(afterburner_max, 1.0), 0.0, 1.0)


func is_afterburner_active() -> bool:
	return afterburner_active


func afterburner_stage_speed_bonus() -> float:
	return afterburner_scroll_bonus * boost_ratio()


func apply_spinout(duration: float = 2.0) -> void:
	spinout_timer = maxf(spinout_timer, duration)
	spinout_duration = maxf(spinout_timer, 0.01)
	afterburner_active = false


func is_spinning_out() -> bool:
	return spinout_timer > 0.0


func tick(delta: float, camera_left: float, scroll_speed: float = 0.0) -> void:
	_cached_left = camera_left
	_visual_scroll_speed = scroll_speed
	_refresh_play_window(camera_left)
	engine_time += delta
	jump_cooldown_timer = maxf(jump_cooldown_timer - delta, 0.0)
	shot_cooldown_timer = maxf(shot_cooldown_timer - delta, 0.0)
	cannon_boost_timer = maxf(cannon_boost_timer - delta, 0.0)
	spinout_timer = maxf(spinout_timer - delta, 0.0)
	position.x += scroll_speed * delta
	if not crashed and not control_locked:
		_handle_input(delta)
	_update_jump(delta)
	_update_visuals(delta)
	queue_redraw()


func _handle_input(delta: float) -> void:
	var up_down := InputBindings.is_action_pressed("move_up", "ui_up") or Input.is_key_pressed(KEY_W)
	var down_down := InputBindings.is_action_pressed("move_down", "ui_down") or Input.is_key_pressed(KEY_S)
	var left_down := InputBindings.is_action_pressed("move_left", "ui_left") or Input.is_key_pressed(KEY_A)
	var right_down := InputBindings.is_action_pressed("move_right", "ui_right") or Input.is_key_pressed(KEY_D)
	var jump_down := InputBindings.is_action_pressed("jump") or Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)
	var attack_down := InputBindings.is_action_pressed("attack") or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_X)
	var boost_down := InputBindings.is_action_pressed("boost") or Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL) or Input.is_joy_button_pressed(0, JOY_BUTTON_RIGHT_SHOULDER)
	up_down = up_down or _virtual_up
	down_down = down_down or _virtual_down
	left_down = left_down or _virtual_left
	right_down = right_down or _virtual_right
	jump_down = jump_down or _virtual_jump
	attack_down = attack_down or _virtual_attack
	boost_down = boost_down or _virtual_boost

	var input_y := 0.0
	if up_down:
		input_y -= 1.0
	if down_down:
		input_y += 1.0
	if vertical_inverted:
		input_y *= -1.0
	var input_x := 0.0
	if right_down:
		input_x += 1.0
	if left_down:
		input_x -= 1.0
	_input_x = input_x
	_input_y = input_y
	if spinout_timer > 0.0:
		var skid := sin(engine_time * 16.0)
		_input_x = -0.45 + skid * 0.20
		_input_y = skid * 0.16
		_update_afterburner(delta, false)
		position.y += _input_y * vertical_speed * 0.18 * delta
		position.x += (-118.0 + skid * 86.0) * delta
		position.x = clampf(position.x, play_window_left, play_window_right)
		position.y = clampf(position.y, top_bound, bottom_bound)
		_jump_prev = jump_down
		_attack_prev = attack_down
		return
	_update_afterburner(delta, boost_down)

	position.y += input_y * vertical_speed * delta
	position.x += input_x * horizontal_speed * delta
	if afterburner_active:
		var pressure := maxf(boost_ratio(), 0.35)
		var push_bonus := (afterburner_forward_speed + maxf(input_x, 0.0) * afterburner_horizontal_bonus) * pressure
		position.x += push_bonus * delta
	position.x = clampf(position.x, play_window_left, play_window_right)
	position.y = clampf(position.y, top_bound, bottom_bound)

	if jump_down and not _jump_prev and not jumping and jump_cooldown_timer <= 0.0 and not jump_blocked:
		_start_jump(jump_height, jump_duration, jump_cooldown)

	if attack_down and shot_cooldown_timer <= 0.0:
		var fire_rate := 0.08 if cannon_boost_timer > 0.0 else shot_cooldown
		shot_cooldown_timer = fire_rate
		var origin := muzzle.global_position if muzzle != null else global_position + Vector2(92.0, -18.0)
		shot_fired.emit(origin, Vector2.RIGHT)

	_jump_prev = jump_down
	_attack_prev = attack_down


func _update_afterburner(delta: float, boost_down: bool) -> void:
	afterburner_empty_lock = false
	afterburner_active = boost_down and not crashed and not control_locked
	if afterburner_active:
		var build_rate := maxf(afterburner_recharge_per_sec, afterburner_idle_recharge_per_sec) * 2.25
		afterburner_meter = minf(afterburner_max, afterburner_meter + build_rate * delta)
		return
	var decay_rate := afterburner_drain_per_sec * 0.58
	afterburner_meter = maxf(0.0, afterburner_meter - decay_rate * delta)


func _update_jump(delta: float) -> void:
	if not jumping:
		jump_z = 0.0
		jump_velocity_z = 0.0
		return
	var gravity := jump_gravity_up if jump_velocity_z > 0.0 else jump_gravity_down
	jump_velocity_z -= gravity * delta
	jump_z += jump_velocity_z * delta
	if jump_z <= 0.0 and jump_velocity_z <= 0.0:
		jumping = false
		jump_z = 0.0
		jump_velocity_z = 0.0
		_active_jump_height = jump_height
		_active_jump_duration = jump_duration
		return


func _update_visuals(delta: float) -> void:
	if bike_sprite == null:
		return
	if crashed:
		bike_sprite.z_index = -1
		bike_sprite.modulate = Color(0.50, 0.48, 0.45, 0.72)
		_hover_offset = sin(engine_time * hover_bob_speed * 0.55) * hover_bob_amount * 0.34
		bike_tilt = lerpf(bike_tilt, -0.38, delta * 3.8)
		bike_sprite.texture = ride_texture
		bike_sprite.position = Vector2(-4.0 + sin(engine_time * 8.5) * 2.5, _hover_offset - jump_z * 0.28)
		bike_sprite.rotation = bike_tilt + sin(engine_time * 10.0) * 0.025
		bike_sprite.scale = Vector2(base_scale, base_scale)
		return
	if spinout_timer > 0.0:
		bike_sprite.z_index = 0
		bike_sprite.texture = ride_texture
		var wobble := sin(engine_time * 16.0)
		var bite := absf(wobble)
		_hover_offset = sin(engine_time * hover_bob_speed * 1.6) * hover_bob_amount * 0.8
		bike_sprite.modulate = Color(1.0, 0.80, 0.58, 1.0)
		bike_sprite.position = Vector2(wobble * 16.0, _hover_offset - jump_z * 0.26)
		bike_sprite.rotation = wobble * 0.58
		bike_sprite.scale = Vector2(base_scale * (1.0 + bite * 0.035), base_scale * (1.0 - bite * 0.025))
		return
	bike_sprite.z_index = 0
	var motion_ratio := clampf((position.x - (play_window_left + 150.0)) / maxf(play_window_right - play_window_left, 1.0), -1.0, 1.0)
	var idle_factor := 1.0 if absf(_input_x) < 0.05 and absf(_input_y) < 0.05 and not jumping else 0.45
	_hover_offset = sin(engine_time * hover_bob_speed) * hover_bob_amount * idle_factor
	var climb_tilt := clampf(jump_velocity_z / 720.0, -0.12, 0.12)
	var target_tilt := (-_input_y * 0.08) + (_input_x * 0.04) + motion_ratio * 0.02 - climb_tilt
	var light_tint := Color(0.96, 0.94, 0.88, 1.0)
	if afterburner_active:
		target_tilt += 0.03
		light_tint = Color(1.0, 0.95, 0.84, 1.0)
	bike_sprite.modulate = light_tint
	bike_tilt = lerpf(bike_tilt, target_tilt, delta * 7.5)
	bike_sprite.texture = jump_texture if is_airborne() and jump_texture != null else ride_texture
	bike_sprite.position = Vector2(_input_x * 3.0, _hover_offset - jump_z * 0.62)
	bike_sprite.rotation = bike_tilt
	bike_sprite.scale = Vector2(base_scale, base_scale)


func launch_from_ramp(big_jump: bool = false) -> void:
	if crashed or control_locked or jumping:
		return
	var boosted_height := maxf(jump_height + 42.0, jump_height * 1.44)
	var boosted_duration := maxf(jump_duration * 1.11, jump_duration + 0.10)
	var fall_scale := 0.72
	if big_jump:
		boosted_height = maxf(jump_height + 110.0, jump_height * 2.10)
		boosted_duration = maxf(jump_duration * 1.44, jump_duration + 0.38)
		fall_scale = 0.62
	_start_jump(boosted_height, boosted_duration, maxf(jump_cooldown, 0.22), fall_scale)


func _start_jump(height: float, duration: float, cooldown: float, fall_scale: float = 0.76) -> void:
	jumping = true
	jump_z = 0.01
	_active_jump_height = height
	_active_jump_duration = duration
	jump_cooldown_timer = cooldown
	var safe_duration := maxf(duration, 0.12)
	var base_gravity := (8.0 * height) / (safe_duration * safe_duration)
	jump_velocity_z = (4.0 * height) / safe_duration
	jump_gravity_up = base_gravity
	jump_gravity_down = base_gravity * clampf(fall_scale, 0.42, 0.96)


func _refresh_play_window(camera_left: float) -> void:
	var viewport_width := get_viewport_rect().size.x
	play_window_left = camera_left + window_left_margin
	var desired_right := camera_left + maxf(viewport_width - window_right_margin, window_left_margin + minimum_window_width)
	play_window_right = maxf(play_window_left + minimum_window_width, desired_right)


func _draw() -> void:
	_draw_hover_contact_shadow()
	_draw_weapon_powerup_glow()
	if engine_trail == null:
		return
	var smoke_origin := to_local(engine_trail.global_position)
	var speed_heat := clampf((_visual_scroll_speed - 900.0) / 1500.0, 0.0, 1.0)
	var boost_heat := maxf(speed_heat, boost_ratio() if afterburner_active else 0.0)
	var hover_pulse := 0.75 + sin(engine_time * 5.4) * 0.12
	var puff_total := 13 if crashed else (6 if afterburner_active else 4)
	for puff in range(puff_total):
		var puff_t := engine_time * (3.8 if crashed else 2.8) + float(puff) * 0.42
		var boost_scale := 2.05 if crashed else ((1.35 + boost_heat * 0.28) if afterburner_active else 1.0)
		var back_offset := (16.0 + float(puff) * 18.0 + sin(puff_t * 1.8) * 4.0) * boost_scale
		var rise_offset := sin(puff_t * 1.4) * (13.0 if crashed else (8.0 if afterburner_active else 5.0)) - float(puff) * (0.7 if crashed else 1.6) + _hover_offset * 0.18
		var radius := (10.0 + float(puff) * 5.0) * hover_pulse * boost_scale
		var alpha := maxf(0.08, (0.60 if crashed else (0.38 if afterburner_active else 0.30)) - float(puff) * (0.034 if crashed else 0.05))
		var smoke_color := Color(0.18, 0.18, 0.20, alpha).lerp(Color(0.095, 0.035, 0.17, alpha * 1.08), speed_heat)
		var smoke_lift := Color(0.34, 0.32, 0.30, alpha * 0.62).lerp(Color(0.26, 0.075, 0.36, alpha * 0.70), speed_heat)
		draw_circle(smoke_origin + Vector2(-back_offset, rise_offset), radius, smoke_color)
		draw_circle(smoke_origin + Vector2(-back_offset - 8.0, rise_offset + 2.0), radius * 0.72, smoke_lift)
		if crashed:
			draw_circle(smoke_origin + Vector2(-back_offset * 0.58, rise_offset + 1.0), radius * 0.32, Color(1.0, 0.32, 0.08, alpha * 0.22))
			draw_circle(smoke_origin + Vector2(-back_offset - 16.0, rise_offset - 8.0), radius * 0.58, Color(0.05, 0.05, 0.055, alpha * 0.38))
		elif afterburner_active:
			var flame_fade := clampf(1.0 - float(puff) / maxf(float(puff_total), 1.0), 0.0, 1.0)
			var flame_color := Color(1.0, 0.34, 0.08, alpha * 0.50 * flame_fade).lerp(Color(0.64, 0.18, 1.0, alpha * 0.45 * flame_fade), speed_heat)
			draw_circle(smoke_origin + Vector2(-back_offset * 0.62, rise_offset - 1.0), radius * 0.36, flame_color)
	if crashed:
		for cloud in range(10):
			var cloud_t := engine_time * 4.8 + float(cloud) * 0.73
			var center := Vector2(
				sin(cloud_t * 1.7) * 54.0 - float(cloud % 3) * 16.0,
				-12.0 + cos(cloud_t * 1.2) * 22.0 + float(cloud / 3) * 9.0
			)
			var cloud_radius := 24.0 + float(cloud % 4) * 8.0 + sin(cloud_t) * 4.0
			var cloud_alpha := 0.34 - float(cloud) * 0.018
			draw_circle(center, cloud_radius, Color(0.04, 0.04, 0.045, cloud_alpha))
			draw_circle(center + Vector2(-14.0, -5.0), cloud_radius * 0.62, Color(0.20, 0.20, 0.20, cloud_alpha * 0.72))
		for ember in range(6):
			var ember_t := engine_time * 8.0 + float(ember) * 1.1
			var ember_pos := Vector2(-38.0 + sin(ember_t) * 62.0, -8.0 + cos(ember_t * 0.8) * 28.0)
			draw_circle(ember_pos, 4.5 + sin(ember_t * 1.4) * 1.5, Color(1.0, 0.28, 0.06, 0.45))


func _draw_weapon_powerup_glow() -> void:
	if not weapon_glow_active or crashed or bike_sprite == null or bike_sprite.texture == null:
		return
	var texture_size := Vector2(float(bike_sprite.texture.get_width()), float(bike_sprite.texture.get_height()))
	var scaled_size := Vector2(texture_size.x * absf(bike_sprite.scale.x), texture_size.y * absf(bike_sprite.scale.y))
	if scaled_size.x <= 1.0 or scaled_size.y <= 1.0:
		return
	var pulse := 0.5 + sin(engine_time * 5.8) * 0.5
	var center := bike_sprite.position
	var core_alpha := 0.18 + pulse * 0.08
	var aura_alpha := 0.08 + pulse * 0.05
	var aura_color := Color(weapon_glow_color.r, weapon_glow_color.g, weapon_glow_color.b, aura_alpha)
	var core_color := Color(weapon_glow_color.r, weapon_glow_color.g, weapon_glow_color.b, core_alpha)
	for scale_mult in [1.14, 1.08]:
		var draw_size: Vector2 = scaled_size * float(scale_mult)
		draw_texture_rect(bike_sprite.texture, Rect2(center - draw_size * 0.5, draw_size), false, aura_color if scale_mult > 1.1 else core_color)
	_draw_local_ellipse(center + Vector2(-6.0, 4.0), Vector2(scaled_size.x * 0.40, scaled_size.y * 0.26), Color(weapon_glow_color.r, weapon_glow_color.g, weapon_glow_color.b, 0.055 + pulse * 0.035))


func _draw_hover_contact_shadow() -> void:
	var safe_jump_height := maxf(_active_jump_height, 1.0)
	var jump_ratio := clampf(jump_z / safe_jump_height, 0.0, 1.0)
	var scale_ratio := base_scale / maxf(_default_base_scale, 0.001)
	var center := Vector2(-7.0 + _input_x * 2.0, 32.0 + _hover_offset * 0.12)
	var shadow_alpha := lerpf(0.34, 0.11, jump_ratio)
	if crashed:
		shadow_alpha = 0.20
	var shadow_radius := Vector2(
		86.0 * scale_ratio * lerpf(1.0, 0.58, jump_ratio),
		12.0 * scale_ratio * lerpf(1.0, 0.76, jump_ratio)
	)
	_draw_local_ellipse(center, shadow_radius, Color(0.0, 0.0, 0.0, shadow_alpha))
	_draw_local_ellipse(center + Vector2(-18.0, 3.0), shadow_radius * Vector2(0.58, 0.46), Color(0.0, 0.0, 0.0, shadow_alpha * 0.34))
	var glow_alpha := 0.035 if not afterburner_active else 0.095
	_draw_local_ellipse(center + Vector2(-30.0, 1.0), shadow_radius * Vector2(0.72, 0.55), Color(1.0, 0.40, 0.10, glow_alpha))
	draw_line(center + Vector2(-58.0 * scale_ratio, -4.0), center + Vector2(60.0 * scale_ratio, -8.0), Color(0.0, 0.0, 0.0, shadow_alpha * 0.38), 4.0 * scale_ratio, true)


func _draw_local_ellipse(center: Vector2, radius: Vector2, color: Color, segments: int = 24) -> void:
	var point_count := maxi(segments, 8)
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
