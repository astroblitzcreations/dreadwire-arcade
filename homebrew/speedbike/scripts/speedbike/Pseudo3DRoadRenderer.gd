extends Node2D
class_name Pseudo3DRoadRenderer

const LANE_NORMALIZED := {
	-2: -0.80,
	-1: -0.40,
	0: 0.0,
	1: 0.40,
	2: 0.80
}

var screen_size := Vector2(1280.0, 720.0)
var horizon_y := 172.0
var road_bottom_y := 720.0
var road_width_near := 920.0
var road_width_far := 76.0
var road_scale_factor := 1.0
var segment_count := 86
var visible_distance := 2350.0
var segment_length := 34.0
var camera_z := 0.0
var level_data: Dictionary = {}
var theme: Dictionary = {}
var previous_theme: Dictionary = {}
var theme_blend := 0.0
var time_accum := 0.0
var perf_baseline := true
var draw_far_background := true
var road_y_offset := 0.0
var stage_origin_z := 0.0
var _curve_frame_cache: Dictionary = {}
var _hill_frame_cache: Dictionary = {}
var _roadside_seed := 0


func _ready() -> void:
	z_index = -30
	_refresh_screen_size()


func _process(delta: float) -> void:
	time_accum += delta
	if theme_blend > 0.0:
		theme_blend = maxf(theme_blend - delta / 3.6, 0.0)
		queue_redraw()


func configure(data: Dictionary) -> void:
	level_data = data
	var next_theme: Dictionary = data.get("theme", WindingLevelData.THEMES["badlands_canyon"])
	if not theme.is_empty() and next_theme != theme:
		previous_theme = theme.duplicate(true)
		theme_blend = 1.0
	theme = next_theme
	_roadside_seed = int(data.get("stage", 50)) * 7919
	_refresh_screen_size()
	queue_redraw()


func set_camera_z(value: float) -> void:
	camera_z = value
	_curve_frame_cache.clear()
	_hill_frame_cache.clear()
	queue_redraw()


func set_road_scale_factor(value: float) -> void:
	var next_value := clampf(value, 0.68, 2.15)
	if absf(next_value - road_scale_factor) < 0.01:
		return
	road_scale_factor = next_value
	queue_redraw()


func project(world_z: float, lane_value: float) -> Dictionary:
	var rel_z := world_z - camera_z
	if rel_z < -70.0 or rel_z > visible_distance:
		return {"visible": false, "x": screen_size.x * 0.5, "y": road_bottom_y, "scale": 1.0, "width": road_width_near}
	var p := clampf(rel_z / visible_distance, 0.0, 1.0)
	var near := 1.0 - p
	var y := lerpf(road_bottom_y - 126.0, horizon_y, pow(p, 0.58)) + _hill_offset_at(world_z) * p + road_y_offset
	var width := lerpf(road_width_near, road_width_far, pow(p, 0.78)) * road_scale_factor
	var center_x := road_center_at_rel(rel_z)
	var lane_x := center_x + lane_value * 0.24 * width
	var scale := lerpf(0.72, 0.08, p)
	return {
		"visible": true,
		"x": lane_x,
		"y": y,
		"scale": scale,
		"width": width,
		"center_x": center_x,
		"near": near
	}


func road_center_at_rel(rel_z: float) -> float:
	var depth_ratio := clampf(rel_z / visible_distance, 0.0, 1.0)
	var samples := maxi(10, int(26.0 * maxf(depth_ratio, 0.12)))
	var step := maxf(rel_z / float(samples), 10.0)
	var offset := 0.0
	var walk := 0.0
	for _i in range(samples):
		var t := clampf(walk / maxf(rel_z, 1.0), 0.0, 1.0)
		var depth_weight := smoothstep(0.10, 1.0, t)
		var next_curve := curve_at(camera_z + walk)
		offset += next_curve * step * 0.18 * depth_weight
		walk += step
	var stage_pressure := clampf((float(int(level_data.get("stage", 50))) - 50.0) / 10.0, 0.0, 1.0)
	var center_limit := screen_size.x * lerpf(0.28, 0.36, stage_pressure)
	return clampf(screen_size.x * 0.5 + offset, screen_size.x * 0.5 - center_limit, screen_size.x * 0.5 + center_limit)


func curve_at(world_z: float) -> float:
	var local_z := world_z - stage_origin_z
	var key := int(local_z / 32.0)
	if _curve_frame_cache.has(key):
		return float(_curve_frame_cache[key])
	var curve_total := 0.0
	var curves: Array = level_data.get("curves", [])
	for row in curves:
		if not (row is Dictionary):
			continue
		var start := float(row.get("z", 0.0))
		var length := maxf(float(row.get("length", 1.0)), 1.0)
		var end := start + length
		if local_z >= start and local_z <= end:
			var t := clampf((local_z - start) / length, 0.0, 1.0)
			curve_total += float(row.get("curve", 0.0)) * sin(t * PI)
	if int(level_data.get("stage", 0)) == 58:
		curve_total += sin(local_z * 0.010) * 0.16
	_curve_frame_cache[key] = curve_total
	return curve_total


func road_width_at_rel(rel_z: float) -> float:
	var p := clampf(rel_z / visible_distance, 0.0, 1.0)
	return lerpf(road_width_near, road_width_far, pow(p, 0.78)) * road_scale_factor


func road_lane_limit_at_rel(rel_z: float) -> float:
	var width := road_width_at_rel(rel_z)
	var playable_ratio := clampf((width * 0.5 - 52.0) / maxf(width * 0.24, 1.0), 1.15, 2.05)
	return playable_ratio


func _draw() -> void:
	_refresh_screen_size()
	_draw_sky()
	if draw_far_background:
		_draw_far_shapes()
	if _theme_id() == "red_tunnel":
		_draw_red_tunnel_backdrop()
	_draw_road()
	if _theme_id() == "red_tunnel":
		_draw_red_tunnel_foreground_shell()
		_draw_red_tunnel_dome_rings()
	_draw_sparse_roadside_props()
	if not perf_baseline:
		_draw_fog()


func _draw_sky() -> void:
	var top := _theme_color("sky_top", Color(0.16, 0.12, 0.10))
	var bottom := _theme_color("sky_bottom", Color(0.48, 0.27, 0.13))
	draw_rect(Rect2(Vector2.ZERO, screen_size), bottom)
	for i in range(18):
		var t := float(i) / 17.0
		var c: Color = top.lerp(bottom, t)
		draw_rect(Rect2(0.0, t * screen_size.y, screen_size.x, screen_size.y / 17.0 + 2.0), c)
	_draw_sky_bodies()


func _draw_sky_bodies() -> void:
	var travel := fmod(camera_z * 0.004, screen_size.x + 260.0)
	var moon_x := screen_size.x + 120.0 - travel
	var moon_y := horizon_y - 58.0 - sin(clampf(camera_z / 15000.0, 0.0, 1.0) * PI) * 86.0
	draw_circle(Vector2(moon_x, moon_y), 34.0, Color(0.82, 0.92, 1.0, 0.86))
	draw_circle(Vector2(moon_x - 10.0, moon_y - 6.0), 27.0, Color(0.70, 0.82, 0.96, 0.24))
	var sun_t := clampf(1.0 - camera_z / 18000.0, 0.0, 1.0)
	if sun_t > 0.0:
		var sun_pos := Vector2(screen_size.x * 0.22 + camera_z * 0.006, horizon_y + 12.0 - sun_t * 78.0)
		draw_circle(sun_pos, 42.0, Color(1.0, 0.48, 0.16, 0.22 * sun_t))
		draw_circle(sun_pos, 18.0, Color(1.0, 0.72, 0.30, 0.72 * sun_t))


func _draw_far_shapes() -> void:
	if _theme_id() == "red_tunnel":
		return
	var base := Color(0.05, 0.04, 0.035, 0.55)
	var stage := int(level_data.get("stage", 50))
	for i in range(10):
		var x := fmod(float(i) * 173.0 - fmod(camera_z * 0.012, 173.0), screen_size.x + 240.0) - 120.0
		var h := 38.0 + float((i * 31 + stage) % 80)
		var y := horizon_y - 10.0 - h * 0.32
		var points := PackedVector2Array([
			Vector2(x - 80.0, horizon_y + 24.0),
			Vector2(x - 38.0, y + h * 0.35),
			Vector2(x, y),
			Vector2(x + 52.0, y + h * 0.45),
			Vector2(x + 92.0, horizon_y + 24.0)
		])
		draw_colored_polygon(points, base)


func _draw_red_tunnel_backdrop() -> void:
	var wall_dark := Color(0.018, 0.001, 0.003, 1.0)
	var glow := Color(1.0, 0.04, 0.02, 0.12)
	draw_rect(Rect2(0.0, horizon_y - 42.0, screen_size.x, screen_size.y - horizon_y + 42.0), wall_dark, true)
	var roof_floor_y := horizon_y + clampf(screen_size.y * 0.065, 44.0, 76.0)
	draw_rect(Rect2(0.0, 0.0, screen_size.x, roof_floor_y), Color(0.006, 0.0, 0.001, 1.0), true)
	var vanishing_left := Vector2(screen_size.x * 0.5 - road_width_far * 0.34, horizon_y + road_y_offset * 0.04)
	var vanishing_right := Vector2(screen_size.x * 0.5 + road_width_far * 0.34, horizon_y + road_y_offset * 0.04)
	var near_left := Vector2(screen_size.x * 0.5 - road_width_near * 0.72 * road_scale_factor, road_bottom_y - 88.0 + road_y_offset)
	var near_right := Vector2(screen_size.x * 0.5 + road_width_near * 0.72 * road_scale_factor, road_bottom_y - 88.0 + road_y_offset)
	var ceiling_left := Vector2(0.0, 0.0)
	var ceiling_right := Vector2(screen_size.x, 0.0)
	draw_colored_polygon(PackedVector2Array([
		ceiling_left,
		ceiling_right,
		vanishing_right + Vector2(420.0, roof_floor_y - horizon_y),
		vanishing_left + Vector2(-420.0, roof_floor_y - horizon_y)
	]), Color(0.012, 0.0, 0.001, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, horizon_y + 18.0),
		vanishing_left,
		near_left,
		Vector2(0.0, screen_size.y)
	]), Color(0.022, 0.001, 0.003, 1.0))
	draw_colored_polygon(PackedVector2Array([
		vanishing_right,
		Vector2(screen_size.x, horizon_y + 18.0),
		Vector2(screen_size.x, screen_size.y),
		near_right
	]), Color(0.022, 0.001, 0.003, 1.0))
	draw_polyline(PackedVector2Array([vanishing_left, near_left]), Color(1.0, 0.05, 0.03, 0.22), 3.0, true)
	draw_polyline(PackedVector2Array([vanishing_right, near_right]), Color(1.0, 0.05, 0.03, 0.22), 3.0, true)
	_draw_red_tunnel_static_panel_seams(vanishing_left, vanishing_right, near_left, near_right)
	for side in [-1.0, 1.0]:
		var wall_points := PackedVector2Array([
			Vector2(screen_size.x * 0.5 + side * road_width_far * 0.50, horizon_y + road_y_offset * 0.10),
			Vector2(screen_size.x * 0.5 + side * screen_size.x * 0.52, horizon_y + 30.0),
			Vector2(screen_size.x * 0.5 + side * screen_size.x * 0.55, screen_size.y),
			Vector2(screen_size.x * 0.5 + side * road_width_near * 0.54 * road_scale_factor, road_bottom_y - 92.0 + road_y_offset)
		])
		draw_colored_polygon(wall_points, Color(0.042, 0.002, 0.004, 0.98))
		draw_polyline(wall_points, Color(glow.r, glow.g, glow.b, 0.20), 2.0, true)
	for shade in range(8):
		var alpha := 0.045 + float(shade) * 0.018
		var inset := float(shade) * 38.0
		draw_rect(Rect2(inset - 2.0, 0.0, 42.0, screen_size.y), Color(0.0, 0.0, 0.0, alpha), true)
		draw_rect(Rect2(screen_size.x - inset - 40.0, 0.0, 42.0, screen_size.y), Color(0.0, 0.0, 0.0, alpha), true)


func _draw_red_tunnel_static_panel_seams(vanishing_left: Vector2, vanishing_right: Vector2, near_left: Vector2, near_right: Vector2) -> void:
	var seam_dark := Color(0.0, 0.0, 0.0, 0.38)
	var seam_red := Color(0.38, 0.010, 0.012, 0.42)
	for side in [-1.0, 1.0]:
		var far_edge := vanishing_left if side < 0.0 else vanishing_right
		var near_edge := near_left if side < 0.0 else near_right
		var wall_outer_far := Vector2(0.0 if side < 0.0 else screen_size.x, horizon_y + 14.0)
		var wall_outer_near := Vector2(0.0 if side < 0.0 else screen_size.x, screen_size.y)
		for panel in range(1, 5):
			var t := float(panel) / 5.0
			var inner := far_edge.lerp(near_edge, t)
			var outer := wall_outer_far.lerp(wall_outer_near, t)
			draw_line(inner, outer, seam_dark, 3.0, true)
			draw_line(inner + Vector2(side * 2.0, 0.0), outer + Vector2(side * 2.0, 0.0), seam_red, 1.2, true)
	for panel in range(1, 5):
		var t := float(panel) / 6.0
		var left := vanishing_left.lerp(near_left, t)
		var right := vanishing_right.lerp(near_right, t)
		var roof_y := lerpf(18.0, horizon_y + 32.0, t)
		var inset := lerpf(42.0, 190.0, t)
		draw_line(Vector2(inset, roof_y), Vector2(screen_size.x - inset, roof_y), Color(0.045, 0.001, 0.002, 0.28), maxf(1.0, 1.4 * t), true)


func _draw_red_tunnel_dome_rings() -> void:
	var spacing := 14500.0
	var phase_z := fmod(camera_z, spacing)
	var light_color := Color(1.0, 0.13, 0.055, 0.82)
	var hot_core := Color(1.0, 0.70, 0.30, 0.94)
	var rib_color := Color(0.19, 0.010, 0.012, 0.78)
	for index in range(3, -1, -1):
		var rel_z := float(index) * spacing - phase_z + 220.0
		if rel_z < 140.0 or rel_z > visible_distance:
			continue
		var sample := _strip_sample(rel_z)
		var p := clampf(rel_z / visible_distance, 0.0, 1.0)
		var near := 1.0 - p
		var y := float(sample.get("y", horizon_y))
		var width := float(sample.get("width", road_width_far))
		var center := float(sample.get("center_x", screen_size.x * 0.5))
		var scale_value := clampf(float(sample.get("scale", 0.2)), 0.08, 0.76)
		var alpha := clampf(0.24 + near * 0.64, 0.20, 0.86)
		var arch_top_y := y - maxf(72.0, width * 0.34)
		var arch_half := width * 0.64
		_draw_red_tunnel_arch(center, y + 8.0 * scale_value, arch_half, arch_top_y, Color(rib_color.r, rib_color.g, rib_color.b, alpha * 0.72), maxf(1.0, 5.2 * scale_value))
		var light_size := maxf(4.0, 26.0 * scale_value)
		var light_y := arch_top_y + maxf(8.0, (y - arch_top_y) * 0.10)
		var strip_half := maxf(24.0, arch_half * 0.20)
		var glow_rect := Rect2(Vector2(center - strip_half * 1.75, light_y - light_size * 0.72), Vector2(strip_half * 3.5, light_size * 1.44))
		draw_rect(glow_rect, Color(light_color.r, light_color.g, light_color.b, 0.05 + alpha * 0.10), true)
		draw_line(Vector2(center - strip_half, light_y), Vector2(center + strip_half, light_y), Color(light_color.r, light_color.g, light_color.b, alpha * 0.88), maxf(2.0, light_size * 0.40), true)
		draw_line(Vector2(center - strip_half * 0.42, light_y), Vector2(center + strip_half * 0.42, light_y), hot_core, maxf(1.0, light_size * 0.16), true)


func _draw_red_tunnel_arch(center_x: float, floor_y: float, half_width: float, top_y: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for step in range(17):
		var t := float(step) / 16.0
		var angle := PI - t * PI
		var x := center_x + cos(angle) * half_width
		var y := floor_y - sin(t * PI) * maxf(16.0, floor_y - top_y)
		points.append(Vector2(x, y))
	draw_polyline(points, color, width, true)


func _draw_red_tunnel_foreground_shell() -> void:
	var far := _strip_sample(visible_distance)
	var mid := _strip_sample(visible_distance * 0.42)
	var near := _strip_sample(0.0)
	var far_left := Vector2(float(far.get("center_x", screen_size.x * 0.5)) - float(far.get("width", road_width_far)) * 1.22, float(far.get("y", horizon_y)) + 44.0)
	var far_right := Vector2(float(far.get("center_x", screen_size.x * 0.5)) + float(far.get("width", road_width_far)) * 1.22, float(far.get("y", horizon_y)) + 44.0)
	var mid_left := Vector2(float(mid.get("center_x", screen_size.x * 0.5)) - float(mid.get("width", road_width_far)) * 1.02, float(mid.get("y", horizon_y)) + 18.0)
	var mid_right := Vector2(float(mid.get("center_x", screen_size.x * 0.5)) + float(mid.get("width", road_width_far)) * 1.02, float(mid.get("y", horizon_y)) + 18.0)
	var near_left := Vector2(float(near.get("center_x", screen_size.x * 0.5)) - float(near.get("width", road_width_near)) * 0.50, float(near.get("y", road_bottom_y)) + 12.0)
	var near_right := Vector2(float(near.get("center_x", screen_size.x * 0.5)) + float(near.get("width", road_width_near)) * 0.50, float(near.get("y", road_bottom_y)) + 12.0)
	var ceiling := Color(0.006, 0.0, 0.001, 1.0)
	var wall := Color(0.014, 0.0, 0.002, 1.0)
	var wall_red := Color(0.080, 0.004, 0.005, 0.98)
	var seam := Color(1.0, 0.035, 0.020, 0.16)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(screen_size.x, 0.0),
		Vector2(screen_size.x, horizon_y + 28.0),
		far_right,
		far_left,
		Vector2(0.0, horizon_y + 28.0)
	]), ceiling)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, horizon_y + 48.0),
		far_left,
		mid_left,
		near_left,
		Vector2(0.0, screen_size.y)
	]), wall)
	draw_colored_polygon(PackedVector2Array([
		far_right,
		Vector2(screen_size.x, horizon_y + 48.0),
		Vector2(screen_size.x, screen_size.y),
		near_right,
		mid_right
	]), wall)
	var mouth_shadow := Color(0.0, 0.0, 0.0, 0.10)
	draw_line(far_left, far_right, mouth_shadow, 3.0, true)
	for side in [-1.0, 1.0]:
		var a := far_left if side < 0.0 else far_right
		var b := mid_left if side < 0.0 else mid_right
		var c := near_left if side < 0.0 else near_right
		draw_polyline(PackedVector2Array([a, b, c]), seam, 4.0, true)
		for rib in range(5):
			var t := float(rib + 1) / 6.0
			var p1 := a.lerp(c, t)
			var p2 := p1 + Vector2(side * screen_size.x * 0.22, -36.0 - t * 54.0)
			draw_line(p1, p2, wall_red, 5.0 - t * 2.5, true)
	var vignette := Color(0.0, 0.0, 0.0, 0.34)
	draw_rect(Rect2(0.0, 0.0, 132.0, screen_size.y), vignette, true)
	draw_rect(Rect2(screen_size.x - 132.0, 0.0, 132.0, screen_size.y), vignette, true)
	draw_rect(Rect2(0.0, 0.0, screen_size.x, 32.0), Color(0.0, 0.0, 0.0, 0.22), true)


func _draw_road() -> void:
	var road_color := _theme_color("road", Color(0.17, 0.15, 0.14))
	var road_alt := _theme_color("road_alt", Color(0.12, 0.11, 0.10))
	var edge_color := _theme_color("edge", Color(1.0, 0.45, 0.10))
	var lane_color := _theme_color("lane", Color(1.0, 0.72, 0.35))
	var previous := _strip_sample(visible_distance)
	for index in range(segment_count - 1, -1, -1):
		var rel_z := (float(index) / float(segment_count - 1)) * visible_distance
		var current := _strip_sample(rel_z)
		var left_far: Vector2 = previous.get("left", Vector2.ZERO)
		var right_far: Vector2 = previous.get("right", Vector2.ZERO)
		var left_near: Vector2 = current.get("left", Vector2.ZERO)
		var right_near: Vector2 = current.get("right", Vector2.ZERO)
		var row_color := road_color if index % 2 == 0 else road_alt
		draw_colored_polygon(PackedVector2Array([left_far, right_far, right_near, left_near]), row_color)
		_draw_edge_rail_dashes(previous, current, edge_color, index)
		_draw_edge_speed_stripes(previous, current, edge_color, index)
		previous = current
	_draw_turn_markers(edge_color)


func _draw_edge_rail_dashes(previous: Dictionary, current: Dictionary, edge_color: Color, index: int) -> void:
	var dash_cycle := int(floor(camera_z / 72.0 + float(index) * 0.72)) % 6
	if dash_cycle > 1:
		return
	var scale_value := clampf(float(current.get("scale", 1.0)), 0.08, 0.86)
	var rail_color := edge_color
	rail_color.a = 0.34 + scale_value * 0.38
	var lift := sin(camera_z * 0.0055 + float(index) * 0.54) * (0.8 + scale_value * 2.2)
	for side in [-1.0, 1.0]:
		var near_center := float(current.get("center_x", screen_size.x * 0.5))
		var far_center := float(previous.get("center_x", screen_size.x * 0.5))
		var near_width := float(current.get("width", road_width_near))
		var far_width := float(previous.get("width", road_width_far))
		var near_edge := Vector2(near_center + side * near_width * 0.50, float(current.get("y", road_bottom_y)) + lift)
		var far_edge := Vector2(far_center + side * far_width * 0.50, float(previous.get("y", horizon_y)) + lift * 0.45)
		draw_line(far_edge, near_edge, rail_color, maxf(1.0, scale_value * 5.0), true)


func _draw_edge_speed_stripes(previous: Dictionary, current: Dictionary, edge_color: Color, index: int) -> void:
	var dash_phase := int(floor(camera_z / 92.0 + float(index) * 0.70)) % 4
	if dash_phase != 0:
		return
	var scale_value := clampf(float(current.get("scale", 1.0)), 0.08, 0.78)
	var stripe_color := edge_color
	stripe_color.a = 0.26 + scale_value * 0.30
	for side in [-1.0, 1.0]:
		var near_center := float(current.get("center_x", screen_size.x * 0.5))
		var far_center := float(previous.get("center_x", screen_size.x * 0.5))
		var near_width := float(current.get("width", road_width_near))
		var far_width := float(previous.get("width", road_width_far))
		var near_edge := Vector2(near_center + side * near_width * 0.47, float(current.get("y", road_bottom_y)))
		var far_edge := Vector2(far_center + side * far_width * 0.47, float(previous.get("y", horizon_y)))
		var near_inner := Vector2(near_center + side * near_width * 0.40, near_edge.y)
		var far_inner := Vector2(far_center + side * far_width * 0.40, far_edge.y)
		draw_colored_polygon(PackedVector2Array([far_edge, near_edge, near_inner, far_inner]), stripe_color)


func _draw_turn_markers(edge_color: Color) -> void:
	if _theme_id() == "red_tunnel":
		return
	var curves: Array = level_data.get("curves", [])
	for row in curves:
		if not (row is Dictionary):
			continue
		var curve_start := stage_origin_z + float(row.get("z", 0.0))
		var marker_rel := curve_start - camera_z - 150.0
		if marker_rel < 250.0 or marker_rel > visible_distance:
			continue
		var sample := _strip_sample(marker_rel)
		_draw_curve_sign(sample, edge_color, float(row.get("curve", 0.0)))


func _draw_road_curve_paint(sample: Dictionary, lane_color: Color) -> void:
	var rel_z := float(sample.get("rel_z", 0.0))
	var curve := _upcoming_curve_strength(rel_z)
	if absf(curve) < 0.20:
		return
	var side := signf(curve)
	var y := float(sample.get("y", horizon_y))
	var width := float(sample.get("width", road_width_far))
	var center := float(sample.get("center_x", screen_size.x * 0.5))
	var scale_value := clampf(float(sample.get("scale", 1.0)), 0.10, 0.82)
	var arrow_w := width * 0.055
	var arrow_h := maxf(7.0, 22.0 * scale_value)
	var color := lane_color
	color.a = clampf(0.12 + absf(curve) * 0.22, 0.12, 0.38)
	for lane_shift in [-0.18, 0.18]:
		var x = center + width * lane_shift
		var points := PackedVector2Array([
			Vector2(x - side * arrow_w, y - arrow_h),
			Vector2(x + side * arrow_w, y),
			Vector2(x - side * arrow_w, y + arrow_h)
		])
		draw_polyline(points, color, maxf(1.0, 5.0 * scale_value), true)


func _draw_curve_sign(sample: Dictionary, edge_color: Color, curve_override := 0.0) -> void:
	var rel_z := float(sample.get("rel_z", 0.0))
	var curve := curve_override if absf(curve_override) > 0.01 else _upcoming_curve_strength(rel_z)
	if absf(curve) < 0.15:
		return
	var y := float(sample.get("y", horizon_y))
	var width := float(sample.get("width", road_width_far))
	var center := float(sample.get("center_x", screen_size.x * 0.5))
	var side := signf(curve)
	var scale_value := clampf(float(sample.get("scale", 1.0)), 0.10, 0.82)
	var x := center + side * width * 0.58
	var sign_size := clampf(54.0 * scale_value, 10.0, 44.0)
	var post_h := sign_size * 2.1
	var base := Vector2(x, y + sign_size * 1.8)
	var warning := Color(1.0, 0.70, 0.16, clampf(0.45 + absf(curve) * 0.40, 0.45, 0.92))
	var dark := Color(0.08, 0.06, 0.035, warning.a)
	var glow := edge_color
	glow.a = 0.18 + absf(curve) * 0.18
	draw_line(base, base + Vector2(0.0, -post_h), Color(0.10, 0.09, 0.08, warning.a), maxf(1.0, 5.0 * scale_value), true)
	var diamond_center := base + Vector2(0.0, -post_h - sign_size * 0.10)
	var diamond := PackedVector2Array([
		diamond_center + Vector2(0.0, -sign_size),
		diamond_center + Vector2(sign_size, 0.0),
		diamond_center + Vector2(0.0, sign_size),
		diamond_center + Vector2(-sign_size, 0.0)
	])
	draw_colored_polygon(diamond, warning)
	draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), dark, maxf(1.0, 3.0 * scale_value), true)
	for arrow_index in range(2 if absf(curve) < 0.55 else 3):
		var arrow_y := diamond_center.y - sign_size * 0.48 + float(arrow_index) * sign_size * 0.45
		var arrow_w := sign_size * 0.44
		var arrow := PackedVector2Array([
			Vector2(diamond_center.x - side * arrow_w, arrow_y - sign_size * 0.15),
			Vector2(diamond_center.x + side * arrow_w, arrow_y),
			Vector2(diamond_center.x - side * arrow_w, arrow_y + sign_size * 0.15)
		])
		draw_polyline(arrow, dark, maxf(1.2, sign_size * 0.12), true)
	draw_circle(diamond_center, sign_size * 1.22, glow)


func _upcoming_curve_strength(rel_z: float) -> float:
	var strongest := 0.0
	for look in [0.0, 180.0, 360.0, 560.0]:
		var curve := curve_at(camera_z + rel_z + look)
		if absf(curve) > absf(strongest):
			strongest = curve
	return strongest


func _draw_fog() -> void:
	var fog := _theme_color("fog", Color(0.9, 0.5, 0.2, 0.12))
	if fog.a <= 0.0:
		return
	for i in range(4):
		var y := horizon_y + float(i) * 34.0 + sin(time_accum * 0.7 + float(i)) * 5.0
		draw_rect(Rect2(0.0, y, screen_size.x, 28.0), fog)


func _draw_sparse_roadside_props() -> void:
	if _theme_id() == "red_tunnel":
		return
	var spacing := 720.0
	var prop_camera_z := camera_z * 0.70
	var start_z: float = floor(prop_camera_z / spacing) * spacing + spacing * 2.0
	for index in range(8, -1, -1):
		var world_z: float = start_z + float(index) * spacing
		var rel_z: float = world_z - prop_camera_z
		if rel_z < 260.0 or rel_z > visible_distance + spacing:
			continue
		var sample := _strip_sample(clampf(rel_z, 0.0, visible_distance))
		var p := clampf(rel_z / maxf(visible_distance, 1.0), 0.0, 1.0)
		var near := 1.0 - p
		var scale_value := clampf(float(sample.get("scale", 0.1)) * 1.05, 0.055, 0.42)
		var side := -1.0 if int((world_z / spacing) + float(_roadside_seed % 3)) % 2 == 0 else 1.0
		var width := float(sample.get("width", road_width_far))
		var center_x := float(sample.get("center_x", screen_size.x * 0.5))
		var base_y := float(sample.get("y", horizon_y))
		var x_push := side * (width * 0.72 + lerpf(16.0, 76.0, near))
		var base_pos := Vector2(center_x + x_push, base_y + 12.0 * scale_value)
		var kind := _sparse_prop_kind(world_z)
		var tint := _sparse_prop_tint(kind, p)
		_draw_sparse_prop_shadow(base_pos, scale_value, near)
		match kind:
			"tree":
				_draw_sparse_tree(base_pos, scale_value, tint, side)
			"sign":
				_draw_sparse_sign(base_pos, scale_value, tint)
			_:
				_draw_sparse_rock(base_pos, scale_value, tint)


func _sparse_prop_kind(world_z: float) -> String:
	var slot := int(absf(world_z * 0.013 + float(_roadside_seed))) % 9
	if slot in [0, 4]:
		return "tree"
	if slot == 7:
		return "sign"
	return "rock"


func _sparse_prop_tint(kind: String, depth_percent: float) -> Color:
	var haze := clampf(depth_percent * 0.48, 0.0, 0.42)
	match kind:
		"tree":
			return Color(0.12, 0.20, 0.12, 0.78).lerp(Color(0.46, 0.54, 0.50, 0.48), haze)
		"sign":
			return Color(0.95, 0.48, 0.10, 0.78).lerp(Color(0.60, 0.62, 0.58, 0.48), haze)
		_:
			return Color(0.20, 0.16, 0.13, 0.72).lerp(Color(0.54, 0.50, 0.46, 0.46), haze)


func _draw_sparse_prop_shadow(base_pos: Vector2, scale_value: float, near: float) -> void:
	draw_set_transform(base_pos + Vector2(0.0, 7.0 * scale_value), 0.0, Vector2(2.6 * scale_value, 0.38 * scale_value))
	draw_circle(Vector2.ZERO, 30.0, Color(0.0, 0.0, 0.0, 0.12 + near * 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_sparse_tree(base_pos: Vector2, scale_value: float, tint: Color, side: float) -> void:
	var trunk_h := 104.0 * scale_value
	var trunk_w := 10.0 * scale_value
	var top := base_pos + Vector2(side * 10.0 * scale_value, -trunk_h)
	draw_colored_polygon(PackedVector2Array([
		base_pos + Vector2(-trunk_w, 0.0),
		base_pos + Vector2(trunk_w, 0.0),
		top + Vector2(trunk_w * 0.55, 0.0),
		top + Vector2(-trunk_w * 0.55, 0.0)
	]), Color(0.22, 0.13, 0.07, tint.a))
	for leaf in range(5):
		var angle := -PI * 0.85 + float(leaf) * PI * 0.42
		var length := (42.0 + float(leaf % 2) * 8.0) * scale_value
		var end := top + Vector2(cos(angle) * length, sin(angle) * length * 0.70)
		var side_vec := Vector2(-sin(angle), cos(angle)) * 10.0 * scale_value
		draw_colored_polygon(PackedVector2Array([top, end + side_vec, end - side_vec]), tint)


func _draw_sparse_sign(base_pos: Vector2, scale_value: float, tint: Color) -> void:
	draw_line(base_pos, base_pos + Vector2(0.0, -58.0 * scale_value), Color(0.10, 0.09, 0.08, tint.a), maxf(1.0, 4.0 * scale_value), true)
	var center := base_pos + Vector2(0.0, -66.0 * scale_value)
	var size := 24.0 * scale_value
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0.0, -size),
		center + Vector2(size, 0.0),
		center + Vector2(0.0, size),
		center + Vector2(-size, 0.0)
	]), tint)


func _draw_sparse_rock(base_pos: Vector2, scale_value: float, tint: Color) -> void:
	var w := 58.0 * scale_value
	var h := 28.0 * scale_value
	draw_colored_polygon(PackedVector2Array([
		base_pos + Vector2(-w * 0.50, 0.0),
		base_pos + Vector2(-w * 0.22, -h * 0.75),
		base_pos + Vector2(w * 0.18, -h),
		base_pos + Vector2(w * 0.52, -h * 0.16),
		base_pos + Vector2(w * 0.22, h * 0.08)
	]), tint)


func _strip_sample(rel_z: float) -> Dictionary:
	var p := clampf(rel_z / visible_distance, 0.0, 1.0)
	var y := lerpf(road_bottom_y - 92.0, horizon_y, pow(p, 0.58)) + _hill_offset_at(camera_z + rel_z) * p + road_y_offset
	var width := lerpf(road_width_near, road_width_far, pow(p, 0.78)) * road_scale_factor
	var center_x := road_center_at_rel(rel_z)
	return {
		"rel_z": rel_z,
		"y": y,
		"width": width,
		"center_x": center_x,
		"scale": lerpf(0.70, 0.08, p),
		"left": Vector2(center_x - width * 0.5, y),
		"right": Vector2(center_x + width * 0.5, y)
	}


func _hill_offset_at(world_z: float) -> float:
	var local_z := world_z - stage_origin_z
	var key := int(local_z / 32.0)
	if _hill_frame_cache.has(key):
		return float(_hill_frame_cache[key])
	var total := 0.0
	var hills: Array = level_data.get("hills", [])
	for row in hills:
		if not (row is Dictionary):
			continue
		var start := float(row.get("z", 0.0))
		var length := maxf(float(row.get("length", 1.0)), 1.0)
		if local_z >= start and local_z <= start + length:
			var t := clampf((local_z - start) / length, 0.0, 1.0)
			total += float(row.get("hill", 0.0)) * sin(t * PI)
	_hill_frame_cache[key] = total
	return total


func _refresh_screen_size() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	screen_size = viewport.get_visible_rect().size
	if screen_size.x <= 0.0 or screen_size.y <= 0.0:
		screen_size = Vector2(1280.0, 720.0)
	road_bottom_y = screen_size.y
	horizon_y = clampf(screen_size.y * 0.24, 132.0, 210.0)
	road_y_offset = clampf(screen_size.y * 0.105, 76.0, 126.0)
	road_width_near = clampf(screen_size.x * 0.62, 820.0, 1220.0)
	road_width_far = clampf(screen_size.x * 0.055, 64.0, 96.0)
	visible_distance = clampf(screen_size.y * 3.05, 2200.0, 3100.0)
	segment_count = 48 if perf_baseline else 86


func _theme_color(key: String, fallback: Color) -> Color:
	var current: Color = theme.get(key, fallback)
	if theme_blend <= 0.0 or previous_theme.is_empty():
		return current
	var previous: Color = previous_theme.get(key, current)
	return previous.lerp(current, 1.0 - theme_blend)


func _theme_id() -> String:
	return str(level_data.get("theme_id", ""))
