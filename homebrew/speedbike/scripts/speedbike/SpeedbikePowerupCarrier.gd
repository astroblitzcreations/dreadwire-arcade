extends "res://scripts/speedbike/SpeedbikeDrone.gd"
class_name SpeedbikePowerupCarrier


func setup(row: Dictionary, mode_ref: Node) -> void:
	var carrier_row := row.duplicate(true)
	carrier_row["enemy_type"] = "powerup"
	carrier_row["health"] = carrier_row.get("health", 1)
	carrier_row["score_value"] = carrier_row.get("score_value", 300)
	super.setup(carrier_row, mode_ref)


func _draw() -> void:
	if destroyed:
		return
	super._draw()
	if drone_texture != null:
		return
	draw_rect(Rect2(-16.0, 18.0, 32.0, 24.0), Color(0.24, 0.28, 0.24, 0.94), true)
	draw_rect(Rect2(-14.0, 20.0, 28.0, 20.0), Color(0.18, 0.62, 0.24, 0.88), false, 2.0)
	draw_line(Vector2(-6.0, 30.0), Vector2(6.0, 30.0), Color(0.94, 1.0, 0.70, 0.96), 2.0, true)
	draw_line(Vector2(0.0, 24.0), Vector2(0.0, 36.0), Color(0.94, 1.0, 0.70, 0.96), 2.0, true)
	draw_circle(Vector2(0.0, 40.0), 2.0, Color(0.94, 1.0, 0.70, 0.96))
