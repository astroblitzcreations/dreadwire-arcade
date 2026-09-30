extends Area2D
class_name SpeedbikeDrone

const DRONE_TEXTURE_PATHS := {
	"interceptor": "res://assets/sprites/speedbike/enemies/speedbike_enemy_garthok.png",
	"rifle_flyer": "res://assets/sprites/speedbike/enemies/speedbike_enemy_khoudri.png",
	"dropper": "res://assets/sprites/speedbike/enemies/speedbike_enemy_beep.png",
	"oil_dropper": "res://assets/sprites/speedbike/enemies/speedbike_enemy_beep.png",
	"powerup": "res://assets/sprites/speedbike/enemies/speedbike_powerup_carrier.png",
	"sheet_interceptor": "res://assets/sprites/speedbike/enemies/speedbike_interceptor_drone.png",
	"sheet_dropper": "res://assets/sprites/speedbike/enemies/speedbike_dropper_drone.png",
	"sheet_powerup": "res://assets/sprites/speedbike/enemies/speedbike_powerup_carrier.png",
	"minizorg": "res://assets/sprites/speedbike/enemies/speedbike_boss_minizorg.png"
}
const DRONE_DISPLAY_SIZES := {
	"interceptor": Vector2(122.2, 80.6),
	"rifle_flyer": Vector2(132.6, 85.8),
	"dropper": Vector2(114.4, 96.2),
	"oil_dropper": Vector2(125.0, 105.0),
	"powerup": Vector2(114.4, 96.2),
	"sheet_interceptor": Vector2(122.2, 80.6),
	"sheet_dropper": Vector2(114.4, 96.2),
	"sheet_powerup": Vector2(114.4, 96.2),
	"minizorg": Vector2(150.8, 109.2)
}

var mode: Node
var payload: Dictionary = {}
var drone_type := "interceptor"
var lane := 2
var health := 1
var max_health := 1
var bob_phase := 0.0
var bob_speed := 2.0
var bob_amount := 12.0
var fired := false
var dropped := false
var shoot_timer := 0.0
var shoot_interval := 1.65
var score_value := 250
var destroyed := false
var reward_kind := ""
var shoot_cycle := 0
var display_size := Vector2(120.0, 56.0)
var drone_texture: Texture2D
var lateral_anchor_x := 0.0
var screen_hold_started := false
var screen_hold_timer := 0.0
var screen_hold_duration := 5.0
var screen_hold_x := 0.0
var screen_escape_active := false
var phase_shift_cooldown := 0.0
var phase_shift_timer := -1.0
var phase_shift_target_slot := -1
var phase_shift_applied := false
var oil_drop_timer := 2.0


func setup(row: Dictionary, mode_ref: Node) -> void:
	mode = mode_ref
	payload = row.duplicate(true)
	drone_type = str(row.get("enemy_type", row.get("drone_type", "interceptor")))
	lane = int(row.get("lane", 2))
	position = Vector2(float(row.get("x", 0.0)), float(row.get("y", 0.0)))
	lateral_anchor_x = position.x
	var default_health := _default_health_for_type()
	var authored_health := int(row.get("health", default_health))
	max_health = maxi(maxi(authored_health, default_health), 1)
	if mode != null and mode.has_method("speedbike_enemy_health_scale"):
		max_health = maxi(int(ceil(float(max_health) * float(mode.call("speedbike_enemy_health_scale")))), 1)
	health = max_health
	bob_phase = randf() * TAU
	bob_speed = float(row.get("bob_speed", _default_bob_speed_for_type()))
	bob_amount = float(row.get("bob_amount", _default_bob_amount_for_type()))
	shoot_interval = float(row.get("shoot_interval", _default_shoot_interval_for_type()))
	score_value = maxi(int(row.get("score_value", 250)), 0)
	reward_kind = str(row.get("reward_kind", ""))
	display_size = DRONE_DISPLAY_SIZES.get(drone_type, Vector2(120.0, 56.0))
	if drone_type == "minizorg":
		phase_shift_cooldown = randf_range(5.5, 11.5)
	screen_hold_started = false
	screen_hold_duration = float(row.get("screen_hold_time", 5.0))
	screen_hold_timer = screen_hold_duration
	screen_hold_x = 0.0
	screen_escape_active = false
	oil_drop_timer = float(row.get("drop_delay", 2.0))
	drone_texture = _load_drone_texture()
	queue_redraw()


func tick(delta: float, camera_left: float, scroll_speed: float = 0.0) -> void:
	if destroyed:
		return
	if drone_type == "minizorg":
		refresh_boss_minion_anchor(delta)
	else:
		_tick_screen_pace(delta, camera_left, scroll_speed)
		bob_phase += delta * bob_speed
		if drone_type == "oil_dropper" and mode != null and mode.has_method("speedbike_player_y"):
			var tracked_y: float = lerpf(float(payload.get("y", position.y)), float(mode.call("speedbike_player_y")) - 20.0, clampf(delta * 2.2, 0.0, 1.0))
			if mode.has_method("speedbike_top_bound") and mode.has_method("speedbike_bottom_bound"):
				tracked_y = clampf(tracked_y, float(mode.call("speedbike_top_bound")) + 10.0, float(mode.call("speedbike_bottom_bound")) - 8.0)
			payload["y"] = tracked_y
		position.y = float(payload.get("y", position.y)) + sin(bob_phase) * bob_amount
	if drone_type == "oil_dropper":
		oil_drop_timer -= delta
		if not dropped and oil_drop_timer <= 0.0:
			dropped = true
			if mode != null and mode.has_method("spawn_oil_spill"):
				mode.spawn_oil_spill(self)
		queue_redraw()
		return
	shoot_timer += delta
	var effective_shoot_interval := shoot_interval
	if mode != null and mode.has_method("speedbike_enemy_fire_interval_scale"):
		effective_shoot_interval = maxf(shoot_interval * float(mode.call("speedbike_enemy_fire_interval_scale")), 0.32)
	if drone_type in ["interceptor", "rifle_flyer", "sheet_interceptor"] and shoot_timer >= effective_shoot_interval and camera_left + 260.0 <= position.x:
		shoot_timer = 0.0
		shoot_cycle += 1
		_fire_standard_pattern()
	elif drone_type == "minizorg" and shoot_timer >= effective_shoot_interval and camera_left + 240.0 <= position.x:
		shoot_timer = 0.0
		shoot_cycle += 1
		_fire_minizorg_pattern()
	if drone_type in ["dropper", "sheet_dropper"] and not dropped and position.x < camera_left + 620.0:
		dropped = true
		if mode != null and mode.has_method("spawn_dropper_barrier"):
			mode.spawn_dropper_barrier(self)
	queue_redraw()


func _tick_screen_pace(delta: float, camera_left: float, scroll_speed: float) -> void:
	var view_width := 1280.0
	if mode != null and mode.has_method("speedbike_view_width"):
		view_width = maxf(float(mode.call("speedbike_view_width")), 640.0)
	var enter_x := camera_left + view_width - 148.0
	if not screen_hold_started and position.x <= enter_x:
		screen_hold_started = true
		screen_hold_x = clampf(position.x - camera_left, 220.0, view_width - 150.0)
		screen_hold_timer = screen_hold_duration
	if screen_hold_started and screen_hold_timer > 0.0:
		screen_hold_timer -= delta
		position.x = camera_left + screen_hold_x
		return
	if screen_hold_started:
		screen_escape_active = true
	if screen_escape_active:
		var zip_speed := maxf(scroll_speed * 1.22, 620.0)
		position.x += (scroll_speed - zip_speed) * delta


func is_finished(camera_left: float) -> bool:
	if drone_type == "minizorg":
		return destroyed
	return position.x < camera_left - 180.0 or destroyed


func refresh_boss_minion_anchor(delta: float = 0.0) -> void:
	if destroyed or drone_type != "minizorg":
		return
	bob_phase += delta * bob_speed
	_tick_minizorg_phase_shift(delta)
	if mode != null and mode.has_method("speedbike_boss_minion_anchor"):
		var anchor: Vector2 = mode.call("speedbike_boss_minion_anchor", int(payload.get("boss_slot", 0))) as Vector2
		lateral_anchor_x = anchor.x
		payload["y"] = anchor.y
	position.y = float(payload.get("y", position.y)) + sin(bob_phase) * bob_amount
	position.x = lateral_anchor_x + sin(bob_phase * 0.42) * 18.0
	queue_redraw()


func _tick_minizorg_phase_shift(delta: float) -> void:
	if delta <= 0.0:
		return
	if phase_shift_timer >= 0.0:
		phase_shift_timer -= delta
		var progress := clampf(1.0 - phase_shift_timer / 0.64, 0.0, 1.0)
		if not phase_shift_applied and progress >= 0.5:
			payload["boss_slot"] = phase_shift_target_slot
			phase_shift_applied = true
		var fade = abs(progress * 2.0 - 1.0)
		modulate.a = clampf(fade, 0.12, 1.0)
		if phase_shift_timer <= 0.0:
			phase_shift_timer = -1.0
			phase_shift_target_slot = -1
			phase_shift_applied = false
			phase_shift_cooldown = randf_range(8.0, 16.0)
			modulate.a = 1.0
		return
	phase_shift_cooldown -= delta
	if phase_shift_cooldown > 0.0:
		return
	if randf() > 0.35:
		phase_shift_cooldown = randf_range(5.5, 10.0)
		return
	var slot_count := 8
	if mode != null and mode.has_method("speedbike_boss_minion_slot_count"):
		slot_count = maxi(int(mode.call("speedbike_boss_minion_slot_count")), 1)
	var current_slot := int(payload.get("boss_slot", 0))
	phase_shift_target_slot = current_slot
	if slot_count > 1:
		var attempts := 0
		while phase_shift_target_slot == current_slot and attempts < 8:
			phase_shift_target_slot = randi_range(0, slot_count - 1)
			attempts += 1
	phase_shift_timer = 0.64
	phase_shift_applied = false


func hurtbox_rect() -> Rect2:
	var hurtbox_scale := 0.72 if drone_type == "minizorg" else 0.74
	var size := display_size * hurtbox_scale
	return Rect2(position.x - size.x * 0.5, position.y - size.y * 0.5, size.x, size.y)


func player_hit(player_rect: Rect2) -> bool:
	return not destroyed and hurtbox_rect().intersects(player_rect)


func hit_by_projectile(projectile_rect: Rect2) -> bool:
	if destroyed or not hurtbox_rect().intersects(projectile_rect):
		return false
	health -= 1
	if health <= 0:
		destroyed = true 
	return true


func _draw() -> void:
	if destroyed:
		return
	if drone_texture != null:
		var shadow_alpha := 0.24 if drone_type == "minizorg" else 0.18
		_draw_local_ellipse(Vector2(0.0, display_size.y * 0.36), Vector2(display_size.x * 0.30, 10.0 if drone_type == "minizorg" else 7.0), Color(0.0, 0.0, 0.0, shadow_alpha))
		if drone_type in ["interceptor", "rifle_flyer", "sheet_interceptor", "minizorg", "oil_dropper"]:
			draw_line(Vector2(display_size.x * 0.30, display_size.y * 0.05), Vector2(display_size.x * 0.58, display_size.y * 0.05), Color(0.64, 0.42, 1.0, 0.16), 9.0, true)
			draw_line(Vector2(display_size.x * 0.22, display_size.y * 0.12), Vector2(display_size.x * 0.48, display_size.y * 0.14), Color(0.10, 0.08, 0.12, 0.18), 13.0, true)
		var draw_rect := Rect2(-display_size * 0.5, display_size)
		draw_texture_rect(drone_texture, draw_rect, false, Color(0.96, 0.94, 0.88, 1.0))
		if drone_type == "minizorg":
			draw_circle(Vector2(-display_size.x * 0.26, display_size.y * 0.10), 7.0, Color(0.92, 0.24, 0.20, 0.88))
			draw_circle(Vector2(-display_size.x * 0.12, display_size.y * 0.08), 5.0, Color(0.84, 0.18, 0.16, 0.82))
			draw_line(Vector2(display_size.x * 0.22, 0.0), Vector2(display_size.x * 0.44, -2.0), Color(0.78, 0.34, 1.0, 0.78), 3.0, true)
		elif drone_type in ["dropper", "sheet_dropper"]:
			draw_circle(Vector2(0.0, display_size.y * 0.18), 6.0, Color(1.0, 0.22, 0.20, 0.82))
		elif drone_type == "oil_dropper":
			var pulse := 0.55 + sin(bob_phase * 2.2) * 0.22
			draw_circle(Vector2(0.0, display_size.y * 0.18), 8.0, Color(0.08, 0.05, 0.03, 0.90))
			draw_rect(Rect2(-18.0, display_size.y * 0.22, 36.0, 15.0), Color(0.02, 0.02, 0.02, 0.80), true)
			draw_circle(Vector2(0.0, display_size.y * 0.34), 5.0 + pulse * 2.0, Color(0.32, 0.84, 0.44, 0.56))
		_draw_health_bar()
		return
	var core := Color(0.28, 0.30, 0.34, 0.96)
	var light := Color(1.0, 0.54, 0.18, 0.92)
	if drone_type in ["dropper", "sheet_dropper"]:
		light = Color(1.0, 0.28, 0.22, 0.92)
	elif drone_type == "powerup":
		light = Color(0.42, 1.0, 0.56, 0.88)
	var body := PackedVector2Array([
		Vector2(-48.0, -12.0),
		Vector2(-18.0, -24.0),
		Vector2(26.0, -20.0),
		Vector2(54.0, 0.0),
		Vector2(18.0, 18.0),
		Vector2(-34.0, 16.0)
	])
	draw_colored_polygon(body, core)
	draw_polyline(body + PackedVector2Array([body[0]]), Color(0.08, 0.08, 0.10, 0.58), 2.0, true)
	draw_circle(Vector2(22.0, -2.0), 8.0, light)
	draw_circle(Vector2(-18.0, -6.0), 4.0, Color(0.82, 0.88, 0.94, 0.72))
	draw_line(Vector2(-48.0, 0.0), Vector2(-78.0, 0.0), Color(0.82, 0.48, 0.16, 0.72), 5.0, true)
	draw_line(Vector2(-52.0, 0.0), Vector2(-102.0, 0.0), Color(0.22, 0.22, 0.24, 0.36), 12.0, true)
	if drone_type == "dropper":
		draw_rect(Rect2(-14.0, 18.0, 28.0, 18.0), Color(0.30, 0.30, 0.32, 0.92), true)
		draw_rect(Rect2(-12.0, 20.0, 24.0, 6.0), Color(0.98, 0.68, 0.24, 0.86), true)
	_draw_health_bar()


func _draw_health_bar() -> void:
	if max_health <= 1:
		return
	var ratio := clampf(float(health) / maxf(float(max_health), 1.0), 0.0, 1.0)
	var bar_width := clampf(display_size.x * 0.72, 58.0, 128.0)
	var bar_pos := Vector2(-bar_width * 0.5, -display_size.y * 0.5 - 14.0)
	var fill_color := Color(1.0, 0.22, 0.12, 0.96).lerp(Color(0.30, 1.0, 0.42, 0.96), ratio)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 6.0)), Color(0.02, 0.02, 0.025, 0.78), true)
	draw_rect(Rect2(bar_pos + Vector2(1.0, 1.0), Vector2((bar_width - 2.0) * ratio, 4.0)), fill_color, true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 6.0)), Color(1.0, 0.86, 0.46, 0.36), false, 1.0)


func _draw_local_ellipse(center: Vector2, radius: Vector2, color: Color, segments: int = 20) -> void:
	var point_count := maxi(segments, 8)
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _load_drone_texture() -> Texture2D:
	var path := str(DRONE_TEXTURE_PATHS.get(drone_type, ""))
	if path.is_empty():
		return null
	if mode != null and mode.has_method("_load_texture"):
		var texture = mode.call("_load_texture", path)
		if texture is Texture2D:
			return texture as Texture2D
	var fallback := load(path)
	if fallback is Texture2D:
		return fallback as Texture2D
	return null


func _default_health_for_type() -> int:
	match drone_type:
		"interceptor":
			return 7
		"dropper":
			return 4
		"sheet_dropper":
			return 4
		"oil_dropper":
			return 5
		"rifle_flyer":
			return 8
		"sheet_interceptor":
			return 5
		"powerup", "sheet_powerup":
			return 2
		"minizorg":
			return 18
		_:
			return 3


func _default_bob_speed_for_type() -> float:
	return 2.8 if drone_type == "minizorg" else 2.0


func _default_bob_amount_for_type() -> float:
	match drone_type:
		"dropper":
			return 10.0
		"sheet_dropper":
			return 10.0
		"oil_dropper":
			return 16.0
		"minizorg":
			return 18.0
		_:
			return 12.0


func _default_shoot_interval_for_type() -> float:
	match drone_type:
		"rifle_flyer":
			return 1.35
		"minizorg":
			return 1.05
		_:
			return 1.65


func _fire_standard_pattern() -> void:
	if mode == null or not mode.has_method("spawn_enemy_bullet"):
		return
	var origin := position + Vector2(-display_size.x * 0.42, 0.0)
	var aim := Vector2.LEFT
	if mode.has_method("speedbike_player_midpoint"):
		var target := mode.call("speedbike_player_midpoint") as Vector2
		var delta := target - origin
		if delta.length_squared() > 1.0:
			aim = delta.normalized()
	if drone_type == "rifle_flyer":
		for spread in [-0.08, 0.08]:
			mode.call("spawn_enemy_bullet", origin, aim.rotated(spread), 640.0, 9.0, "bullet")
		if shoot_cycle % 3 == 0 and mode.has_method("spawn_enemy_powerup_shot"):
			mode.call("spawn_enemy_powerup_shot", origin + Vector2(-10.0, 12.0), aim.rotated(randf_range(-0.12, 0.12)), 430.0, _random_hazard_powerup_kind())
		return
	mode.call("spawn_enemy_bullet", origin, aim, 620.0, 9.0, "bullet")
	if drone_type == "interceptor" and shoot_cycle % 3 == 0 and mode.has_method("spawn_enemy_powerup_shot"):
		mode.call("spawn_enemy_powerup_shot", origin + Vector2(-10.0, 12.0), aim.rotated(randf_range(-0.16, 0.16)), 420.0, _random_hazard_powerup_kind())


func _random_hazard_powerup_kind() -> String:
	var kinds := ["rapid", "machine", "spread", "laser", "rocket", "fireball", "gold", "purple"]
	return str(kinds[randi() % kinds.size()])


func _fire_minizorg_pattern() -> void:
	if mode == null or not mode.has_method("spawn_enemy_bullet"):
		return
	var origin := position + Vector2(-display_size.x * 0.42, 0.0)
	var target := origin + Vector2(-120.0, 0.0)
	if mode.has_method("speedbike_player_midpoint"):
		target = mode.call("speedbike_player_midpoint") as Vector2
	var aim := (target - origin).normalized()
	if aim.length_squared() <= 0.1:
		aim = Vector2.LEFT
	var bullet_speed := 560.0
	var missile_speed := 430.0
	if mode.has_method("speedbike_boss_bullet_speed"):
		bullet_speed = float(mode.call("speedbike_boss_bullet_speed", bullet_speed))
		missile_speed = float(mode.call("speedbike_boss_bullet_speed", missile_speed))
	for spread in [-0.12, 0.0, 0.12]:
		mode.call("spawn_enemy_bullet", origin, aim.rotated(spread), bullet_speed, 10.0, "boss_bullet", true)
	var boss_phase := ""
	if mode.has_method("speedbike_boss_damage_phase"):
		boss_phase = str(mode.call("speedbike_boss_damage_phase"))
	if boss_phase == "dome" and shoot_cycle % 2 == 0 and mode.has_method("spawn_enemy_homing_missile"):
		mode.call("spawn_enemy_homing_missile", origin + Vector2(-12.0, 8.0), missile_speed, true)
