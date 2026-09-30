extends Node

signal settings_changed

var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0
var show_tooltips := true
var _touch_mode := "off"

func is_mobile_platform() -> bool: return false
func touch_controls_mode() -> String: return _touch_mode
func use_touch_controls() -> bool: return false
func set_show_tooltips(value: bool) -> void: show_tooltips = value; settings_changed.emit()
func set_touch_controls_mode(value: String) -> void: _touch_mode = value; settings_changed.emit()
func set_master_volume(value: float) -> void: master_volume = clampf(value, 0.0, 1.0); settings_changed.emit()
func set_music_volume(value: float) -> void: music_volume = clampf(value, 0.0, 1.0); settings_changed.emit()
func set_sfx_volume(value: float) -> void: sfx_volume = clampf(value, 0.0, 1.0); settings_changed.emit()

