extends SpeedbikeMode

const ONLINE_SEND_INTERVAL := 0.025
const REMOTE_INTERP_SPEED := 25.0
const REMOTE_JUMP_INTERP_SPEED := 30.0
const REMOTE_PREDICTION_MAX := 0.20
const ONLINE_SPECTATOR_CAMERA_LERP := 16.0
const ONLINE_WRECK_DRIFT_SPEED := 96.0
const ONLINE_WRECK_FALL_SPEED := 42.0

var remote_speedbike: SpeedbikeController
var remote_rider_id := ""
var remote_target_position := Vector2.ZERO
var remote_target_velocity := Vector2.ZERO
var remote_target_jump_z := 0.0
var remote_target_valid := false
var remote_target_received_ms := 0
var remote_last_update_stamp := 0
var remote_last_crashed := false
var online_send_timer := 0.0
var online_death_mode := "revive_after_two_checkpoints"
var online_death_mode_button: Button
var online_last_team_restart_serial := -1
var online_last_local_revive_serial := -1
var online_waiting_for_revive := false
var online_suppress_crash_event := false
var online_waiting_for_partner_start := false
var online_local_wreck_offset := -1.0
var online_local_wreck_y := 0.0
var online_remote_wreck_started_ms := 0
var online_remote_wreck_start_offset := -1.0
var online_remote_wreck_start_y := 0.0
var observer_primary_rider_id := ""
var online_leave_match_button: Button


func _ready() -> void:
	super._ready()
	if not NetworkClient.match_state_changed.is_connected(_on_match_state_changed):
		NetworkClient.match_state_changed.connect(_on_match_state_changed)
	_add_online_death_mode_control()
	_add_online_leave_match_control()
	_ensure_remote_speedbike()
	if _online_is_observer():
		_prepare_online_observer_mode()
	_apply_online_speedbike_state()
	_send_online_speedbike_input(true)


func _setup_mode_context() -> void:
	super._setup_mode_context()
	_apply_online_stage_hint(_online_requested_stage_id(), false)


func _exit_tree() -> void:
	if NetworkClient.match_state_changed.is_connected(_on_match_state_changed):
		NetworkClient.match_state_changed.disconnect(_on_match_state_changed)


func _physics_process(delta: float) -> void:
	if _online_is_observer():
		_tick_online_observer(delta)
		return
	if online_waiting_for_partner_start:
		_apply_online_speedbike_state()
		if _online_both_riders_ready(_online_speedbike_state()):
			online_waiting_for_partner_start = false
			player_speedbike.set_control_locked(false)
			_show_warning("BOTH RIDERS READY - GO", 0.9)
		else:
			player_speedbike.set_control_locked(true)
			_tick_flash_and_audio(delta)
			_tick_remote_speedbike(delta)
			_send_online_speedbike_input(false)
			_update_hud()
			queue_redraw()
			return
	if online_waiting_for_revive:
		_tick_online_revive_spectator(delta)
		return
	var overlay_menu_open := pause_open
	if overlay_menu_open:
		pause_open = false
	super._physics_process(delta)
	if overlay_menu_open:
		pause_open = true
		pause_panel.visible = true
	_apply_online_speedbike_state()
	_tick_remote_speedbike(delta)
	_send_online_speedbike_input(false)


func _process(delta: float) -> void:
	if _online_is_observer():
		_apply_online_observer_state()
		return
	super._process(delta)
	_apply_online_speedbike_state()
	_tick_remote_speedbike(delta)


func _set_speedbike_rider(rider_id: String) -> void:
	super._set_speedbike_rider(rider_id)
	_send_online_speedbike_input(true)


func _deploy_selected_rider() -> void:
	super._deploy_selected_rider()
	if not _online_both_riders_ready(_online_speedbike_state()):
		online_waiting_for_partner_start = true
		player_speedbike.set_control_locked(true)
		_show_warning("WAITING FOR PARTNER RIDER", 1.2)
	_send_online_speedbike_input(true)


func _trigger_crash(hit_position: Vector2) -> void:
	if crash_restart_timer > 0.0 or online_waiting_for_revive:
		return
	super._trigger_crash(hit_position)
	_emit_online_crash()
	if online_death_mode == "revive_after_two_checkpoints" and not online_suppress_crash_event:
		online_waiting_for_revive = true
		crash_restart_timer = -1.0
		player_speedbike.set_control_locked(true)
		player_speedbike.set_crashed(true)
		_start_local_wreck_visual()
		_show_warning("BIKE LOST - PARTNER MUST CLEAR 2 CHECKPOINTS", 1.35)


func _trigger_disintegration_crash(hit_position: Vector2) -> void:
	if crash_restart_timer > 0.0 or online_waiting_for_revive:
		return
	super._trigger_disintegration_crash(hit_position)
	_emit_online_crash()
	if online_death_mode == "revive_after_two_checkpoints" and not online_suppress_crash_event:
		online_waiting_for_revive = true
		crash_restart_timer = -1.0
		player_speedbike.set_control_locked(true)
		player_speedbike.set_crashed(true)
		_start_local_wreck_visual()
		_show_warning("RIDER DOWN - WAITING ON PARTNER CHECKPOINTS", 1.35)


func _handle_player_hit(source: String, hit_position: Vector2) -> void:
	if online_waiting_for_revive:
		return
	super._handle_player_hit(source, hit_position)


func _commit_checkpoint(next_event_index: int = -1) -> void:
	super._commit_checkpoint(next_event_index)
	if _online_is_observer():
		return
	NetworkClient.send_speedbike_checkpoint({
		"stage_id": stage_map_id,
		"checkpoint": checkpoint_count,
		"stage_elapsed": stage_elapsed
	})


func _add_online_death_mode_control() -> void:
	if online_death_mode_button != null or character_deploy_button == null:
		return
	var parent := character_deploy_button.get_parent()
	if parent == null:
		return
	online_death_mode_button = Button.new()
	online_death_mode_button.focus_mode = Control.FOCUS_ALL
	online_death_mode_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_death_mode_button.pressed.connect(_toggle_online_death_mode)
	parent.add_child(online_death_mode_button)
	parent.move_child(online_death_mode_button, max(0, character_deploy_button.get_index()))
	_sync_online_death_mode_button()


func _add_online_leave_match_control() -> void:
	if online_leave_match_button != null or pause_main_section == null:
		return
	online_leave_match_button = Button.new()
	online_leave_match_button.text = "LEAVE MATCH"
	online_leave_match_button.focus_mode = Control.FOCUS_ALL
	online_leave_match_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_leave_match_button.tooltip_text = "Disconnect from this online room and return to the war room."
	online_leave_match_button.pressed.connect(_leave_online_match)
	pause_main_section.add_child(online_leave_match_button)


func _toggle_online_death_mode() -> void:
	online_death_mode = "shared_crash" if online_death_mode == "revive_after_two_checkpoints" else "revive_after_two_checkpoints"
	_sync_online_death_mode_button()
	_send_online_speedbike_input(true)


func _sync_online_death_mode_button() -> void:
	if online_death_mode_button == null:
		return
	online_death_mode_button.text = "CO-OP DEATH: %s" % ("BOTH CRASH" if online_death_mode == "shared_crash" else "REVIVE AFTER 2 CHECKPOINTS")
	online_death_mode_button.tooltip_text = "Choose whether one crash wipes both riders or the downed rider waits until the partner clears two checkpoints."


func _online_is_observer() -> bool:
	return NetworkClient.your_seat < 0 and bool(NetworkClient.pending_match.get("observer", false))


func _online_requested_stage_id() -> String:
	var candidates := [
		str(NetworkClient.pending_match.get("speedbike_stage_id", "")),
		str(NetworkClient.match_state.get("speedbike_stage_id", "")),
		str(_online_speedbike_state().get("stage_id", "")),
		str(_online_speedbike_state().get("start_stage_id", ""))
	]
	for candidate in candidates:
		var stage_id := str(candidate).strip_edges()
		if not stage_id.is_empty() and SPEEDBIKE_STAGE_FILES.has(stage_id):
			return stage_id
	return ""


func _apply_online_stage_hint(stage_id: String, reload_stage := false) -> bool:
	var clean_id := stage_id.strip_edges()
	if clean_id.is_empty() or not SPEEDBIKE_STAGE_FILES.has(clean_id) or clean_id == stage_map_id:
		return false
	stage_map_id = clean_id
	chapter_start_stage_id = clean_id
	_build_stage_sequence()
	_sync_active_stage_state()
	if reload_stage:
		_load_stage_payload()
		_start_stage()
	return true


func _sync_observer_stage_from_state(state: Dictionary) -> void:
	if not _online_is_observer():
		return
	var stage_id := str(state.get("stage_id", "")).strip_edges()
	if stage_id.is_empty():
		var players: Variant = state.get("players", [])
		if players is Array:
			for row in players:
				if row is Dictionary:
					stage_id = str((row as Dictionary).get("stage_id", "")).strip_edges()
					if not stage_id.is_empty():
						break
	if _apply_online_stage_hint(stage_id, stage_started):
		_prepare_online_observer_mode()


func _prepare_online_observer_mode() -> void:
	if not stage_started:
		_start_stage()
	selection_open = false
	online_waiting_for_partner_start = false
	online_waiting_for_revive = false
	if character_select_shade != null:
		character_select_shade.visible = false
	if character_select_panel != null:
		character_select_panel.visible = false
	if online_death_mode_button != null:
		online_death_mode_button.visible = false
	player_speedbike.set_control_locked(true)
	player_speedbike.monitoring = false
	player_speedbike.monitorable = false
	for child in player_speedbike.get_children():
		if child is CollisionShape2D:
			child.disabled = true
	_show_warning("OBSERVER FEED - LIVE ROOM", 1.25)


func _tick_online_observer(delta: float) -> void:
	screen_size = get_viewport_rect().size
	_build_lane_positions()
	var state := _online_speedbike_state()
	_sync_observer_stage_from_state(state)
	var target_camera_x := speedbike_camera.position.x + maxf(camera_scroll_speed, stage_base_speed) * delta
	var max_remote_elapsed := stage_elapsed
	for row in state.get("players", []):
		if not (row is Dictionary):
			continue
		target_camera_x = maxf(target_camera_x, float(row.get("camera_x", target_camera_x)))
		max_remote_elapsed = maxf(max_remote_elapsed, float(row.get("stage_elapsed", max_remote_elapsed)))
	stage_elapsed = maxf(stage_elapsed + delta, max_remote_elapsed)
	chapter_elapsed_total += delta
	var camera_gap := target_camera_x - speedbike_camera.position.x
	if camera_gap > screen_size.x * 0.34:
		speedbike_camera.position.x = target_camera_x - screen_size.x * 0.06
	else:
		speedbike_camera.position.x = lerpf(speedbike_camera.position.x, target_camera_x, clampf(delta * ONLINE_SPECTATOR_CAMERA_LERP, 0.0, 1.0))
	speedbike_camera.position.y = screen_size.y * 0.5
	camera_scroll_speed = maxf((target_camera_x - speedbike_camera.position.x) / maxf(delta, 0.001), stage_base_speed)
	player_speedbike.configure_play_window(_camera_left(), speedbike_top_bound(), speedbike_bottom_bound())
	pattern_runner.tick(delta)
	_tick_obstacles(delta)
	_tick_drones(delta)
	_tick_projectiles(delta)
	_tick_fx(delta)
	_cleanup_runtime_objects()
	_apply_headlight_visibility_to_runtime()
	_apply_online_observer_state()
	_tick_flash_and_audio(delta)
	_update_hud()
	queue_redraw()


func _apply_online_observer_state() -> void:
	_ensure_remote_speedbike()
	_apply_observed_speedbike_to_controller(player_speedbike, _online_player_state(0), true)
	if remote_speedbike != null and is_instance_valid(remote_speedbike):
		_apply_observed_speedbike_to_controller(remote_speedbike, _online_player_state(1), false)


func _apply_observed_speedbike_to_controller(controller: SpeedbikeController, rider_state: Dictionary, primary: bool) -> void:
	if controller == null or not is_instance_valid(controller):
		return
	if rider_state.is_empty():
		controller.visible = false
		return
	controller.visible = bool(rider_state.get("ready", false)) or bool(rider_state.get("crashed", false)) or bool(rider_state.get("dead", false))
	controller.set_control_locked(true)
	controller.monitoring = false
	controller.monitorable = false
	if primary:
		_apply_observer_primary_rider_profile(str(rider_state.get("rider_id", "female")))
	else:
		_apply_remote_rider_profile(str(rider_state.get("rider_id", "scout")))
	var remote_x_offset := float(rider_state.get("x_offset", float(rider_state.get("x", _camera_left() + 280.0)) - float(rider_state.get("camera_x", _camera_left()))))
	var remote_y := float(rider_state.get("y", speedbike_lane_y(3 if primary else 2)))
	controller.global_position = Vector2(_camera_left() + remote_x_offset, remote_y)
	controller.jump_z = float(rider_state.get("jump_z", 0.0))
	var crashed := bool(rider_state.get("dead", false)) or bool(rider_state.get("crashed", false))
	controller.set_crashed(crashed)
	controller.tick(get_physics_process_delta_time(), _camera_left(), 0.0)


func _apply_observer_primary_rider_profile(rider_id: String) -> void:
	var clean_id := rider_id.strip_edges().to_lower()
	if clean_id.is_empty() or clean_id == observer_primary_rider_id:
		return
	if not RIDER_DEFS.has(clean_id):
		clean_id = "female"
	var rider_def: Dictionary = RIDER_DEFS.get(clean_id, RIDER_DEFS["female"])
	var hurtbox_mult := float(rider_def.get("hurtbox_mult", 1.0))
	player_speedbike.apply_rider_profile({
		"ride_texture": _load_texture(str(rider_def.get("ride_path", ""))),
		"jump_texture": _load_texture(str(rider_def.get("jump_path", ""))),
		"scale": float(rider_def.get("scale", 0.14)),
		"vertical_speed": 420.0 * float(rider_def.get("vertical_mult", 1.0)),
		"horizontal_speed": 340.0 * float(rider_def.get("horizontal_mult", 1.0)),
		"jump_duration": 0.62 * float(rider_def.get("jump_duration_mult", 1.0)),
		"jump_height": 72.0 + float(rider_def.get("jump_height_add", 0.0)),
		"jump_cooldown": 0.12 * float(rider_def.get("jump_cooldown_mult", 1.0)),
		"shot_cooldown": 0.12 * float(rider_def.get("shot_cooldown_mult", 1.0)),
		"hurtbox_size": Vector2(156.0, 54.0) * hurtbox_mult
	})
	observer_primary_rider_id = clean_id


func _tick_online_revive_spectator(delta: float) -> void:
	screen_size = get_viewport_rect().size
	_build_lane_positions()
	var remote_state := _online_remote_player_state()
	_keep_online_live_feed_visible(remote_state)
	var remote_elapsed := float(remote_state.get("stage_elapsed", stage_elapsed)) if not remote_state.is_empty() else stage_elapsed
	stage_elapsed = maxf(stage_elapsed, remote_elapsed)
	var previous_camera_x := speedbike_camera.position.x
	_sync_spectator_camera_to_remote(delta, remote_state)
	var observed_scroll := (speedbike_camera.position.x - previous_camera_x) / maxf(delta, 0.001)
	camera_scroll_speed = maxf(observed_scroll, _online_remote_scroll_hint(remote_state))
	player_speedbike.configure_play_window(_camera_left(), speedbike_top_bound(), speedbike_bottom_bound())
	_apply_online_speedbike_state()
	if not online_waiting_for_revive:
		_send_online_speedbike_input(true)
		_tick_flash_and_audio(delta)
		_keep_online_live_feed_visible(remote_state)
		_update_hud()
		queue_redraw()
		return
	remote_state = _online_remote_player_state()
	_keep_online_live_feed_visible(remote_state)
	remote_elapsed = float(remote_state.get("stage_elapsed", stage_elapsed)) if not remote_state.is_empty() else stage_elapsed
	stage_elapsed = maxf(stage_elapsed + delta, remote_elapsed)
	chapter_elapsed_total += delta
	invuln_timer = maxf(invuln_timer - delta, 0.0)
	slow_time_timer = maxf(slow_time_timer - delta, 0.0)
	current_hits_flash = maxf(current_hits_flash - delta, 0.0)
	pattern_runner.tick(delta)
	_tick_obstacles(delta)
	_tick_drones(delta)
	_tick_projectiles(delta)
	_tick_fx(delta)
	_tick_local_wreck_visual(delta)
	_tick_remote_speedbike(delta)
	speedbike_camera.offset = speedbike_camera.offset.lerp(Vector2.ZERO, clampf(delta * 4.0, 0.0, 1.0))
	_cleanup_runtime_objects()
	_apply_headlight_visibility_to_runtime()
	_tick_flash_and_audio(delta)
	_keep_online_live_feed_visible(remote_state)
	_send_online_speedbike_input(false)
	_update_hud()
	queue_redraw()


func _sync_spectator_camera_to_remote(delta: float, remote_state: Dictionary) -> void:
	var fallback_speed := _online_remote_scroll_hint(remote_state)
	var target_camera_x := speedbike_camera.position.x + fallback_speed * delta
	if not remote_state.is_empty():
		var remote_camera_x := float(remote_state.get("camera_x", target_camera_x))
		target_camera_x = maxf(target_camera_x, remote_camera_x)
	var camera_gap := target_camera_x - speedbike_camera.position.x
	if camera_gap > screen_size.x * 0.34:
		speedbike_camera.position.x = target_camera_x - screen_size.x * 0.06
	else:
		var blend := clampf(delta * ONLINE_SPECTATOR_CAMERA_LERP, 0.0, 1.0)
		speedbike_camera.position.x = lerpf(speedbike_camera.position.x, target_camera_x, blend)
	speedbike_camera.position.y = screen_size.y * 0.5


func _online_remote_scroll_hint(remote_state: Dictionary) -> float:
	var elapsed := stage_elapsed
	if not remote_state.is_empty():
		elapsed = maxf(elapsed, float(remote_state.get("stage_elapsed", elapsed)))
	var ramp_speed := stage_base_speed + stage_speed_ramp * elapsed + stage_speed_bonus
	return maxf(maxf(ramp_speed, camera_scroll_speed), stage_base_speed)


func _start_local_wreck_visual() -> void:
	online_local_wreck_offset = clampf(player_speedbike.global_position.x - _camera_left(), 84.0, maxf(screen_size.x - 110.0, 420.0))
	online_local_wreck_y = player_speedbike.global_position.y


func _tick_local_wreck_visual(delta: float) -> void:
	if player_speedbike == null:
		return
	if online_local_wreck_offset < -400.0:
		player_speedbike.visible = false
		return
	if online_local_wreck_offset < 0.0:
		_start_local_wreck_visual()
	player_speedbike.visible = true
	online_local_wreck_offset -= ONLINE_WRECK_DRIFT_SPEED * delta
	online_local_wreck_y = minf(online_local_wreck_y + ONLINE_WRECK_FALL_SPEED * delta, speedbike_bottom_bound() + 120.0)
	player_speedbike.global_position = Vector2(_camera_left() + online_local_wreck_offset, online_local_wreck_y)
	player_speedbike.set_crashed(true)
	player_speedbike.set_control_locked(true)
	player_speedbike.tick(delta, _camera_left(), 0.0)


func _reset_online_wreck_visuals() -> void:
	online_local_wreck_offset = -1.0
	online_local_wreck_y = 0.0
	online_remote_wreck_started_ms = 0
	online_remote_wreck_start_offset = -1.0
	online_remote_wreck_start_y = 0.0
	if player_speedbike != null:
		player_speedbike.visible = true


func _online_clear_death_visual_state() -> void:
	online_waiting_for_revive = false
	crash_restart_timer = -1.0
	flash_alpha = 0.0
	current_hits_flash = 0.0
	_reset_online_wreck_visuals()
	if flash_rect != null:
		flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	if player_speedbike != null:
		player_speedbike.visible = true
		player_speedbike.set_crashed(false)
		player_speedbike.set_control_locked(false)


func _keep_online_live_feed_visible(remote_state: Dictionary = {}) -> void:
	flash_alpha = 0.0
	current_hits_flash = 0.0
	if flash_rect != null:
		flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	if not online_waiting_for_revive:
		return
	var remote_visible := remote_speedbike != null and is_instance_valid(remote_speedbike) and remote_speedbike.visible
	var remote_alive := not bool(remote_state.get("dead", false)) and not bool(remote_state.get("crashed", false))
	if remote_state.is_empty() or not remote_visible or not remote_alive:
		blackout_strength = 0.0


func _toggle_pause() -> void:
	pause_open = not pause_open
	pause_panel.visible = pause_open
	_clear_speedbike_touch_states()
	get_tree().paused = false
	if pause_open:
		pause_current_tab = "main"
		pause_title.text = "ONLINE SPEEDBIKE MENU\n%s" % ("OBSERVER FEED" if _online_is_observer() else stage_name)
		pause_resume_button.text = "CLOSE MENU"
		player_speedbike.set_control_locked(_online_is_observer())
		_sync_speedbike_pause_controls()
		_apply_speedbike_mobile_layout()
		_focus_speedbike_pause_default_control()
	else:
		speedbike_touch_layout_edit_mode = false
		player_speedbike.set_control_locked(_online_is_observer())
		_sync_speedbike_touch_controls()


func _resume_from_pause() -> void:
	get_tree().paused = false
	pause_open = false
	pause_panel.visible = false
	speedbike_touch_layout_edit_mode = false
	_clear_speedbike_touch_states()
	if player_speedbike != null:
		player_speedbike.set_control_locked(_online_is_observer())
	_sync_speedbike_touch_controls()


func _leave_online_match() -> void:
	get_tree().paused = false
	online_waiting_for_partner_start = false
	online_waiting_for_revive = false
	NetworkClient.disconnect_match()
	_return_to_war_room()


func _headlight_beam_geometry() -> Dictionary:
	var headlight_rider := _online_spectator_headlight_rider()
	if headlight_rider == null:
		return super._headlight_beam_geometry()
	var beam_origin: Vector2 = headlight_rider.bike_midpoint() + Vector2(72.0, -8.0)
	var near_half := 62.0
	var far_x := minf(_camera_right() + 64.0, beam_origin.x + 448.0)
	var far_half := 156.0
	return {
		"origin": beam_origin,
		"near_half": near_half,
		"far_x": far_x,
		"far_half": far_half
	}


func _online_spectator_headlight_rider() -> SpeedbikeController:
	if online_waiting_for_revive and remote_speedbike != null and is_instance_valid(remote_speedbike) and remote_speedbike.visible and not remote_last_crashed:
		return remote_speedbike
	return player_speedbike


func _ensure_remote_speedbike() -> void:
	if remote_speedbike != null and is_instance_valid(remote_speedbike):
		return
	if player_speedbike == null:
		return
	remote_speedbike = player_speedbike.duplicate() as SpeedbikeController
	if remote_speedbike == null:
		return
	remote_speedbike.name = "RemoteSpeedbike"
	player_speedbike.get_parent().add_child(remote_speedbike)
	remote_speedbike.modulate = Color(0.52, 0.82, 1.0, 0.92)
	remote_speedbike.z_as_relative = false
	remote_speedbike.z_index = max(player_speedbike.z_index + 8, 48)
	remote_speedbike.monitoring = false
	remote_speedbike.monitorable = false
	remote_speedbike.visible = false
	for child in remote_speedbike.get_children():
		if child is CollisionShape2D:
			child.disabled = true
	remote_speedbike.set_control_locked(true)


func _apply_remote_rider_profile(rider_id: String) -> void:
	if remote_speedbike == null or not is_instance_valid(remote_speedbike):
		return
	var clean_id := rider_id.strip_edges().to_lower()
	if clean_id.is_empty() or clean_id == remote_rider_id:
		return
	if not RIDER_DEFS.has(clean_id):
		clean_id = "female"
	var rider_def: Dictionary = RIDER_DEFS.get(clean_id, RIDER_DEFS["female"])
	var hurtbox_mult := float(rider_def.get("hurtbox_mult", 1.0))
	remote_speedbike.apply_rider_profile({
		"ride_texture": _load_texture(str(rider_def.get("ride_path", ""))),
		"jump_texture": _load_texture(str(rider_def.get("jump_path", ""))),
		"scale": float(rider_def.get("scale", 0.14)),
		"vertical_speed": 420.0 * float(rider_def.get("vertical_mult", 1.0)),
		"horizontal_speed": 340.0 * float(rider_def.get("horizontal_mult", 1.0)),
		"jump_duration": 0.62 * float(rider_def.get("jump_duration_mult", 1.0)),
		"jump_height": 72.0 + float(rider_def.get("jump_height_add", 0.0)),
		"jump_cooldown": 0.12 * float(rider_def.get("jump_cooldown_mult", 1.0)),
		"shot_cooldown": 0.12 * float(rider_def.get("shot_cooldown_mult", 1.0)),
		"hurtbox_size": Vector2(156.0, 54.0) * hurtbox_mult
	})
	remote_rider_id = clean_id


func _send_online_speedbike_input(force := false) -> void:
	if _online_is_observer():
		return
	if not NetworkClient.match_is_connected():
		return
	online_send_timer -= get_physics_process_delta_time()
	if not force and online_send_timer > 0.0:
		return
	online_send_timer = ONLINE_SEND_INTERVAL
	var input_state := _current_online_input_state()
	input_state["rider_id"] = selected_rider_id
	input_state["ready"] = not selection_open
	input_state["death_mode"] = online_death_mode
	input_state["x"] = player_speedbike.global_position.x
	input_state["x_offset"] = player_speedbike.global_position.x - _camera_left()
	input_state["camera_x"] = speedbike_camera.global_position.x
	input_state["y"] = player_speedbike.global_position.y
	input_state["jump_z"] = player_speedbike.jump_z
	input_state["airborne"] = player_speedbike.is_airborne()
	input_state["crashed"] = player_speedbike.crashed or online_waiting_for_revive
	input_state["stage_id"] = stage_map_id
	input_state["stage_elapsed"] = stage_elapsed
	NetworkClient.send_speedbike_input(input_state)


func _current_online_input_state() -> Dictionary:
	var touch_attack := bool(speedbike_touch_states.get("fire", false))
	if speedbike_touch_autofire_enabled and (bool(speedbike_touch_states.get("left", false)) or bool(speedbike_touch_states.get("right", false))):
		touch_attack = true
	return {
		"up": Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W) or bool(speedbike_touch_states.get("up", false)),
		"down": Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S) or bool(speedbike_touch_states.get("down", false)),
		"left": Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A) or bool(speedbike_touch_states.get("left", false)),
		"right": Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D) or bool(speedbike_touch_states.get("right", false)),
		"jump": Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A) or bool(speedbike_touch_states.get("jump", false)),
		"attack": Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_X) or touch_attack,
		"boost": Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL) or Input.is_joy_button_pressed(0, JOY_BUTTON_RIGHT_SHOULDER) or bool(speedbike_touch_states.get("boost", false))
	}


func _emit_online_crash() -> void:
	if online_suppress_crash_event:
		return
	NetworkClient.send_speedbike_crash({
		"stage_id": stage_map_id,
		"checkpoint": checkpoint_count,
		"stage_elapsed": stage_elapsed
	})


func _on_match_state_changed() -> void:
	if _online_is_observer():
		_apply_online_observer_state()
	else:
		_apply_online_speedbike_state()


func _apply_online_speedbike_state() -> void:
	var state := _online_speedbike_state()
	if state.is_empty():
		return
	if online_waiting_for_partner_start and _online_both_riders_ready(state):
		online_waiting_for_partner_start = false
		player_speedbike.set_control_locked(false)
		_show_warning("BOTH RIDERS READY - GO", 0.9)
	var next_death_mode := str(state.get("death_mode", online_death_mode)).strip_edges().to_lower()
	if ["revive_after_two_checkpoints", "shared_crash"].has(next_death_mode):
		online_death_mode = next_death_mode
		_sync_online_death_mode_button()

	var team_restart_serial := int(state.get("team_restart_serial", 0))
	if online_last_team_restart_serial < 0:
		online_last_team_restart_serial = team_restart_serial
	elif team_restart_serial != online_last_team_restart_serial:
		online_last_team_restart_serial = team_restart_serial
		online_suppress_crash_event = true
		online_waiting_for_partner_start = false
		online_waiting_for_revive = false
		if online_death_mode == "shared_crash" and not player_speedbike.crashed:
			_trigger_crash(player_speedbike.bike_midpoint())
		_restart_from_checkpoint()
		_online_clear_death_visual_state()
		_show_warning("TEAM WIPE - RESETTING BOTH RIDERS", 1.0)
		online_suppress_crash_event = false

	var local_state := _online_player_state(_online_local_seat())
	if not local_state.is_empty():
		var revive_serial := int(local_state.get("revive_serial", 0))
		if online_last_local_revive_serial < 0:
			online_last_local_revive_serial = revive_serial
		elif revive_serial != online_last_local_revive_serial:
			online_last_local_revive_serial = revive_serial
			if online_waiting_for_revive or player_speedbike.crashed:
				_restart_from_checkpoint()
				_online_clear_death_visual_state()
				_show_warning("PARTNER CLEARED THE REVIVE WINDOW", 1.0)

	var remote_state := _online_remote_player_state()
	if remote_state.is_empty():
		if remote_speedbike != null:
			remote_speedbike.visible = false
		return
	_ensure_remote_speedbike()
	if remote_speedbike == null or not is_instance_valid(remote_speedbike):
		return
	var remote_ready := bool(remote_state.get("ready", false))
	remote_speedbike.visible = remote_ready or bool(state.get("started", false)) or bool(remote_state.get("dead", false)) or bool(remote_state.get("crashed", false))
	_apply_remote_rider_profile(str(remote_state.get("rider_id", "female")))
	var remote_crashed := bool(remote_state.get("dead", false)) or bool(remote_state.get("crashed", false))
	if remote_crashed != remote_last_crashed:
		remote_speedbike.set_crashed(remote_crashed)
		remote_last_crashed = remote_crashed
	remote_speedbike.set_control_locked(true)
	var remote_update_stamp := int(remote_state.get("last_update", 0))
	if remote_target_valid and remote_update_stamp > 0 and remote_update_stamp <= remote_last_update_stamp:
		return
	remote_last_update_stamp = remote_update_stamp
	var now_ms := Time.get_ticks_msec()
	var remote_x_offset := float(remote_state.get("x_offset", float(remote_state.get("x", _camera_left() + 280.0)) - float(remote_state.get("camera_x", _camera_left()))))
	var remote_y := float(remote_state.get("y", speedbike_lane_y(3)))
	if remote_crashed:
		if online_remote_wreck_started_ms <= 0:
			online_remote_wreck_started_ms = now_ms
			online_remote_wreck_start_offset = clampf(remote_x_offset, 84.0, maxf(screen_size.x - 110.0, 420.0))
			online_remote_wreck_start_y = remote_y
		var wreck_age := maxf(float(now_ms - online_remote_wreck_started_ms) / 1000.0, 0.0)
		remote_x_offset = online_remote_wreck_start_offset - ONLINE_WRECK_DRIFT_SPEED * wreck_age
		remote_y = minf(online_remote_wreck_start_y + ONLINE_WRECK_FALL_SPEED * wreck_age, speedbike_bottom_bound() + 120.0)
		remote_x_offset = clampf(remote_x_offset, -420.0, maxf(screen_size.x - 90.0, 460.0))
	else:
		online_remote_wreck_started_ms = 0
		online_remote_wreck_start_offset = -1.0
		online_remote_wreck_start_y = 0.0
		remote_x_offset = clampf(remote_x_offset, 90.0, maxf(screen_size.x - 120.0, 420.0))
	var next_target := Vector2(_camera_left() + remote_x_offset, remote_y)
	if remote_target_valid:
		var elapsed := maxf(float(now_ms - remote_target_received_ms) / 1000.0, 0.001)
		remote_target_velocity = (next_target - remote_target_position) / elapsed
		if remote_target_velocity.length() > 1600.0:
			remote_target_velocity = remote_target_velocity.normalized() * 1600.0
	else:
		remote_speedbike.global_position = next_target
		remote_target_velocity = Vector2.ZERO
	remote_target_position = next_target
	remote_target_jump_z = float(remote_state.get("jump_z", 0.0))
	remote_target_received_ms = now_ms
	remote_target_valid = true


func _tick_remote_speedbike(delta: float) -> void:
	if remote_speedbike == null or not is_instance_valid(remote_speedbike) or not remote_target_valid:
		return
	if not remote_speedbike.visible:
		return
	var packet_age := clampf(float(Time.get_ticks_msec() - remote_target_received_ms) / 1000.0, 0.0, REMOTE_PREDICTION_MAX)
	var predicted_position := remote_target_position + remote_target_velocity * packet_age
	var blend := clampf(delta * REMOTE_INTERP_SPEED, 0.0, 1.0)
	remote_speedbike.global_position = remote_speedbike.global_position.lerp(predicted_position, blend)
	remote_speedbike.jump_z = lerpf(remote_speedbike.jump_z, remote_target_jump_z, clampf(delta * REMOTE_JUMP_INTERP_SPEED, 0.0, 1.0))
	remote_speedbike.set_control_locked(true)
	remote_speedbike.tick(delta, _camera_left(), 0.0)


func _online_speedbike_state() -> Dictionary:
	return NetworkClient.match_state.get("speedbike_state", {}) as Dictionary


func _online_player_state(seat: int) -> Dictionary:
	var state := _online_speedbike_state()
	if state.is_empty():
		return {}
	for row in state.get("players", []):
		if row is Dictionary and int(row.get("seat", -1)) == seat:
			return row
	return {}


func _online_remote_player_state() -> Dictionary:
	var state := _online_speedbike_state()
	if state.is_empty():
		return {}
	var local_seat := _online_local_seat()
	var expected_remote_seat := 1 if local_seat == 0 else 0
	for row in state.get("players", []):
		if row is Dictionary and int(row.get("seat", -1)) == expected_remote_seat:
			return row
	for row in state.get("players", []):
		if row is Dictionary and int(row.get("seat", -1)) != local_seat:
			return row
	return {}


func _online_both_riders_ready(state: Dictionary) -> bool:
	if state.is_empty():
		return false
	var ready_count := 0
	for row in state.get("players", []):
		if row is Dictionary and bool(row.get("ready", false)):
			ready_count += 1
	return ready_count >= 2


func _remote_seat() -> int:
	var local_seat := _online_local_seat()
	return 1 if local_seat == 0 else 0


func _online_local_seat() -> int:
	if NetworkClient.your_seat >= 0:
		return NetworkClient.your_seat
	return int(NetworkClient.match_state.get("your_seat", -1))
