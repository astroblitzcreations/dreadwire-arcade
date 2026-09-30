extends Control
@export var message: String = "JACKPOT!"
var label: Label
func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    label = Label.new()
    label.text = message
    label.add_theme_font_size_override("font_size", 32)
    label.add_theme_color_override("font_color", Color(1, .75, .2))
    add_child(label)
    scale = Vector2.ONE * .4
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2.ONE * 1.15, .16).set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "scale", Vector2.ONE, .12)
    tween.tween_interval(.9)
    tween.tween_property(self, "modulate:a", 0.0, .3)
    tween.tween_callback(queue_free)
