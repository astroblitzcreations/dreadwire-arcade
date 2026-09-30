extends Area2D
class_name SpeedbikeObstacle

const OBSTACLE_TEXTURE_PATHS := {
	"full_wall_block": "res://assets/sprites/speedbike/obstacles/full_wall_block.png",
	"top_block": "res://assets/sprites/speedbike/obstacles/top_block.png",
	"bottom_block": "res://assets/sprites/speedbike/obstacles/bottom_block.png",
	"center_block": "res://assets/sprites/speedbike/obstacles/center_block.png",
	"slit_wall_center_gap": "res://assets/sprites/speedbike/obstacles/slit_wall_center_gap.png",
	"vertical_slice": "res://assets/sprites/speedbike/obstacles/vertical_slice.png",
	"low_barricade": "res://assets/sprites/speedbike/obstacles/low_barricade.png",
	"destructible_wall": "res://assets/sprites/speedbike/obstacles/destructible_wall.png",
	"pit_small": "res://assets/sprites/speedbike/obstacles/pit_small.png",
	"pit_large": "res://assets/sprites/speedbike/obstacles/pit_large.png",
	"ramp_normal": "res://assets/sprites/speedbike/obstacles/ramp_normal.png",
	"ramp_triple_boost": "res://assets/sprites/speedbike/obstacles/ramp_triple_boost.png",
	"laser_gate_active": "res://assets/sprites/speedbike/obstacles/laser_gate_active.png",
	"laser_gate_emitter_off": "res://assets/sprites/speedbike/obstacles/laser_gate_emitter_off.png",
	"laser_gate_warning": "res://assets/sprites/speedbike/obstacles/laser_gate_warning.png",
	"moving_gate": "res://assets/sprites/speedbike/obstacles/moving_gate.png",
	"mine": "res://assets/sprites/speedbike/obstacles/mine.png",
	"oil_spill": "res://assets/sprites/speedbike/obstacles/oil_spill.png"
}

var mode: Node
var payload: Dictionary = {}
var obstacle_type := ""
var shape := ""
var required_jump_height := 0.0
var kill_on_touch := true
var warning_time := 0.48
var active_time := 0.72
var cooldown_time := 0.42
var move_axis := "vertical"
var move_range := 74.0
var move_speed := 2.1
var elapsed := 0.0
var scored := false
var near_miss_awarded := false
var destroyed := false
var destructible := false
var destructible_hits_remaining := 0
var destructible_hits_max := 0
var damage_flash_timer := 0.0
var score_value := 100
var base_rects: Array[Rect2] = []
var ramp_triggered := false
var pit_clear_locked := false
var ramp_assist := false
var ramp_big_jump := false
var oil_spinout_triggered := false
var obstacle_texture_path := ""
var obstacle_texture: Texture2D


func setup(row: Dictionary, mode_ref: Node) -> void:
	mode = mode_ref
	payload = row.duplicate(true)
	obstacle_type = str(row.get("kind", "block"))
	shape = str(row.get("shape", obstacle_type))
	required_jump_height = float(row.get("required_jump_height", 46.0 if obstacle_type == "pit" else 34.0))
	kill_on_touch = bool(row.get("kill_on_touch", true))
	warning_time = float(row.get("warning_time", warning_time))
	active_time = float(row.get("active_time", active_time))
	cooldown_time = float(row.get("cooldown_time", cooldown_time))
	move_axis = str(row.get("move_axis", move_axis))
	move_range = float(row.get("move_range", move_range))
	move_speed = float(row.get("move_speed", move_speed))
	destructible = bool(row.get("destructible", obstacle_type == "mine"))
	destructible_hits_max = maxi(int(row.get("destructible_hits", 1)), 1)
	destructible_hits_remaining = destructible_hits_max
	score_value = maxi(int(row.get("score_value", 100)), 0)
	position = Vector2.ZERO
	ramp_triggered = false
	pit_clear_locked = false
	ramp_assist = bool(row.get("ramp_assist", false))
	ramp_big_jump = bool(row.get("big_jump", false))
	oil_spinout_triggered = false
	damage_flash_timer = 0.0
	obstacle_texture_path = ""
	obstacle_texture = null
	base_rects.clear()
	var rect_rows: Variant = row.get("rects", [])
	if rect_rows is Array:
		for rect_value in rect_rows:
			if rect_value is Dictionary:
				base_rects.append(Rect2(
					float(rect_value.get("x", 0.0)),
					float(rect_value.get("y", 0.0)),
					float(rect_value.get("w", 0.0)),
					float(rect_value.get("h", 0.0))
				))
	obstacle_texture_path = _obstacle_texture_path()
	obstacle_texture = _load_obstacle_texture(obstacle_texture_path)
	queue_redraw()


func tick(delta: float) -> void:
	if destroyed:
		return
	elapsed += delta
	damage_flash_timer = maxf(damage_flash_timer - delta, 0.0)
	queue_redraw()


func is_finished(camera_left: float, screen_width: float) -> bool:
	if destroyed:
		return true
	return trailing_x() < camera_left - 160.0


func is_active() -> bool:
	if obstacle_type != "laser_gate":
		return true
	var cycle := warning_time + active_time + cooldown_time
	if cycle <= 0.01:
		return true
	var phase := fposmod(elapsed, cycle)
	return phase >= warning_time and phase < warning_time + active_time


func is_warning() -> bool:
	if obstacle_type != "laser_gate":
		return false
	var cycle := warning_time + active_time + cooldown_time
	if cycle <= 0.01:
		return false
	return fposmod(elapsed, cycle) < warning_time


func _current_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var offset := Vector2.ZERO
	if obstacle_type == "moving_gate":
		var wave := sin(elapsed * move_speed) * move_range
		offset = Vector2(0.0, wave) if move_axis == "vertical" else Vector2(wave, 0.0)
	for rect in base_rects:
		rects.append(Rect2(rect.position + offset, rect.size))
	return rects


func collides_with_rect(world_rect: Rect2) -> bool:
	if destroyed:
		return false
	if obstacle_type == "laser_gate" and not is_active():
		return false
	for rect in _current_rects():
		if rect.intersects(world_rect):
			return true
	return false


func hit_report(player_rect: Rect2, jump_z: float) -> Dictionary:
	if destroyed:
		return {"hit": false}
	var rects := _current_rects()
	if obstacle_type == "oil_spill":
		for rect in rects:
			if rect.intersects(player_rect) and jump_z < 22.0 and not oil_spinout_triggered:
				oil_spinout_triggered = true
				return {"hit": false, "spinout": true}
		return {"hit": false}
	if obstacle_type == "ramp":
		for rect in rects:
			if rect.intersects(player_rect) and jump_z <= 2.0 and not ramp_triggered:
				ramp_triggered = true
				return {"hit": false, "launch": true, "big_jump": ramp_big_jump}
		return {"hit": false}
	if obstacle_type == "pit":
		for rect in rects:
			var edge_margin := minf(28.0, rect.size.x * 0.24)
			var inner_left := rect.position.x + edge_margin
			var inner_right := rect.position.x + rect.size.x - edge_margin
			var clearance_x := player_rect.position.x + player_rect.size.x * 0.50
			var clearance_inside := clearance_x > inner_left and clearance_x < inner_right
			var assist_height := required_jump_height * 0.60 if ramp_assist else required_jump_height
			var lock_height := assist_height * (0.56 if ramp_assist else 0.52)
			var fail_height := assist_height * 0.24
			if clearance_inside:
				if jump_z >= lock_height:
					pit_clear_locked = true
				elif jump_z <= fail_height and not pit_clear_locked:
					return {"hit": true, "jump_fail": true}
			elif clearance_x > inner_right:
				pit_clear_locked = false
		return {"hit": false}
	if obstacle_type == "laser_gate" and not is_active():
		return {"hit": false}
	for rect in rects:
		if rect.intersects(player_rect):
			if obstacle_type == "block" and shape == "center" and jump_z >= 42.0:
				continue
			if obstacle_type == "block" and shape == "vertical_slice" and jump_z >= 48.0:
				continue
			if obstacle_type == "low_barricade" and jump_z >= required_jump_height:
				continue
			return {"hit": true, "jump_fail": obstacle_type == "low_barricade"}
	return {"hit": false}


func hit_by_projectile(projectile_rect: Rect2, projectile_kind: String = "normal", projectile_damage: int = 1) -> bool:
	if destroyed or not destructible:
		return false
	for rect in _current_rects():
		var weakspot_rect := _weakspot_rect_for(rect)
		if weakspot_rect.intersects(projectile_rect):
			destructible_hits_remaining = maxi(destructible_hits_remaining - maxi(projectile_damage, 1), 0)
			damage_flash_timer = 0.12
			if destructible_hits_remaining <= 0:
				destroyed = true
			queue_redraw()
			return true
	return false


func near_miss_ready(player_rect: Rect2) -> bool:
	if near_miss_awarded or destroyed:
		return false
	if obstacle_type in ["pit", "moving_gate", "ramp", "oil_spill"]:
		return false
	for rect in _current_rects():
		if rect.intersects(player_rect.grow(14.0)) and not rect.intersects(player_rect):
			return true
	return false


func mark_near_miss_awarded() -> void:
	near_miss_awarded = true


func _draw_textured_obstacle(rects: Array[Rect2]) -> bool:
	if rects.is_empty():
		return false
	if obstacle_type in ["block", "moving_gate"] and shape in ["center_gap", "top_bottom_gap", "moving_gap", "moving_slit"]:
		return _draw_split_gap_textures(rects)
	var texture := _current_obstacle_texture()
	if texture == null:
		return false
	match obstacle_type:
		"pit":
			for rect in rects:
				draw_rect(rect, Color(0.008, 0.007, 0.008, 1.0), true)
				_draw_tiled_pit_texture(texture, rect, Color(1.0, 1.0, 1.0, 1.0))
				draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), Color(1.0, 0.54, 0.12, 0.32), 4.0, true)
				draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + rect.size, Color(1.0, 0.36, 0.08, 0.20), 5.0, true)
			return true
		"ramp":
			for rect in rects:
				draw_rect(Rect2(rect.position.x - 14.0, rect.end.y + 1.0, rect.size.x + 28.0, 9.0), Color(0.0, 0.0, 0.0, 0.30), true)
				var ramp_rect := Rect2(rect.position.x - 6.0, rect.position.y, rect.size.x + 12.0, rect.size.y)
				if ramp_big_jump:
					draw_rect(ramp_rect.grow(8.0), Color(0.16, 0.70, 1.0, 0.14), false, 3.0)
				draw_texture_rect(texture, ramp_rect, false, Color(1.0, 1.0, 1.0, 1.0))
			return true
		"laser_gate":
			var tint := Color(1.0, 1.0, 1.0, 1.0)
			if is_warning():
				tint = Color(1.0, 0.88, 0.48, 0.92)
			elif not is_active():
				tint = Color(0.72, 0.82, 0.92, 0.70)
			for rect in rects:
				var laser_rect := Rect2(rect.position.x, rect.get_center().y - 22.0, rect.size.x, 44.0)
				var glow_color := Color(1.0, 0.18, 0.12, 0.18) if is_active() else Color(0.32, 0.76, 1.0, 0.10)
				draw_rect(laser_rect.grow(14.0), glow_color, true)
				draw_texture_rect(texture, laser_rect, false, tint)
				if is_warning():
					draw_rect(laser_rect.grow(10.0), Color(1.0, 0.82, 0.28, 0.13), false, 2.0)
			return true
		"mine":
			for rect in rects:
				var draw_rect := _fit_texture_to_rect(texture, rect.grow(8.0), true)
				_draw_sprite_shadow(draw_rect, 0.26, Vector2(6.0, 8.0))
				draw_circle(draw_rect.get_center(), minf(draw_rect.size.x, draw_rect.size.y) * 0.55, Color(1.0, 0.18, 0.10, 0.13))
				draw_texture_rect(texture, draw_rect, false, Color(1.0, 1.0, 1.0, 1.0))
			return true
		"low_barricade":
			var damage_ratio := float(destructible_hits_remaining) / maxf(float(destructible_hits_max), 1.0)
			var tint := Color(1.0, 1.0, 1.0, 1.0)
			if damage_flash_timer > 0.0:
				tint = Color(1.0, 0.74, 0.46, 1.0)
			for rect in rects:
				var draw_rect := rect.grow_individual(6.0, 6.0, 6.0, 4.0)
				_draw_sprite_shadow(draw_rect, 0.30, Vector2(7.0, 7.0))
				draw_texture_rect(texture, draw_rect, false, tint)
				if destructible:
					_draw_weakspot(rect, damage_ratio)
			return true
		_:
			var damage_ratio := float(destructible_hits_remaining) / maxf(float(destructible_hits_max), 1.0)
			var tint := Color(1.0, 1.0, 1.0, 1.0)
			if damage_flash_timer > 0.0:
				tint = Color(1.0, 0.68, 0.42, 1.0)
			for rect in rects:
				_draw_sprite_shadow(rect, 0.34, Vector2(8.0, 7.0))
				if destructible:
					draw_rect(rect.grow(8.0), Color(1.0, 0.30, 0.14, 0.12), false, 3.0)
				elif shape == "vertical_slice":
					draw_rect(rect.grow(6.0), Color(1.0, 0.50, 0.18, 0.11), false, 2.0)
				_draw_texture_rect_or_flipped(texture, rect, tint, shape == "vertical_slice")
				if destructible:
					_draw_weakspot(rect, damage_ratio)
			return true


func _draw_split_gap_textures(rects: Array[Rect2]) -> bool:
	var drew_any := false
	var combined := _combined_rect(rects)
	for rect in rects:
		var path := _gap_piece_texture_path(rect, combined)
		var texture := _load_obstacle_texture(path)
		if texture == null:
			continue
		var tint := Color(1.0, 1.0, 1.0, 1.0)
		if damage_flash_timer > 0.0:
			tint = Color(1.0, 0.68, 0.42, 1.0)
		_draw_sprite_shadow(rect, 0.32, Vector2(8.0, 7.0))
		draw_texture_rect(texture, rect, false, tint)
		_draw_gap_piece_edge_light(rect, combined)
		if destructible:
			var damage_ratio := float(destructible_hits_remaining) / maxf(float(destructible_hits_max), 1.0)
			_draw_weakspot(rect, damage_ratio)
		drew_any = true
	return drew_any


func _gap_piece_texture_path(rect: Rect2, combined: Rect2) -> String:
	var key := "top_block" if rect.get_center().y < combined.get_center().y else "bottom_block"
	return str(OBSTACLE_TEXTURE_PATHS.get(key, ""))


func _draw_sprite_shadow(rect: Rect2, strength: float = 0.30, offset: Vector2 = Vector2(7.0, 7.0)) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var shadow := Rect2(rect.position + offset, rect.size)
	draw_rect(shadow, Color(0.0, 0.0, 0.0, strength), true)
	draw_rect(shadow.grow(-minf(rect.size.x, rect.size.y) * 0.10), Color(0.0, 0.0, 0.0, strength * 0.26), true)


func _draw_gap_piece_edge_light(rect: Rect2, combined: Rect2) -> void:
	var is_top := rect.get_center().y < combined.get_center().y
	var y := rect.end.y if is_top else rect.position.y
	draw_line(Vector2(rect.position.x + 6.0, y), Vector2(rect.end.x - 6.0, y), Color(0.34, 0.82, 1.0, 0.28), 3.0, true)
	draw_line(Vector2(rect.position.x + 10.0, y + (-5.0 if is_top else 5.0)), Vector2(rect.end.x - 10.0, y + (-5.0 if is_top else 5.0)), Color(0.0, 0.0, 0.0, 0.24), 2.0, true)


func _draw_texture_rect_or_flipped(texture: Texture2D, rect: Rect2, tint: Color, flip_h: bool = false) -> void:
	if texture == null:
		return
	if not flip_h:
		draw_texture_rect(texture, rect, false, tint)
		return
	draw_set_transform(Vector2(rect.position.x + rect.size.x, rect.position.y), 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(texture, Rect2(Vector2.ZERO, rect.size), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_tiled_pit_texture(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
		return
	var pit_rect := _pit_texture_rect(texture, rect)
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	var tile_width := pit_rect.size.y * texture_size.x / maxf(texture_size.y, 1.0)
	if pit_rect.size.x <= tile_width * 1.08:
		var fitted := _fit_texture_to_rect(texture, pit_rect, true)
		draw_texture_rect(texture, fitted, false, tint)
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


func preview_texture_entries(right_edge: float) -> Array:
	var entries: Array = []
	var rects := preview_rects(right_edge)
	if rects.is_empty():
		return entries
	if obstacle_type in ["block", "moving_gate"] and shape in ["center_gap", "top_bottom_gap", "moving_gap", "moving_slit"]:
		var combined := _combined_rect(rects)
		for rect in rects:
			entries.append({
				"path": _gap_piece_texture_path(rect, combined),
				"rect": rect,
				"flip_h": false,
				"tile_pit": false
			})
		return entries
	var path := _obstacle_texture_path()
	if path.is_empty():
		return entries
	for rect in rects:
		entries.append({
			"path": path,
			"rect": rect,
			"flip_h": shape == "vertical_slice",
			"tile_pit": obstacle_type == "pit"
		})
	return entries


func _current_obstacle_texture() -> Texture2D:
	var path := _obstacle_texture_path()
	if path.is_empty():
		return null
	if path != obstacle_texture_path or obstacle_texture == null:
		obstacle_texture_path = path
		obstacle_texture = _load_obstacle_texture(path)
	return obstacle_texture


func _obstacle_texture_path() -> String:
	var key := ""
	match obstacle_type:
		"ramp":
			key = "ramp_triple_boost" if ramp_big_jump or int(payload.get("ramp_count", 1)) > 1 else "ramp_normal"
		"oil_spill":
			key = "oil_spill"
		"mine":
			key = "mine"
		"pit":
			key = ""
		"laser_gate":
			if is_active():
				key = "laser_gate_active"
			elif is_warning():
				key = "laser_gate_warning"
			else:
				key = "laser_gate_emitter_off"
		"low_barricade":
			key = "low_barricade"
		"moving_gate":
			key = "slit_wall_center_gap" if shape in ["moving_gap", "moving_slit", "center_gap", "top_bottom_gap"] else "moving_gate"
		_:
			if destructible:
				key = "destructible_wall"
			else:
				match shape:
					"top":
						key = "top_block"
					"bottom":
						key = "bottom_block"
					"center":
						key = "center_block"
					"center_gap", "top_bottom_gap":
						key = "slit_wall_center_gap"
					"vertical_slice":
						key = "vertical_slice"
					_:
						key = "full_wall_block"
	return str(OBSTACLE_TEXTURE_PATHS.get(key, ""))


func _load_obstacle_texture(path: String) -> Texture2D:
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


func _combined_rect(rects: Array[Rect2]) -> Rect2:
	if rects.is_empty():
		return Rect2()
	var combined := rects[0]
	for index in range(1, rects.size()):
		combined = combined.merge(rects[index])
	return combined


func _fit_texture_to_rect(texture: Texture2D, target: Rect2, preserve_aspect: bool = true) -> Rect2:
	if texture == null or not preserve_aspect:
		return target
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or target.size.x <= 0.0 or target.size.y <= 0.0:
		return target
	var scale := minf(target.size.x / texture_size.x, target.size.y / texture_size.y)
	var draw_size := texture_size * scale
	return Rect2(target.get_center() - draw_size * 0.5, draw_size)


func _pit_texture_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	if texture == null or texture.get_width() <= 0:
		return rect
	var aspect := float(texture.get_height()) / maxf(float(texture.get_width()), 1.0)
	var draw_height := clampf(rect.size.x * aspect, 54.0, minf(rect.size.y * 0.72, 116.0))
	return Rect2(rect.position.x, rect.get_center().y - draw_height * 0.5, rect.size.x, draw_height)


func _draw() -> void:
	if destroyed:
		return
	var rects := _current_rects()
	if _draw_textured_obstacle(rects):
		return
	match obstacle_type:
		"ramp":
			for rect in rects:
				var base_y := rect.position.y + rect.size.y
				var left_x := rect.position.x
				var right_x := rect.position.x + rect.size.x
				var ramp_count := maxi(int(payload.get("ramp_count", 1)), 1)
				var plate_h := minf(rect.size.y * (0.56 if ramp_big_jump else 0.50), 58.0 if ramp_big_jump else 42.0)
				var lip_h := minf(rect.size.y * 0.28, 24.0)
				var segment_gap := 7.0 if ramp_count > 1 else 0.0
				var segment_width := (rect.size.x - segment_gap * float(ramp_count - 1)) / float(ramp_count)
				draw_rect(Rect2(left_x - 18.0, base_y + 1.0, rect.size.x + 42.0, 8.0), Color(0.0, 0.0, 0.0, 0.34), true)
				draw_rect(Rect2(left_x - 12.0, base_y - lip_h, rect.size.x + 28.0, lip_h + 8.0), Color(0.045, 0.045, 0.05, 0.62), true)
				if ramp_big_jump:
					draw_rect(Rect2(left_x - 14.0, base_y - lip_h - 8.0, rect.size.x + 30.0, 8.0), Color(0.18, 0.42, 0.62, 0.46), true)
				for segment in range(ramp_count):
					var sx := left_x + float(segment) * (segment_width + segment_gap)
					var ex := sx + segment_width
					var top_y := base_y - plate_h - (8.0 if ramp_big_jump and segment == ramp_count - 1 else 0.0)
					var ramp_poly := PackedVector2Array([
						Vector2(sx, base_y),
						Vector2(sx + segment_width * 0.18, base_y),
						Vector2(ex - 12.0, top_y),
						Vector2(ex, base_y)
					])
					draw_colored_polygon(ramp_poly, Color(0.34, 0.32, 0.28, 0.98))
					draw_colored_polygon(PackedVector2Array([
						Vector2(sx + segment_width * 0.18, base_y),
						Vector2(ex - 12.0, top_y),
						Vector2(ex, base_y)
					]), Color(0.16, 0.15, 0.14, 0.84))
					draw_polyline(PackedVector2Array([ramp_poly[0], ramp_poly[1], ramp_poly[2], ramp_poly[3], ramp_poly[0]]), Color(0.03, 0.03, 0.035, 0.78), 4.0, true)
					for stripe in range(4):
						var t := float(stripe) / 4.0
						var stripe_x := lerpf(sx + 18.0, ex - 36.0, t)
						draw_line(Vector2(stripe_x, base_y - 5.0), Vector2(stripe_x + 22.0, top_y + 8.0), Color(1.0, 0.64, 0.12, 0.90), 5.0, true)
						draw_line(Vector2(stripe_x + 11.0, base_y - 5.0), Vector2(stripe_x + 33.0, top_y + 8.0), Color(0.035, 0.035, 0.04, 0.78), 4.0, true)
					draw_line(Vector2(sx + 10.0, base_y - 4.0), Vector2(ex - 16.0, top_y + 2.0), Color(1.0, 0.86, 0.34, 0.92), 4.0, true)
					draw_circle(Vector2(sx + 18.0, base_y - lip_h * 0.42), 3.5, Color(0.02, 0.02, 0.025, 0.70))
					draw_circle(Vector2(ex - 18.0, top_y + lip_h * 0.22), 3.5, Color(0.02, 0.02, 0.025, 0.70))
					if ramp_big_jump:
						var arrow_y := top_y + plate_h * 0.45
						draw_line(Vector2(sx + segment_width * 0.30, arrow_y), Vector2(ex - segment_width * 0.22, arrow_y - 16.0), Color(0.42, 0.86, 1.0, 0.84), 5.0, true)
						draw_line(Vector2(ex - segment_width * 0.22, arrow_y - 16.0), Vector2(ex - segment_width * 0.36, arrow_y - 4.0), Color(0.42, 0.86, 1.0, 0.84), 4.0, true)
						draw_line(Vector2(ex - segment_width * 0.22, arrow_y - 16.0), Vector2(ex - segment_width * 0.34, arrow_y - 30.0), Color(0.42, 0.86, 1.0, 0.84), 4.0, true)
		"oil_spill":
			for rect in rects:
				var center := rect.get_center()
				var radius := Vector2(rect.size.x * 0.47, rect.size.y * 0.34)
				_draw_ellipse(center + Vector2(5.0, 6.0), radius * 1.06, Color(0.0, 0.0, 0.0, 0.22))
				_draw_ellipse(center, radius, Color(0.015, 0.019, 0.020, 0.88))
				_draw_ellipse(center + Vector2(rect.size.x * 0.14, -3.0), radius * Vector2(0.66, 0.50), Color(0.028, 0.052, 0.050, 0.76))
				_draw_ellipse(center + Vector2(-rect.size.x * 0.18, 2.0), radius * Vector2(0.42, 0.35), Color(0.08, 0.035, 0.12, 0.46))
				_draw_ellipse(center + Vector2(rect.size.x * 0.30, 6.0), radius * Vector2(0.20, 0.18), Color(0.02, 0.02, 0.024, 0.72))
				draw_line(center + Vector2(-rect.size.x * 0.37, -3.0), center + Vector2(rect.size.x * 0.31, -7.0), Color(0.24, 0.86, 0.58, 0.30), 3.0, true)
				draw_line(center + Vector2(-rect.size.x * 0.30, 6.0), center + Vector2(rect.size.x * 0.18, 3.0), Color(0.94, 0.50, 0.16, 0.23), 2.0, true)
				draw_line(center + Vector2(-rect.size.x * 0.08, -10.0), center + Vector2(rect.size.x * 0.36, -1.0), Color(0.26, 0.70, 1.0, 0.16), 2.0, true)
		"mine":
			for rect in rects:
				var center := rect.get_center()
				draw_circle(center, rect.size.x * 0.42, Color(0.18, 0.18, 0.22, 0.96))
				draw_circle(center, rect.size.x * 0.24, Color(1.0, 0.46, 0.18, 0.82))
				for spike in range(8):
					var angle := float(spike) / 8.0 * TAU
					var start := center + Vector2(cos(angle), sin(angle)) * 8.0
					var finish := center + Vector2(cos(angle), sin(angle)) * 20.0
					draw_line(start, finish, Color(0.80, 0.80, 0.86, 0.82), 2.0, true)
		"pit":
			for rect in rects:
				draw_rect(rect, Color(0.035, 0.018, 0.028, 1.0), true)
				draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 22.0), Color(0.38, 0.12, 0.04, 0.98), true)
				draw_line(rect.position, rect.position + Vector2(rect.size.x, 0.0), Color(1.0, 0.82, 0.18, 1.0), 9.0)
				draw_rect(rect.grow(5.0), Color(1.0, 0.28, 0.08, 0.82), false, 5.0)
				draw_line(rect.position + Vector2(0.0, 16.0), rect.position + Vector2(rect.size.x, 28.0), Color(0.55, 0.30, 0.08, 0.36), 3.0, true)
				draw_line(rect.position + Vector2(0.0, rect.size.y), rect.position + rect.size, Color(0.14, 0.12, 0.12, 0.86), 6.0)
				draw_line(rect.position, rect.position + Vector2(0.0, rect.size.y), Color(0.86, 0.42, 0.12, 0.24), 6.0, true)
				draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + rect.size, Color(0.86, 0.42, 0.12, 0.24), 6.0, true)
				for spark in range(maxi(int(rect.size.x / 54.0), 1)):
					var spark_x := rect.position.x + 18.0 + spark * 50.0
					draw_line(Vector2(spark_x, rect.position.y + 10.0), Vector2(spark_x + 14.0, rect.position.y + 24.0), Color(1.0, 0.52, 0.18, 0.46), 2.0, true)
		"laser_gate":
			var gate_color := Color(1.0, 0.2, 0.16, 0.92) if is_active() else Color(1.0, 0.88, 0.42, 0.48)
			for rect in rects:
				draw_rect(rect, gate_color, true)
				if is_warning():
					draw_rect(rect.grow(12.0), Color(1.0, 0.82, 0.42, 0.12), false, 2.0)
		"low_barricade":
			for rect in rects:
				var damage_ratio := float(destructible_hits_remaining) / maxf(float(destructible_hits_max), 1.0)
				var fill := Color(0.34, 0.30, 0.24, 0.96)
				var cap := Color(0.98, 0.70, 0.22, 0.92)
				if destructible:
					fill = Color(0.34, 0.16, 0.12, 0.96)
					cap = Color(1.0, 0.30, 0.20, 0.92)
					if damage_flash_timer > 0.0:
						fill = fill.lerp(Color(1.0, 0.66, 0.42, 0.96), 0.55)
					cap = cap.lerp(Color(0.36, 0.14, 0.12, 0.92), (1.0 - damage_ratio) * 0.36)
				draw_rect(rect, fill, true)
				draw_rect(Rect2(rect.position, Vector2(rect.size.x, 10.0)), cap, true)
				for stripe in range(maxi(int(rect.size.x / 34.0), 1)):
					var stripe_x := rect.position.x + 10.0 + stripe * 32.0
					draw_line(Vector2(stripe_x, rect.position.y + 4.0), Vector2(stripe_x + 14.0, rect.position.y + rect.size.y - 6.0), Color(0.18, 0.16, 0.14, 0.84), 2.0)
				if destructible:
					_draw_weakspot(rect, damage_ratio)
		_:
			var damage_ratio := float(destructible_hits_remaining) / maxf(float(destructible_hits_max), 1.0)
			var block_fill := Color(0.24, 0.24, 0.28, 0.96)
			var block_edge := Color(0.96, 0.74, 0.26, 0.86)
			if obstacle_type == "moving_gate":
				block_fill = Color(0.22, 0.26, 0.30, 0.96)
				block_edge = Color(0.92, 0.90, 0.98, 0.82)
			elif destructible:
				block_fill = Color(0.32, 0.14, 0.12, 0.96)
				block_edge = Color(1.0, 0.34, 0.24, 0.90)
				if damage_flash_timer > 0.0:
					block_fill = block_fill.lerp(Color(1.0, 0.58, 0.34, 0.96), 0.52)
				block_edge = block_edge.lerp(Color(0.42, 0.14, 0.12, 0.86), (1.0 - damage_ratio) * 0.34)
			for rect in rects:
				draw_rect(rect, block_fill, true)
				draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8.0)), block_edge, true)
				draw_rect(Rect2(rect.position.x + 4.0, rect.position.y + 10.0, 8.0, rect.size.y - 18.0), Color(0.0, 0.0, 0.0, 0.18), true)
				draw_rect(Rect2(rect.end.x - 12.0, rect.position.y + 10.0, 8.0, rect.size.y - 18.0), Color(1.0, 0.88, 0.42, 0.10), true)
				draw_rect(Rect2(rect.position, rect.size), Color(0.06, 0.06, 0.08, 0.38), false, 2.0)
				var stripe_count := maxi(int(rect.size.y / 36.0), 1)
				for stripe in range(stripe_count):
					var y := rect.position.y + 14.0 + stripe * 28.0
					draw_line(Vector2(rect.position.x + 12.0, y), Vector2(rect.position.x + rect.size.x - 12.0, y), Color(0.08, 0.08, 0.10, 0.34), 2.0)
				for bolt_y in range(maxi(int(rect.size.y / 48.0), 1)):
					var y := rect.position.y + 22.0 + bolt_y * 44.0
					draw_circle(Vector2(rect.position.x + 18.0, y), 3.5, Color(0.02, 0.02, 0.025, 0.52))
					draw_circle(Vector2(rect.end.x - 18.0, y), 3.5, Color(0.02, 0.02, 0.025, 0.52))
				if destructible:
					_draw_weakspot(rect, damage_ratio)


func warning_entries() -> Array:
	var entries: Array = []
	if destroyed or obstacle_type == "ramp":
		return entries
	var rects := _current_rects()
	var seen_keys: Dictionary = {}
	if obstacle_type in ["pit", "low_barricade", "laser_gate", "oil_spill"]:
		if not rects.is_empty():
			entries.append({
				"y": (rects[0] as Rect2).get_center().y,
				"kind": obstacle_type,
				"destructible": destructible,
				"ramp_assist": ramp_assist
			})
		return entries
	for rect in rects:
		var current_rect := rect as Rect2
		var key := "%s_%d" % [obstacle_type, int(round(current_rect.get_center().y))]
		if seen_keys.has(key):
			continue
		seen_keys[key] = true
		entries.append({
			"y": current_rect.get_center().y,
			"kind": obstacle_type,
			"destructible": destructible,
			"shape": shape,
			"ramp_assist": ramp_assist
		})
	return entries


func preview_rects(right_edge: float) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if destroyed:
		return rects
	var current_rects := _current_rects()
	if current_rects.is_empty():
		return rects
	var lead := leading_x()
	var trail := trailing_x()
	var width := maxf(trail - lead, 1.0)
	var offset := Vector2(right_edge - width - lead, 0.0)
	for rect in current_rects:
		var current_rect := rect as Rect2
		rects.append(Rect2(current_rect.position + offset, current_rect.size))
	return rects


func _weakspot_rect_for(rect: Rect2) -> Rect2:
	var center := rect.get_center()
	var size := Vector2(minf(rect.size.x * 0.36, 54.0), minf(rect.size.y * 0.42, 46.0))
	if obstacle_type == "low_barricade":
		size = Vector2(minf(rect.size.x * 0.30, 44.0), 32.0)
	return Rect2(center - size * 0.5, size)


func _draw_weakspot(rect: Rect2, damage_ratio: float) -> void:
	var weakspot := _weakspot_rect_for(rect)
	var center := weakspot.get_center()
	var hot_color := Color(1.0, 0.76, 0.22, 0.94)
	if damage_flash_timer > 0.0:
		hot_color = Color(1.0, 0.96, 0.62, 0.98)
	draw_circle(center, weakspot.size.x * 0.38, hot_color)
	draw_line(center + Vector2(-weakspot.size.x * 0.26, 0.0), center + Vector2(weakspot.size.x * 0.26, 0.0), Color(0.18, 0.10, 0.08, 0.88), 2.0, true)
	draw_line(center + Vector2(0.0, -weakspot.size.y * 0.26), center + Vector2(0.0, weakspot.size.y * 0.26), Color(0.18, 0.10, 0.08, 0.88), 2.0, true)
	var pip_y := weakspot.position.y + weakspot.size.y + 8.0
	for pip in range(destructible_hits_max):
		var pip_x := center.x - (float(destructible_hits_max - 1) * 7.0) + float(pip) * 14.0
		var active := pip < destructible_hits_remaining
		var pip_color := Color(1.0, 0.80, 0.28, 0.92) if active else Color(0.26, 0.14, 0.12, 0.82)
		draw_circle(Vector2(pip_x, pip_y), 4.0, pip_color)


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color, segments: int = 24) -> void:
	var point_count := maxi(segments, 8)
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func leading_x() -> float:
	var furthest_left := INF
	for rect in _current_rects():
		furthest_left = minf(furthest_left, rect.position.x)
	return 0.0 if furthest_left == INF else furthest_left


func trailing_x() -> float:
	var furthest_right := -INF
	for rect in _current_rects():
		furthest_right = maxf(furthest_right, rect.position.x + rect.size.x)
	return 0.0 if furthest_right == -INF else furthest_right
