extends RefCounted
class_name InputBindings

const BINDINGS_PATH := "user://coc_input_bindings.cfg"
const ACTION_PREFIX := "coc_"
static var _runtime_bindings: Dictionary = {}

const ACTION_ROWS := [
	{"id": "move_up", "label": "Move Up"},
	{"id": "move_down", "label": "Move Down"},
	{"id": "move_left", "label": "Move Left / Brake"},
	{"id": "move_right", "label": "Move Right / Forward"},
	{"id": "jump", "label": "Jump / Hop"},
	{"id": "attack", "label": "Attack / Fire"},
	{"id": "boost", "label": "Run / Afterburner"},
	{"id": "pause", "label": "Pause / Menu"}
]

const DEFAULT_BINDINGS := {
	"move_up": {"keys": [KEY_W, KEY_UP], "joy_buttons": [JOY_BUTTON_DPAD_UP]},
	"move_down": {"keys": [KEY_S, KEY_DOWN], "joy_buttons": [JOY_BUTTON_DPAD_DOWN]},
	"move_left": {"keys": [KEY_A, KEY_LEFT], "joy_buttons": [JOY_BUTTON_DPAD_LEFT]},
	"move_right": {"keys": [KEY_D, KEY_RIGHT], "joy_buttons": [JOY_BUTTON_DPAD_RIGHT]},
	"jump": {"keys": [KEY_SPACE], "joy_buttons": [JOY_BUTTON_A]},
	"attack": {"keys": [KEY_ENTER, KEY_KP_ENTER], "joy_buttons": [JOY_BUTTON_X]},
	"boost": {"keys": [KEY_SHIFT, KEY_CTRL], "joy_buttons": [JOY_BUTTON_RIGHT_SHOULDER]},
	"pause": {"keys": [KEY_ESCAPE], "joy_buttons": [JOY_BUTTON_START, JOY_BUTTON_BACK]}
}


static func binding_rows() -> Array:
	return ACTION_ROWS.duplicate(true)


static func action_name(action_id: String) -> StringName:
	return StringName("%s%s" % [ACTION_PREFIX, action_id])


static func label_for(action_id: String) -> String:
	for row in ACTION_ROWS:
		if str(row.get("id", "")) == action_id:
			return str(row.get("label", action_id.capitalize()))
	return action_id.capitalize()


static func load_and_apply() -> Dictionary:
	var bindings := load_bindings()
	apply_bindings(bindings)
	_runtime_bindings = bindings.duplicate(true)
	return bindings


static func load_bindings() -> Dictionary:
	var bindings := DEFAULT_BINDINGS.duplicate(true)
	var config := ConfigFile.new()
	if config.load(BINDINGS_PATH) != OK:
		return bindings
	for row in ACTION_ROWS:
		var action_id := str(row.get("id", ""))
		if action_id.is_empty():
			continue
		var saved := {
			"keys": _int_array(config.get_value(action_id, "keys", bindings.get(action_id, {}).get("keys", []))),
			"joy_buttons": _int_array(config.get_value(action_id, "joy_buttons", bindings.get(action_id, {}).get("joy_buttons", [])))
		}
		var axis := int(config.get_value(action_id, "joy_axis", -1))
		var axis_value := float(config.get_value(action_id, "joy_axis_value", 0.0))
		if axis >= 0 and absf(axis_value) > 0.01:
			saved["joy_axis"] = axis
			saved["joy_axis_value"] = signf(axis_value)
		bindings[action_id] = saved
	return bindings


static func save_bindings(bindings: Dictionary) -> void:
	var config := ConfigFile.new()
	for row in ACTION_ROWS:
		var action_id := str(row.get("id", ""))
		var binding := _binding_for(bindings, action_id)
		config.set_value(action_id, "keys", _int_array(binding.get("keys", [])))
		config.set_value(action_id, "joy_buttons", _int_array(binding.get("joy_buttons", [])))
		config.set_value(action_id, "joy_axis", int(binding.get("joy_axis", -1)))
		config.set_value(action_id, "joy_axis_value", float(binding.get("joy_axis_value", 0.0)))
	config.save(BINDINGS_PATH)


static func reset_to_defaults() -> void:
	save_bindings(DEFAULT_BINDINGS.duplicate(true))
	apply_bindings(DEFAULT_BINDINGS.duplicate(true))


static func apply_bindings(bindings: Dictionary) -> void:
	_runtime_bindings = bindings.duplicate(true)
	for row in ACTION_ROWS:
		var action_id := str(row.get("id", ""))
		var input_action := action_name(action_id)
		if not InputMap.has_action(input_action):
			InputMap.add_action(input_action)
		InputMap.action_erase_events(input_action)
		var binding := _binding_for(bindings, action_id)
		for key in _int_array(binding.get("keys", [])):
			var key_event := InputEventKey.new()
			key_event.keycode = key
			InputMap.action_add_event(input_action, key_event)
		for joy_button in _int_array(binding.get("joy_buttons", [])):
			var joy_event := InputEventJoypadButton.new()
			joy_event.button_index = joy_button
			InputMap.action_add_event(input_action, joy_event)
		var joy_axis := int(binding.get("joy_axis", -1))
		var joy_axis_value := float(binding.get("joy_axis_value", 0.0))
		if joy_axis >= 0 and absf(joy_axis_value) > 0.01:
			var axis_event := InputEventJoypadMotion.new()
			axis_event.axis = joy_axis
			axis_event.axis_value = signf(joy_axis_value)
			InputMap.action_add_event(input_action, axis_event)


static func is_action_pressed(action_id: String, fallback_action := "") -> bool:
	var input_action := action_name(action_id)
	if InputMap.has_action(input_action) and Input.is_action_pressed(input_action):
		return true
	# Controller IDs are not stable on the cabinet because the built-in encoder,
	# Xbox/USB pads and web virtual pads can connect in different orders. Poll the
	# saved binding across every live device instead of assuming joypad 0.
	var binding := _binding_for(_runtime_bindings if not _runtime_bindings.is_empty() else load_bindings(), action_id)
	for device_id in Input.get_connected_joypads():
		for joy_button in _int_array(binding.get("joy_buttons", [])):
			if Input.is_joy_button_pressed(device_id, joy_button):
				return true
		var joy_axis := int(binding.get("joy_axis", -1))
		var joy_axis_value := float(binding.get("joy_axis_value", 0.0))
		if joy_axis >= 0 and absf(joy_axis_value) > 0.01:
			var axis_value := Input.get_joy_axis(device_id, joy_axis)
			if axis_value * signf(joy_axis_value) > 0.55:
				return true
	if not fallback_action.is_empty() and Input.is_action_pressed(fallback_action):
		return true
	return false


static func is_action_just_pressed(action_id: String, fallback_action := "") -> bool:
	var input_action := action_name(action_id)
	if InputMap.has_action(input_action) and Input.is_action_just_pressed(input_action):
		return true
	if not fallback_action.is_empty() and Input.is_action_just_pressed(fallback_action):
		return true
	return false


static func describe_binding(action_id: String) -> String:
	var binding := _binding_for(load_bindings(), action_id)
	var parts: Array[String] = []
	for key in _int_array(binding.get("keys", [])):
		parts.append(OS.get_keycode_string(key))
	for joy_button in _int_array(binding.get("joy_buttons", [])):
		parts.append(_joy_button_name(joy_button))
	var joy_axis := int(binding.get("joy_axis", -1))
	var joy_axis_value := float(binding.get("joy_axis_value", 0.0))
	if joy_axis >= 0 and absf(joy_axis_value) > 0.01:
		parts.append("Stick %s %s" % [str(joy_axis), "+" if joy_axis_value > 0.0 else "-"])
	return " / ".join(parts) if not parts.is_empty() else "Unbound"


static func set_binding_from_event(action_id: String, event: InputEvent) -> bool:
	var bindings := load_bindings()
	var binding := _binding_for(bindings, action_id)
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return false
		var keycode := int(key_event.keycode)
		if keycode == 0:
			keycode = int(key_event.physical_keycode)
		if keycode == 0:
			return false
		binding["keys"] = [keycode]
	elif event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		if not button_event.pressed:
			return false
		binding["joy_buttons"] = [int(button_event.button_index)]
	elif event is InputEventJoypadMotion:
		var motion_event := event as InputEventJoypadMotion
		if absf(motion_event.axis_value) < 0.55:
			return false
		binding["joy_axis"] = int(motion_event.axis)
		binding["joy_axis_value"] = signf(motion_event.axis_value)
	else:
		return false
	bindings[action_id] = binding
	save_bindings(bindings)
	apply_bindings(bindings)
	return true


static func _binding_for(bindings: Dictionary, action_id: String) -> Dictionary:
	var fallback = DEFAULT_BINDINGS.get(action_id, {}).duplicate(true)
	var binding = bindings.get(action_id, fallback)
	if binding is Dictionary:
		var result := (binding as Dictionary).duplicate(true)
		if not result.has("keys"):
			result["keys"] = fallback.get("keys", [])
		if not result.has("joy_buttons"):
			result["joy_buttons"] = fallback.get("joy_buttons", [])
		return result
	return fallback


static func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for entry in value:
			result.append(int(entry))
	elif value is PackedInt32Array:
		for entry in value:
			result.append(int(entry))
	return result


static func _joy_button_name(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_A:
			return "Pad A"
		JOY_BUTTON_B:
			return "Pad B"
		JOY_BUTTON_X:
			return "Pad X"
		JOY_BUTTON_Y:
			return "Pad Y"
		JOY_BUTTON_LEFT_SHOULDER:
			return "Pad LB"
		JOY_BUTTON_RIGHT_SHOULDER:
			return "Pad RB"
		JOY_BUTTON_BACK:
			return "Pad Back"
		JOY_BUTTON_START:
			return "Pad Start"
		JOY_BUTTON_DPAD_UP:
			return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN:
			return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT:
			return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT:
			return "D-Pad Right"
		_:
			return "Pad Button %d" % button_index
