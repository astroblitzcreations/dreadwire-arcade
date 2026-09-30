extends Node2D

const APP_SHELL_SCENE := "res://scenes/AppShell.tscn"
const TILE_SIZE := 24.0
const READY_DELAY := 0.9
const DEATH_DELAY := 1.25
const LEVEL_CLEAR_DELAY := 1.65
const DEMO_START_DELAY := 5.0
const EXTRA_LIFE_STEP := 7000
const FRUIT_ACTIVE_TIME := 9.0
const FRUIT_MOVE_SPEED := 54.0
const PACMAN_BASE_SPEED := 96.0
const GHOST_BASE_SPEED := 82.0
const FRIGHTENED_BASE_DURATION := 10.0
const FRIGHTENED_BLINK_WARNING_TIME := 2.1
const SIM_STEP := 1.0 / 120.0
const POWER_MODE_MAX_TIME := 18.0
const GHOST_EAT_ANIM_DURATION := 0.42
const GHOST_EAT_JAIL_DELAY := 2.35
const PACMAN_TUNNEL_TRANSIT_TIME := 0.42
const GHOST_TUNNEL_TRANSIT_TIME := 1.28
const PACMAN_TUNNEL_SPEED := 74.0
const GHOST_TUNNEL_SPEED := 42.0
const GHOST_STUN_TIME := 1.0
const DEMO_DECISION_COOLDOWN := 0.32
const DEMO_GOAL_HOLD_MIN := 0.85
const DEMO_GOAL_HOLD_MAX := 1.65
const DEMO_STUCK_REPLAN_TIME := 0.52
const DEMO_PANIC_THRESHOLD := 220.0
const DEMO_MEMORY_LIMIT := 18
const DEMO_HIGH_STAGE_CHANCE := 0.42
const DEMO_HIGH_STAGE_MIN := 3
const DEMO_HIGH_STAGE_MAX := 8
const ABILITY_FIRST_RECHARGE := 20.0
const ABILITY_SECOND_RECHARGE := 10.0
const ABILITY_TILT_RECHARGE := 45.0
const ABILITY_TILT_WINDOW := 5.0
const ABILITY_SHAKE_TIME := 0.48
const PAC_IDLE_TRIPPY_TIME := 5.0
const TRIPPY_STAGE_MAX := 10
const TOUCH_SWIPE_THRESHOLD := 22.0
const CHARLES_GHOST_INDEX := 0
const VEIL_GHOST_INDEX := 1
const PYRO_GHOST_INDEX := 2
const BISTRO_GHOST_INDEX := 3
const PACMAN_SPAWN := Vector2i(9, 17)
const FRUIT_CELL := Vector2i(9, 11)
const TUNNEL_ROW := 9
const TUNNEL_MARGIN := 18.0
const GHOST_SPAWNS := [Vector2i(9, 8), Vector2i(9, 9), Vector2i(8, 9), Vector2i(10, 9)]
const GHOST_RELEASE_DELAYS := [0.0, 2.0, 5.0, 8.0]
const GHOST_COLORS := [
	Color(1.0, 0.18, 0.18, 1.0),
	Color(1.0, 0.62, 0.82, 1.0),
	Color(0.34, 1.0, 1.0, 1.0),
	Color(1.0, 0.72, 0.3, 1.0)
]
const CHARLES_GHOST_TEXTURE := preload("res://assets/sprites/hidden/charles_ghost.png")
const VEIL_GHOST_TEXTURE := preload("res://assets/sprites/hidden/veil_ghost.png")
const PYRO_GHOST_TEXTURE := preload("res://assets/sprites/hidden/pyro_ghost.png")
const BISTRO_GHOST_TEXTURE := preload("res://assets/sprites/hidden/bistro_ghost.png")
const FRUIT_SEQUENCE := ["cherry", "strawberry", "orange", "apple", "melon", "galaxian", "bell", "key"]
const WALL_THEMES := [
	{"fill": Color(0.02, 0.06, 0.22, 1.0), "line": Color(0.1, 0.22, 0.98, 0.98), "gate": Color(1.0, 0.55, 0.88, 0.98)},
	{"fill": Color(0.12, 0.05, 0.16, 1.0), "line": Color(1.0, 0.44, 0.88, 0.98), "gate": Color(1.0, 0.76, 0.38, 0.98)},
	{"fill": Color(0.05, 0.13, 0.08, 1.0), "line": Color(0.48, 1.0, 0.62, 0.98), "gate": Color(1.0, 0.88, 0.32, 0.98)},
	{"fill": Color(0.14, 0.08, 0.02, 1.0), "line": Color(1.0, 0.74, 0.24, 0.98), "gate": Color(0.62, 0.88, 1.0, 0.98)}
]
const DIR_RIGHT := Vector2i(1, 0)
const DIR_LEFT := Vector2i(-1, 0)
const DIR_UP := Vector2i(0, -1)
const DIR_DOWN := Vector2i(0, 1)
const DIRECTIONS := [DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN]
const MAZE_LAYOUT := [
	"###################",
	"#o...............o#",
	"#.###.#####.###.#.#",
	"#........#........#",
	"#.###.#.#.#.#.###.#",
	"#.....#.#.#.#.....#",
	"###.#.#.#.#.#.#.###",
	"#...#.........#...#",
	"#.#.###.---.###.#.#",
	"...................",
	"#.#.###.###.###.#.#",
	"#...#.....#.....#.#",
	"###.#.#.#.#.#.#.###",
	"#.....#.#.#.#.....#",
	"#.###.#.#.#.#.###.#",
	"#........#........#",
	"#.###.#####.###.#.#",
	"#o...............o#",
	"#.###.#.#.#.#.###.#",
	"#.....#.#.#.#.....#",
	"###################"
]

var score := 0
var high_score := 0
var lives := 3
var level := 1
var game_state := "intro"
var state_timer := 0.0
var frightened_timer := 0.0
var frightened_chain := 0
var pellets: Dictionary = {}
var initial_pellet_count := 0
var anim_time := 0.0
var fruit := {
	"active": false,
	"timer": 0.0,
	"spawns_done": 0,
	"cell": FRUIT_CELL,
	"target_cell": FRUIT_CELL,
	"position": Vector2.ZERO,
	"direction": Vector2i.ZERO,
	"bounce_phase": 0.0
}
var next_extra_life_score := EXTRA_LIFE_STEP
var pacman := {}
var ghosts: Array[Dictionary] = []
var _sim_accumulator := 0.0
var _last_real_ticks_usec := 0
var _previous_time_scale := 1.0
var _pac_move_sound_cooldown := 0.0
var power_combo_pellets := 0
var power_combo_ghosts := 0
var power_combo_power_balls := 0
var power_combo_flash_timer := 0.0
var ability_charges := 2
var ability_recent_use_timer := 0.0
var ability_recharge_timers: Array[float] = []
var ability_tilt_timer := 0.0
var screen_shake_timer := 0.0
var screen_shake_strength := 0.0
var demo_mode := false
var demo_goal_cell := PACMAN_SPAWN
var demo_goal_kind := ""
var demo_goal_hold_timer := 0.0
var demo_decision_timer := 0.0
var demo_last_cell := PACMAN_SPAWN
var demo_stuck_timer := 0.0
var demo_last_goal_distance := INF
var demo_recent_cells: Array[Vector2i] = []
var demo_cell_bias: Dictionary = {}
var touch_controls_enabled := false
var touch_drag_active := false
var touch_drag_start := Vector2.ZERO
var touch_drag_last := Vector2.ZERO
var fullscreen_fill_enabled := false
var presentation_orientation := "landscape"
var presentation_fit_mode := "fill"
var pac_idle_timer := 0.0
var trippy_mode_active := false
var trippy_mode_strength := 0.0
var trippy_mode_level := 0
var pac_idle_trippy_claimed := false
var menu_selection := 0
var joy_axis_latched: Dictionary = {}
const MENU_ITEMS := ["START GAME", "FULL SCREEN", "SCREEN FIT / FILL", "EXIT TO ARCADE"]
const PAUSE_ITEMS := ["RESUME GAME", "RESTART GAME", "RECONFIGURE CONTROLLER", "MUSIC", "SCREEN FIT / FILL", "FULL SCREEN", "DISPLAY BUTTONS", "CONTROLLER HELP", "EXIT TO ARCADE"]
const CONTROL_ACTIONS := ["UP", "DOWN", "LEFT", "RIGHT", "TILT / ACTION", "PAUSE", "SELECT", "START"]
var pause_open := false
var pause_selection := 0
var music_enabled := true
var display_buttons_enabled := false
var controller_help_timer := 0.0
var exit_confirm_timer := 0.0
var joy_button_states: Dictionary = {}
var exit_chord_latched: Dictionary = {}
var control_wizard_open := false
var control_wizard_step := 0
var control_wizard_device := -1
var control_wizard_name := ""
var control_wizard_hold_button := -1
var control_wizard_hold_time := 0.0
var controller_mappings: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if get_tree() != null:
		get_tree().paused = false
	_previous_time_scale = Engine.time_scale
	Engine.time_scale = 1.0
	OS.low_processor_usage_mode = false
	OS.low_processor_usage_mode_sleep_usec = 0
	Engine.max_fps = 0
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	touch_controls_enabled = AppState.use_touch_controls()
	fullscreen_fill_enabled = true
	var viewport_size := get_viewport_rect().size
	# X11 already rotates the physical portrait display. Keep game coordinates upright.
	presentation_orientation = "landscape"
	presentation_fit_mode = "fit"
	_last_real_ticks_usec = Time.get_ticks_usec()
	_sim_accumulator = 0.0
	_reset_run_state(false)
	game_state = "intro"
	menu_selection = 0
	state_timer = 0.0
	SoundDirector.start_maze_music()
	_load_controller_mappings()
	_load_display_settings()
	queue_redraw()


func _exit_tree() -> void:
	SoundDirector.stop_maze_music()
	Engine.time_scale = _previous_time_scale

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		_handle_joy_motion(event as InputEventJoypadMotion)
		return
	if event is InputEventJoypadButton:
		_handle_joy_button(event as InputEventJoypadButton)
		return
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed and _handle_ui_button_press(touch_event.position):
			return
		if not touch_controls_enabled:
			return
		if touch_event.pressed:
			if _touch_tilt_button_rect().has_point(touch_event.position):
				if game_state == "play":
					_activate_tilt_burst()
				return
			if game_state in ["intro", "game_over"] or demo_mode:
				_start_new_run(false)
				return
			touch_drag_active = true
			touch_drag_start = touch_event.position
			touch_drag_last = touch_event.position
		else:
			touch_drag_active = false
		return
	if event is InputEventScreenDrag:
		if not touch_controls_enabled or game_state not in ["ready", "play"] or demo_mode:
			return
		var drag_event := event as InputEventScreenDrag
		if not touch_drag_active:
			touch_drag_active = true
			touch_drag_start = drag_event.position
		touch_drag_last = drag_event.position
		_handle_touch_swipe(drag_event.position - touch_drag_start)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
				return
			KEY_ENTER, KEY_KP_ENTER:
				if game_state in ["intro", "game_over"] or demo_mode:
					_activate_menu_item()
					return
				if game_state == "play":
					_activate_tilt_burst()
					return
			KEY_SPACE:
				if demo_mode:
					_start_new_run(false)
					return
				if game_state == "play":
					_activate_tilt_burst()
					return
			KEY_LEFT, KEY_A:
				_handle_navigation(DIR_LEFT)
			KEY_RIGHT, KEY_D:
				if demo_mode:
					_start_new_run(false)
				_handle_navigation(DIR_RIGHT)
			KEY_UP, KEY_W:
				if demo_mode:
					_start_new_run(false)
				_handle_navigation(DIR_UP)
			KEY_DOWN, KEY_S:
				if demo_mode:
					_start_new_run(false)
				_handle_navigation(DIR_DOWN)
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if _handle_ui_button_press(mouse_event.position):
				return


func _handle_joy_motion(event: InputEventJoypadMotion) -> void:
	var key := "%d:%d" % [event.device, event.axis]
	var active := absf(event.axis_value) >= 0.58
	var was_active := bool(joy_axis_latched.get(key, false))
	joy_axis_latched[key] = active
	if not active or was_active:
		return
	if control_wizard_open:
		control_wizard_device = event.device
		control_wizard_name = Input.get_joy_name(event.device)
		_store_control_binding(CONTROL_ACTIONS[control_wizard_step], "axis,%d,%d" % [event.axis, 1 if event.axis_value > 0.0 else -1])
		_advance_control_wizard()
		return
	var device_name := Input.get_joy_name(event.device).to_lower()
	var mapped_action := _mapped_axis_action(device_name, event.axis, event.axis_value)
	if not mapped_action.is_empty():
		_dispatch_control_action(mapped_action)
		return
	var direction := Vector2i.ZERO
	if "dragonrise" in device_name or "generic usb joystick" in device_name:
		# The cabinet encoder is mounted 90 degrees. Match its proven EmulationStation map.
		if event.axis == JOY_AXIS_LEFT_X:
			direction = DIR_DOWN if event.axis_value > 0.0 else DIR_UP
		elif event.axis == JOY_AXIS_LEFT_Y:
			direction = DIR_LEFT if event.axis_value > 0.0 else DIR_RIGHT
	else:
		if event.axis == JOY_AXIS_LEFT_X or event.axis == JOY_AXIS_RIGHT_X:
			direction = DIR_RIGHT if event.axis_value > 0.0 else DIR_LEFT
		elif event.axis == JOY_AXIS_LEFT_Y or event.axis == JOY_AXIS_RIGHT_Y:
			direction = DIR_DOWN if event.axis_value > 0.0 else DIR_UP
	if direction != Vector2i.ZERO:
		_handle_navigation(direction)


func _handle_joy_button(event: InputEventJoypadButton) -> void:
	joy_button_states["%d:%d" % [event.device, event.button_index]] = event.pressed
	var device_name := Input.get_joy_name(event.device).to_lower()
	var cabinet := "dragonrise" in device_name or "generic usb joystick" in device_name
	if control_wizard_open:
		if event.pressed:
			control_wizard_device = event.device
			control_wizard_name = Input.get_joy_name(event.device)
			control_wizard_hold_button = event.button_index
			control_wizard_hold_time = 0.0
		else:
			if control_wizard_hold_button == event.button_index and control_wizard_hold_time < 0.9:
				_store_control_binding(CONTROL_ACTIONS[control_wizard_step], "button,%d" % event.button_index)
				_advance_control_wizard()
			control_wizard_hold_button = -1
		return
	var start_down := bool(joy_button_states.get("%d:%d" % [event.device, JOY_BUTTON_START], false)) or (cabinet and bool(joy_button_states.get("%d:7" % event.device, false)))
	var select_down := bool(joy_button_states.get("%d:%d" % [event.device, JOY_BUTTON_BACK], false)) or (cabinet and bool(joy_button_states.get("%d:5" % event.device, false)))
	var chord_key := str(event.device)
	if start_down and select_down:
		if not bool(exit_chord_latched.get(chord_key, false)):
			exit_chord_latched[chord_key] = true
			if exit_confirm_timer > 0.0:
				get_tree().quit()
			else:
				exit_confirm_timer = 2.0
				queue_redraw()
		return
	else:
		exit_chord_latched[chord_key] = false
	if not event.pressed:
		return
	var mapped_button_action := _mapped_button_action(device_name, event.button_index)
	if not mapped_button_action.is_empty():
		_dispatch_control_action(mapped_button_action)
		return
	var is_start := event.button_index == JOY_BUTTON_START or (cabinet and event.button_index == 7)
	if pause_open:
		if event.button_index in [JOY_BUTTON_A, JOY_BUTTON_X, JOY_BUTTON_START]:
			_activate_pause_item()
		elif event.button_index == JOY_BUTTON_B:
			_set_pause(false)
		return
	if is_start and game_state not in ["intro", "game_over"]:
		_set_pause(true)
		return
	if event.button_index in [JOY_BUTTON_A, JOY_BUTTON_X, JOY_BUTTON_START]:
		if game_state in ["intro", "game_over"] or demo_mode:
			_activate_menu_item()
		elif game_state == "play":
			_activate_tilt_burst()
	elif event.button_index == JOY_BUTTON_B and game_state in ["intro", "game_over"]:
		get_tree().quit()


func _handle_navigation(direction: Vector2i) -> void:
	if pause_open:
		var pause_step := 1 if direction.y > 0 or direction.x > 0 else -1
		pause_selection = wrapi(pause_selection + pause_step, 0, PAUSE_ITEMS.size())
		queue_redraw()
		return
	if game_state in ["intro", "game_over"]:
		if direction.y != 0 or direction.x != 0:
			var step := 1 if direction.y > 0 or direction.x > 0 else -1
			menu_selection = wrapi(menu_selection + step, 0, MENU_ITEMS.size())
			queue_redraw()
		return
	if demo_mode:
		_start_new_run(false)
	_handle_direction_press(direction)


func _activate_menu_item() -> void:
	match menu_selection:
		0:
			_start_new_run(false)
		1:
			_toggle_fullscreen_fill()
		2:
			_toggle_presentation_fit_mode()
		3:
			get_tree().quit()
	queue_redraw()


func _set_pause(open: bool) -> void:
	pause_open = open
	pause_selection = 0
	queue_redraw()


func _activate_pause_item() -> void:
	match pause_selection:
		0:
			_set_pause(false)
		1:
			_set_pause(false)
			_start_new_run(false)
		2:
			_start_control_wizard()
		3:
			music_enabled = not music_enabled
			SoundDirector.set_maze_music_enabled(music_enabled)
		4:
			_toggle_presentation_fit_mode()
		5:
			_toggle_fullscreen_fill()
		6:
			display_buttons_enabled = not display_buttons_enabled
			_save_display_settings()
		7:
			controller_help_timer = 5.0
		8:
			get_tree().quit()
	queue_redraw()


func _handle_direction_press(direction: Vector2i) -> void:
	if game_state == "intro":
		_start_new_run()
	if game_state in ["ready", "play"]:
		_set_pacman_wanted_direction(direction)


func _handle_touch_swipe(delta: Vector2) -> void:
	if delta.length() < TOUCH_SWIPE_THRESHOLD:
		return
	if absf(delta.x) >= absf(delta.y):
		_handle_direction_press(DIR_RIGHT if delta.x > 0.0 else DIR_LEFT)
	else:
		_handle_direction_press(DIR_DOWN if delta.y > 0.0 else DIR_UP)
	touch_drag_start = touch_drag_last


func _handle_ui_button_press(position: Vector2) -> bool:
	if not display_buttons_enabled:
		return false
	if _ui_hit_rect(_fullscreen_button_rect()).has_point(position):
		_toggle_fullscreen_fill()
		return true
	if _ui_hit_rect(_orientation_button_rect()).has_point(position):
		_toggle_presentation_orientation()
		return true
	if _ui_hit_rect(_fit_button_rect()).has_point(position):
		_toggle_presentation_fit_mode()
		return true
	return false


func _process(delta: float) -> void:
	exit_confirm_timer = maxf(exit_confirm_timer - delta, 0.0)
	controller_help_timer = maxf(controller_help_timer - delta, 0.0)
	if control_wizard_open and control_wizard_hold_button >= 0:
		control_wizard_hold_time += delta
		if control_wizard_hold_time >= 0.9:
			control_wizard_hold_button = -1
			_advance_control_wizard()
	var now_usec := Time.get_ticks_usec()
	var real_delta := clampf(float(now_usec - _last_real_ticks_usec) / 1000000.0, 0.0, 0.1)
	_last_real_ticks_usec = now_usec
	anim_time += real_delta
	_sim_accumulator = minf(_sim_accumulator + real_delta, 0.25)
	while _sim_accumulator >= SIM_STEP:
		_simulate_step(SIM_STEP)
		_sim_accumulator -= SIM_STEP
	queue_redraw()


func _simulate_step(delta: float) -> void:
	if pause_open:
		return
	match game_state:
		"ready":
			state_timer = maxf(state_timer - delta, 0.0)
			if state_timer <= 0.0:
				game_state = "play"
		"play":
			_update_play(delta)
		"dead":
			state_timer = maxf(state_timer - delta, 0.0)
			if state_timer <= 0.0:
				if lives <= 0:
					game_state = "game_over"
					state_timer = DEMO_START_DELAY
				else:
					_reset_positions(true)
					game_state = "ready"
					state_timer = READY_DELAY
		"level_clear":
			state_timer = maxf(state_timer - delta, 0.0)
			if state_timer <= 0.0:
				_begin_next_level()
		"game_over":
			state_timer = maxf(state_timer - delta, 0.0)
			if state_timer <= 0.0:
				_start_new_run(true)


func _current_wall_theme() -> Dictionary:
	return WALL_THEMES[(level - 1) % WALL_THEMES.size()]


func _start_new_run(start_demo := false) -> void:
	demo_mode = start_demo
	score = 0
	lives = 3
	level = _demo_start_level() if start_demo else 1
	next_extra_life_score = EXTRA_LIFE_STEP
	if start_demo:
		_demo_decay_cell_bias()
	else:
		demo_cell_bias.clear()
	_reset_run_state(true)


func _begin_next_level() -> void:
	level += 1
	_increase_trippy_level()
	_reset_run_state(false)


func _increase_trippy_level(amount := 1) -> void:
	trippy_mode_level = mini(trippy_mode_level + amount, TRIPPY_STAGE_MAX)
	if trippy_mode_level > 0:
		trippy_mode_active = true


func _reset_run_state(full_reset_score: bool) -> void:
	SoundDirector.stop_pac_super()
	frightened_timer = 0.0
	frightened_chain = 0
	_pac_move_sound_cooldown = 0.0
	power_combo_pellets = 0
	power_combo_ghosts = 0
	power_combo_power_balls = 0
	power_combo_flash_timer = 0.0
	ability_charges = 2
	ability_recent_use_timer = 0.0
	ability_recharge_timers.clear()
	ability_tilt_timer = 0.0
	screen_shake_timer = 0.0
	screen_shake_strength = 0.0
	pac_idle_timer = 0.0
	pac_idle_trippy_claimed = false
	if full_reset_score:
		trippy_mode_active = false
		trippy_mode_strength = 0.0
		trippy_mode_level = 0
	if full_reset_score:
		score = 0
		lives = 3
		next_extra_life_score = EXTRA_LIFE_STEP
		level = max(level, 1)
	_reset_board()
	_reset_positions(false)
	game_state = "ready"
	state_timer = READY_DELAY


func _reset_demo_state() -> void:
	demo_goal_cell = PACMAN_SPAWN
	demo_goal_kind = ""
	demo_goal_hold_timer = 0.0
	demo_decision_timer = 0.0
	demo_last_cell = PACMAN_SPAWN
	demo_stuck_timer = 0.0
	demo_last_goal_distance = INF
	demo_recent_cells.clear()


func _demo_start_level() -> int:
	if randf() >= DEMO_HIGH_STAGE_CHANCE:
		return 1
	return randi_range(DEMO_HIGH_STAGE_MIN, DEMO_HIGH_STAGE_MAX)


func _demo_decay_cell_bias() -> void:
	if demo_cell_bias.is_empty():
		return
	var next_bias: Dictionary = {}
	for cell_key in demo_cell_bias.keys():
		var cell := cell_key as Vector2i
		var value := float(demo_cell_bias.get(cell, 0.0)) * 0.64
		if value >= 0.35:
			next_bias[cell] = value
	demo_cell_bias = next_bias


func _demo_note_cell_visit(cell: Vector2i) -> void:
	if demo_recent_cells.is_empty() or demo_recent_cells[demo_recent_cells.size() - 1] != cell:
		demo_recent_cells.append(cell)
		while demo_recent_cells.size() > DEMO_MEMORY_LIMIT:
			demo_recent_cells.remove_at(0)
	var recent_count := demo_recent_cells.size()
	if recent_count >= 4:
		var newest := demo_recent_cells[recent_count - 1]
		var newest_pair := demo_recent_cells[recent_count - 2]
		if newest == demo_recent_cells[recent_count - 3] and newest_pair == demo_recent_cells[recent_count - 4]:
			demo_cell_bias[newest] = minf(float(demo_cell_bias.get(newest, 0.0)) + 5.4, 44.0)
			demo_cell_bias[newest_pair] = minf(float(demo_cell_bias.get(newest_pair, 0.0)) + 5.4, 44.0)


func _demo_revisit_penalty(cell: Vector2i) -> float:
	var penalty := float(demo_cell_bias.get(cell, 0.0))
	var recency_weight := 7.0
	for index in range(demo_recent_cells.size() - 1, -1, -1):
		if demo_recent_cells[index] == cell:
			penalty += recency_weight
		recency_weight *= 0.74
	return penalty


func _demo_forward_lane_value(cell: Vector2i, direction: Vector2i) -> float:
	if direction == Vector2i.ZERO:
		return -INF
	var score_value := 0.0
	var cursor := cell
	for step in range(1, 6):
		cursor = _demo_step_cell(cursor, direction)
		score_value += _demo_local_pellet_value(cursor) / float(step)
		score_value -= _demo_revisit_penalty(cursor) * (0.42 / float(step))
		score_value -= _demo_danger_penalty(cursor) * (0.004 / float(step))
	return score_value


func _reset_board() -> void:
	pellets.clear()
	initial_pellet_count = 0
	for row in range(MAZE_LAYOUT.size()):
		var line := String(MAZE_LAYOUT[row])
		for column in range(line.length()):
			var cell := Vector2i(column, row)
			if _is_ghost_gate(cell) or _is_ghost_house_cell(cell):
				continue
			match line.substr(column, 1):
				".":
					pellets[cell] = 10
					initial_pellet_count += 1
				"o":
					pellets[cell] = 50
					initial_pellet_count += 1
	fruit["active"] = false
	fruit["timer"] = 0.0
	fruit["spawns_done"] = 0
	fruit["cell"] = FRUIT_CELL
	fruit["target_cell"] = FRUIT_CELL
	fruit["position"] = _cell_center(FRUIT_CELL)
	fruit["direction"] = Vector2i.ZERO
	fruit["bounce_phase"] = randf() * TAU


func _level_pacman_speed() -> float:
	return (PACMAN_BASE_SPEED + float(level - 1) * 5.5) * _powered_speed_multiplier()


func _level_ghost_speed() -> float:
	return GHOST_BASE_SPEED + float(level - 1) * 6.0


func _level_frightened_duration() -> float:
	return FRIGHTENED_BASE_DURATION


func _fruit_kind_for_level(level_value: int) -> String:
	if level_value <= 1:
		return FRUIT_SEQUENCE[0]
	if level_value >= 8:
		return "key"
	return FRUIT_SEQUENCE[level_value - 1]


func _fruit_score_for_level(level_value: int) -> int:
	match _fruit_kind_for_level(level_value):
		"cherry":
			return 100
		"strawberry":
			return 300
		"orange":
			return 500
		"apple":
			return 700
		"melon":
			return 1000
		"galaxian":
			return 2000
		"bell":
			return 3000
		"key":
			return 5000
		_:
			return 100


func _fruit_counter_kinds_for_level(level_value: int) -> Array[String]:
	var icons: Array[String] = []
	if level_value <= 0:
		return icons
	var max_icons := 7
	if level_value <= 8:
		for entry_level in range(1, level_value + 1):
			icons.append(_fruit_kind_for_level(entry_level))
		return icons
	for entry_level in range(level_value - max_icons + 1, level_value + 1):
		icons.append(_fruit_kind_for_level(entry_level))
	return icons


func _release_delay_for_ghost(ghost_index: int, after_death: bool) -> float:
	if after_death:
		return float([2.4, 6.0, 9.5, 13.0][ghost_index])
	var base_delay: float = float(GHOST_RELEASE_DELAYS[ghost_index])
	if level <= 1:
		base_delay += float([1.1, 2.4, 3.8, 5.2][ghost_index])
	elif level == 2:
		base_delay += float([0.6, 1.2, 2.2, 3.3][ghost_index])
	return base_delay


func _special_ghost_kind_for_index(ghost_index: int) -> String:
	match ghost_index:
		CHARLES_GHOST_INDEX:
			return "charles"
		VEIL_GHOST_INDEX:
			return "veil"
		PYRO_GHOST_INDEX:
			return "pyro"
		BISTRO_GHOST_INDEX:
			return "bistro"
		_:
			return ""


func _reset_positions(after_death := false) -> void:
	pacman = {
		"cell": PACMAN_SPAWN,
		"position": _cell_center(PACMAN_SPAWN),
		"direction": DIR_LEFT,
		"wanted_direction": DIR_LEFT,
		"target_cell": PACMAN_SPAWN,
		"travel_from": PACMAN_SPAWN,
		"tunnel_speed": PACMAN_TUNNEL_SPEED,
		"tunnel_active": false,
		"tunnel_timer": 0.0,
		"tunnel_duration": PACMAN_TUNNEL_TRANSIT_TIME,
		"tunnel_from": PACMAN_SPAWN,
		"tunnel_to": PACMAN_SPAWN
	}
	ghosts.clear()
	for ghost_index in range(GHOST_SPAWNS.size()):
		ghosts.append({
			"cell": GHOST_SPAWNS[ghost_index],
			"position": _cell_center(GHOST_SPAWNS[ghost_index]),
			"direction": DIR_UP if ghost_index == 0 and not after_death else DIR_DOWN,
			"spawn_cell": GHOST_SPAWNS[ghost_index],
			"target_cell": GHOST_SPAWNS[ghost_index],
			"frightened": false,
			"returning": false,
			"released": ghost_index == 0 and not after_death,
			"release_timer": 0.0 if ghost_index == 0 and not after_death else _release_delay_for_ghost(ghost_index, after_death),
			"power_jail_hold": false,
			"house_phase": 0.0,
			"stun_timer": 0.0,
			"color": GHOST_COLORS[ghost_index % GHOST_COLORS.size()],
			"special_kind": "",
			"eaten_anim": 0.0,
			"eaten_total": GHOST_EAT_ANIM_DURATION,
			"eaten_origin": _cell_center(GHOST_SPAWNS[ghost_index]),
			"eaten_target": _cell_center(GHOST_SPAWNS[ghost_index]),
			"tunnel_speed": GHOST_TUNNEL_SPEED,
			"tunnel_active": false,
			"tunnel_timer": 0.0,
			"tunnel_duration": GHOST_TUNNEL_TRANSIT_TIME,
			"tunnel_from": GHOST_SPAWNS[ghost_index],
			"tunnel_to": GHOST_SPAWNS[ghost_index]
		})
	_reset_demo_state()


func _maze_origin() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var maze_size := Vector2(_maze_width(), _maze_height()) * TILE_SIZE
	return Vector2(
		floor((viewport_size.x - maze_size.x) * 0.5),
		floor((viewport_size.y - maze_size.y) * 0.5 + 18.0)
	)


func _maze_width() -> int:
	return String(MAZE_LAYOUT[0]).length()


func _maze_height() -> int:
	return MAZE_LAYOUT.size()


func _cell_center(cell: Vector2i) -> Vector2:
	if cell.y == TUNNEL_ROW:
		var origin := _maze_origin()
		if cell.x == -1:
			return Vector2(origin.x - TILE_SIZE * 0.5 - TUNNEL_MARGIN, origin.y + (float(cell.y) + 0.5) * TILE_SIZE)
		if cell.x == _maze_width():
			return Vector2(origin.x + (float(_maze_width()) + 0.5) * TILE_SIZE + TUNNEL_MARGIN, origin.y + (float(cell.y) + 0.5) * TILE_SIZE)
	return _maze_origin() + (Vector2(cell) + Vector2(0.5, 0.5)) * TILE_SIZE


func _world_to_cell(world_position: Vector2) -> Vector2i:
	var local := (world_position - _maze_origin()) / TILE_SIZE
	if int(floor(local.y)) == TUNNEL_ROW:
		if world_position.x < _maze_origin().x:
			return Vector2i(-1, TUNNEL_ROW)
		if world_position.x > _maze_origin().x + float(_maze_width()) * TILE_SIZE:
			return Vector2i(_maze_width(), TUNNEL_ROW)
	return Vector2i(int(floor(local.x)), int(floor(local.y)))


func _cell_is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.y < _maze_height() and cell.x < _maze_width()


func _cell_is_wall(cell: Vector2i) -> bool:
	if cell.y == TUNNEL_ROW and (cell.x < 0 or cell.x >= _maze_width()):
		return false
	if not _cell_is_inside(cell):
		return true
	var line := String(MAZE_LAYOUT[cell.y])
	var tile := line.substr(cell.x, 1)
	return tile == "#"


func _is_ghost_house_cell(cell: Vector2i) -> bool:
	return cell.y == 9 and cell.x >= 8 and cell.x <= 10


func _cell_is_open(cell: Vector2i) -> bool:
	if _is_ghost_gate(cell) or _is_ghost_house_cell(cell):
		return false
	return not _cell_is_wall(cell)


func _is_ghost_gate(cell: Vector2i) -> bool:
	if not _cell_is_inside(cell):
		return false
	var line := String(MAZE_LAYOUT[cell.y])
	return line.substr(cell.x, 1) == "-"


func _cell_is_open_for_ghost(cell: Vector2i, ghost: Dictionary) -> bool:
	if _is_ghost_house_cell(cell):
		return bool(ghost.get("returning", false)) or not bool(ghost.get("released", false))
	if _is_ghost_gate(cell):
		return bool(ghost.get("released", false)) or bool(ghost.get("returning", false))
	return _cell_is_open(cell)


func _ghost_jail_delay_after_eaten(ghost_index: int) -> float:
	return GHOST_EAT_JAIL_DELAY + float(ghost_index) * 0.45


func _reverse_dir(dir: Vector2i) -> Vector2i:
	return Vector2i(-dir.x, -dir.y)


func _dir_to_vec2(dir: Vector2i) -> Vector2:
	return Vector2(float(dir.x), float(dir.y))


func _wrap_tunnel_cell(cell: Vector2i) -> Vector2i:
	if cell.y != TUNNEL_ROW:
		return cell
	if cell.x < -1:
		return Vector2i(_maze_width(), cell.y)
	if cell.x > _maze_width():
		return Vector2i(-1, cell.y)
	return cell


func _is_tunnel_warp_cell(cell: Vector2i) -> bool:
	return cell.y == TUNNEL_ROW and (cell.x == -1 or cell.x == _maze_width())


func _opposite_tunnel_cell(cell: Vector2i) -> Vector2i:
	if cell.y != TUNNEL_ROW:
		return cell
	if cell.x == -1:
		return Vector2i(_maze_width(), cell.y)
	if cell.x == _maze_width():
		return Vector2i(-1, cell.y)
	return cell


func _tunnel_destination_cell(cell: Vector2i) -> Vector2i:
	if cell.y != TUNNEL_ROW:
		return cell
	if cell.x == -1:
		return Vector2i(_maze_width() - 1, cell.y)
	if cell.x == _maze_width():
		return Vector2i(0, cell.y)
	return cell


func _tunnel_entry_warp_cell(actor: Dictionary) -> Vector2i:
	var destination: Vector2i = actor.get("tunnel_to", actor.get("cell", PACMAN_SPAWN))
	if destination.y != TUNNEL_ROW:
		return destination
	if destination.x == 0:
		return Vector2i(_maze_width(), destination.y)
	return Vector2i(-1, destination.y)


func _tunnel_exit_warp_cell(actor: Dictionary) -> Vector2i:
	var destination: Vector2i = actor.get("tunnel_to", actor.get("cell", PACMAN_SPAWN))
	if destination.y != TUNNEL_ROW:
		return destination
	if destination.x == 0:
		return Vector2i(-1, destination.y)
	return Vector2i(_maze_width(), destination.y)


func _is_actor_in_tunnel_transit(cell: Vector2i, target_cell: Vector2i, tunnel_active := false) -> bool:
	if tunnel_active:
		return true
	if cell.y != TUNNEL_ROW and target_cell.y != TUNNEL_ROW:
		return false
	return _is_tunnel_warp_cell(cell) or _is_tunnel_warp_cell(target_cell)


func _begin_tunnel_transit(actor: Dictionary, from_cell: Vector2i, warp_cell: Vector2i, duration: float) -> Dictionary:
	var destination := _tunnel_destination_cell(warp_cell)
	var path_distance := _tunnel_path_distance(from_cell, destination)
	actor["tunnel_active"] = true
	actor["tunnel_timer"] = 0.0
	actor["tunnel_duration"] = maxf(duration, path_distance / maxf(float(actor.get("tunnel_speed", PACMAN_TUNNEL_SPEED)), 1.0))
	actor["tunnel_from"] = from_cell
	actor["tunnel_to"] = destination
	actor["cell"] = from_cell
	actor["target_cell"] = from_cell
	actor["position"] = _cell_center(from_cell)
	return actor


func _tunnel_path_distance(from_cell: Vector2i, destination_cell: Vector2i) -> float:
	var actor := {
		"tunnel_from": from_cell,
		"tunnel_to": destination_cell,
		"cell": from_cell
	}
	var from_center := _cell_center(from_cell)
	var entry_center := _cell_center(_tunnel_entry_warp_cell(actor))
	var destination_center := _cell_center(destination_cell)
	var exit_center := _cell_center(_tunnel_exit_warp_cell(actor))
	return from_center.distance_to(entry_center) + exit_center.distance_to(destination_center)


func _update_tunnel_transit(actor: Dictionary, delta: float) -> Dictionary:
	var timer := minf(float(actor.get("tunnel_timer", 0.0)) + delta, float(actor.get("tunnel_duration", PACMAN_TUNNEL_TRANSIT_TIME)))
	actor["tunnel_timer"] = timer
	if timer >= float(actor.get("tunnel_duration", PACMAN_TUNNEL_TRANSIT_TIME)):
		var destination: Vector2i = actor.get("tunnel_to", actor.get("cell", PACMAN_SPAWN))
		actor["tunnel_active"] = false
		actor["cell"] = destination
		actor["target_cell"] = destination
		actor["position"] = _cell_center(destination)
		if actor.has("travel_from"):
			actor["travel_from"] = destination
	return actor


func _tunnel_draw_center(actor: Dictionary) -> Vector2:
	if not bool(actor.get("tunnel_active", false)):
		return actor.get("position", Vector2.ZERO)
	var progress := clampf(float(actor.get("tunnel_timer", 0.0)) / maxf(float(actor.get("tunnel_duration", PACMAN_TUNNEL_TRANSIT_TIME)), 0.001), 0.0, 1.0)
	var from_center := _cell_center(actor.get("tunnel_from", actor.get("cell", PACMAN_SPAWN)))
	var destination_center := _cell_center(actor.get("tunnel_to", actor.get("cell", PACMAN_SPAWN)))
	var entry_center := _cell_center(_tunnel_entry_warp_cell(actor))
	var exit_center := _cell_center(_tunnel_exit_warp_cell(actor))
	if progress < 0.5:
		return from_center.lerp(entry_center, progress / 0.5)
	return exit_center.lerp(destination_center, (progress - 0.5) / 0.5)


func _tunnel_draw_alpha(actor: Dictionary) -> float:
	return 1.0


func _move_toward_point(position: Vector2, target: Vector2, distance: float) -> Vector2:
	var to_target := target - position
	var remaining := to_target.length()
	if remaining <= 0.0001:
		return target
	if distance >= remaining:
		return target
	return position + to_target / remaining * distance


func _set_pacman_wanted_direction(direction: Vector2i) -> void:
	if pacman.is_empty():
		return
	pacman["wanted_direction"] = direction


func _screen_shake_offset() -> Vector2:
	if screen_shake_timer <= 0.0 or screen_shake_strength <= 0.0:
		return Vector2.ZERO
	var fade := clampf(screen_shake_timer / ABILITY_SHAKE_TIME, 0.0, 1.0)
	return Vector2(
		sin(anim_time * 62.0) * screen_shake_strength * fade,
		cos(anim_time * 54.0) * screen_shake_strength * 0.72 * fade
	)


func _ui_safe_rect() -> Rect2:
	var viewport_rect := get_viewport_rect()
	var safe_area := Rect2(DisplayServer.get_display_safe_area())
	if safe_area.size.x <= 1.0 or safe_area.size.y <= 1.0:
		return viewport_rect
	return safe_area


func _ui_hit_rect(rect: Rect2) -> Rect2:
	return rect.grow(22.0 if touch_controls_enabled else 6.0)


func _show_panel_display_controls() -> bool:
	return game_state in ["intro", "game_over"]


func _center_message_panel_rect(center: Vector2) -> Rect2:
	var size := Vector2(440.0, 132.0)
	if _show_panel_display_controls():
		size = Vector2(452.0, 228.0)
	return Rect2(center - size * 0.5, size)


func _touch_tilt_button_rect() -> Rect2:
	var safe_rect := _ui_safe_rect()
	var size := Vector2(132.0, 68.0)
	return Rect2(safe_rect.position + safe_rect.size - size - Vector2(28.0, 28.0), size)


func _fullscreen_button_rect() -> Rect2:
	if _show_panel_display_controls():
		var panel := _center_message_panel_rect(get_viewport_rect().size * 0.5)
		var size := Vector2(128.0, 42.0)
		var gap := 10.0
		var total_width := size.x * 3.0 + gap * 2.0
		var start_x := panel.position.x + (panel.size.x - total_width) * 0.5
		var y := panel.position.y + panel.size.y - size.y - 18.0
		return Rect2(Vector2(start_x, y), size)
	if touch_controls_enabled:
		return Rect2(Vector2(-4000.0, -4000.0), Vector2.ZERO)
	var safe_rect := _ui_safe_rect()
	var size := Vector2(172.0, 44.0)
	return Rect2(safe_rect.position + Vector2(safe_rect.size.x - size.x - 18.0, 18.0), size)


func _orientation_button_rect() -> Rect2:
	var top_rect := _fullscreen_button_rect()
	if _show_panel_display_controls():
		return Rect2(top_rect.position + Vector2(top_rect.size.x + 10.0, 0.0), top_rect.size)
	if touch_controls_enabled:
		return Rect2(Vector2(-4000.0, -4000.0), Vector2.ZERO)
	return Rect2(top_rect.position + Vector2(0.0, top_rect.size.y + 10.0), top_rect.size)


func _fit_button_rect() -> Rect2:
	var orientation_rect := _orientation_button_rect()
	if _show_panel_display_controls():
		return Rect2(orientation_rect.position + Vector2(orientation_rect.size.x + 10.0, 0.0), orientation_rect.size)
	if touch_controls_enabled:
		return Rect2(Vector2(-4000.0, -4000.0), Vector2.ZERO)
	return Rect2(orientation_rect.position + Vector2(0.0, orientation_rect.size.y + 10.0), orientation_rect.size)


func _playfield_target_rect() -> Rect2:
	var viewport_size := get_viewport_rect().size
	var top_margin := 86.0
	var bottom_margin := 74.0
	if presentation_orientation == "portrait":
		top_margin = 94.0
		bottom_margin = 168.0 if touch_controls_enabled else 110.0
	else:
		bottom_margin = 122.0 if touch_controls_enabled else 74.0
	var available := Rect2(
		Vector2(0.0, top_margin),
		Vector2(viewport_size.x, maxf(viewport_size.y - top_margin - bottom_margin, 120.0))
	)
	var width_ratio := 0.98 if fullscreen_fill_enabled else 0.86
	var height_ratio := 0.96 if fullscreen_fill_enabled else 0.84
	if presentation_fit_mode == "fill":
		width_ratio = minf(width_ratio + 0.03, 1.0)
		height_ratio = minf(height_ratio + 0.03, 1.0)
	if presentation_orientation == "portrait":
		width_ratio = 0.82 if fullscreen_fill_enabled else 0.68
		height_ratio = 0.98 if fullscreen_fill_enabled else 0.88
		if presentation_fit_mode == "fill":
			width_ratio = minf(width_ratio + 0.08, 0.96)
			height_ratio = minf(height_ratio + 0.02, 1.0)
	var box_size := Vector2(available.size.x * width_ratio, available.size.y * height_ratio)
	return Rect2(available.position + (available.size - box_size) * 0.5, box_size)


func _playfield_rotation() -> float:
	var base_rotation := -PI * 0.5 if presentation_orientation == "portrait" else 0.0
	if trippy_mode_strength <= 0.001 or trippy_mode_level < 3:
		return base_rotation
	var rotate_ratio := float(trippy_mode_level - 2) / float(maxi(TRIPPY_STAGE_MAX - 2, 1))
	return base_rotation + sin(anim_time * 0.9) * (0.18 + 0.34 * rotate_ratio) * trippy_mode_strength + cos(anim_time * 1.7) * (0.08 + 0.18 * rotate_ratio) * trippy_mode_strength


func _playfield_scale_vector() -> Vector2:
	var target_rect := _playfield_target_rect()
	var maze_size := Vector2(_maze_width(), _maze_height()) * TILE_SIZE
	var rotated_size := maze_size
	if presentation_orientation == "portrait":
		rotated_size = Vector2(maze_size.y, maze_size.x)
	var fit_scale := minf(target_rect.size.x / maxf(rotated_size.x, 1.0), target_rect.size.y / maxf(rotated_size.y, 1.0))
	var fill_scale := maxf(target_rect.size.x / maxf(rotated_size.x, 1.0), target_rect.size.y / maxf(rotated_size.y, 1.0))
	var uniform_scale := fit_scale
	if presentation_fit_mode == "fill":
		uniform_scale = minf(fill_scale, fit_scale * 1.22)
	if fullscreen_fill_enabled:
		uniform_scale *= 1.02
	uniform_scale = maxf(uniform_scale, 0.82)
	if trippy_mode_strength <= 0.001:
		return Vector2.ONE * uniform_scale
	var trippy_ratio := float(trippy_mode_level) / float(TRIPPY_STAGE_MAX)
	var x_scale := uniform_scale * (1.0 + sin(anim_time * 1.6) * (0.06 + 0.09 * trippy_ratio) * trippy_mode_strength)
	var y_scale := uniform_scale * (1.0 + cos(anim_time * 1.3) * (0.07 + 0.1 * trippy_ratio) * trippy_mode_strength)
	return Vector2(maxf(x_scale, 0.74), maxf(y_scale, 0.74))


func _playfield_transform_offset(scale_value: Vector2) -> Vector2:
	var target_rect := _playfield_target_rect()
	var maze_size := Vector2(_maze_width(), _maze_height()) * TILE_SIZE
	var rotated_size := maze_size
	if presentation_orientation == "portrait":
		rotated_size = Vector2(maze_size.y, maze_size.x)
	var drawn_size := Vector2(rotated_size.x * scale_value.x, rotated_size.y * scale_value.y)
	var base_center := _maze_origin() + maze_size * 0.5
	var rotation := _playfield_rotation()
	var target_center := target_rect.position + (target_rect.size - drawn_size) * 0.5 + drawn_size * 0.5 + _screen_shake_offset()
	if trippy_mode_strength > 0.001:
		var trippy_ratio := float(trippy_mode_level) / float(TRIPPY_STAGE_MAX)
		target_center += Vector2(
			sin(anim_time * 1.2) * (18.0 + 28.0 * trippy_ratio) + cos(anim_time * 3.6) * (7.0 + 9.0 * trippy_ratio),
			cos(anim_time * 1.05) * (14.0 + 22.0 * trippy_ratio) + sin(anim_time * 2.8) * (5.0 + 8.0 * trippy_ratio)
		) * trippy_mode_strength
	var rotated_center := base_center.rotated(rotation)
	return target_center - Vector2(rotated_center.x * scale_value.x, rotated_center.y * scale_value.y)


func _toggle_fullscreen_fill() -> void:
	fullscreen_fill_enabled = not fullscreen_fill_enabled
	if not AppState.is_mobile_platform():
		var next_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen_fill_enabled else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(next_mode)


func _toggle_presentation_orientation() -> void:
	presentation_orientation = "portrait" if presentation_orientation == "landscape" else "landscape"


func _toggle_presentation_fit_mode() -> void:
	presentation_fit_mode = "fit" if presentation_fit_mode == "fill" else "fill"


func _pacman_travel_progress() -> float:
	if pacman.is_empty():
		return 0.0
	var travel_from: Vector2i = pacman.get("travel_from", pacman.get("cell", PACMAN_SPAWN))
	var target_cell: Vector2i = pacman.get("target_cell", pacman.get("cell", PACMAN_SPAWN))
	if travel_from == target_cell:
		return 0.0
	var start := _cell_center(travel_from)
	var finish := _cell_center(target_cell)
	var path_length := start.distance_to(finish)
	if path_length <= 0.001:
		return 1.0
	var position: Vector2 = pacman.get("position", start)
	return clampf(start.distance_to(position) / path_length, 0.0, 1.0)


func _pacman_eye_offset(direction: Vector2i, radius: float) -> Vector2:
	match direction:
		DIR_LEFT:
			return Vector2(-radius * 0.14, -radius * 0.26)
		DIR_UP:
			return Vector2(radius * 0.18, -radius * 0.12)
		DIR_DOWN:
			return Vector2(radius * 0.18, -radius * 0.28)
		_:
			return Vector2(radius * 0.14, -radius * 0.26)


func _pacman_chomp_amount(direction: Vector2i) -> float:
	if direction == Vector2i.ZERO:
		return 0.04
	var progress := _pacman_travel_progress()
	var target_cell: Vector2i = pacman.get("target_cell", pacman.get("cell", PACMAN_SPAWN))
	var fruit_cell: Vector2i = fruit.get("cell", FRUIT_CELL)
	var has_pellet := pellets.has(target_cell) or (bool(fruit.get("active", false)) and target_cell == fruit_cell)
	if has_pellet:
		if progress < 0.72:
			return lerpf(0.12, 1.0, progress / 0.72)
		return lerpf(1.0, 0.0, (progress - 0.72) / 0.28)
	return 0.18 + 0.82 * absf(sin(progress * PI))


func _powered_growth_scale() -> float:
	if frightened_timer <= 0.0:
		return 1.0
	var combo_value := float(power_combo_pellets) * 0.012 + float(power_combo_power_balls) * 0.12 + float(power_combo_ghosts) * 0.22
	return 1.1 + clampf(combo_value, 0.0, 0.78)


func _powered_speed_multiplier() -> float:
	if frightened_timer <= 0.0:
		return 1.0
	var ghost_speed_bonus := clampf(float(power_combo_ghosts) * 0.045, 0.0, 0.18)
	return 1.0 + ghost_speed_bonus


func _ghost_skill_factor() -> float:
	return clampf(0.24 + float(level - 1) * 0.15, 0.24, 1.0)


func _demo_player_skill() -> float:
	var cleared_ratio := clampf(1.0 - _remaining_pellet_ratio(), 0.0, 1.0)
	return clampf(0.44 + float(level - 1) * 0.08 + cleared_ratio * 0.18, 0.44, 1.0)


func _available_demo_directions(cell: Vector2i) -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	for direction in DIRECTIONS:
		var next_cell := _wrap_tunnel_cell(cell + direction)
		if _is_ghost_gate(next_cell):
			continue
		if _is_tunnel_warp_cell(next_cell) or _cell_is_open(next_cell):
			directions.append(direction)
	return directions


func _demo_step_cell(cell: Vector2i, direction: Vector2i) -> Vector2i:
	var next_cell := _wrap_tunnel_cell(cell + direction)
	if _is_tunnel_warp_cell(next_cell):
		return _tunnel_destination_cell(next_cell)
	return next_cell


func _demo_frightened_ghost_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for ghost in ghosts:
		if not bool(ghost.get("released", false)) or bool(ghost.get("returning", false)):
			continue
		if bool(ghost.get("tunnel_active", false)) or float(ghost.get("eaten_anim", 0.0)) > 0.0:
			continue
		if not bool(ghost.get("frightened", false)) or float(ghost.get("stun_timer", 0.0)) > 0.0:
			continue
		cells.append(ghost.get("cell", FRUIT_CELL))
	return cells


func _demo_dangerous_ghost_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if frightened_timer > 0.0:
		return cells
	for ghost in ghosts:
		if not bool(ghost.get("released", false)) or bool(ghost.get("returning", false)):
			continue
		if bool(ghost.get("tunnel_active", false)) or float(ghost.get("eaten_anim", 0.0)) > 0.0:
			continue
		if bool(ghost.get("frightened", false)) or float(ghost.get("stun_timer", 0.0)) > 0.0:
			continue
		cells.append(ghost.get("cell", FRUIT_CELL))
	return cells


func _demo_danger_penalty(cell: Vector2i) -> float:
	var penalty := 0.0
	for ghost_cell in _demo_dangerous_ghost_cells():
		var distance := cell.distance_to(ghost_cell)
		if distance <= 0.1:
			penalty += 14000.0
		elif distance <= 1.1:
			penalty += 2400.0
		elif distance <= 2.1:
			penalty += 520.0
		elif distance <= 3.2:
			penalty += 140.0
		elif distance <= 4.2:
			penalty += 34.0
	return penalty


func _nearest_target_distance(from_cell: Vector2i, targets: Array[Vector2i]) -> float:
	if targets.is_empty():
		return 99999.0
	var best := INF
	for target in targets:
		var distance := from_cell.distance_to(target)
		if distance < best:
			best = distance
	return best


func _demo_build_path_map(start: Vector2i) -> Dictionary:
	var frontier: Array[Vector2i] = []
	var distances: Dictionary = {}
	var first_steps: Dictionary = {}
	frontier.append(start)
	distances[start] = 0
	var frontier_index := 0
	while frontier_index < frontier.size():
		var cell: Vector2i = frontier[frontier_index]
		frontier_index += 1
		var cell_distance := int(distances.get(cell, 0))
		var options: Array[Vector2i] = _available_demo_directions(cell)
		for direction in options:
			var next_cell := _demo_step_cell(cell, direction)
			if distances.has(next_cell):
				continue
			distances[next_cell] = cell_distance + 1
			first_steps[next_cell] = direction if cell == start else first_steps.get(cell, direction)
			frontier.append(next_cell)
	return {"distance": distances, "first": first_steps}


func _demo_local_pellet_value(cell: Vector2i) -> float:
	var total := 0.0
	for offset_y in range(-2, 3):
		for offset_x in range(-2, 3):
			var distance_steps = abs(offset_x) + abs(offset_y)
			if distance_steps > 2:
				continue
			var sample := cell + Vector2i(offset_x, offset_y)
			var pellet_value := int(pellets.get(sample, 0))
			if pellet_value <= 0:
				continue
			var weight := 1.0 / float(distance_steps + 1)
			total += (8.0 if pellet_value >= 50 else 1.35) * weight
	if bool(fruit.get("active", false)):
		var fruit_cell: Vector2i = fruit.get("cell", FRUIT_CELL)
		var fruit_distance := cell.distance_to(fruit_cell)
		if fruit_distance <= 3.0:
			total += 6.0 - fruit_distance * 1.2
	return total


func _demo_goal_is_valid() -> bool:
	match demo_goal_kind:
		"pellet", "power":
			return pellets.has(demo_goal_cell)
		"fruit":
			return bool(fruit.get("active", false))
		"ghost":
			return not _demo_frightened_ghost_cells().is_empty()
		_:
			return false


func _demo_resolve_goal_cell(from_cell: Vector2i) -> Vector2i:
	match demo_goal_kind:
		"fruit":
			if bool(fruit.get("active", false)):
				return fruit.get("cell", demo_goal_cell)
		"ghost":
			var frightened_cells: Array[Vector2i] = _demo_frightened_ghost_cells()
			if not frightened_cells.is_empty():
				var nearest := frightened_cells[0]
				var best_distance := from_cell.distance_to(nearest)
				for ghost_cell in frightened_cells:
					var distance := from_cell.distance_to(ghost_cell)
					if distance < best_distance:
						best_distance = distance
						nearest = ghost_cell
				return nearest
	return demo_goal_cell


func _demo_escape_direction(cell: Vector2i, current_direction: Vector2i) -> Vector2i:
	var options: Array[Vector2i] = _available_demo_directions(cell)
	if options.is_empty():
		return Vector2i.ZERO
	var reverse := _reverse_dir(current_direction)
	var dangerous_cells: Array[Vector2i] = _demo_dangerous_ghost_cells()
	var best_dir := options[0]
	var best_score := -INF
	for direction in options:
		var next_cell := _demo_step_cell(cell, direction)
		var nearest_danger := 99999.0
		for ghost_cell in dangerous_cells:
			var distance := next_cell.distance_to(ghost_cell)
			if distance < nearest_danger:
				nearest_danger = distance
		var score_value := nearest_danger * 8.0 + _demo_local_pellet_value(next_cell) - _demo_revisit_penalty(next_cell) * 0.72
		if direction == current_direction:
			score_value += 1.2
		elif direction == reverse:
			score_value -= 2.8
		if _is_tunnel_warp_cell(_wrap_tunnel_cell(cell + direction)):
			score_value += 0.45
		if score_value > best_score:
			best_score = score_value
			best_dir = direction
	return best_dir


func _demo_choose_goal(cell: Vector2i, path_map: Dictionary, current_direction: Vector2i) -> Dictionary:
	var distances: Dictionary = path_map.get("distance", {})
	var first_steps: Dictionary = path_map.get("first", {})
	var skill := _demo_player_skill()
	var randomness := lerpf(2.2, 0.18, skill)
	var best_kind := ""
	var best_cell := cell
	var best_score := INF
	var frightened_cells: Array[Vector2i] = _demo_frightened_ghost_cells()
	for ghost_cell in frightened_cells:
		if not distances.has(ghost_cell):
			continue
		var distance_steps := float(int(distances.get(ghost_cell, 99999)))
		var first_direction: Vector2i = first_steps.get(ghost_cell, Vector2i.ZERO)
		var score_value := distance_steps * 0.44 + _demo_danger_penalty(ghost_cell) * 0.002 + _demo_revisit_penalty(ghost_cell) * 0.18 - 32.0 - randf() * randomness
		if current_direction != Vector2i.ZERO:
			if first_direction == current_direction:
				score_value -= 1.25
			elif first_direction == _reverse_dir(current_direction):
				score_value += 2.9
		if score_value < best_score:
			best_score = score_value
			best_kind = "ghost"
			best_cell = ghost_cell
	if bool(fruit.get("active", false)):
		var fruit_cell: Vector2i = fruit.get("cell", FRUIT_CELL)
		if distances.has(fruit_cell):
			var distance_steps := float(int(distances.get(fruit_cell, 99999)))
			var first_direction: Vector2i = first_steps.get(fruit_cell, Vector2i.ZERO)
			var score_value := distance_steps * 0.76 + _demo_danger_penalty(fruit_cell) * 0.004 + _demo_revisit_penalty(fruit_cell) * 0.34 - 18.0 - randf() * randomness
			if current_direction != Vector2i.ZERO:
				if first_direction == current_direction:
					score_value -= 0.95
				elif first_direction == _reverse_dir(current_direction):
					score_value += 2.2
			if score_value < best_score:
				best_score = score_value
				best_kind = "fruit"
				best_cell = fruit_cell
	for pellet_key in pellets.keys():
		var pellet_cell := pellet_key as Vector2i
		if not distances.has(pellet_cell):
			continue
		var pellet_value := int(pellets.get(pellet_cell, 0))
		var distance_steps := float(int(distances.get(pellet_cell, 99999)))
		var first_direction: Vector2i = first_steps.get(pellet_cell, Vector2i.ZERO)
		var reward := 12.0 if pellet_value >= 50 else 4.0
		reward += _demo_local_pellet_value(pellet_cell) * 1.35
		if pellet_value >= 50:
			reward += 4.5
		if demo_goal_kind in ["pellet", "power"] and pellet_cell == demo_goal_cell:
			reward += 1.8
		if current_direction != Vector2i.ZERO:
			if first_direction == current_direction:
				reward += 1.55
			elif first_direction == _reverse_dir(current_direction):
				reward -= 2.8
		var score_value := distance_steps * lerpf(1.18, 0.92, skill) + _demo_danger_penalty(pellet_cell) * lerpf(0.01, 0.004, skill) + _demo_revisit_penalty(pellet_cell) * lerpf(0.82, 0.36, skill) - reward - randf() * randomness
		if pellet_cell == cell and current_direction != Vector2i.ZERO:
			score_value += 0.35
		if score_value < best_score:
			best_score = score_value
			best_kind = "power" if pellet_value >= 50 else "pellet"
			best_cell = pellet_cell
	if best_kind.is_empty():
		best_kind = "pellet"
		best_cell = cell
	return {"kind": best_kind, "cell": best_cell}


func _update_demo_controller(delta: float) -> void:
	if not demo_mode or pacman.is_empty():
		return
	if bool(pacman.get("tunnel_active", false)):
		return
	demo_goal_hold_timer = maxf(demo_goal_hold_timer - delta, 0.0)
	demo_decision_timer = maxf(demo_decision_timer - delta, 0.0)
	var cell: Vector2i = pacman.get("cell", PACMAN_SPAWN)
	var direction: Vector2i = pacman.get("direction", DIR_LEFT)
	var target_cell: Vector2i = pacman.get("target_cell", cell)
	var at_decision_point = target_cell == cell or pacman.get("position", _cell_center(cell)).distance_to(_cell_center(target_cell)) <= TILE_SIZE * 0.18
	if cell == demo_last_cell:
		if at_decision_point:
			demo_stuck_timer = minf(demo_stuck_timer + delta, 2.5)
	else:
		demo_last_cell = cell
		demo_stuck_timer = 0.0
	if not at_decision_point:
		return
	_demo_note_cell_visit(cell)
	var options: Array[Vector2i] = _available_demo_directions(cell)
	if options.is_empty():
		return
	var panic := frightened_timer <= 0.0 and _demo_danger_penalty(cell) >= DEMO_PANIC_THRESHOLD
	if panic:
		pacman["wanted_direction"] = _demo_escape_direction(cell, direction)
		demo_goal_kind = ""
		demo_goal_cell = cell
		demo_goal_hold_timer = 0.0
		demo_decision_timer = DEMO_DECISION_COOLDOWN * 0.5
		demo_last_goal_distance = INF
		return
	if options.size() <= 2 and direction != Vector2i.ZERO and options.has(direction):
		pacman["wanted_direction"] = direction
		return
	if demo_decision_timer > 0.0 and direction != Vector2i.ZERO and options.has(direction) and _demo_goal_is_valid():
		pacman["wanted_direction"] = direction
		return
	var path_map := _demo_build_path_map(cell)
	var distances: Dictionary = path_map.get("distance", {})
	if distances.is_empty():
		return
	var resolved_goal := _demo_resolve_goal_cell(cell)
	var need_new_goal := not _demo_goal_is_valid() or not distances.has(resolved_goal) or demo_goal_hold_timer <= 0.0 or demo_stuck_timer >= DEMO_STUCK_REPLAN_TIME
	if need_new_goal:
		var choice: Dictionary = _demo_choose_goal(cell, path_map, direction)
		demo_goal_kind = String(choice.get("kind", ""))
		demo_goal_cell = choice.get("cell", cell)
		demo_goal_hold_timer = 0.48 if demo_goal_kind in ["ghost", "fruit"] else lerpf(DEMO_GOAL_HOLD_MIN, DEMO_GOAL_HOLD_MAX, _demo_player_skill())
		resolved_goal = _demo_resolve_goal_cell(cell)
		demo_last_goal_distance = float(int(distances.get(resolved_goal, 99999)))
	resolved_goal = _demo_resolve_goal_cell(cell)
	var first_steps: Dictionary = path_map.get("first", {})
	var wanted_direction: Vector2i = first_steps.get(resolved_goal, _demo_escape_direction(cell, direction))
	var forward_value := _demo_forward_lane_value(cell, direction)
	var wanted_value := _demo_forward_lane_value(cell, wanted_direction)
	if options.size() <= 2 and direction != Vector2i.ZERO and wanted_direction == _reverse_dir(direction) and _demo_danger_penalty(cell) < DEMO_PANIC_THRESHOLD * 1.4 and options.has(direction):
		wanted_direction = direction
	elif direction != Vector2i.ZERO and options.has(direction) and wanted_direction != direction and _demo_danger_penalty(cell) < DEMO_PANIC_THRESHOLD * 1.2 and forward_value >= wanted_value - 1.1 and demo_stuck_timer < DEMO_STUCK_REPLAN_TIME:
		wanted_direction = direction
	if demo_stuck_timer >= DEMO_STUCK_REPLAN_TIME:
		demo_cell_bias[cell] = minf(float(demo_cell_bias.get(cell, 0.0)) + delta * 26.0, 48.0)
	pacman["wanted_direction"] = wanted_direction
	demo_decision_timer = DEMO_DECISION_COOLDOWN
	var goal_distance := float(int(distances.get(resolved_goal, 0)))
	if goal_distance < demo_last_goal_distance:
		demo_stuck_timer = 0.0
	demo_last_goal_distance = goal_distance


func _activate_tilt_burst() -> void:
	if game_state != "play":
		return
	if ability_tilt_timer > 0.0 or ability_charges <= 0:
		return
	if ability_charges == 1 and ability_recent_use_timer > 0.0:
		ability_charges = 0
		ability_recharge_timers.clear()
		ability_tilt_timer = ABILITY_TILT_RECHARGE
	else:
		ability_charges -= 1
		ability_recharge_timers.append(ABILITY_SECOND_RECHARGE if not ability_recharge_timers.is_empty() else ABILITY_FIRST_RECHARGE)
		ability_recent_use_timer = ABILITY_TILT_WINDOW
	screen_shake_timer = ABILITY_SHAKE_TIME
	screen_shake_strength = 16.0 if ability_tilt_timer <= 0.0 else 24.0
	var pac_cell: Vector2i = pacman.get("cell", PACMAN_SPAWN)
	for ghost_index in range(ghosts.size()):
		var ghost := ghosts[ghost_index]
		if bool(ghost.get("returning", false)) or not bool(ghost.get("released", false)) or float(ghost.get("eaten_anim", 0.0)) > 0.0:
			continue
		var ghost_cell: Vector2i = ghost.get("cell", ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index]))
		var desired_steps := 1 + int(randi() % 2)
		var moved_cell := ghost_cell
		for _step in range(desired_steps):
			var away := Vector2i(
				0 if ghost_cell.x == pac_cell.x else int(sign(ghost_cell.x - pac_cell.x)),
				0 if ghost_cell.y == pac_cell.y else int(sign(ghost_cell.y - pac_cell.y))
			)
			var options: Array[Vector2i] = []
			if abs(ghost_cell.x - pac_cell.x) >= abs(ghost_cell.y - pac_cell.y):
				if away.x != 0:
					options.append(Vector2i(away.x, 0))
				if away.y != 0:
					options.append(Vector2i(0, away.y))
			else:
				if away.y != 0:
					options.append(Vector2i(0, away.y))
				if away.x != 0:
					options.append(Vector2i(away.x, 0))
			for direction in DIRECTIONS:
				if not options.has(direction):
					options.append(direction)
			var chosen := moved_cell
			for option in options:
				var candidate := _wrap_tunnel_cell(moved_cell + option)
				if _cell_is_open_for_ghost(candidate, ghost):
					chosen = candidate
					break
			moved_cell = chosen
		ghost["cell"] = moved_cell
		ghost["target_cell"] = moved_cell
		ghost["position"] = _cell_center(moved_cell)
		ghost["direction"] = _reverse_dir(ghost.get("direction", DIR_LEFT))
		ghost["stun_timer"] = GHOST_STUN_TIME
		ghosts[ghost_index] = ghost


func _update_play(delta: float) -> void:
	_pac_move_sound_cooldown = maxf(_pac_move_sound_cooldown - delta, 0.0)
	ability_recent_use_timer = maxf(ability_recent_use_timer - delta, 0.0)
	power_combo_flash_timer = maxf(power_combo_flash_timer - delta, 0.0)
	screen_shake_timer = maxf(screen_shake_timer - delta, 0.0)
	if ability_tilt_timer > 0.0:
		ability_tilt_timer = maxf(ability_tilt_timer - delta, 0.0)
		if ability_tilt_timer <= 0.0:
			ability_charges = 2
			ability_recharge_timers.clear()
	for timer_index in range(ability_recharge_timers.size() - 1, -1, -1):
		ability_recharge_timers[timer_index] = maxf(float(ability_recharge_timers[timer_index]) - delta, 0.0)
		if float(ability_recharge_timers[timer_index]) <= 0.0:
			ability_recharge_timers.remove_at(timer_index)
			ability_charges = mini(ability_charges + 1, 2)
	var was_powered := frightened_timer > 0.0
	frightened_timer = maxf(frightened_timer - delta, 0.0)
	if was_powered and frightened_timer <= 0.0:
		SoundDirector.stop_pac_super()
		frightened_chain = 0
		power_combo_pellets = 0
		power_combo_ghosts = 0
		power_combo_power_balls = 0
		var release_queue_index := 0
		for ghost_index in range(ghosts.size()):
			var ghost := ghosts[ghost_index]
			ghost["frightened"] = false
			if bool(ghost.get("power_jail_hold", false)):
				ghost["power_jail_hold"] = false
				ghost["released"] = false
				ghost["returning"] = false
				ghost["direction"] = DIR_UP
				ghost["release_timer"] = 0.7 + float(release_queue_index) * 0.55
				release_queue_index += 1
			ghosts[ghost_index] = ghost
	_update_fruit(delta)
	_update_demo_controller(delta)
	_update_pacman(delta)
	_update_pacman_idle_gag(delta)
	_update_ghosts(delta)
	_check_collisions()
	while score >= next_extra_life_score:
		lives += 1
		next_extra_life_score += EXTRA_LIFE_STEP
		SoundDirector.play_pac_extrapac()
	if pellets.is_empty() and game_state == "play":
		SoundDirector.play_pac_nextlevel()
		game_state = "level_clear"
		state_timer = LEVEL_CLEAR_DELAY
		high_score = maxi(high_score, score)


func _update_pacman_idle_gag(delta: float) -> void:
	if pacman.is_empty() or demo_mode or game_state != "play" or bool(pacman.get("tunnel_active", false)):
		pac_idle_timer = 0.0
		pac_idle_trippy_claimed = false
		trippy_mode_strength = maxf(trippy_mode_strength - delta * 1.8, 0.0)
		return
	var cell: Vector2i = pacman.get("cell", PACMAN_SPAWN)
	var target_cell: Vector2i = pacman.get("target_cell", cell)
	var position: Vector2 = pacman.get("position", _cell_center(cell))
	var direction: Vector2i = pacman.get("direction", Vector2i.ZERO)
	var standing_still := direction == Vector2i.ZERO and target_cell == cell and position.distance_to(_cell_center(cell)) <= 0.05
	if standing_still:
		pac_idle_timer += delta
		if pac_idle_timer >= PAC_IDLE_TRIPPY_TIME and not pac_idle_trippy_claimed:
			pac_idle_trippy_claimed = true
			_increase_trippy_level()
	else:
		pac_idle_timer = 0.0
		pac_idle_trippy_claimed = false
	var target_strength := 0.0
	if trippy_mode_level > 0:
		var trippy_ratio := float(trippy_mode_level) / float(TRIPPY_STAGE_MAX)
		target_strength = lerpf(0.32, 2.2, trippy_ratio)
	if trippy_mode_active:
		if trippy_mode_strength < target_strength:
			trippy_mode_strength = minf(trippy_mode_strength + delta * 0.42, target_strength)
		else:
			trippy_mode_strength = maxf(trippy_mode_strength - delta * 0.2, target_strength)
	else:
		trippy_mode_strength = maxf(trippy_mode_strength - delta * 1.2, 0.0)


func _remaining_pellet_ratio() -> float:
	if initial_pellet_count <= 0:
		return 0.0
	return float(pellets.size()) / float(initial_pellet_count)


func _available_fruit_directions(cell: Vector2i) -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	for direction in DIRECTIONS:
		var next_cell := _wrap_tunnel_cell(cell + direction)
		if _is_tunnel_warp_cell(next_cell):
			continue
		if _is_ghost_gate(next_cell):
			continue
		if _cell_is_open(next_cell):
			directions.append(direction)
	return directions


func _spawn_bonus_cherry() -> void:
	var options := _available_fruit_directions(FRUIT_CELL)
	var direction := Vector2i.ZERO if options.is_empty() else options[randi() % options.size()]
	fruit["active"] = true
	fruit["timer"] = FRUIT_ACTIVE_TIME
	fruit["cell"] = FRUIT_CELL
	fruit["target_cell"] = FRUIT_CELL
	fruit["position"] = _cell_center(FRUIT_CELL)
	fruit["direction"] = direction
	fruit["bounce_phase"] = randf() * TAU


func _update_fruit(delta: float) -> void:
	if bool(fruit.get("active", false)):
		var timer := maxf(float(fruit.get("timer", 0.0)) - delta, 0.0)
		fruit["timer"] = timer
		fruit["bounce_phase"] = fposmod(float(fruit.get("bounce_phase", 0.0)) + delta * 10.0, TAU)
		if timer <= 0.0:
			fruit["active"] = false
		else:
			var cell: Vector2i = fruit.get("cell", FRUIT_CELL)
			var target_cell: Vector2i = fruit.get("target_cell", cell)
			var position: Vector2 = fruit.get("position", _cell_center(cell))
			var direction: Vector2i = fruit.get("direction", Vector2i.ZERO)
			var target_center := _cell_center(target_cell)
			var reached_target := target_cell == cell or position.distance_to(target_center) <= FRUIT_MOVE_SPEED * delta + 0.001
			if reached_target:
				position = target_center
				cell = target_cell
				var options := _available_fruit_directions(cell)
				if not options.is_empty():
					var reverse := _reverse_dir(direction)
					var preferred: Array[Vector2i] = []
					if options.has(direction):
						preferred.append(direction)
					for option in options:
						if option != reverse and option != direction:
							preferred.append(option)
					if preferred.is_empty():
						preferred = options
					direction = preferred[randi() % preferred.size()]
					target_cell = _wrap_tunnel_cell(cell + direction)
				else:
					direction = Vector2i.ZERO
					target_cell = cell
			if direction != Vector2i.ZERO and target_cell != cell:
				position = _move_toward_point(position, _cell_center(target_cell), FRUIT_MOVE_SPEED * delta)
			else:
				position = _cell_center(cell)
			fruit["cell"] = cell
			fruit["target_cell"] = target_cell
			fruit["position"] = position
			fruit["direction"] = direction
	else:
		var spawns_done := int(fruit.get("spawns_done", 0))
		var ratio := _remaining_pellet_ratio()
		if spawns_done == 0 and ratio <= 0.78:
			_spawn_bonus_cherry()
			fruit["spawns_done"] = 1
		elif spawns_done == 1 and ratio <= 0.54:
			_spawn_bonus_cherry()
			fruit["spawns_done"] = 2
		elif spawns_done == 2 and ratio <= 0.3:
			_spawn_bonus_cherry()
			fruit["spawns_done"] = 3


func _update_pacman(delta: float) -> void:
	if bool(pacman.get("tunnel_active", false)):
		pacman = _update_tunnel_transit(pacman, delta)
		return
	var position: Vector2 = pacman.get("position", Vector2.ZERO)
	var cell: Vector2i = pacman.get("cell", PACMAN_SPAWN)
	var direction: Vector2i = pacman.get("direction", DIR_LEFT)
	var wanted: Vector2i = pacman.get("wanted_direction", direction)
	var target_cell: Vector2i = pacman.get("target_cell", cell)
	var travel_from: Vector2i = pacman.get("travel_from", cell)
	var move_budget := _level_pacman_speed() * delta
	var iterations := 0
	while iterations < 3:
		iterations += 1
		var target_center := _cell_center(target_cell)
		var distance_to_target := 0.0 if target_cell == cell else position.distance_to(target_center)
		if distance_to_target > move_budget + 0.001:
			if direction != Vector2i.ZERO and target_cell != cell:
				position = _move_toward_point(position, target_center, move_budget)
			else:
				position = _cell_center(cell)
			move_budget = 0.0
			break
		position = target_center
		move_budget = maxf(move_budget - distance_to_target, 0.0)
		cell = target_cell
		var pellet_value := int(pellets.get(cell, 0))
		if pellet_value > 0:
			pellets.erase(cell)
			score += pellet_value
			if pellet_value >= 50:
				SoundDirector.play_pac_super()
				frightened_timer = minf(_level_frightened_duration(), POWER_MODE_MAX_TIME)
				frightened_chain = 0
				power_combo_power_balls += 1
				power_combo_flash_timer = 0.9
				for ghost_index in range(ghosts.size()):
					var ghost := ghosts[ghost_index]
					if not bool(ghost.get("returning", false)):
						ghost["frightened"] = true
						ghosts[ghost_index] = ghost
			else:
				SoundDirector.play_pac_eat()
				if frightened_timer > 0.0:
					power_combo_pellets += 1
		var fruit_pos: Vector2 = fruit.get("position", _cell_center(FRUIT_CELL))
		if bool(fruit.get("active", false)) and position.distance_to(fruit_pos) <= TILE_SIZE * 0.58:
			fruit["active"] = false
			score += _fruit_score_for_level(level)
			SoundDirector.play_pac_eatfruit()
		var wanted_cell := _wrap_tunnel_cell(cell + wanted)
		if wanted != direction and _cell_is_open(wanted_cell):
			direction = wanted
		var forward_cell := _wrap_tunnel_cell(cell + direction)
		if direction == Vector2i.ZERO or not _cell_is_open(forward_cell):
			direction = Vector2i.ZERO
			target_cell = cell
			travel_from = cell
			break
		else:
			if _is_tunnel_warp_cell(forward_cell):
				pacman = _begin_tunnel_transit(pacman, cell, forward_cell, PACMAN_TUNNEL_TRANSIT_TIME)
				pacman["travel_from"] = cell
				pacman["direction"] = direction
				return
			if _pac_move_sound_cooldown <= 0.0:
				SoundDirector.play_pac_move()
				_pac_move_sound_cooldown = 0.09
			travel_from = cell
			target_cell = forward_cell
		if move_budget <= 0.001:
			break
	high_score = maxi(high_score, score)
	if move_budget > 0.0 and direction != Vector2i.ZERO and target_cell != cell:
		position = _move_toward_point(position, _cell_center(target_cell), move_budget)
	else:
		if direction == Vector2i.ZERO or target_cell == cell:
			position = _cell_center(cell)
	pacman["cell"] = cell
	pacman["target_cell"] = target_cell
	pacman["travel_from"] = travel_from
	pacman["position"] = position
	pacman["direction"] = direction


func _available_directions(cell: Vector2i, ghost: Dictionary) -> Array[Vector2i]:
	var directions: Array[Vector2i] = []
	for direction in DIRECTIONS:
		if _cell_is_open_for_ghost(cell + direction, ghost):
			directions.append(direction)
	return directions


func _ghost_target_cell(ghost: Dictionary, ghost_index: int) -> Vector2i:
	var pac_cell := _world_to_cell(Vector2(pacman.get("position", Vector2.ZERO)))
	if bool(ghost.get("returning", false)):
		return ghost.get("spawn_cell", pac_cell)
	if bool(ghost.get("frightened", false)):
		return pac_cell + Vector2i(
			int(round(sin(anim_time + float(ghost_index) * 2.1) * 6.0)),
			int(round(cos(anim_time * 0.8 + float(ghost_index)) * 6.0))
		)
	match ghost_index:
		0:
			return pac_cell
		1:
			return pac_cell + pacman.get("direction", DIR_LEFT) * 4
		2:
			return Vector2i(1, _maze_height() - 2) if int(floor(anim_time / 6.0)) % 2 == 0 else Vector2i(_maze_width() - 2, 1)
		_:
			var ghost_cell := _world_to_cell(Vector2(ghost.get("position", Vector2.ZERO)))
			return pac_cell if ghost_cell.distance_to(pac_cell) > 5.0 else Vector2i(_maze_width() - 2, _maze_height() - 2)


func _choose_ghost_direction(cell: Vector2i, current_dir: Vector2i, ghost: Dictionary, ghost_index: int) -> Vector2i:
	var options := _available_directions(cell, ghost)
	if options.is_empty():
		return Vector2i.ZERO
	if options.size() > 1:
		options.erase(_reverse_dir(current_dir))
		if options.is_empty():
			options = _available_directions(cell, ghost)
	if not bool(ghost.get("frightened", false)) and not bool(ghost.get("returning", false)):
		var skill := _ghost_skill_factor()
		if randf() > skill:
			if options.has(current_dir):
				return current_dir
			return options[randi() % options.size()]
	var target := _ghost_target_cell(ghost, ghost_index)
	var best_dir := options[0]
	var best_score := INF
	for option in options:
		var option_cell := cell + option
		var score_value := option_cell.distance_to(target)
		if bool(ghost.get("frightened", false)):
			score_value = -score_value
		if score_value < best_score:
			best_score = score_value
			best_dir = option
	return best_dir


func _update_ghost_house(delta: float, ghost_index: int, ghost: Dictionary) -> Dictionary:
	if bool(ghost.get("released", false)) or bool(ghost.get("returning", false)):
		return ghost
	var power_hold := bool(ghost.get("power_jail_hold", false))
	var release_timer := float(ghost.get("release_timer", 0.0))
	if not power_hold:
		release_timer = maxf(release_timer - delta, 0.0)
	ghost["release_timer"] = release_timer
	var phase := fposmod(float(ghost.get("house_phase", 0.0)) + delta * 2.2, TAU)
	ghost["house_phase"] = phase
	var spawn_cell: Vector2i = ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index])
	var spawn_center := _cell_center(spawn_cell)
	ghost["cell"] = spawn_cell
	ghost["target_cell"] = spawn_cell
	ghost["position"] = spawn_center + Vector2(0.0, sin(phase) * 7.0)
	if power_hold and frightened_timer > 0.0:
		return ghost
	if release_timer <= 0.0:
		ghost["released"] = true
		ghost["power_jail_hold"] = false
		ghost["direction"] = DIR_UP
	return ghost


func _update_ghosts(delta: float) -> void:
	for ghost_index in range(ghosts.size()):
		var ghost := ghosts[ghost_index]
		if bool(ghost.get("tunnel_active", false)):
			ghost = _update_tunnel_transit(ghost, delta)
			ghosts[ghost_index] = ghost
			continue
		var stun_timer := maxf(float(ghost.get("stun_timer", 0.0)) - delta, 0.0)
		ghost["stun_timer"] = stun_timer
		var eaten_anim := float(ghost.get("eaten_anim", 0.0))
		if eaten_anim > 0.0:
			eaten_anim = maxf(eaten_anim - delta, 0.0)
			ghost["eaten_anim"] = eaten_anim
			var total := maxf(float(ghost.get("eaten_total", GHOST_EAT_ANIM_DURATION)), 0.001)
			var progress := 1.0 - eaten_anim / total
			var eaten_origin: Vector2 = ghost.get("eaten_origin", pacman.get("position", Vector2.ZERO))
			var eaten_target: Vector2 = ghost.get("eaten_target", _cell_center(ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index])))
			ghost["position"] = eaten_origin.lerp(eaten_target, clampf(progress, 0.0, 1.0))
			if eaten_anim <= 0.0:
				var spawn_cell: Vector2i = ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index])
				ghost["position"] = _cell_center(spawn_cell)
				ghost["cell"] = spawn_cell
				ghost["target_cell"] = spawn_cell
				ghost["direction"] = DIR_UP
				ghost["frightened"] = false
				ghost["power_jail_hold"] = frightened_timer > 0.0
				ghost["returning"] = false
				ghost["released"] = false
				ghost["release_timer"] = _ghost_jail_delay_after_eaten(ghost_index)
				ghost["house_phase"] = randf() * TAU
			ghosts[ghost_index] = ghost
			continue
		if stun_timer > 0.0:
			var stunned_cell: Vector2i = ghost.get("cell", ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index]))
			ghost["target_cell"] = stunned_cell
			ghost["position"] = _cell_center(stunned_cell)
			ghosts[ghost_index] = ghost
			continue
		ghost = _update_ghost_house(delta, ghost_index, ghost)
		var position: Vector2 = ghost.get("position", Vector2.ZERO)
		var cell: Vector2i = ghost.get("cell", ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index]))
		var current_dir: Vector2i = ghost.get("direction", DIR_LEFT)
		var target_cell: Vector2i = ghost.get("target_cell", cell)
		var target_center := _cell_center(target_cell)
		var speed := _level_ghost_speed() * lerpf(0.76, 1.0, _ghost_skill_factor())
		if bool(ghost.get("frightened", false)):
			speed *= 0.72
		if bool(ghost.get("returning", false)):
			speed *= 1.15
		if _is_actor_in_tunnel_transit(cell, target_cell, bool(ghost.get("tunnel_active", false))):
			speed *= 0.42
		var reached_target := position.distance_to(target_center) <= speed * delta + 0.001
		if reached_target:
			position = target_center
			cell = target_cell
			if bool(ghost.get("returning", false)) and cell == ghost.get("spawn_cell", cell):
				ghost["returning"] = false
				ghost["released"] = false
				ghost["frightened"] = false
				var hold_in_jail := frightened_timer > 0.0
				ghost["power_jail_hold"] = hold_in_jail
				ghost["release_timer"] = 0.0 if hold_in_jail else 1.2 + float(ghost_index) * 0.35
			elif bool(ghost.get("released", false)):
				current_dir = _choose_ghost_direction(cell, current_dir, ghost, ghost_index)
			var next_cell := _wrap_tunnel_cell(cell + current_dir)
			if not bool(ghost.get("released", false)) or current_dir == Vector2i.ZERO or not _cell_is_open_for_ghost(next_cell, ghost):
				current_dir = Vector2i.ZERO
				target_cell = cell
			else:
				if _is_tunnel_warp_cell(next_cell):
					ghost = _begin_tunnel_transit(ghost, cell, next_cell, GHOST_TUNNEL_TRANSIT_TIME)
					ghost["direction"] = current_dir
					ghosts[ghost_index] = ghost
					continue
				target_cell = next_cell
				target_center = _cell_center(target_cell)
		if bool(ghost.get("released", false)) and current_dir != Vector2i.ZERO and target_cell != cell:
			position = _move_toward_point(position, target_center, speed * delta)
		elif bool(ghost.get("released", false)):
			position = _cell_center(cell)
		ghost["cell"] = cell
		ghost["target_cell"] = target_cell
		ghost["position"] = position
		ghost["direction"] = current_dir
		ghosts[ghost_index] = ghost


func _check_collisions() -> void:
	var pac_pos: Vector2 = pacman.get("position", Vector2.ZERO)
	var pac_cell: Vector2i = pacman.get("cell", PACMAN_SPAWN)
	var pac_target_cell: Vector2i = pacman.get("target_cell", pac_cell)
	if _is_actor_in_tunnel_transit(pac_cell, pac_target_cell, bool(pacman.get("tunnel_active", false))):
		return
	for ghost_index in range(ghosts.size()):
		var ghost := ghosts[ghost_index]
		if float(ghost.get("eaten_anim", 0.0)) > 0.0:
			continue
		var ghost_cell: Vector2i = ghost.get("cell", ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index]))
		var ghost_target_cell: Vector2i = ghost.get("target_cell", ghost_cell)
		if _is_actor_in_tunnel_transit(ghost_cell, ghost_target_cell, bool(ghost.get("tunnel_active", false))):
			continue
		var ghost_pos: Vector2 = ghost.get("position", Vector2.ZERO)
		var collision_radius := TILE_SIZE * 0.52
		if pac_pos.distance_to(ghost_pos) > collision_radius:
			continue
		if bool(ghost.get("frightened", false)):
			frightened_chain += 1
			score += 200 * int(pow(2.0, float(frightened_chain - 1)))
			power_combo_ghosts += 1
			power_combo_flash_timer = 0.9
			SoundDirector.play_pac_ghost()
			ghost["eaten_anim"] = GHOST_EAT_ANIM_DURATION
			ghost["eaten_total"] = GHOST_EAT_ANIM_DURATION
			var pac_dir: Vector2i = pacman.get("direction", DIR_LEFT)
			var mouth_dir := _dir_to_vec2(pac_dir) if pac_dir != Vector2i.ZERO else Vector2.LEFT
			var mouth_origin := pac_pos + mouth_dir * (TILE_SIZE * 0.34)
			ghost["eaten_origin"] = mouth_origin
			ghost["eaten_target"] = _cell_center(ghost.get("spawn_cell", GHOST_SPAWNS[ghost_index]))
			ghost["position"] = mouth_origin
			ghost["frightened"] = false
			ghost["power_jail_hold"] = true
			ghosts[ghost_index] = ghost
			high_score = maxi(high_score, score)
			continue
		if bool(ghost.get("returning", false)) or not bool(ghost.get("released", false)):
			continue
		lives -= 1
		trippy_mode_active = false
		trippy_mode_strength = 0.0
		trippy_mode_level = 0
		pac_idle_timer = 0.0
		pac_idle_trippy_claimed = false
		SoundDirector.play_pac_death()
		game_state = "dead"
		state_timer = DEATH_DELAY
		return


func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var bg := Rect2(Vector2.ZERO, viewport_size)
	draw_rect(bg, Color(0.0, 0.0, 0.0, 1.0), true)
	var playfield_scale := _playfield_scale_vector()
	draw_set_transform(_playfield_transform_offset(playfield_scale), _playfield_rotation(), playfield_scale)
	_draw_maze()
	_draw_house_gate()
	_draw_jail()
	_draw_pellets()
	_draw_fruit()
	_draw_pacman()
	_draw_ghosts()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_hud()
	_draw_overlay()
	if pause_open:
		_draw_pause_menu()
	if control_wizard_open:
		_draw_control_wizard()
	if exit_confirm_timer > 0.0:
		_draw_exit_confirmation()
	_draw_trippy_overlay()
	if touch_controls_enabled:
		var font: Font = ThemeDB.fallback_font
		if font != null:
			_draw_touch_controls(font)


func _draw_trippy_overlay() -> void:
	if trippy_mode_strength <= 0.001:
		return
	var viewport_size := get_viewport_rect().size
	var trippy_ratio := float(maxi(trippy_mode_level, 1)) / float(TRIPPY_STAGE_MAX)
	var band_count := 12 + int(floor(trippy_ratio * 12.0))
	var band_wobble := (10.0 + 34.0 * trippy_ratio) * trippy_mode_strength
	for band_index in range(band_count):
		var ratio := float(band_index) / float(band_count)
		var band_height := viewport_size.y / float(band_count)
		var y := ratio * viewport_size.y + sin(anim_time * (2.1 + trippy_ratio * 1.4) + ratio * (9.0 + trippy_ratio * 11.0)) * band_wobble
		var hue_phase := anim_time * (0.75 + trippy_ratio * 0.85) + ratio * (4.6 + trippy_ratio * 5.2)
		var band_color := Color(
			0.5 + 0.5 * sin(hue_phase),
			0.5 + 0.5 * sin(hue_phase + 2.1),
			0.5 + 0.5 * sin(hue_phase + 4.2),
			(0.04 + 0.08 * trippy_ratio) * trippy_mode_strength
		)
		draw_rect(Rect2(Vector2(0.0, y), Vector2(viewport_size.x, band_height + 12.0 + 16.0 * trippy_ratio)), band_color, true)
	var blob_count := 5 + int(floor(trippy_ratio * 7.0))
	for blob_index in range(blob_count):
		var blob_phase := anim_time * (0.6 + float(blob_index) * 0.13 + trippy_ratio * 0.35)
		var blob_center := Vector2(
			viewport_size.x * (0.12 + 0.11 * fmod(float(blob_index), 7.0)) + sin(blob_phase * (1.7 + trippy_ratio * 1.1)) * (46.0 + 72.0 * trippy_ratio) * trippy_mode_strength,
			viewport_size.y * (0.18 + 0.11 * float(blob_index % 5)) + cos(blob_phase * (1.4 + trippy_ratio * 0.9)) * (34.0 + 54.0 * trippy_ratio) * trippy_mode_strength
		)
		var blob_radius := (44.0 + 18.0 * sin(blob_phase * (2.0 + trippy_ratio * 1.2) + float(blob_index))) * (0.45 + trippy_mode_strength * (0.65 + 0.6 * trippy_ratio))
		var blob_color := Color(
			0.6 + 0.4 * sin(blob_phase + 1.1),
			0.6 + 0.4 * sin(blob_phase + 3.0),
			0.6 + 0.4 * sin(blob_phase + 5.0),
			(0.055 + 0.09 * trippy_ratio) * trippy_mode_strength
		)
		draw_circle(blob_center, blob_radius, blob_color)
	if trippy_mode_level >= 4:
		var burst_count := 3 + int(floor(trippy_ratio * 6.0))
		for burst_index in range(burst_count):
			var burst_phase := anim_time * (0.8 + 0.18 * float(burst_index))
			var burst_center := Vector2(
				viewport_size.x * (0.15 + 0.14 * fmod(float(burst_index), 5.0)),
				viewport_size.y * (0.2 + 0.17 * float(burst_index % 4))
			) + Vector2(
				sin(burst_phase * 1.6 + float(burst_index)) * (22.0 + 66.0 * trippy_ratio),
				cos(burst_phase * 1.3 + float(burst_index) * 1.7) * (18.0 + 54.0 * trippy_ratio)
			) * trippy_mode_strength
			var burst_radius := (30.0 + 18.0 * sin(burst_phase * 2.4 + float(burst_index))) * (0.7 + 1.15 * trippy_ratio) * trippy_mode_strength
			var ring_color := Color(
				0.85 + 0.15 * sin(burst_phase + 0.9),
				0.2 + 0.8 * sin(burst_phase + 2.6) * 0.5 + 0.4,
				0.75 + 0.25 * sin(burst_phase + 4.4),
				(0.08 + 0.12 * trippy_ratio) * trippy_mode_strength
			)
			draw_arc(burst_center, burst_radius, 0.0, TAU, 48, ring_color, 2.0 + 3.5 * trippy_ratio, true)
	if trippy_mode_level >= 7:
		var flash_alpha := (0.025 + 0.085 * trippy_ratio) * trippy_mode_strength * (0.5 + 0.5 * sin(anim_time * (7.0 + 6.0 * trippy_ratio)))
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(1.0, 0.24 + 0.3 * sin(anim_time * 1.7), 0.9, flash_alpha), true)
	var vignette_size := 18.0 + 26.0 * trippy_ratio
	var vignette_alpha := (0.08 + 0.08 * trippy_ratio) * trippy_mode_strength
	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, vignette_size)), Color(0.08, 0.0, 0.16, vignette_alpha), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(vignette_size, viewport_size.y)), Color(0.08, 0.0, 0.16, vignette_alpha), true)
	draw_rect(Rect2(Vector2(0.0, viewport_size.y - vignette_size), Vector2(viewport_size.x, vignette_size)), Color(0.0, 0.08, 0.18, vignette_alpha), true)
	draw_rect(Rect2(Vector2(viewport_size.x - vignette_size, 0.0), Vector2(vignette_size, viewport_size.y)), Color(0.0, 0.08, 0.18, vignette_alpha), true)
	var font: Font = ThemeDB.fallback_font
	if font != null:
		var text := "TRIPPY PACMAN x%d/%d" % [maxi(trippy_mode_level, 1), TRIPPY_STAGE_MAX]
		var text_pos := Vector2(
			30.0 + sin(anim_time * (1.8 + trippy_ratio * 0.8)) * (10.0 + 18.0 * trippy_ratio) * trippy_mode_strength,
			176.0 + cos(anim_time * (2.0 + trippy_ratio * 0.7)) * (8.0 + 14.0 * trippy_ratio) * trippy_mode_strength
		)
		draw_string_outline(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 2, Color(0.04, 0.02, 0.06, 0.9))
		draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.92, 1.0, 0.7, 0.7 + 0.25 * trippy_mode_strength))


func _draw_maze() -> void:
	var origin := _maze_origin()
	var theme := _current_wall_theme()
	for row in range(_maze_height()):
		var line := String(MAZE_LAYOUT[row])
		for column in range(line.length()):
			var tile := line.substr(column, 1)
			if tile != "#":
				continue
			var rect := Rect2(origin + Vector2(column, row) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
			draw_rect(rect, theme.get("fill", Color(0.02, 0.06, 0.22, 1.0)), true)
			draw_rect(rect.grow(-3.0), theme.get("line", Color(0.1, 0.22, 0.98, 0.98)), false, 2.0)


func _draw_house_gate() -> void:
	var theme := _current_wall_theme()
	var gate_left := _cell_center(Vector2i(8, 8)).x - TILE_SIZE * 0.42
	var gate_right := _cell_center(Vector2i(10, 8)).x + TILE_SIZE * 0.42
	var gate_y := _cell_center(Vector2i(9, 8)).y + TILE_SIZE * 0.34
	var rect := Rect2(Vector2(gate_left, gate_y), Vector2(gate_right - gate_left, 3.0))
	draw_rect(rect, theme.get("gate", Color(1.0, 0.55, 0.88, 0.98)), true)


func _draw_jail() -> void:
	var theme := _current_wall_theme()
	var line_color: Color = theme.get("line", Color(0.1, 0.22, 0.98, 0.98))
	var fill_color: Color = theme.get("fill", Color(0.02, 0.06, 0.22, 1.0))
	var left_x := _cell_center(Vector2i(7, 8)).x - TILE_SIZE * 0.5
	var right_x := _cell_center(Vector2i(11, 8)).x + TILE_SIZE * 0.5
	var top_y := _cell_center(Vector2i(9, 8)).y - TILE_SIZE * 0.72
	var bottom_y := _cell_center(Vector2i(9, 9)).y + TILE_SIZE * 0.46
	var gate_left := _cell_center(Vector2i(8, 8)).x - TILE_SIZE * 0.42
	var gate_right := _cell_center(Vector2i(10, 8)).x + TILE_SIZE * 0.42
	var house_rect := Rect2(Vector2(left_x, top_y), Vector2(right_x - left_x, bottom_y - top_y))
	draw_rect(house_rect, fill_color.darkened(0.48), true)
	draw_rect(house_rect.grow(-4.0), fill_color.darkened(0.2), true)
	draw_line(Vector2(left_x, top_y), Vector2(gate_left, top_y), line_color, 2.0)
	draw_line(Vector2(gate_right, top_y), Vector2(right_x, top_y), line_color, 2.0)
	draw_line(Vector2(left_x, top_y), Vector2(left_x, bottom_y), line_color, 2.0)
	draw_line(Vector2(right_x, top_y), Vector2(right_x, bottom_y), line_color, 2.0)
	draw_line(Vector2(left_x, bottom_y), Vector2(right_x, bottom_y), line_color, 2.0)


func _draw_pellets() -> void:
	for cell_key in pellets.keys():
		var cell := cell_key as Vector2i
		var pellet_value := int(pellets[cell])
		var center := _cell_center(cell)
		if pellet_value >= 50:
			var pulse := 0.78 + 0.22 * sin(anim_time * 6.0)
			draw_circle(center, 5.6 * pulse, Color(1.0, 0.95, 0.55, 0.96))
			draw_circle(center, 2.0, Color(1.0, 1.0, 0.88, 0.98))
		else:
			draw_circle(center, 2.2, Color(1.0, 0.88, 0.45, 0.94))


func _draw_fruit_icon(center: Vector2, kind: String, scale := 1.0, alpha := 1.0) -> void:
	var stem_color := Color(0.3, 0.8, 0.22, 0.95 * alpha)
	match kind:
		"cherry":
			draw_circle(center + Vector2(-3.2, 1.2) * scale, 4.2 * scale, Color(0.98, 0.18, 0.2, alpha))
			draw_circle(center + Vector2(3.2, -0.2) * scale, 4.2 * scale, Color(1.0, 0.28, 0.24, alpha))
			draw_line(center + Vector2(-2.8, -2.4) * scale, center + Vector2(0.8, -8.0) * scale, stem_color, 2.0)
			draw_line(center + Vector2(3.2, -4.0) * scale, center + Vector2(0.8, -8.0) * scale, stem_color, 2.0)
		"strawberry":
			draw_circle(center, 5.4 * scale, Color(1.0, 0.18, 0.2, alpha))
			for seed_index in range(5):
				var angle := -0.8 + float(seed_index) * 0.45
				draw_circle(center + Vector2(cos(angle) * 2.8, sin(angle) * 2.5) * scale, 0.8 * scale, Color(1.0, 0.95, 0.55, 0.92 * alpha))
			draw_line(center + Vector2(-2.0, -5.0) * scale, center + Vector2(0.0, -8.0) * scale, stem_color, 2.0)
			draw_line(center + Vector2(2.0, -5.0) * scale, center + Vector2(0.0, -8.0) * scale, stem_color, 2.0)
		"orange":
			draw_circle(center, 5.6 * scale, Color(1.0, 0.58, 0.12, alpha))
			draw_circle(center + Vector2(1.2, -1.4) * scale, 2.0 * scale, Color(1.0, 0.76, 0.28, 0.38 * alpha))
		"apple":
			draw_circle(center + Vector2(-2.0, 0.8) * scale, 4.8 * scale, Color(0.96, 0.16, 0.16, alpha))
			draw_circle(center + Vector2(2.0, 0.8) * scale, 4.8 * scale, Color(1.0, 0.24, 0.18, alpha))
			draw_line(center + Vector2(0.0, -3.4) * scale, center + Vector2(1.2, -8.0) * scale, stem_color, 2.0)
			draw_circle(center + Vector2(3.8, -6.4) * scale, 1.8 * scale, Color(0.44, 0.9, 0.24, 0.95 * alpha))
		"melon":
			draw_circle(center, 5.8 * scale, Color(0.34, 0.82, 0.26, alpha))
			draw_arc(center, 5.2 * scale, -0.8, 0.8, 14, Color(0.58, 1.0, 0.46, 0.72 * alpha), 1.6)
		"galaxian":
			var ship := PackedVector2Array([
				center + Vector2(0.0, -7.0) * scale,
				center + Vector2(6.4, 1.2) * scale,
				center + Vector2(2.4, 6.4) * scale,
				center + Vector2(-2.4, 6.4) * scale,
				center + Vector2(-6.4, 1.2) * scale
			])
			draw_colored_polygon(ship, Color(0.48, 0.98, 1.0, alpha))
			draw_circle(center + Vector2(0.0, 0.8) * scale, 2.0 * scale, Color(1.0, 0.32, 0.36, 0.95 * alpha))
		"bell":
			draw_circle(center + Vector2(0.0, -0.8) * scale, 5.2 * scale, Color(1.0, 0.92, 0.28, alpha))
			draw_rect(Rect2(center + Vector2(-4.2, 0.4) * scale, Vector2(8.4, 4.6) * scale), Color(0.98, 0.82, 0.18, alpha), true)
			draw_circle(center + Vector2(0.0, 5.6) * scale, 1.3 * scale, Color(0.8, 0.42, 0.16, 0.95 * alpha))
		"key":
			draw_circle(center + Vector2(-2.8, 0.0) * scale, 3.2 * scale, Color(0.98, 0.9, 0.32, alpha))
			draw_circle(center + Vector2(-2.8, 0.0) * scale, 1.4 * scale, Color(0.0, 0.0, 0.0, alpha))
			draw_rect(Rect2(center + Vector2(-0.6, -1.0) * scale, Vector2(8.6, 2.0) * scale), Color(0.98, 0.9, 0.32, alpha), true)
			draw_rect(Rect2(center + Vector2(5.2, 0.8) * scale, Vector2(1.8, 2.8) * scale), Color(0.98, 0.9, 0.32, alpha), true)
			draw_rect(Rect2(center + Vector2(2.8, 0.8) * scale, Vector2(1.6, 2.2) * scale), Color(0.98, 0.9, 0.32, alpha), true)
		_:
			draw_circle(center, 5.0 * scale, Color(1.0, 0.2, 0.2, alpha))


func _draw_fruit() -> void:
	if not bool(fruit.get("active", false)):
		return
	var center: Vector2 = fruit.get("position", _cell_center(FRUIT_CELL))
	center.y += sin(float(fruit.get("bounce_phase", 0.0))) * 4.5
	_draw_fruit_icon(center, _fruit_kind_for_level(level), 1.14, 0.98)


func _draw_pacman() -> void:
	if pacman.is_empty():
		return
	var center: Vector2 = _tunnel_draw_center(pacman)
	var tunnel_alpha: float = _tunnel_draw_alpha(pacman)
	var direction: Vector2i = pacman.get("direction", DIR_LEFT)
	if direction == Vector2i.ZERO:
		direction = pacman.get("wanted_direction", DIR_RIGHT)
		if direction == Vector2i.ZERO:
			direction = DIR_RIGHT
	var facing_angle := 0.0
	if direction == DIR_LEFT:
		facing_angle = PI
	elif direction == DIR_UP:
		facing_angle = -PI * 0.5
	elif direction == DIR_DOWN:
		facing_angle = PI * 0.5
	var radius := TILE_SIZE * 0.42 * _powered_growth_scale()
	var powered := frightened_timer > 0.0
	var body_color := Color(1.0, 0.9, 0.08, tunnel_alpha)
	if powered:
		var fade := 0.42 + 0.58 * (0.5 + 0.5 * sin(anim_time * 16.0))
		body_color = Color(1.0, 0.95, 0.38, fade * tunnel_alpha)
		draw_circle(center, radius * 1.22, Color(1.0, 0.95, 0.55, (0.22 + fade * 0.24) * tunnel_alpha))
		draw_circle(center, radius * 1.42, Color(1.0, 0.88, 0.32, (0.06 + fade * 0.08) * tunnel_alpha))
	if trippy_mode_active and trippy_mode_level >= 3:
		var red_pulse := 0.5 + 0.5 * sin(anim_time * 5.2)
		draw_circle(center, radius * 1.32, Color(1.0, 0.16, 0.14, (0.18 + red_pulse * 0.2) * tunnel_alpha))
		draw_circle(center, radius * 1.62, Color(1.0, 0.06, 0.06, (0.05 + red_pulse * 0.1) * tunnel_alpha))
		body_color = Color(1.0, 0.14, 0.12, (0.34 + red_pulse * 0.64) * tunnel_alpha)
	draw_circle(center, radius, body_color)
	var mouth_open := lerpf(0.04, 0.58, _pacman_chomp_amount(direction))
	var mouth_a := facing_angle + mouth_open
	var mouth_b := facing_angle - mouth_open
	var mouth_poly := PackedVector2Array([
		center,
		center + Vector2(cos(mouth_a), sin(mouth_a)) * radius * 1.34,
		center + Vector2(cos(mouth_b), sin(mouth_b)) * radius * 1.34
	])
	draw_colored_polygon(mouth_poly, Color(0.0, 0.0, 0.0, tunnel_alpha))
	var eye_pos := center + _pacman_eye_offset(direction, radius)
	draw_circle(eye_pos, radius * 0.09, Color(0.0, 0.0, 0.0, 0.92 * tunnel_alpha))
	if pac_idle_timer >= 3.0 and game_state == "play" and not demo_mode:
		_draw_pacman_idle_cigarette(center, direction, facing_angle, radius, tunnel_alpha)


func _draw_pacman_idle_cigarette(center: Vector2, direction: Vector2i, facing_angle: float, radius: float, alpha: float) -> void:
	var forward := Vector2(cos(facing_angle), sin(facing_angle))
	var side := Vector2(-forward.y, forward.x)
	var mouth_pos := center + forward * radius * 0.64 + side * radius * 0.05
	var cig_start := mouth_pos
	var cig_end := mouth_pos + forward * radius * 0.56
	draw_line(cig_start, cig_end, Color(0.98, 0.94, 0.84, 0.98 * alpha), 3.4)
	draw_line(cig_start + forward * radius * 0.1, cig_end - forward * radius * 0.12, Color(0.86, 0.78, 0.66, 0.36 * alpha), 1.4)
	draw_line(cig_end - forward * radius * 0.12, cig_end, Color(1.0, 0.44, 0.12, (0.8 + 0.2 * sin(anim_time * 8.0)) * alpha), 3.4)
	var smoke_origin := cig_end + Vector2(0.0, -radius * 0.04)
	for puff_index in range(4):
		var puff_age := fposmod(anim_time * 0.42 + float(puff_index) * 0.31, 1.0)
		var puff_pos := smoke_origin + Vector2(
			sin(anim_time * 1.7 + float(puff_index) * 0.8) * radius * 0.24,
			-radius * (0.28 + puff_age * 0.84)
		)
		var puff_radius := radius * (0.12 + puff_age * 0.14)
		var puff_alpha := (0.24 + (1.0 - puff_age) * 0.28) * alpha
		draw_circle(puff_pos, puff_radius, Color(0.84, 0.84, 0.88, puff_alpha))


func _draw_ghosts() -> void:
	for ghost in ghosts:
		var center: Vector2 = _tunnel_draw_center(ghost)
		var tunnel_alpha: float = _tunnel_draw_alpha(ghost)
		var stun_timer := float(ghost.get("stun_timer", 0.0))
		var eaten_anim := float(ghost.get("eaten_anim", 0.0))
		if eaten_anim > 0.0:
			var total := maxf(float(ghost.get("eaten_total", GHOST_EAT_ANIM_DURATION)), 0.001)
			var progress := 1.0 - eaten_anim / total
			var eaten_origin: Vector2 = ghost.get("eaten_origin", center)
			var eaten_target: Vector2 = ghost.get("eaten_target", center)
			var draw_center := eaten_origin.lerp(eaten_target, clampf(progress, 0.0, 1.0))
			var size := TILE_SIZE * (0.18 + (1.0 - progress) * 0.04)
			draw_circle(draw_center, size, Color(1.0, 0.96, 0.72, 0.96 * tunnel_alpha))
			draw_circle(draw_center, size * 1.8, Color(1.0, 0.92, 0.45, 0.16 * tunnel_alpha))
			continue
		var frightened := bool(ghost.get("frightened", false))
		var color: Color = ghost.get("color", Color.WHITE)
		if frightened:
			var blink_warning := frightened_timer > 0.0 and frightened_timer <= FRIGHTENED_BLINK_WARNING_TIME
			if blink_warning and int(floor(anim_time * 10.0)) % 2 == 0:
				color = Color(1.0, 1.0, 1.0, 1.0)
			else:
				color = Color(0.28, 0.55, 1.0, 1.0)
		var special_kind := String(ghost.get("special_kind", ""))
		if not special_kind.is_empty():
			_draw_special_ghost(center, ghost, special_kind, tunnel_alpha, stun_timer, frightened)
			continue
		color.a *= tunnel_alpha
		var size := TILE_SIZE * 0.76
		var head_center := center + Vector2(0.0, -size * 0.16)
		draw_circle(head_center, size * 0.38, color)
		draw_rect(Rect2(center + Vector2(-size * 0.38, -size * 0.14), Vector2(size * 0.76, size * 0.56)), color, true)
		for bump in range(4):
			var x := center.x - size * 0.3 + float(bump) * size * 0.2
			var y := center.y + size * 0.33 + (size * 0.06 if bump % 2 == 0 else 0.0)
			draw_circle(Vector2(x, y), size * 0.1, color)
		for side in [-1.0, 1.0]:
			var eye_center := center + Vector2(side * size * 0.15, -size * 0.06)
			draw_circle(eye_center, size * 0.08, Color(1.0, 1.0, 1.0, 0.98 * tunnel_alpha))
			draw_circle(eye_center + Vector2(side * size * 0.015, size * 0.02), size * 0.035, Color(0.04, 0.09, 0.22, 0.96 * tunnel_alpha))
		if stun_timer > 0.0:
			for star_index in range(3):
				var angle := anim_time * 6.0 + float(star_index) * TAU / 3.0
				var orbit := Vector2(cos(angle), sin(angle)) * (size * 0.3)
				draw_circle(center + Vector2(0.0, -size * 0.46) + orbit, size * 0.05, Color(1.0, 0.96, 0.42, 0.9 * tunnel_alpha))


func _draw_special_ghost(center: Vector2, ghost: Dictionary, special_kind: String, tunnel_alpha: float, stun_timer: float, frightened: bool) -> void:
	var texture: Texture2D = null
	var label := ""
	var label_color := Color(0.96, 0.96, 1.0, 0.92 * tunnel_alpha)
	match special_kind:
		"charles":
			texture = CHARLES_GHOST_TEXTURE
			label = "CHARLES"
			label_color = Color(0.68, 1.0, 0.9, 0.92 * tunnel_alpha)
		"veil":
			texture = VEIL_GHOST_TEXTURE
			label = "VEIL"
			label_color = Color(0.96, 0.96, 1.0, 0.92 * tunnel_alpha)
		"pyro":
			texture = PYRO_GHOST_TEXTURE
			label = "PYRO"
			label_color = Color(1.0, 0.74, 0.44, 0.92 * tunnel_alpha)
		"bistro":
			texture = BISTRO_GHOST_TEXTURE
			label = "BISTRO"
			label_color = Color(0.92, 0.96, 1.0, 0.92 * tunnel_alpha)
	if texture == null:
		return
	var size := TILE_SIZE * 0.76
	var badge_size := Vector2(size * 0.64, size * 0.62)
	if special_kind == "bistro":
		badge_size = Vector2(size * 0.72, size * 0.56)
	elif special_kind == "veil":
		badge_size = Vector2(size * 0.54, size * 0.56)
	var badge_center := center + Vector2(0.0, -size * 0.02)
	var draw_color := Color(1.0, 1.0, 1.0, 0.98 * tunnel_alpha)
	if frightened:
		var pulse := 0.72 + 0.28 * (0.5 + 0.5 * sin(anim_time * 3.2))
		draw_color = Color(pulse, pulse, pulse, 0.98 * tunnel_alpha)
	draw_round_rect(
		Rect2(badge_center - badge_size * 0.5 - Vector2(2.0, 2.0), badge_size + Vector2(4.0, 4.0)),
		Color(0.02, 0.03, 0.05, 0.84 * tunnel_alpha),
		4.0
	)
	draw_texture_rect(texture, Rect2(badge_center - badge_size * 0.5, badge_size), false, draw_color)
	var font: Font = ThemeDB.fallback_font
	if font != null:
		var label_size := 9 if label.length() >= 7 else (10 if label.length() >= 6 else 11)
		var label_pos := center + Vector2(-badge_size.x * 0.6, -size * 0.62)
		draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, 2, Color(0.02, 0.02, 0.02, 0.88 * tunnel_alpha))
		draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, label_color)
	if frightened:
		for star_index in range(4):
			var star_phase := anim_time * 1.8 + float(star_index) * 1.4
			var star_offset := Vector2(
				cos(star_phase) * size * 0.28,
				sin(star_phase * 1.1) * size * 0.18 - size * 0.1
			)
			var star_alpha := (0.16 + 0.24 * (0.5 + 0.5 * sin(star_phase * 2.0))) * tunnel_alpha
			draw_circle(center + star_offset, size * 0.04, Color(1.0, 0.96, 0.56, star_alpha))
			draw_line(
				center + star_offset + Vector2(-size * 0.05, 0.0),
				center + star_offset + Vector2(size * 0.05, 0.0),
				Color(1.0, 0.96, 0.72, star_alpha),
				1.0
			)
			draw_line(
				center + star_offset + Vector2(0.0, -size * 0.05),
				center + star_offset + Vector2(0.0, size * 0.05),
				Color(1.0, 0.96, 0.72, star_alpha),
				1.0
			)
	if stun_timer > 0.0:
		for star_index in range(3):
			var angle := anim_time * 6.0 + float(star_index) * TAU / 3.0
			var orbit := Vector2(cos(angle), sin(angle)) * (size * 0.3)
			draw_circle(center + Vector2(0.0, -size * 0.46) + orbit, size * 0.05, Color(1.0, 0.96, 0.42, 0.9 * tunnel_alpha))


func draw_round_rect(rect: Rect2, color: Color, radius: float) -> void:
	var safe_radius := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	draw_rect(Rect2(rect.position + Vector2(safe_radius, 0.0), Vector2(rect.size.x - safe_radius * 2.0, rect.size.y)), color, true)
	draw_rect(Rect2(rect.position + Vector2(0.0, safe_radius), Vector2(rect.size.x, rect.size.y - safe_radius * 2.0)), color, true)
	draw_circle(rect.position + Vector2(safe_radius, safe_radius), safe_radius, color)
	draw_circle(rect.position + Vector2(rect.size.x - safe_radius, safe_radius), safe_radius, color)
	draw_circle(rect.position + Vector2(safe_radius, rect.size.y - safe_radius), safe_radius, color)
	draw_circle(rect.position + Vector2(rect.size.x - safe_radius, rect.size.y - safe_radius), safe_radius, color)


func _draw_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var viewport_size := get_viewport_rect().size
	if display_buttons_enabled and not _show_panel_display_controls():
		_draw_fullscreen_button(font)
	var top_left := Vector2(28.0, 38.0)
	draw_string_outline(font, top_left, "TRIPPY GOLD MAZE", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, 2, Color(0.06, 0.05, 0.02, 0.96))
	draw_string(font, top_left, "TRIPPY GOLD MAZE", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1.0, 0.92, 0.42, 0.98))
	var info_pos := Vector2(28.0, 72.0)
	draw_string_outline(font, info_pos, "SCORE %d   HI %d   LIVES %d" % [score, high_score, lives], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, info_pos, "SCORE %d   HI %d   LIVES %d" % [score, high_score, lives], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.98, 0.86, 0.98))
	var fruit_label_pos := Vector2(28.0, 97.0)
	draw_string_outline(font, fruit_label_pos, "FRUITS", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, fruit_label_pos, "FRUITS", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.95, 0.72, 0.96))
	var fruit_icons := _fruit_counter_kinds_for_level(level)
	var fruit_start := Vector2(102.0, 92.0)
	for icon_index in range(fruit_icons.size()):
		_draw_fruit_icon(fruit_start + Vector2(float(icon_index) * 24.0, 0.0), fruit_icons[icon_index], 0.72, 0.98)
	var ability_text := "TILT %d/2" % ability_charges
	if ability_tilt_timer > 0.0:
		ability_text += "  |  OVERHEAT %.0fs" % ceil(ability_tilt_timer)
	elif not ability_recharge_timers.is_empty():
		ability_text += "  |  RECHARGE %.0fs" % ceil(float(ability_recharge_timers[0]))
	if demo_mode:
		ability_text += "  |  DEMO"
	var ability_pos := Vector2(28.0, 124.0)
	draw_string_outline(font, ability_pos, ability_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, ability_pos, ability_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.82, 0.96, 1.0, 0.96))
	if frightened_timer > 0.0 or power_combo_flash_timer > 0.0:
		var combo_text := "POWER %.1fs  |  BALLS %d  |  GHOSTS %d  |  PELLETS %d" % [frightened_timer, power_combo_power_balls, power_combo_ghosts, power_combo_pellets]
		var combo_color := Color(1.0, 0.92, 0.4, 0.98) if power_combo_flash_timer <= 0.0 else Color(1.0, 1.0, 0.75, 0.98)
		var combo_pos := Vector2(28.0, 148.0)
		draw_string_outline(font, combo_pos, combo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 2, Color(0.04, 0.03, 0.02, 0.95))
		draw_string(font, combo_pos, combo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, combo_color)
	var help_pos := Vector2(28.0, viewport_size.y - 28.0)
	var help_text := "SWIPE TO MOVE   TAP TILT   ESC RETURNS TO MENU" if touch_controls_enabled else "ARROWS / WASD MOVE   ENTER OR SPACE TILTS   ESC RETURNS TO MENU"
	draw_string_outline(font, help_pos, help_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, help_pos, help_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.92, 0.96, 1.0, 0.95))


func _draw_fullscreen_button(font: Font) -> void:
	var rect := _fullscreen_button_rect()
	var active_color := Color(0.82, 0.96, 1.0, 0.96) if fullscreen_fill_enabled else Color(1.0, 0.95, 0.72, 0.94)
	draw_rect(rect, Color(0.08, 0.1, 0.16, 0.82), true)
	draw_rect(rect.grow(-3.0), Color(0.02, 0.03, 0.05, 0.7), true)
	draw_rect(rect, active_color, false, 2.0)
	var label := "FULL SCREEN ON" if fullscreen_fill_enabled else "FULL SCREEN"
	var label_pos := rect.position + Vector2(12.0, 29.0)
	draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, active_color)
	var orientation_rect := _orientation_button_rect()
	var orientation_color := Color(0.92, 0.96, 1.0, 0.96) if presentation_orientation == "landscape" else Color(1.0, 0.86, 0.92, 0.96)
	draw_rect(orientation_rect, Color(0.08, 0.1, 0.16, 0.82), true)
	draw_rect(orientation_rect.grow(-3.0), Color(0.02, 0.03, 0.05, 0.7), true)
	draw_rect(orientation_rect, orientation_color, false, 2.0)
	var orientation_label := "LANDSCAPE" if presentation_orientation == "landscape" else "PORTRAIT"
	var orientation_pos := orientation_rect.position + Vector2(12.0, 29.0)
	draw_string_outline(font, orientation_pos, orientation_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, orientation_pos, orientation_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, orientation_color)
	var fit_rect := _fit_button_rect()
	var fit_color := Color(0.88, 0.98, 0.82, 0.96) if presentation_fit_mode == "fit" else Color(0.98, 0.9, 0.72, 0.96)
	draw_rect(fit_rect, Color(0.08, 0.1, 0.16, 0.82), true)
	draw_rect(fit_rect.grow(-3.0), Color(0.02, 0.03, 0.05, 0.7), true)
	draw_rect(fit_rect, fit_color, false, 2.0)
	var fit_label := "SCREEN FIT" if presentation_fit_mode == "fit" else "SCREEN FILL"
	var fit_pos := fit_rect.position + Vector2(12.0, 29.0)
	draw_string_outline(font, fit_pos, fit_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, fit_pos, fit_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, fit_color)


func _draw_touch_controls(font: Font) -> void:
	var rect := _touch_tilt_button_rect()
	var ready := ability_charges > 0 and ability_tilt_timer <= 0.0
	var base_color := Color(0.14, 0.18, 0.28, 0.8)
	var glow_color := Color(0.88, 0.82, 0.34, 0.92) if ready else Color(0.42, 0.46, 0.58, 0.84)
	draw_rect(rect, base_color, true)
	draw_rect(rect.grow(-3.0), Color(0.04, 0.05, 0.08, 0.72), true)
	draw_rect(rect, glow_color, false, 2.0)
	var label := "TILT" if ready else ("OVERHEAT" if ability_tilt_timer > 0.0 else "RECHARGE")
	var sublabel := "%d/2" % ability_charges if ready else ("%.0fs" % ceil(ability_tilt_timer) if ability_tilt_timer > 0.0 else "%.0fs" % ceil(float(ability_recharge_timers[0])) if not ability_recharge_timers.is_empty() else "0/2")
	var label_pos := rect.position + Vector2(18.0, 28.0)
	var sub_pos := rect.position + Vector2(18.0, 52.0)
	draw_string_outline(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.96, 0.82, 0.98))
	draw_string_outline(font, sub_pos, sublabel, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 2, Color(0.04, 0.03, 0.02, 0.95))
	draw_string(font, sub_pos, sublabel, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, glow_color.lightened(0.18))


func _draw_overlay() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var center := get_viewport_rect().size * 0.5
	match game_state:
		"intro":
			_draw_arcade_menu(font, center, "TRIPPY GOLD MAZE", "CHOMP • CHASE • SURVIVE")
		"ready":
			_draw_center_message(font, center, "DEMO READY" if demo_mode else "READY", "")
		"dead":
			_draw_center_message(font, center, "YOU GOT CHOMPED", "")
		"level_clear":
			_draw_center_message(font, center, "LEVEL CLEAR", "")
		"game_over":
			_draw_arcade_menu(font, center, "GAME OVER", "SCORE %d   HIGH %d" % [score, high_score])


func _draw_pause_menu() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var center := get_viewport_rect().size * 0.5
	var panel := Rect2(center - Vector2(255.0, 280.0), Vector2(510.0, 560.0))
	draw_rect(panel, Color(0.005, 0.01, 0.04, 0.97), true)
	draw_rect(panel, Color(0.1, 0.9, 1.0, 1.0), false, 4.0)
	draw_string(font, panel.position + Vector2(20.0, 52.0), "GAME PAUSED", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 40.0, 34, Color(1.0, 0.9, 0.18))
	for item_index in range(PAUSE_ITEMS.size()):
		var row := Rect2(panel.position + Vector2(54.0, 76.0 + item_index * 61.0), Vector2(panel.size.x - 108.0, 47.0))
		var selected := item_index == pause_selection
		draw_rect(row, Color(0.08, 0.5, 0.78, 0.42) if selected else Color(0.02, 0.04, 0.12, 0.82), true)
		draw_rect(row, Color(1.0, 0.82, 0.16) if selected else Color(0.15, 0.38, 0.58), false, 2.0)
		var label: String = String(PAUSE_ITEMS[item_index])
		if item_index == 3:
			label = "MUSIC: %s" % ("ON" if music_enabled else "OFF")
		elif item_index == 4:
			label = "SCREEN MODE: %s" % presentation_fit_mode.to_upper()
		elif item_index == 5:
			label = "FULL SCREEN: %s" % ("ON" if fullscreen_fill_enabled else "OFF")
		elif item_index == 6:
			label = "DISPLAY BUTTONS: %s" % ("ON" if display_buttons_enabled else "OFF")
		draw_string(font, row.position + Vector2(8.0, 31.0), label, HORIZONTAL_ALIGNMENT_CENTER, row.size.x - 16.0, 20, Color.WHITE)
	if controller_help_timer > 0.0:
		draw_string(font, panel.position + Vector2(24.0, panel.size.y - 24.0), "CABINET, XBOX & USB PADS AUTO-DETECTED", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48.0, 15, Color(0.55, 0.96, 1.0))


func _start_control_wizard() -> void:
	control_wizard_open = true
	control_wizard_step = 0
	control_wizard_device = -1
	control_wizard_name = ""
	control_wizard_hold_button = -1
	pause_open = true


func _advance_control_wizard() -> void:
	control_wizard_step += 1
	if control_wizard_step >= CONTROL_ACTIONS.size():
		control_wizard_open = false
		_save_controller_mappings()
		controller_help_timer = 4.0
	queue_redraw()


func _store_control_binding(action: String, binding: String) -> void:
	var name := control_wizard_name.to_lower().strip_edges()
	if name.is_empty():
		name = "device_%d" % control_wizard_device
	if not controller_mappings.has(name):
		controller_mappings[name] = {}
	controller_mappings[name][action] = binding


func _mapped_axis_action(device_name: String, axis: int, value: float) -> String:
	var mappings: Dictionary = controller_mappings.get(device_name.strip_edges(), {})
	for action in CONTROL_ACTIONS:
		var binding := String(mappings.get(action, ""))
		var parts := binding.split(",")
		if parts.size() == 3 and parts[0] == "axis" and int(parts[1]) == axis and int(parts[2]) == (1 if value > 0.0 else -1):
			return action
	return ""


func _mapped_button_action(device_name: String, button: int) -> String:
	var mappings: Dictionary = controller_mappings.get(device_name.strip_edges(), {})
	for action in CONTROL_ACTIONS:
		var binding := String(mappings.get(action, ""))
		if binding == "button,%d" % button:
			return action
	return ""


func _dispatch_control_action(action: String) -> void:
	match action:
		"UP": _handle_navigation(DIR_UP)
		"DOWN": _handle_navigation(DIR_DOWN)
		"LEFT": _handle_navigation(DIR_LEFT)
		"RIGHT": _handle_navigation(DIR_RIGHT)
		"TILT / ACTION":
			if game_state in ["intro", "game_over"]: _activate_menu_item()
			elif game_state == "play": _activate_tilt_burst()
		"PAUSE", "START":
			if game_state not in ["intro", "game_over"]: _set_pause(not pause_open)
		"SELECT": pass


func _save_controller_mappings() -> void:
	var config := ConfigFile.new()
	for device_name in controller_mappings:
		for action in controller_mappings[device_name]:
			config.set_value(device_name, action, controller_mappings[device_name][action])
	config.save("user://goldmaze_controls.cfg")


func _save_display_settings() -> void:
	var config := ConfigFile.new()
	config.load("user://goldmaze_display.cfg")
	config.set_value("display", "buttons_enabled", display_buttons_enabled)
	config.save("user://goldmaze_display.cfg")


func _load_display_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://goldmaze_display.cfg") == OK:
		display_buttons_enabled = bool(config.get_value("display", "buttons_enabled", false))


func _load_controller_mappings() -> void:
	var config := ConfigFile.new()
	if config.load("user://goldmaze_controls.cfg") != OK:
		return
	for section in config.get_sections():
		controller_mappings[section] = {}
		for key in config.get_section_keys(section):
			controller_mappings[section][key] = config.get_value(section, key, "")


func _draw_control_wizard() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var size := get_viewport_rect().size
	var panel := Rect2(size * 0.5 - Vector2(285.0, 170.0), Vector2(570.0, 340.0))
	draw_rect(panel, Color(0.0, 0.01, 0.05, 0.99), true)
	draw_rect(panel, Color(0.15, 0.92, 1.0), false, 4.0)
	draw_string(font, panel.position + Vector2(20.0, 56.0), "CONTROLLER SETUP", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 40.0, 32, Color(1.0, 0.88, 0.18))
	var prompt := "PRESS: %s" % CONTROL_ACTIONS[control_wizard_step]
	draw_string(font, panel.position + Vector2(20.0, 140.0), prompt, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 40.0, 29, Color.WHITE)
	draw_string(font, panel.position + Vector2(24.0, 205.0), "Move the stick or tap the button you want to use.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48.0, 18, Color(0.62, 0.94, 1.0))
	draw_string(font, panel.position + Vector2(24.0, 245.0), "Hold any already assigned button for 1 second to skip.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48.0, 16, Color(0.82, 0.84, 0.94))
	draw_string(font, panel.position + Vector2(24.0, 300.0), "STEP %d OF %d" % [control_wizard_step + 1, CONTROL_ACTIONS.size()], HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48.0, 16, Color(1.0, 0.54, 0.8))


func _draw_exit_confirmation() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var size := get_viewport_rect().size
	var rect := Rect2(Vector2(40.0, size.y - 112.0), Vector2(size.x - 80.0, 74.0))
	draw_rect(rect, Color(0.12, 0.0, 0.04, 0.96), true)
	draw_rect(rect, Color(1.0, 0.24, 0.42), false, 3.0)
	draw_string(font, rect.position + Vector2(10.0, 46.0), "PRESS START + SELECT AGAIN WITHIN 2 SECONDS TO EXIT", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 20.0, 18, Color.WHITE)


func _draw_arcade_menu(font: Font, center: Vector2, title: String, subtitle: String) -> void:
	var panel := Rect2(center - Vector2(250.0, 230.0), Vector2(500.0, 460.0))
	draw_rect(panel, Color(0.005, 0.01, 0.04, 0.94), true)
	draw_rect(panel.grow(-5.0), Color(0.02, 0.02, 0.11, 0.94), true)
	draw_rect(panel, Color(0.12, 0.88, 1.0, 0.95), false, 4.0)
	draw_rect(panel.grow(-10.0), Color(1.0, 0.2, 0.72, 0.82), false, 2.0)
	var title_width := panel.size.x - 40.0
	draw_string_outline(font, panel.position + Vector2(20.0, 65.0), title, HORIZONTAL_ALIGNMENT_CENTER, title_width, 38, 4, Color.BLACK)
	draw_string(font, panel.position + Vector2(20.0, 65.0), title, HORIZONTAL_ALIGNMENT_CENTER, title_width, 38, Color(1.0, 0.9, 0.16))
	draw_string(font, panel.position + Vector2(20.0, 98.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, title_width, 17, Color(0.5, 0.95, 1.0))
	for item_index in range(MENU_ITEMS.size()):
		var row := Rect2(panel.position + Vector2(54.0, 130.0 + item_index * 62.0), Vector2(panel.size.x - 108.0, 48.0))
		var selected := item_index == menu_selection
		var row_color := Color(0.1, 0.72, 0.95, 0.3) if selected else Color(0.02, 0.04, 0.12, 0.78)
		draw_rect(row, row_color, true)
		draw_rect(row, Color(1.0, 0.86, 0.2, 1.0) if selected else Color(0.18, 0.42, 0.62, 0.7), false, 3.0 if selected else 1.0)
		var label: String = String(MENU_ITEMS[item_index])
		if item_index == 1:
			label = "FULL SCREEN: %s" % ("ON" if fullscreen_fill_enabled else "OFF")
		elif item_index == 2:
			label = "SCREEN MODE: %s" % presentation_fit_mode.to_upper()
		draw_string(font, row.position + Vector2(8.0, 32.0), label, HORIZONTAL_ALIGNMENT_CENTER, row.size.x - 16.0, 22, Color.WHITE if selected else Color(0.72, 0.82, 0.96))
	draw_string(font, panel.position + Vector2(20.0, panel.size.y - 28.0), "D-PAD / STICK: MOVE    A / START: SELECT    B: EXIT", HORIZONTAL_ALIGNMENT_CENTER, title_width, 14, Color(0.72, 0.9, 1.0))


func _draw_center_message(font: Font, center: Vector2, title: String, subtitle: String) -> void:
	var panel := _center_message_panel_rect(center)
	draw_rect(panel, Color(0.0, 0.0, 0.0, 0.78), true)
	draw_rect(panel, Color(1.0, 0.85, 0.28, 0.92), false, 2.0)
	var title_pos := panel.position + Vector2(26.0, 48.0)
	draw_string_outline(font, title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, 2, Color(0.06, 0.04, 0.01, 0.96))
	draw_string(font, title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1.0, 0.92, 0.36, 0.98))
	if not subtitle.is_empty():
		var subtitle_pos := panel.position + Vector2(26.0, 84.0)
		draw_string_outline(font, subtitle_pos, subtitle, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 52.0, 16, 2, Color(0.04, 0.03, 0.02, 0.95))
		draw_string(font, subtitle_pos, subtitle, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 52.0, 16, Color(0.98, 0.98, 0.94, 0.95))
