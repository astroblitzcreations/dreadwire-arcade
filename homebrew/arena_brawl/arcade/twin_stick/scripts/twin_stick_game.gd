extends Node2D
## Self-contained playable reference demo, separate from your main game's files.
## Portrait 768x1024 cabinet design. Body direction and weapon angle are independent.
## Manual collision simulation continues when embedded in a paused SceneTree.
signal close_requested
const BASE = "res://arcade/twin_stick/"
const ART = BASE + "assets/"
const LIBRARY = preload("res://arcade/twin_stick/scripts/asset_library.gd")
const AUDIO = preload("res://arcade/twin_stick/scripts/audio_director.gd")
const INPUT_SETUP = preload("res://arcade/twin_stick/scripts/input_setup.gd")
const DIRS = ["s", "sw", "w", "nw", "n", "ne", "e", "se"]
const ROOM = Rect2(55, 175, 658, 770)
var library = LIBRARY.new()
var audio
var players: Array = []
var enemies: Array = []
var shots: Array = []
var drops: Array = []
var effects: Array = []
var hazards: Array = []
var player_bombs: Array = []
var popups: Array = []
var enemy_defs: Dictionary = {}
var boss_defs: Dictionary = {}
var weapons: Dictionary = {}
var weapon_ids: Array = []
var waves: Array = []
var pickup_ids: Array = []
var game_time: float = 0.0
var wave_index: int = 0
var phase: String = "warning"
var phase_timer: float = 1.5
var demo_paused: bool = false
var game_over: bool = false
var victory: bool = false
var god_mode: bool = false
var debug_info: bool = false
var show_help: bool = false
var p2_enabled: bool = true
var score_multiplier: int = 1
var font: Font
var crt_layer: CanvasLayer
var crt_rect: ColorRect
var texture_seed: int = 0
var shake: float = 0.0
var next_enemy_uid: int = 1
var exit_armed_until: float = 0.0
const PAUSE_ITEMS = ["RESUME GAME", "RESTART GAME", "MAIN MENU / PLAYER SELECT", "RECONFIGURE PLAYER 1", "RECONFIGURE PLAYER 2", "PLAYER 1 CONTROLLER", "PLAYER 2 CONTROLLER", "MUSIC", "SOUND EFFECTS", "VOICE", "CONTROLLER HELP", "EXIT TO ARCADE"]
const CONTROL_ACTIONS = ["MOVE UP", "MOVE DOWN", "MOVE LEFT", "MOVE RIGHT", "FIRE", "SECONDARY / BOMB", "FIRE UP", "FIRE DOWN", "FIRE LEFT", "FIRE RIGHT", "LOCK AIM", "PAUSE", "SELECT", "START"]
var pause_selection := 0
var control_wizard_open := false
var control_wizard_step := 0
var control_wizard_device := -1
var control_wizard_name := ""
var control_wizard_player := 0
var control_wizard_hold_button := -1
var control_wizard_hold_time := 0.0
var controller_mappings: Dictionary = {}
var player_controllers: Array[String] = ["", ""]
var mobile_pad_labels: Dictionary = {}
var joy_axis_latched: Dictionary = {}
var music_enabled := true
var sfx_enabled := true
var voice_enabled := true
var music_volume := 80
var sfx_volume := 85
var voice_volume := 90
var controller_help_timer := 0.0
var difficulty := "normal"
var attract_mode := false
var enemy_health_scale := 1.0
var enemy_speed_scale := 0.88
var enemy_fire_scale := 1.18
var enemy_damage_scale := 0.85
var enemy_count_scale := 0.9
var entrance_elapsed := 0.0
var entrance_started_msec := 0
var entrance_go_played := false
var entrance_banner_played := false
var entrance_banner := ""
var entrance_cheer_played := false
var entrance_money_step := 0
var intro_animation: TextureRect
var intro_frame := -1
var intro_love_label: Label
var route_history: Array[String] = []
var floor_in_room := 1
var floor_transition := 0.0
var floor_order: Array[Vector2i] = []
var floor_rank: Dictionary = {}
var pending_route := ""
var map_position := Vector2i.ZERO
var map_path: Array[Vector2i] = []
var map_visited: Dictionary = {}
var map_hidden_found: Dictionary = {}
var corridor_direction := 1
var corridor_progress := 0.0
var corridor_spawn_mark := 0
var wave_spawned := false
var wave_reinforcements_spawned := false
var combat_elapsed := 0.0
var enemy_clear_stable_time := 0.0
var door_open_timer := 0.0
var erosion_cells: Dictionary = {}
var erosion_order: Array[Vector2i] = []
var erosion_timer := 0.0
var erosion_index := 0
var erosion_active := false
var floor_tile_states: Dictionary = {}
var floor_tile_changed_at: Dictionary = {}
var floor_trail_bombs: Array = []
var player_clones: Array = []
var cinematic_finisher: Dictionary = {}
var enemy_finisher_cooldown := 0.0
const CINEMATIC_FINISHERS = ["LADDER PLANK", "TRASH COMPACTOR", "ROCKET CHAIR", "NEON TRAIN"]
const FLOORS_PER_ROOM := 10
const CORRIDOR_LENGTH := 1350.0
const PRIZE_ORDER := ["toaster", "vcr", "microwave", "camcorder", "luxury_car", "vacation", "silver_bar", "gold_bar", "cash_pile", "key"]
const PRIZE_VALUES := {
    "toaster": {"label": "TOASTERS", "cash": 100, "score": 1000},
    "vcr": {"label": "VCRS", "cash": 500, "score": 2000},
    "microwave": {"label": "MICROWAVES", "cash": 800, "score": 3000},
    "camcorder": {"label": "CAMCORDERS", "cash": 1500, "score": 5000},
    "luxury_car": {"label": "LUXURY CARS", "cash": 15000, "score": 20000},
    "vacation": {"label": "VACATIONS", "cash": 10000, "score": 15000},
    "silver_bar": {"label": "SILVER BARS", "cash": 1000, "score": 5000},
    "gold_bar": {"label": "GOLD BARS", "cash": 5000, "score": 10000},
    "cash_pile": {"label": "CASH PILES", "cash": 500, "score": 500},
    "key": {"label": "SECRET KEYS", "cash": 0, "score": 0},
}
const STAGE_WINNER_BONUS := 100000
const RECOVERY_PATH := "user://arena_brawl_recovery.cfg"
const RECOVERY_TEMP_PATH := "user://arena_brawl_recovery.cfg.tmp"
const RECOVERY_VERSION := 1
var recovery_save_timer := 0.0
var recovery_restored := false
var prize_spawn_timer := 12.0
var tally_time := 0.0
var high_score_music_started := false
const NAME_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
var name_entry_chars: Array[int] = [0, 0, 0]
var name_entry_cursor := 0
var high_score_saved := false
var high_score_rank := -1
var name_axis_latched: Dictionary = {}
var boss_tally_row := 0
var boss_tally_counts: Array = [{}, {}]
var boss_tally_cash: Array[int] = [0, 0]
var boss_tally_tick := 0.0
var boss_tally_pause := 0.0
var boss_tally_finish := 0.0
var boss_tally_winner := -2
var boss_tally_bonus_awarded := false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    INPUT_SETUP.install()
    randomize()
    font = ThemeDB.fallback_font
    for definition in library.data("enemies"):
        enemy_defs[definition["id"]] = definition
    for definition in library.data("bosses"):
        boss_defs[definition["id"]] = definition
    for definition in library.data("weapons"):
        weapons[definition["id"]] = definition
        weapon_ids.append(definition["id"])
    for definition in library.data("prizes"):
        if definition["id"] != "bomb":
            pickup_ids.append(definition["id"])
    waves = _build_campaign_waves(library.data("waves"))
    audio = AUDIO.new()
    add_child(audio)
    _setup_intro_video()
    _load_difficulty()
    _load_controller_mappings()
    _refresh_player_controllers()
    _make_crt()
    restart()

func _build_campaign_waves(source: Array) -> Array:
    var campaign: Array = []
    for stage in range(4):
        var base = stage * 5
        var recipes: Array = source.slice(base, base + 4)
        for floor_number in range(10):
            var wave: Dictionary = recipes[floor_number % recipes.size()].duplicate(true)
            wave["wave"] = campaign.size() + 1
            wave["count"] = int(wave["count"]) + floor_number * 2
            wave["hazard_count"] = mini(4, int(wave["hazard_count"]) + int(floor_number / 3))
            wave["boss"] = ""
            campaign.append(wave)
        var boss_wave: Dictionary = source[base + 4].duplicate(true)
        boss_wave["wave"] = campaign.size() + 1
        campaign.append(boss_wave)
    return campaign

func restart(load_recovery: bool = true) -> void:
    enemies.clear()
    shots.clear()
    drops.clear()
    effects.clear()
    hazards.clear()
    player_bombs.clear()
    popups.clear()
    players = [_new_player(0, Vector2(280, 545)), _new_player(1, Vector2(488, 545))]
    wave_index = 0
    game_time = 0.0
    phase = "entrance"
    phase_timer = 13.4
    entrance_elapsed = 0.0
    entrance_started_msec = Time.get_ticks_msec()
    entrance_go_played = false
    entrance_banner_played = false
    entrance_banner = ""
    entrance_cheer_played = false
    entrance_money_step = 0
    if is_instance_valid(intro_animation):
        intro_animation.visible = false
        intro_animation.texture = null
        intro_frame = -1
    if is_instance_valid(intro_love_label):
        intro_love_label.visible = false
    route_history.clear()
    floor_in_room = 1
    floor_transition = 0.0
    floor_order.clear()
    floor_rank.clear()
    pending_route = ""
    map_position = Vector2i.ZERO
    map_path = [Vector2i.ZERO]
    map_visited = {"0,0": true}
    map_hidden_found.clear()
    corridor_progress = 0.0
    corridor_spawn_mark = 0
    wave_spawned = false
    wave_reinforcements_spawned = false
    combat_elapsed = 0.0
    enemy_clear_stable_time = 0.0
    erosion_cells.clear()
    erosion_order.clear()
    erosion_timer = 0.0
    erosion_index = 0
    erosion_active = false
    floor_tile_states.clear()
    floor_tile_changed_at.clear()
    floor_trail_bombs.clear()
    player_clones.clear()
    cinematic_finisher.clear()
    enemy_finisher_cooldown = 0.0
    prize_spawn_timer = randf_range(10.0, 16.0)
    tally_time = 0.0
    high_score_music_started = false
    name_entry_chars = [0, 0, 0]
    name_entry_cursor = 0
    high_score_saved = false
    high_score_rank = -1
    name_axis_latched.clear()
    game_over = false
    victory = false
    demo_paused = false
    recovery_save_timer = 0.0
    recovery_restored = false
    if audio != null:
        audio.stop_all()
        audio.play_music("circuit_1")
        audio.announce_sequence(["voice_contestant_1.wav", "voice_contestant_2.wav"] if p2_enabled else ["voice_contestant_1.wav"])
    if load_recovery:
        _restore_recovery_checkpoint()

func _save_recovery_checkpoint() -> void:
    if attract_mode or game_over or victory or wave_index < 0 or wave_index >= waves.size():
        return
    if phase not in ["warning", "combat", "clear_hold", "intermission", "route", "turn", "corridor"]:
        return
    var config = ConfigFile.new()
    config.set_value("recovery", "version", RECOVERY_VERSION)
    config.set_value("recovery", "saved_unix", int(Time.get_unix_time_from_system()))
    config.set_value("campaign", "wave_index", wave_index)
    config.set_value("campaign", "floor_in_room", floor_in_room)
    config.set_value("campaign", "game_time", game_time)
    config.set_value("campaign", "route_history", route_history)
    config.set_value("campaign", "map_position", map_position)
    config.set_value("campaign", "map_path", map_path)
    config.set_value("campaign", "map_visited", map_visited)
    config.set_value("campaign", "map_hidden_found", map_hidden_found)
    for i in range(players.size()):
        var p: Dictionary = players[i]
        var section = "player_%d" % i
        for key in ["health", "armor", "lives", "score", "cash", "gold", "weapon", "bombs", "drone_level", "lightning_level", "continues", "kills", "boss_kills", "deaths", "pickups", "continues_used"]:
            config.set_value(section, key, p[key])
        config.set_value(section, "stage_loot", p["stage_loot"])
        config.set_value(section, "loot_totals", p["loot_totals"])
        config.set_value(section, "keys", p["keys"])
        config.set_value(section, "stage_wins", p["stage_wins"])
    if config.save(RECOVERY_TEMP_PATH) != OK:
        return
    var target = ProjectSettings.globalize_path(RECOVERY_PATH)
    var temporary = ProjectSettings.globalize_path(RECOVERY_TEMP_PATH)
    if FileAccess.file_exists(target):
        DirAccess.remove_absolute(target)
    DirAccess.rename_absolute(temporary, target)

func _restore_recovery_checkpoint() -> void:
    var config = ConfigFile.new()
    if config.load(RECOVERY_PATH) != OK or int(config.get_value("recovery", "version", 0)) != RECOVERY_VERSION:
        return
    wave_index = clampi(int(config.get_value("campaign", "wave_index", 0)), 0, waves.size() - 1)
    floor_in_room = clampi(int(config.get_value("campaign", "floor_in_room", 1)), 1, FLOORS_PER_ROOM)
    game_time = maxf(0.0, float(config.get_value("campaign", "game_time", 0.0)))
    route_history = config.get_value("campaign", "route_history", [])
    map_position = config.get_value("campaign", "map_position", Vector2i.ZERO)
    map_path = config.get_value("campaign", "map_path", [map_position])
    map_visited = config.get_value("campaign", "map_visited", {"%d,%d" % [map_position.x, map_position.y]: true})
    map_hidden_found = config.get_value("campaign", "map_hidden_found", {})
    for i in range(players.size()):
        var section = "player_%d" % i
        var p: Dictionary = players[i]
        p["health"] = clampf(float(config.get_value(section, "health", 100.0)), 1.0, 100.0)
        p["armor"] = maxf(0.0, float(config.get_value(section, "armor", 0.0)))
        p["lives"] = maxi(1, int(config.get_value(section, "lives", 3)))
        p["score"] = maxi(0, int(config.get_value(section, "score", 0)))
        p["cash"] = maxi(0, int(config.get_value(section, "cash", 0)))
        p["gold"] = maxi(0, int(config.get_value(section, "gold", 0)))
        var saved_weapon = String(config.get_value(section, "weapon", "pulse_pistol"))
        p["weapon"] = saved_weapon if weapons.has(saved_weapon) else "pulse_pistol"
        p["bombs"] = maxi(0, int(config.get_value(section, "bombs", 0)))
        p["drone_level"] = maxi(0, int(config.get_value(section, "drone_level", 0)))
        p["lightning_level"] = maxi(0, int(config.get_value(section, "lightning_level", 0)))
        p["continues"] = clampi(int(config.get_value(section, "continues", 3)), 0, 3)
        for stat in ["kills", "boss_kills", "deaths", "pickups", "continues_used"]:
            p[stat] = maxi(0, int(config.get_value(section, stat, 0)))
        var saved_loot: Dictionary = config.get_value(section, "stage_loot", {})
        var saved_loot_totals: Dictionary = config.get_value(section, "loot_totals", {})
        p["stage_loot"] = _empty_stage_loot()
        p["loot_totals"] = _empty_stage_loot()
        for prize_id in PRIZE_ORDER:
            p["stage_loot"][prize_id] = maxi(0, int(saved_loot.get(prize_id, 0)))
            p["loot_totals"][prize_id] = maxi(0, int(saved_loot_totals.get(prize_id, p["stage_loot"][prize_id])))
        p["keys"] = maxi(0, int(config.get_value(section, "keys", 0)))
        p["stage_wins"] = maxi(0, int(config.get_value(section, "stage_wins", 0)))
        p["invuln"] = 3.0
    phase = "warning"
    phase_timer = 3.0
    entrance_elapsed = 99.0
    recovery_restored = true
    if audio != null:
        audio.stop_all()
        audio.play_music("inner_sanctum" if not str(waves[wave_index]["boss"]).is_empty() else "circuit_3" if wave_index >= 14 else "circuit_2" if wave_index >= 7 else "circuit_1")
    _popup("RECOVERY LOADED — FLOOR %d/%d" % [floor_in_room, FLOORS_PER_ROOM], Vector2(384, 430), Color(.3, 1, .72))

func _clear_recovery_checkpoint() -> void:
    for path in [RECOVERY_PATH, RECOVERY_TEMP_PATH]:
        var absolute = ProjectSettings.globalize_path(path)
        if FileAccess.file_exists(absolute):
            DirAccess.remove_absolute(absolute)

func _setup_intro_video() -> void:
    # Godot's Theora decoder corrupts this particular animation on the Pi's
    # GLES stack. A short numbered-image sequence is deterministic and keeps
    # every frame pristine on both the cabinet and remote stream.
    intro_animation = TextureRect.new()
    intro_animation.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    intro_animation.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    intro_animation.size = Vector2(576, 736)
    intro_animation.position = Vector2(-620, 152)
    intro_animation.visible = false
    intro_animation.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(intro_animation)
    intro_love_label = Label.new()
    intro_love_label.text = "I LOVE IT!"
    intro_love_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    intro_love_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    intro_love_label.add_theme_font_size_override("font_size", 48)
    intro_love_label.add_theme_color_override("font_color", Color(1, .92, .2))
    intro_love_label.add_theme_color_override("font_outline_color", Color(1, .05, .5))
    intro_love_label.add_theme_constant_override("outline_size", 10)
    intro_love_label.size = Vector2(576, 92)
    intro_love_label.position = Vector2(-620, 770)
    intro_love_label.visible = false
    intro_love_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(intro_love_label)

func _new_player(index: int, point: Vector2) -> Dictionary:
    return {"id": index, "name": "volt" if index == 0 else "nova", "pos": point,
        "health": 100.0, "armor": 0.0, "lives": 3, "score": 0, "cash": 0, "gold": 0,
        "kills": 0, "boss_kills": 0, "deaths": 0, "pickups": 0, "continues_used": 0,
        "stage_loot": _empty_stage_loot(), "loot_totals": _empty_stage_loot(),
        "keys": 0, "stage_wins": 0,
        "weapon": "pulse_pistol", "fire_timer": 0.0, "aim": Vector2.UP,
        "move": Vector2.ZERO, "dir": "s", "invuln": 2.5,
        "respawn": 0.0, "damage_flash": 0.0, "buffs": {}, "anim_time": 0.0,
        "fire_held": false, "lock_held": false, "locked_aim": Vector2.UP,
        "secondary_held": false, "bombs": 0, "drone_level": 0,
        "shield_share_cooldown": 0.0, "death_move": "", "death_progress": 0.0,
        "death_direction": 1.0,
        "floor_cell": Vector2i(-99, -99), "floor_trail": [], "trail_cooldown": 0.0,
        "trail_last_step": 0.0, "lightning_level": 0,
        "floor_falling": false,
        "continue_timer": 0.0, "continues": 3}

func _empty_stage_loot() -> Dictionary:
    var result := {}
    for prize_id in PRIZE_ORDER:
        result[prize_id] = 0
    return result

func _input(event: InputEvent) -> void:
    if control_wizard_open:
        if _capture_control_event(event):
            get_viewport().set_input_as_handled()
        return
    if (victory and tally_time >= 7.0) or (game_over and tally_time >= 3.0):
        if _handle_name_entry(event):
            get_viewport().set_input_as_handled()
        return
    if attract_mode and (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton):
        var config = ConfigFile.new()
        config.set_value("game", "difficulty", difficulty)
        config.set_value("game", "two_players", p2_enabled)
        config.set_value("game", "attract_mode", false)
        config.save("user://arena_brawl_game.cfg")
        get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
        return
    if event is InputEventKey and event.pressed and not event.echo:
        if demo_paused:
            match event.physical_keycode:
                KEY_UP, KEY_W: _move_pause_selection(-1)
                KEY_DOWN, KEY_S: _move_pause_selection(1)
                KEY_LEFT, KEY_A: _adjust_pause_setting(-10)
                KEY_RIGHT, KEY_D: _adjust_pause_setting(10)
                KEY_ENTER, KEY_KP_ENTER, KEY_SPACE: _activate_pause_item()
                KEY_ESCAPE, KEY_P: _set_pause(false)
            get_viewport().set_input_as_handled()
            return
        match event.physical_keycode:
            KEY_ESCAPE:
                close_requested.emit()
                if close_requested.get_connections().is_empty():
                    get_tree().quit()
            KEY_P:
                _set_pause(not demo_paused)
            KEY_R:
                _clear_recovery_checkpoint()
                restart(false)
            KEY_TAB:
                p2_enabled = not p2_enabled
            KEY_M:
                audio.toggle_music()
            KEY_C:
                crt_layer.visible = not crt_layer.visible
            KEY_F1:
                show_help = not show_help
            KEY_F2:
                if OS.is_debug_build():
                    debug_info = not debug_info
            KEY_F3:
                if OS.is_debug_build():
                    god_mode = not god_mode
            KEY_F4:
                if OS.is_debug_build():
                    enemies.clear()
                    phase = "clear"
                    phase_timer = 0.2
            KEY_F5:
                if OS.is_debug_build():
                    _spawn_enemy("grunt", Vector2(640, 220), false)
            KEY_F6:
                if OS.is_debug_build():
                    _spawn_enemy("enforcer", Vector2(640, 270), true)
            KEY_F7:
                if OS.is_debug_build():
                    players[0]["health"] = 100.0
                    _cycle_weapon(players[0])
        get_viewport().set_input_as_handled()
    elif event is InputEventJoypadMotion:
        _handle_menu_axis(event)
    elif event is InputEventJoypadButton and event.pressed:
        var mapped = _mapped_button_action(Input.get_joy_name(event.device).to_lower(), event.button_index)
        if demo_paused:
            if mapped == "MOVE UP":
                _move_pause_selection(-1)
            elif mapped == "MOVE DOWN":
                _move_pause_selection(1)
            elif mapped == "MOVE LEFT":
                _adjust_pause_setting(-10)
            elif mapped == "MOVE RIGHT":
                _adjust_pause_setting(10)
            elif mapped in ["FIRE", "START"] or event.button_index in [JOY_BUTTON_A, JOY_BUTTON_X, JOY_BUTTON_START]:
                _activate_pause_item()
            elif event.button_index == JOY_BUTTON_B:
                _set_pause(false)
            get_viewport().set_input_as_handled()
            return
        if game_over and (mapped == "START" or event.button_index == JOY_BUTTON_START):
            get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
            get_viewport().set_input_as_handled()
            return
        if mapped in ["PAUSE", "START"] or event.button_index == JOY_BUTTON_START:
            if Input.is_joy_button_pressed(event.device, JOY_BUTTON_BACK):
                _request_exit()
                get_viewport().set_input_as_handled()
                return
            _set_pause(true)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _cycle_weapon(players[0])
            get_viewport().set_input_as_handled()

func _handle_name_entry(event: InputEvent) -> bool:
    if high_score_saved:
        if event is InputEventKey and event.pressed or event is InputEventJoypadButton and event.pressed:
            get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
            return true
        return false
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_LEFT: name_entry_cursor = wrapi(name_entry_cursor - 1, 0, 3)
            KEY_RIGHT: name_entry_cursor = wrapi(name_entry_cursor + 1, 0, 3)
            KEY_UP: name_entry_chars[name_entry_cursor] = wrapi(name_entry_chars[name_entry_cursor] + 1, 0, NAME_CHARS.length())
            KEY_DOWN: name_entry_chars[name_entry_cursor] = wrapi(name_entry_chars[name_entry_cursor] - 1, 0, NAME_CHARS.length())
            KEY_ENTER, KEY_KP_ENTER, KEY_SPACE: _save_high_score()
            _: return false
        return true
    if event is InputEventJoypadButton and event.pressed:
        match event.button_index:
            JOY_BUTTON_DPAD_LEFT: name_entry_cursor = wrapi(name_entry_cursor - 1, 0, 3)
            JOY_BUTTON_DPAD_RIGHT: name_entry_cursor = wrapi(name_entry_cursor + 1, 0, 3)
            JOY_BUTTON_DPAD_UP: name_entry_chars[name_entry_cursor] = wrapi(name_entry_chars[name_entry_cursor] + 1, 0, NAME_CHARS.length())
            JOY_BUTTON_DPAD_DOWN: name_entry_chars[name_entry_cursor] = wrapi(name_entry_chars[name_entry_cursor] - 1, 0, NAME_CHARS.length())
            JOY_BUTTON_A, JOY_BUTTON_START: _save_high_score()
            _: return false
        return true
    if event is InputEventJoypadMotion:
        var key = "%d:%d" % [event.device, event.axis]
        var active = absf(event.axis_value) > .7
        var was_active = bool(name_axis_latched.get(key, false))
        name_axis_latched[key] = active
        if not active or was_active:
            return active
        if event.axis == JOY_AXIS_LEFT_X:
            name_entry_cursor = wrapi(name_entry_cursor + (1 if event.axis_value > 0 else -1), 0, 3)
            return true
        if event.axis == JOY_AXIS_LEFT_Y:
            name_entry_chars[name_entry_cursor] = wrapi(name_entry_chars[name_entry_cursor] + (-1 if event.axis_value > 0 else 1), 0, NAME_CHARS.length())
            return true
    return false

func _save_high_score() -> void:
    var initials = ""
    for index in name_entry_chars:
        initials += NAME_CHARS[index]
    var winner = 0 if players[0]["score"] >= players[1]["score"] else 1
    var config = ConfigFile.new()
    config.load("user://arena_brawl_scores.cfg")
    var entries: Array = config.get_value("leaderboard", "entries", [])
    if entries.is_empty():
        var old_score = int(config.get_value("champion", "score", 0))
        if old_score > 0:
            entries.append({"name": String(config.get_value("champion", "name", "---")),
                "score": old_score, "cash": int(config.get_value("champion", "cash", 0)),
                "gold": int(config.get_value("champion", "gold", 0)), "level": 1, "floor": 1,
                "kills": 0, "boss_kills": 0, "deaths": 0, "pickups": 0,
                "continues_used": 0, "keys": 0, "stage_wins": 0,
                "loot_totals": _empty_stage_loot(), "play_time": 0, "stamp": 0})
    var stamp = int(Time.get_unix_time_from_system())
    entries.append({"name": initials, "score": int(players[winner]["score"]),
        "cash": int(players[winner]["cash"]), "gold": int(players[winner]["gold"]),
        "level": wave_index + 1, "floor": floor_in_room,
        "kills": int(players[winner]["kills"]),
        "boss_kills": int(players[winner]["boss_kills"]),
        "deaths": int(players[winner]["deaths"]),
        "pickups": int(players[winner]["pickups"]),
        "continues_used": int(players[winner]["continues_used"]),
        "keys": int(players[winner]["keys"]),
        "stage_wins": int(players[winner]["stage_wins"]),
        "loot_totals": players[winner]["loot_totals"].duplicate(true),
        "play_time": int(game_time), "stamp": stamp})
    entries.sort_custom(func(a, b):
        if int(a["score"]) == int(b["score"]):
            return int(a.get("stamp", 0)) < int(b.get("stamp", 0))
        return int(a["score"]) > int(b["score"]))
    high_score_rank = -1
    for i in range(entries.size()):
        if int(entries[i].get("stamp", -1)) == stamp and String(entries[i]["name"]) == initials:
            high_score_rank = i + 1
            break
    if entries.size() > 10:
        entries.resize(10)
    if high_score_rank > 10:
        high_score_rank = -1
    config.set_value("leaderboard", "entries", entries)
    if not entries.is_empty():
        config.set_value("champion", "name", entries[0]["name"])
        config.set_value("champion", "score", entries[0]["score"])
        config.set_value("champion", "cash", entries[0]["cash"])
        config.set_value("champion", "gold", entries[0]["gold"])
    config.save("user://arena_brawl_scores.cfg")
    high_score_saved = true

func _cycle_weapon(player: Dictionary) -> void:
    var i = weapon_ids.find(player["weapon"])
    player["weapon"] = weapon_ids[(i + 1) % weapon_ids.size()]
    audio.play_sfx("weapon_pickup")

func _process(delta: float) -> void:
    # Use elapsed wall-clock time so the entrance and gameplay never become
    # slow motion when the cabinet briefly drops frames. Pausing does not build
    # up delta, so a clamp here only makes overloaded hardware run slower.
    var dt = delta
    controller_help_timer = maxf(0.0, controller_help_timer - dt)
    enemy_finisher_cooldown = maxf(0.0, enemy_finisher_cooldown - dt)
    if control_wizard_open and control_wizard_hold_button >= 0:
        control_wizard_hold_time += dt
        if control_wizard_hold_time >= 0.9:
            control_wizard_hold_button = -1
            _advance_control_wizard()
    if not demo_paused and not game_over and not victory:
        game_time += dt
        if attract_mode and game_time >= 35.0:
            var attract_config = ConfigFile.new()
            attract_config.load("user://arena_brawl_game.cfg")
            attract_config.set_value("game", "attract_mode", false)
            attract_config.save("user://arena_brawl_game.cfg")
            get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
            return
        if phase == "entrance":
            _update_entrance(dt)
        else:
            # Local finishers never pause the other contestants or the arena.
            if phase in ["combat", "route", "clear_hold", "intermission", "warning"]:
                _update_players(dt)
            _update_waves(dt)
            if phase in ["combat", "corridor"]:
                _update_enemies(dt)
        _update_shots(dt)
        _update_player_clones(dt)
        _update_floor_trail_bombs(dt)
        _update_drops(dt)
        _update_hazards(dt)
        _update_random_prizes(dt)
    elif victory:
        tally_time += dt
        if tally_time >= 7.0 and not high_score_music_started:
            high_score_music_started = true
            audio.play_music("high_score")
    elif game_over:
        tally_time += dt
        if attract_mode and tally_time >= 3.0:
            var demo_config = ConfigFile.new()
            demo_config.load("user://arena_brawl_game.cfg")
            demo_config.set_value("game", "attract_mode", false)
            demo_config.save("user://arena_brawl_game.cfg")
            get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
            return
    _update_visuals(dt if not demo_paused else 0.0)
    _fade_floor_marks()
    recovery_save_timer -= dt
    if recovery_save_timer <= 0.0:
        recovery_save_timer = 5.0
        _save_recovery_checkpoint()
    shake = move_toward(shake, 0.0, dt * 16.0)
    queue_redraw()

func _update_entrance(_dt: float) -> void:
    # Drive the show sequence from a monotonic clock. This keeps voice/video
    # sync exact even when Theora decoding or remote capture drops a frame.
    entrance_elapsed = (Time.get_ticks_msec() - entrance_started_msec) / 1000.0
    phase_timer = maxf(0.0, 13.4 - entrance_elapsed)
    # Keep the television-studio entrance energetic: contestants reach the
    # arena in five seconds rather than slowly drifting for most of the intro.
    var travel = clampf(entrance_elapsed / 5.0, 0.0, 1.0)
    travel = travel * travel * (3.0 - 2.0 * travel)
    players[0]["pos"] = Vector2(lerpf(35.0, 330.0, travel), lerpf(860.0, 545.0, travel))
    players[0]["move"] = Vector2(1, -0.35) if travel < 1 else Vector2.ZERO
    if p2_enabled:
        players[1]["pos"] = Vector2(lerpf(733.0, 438.0, travel), lerpf(860.0, 545.0, travel))
        players[1]["move"] = Vector2(-1, -0.35) if travel < 1 else Vector2.ZERO
    if entrance_elapsed >= .55 and not entrance_go_played:
        entrance_go_played = true
        # The original show cadence is four fast, distinct calls.
        audio.announce_sequence(["voice_go.wav", "voice_go.wav", "voice_go.wav", "voice_go.wav"], true, 0.0, true, .05)
    if entrance_elapsed >= 2.45 and not entrance_cheer_played:
        entrance_cheer_played = true
        audio.announce_sequence(["voice_cheer_2.wav"], false, 0.0, true)
    if entrance_elapsed >= 6.5 and not entrance_banner_played:
        entrance_banner_played = true
        entrance_banner = "BIG MONEY"
        intro_animation.visible = true
        intro_frame = -1
        # Queue the complete samples as one sequence. Separate timed priority
        # calls stopped the previous WAV at its last syllable on slower frames.
        audio.announce_sequence([
            "voice_big_money.wav", "voice_big_prizes.wav", "voice_i_love_it.wav"
        ], true, 0.0, true, .05)
        entrance_money_step = 3
    if entrance_banner_played:
        var banner_time := entrance_elapsed - 6.5
        var wanted_frame := clampi(floori(banner_time * 10.0) + 1, 1, 51)
        if wanted_frame != intro_frame:
            intro_frame = wanted_frame
            intro_animation.texture = load(BASE + "assets/intro_frames/frame_%03d.jpg" % intro_frame)
        var banner_x := 96.0
        if banner_time < .48:
            var slide_in := clampf(banner_time / .48, 0.0, 1.0)
            slide_in = 1.0 - pow(1.0 - slide_in, 3.0)
            banner_x = lerpf(-620.0, 96.0, slide_in)
        elif banner_time > 5.75:
            var slide_out := clampf((banner_time - 5.75) / .72, 0.0, 1.0)
            banner_x = lerpf(96.0, 790.0, slide_out * slide_out)
        intro_animation.position = Vector2(banner_x, 152)
        intro_love_label.position = Vector2(banner_x, 770)
        intro_love_label.visible = banner_time >= 4.95 and banner_time < 6.47
        intro_love_label.modulate.a = .72 + abs(sin(entrance_elapsed * 9.0)) * .28
    if phase_timer <= 0:
        intro_animation.visible = false
        intro_animation.texture = null
        intro_love_label.visible = false
        phase = "warning"
        phase_timer = 1.4

func _update_random_prizes(dt: float) -> void:
    if phase != "combat":
        return
    prize_spawn_timer -= dt
    if prize_spawn_timer <= 0:
        prize_spawn_timer = randf_range(10.0, 18.0)
        var roll = randf()
        var prize = "combat_clone" if roll < .14 else "lightning_bolt" if roll < .28 else "credits" if roll < .72 else "prize_box"
        _add_pickup(prize, Vector2(randf_range(120, 648), randf_range(260, 870)))
        _popup("BONUS DROP!", Vector2(384, 230), Color(1, .82, .12))

func _request_exit() -> void:
    var now = Time.get_ticks_msec() / 1000.0
    if now <= exit_armed_until:
        get_tree().quit()
        return
    exit_armed_until = now + 2.0
    _popup("PRESS START + SELECT AGAIN TO EXIT", Vector2(384, 500), Color(1.0, 0.85, 0.2))
    audio.play_sfx("pause")

func _set_pause(open: bool) -> void:
    demo_paused = open
    pause_selection = 0
    if not control_wizard_open and sfx_enabled:
        audio.play_sfx("pause")
    queue_redraw()

func _move_pause_selection(amount: int) -> void:
    pause_selection = wrapi(pause_selection + amount, 0, PAUSE_ITEMS.size())
    if sfx_enabled:
        audio.play_sfx("menu_move")
    queue_redraw()

func _activate_pause_item() -> void:
    if sfx_enabled:
        audio.play_sfx("menu_select")
    match pause_selection:
        0: _set_pause(false)
        1:
            _clear_recovery_checkpoint()
            restart(false)
            _set_pause(false)
        2:
            if is_instance_valid(audio):
                audio.stop_all()
            get_tree().change_scene_to_file(BASE + "scenes/TitleScreen.tscn")
        3: _start_control_wizard(0)
        4: _start_control_wizard(1)
        5: _cycle_player_controller(0, 1)
        6: _cycle_player_controller(1, 1)
        7: _adjust_pause_setting(10)
        8: _adjust_pause_setting(10)
        9: _adjust_pause_setting(10)
        10: controller_help_timer = 6.0
        11: get_tree().quit()
    queue_redraw()

func _adjust_pause_setting(amount: int) -> void:
    match pause_selection:
        5: _cycle_player_controller(0, amount)
        6: _cycle_player_controller(1, amount)
        7:
            music_volume = clampi(music_volume + amount, 0, 100)
            music_enabled = music_volume > 0
            audio.set_music_enabled(music_enabled)
            audio.set_music_volume(music_volume)
        8:
            sfx_volume = clampi(sfx_volume + amount, 0, 100)
            sfx_enabled = sfx_volume > 0
            audio.set_sfx_enabled(sfx_enabled)
            audio.set_sfx_volume(sfx_volume)
        9:
            voice_volume = clampi(voice_volume + amount, 0, 100)
            voice_enabled = voice_volume > 0
            audio.set_voice_enabled(voice_enabled)
            audio.set_voice_volume(voice_volume)
        _: return
    _save_controller_mappings()
    queue_redraw()

func _start_control_wizard(player_id: int) -> void:
    _refresh_player_controllers()
    control_wizard_player = player_id
    control_wizard_open = true
    control_wizard_step = 0
    control_wizard_device = _assigned_pad(player_id)
    control_wizard_name = Input.get_joy_name(control_wizard_device).to_lower().strip_edges() if control_wizard_device >= 0 else ""
    control_wizard_hold_button = -1
    demo_paused = true
    queue_redraw()

func _capture_control_event(event: InputEvent) -> bool:
    if event is InputEventJoypadMotion and absf(event.axis_value) >= 0.62:
        if event.device != control_wizard_device:
            return true
        _store_control_binding(CONTROL_ACTIONS[control_wizard_step], "axis,%d,%d" % [event.axis, 1 if event.axis_value > 0 else -1])
        _advance_control_wizard()
        return true
    if event is InputEventJoypadButton:
        if event.device != control_wizard_device:
            return true
        if event.pressed:
            control_wizard_hold_button = event.button_index
            control_wizard_hold_time = 0.0
        elif control_wizard_hold_button == event.button_index:
            if control_wizard_hold_time < 0.9:
                _store_control_binding(CONTROL_ACTIONS[control_wizard_step], "button,%d" % event.button_index)
                _advance_control_wizard()
            control_wizard_hold_button = -1
        return true
    if event is InputEventKey:
        if control_wizard_device < 0 and event.pressed and not event.echo:
            control_wizard_device = -1
            control_wizard_name = "keyboard"
            _store_control_binding(CONTROL_ACTIONS[control_wizard_step], "key,%d" % event.physical_keycode)
            _advance_control_wizard()
        return true
    return false

func _advance_control_wizard() -> void:
    control_wizard_step += 1
    control_wizard_hold_button = -1
    control_wizard_hold_time = 0.0
    if control_wizard_step >= CONTROL_ACTIONS.size():
        control_wizard_open = false
        _save_controller_mappings()
        controller_help_timer = 5.0
    queue_redraw()

func _store_control_binding(action: String, binding: String) -> void:
    var name = control_wizard_name if not control_wizard_name.is_empty() else "device_%d" % control_wizard_device
    if not controller_mappings.has(name):
        controller_mappings[name] = {}
    controller_mappings[name][action] = binding

func _mapped_button_action(device_name: String, button: int) -> String:
    var mappings: Dictionary = controller_mappings.get(device_name.strip_edges(), {})
    for action in CONTROL_ACTIONS:
        if String(mappings.get(action, "")) == "button,%d" % button:
            return action
    return ""

func _mapped_action_pressed(device_name: String, device: int, action: String) -> bool:
    var binding = String((controller_mappings.get(device_name.strip_edges(), {}) as Dictionary).get(action, ""))
    var parts = binding.split(",")
    if parts.size() == 2 and parts[0] == "button":
        return Input.is_joy_button_pressed(device, int(parts[1]))
    if parts.size() == 3 and parts[0] == "axis":
        return Input.get_joy_axis(device, int(parts[1])) * int(parts[2]) > 0.55
    return false

func _mapped_move_vector(device_name: String, device: int) -> Vector2:
    var result = Vector2.ZERO
    if _mapped_action_pressed(device_name, device, "MOVE LEFT"): result.x -= 1
    if _mapped_action_pressed(device_name, device, "MOVE RIGHT"): result.x += 1
    if _mapped_action_pressed(device_name, device, "MOVE UP"): result.y -= 1
    if _mapped_action_pressed(device_name, device, "MOVE DOWN"): result.y += 1
    return result.normalized()

func _mapped_keyboard_action_pressed(action: String) -> bool:
    var mappings: Dictionary = controller_mappings.get("keyboard", {})
    var parts = String(mappings.get(action, "")).split(",")
    return parts.size() == 2 and parts[0] == "key" and Input.is_physical_key_pressed(int(parts[1]))

func _handle_menu_axis(event: InputEventJoypadMotion) -> void:
    if not demo_paused:
        return
    var key = "%d:%d" % [event.device, event.axis]
    var active = absf(event.axis_value) >= 0.62
    var was_active = bool(joy_axis_latched.get(key, false))
    joy_axis_latched[key] = active
    if not active or was_active:
        return
    var mapped = ""
    var name = Input.get_joy_name(event.device).to_lower().strip_edges()
    var mappings: Dictionary = controller_mappings.get(name, {})
    for action in CONTROL_ACTIONS:
        var parts = String(mappings.get(action, "")).split(",")
        if parts.size() == 3 and parts[0] == "axis" and int(parts[1]) == event.axis and int(parts[2]) == (1 if event.axis_value > 0 else -1):
            mapped = action
            break
    if mapped == "MOVE UP":
        _move_pause_selection(-1)
    elif mapped == "MOVE DOWN":
        _move_pause_selection(1)
    elif mapped == "MOVE LEFT":
        _adjust_pause_setting(-10)
    elif mapped == "MOVE RIGHT":
        _adjust_pause_setting(10)
    elif event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
        if event.axis == JOY_AXIS_LEFT_Y:
            _move_pause_selection(1 if event.axis_value > 0 else -1)
        else:
            _adjust_pause_setting(10 if event.axis_value > 0 else -10)

func _save_controller_mappings() -> void:
    var config = ConfigFile.new()
    for device_name in controller_mappings:
        for action in controller_mappings[device_name]:
            config.set_value(device_name, action, controller_mappings[device_name][action])
    config.set_value("audio", "music_volume", music_volume)
    config.set_value("audio", "sfx_volume", sfx_volume)
    config.set_value("audio", "voice_volume", voice_volume)
    config.set_value("players", "player1_controller", player_controllers[0])
    config.set_value("players", "player2_controller", player_controllers[1])
    config.save("user://arena_brawl_controls.cfg")

func _load_controller_mappings() -> void:
    var config = ConfigFile.new()
    if config.load("user://arena_brawl_controls.cfg") != OK:
        return
    for section in config.get_sections():
        if section == "audio":
            music_volume = int(config.get_value(section, "music_volume", music_volume))
            sfx_volume = int(config.get_value(section, "sfx_volume", sfx_volume))
            voice_volume = int(config.get_value(section, "voice_volume", voice_volume))
            continue
        if section == "players":
            player_controllers[0] = String(config.get_value(section, "player1_controller", ""))
            player_controllers[1] = String(config.get_value(section, "player2_controller", ""))
            continue
        controller_mappings[section] = {}
        for key in config.get_section_keys(section):
            controller_mappings[section][key] = config.get_value(section, key)
    music_enabled = music_volume > 0
    sfx_enabled = sfx_volume > 0
    voice_enabled = voice_volume > 0
    audio.set_music_enabled(music_enabled)
    audio.set_sfx_enabled(sfx_enabled)
    audio.set_voice_enabled(voice_enabled)
    audio.set_music_volume(music_volume)
    audio.set_sfx_volume(sfx_volume)
    audio.set_voice_volume(voice_volume)

func _active_players() -> Array:
    var output: Array = []
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] > 0 and p["respawn"] <= 0.0:
            output.append(p)
    return output

func _load_difficulty() -> void:
    var config = ConfigFile.new()
    if config.load("user://arena_brawl_game.cfg") == OK:
        difficulty = String(config.get_value("game", "difficulty", "normal"))
        p2_enabled = bool(config.get_value("game", "two_players", true))
        attract_mode = bool(config.get_value("game", "attract_mode", false))
    match difficulty:
        "easy":
            enemy_health_scale = 0.78
            enemy_speed_scale = 0.72
            enemy_fire_scale = 1.42
            enemy_damage_scale = 0.65
            enemy_count_scale = 0.72
        "afraid":
            enemy_health_scale = 0.58
            enemy_speed_scale = 0.58
            enemy_fire_scale = 1.75
            enemy_damage_scale = 0.45
            enemy_count_scale = 0.55

func _ordered_pads() -> Array:
    # Keep the physical cabinet players deterministic. The companion service
    # exposes four always-present virtual pads and Linux may expose both a
    # wired xpad receiver and a Bluetooth Xbox pad; neither should displace
    # the active wireless Xbox or the DragonRise cabinet encoder.
    _refresh_mobile_pad_labels()
    var pads = Input.get_connected_joypads().filter(func(device):
        var device_name = Input.get_joy_name(device).to_lower().strip_edges()
        return not device_name.begins_with("dreadwire player") or mobile_pad_labels.has(device_name))
    pads.sort_custom(func(a, b):
        var an = Input.get_joy_name(a).to_lower()
        var bn = Input.get_joy_name(b).to_lower()
        var arank = 0 if "xbox wireless" in an else 1 if _is_cabinet_pad(a) else 2 if "xbox" in an or "x-box" in an else 3
        var brank = 0 if "xbox wireless" in bn else 1 if _is_cabinet_pad(b) else 2 if "xbox" in bn or "x-box" in bn else 3
        return arank < brank if arank != brank else a < b)
    return pads

func _is_cabinet_pad(device: int) -> bool:
    var name = Input.get_joy_name(device).to_lower()
    var info = Input.get_joy_info(device)
    return "dragonrise" in name or (int(info.get("vendor_id", -1)) == 0x79 and int(info.get("product_id", -1)) == 0x06)

func _pad_label(device: int) -> String:
    var device_name = Input.get_joy_name(device).strip_edges()
    if _is_cabinet_pad(device):
        return "BUILT-IN CABINET (DragonRise)"
    return String(mobile_pad_labels.get(device_name.to_lower(), device_name))

func _refresh_mobile_pad_labels() -> void:
    mobile_pad_labels.clear()
    var path = "/run/dreadwire/mobile-controllers.json"
    if not FileAccess.file_exists(path):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
    if not parsed is Dictionary:
        return
    var controllers: Dictionary = parsed.get("controllers", {})
    for player in controllers:
        var record: Dictionary = controllers[player]
        var slot = int(player)
        if slot >= 1 and slot <= 4:
            mobile_pad_labels["dreadwire player %d" % slot] = String(record.get("label", "Mobile Player %d" % slot))

func _physical_pad_names() -> Array[String]:
    var names: Array[String] = []
    for device in _ordered_pads():
        var name = _pad_label(device)
        if not names.has(name):
            names.append(name)
    return names

func _refresh_player_controllers() -> void:
    var names = _physical_pad_names()
    if names.is_empty():
        return
    if player_controllers[0].is_empty() or not names.has(player_controllers[0]):
        player_controllers[0] = names[0]
    if player_controllers[1].is_empty() or not names.has(player_controllers[1]) or player_controllers[1] == player_controllers[0]:
        player_controllers[1] = names[1] if names.size() > 1 else ""
    _save_controller_mappings()

func _cycle_player_controller(player_id: int, amount: int) -> void:
    var names = _physical_pad_names()
    if names.is_empty():
        return
    var current = names.find(player_controllers[player_id])
    var next = wrapi(current + (1 if amount > 0 else -1), 0, names.size())
    var chosen = names[next]
    var other = 1 - player_id
    if player_controllers[other] == chosen:
        player_controllers[other] = player_controllers[player_id]
    player_controllers[player_id] = chosen
    _save_controller_mappings()
    queue_redraw()

func _assigned_pad(player_id: int) -> int:
    if player_id < 0 or player_id >= player_controllers.size():
        return -1
    for device in Input.get_connected_joypads():
        if _pad_label(device) == player_controllers[player_id] or Input.get_joy_name(device).strip_edges() == player_controllers[player_id]:
            return device
    return -1

func _nearest_player(point: Vector2) -> Dictionary:
    var result: Dictionary = {}
    var best = INF
    for p in _active_players():
        if p["buffs"].has("blessing_stealth"):
            continue
        var distance = point.distance_squared_to(p["pos"])
        if distance < best:
            best = distance
            result = p
    return result

func _clamp_room(point: Vector2, radius: float = 18.0) -> Vector2:
    return Vector2(clampf(point.x, ROOM.position.x + radius, ROOM.end.x - radius),
        clampf(point.y, ROOM.position.y + radius, ROOM.end.y - radius))

func _direction(vector: Vector2) -> String:
    var index = posmod(roundi((vector.angle() - PI / 2.0) / (PI / 4.0)), 8)
    return DIRS[index]

func _update_players(dt: float) -> void:
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] <= 0:
            p["continue_timer"] = maxf(0.0, p["continue_timer"] - dt)
            if p["continue_timer"] > 0 and p["continues"] > 0 and _continue_requested(int(p["id"])):
                p["continues"] -= 1
                p["continues_used"] += 1
                p["lives"] = 3
                p["health"] = 100.0
                p["respawn"] = 0.0
                p["invuln"] = 3.0
                p["pos"] = Vector2(280 + p["id"] * 208, 545)
                p["continue_timer"] = 0.0
                audio.announce_sequence(["voice_contestant_1.wav" if p["id"] == 0 else "voice_contestant_2.wav", "voice_go.wav"])
                _effect("enemy_spawn", p["pos"], 1.0)
            continue
        p["invuln"] = maxf(0, p["invuln"] - dt)
        p["damage_flash"] = maxf(0, p["damage_flash"] - dt)
        p["shield_share_cooldown"] = maxf(0, p["shield_share_cooldown"] - dt)
        p["trail_cooldown"] = maxf(0, p["trail_cooldown"] - dt)
        p["fire_timer"] = maxf(0, p["fire_timer"] - dt)
        p["anim_time"] += dt
        if p["respawn"] > 0:
            p["death_progress"] += dt
        for key in p["buffs"].keys():
            p["buffs"][key] -= dt
            if p["buffs"][key] <= 0:
                p["buffs"].erase(key)
        if p["respawn"] > 0:
            p["respawn"] -= dt
            if p["respawn"] <= 0:
                p["health"] = 100.0
                p["invuln"] = 3.0
                p["death_move"] = ""
                p["death_progress"] = 0.0
                p["pos"] = _safe_floor_position(int(p["id"])) if erosion_active else Vector2(280 + p["id"] * 208, 545)
                audio.play_sfx("player_respawn")
                audio.announce_sequence(["voice_contestant_1.wav" if p["id"] == 0 else "voice_contestant_2.wav", "voice_go.wav"])
                _effect("enemy_spawn", p["pos"], 1.0)
            continue
        var prefix = "brawl_p1_" if p["id"] == 0 else "brawl_p2_"
        var move = Input.get_vector(prefix + "left", prefix + "right", prefix + "up", prefix + "down")
        var aim: Vector2 = p["aim"]
        var firing = false
        var fire_button = false
        var lock_button = false
        var secondary_button = false
        if p["id"] == 0:
            aim = (get_global_mouse_position() - p["pos"] - Vector2(0, -18)).normalized()
            fire_button = Input.is_action_pressed("brawl_p1_fire") or _mapped_keyboard_action_pressed("FIRE")
            lock_button = Input.is_physical_key_pressed(KEY_SHIFT) or _mapped_keyboard_action_pressed("LOCK AIM")
            secondary_button = Input.is_physical_key_pressed(KEY_B) or _mapped_keyboard_action_pressed("SECONDARY / BOMB")
            firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or fire_button
            if fire_button and move.length() > 0.1:
                aim = move.normalized()
        else:
            var key_aim = Input.get_vector("brawl_p2_aim_left", "brawl_p2_aim_right", "brawl_p2_aim_up", "brawl_p2_aim_down")
            if key_aim.length() > 0.1:
                aim = key_aim.normalized()
            firing = Input.is_action_pressed("brawl_p2_fire") or key_aim.length() > 0.1
            secondary_button = Input.is_physical_key_pressed(KEY_O)
        # Cabinet/first gamepad is P1. A second gamepad or phone becomes P2.
        var device = _assigned_pad(int(p["id"]))
        if device >= 0:
            var left = INPUT_SETUP.deadzone(Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)))
            if _is_cabinet_pad(device):
                left = Vector2(-left.y, left.x)
            var right = INPUT_SETUP.deadzone(Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)))
            if left.length() > 0:
                move = left
            if right.length() > 0:
                aim = right.normalized()
                firing = true
            var device_name = Input.get_joy_name(device).to_lower()
            var custom_move = _mapped_move_vector(device_name, device)
            if custom_move.length() > 0.1:
                move = custom_move
            var mapped_fire = _mapped_action_pressed(device_name, device, "FIRE")
            var fixed_aim = Vector2(
                float(_mapped_action_pressed(device_name, device, "FIRE RIGHT")) - float(_mapped_action_pressed(device_name, device, "FIRE LEFT")),
                float(_mapped_action_pressed(device_name, device, "FIRE DOWN")) - float(_mapped_action_pressed(device_name, device, "FIRE UP")))
            var has_directional_bindings = not String((controller_mappings.get(device_name.strip_edges(), {}) as Dictionary).get("FIRE UP", "")).is_empty()
            if not has_directional_bindings:
                fixed_aim = Vector2(
                    float(Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_X)),
                    float(Input.is_joy_button_pressed(device, JOY_BUTTON_A)) - float(Input.is_joy_button_pressed(device, JOY_BUTTON_Y)))
            if fixed_aim.length() > 0.1:
                aim = fixed_aim.normalized()
                firing = true
            var action_fire = mapped_fire
            var action_lock = _mapped_action_pressed(device_name, device, "LOCK AIM")
            var action_secondary = _mapped_action_pressed(device_name, device, "SECONDARY / BOMB")
            fire_button = fire_button or action_fire
            lock_button = lock_button or action_lock
            secondary_button = secondary_button or action_secondary or Input.is_joy_button_pressed(device, JOY_BUTTON_B)
            firing = firing or action_fire or Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.3
            if action_fire and right.length() <= 0.1 and move.length() > 0.1 and not lock_button:
                aim = move.normalized()
        if attract_mode:
            var target_enemy: Dictionary = {}
            var nearest = INF
            for enemy in enemies:
                var distance = p["pos"].distance_squared_to(enemy["pos"])
                if distance < nearest:
                    nearest = distance
                    target_enemy = enemy
            if not target_enemy.is_empty():
                # Demo contestants deliberately play like good humans rather
                # than perfect turrets: reaction bursts, slight aim drift and
                # imperfect spacing keep waves readable and survivable.
                var raw_aim: Vector2 = (target_enemy["pos"] - p["pos"]).normalized()
                aim = raw_aim.rotated(sin(game_time * 2.1 + p["id"] * 2.7) * .11)
                var burst_active := fmod(game_time + p["id"] * .63, 1.55) < .88
                firing = burst_active
                fire_button = burst_active
                var orbit = Vector2.from_angle(game_time * .48 + p["id"] * PI)
                var spacing = (p["pos"] - target_enemy["pos"]).normalized() * (.58 if nearest < 42000 else .18)
                move = (orbit * .72 + spacing).normalized()
        # FIRE and LOCK AIM are intentionally separate. FIRE normally follows
        # travel direction. Pressing LOCK snapshots that direction; while it is
        # held, the player can move anywhere without rotating the stream.
        if fire_button and lock_button and not bool(p["lock_held"]):
            p["locked_aim"] = aim if aim.length() > 0.1 else p["aim"]
        if fire_button and lock_button:
            aim = p["locked_aim"]
        p["fire_held"] = fire_button
        p["lock_held"] = lock_button
        # Ground bombs were removed: noisy controller edges could repeatedly
        # trigger them and cover the arena with automatic orange blast rings.
        p["secondary_held"] = secondary_button
        p["move"] = move
        p["aim"] = aim if aim.length() > 0.01 else Vector2.UP
        if move.length() > 0.01:
            p["dir"] = _direction(move)
        elif firing:
            p["dir"] = _direction(p["aim"])
        var lightning_speed = 1.0 + float(p["lightning_level"]) * .10
        var speed = 230.0 * lightning_speed * (1.4 if p["buffs"].has("speed_boost") else 1.0) * (.84 if attract_mode else 1.0)
        p["pos"] = _clamp_room(p["pos"] + move * speed * dt)
        if phase == "combat":
            _update_floor_paint(p)
        if firing and p["fire_timer"] <= 0:
            _fire_player(p)
    _share_reflect_shields()
    var anyone_alive = false
    var continue_available = false
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        anyone_alive = anyone_alive or p["lives"] > 0
        continue_available = continue_available or p["continue_timer"] > 0
    if not anyone_alive and not continue_available and not game_over:
        game_over = true
        audio.play_music("game_over")

func _continue_requested(player_id: int) -> bool:
    if player_id == 1 and Input.is_physical_key_pressed(KEY_U):
        return true
    var device = _assigned_pad(player_id)
    if device < 0:
        return false
    return Input.is_joy_button_pressed(device, JOY_BUTTON_A) or Input.is_joy_button_pressed(device, JOY_BUTTON_START)

func _fire_player(p: Dictionary) -> void:
    if shots.size() > 420:
        return
    var w: Dictionary = weapons[p["weapon"]]
    var demo_rate := 1.45 if attract_mode else 1.0
    var demo_damage := .64 if attract_mode else 1.0
    p["fire_timer"] = w["fire_interval"] * (0.55 if p["buffs"].has("rapid_fire") else 1.0) * demo_rate
    var count = int(w["projectile_count"]) + (2 if p["buffs"].has("spread_shot") else 0)
    var spread = maxf(float(w["spread_degrees"]), 7 if count > 1 else 0)
    var origin: Vector2 = p["pos"] + Vector2(0, -18)
    var angle: float = p["aim"].angle()
    for j in range(count):
        var direction = Vector2.from_angle(angle + deg_to_rad((j - (count - 1) * 0.5) * spread))
        shots.append({"pos": origin + direction * 28, "old": origin,
            "vel": direction * w["projectile_speed"], "owner": p["id"], "kind": w["projectile"],
            "damage": w["damage"] * (1.6 if p["buffs"].has("damage_boost") else 1) * demo_damage,
            "life": w["lifetime"], "pierce": w["piercing"] or p["buffs"].has("piercing"),
            "splash": w["splash_radius"], "chain": w["chain_targets"], "hit_ids": []})
    # The orbit robot is a companion upgrade, not a replacement weapon.  It
    # copies the owner's aim and fires extra scaled shots alongside them.
    if int(p["drone_level"]) > 0:
        for drone_index in range(mini(3, int(p["drone_level"]))):
            var orbit_angle = game_time * (3.0 + drone_index * .18) + drone_index * TAU / maxf(1.0, float(p["drone_level"]))
            var drone_origin = p["pos"] + Vector2.from_angle(orbit_angle) * (42.0 + drone_index * 7.0)
            var direction = p["aim"].normalized()
            shots.append({"pos": drone_origin + direction * 18, "old": drone_origin,
                "vel": direction * float(w["projectile_speed"]), "owner": p["id"], "kind": w["projectile"],
                "damage": float(w["damage"]) * (.55 + drone_index * .12) * demo_damage, "life": w["lifetime"],
                "pierce": false, "splash": float(w["splash_radius"]) * .45, "chain": 0, "hit_ids": []})
    if w["id"] != "flame_projector" or int(game_time * 10) % 5 == 0:
        if sfx_enabled:
            audio.play_sfx(w["sound"], randf_range(0.96, 1.04))
    _effect("muzzle_plasma" if w["projectile"] == "plasma" else "muzzle_pulse", origin + p["aim"] * 34, 0.20, angle)

func _spawn_combat_clone(p: Dictionary) -> void:
    var owner = int(p["id"])
    # Picking up another clone refreshes the existing helper rather than
    # multiplying autonomous shooters until the arena becomes unreadable.
    player_clones = player_clones.filter(func(clone): return int(clone["owner"]) != owner)
    player_clones.append({"owner": owner, "pos": p["pos"] + Vector2(-38 if owner == 0 else 38, 28),
        "time": 5.0, "fire_timer": .12, "aim": p["aim"], "anim_time": 0.0})
    _popup("COMBAT CLONE — 5 SECONDS!", p["pos"] + Vector2(0, -72), Color(.45, 1, .95))
    _effect("enemy_spawn", p["pos"], .8)

func _update_player_clones(dt: float) -> void:
    for clone in player_clones:
        clone["time"] -= dt
        clone["fire_timer"] -= dt
        clone["anim_time"] += dt
        var owner_id = int(clone["owner"])
        if owner_id < 0 or owner_id >= players.size() or players[owner_id]["lives"] <= 0:
            clone["time"] = 0.0
            continue
        var owner: Dictionary = players[owner_id]
        var target: Dictionary = {}
        var nearest := INF
        for enemy in enemies:
            if float(enemy["hp"]) <= 0.0 or float(enemy["spawn"]) > 0.0:
                continue
            var distance: float = clone["pos"].distance_squared_to(enemy["pos"])
            if distance < nearest:
                nearest = distance
                target = enemy
        var destination: Vector2
        if target.is_empty():
            destination = owner["pos"] + Vector2(-44 if owner_id == 0 else 44, 30)
        else:
            var away = (clone["pos"] - target["pos"]).normalized()
            if away == Vector2.ZERO:
                away = Vector2.DOWN
            destination = target["pos"] + away * 125.0
            clone["aim"] = (target["pos"] - clone["pos"]).normalized()
        var delta_to_target: Vector2 = destination - clone["pos"]
        if delta_to_target.length() > 8.0:
            clone["pos"] += delta_to_target.normalized() * minf(delta_to_target.length(), 330.0 * dt)
            clone["pos"] = _clamp_room(clone["pos"], 26.0)
        if target.is_empty() or float(clone["fire_timer"]) > 0.0 or shots.size() > 416:
            continue
        var w: Dictionary = weapons[owner["weapon"]]
        var direction: Vector2 = clone["aim"]
        var origin: Vector2 = clone["pos"] + Vector2(0, -18)
        clone["fire_timer"] = maxf(.18, float(w["fire_interval"]) * .8)
        shots.append({"pos": origin + direction * 22.0, "old": origin,
            "vel": direction * float(w["projectile_speed"]), "owner": owner_id, "kind": w["projectile"],
            "damage": float(w["damage"]) * .55, "life": w["lifetime"], "pierce": false,
            "splash": float(w["splash_radius"]) * .4, "chain": 0, "hit_ids": []})
        _effect("muzzle_plasma" if w["projectile"] == "plasma" else "muzzle_pulse", origin + direction * 27.0, .14, direction.angle())
    player_clones = player_clones.filter(func(clone): return float(clone["time"]) > 0.0)

func _hurt_player(p: Dictionary, amount: float, finisher_source: String = "") -> void:
    if god_mode or p["respawn"] > 0 or (finisher_source != "floor" and (p["invuln"] > 0 or p["buffs"].has("invulnerability"))):
        return
    var absorbed = minf(p["armor"], amount * 0.7)
    p["armor"] -= absorbed
    p["health"] -= amount - absorbed
    p["invuln"] = 0.8
    p["damage_flash"] = 0.16
    audio.play_sfx("player_hurt")
    _effect("blood_damage", p["pos"], 0.45)
    if p["health"] <= 0:
        p["lives"] -= 1
        p["deaths"] += 1
        p["respawn"] = 3.2
        var death_moves = ["CRUSHED", "SHRINK + STOMP", "VAPORIZED", "LAUNCHED", "FROZEN SHATTER", "FLATTENED", "ELECTROCUTED", "CAMERA SMASH", "FIELD GOAL", "UPPERCUT", "SPUN OUT", "DISINTEGRATED", "LADDER PLANK", "TRASH COMPACTOR", "ROCKET CHAIR", "NEON TRAIN"]
        p["death_move"] = "FLOOR SWALLOWED" if finisher_source == "floor" else death_moves[randi() % death_moves.size()]
        p["death_progress"] = 0.0
        p["death_direction"] = -1.0 if randf() < .5 else 1.0
        if String(p["death_move"]) in CINEMATIC_FINISHERS:
            _start_cinematic_finisher(String(p["death_move"]), "player", int(p["id"]), finisher_source, -1, p["pos"])
        _popup(p["death_move"], p["pos"] + Vector2(0, -62), Color(1, .2, .32))
        _effect("explosion_medium", p["pos"], 0.8)
        audio.play_sfx("player_death")
        audio.announce("player_death")
        if p["lives"] <= 0:
            p["continue_timer"] = 10.0
    elif p["health"] < 30:
        audio.announce("player_low_health")

func _drop_player_bomb(p: Dictionary) -> void:
    p["bombs"] = maxi(0, int(p["bombs"]) - 1)
    player_bombs.append({"pos": p["pos"], "owner": p["id"], "time": 0.0, "fuse": .72})
    _popup("BOMB ARMED", p["pos"] + Vector2(0, -52), Color(1, .35, .15))
    audio.play_sfx("bomber_throw")

func _update_player_bombs(dt: float) -> void:
    for bomb in player_bombs:
        bomb["time"] += dt
        if bomb["time"] < bomb["fuse"]:
            continue
        for enemy in enemies:
            var distance = enemy["pos"].distance_to(bomb["pos"])
            if distance < 210.0:
                _hurt_enemy(enemy, lerpf(185.0, 60.0, distance / 210.0), int(bomb["owner"]))
        for shot in shots:
            if int(shot["owner"]) < 0 and shot["pos"].distance_to(bomb["pos"]) < 245.0:
                shot["life"] = 0
        _effect("explosion_large", bomb["pos"], 1.0)
        audio.play_sfx("explosion_large")
        shake = 8.0
    player_bombs = player_bombs.filter(func(bomb): return bomb["time"] < bomb["fuse"])

func _share_reflect_shields() -> void:
    var active = _active_players()
    if active.size() < 2:
        return
    var a: Dictionary = active[0]
    var b: Dictionary = active[1]
    if a["pos"].distance_to(b["pos"]) > 42 or a["shield_share_cooldown"] > 0 or b["shield_share_cooldown"] > 0:
        return
    var a_time = float(a["buffs"].get("reflect_shield", 0.0))
    var b_time = float(b["buffs"].get("reflect_shield", 0.0))
    var donor: Dictionary = a if a_time > b_time + 1.0 else b if b_time > a_time + 1.0 else {}
    if donor.is_empty():
        return
    var receiver: Dictionary = b if donor == a else a
    var shared = float(donor["buffs"]["reflect_shield"]) * .5
    donor["buffs"]["reflect_shield"] = shared
    receiver["buffs"]["reflect_shield"] = shared
    donor["shield_share_cooldown"] = 1.5
    receiver["shield_share_cooldown"] = 1.5
    _popup("SHIELD SHARED!", (a["pos"] + b["pos"]) * .5 + Vector2(0, -55), Color(1, .25, .8))
    audio.play_sfx("shield_block")

func _update_waves(dt: float) -> void:
    door_open_timer = maxf(0.0, door_open_timer - dt)
    if phase == "boss_tally":
        _update_boss_tally(dt)
        return
    if phase == "route":
        _update_route_choice()
        return
    if phase == "floor_drop" or phase == "floor_build":
        _update_floor_transition(dt)
        return
    if phase == "clear_hold":
        # Never let the floor transition strand a living or spawning enemy.
        # If anything reappears during the clear flourish, resume combat.
        if _living_enemy_count() > 0:
            phase = "combat"
            enemy_clear_stable_time = 0.0
            return
        phase_timer -= dt
        if phase_timer <= 0:
            _finish_floor_clear()
        return
    if phase == "intermission":
        phase_timer -= dt
        if phase_timer <= 0:
            phase = "warning"
            phase_timer = 1.4
            _popup("NEXT ROUND STARTS NOW!", Vector2(384, 430), Color(.3, 1, .72))
        return
    if phase == "floor_restore":
        phase_timer -= dt
        floor_transition = 1.0 - clampf(phase_timer / 3.0, 0.0, 1.0)
        if phase_timer <= 0:
            erosion_cells.clear()
            erosion_active = false
            _start_floor_drop("")
        return
    if phase == "turn":
        phase_timer -= dt
        floor_transition = 1.0 - clampf(phase_timer / 1.35, 0.0, 1.0)
        if phase_timer <= 0:
            if wave_index + 1 >= waves.size():
                _start_campaign_victory()
                return
            wave_index += 1
            floor_in_room = 1
            phase = "intermission"
            phase_timer = 3.0
            pending_route = ""
        return
    if phase == "corridor":
        _update_corridor(dt)
        return
    phase_timer -= dt
    if phase == "warning" and phase_timer <= 0:
        _begin_wave()
    elif phase == "combat":
        combat_elapsed += dt
        if erosion_active:
            _update_floor_erosion(dt)
        # Upgraded weapons can erase the opening group very quickly. A second
        # arrival makes each normal floor feel like a complete round.
        if wave_spawned and not wave_reinforcements_spawned and combat_elapsed >= 10.0:
            var wave: Dictionary = waves[wave_index]
            wave_reinforcements_spawned = true
            if str(wave["boss"]).is_empty():
                var pool: Array = wave["enemy_pool"]
                var doors = [Vector2(384, 180), Vector2(384, 940), Vector2(58, 555), Vector2(710, 555)]
                for j in range(mini(5, 2 + int(wave_index / 4))):
                    _spawn_enemy(pool[randi() % pool.size()], doors[(j + wave_index) % doors.size()], false)
                _popup("BONUS WAVE!", Vector2(384, 430), Color(1, .35, .72))
        if _living_enemy_count() == 0:
            enemy_clear_stable_time += dt
        else:
            enemy_clear_stable_time = 0.0
        if wave_spawned and wave_reinforcements_spawned and combat_elapsed >= 12.0 and enemy_clear_stable_time >= 2.0:
            phase = "clear_hold"
            phase_timer = 5.0
            floor_transition = 0.0
            audio.play_sfx("wave_clear")
            audio.play_sfx("door_close")
            _popup("ROUND CLEAR — NEXT ROUND IN 5", Vector2(384, 430), Color(.35, 1, .55))

func _finish_floor_clear() -> void:
    if phase != "clear_hold":
        return
    if _living_enemy_count() > 0:
        phase = "combat"
        enemy_clear_stable_time = 0.0
        return
    wave_spawned = false
    var defeated_boss = not str(waves[wave_index]["boss"]).is_empty()
    if randf() < .28:
        _add_pickup("reflect_shield", Vector2(randf_range(170, 598), randf_range(410, 720)))
    if randf() < .32:
        _add_pickup("lightning_bolt", Vector2(randf_range(170, 598), randf_range(410, 720)))
    if defeated_boss:
        _start_boss_tally()
    else:
        wave_index += 1
        floor_in_room += 1
        phase = "intermission"
        phase_timer = 0.8
    _save_recovery_checkpoint()

func _start_boss_tally() -> void:
    phase = "boss_tally"
    phase_timer = 0.0
    boss_tally_row = 0
    boss_tally_counts = [_empty_stage_loot(), _empty_stage_loot()]
    boss_tally_cash = [0, 0]
    boss_tally_tick = 0.0
    boss_tally_pause = 0.55
    boss_tally_finish = 0.0
    boss_tally_winner = -2
    boss_tally_bonus_awarded = false
    shots.clear()
    hazards.clear()
    drops.clear()
    audio.play_sfx("wave_clear")
    _popup("STAGE COMPLETE — PRIZE SETTLEMENT", Vector2(384, 430), Color(1, .76, .16))

func _update_boss_tally(dt: float) -> void:
    if boss_tally_pause > 0.0:
        boss_tally_pause -= dt
        return
    if boss_tally_row < PRIZE_ORDER.size():
        boss_tally_tick -= dt
        if boss_tally_tick > 0.0:
            return
        boss_tally_tick = 0.06
        var prize_id: String = PRIZE_ORDER[boss_tally_row]
        var complete := true
        for i in range(2 if p2_enabled else 1):
            var target = int(players[i]["stage_loot"].get(prize_id, 0))
            var shown = int(boss_tally_counts[i].get(prize_id, 0))
            if shown < target:
                var step = 10 if target - shown > 40 else 5 if target - shown > 20 else 1
                step = mini(step, target - shown)
                boss_tally_counts[i][prize_id] = shown + step
                boss_tally_cash[i] += step * int(PRIZE_VALUES[prize_id]["cash"])
                complete = false
        if complete:
            boss_tally_row += 1
            boss_tally_pause = .3
        else:
            audio.play_sfx("credits_pickup")
        return
    if not boss_tally_bonus_awarded:
        boss_tally_bonus_awarded = true
        if p2_enabled:
            boss_tally_winner = 0 if boss_tally_cash[0] > boss_tally_cash[1] else 1 if boss_tally_cash[1] > boss_tally_cash[0] else -1
        else:
            boss_tally_winner = 0 if boss_tally_cash[0] >= 15000 else -1
        if boss_tally_winner >= 0:
            players[boss_tally_winner]["score"] += STAGE_WINNER_BONUS
            players[boss_tally_winner]["stage_wins"] += 1
            audio.announce_sequence(["voice_i_love_it.wav"], true, 3.0)
        boss_tally_finish = 3.4
        return
    boss_tally_finish -= dt
    if boss_tally_finish <= 0.0:
        for p in players:
            p["stage_loot"] = _empty_stage_loot()
        if wave_index + 1 >= waves.size():
            _start_campaign_victory()
            return
        phase = "route"
        audio.announce_sequence(["voice_lets_go.wav"])
        _popup("CHOOSE YOUR PATH", Vector2(384, 470), Color(.3, 1, .65))
        _save_recovery_checkpoint()

func _start_campaign_victory() -> void:
    # The fourth boss is the final campaign entry.  Never expose a route door
    # that can advance past the end of the wave table; finish the run and keep
    # its complete score/loot statistics available for the high-score entry.
    if victory:
        return
    phase = "complete"
    victory = true
    tally_time = 0.0
    shots.clear()
    hazards.clear()
    enemies.clear()
    player_bombs.clear()
    audio.play_music("win_game")
    audio.announce("victory", true)
    _popup("CAMPAIGN COMPLETE!", Vector2(384, 430), Color(1, .76, .16))

func _prepare_floor_erosion() -> void:
    erosion_cells.clear()
    erosion_order.clear()
    # An irregular inward sweep gives players readable danger at the edge while
    # still breaking into Tetris-like bites instead of a plain shrinking box.
    var cells: Array[Vector2i] = []
    for y in range(1, 13):
        for x in range(1, 11):
            cells.append(Vector2i(x, y))
    cells.sort_custom(func(a, b):
        var edge_a = mini(mini(a.x - 1, 10 - a.x), mini(a.y - 1, 12 - a.y))
        var edge_b = mini(mini(b.x - 1, 10 - b.x), mini(b.y - 1, 12 - b.y))
        if edge_a == edge_b:
            return posmod(a.x * 7 + a.y * 11 + wave_index * 3, 17) < posmod(b.x * 7 + b.y * 11 + wave_index * 3, 17)
        return edge_a < edge_b)
    erosion_order.assign(cells)
    erosion_timer = 3.5
    erosion_index = 0
    erosion_active = true
    _popup("STAGE 15: RUN! THE FLOOR IS HUNGRY", Vector2(384, 430), Color(1, .18, .4))

func _floor_cell_at(point: Vector2) -> Vector2i:
    return Vector2i(clampi(int(point.x / 64.0), 0, 11), clampi(int((point.y - 128.0) / 64.0), 0, 13))

func _update_floor_paint(player: Dictionary) -> void:
    var cell = _floor_cell_at(player["pos"])
    if cell == player["floor_cell"]:
        return
    player["floor_cell"] = cell
    if cell.x <= 0 or cell.x >= 11 or cell.y <= 0 or cell.y >= 13 or erosion_cells.has(cell):
        return
    _extend_floor_trail(player, cell)

func _fade_floor_marks() -> void:
    var expired: Array = []
    for cell in floor_tile_changed_at:
        if game_time - float(floor_tile_changed_at[cell]) > 1.8:
            expired.append(cell)
    for cell in expired:
        floor_tile_changed_at.erase(cell)
        floor_tile_states.erase(cell)
    for player in players:
        var trail_life = 5.5 + float(player["lightning_level"])
        if not player["floor_trail"].is_empty() and game_time - float(player["trail_last_step"]) > trail_life:
            player["floor_trail"].clear()

func _extend_floor_trail(player: Dictionary, cell: Vector2i) -> void:
    if float(player["trail_cooldown"]) > 0.0:
        return
    var trail: Array = player["floor_trail"]
    player["trail_last_step"] = game_time
    if trail.is_empty():
        trail.append(cell)
        return
    # Analog diagonals often cross two grid boundaries in one rendered frame.
    # Fill both orthogonal steps so the laser remains connected instead of
    # randomly resetting while the player draws a perfectly sensible loop.
    var previous: Vector2i = trail[-1]
    var cursor = previous
    while cursor.x != cell.x:
        cursor.x += 1 if cell.x > cursor.x else -1
        if _append_floor_trail_cell(player, cursor): return
    while cursor.y != cell.y:
        cursor.y += 1 if cell.y > cursor.y else -1
        if _append_floor_trail_cell(player, cursor): return

func _append_floor_trail_cell(player: Dictionary, cell: Vector2i) -> bool:
    var trail: Array = player["floor_trail"]
    # Stepping back one square is a correction, not a failed loop. Erasing the
    # whole trail here made analog controls feel random and unreliable.
    if trail.size() >= 2 and cell == trail[-2]:
        trail.pop_back()
        return false
    var earlier = trail.find(cell)
    if earlier >= 0:
        var loop: Array = trail.slice(earlier)
        var max_loop = 8 + mini(2, int(player["lightning_level"]))
        if loop.size() >= 4 and loop.size() <= max_loop:
            loop.append(cell)
            _arm_floor_trail_bomb(player, loop)
            trail.clear()
            return true
        else:
            trail = trail.slice(earlier)
            player["floor_trail"] = trail
            return false
    trail.append(cell)
    var max_trail = 10
    if trail.size() > max_trail:
        trail.pop_front()
    return false

func _arm_floor_trail_bomb(player: Dictionary, cells: Array) -> void:
    var center := Vector2.ZERO
    for cell in cells:
        var point = Vector2(cell.x * 64 + 32, 128 + cell.y * 64 + 32)
        center += point
    center /= float(cells.size())
    center = _clamp_room(center, 82.0)
    # Completing a compact loop arms a four-wall ricochet bomb. Its size stays
    # fixed so drawing a giant loop never creates a room-clearing weapon.
    var half := 64.0
    var points = PackedVector2Array([
        center + Vector2(-half, -half), center + Vector2(half, -half),
        center + Vector2(half, half), center + Vector2(-half, half)])
    var trapped_uids: Array[int] = []
    for enemy in enemies:
        if float(enemy["hp"]) > 0.0 and Geometry2D.is_point_in_polygon(enemy["pos"], points):
            trapped_uids.append(int(enemy["uid"]))
    var wall_hp := [randf_range(90.0, 125.0), randf_range(90.0, 125.0), randf_range(90.0, 125.0), randf_range(90.0, 125.0)]
    floor_trail_bombs.append({"owner": int(player["id"]), "points": points,
        "center": center, "time": 0.0, "fuse": 5.5, "hp": 1.0, "max_hp": 1.0,
        "wall_hp": wall_hp, "wall_max_hp": wall_hp.duplicate(),
        "trapped_uids": trapped_uids, "dead": false})
    _popup("RICOCHET BOMB: %d TRAPPED" % trapped_uids.size(), center + Vector2(0, -88), Color(.2, 1, .95) if int(player["id"]) == 0 else Color(1, .2, .78))
    audio.play_sfx("electric_floor")

func _update_floor_trail_bombs(dt: float) -> void:
    for bomb in floor_trail_bombs:
        bomb["time"] += dt
        var intact_walls: int = 0
        for hp in bomb["wall_hp"]:
            if float(hp) > 0.0: intact_walls += 1
        if float(bomb["time"]) < float(bomb["fuse"]) and intact_walls > 0:
            continue
        var owner = int(bomb["owner"])
        var center: Vector2 = bomb["center"]
        var blast_damage = 18.0 if intact_walls <= 0 else 38.0
        var blast_radius = 105.0 if intact_walls <= 0 else 138.0
        for enemy in enemies:
            if enemy["hp"] > 0 and enemy["pos"].distance_to(center) <= blast_radius:
                _hurt_enemy(enemy, 14.0 if enemy["boss"] else blast_damage, owner)
        _popup("BOMB IMPLODED" if intact_walls <= 0 else "RICOCHET BOMB!", center + Vector2(0, -84), Color(.25, 1, .9))
        _effect("explosion_medium", center, .8)
        audio.play_sfx("explosion_medium")
        bomb["dead"] = true
        if owner >= 0 and owner < players.size():
            players[owner]["trail_cooldown"] = 3.0
            players[owner]["floor_trail"].clear()
    floor_trail_bombs = floor_trail_bombs.filter(func(bomb): return not bool(bomb["dead"]))

func _living_enemy_count() -> int:
    var count := 0
    for enemy in enemies:
        if float(enemy["hp"]) > 0.0:
            count += 1
    return count

func _safe_floor_position(player_id: int) -> Vector2:
    var preferred = Vector2i(4 + player_id * 3, 7)
    if not erosion_cells.has(preferred):
        return Vector2(preferred.x * 64 + 32, 128 + preferred.y * 64 + 32)
    for reverse_index in range(erosion_order.size() - 1, -1, -1):
        var cell = erosion_order[reverse_index]
        if not erosion_cells.has(cell):
            return Vector2(cell.x * 64 + 32, 128 + cell.y * 64 + 32)
    return Vector2(384, 545)

func _update_floor_erosion(dt: float) -> void:
    erosion_timer -= dt
    if erosion_timer > 0:
        return
    erosion_timer += .24
    if erosion_index < erosion_order.size():
        var cell = erosion_order[erosion_index]
        erosion_cells[cell] = true
        erosion_index += 1
        if erosion_index % 5 == 0:
            audio.play_sfx("electric_floor")
    for player in _active_players():
        if erosion_cells.has(_floor_cell_at(player["pos"])):
            _hurt_player(player, 9999.0, "floor")
    for enemy in enemies:
        if enemy["hp"] > 0 and erosion_cells.has(_floor_cell_at(enemy["pos"])):
            _hurt_enemy(enemy, enemy["hp"] + 1.0, -1)

func _update_route_choice() -> void:
    if wave_index + 1 >= waves.size():
        _start_campaign_victory()
        return
    var exits = {
        "NORTH": Vector2(384, 185), "SOUTH": Vector2(384, 930),
        "WEST": Vector2(65, 555), "EAST": Vector2(703, 555)}
    for p in _active_players():
        for route in exits:
            if p["pos"].distance_to(exits[route]) < 62:
                route_history.append(route)
                pending_route = route
                _move_map(route)
                corridor_direction = -1 if route == "WEST" else 1
                phase = "turn"
                phase_timer = 1.35
                floor_transition = 0.0
                audio.play_sfx("door_open")
                return

func _start_floor_drop(route: String) -> void:
    pending_route = route
    _make_floor_order()
    phase = "floor_drop"
    floor_transition = 0.0
    phase_timer = 6.5
    shots.clear()
    hazards.clear()
    audio.play_sfx("electric_floor")
    _popup("FLOOR %d DESCENDING" % floor_in_room, Vector2(384, 430), Color(1, .52, .12))

func _make_floor_order() -> void:
    floor_order.clear()
    floor_rank.clear()
    # A readable top-to-bottom data wipe gives players a clear direction to
    # escape. Each row breaks in an alternating zig-zag rather than a noisy
    # random pattern that was difficult to understand while moving.
    var clusters: Array = []
    for y in range(1, 13):
        var row: Array[Vector2i] = []
        for x in range(1, 11): row.append(Vector2i(x, y))
        if (y + wave_index) % 2 == 0: row.reverse()
        clusters.append_array(row)
    floor_order.assign(clusters)
    for i in range(floor_order.size()): floor_rank[floor_order[i]] = i

func _update_floor_transition(dt: float) -> void:
    phase_timer -= dt
    if phase == "floor_drop":
        floor_transition = 1.0 - clampf(phase_timer / 6.5, 0.0, 1.0)
        var removed = int(floor_transition * floor_order.size())
        var danger_y = 185.0 + floor_transition * 700.0
        for player in _active_players():
            # The wipe never locks input. If it catches somebody, its energy
            # front carries them forward while they can still steer sideways
            # and keep running toward the extraction strip.
            if player["pos"].y < danger_y + 42.0:
                player["pos"].y = minf(925.0, danger_y + 42.0)
        if phase_timer <= 0:
            wave_index += 1
            if wave_index >= waves.size():
                victory = true
                tally_time = 0.0
                audio.play_music("win_game")
                audio.announce("victory", true)
                return
            if not pending_route.is_empty(): floor_in_room = 1
            else: floor_in_room += 1
            floor_tile_states.clear()
            floor_tile_changed_at.clear()
            for player in players:
                player["pos"] = Vector2(280 + player["id"] * 208, 365)
                player["floor_cell"] = Vector2i(-99, -99)
                player["floor_falling"] = false
                player["invuln"] = maxf(player["invuln"], 1.5)
            phase = "floor_build"
            phase_timer = 2.8
            floor_transition = 0.0
    else:
        floor_transition = 1.0 - clampf(phase_timer / 2.8, 0.0, 1.0)
        for player in _active_players(): player["pos"].y = lerpf(365.0, 545.0, floor_transition)
        if phase_timer <= 0:
            phase = "warning"
            phase_timer = 2.0
            pending_route = ""
            audio.play_sfx("door_open")

func _begin_corridor() -> void:
    phase = "corridor"
    corridor_progress = 0.0
    corridor_spawn_mark = 0
    enemies.clear()
    shots.clear()
    hazards.clear()
    for player in players:
        player["pos"] = Vector2(150 if corridor_direction > 0 else 618, 650 + player["id"] * 65)
    audio.play_music("junkyard")
    _popup("SIDE STAGE - PUSH %s" % ("RIGHT" if corridor_direction > 0 else "LEFT"), Vector2(384, 430), Color(1, .72, .12))

func _update_corridor(dt: float) -> void:
    var push := 0.0
    for player in _active_players(): push = maxf(push, player["move"].x * corridor_direction)
    corridor_progress = minf(CORRIDOR_LENGTH, corridor_progress + maxf(.12, push) * 155.0 * dt)
    var mark = int(corridor_progress / 225.0)
    while corridor_spawn_mark < mark and corridor_spawn_mark < 6:
        corridor_spawn_mark += 1
        var wave: Dictionary = waves[mini(wave_index, waves.size() - 1)]
        var pool: Array = wave["enemy_pool"]
        for j in range(2 + corridor_spawn_mark % 2):
            var x = 700.0 if corridor_direction > 0 else 68.0
            _spawn_enemy(pool[(corridor_spawn_mark + j) % pool.size()], Vector2(x, 330 + j * 210), false)
            enemies[-1]["spawn"] = .35
    if corridor_progress >= CORRIDOR_LENGTH and enemies.is_empty():
        _start_floor_drop(pending_route)

func _move_map(route: String) -> void:
    var delta: Vector2i = {"NORTH": Vector2i(0, -1), "SOUTH": Vector2i(0, 1), "WEST": Vector2i(-1, 0), "EAST": Vector2i(1, 0)}[route]
    map_position += delta
    map_path.append(map_position)
    var key = "%d,%d" % [map_position.x, map_position.y]
    var was_visited = map_visited.has(key)
    map_visited[key] = true
    var hidden = key in ["2,0", "-2,1", "1,-2"]
    if hidden and not map_hidden_found.has(key):
        map_hidden_found[key] = true
        _add_pickup("prize_box", Vector2(340, 560))
        _add_pickup("credits", Vector2(428, 560))
        audio.announce("bonus", true)
        _popup("HIDDEN PATH DISCOVERED!", Vector2(384, 490), Color(1, .72, .12))
    elif was_visited:
        _popup("BACKTRACKING - KNOWN ROOM", Vector2(384, 490), Color(.45, .8, 1))
    elif abs(map_position.x) + abs(map_position.y) >= 4:
        _popup("DEAD END AHEAD - REMEMBER THE WAY BACK", Vector2(384, 490), Color(1, .35, .3))

func _begin_wave() -> void:
    if wave_index < 0 or wave_index >= waves.size():
        _start_campaign_victory()
        return
    var wave: Dictionary = waves[wave_index]
    phase = "combat"
    wave_spawned = false
    wave_reinforcements_spawned = false
    combat_elapsed = 0.0
    enemy_clear_stable_time = 0.0
    door_open_timer = 2.2
    erosion_active = false
    erosion_cells.clear()
    hazards.clear()
    var doors = [Vector2(384, 180), Vector2(384, 940), Vector2(58, 555), Vector2(710, 555)]
    var pool: Array = wave["enemy_pool"]
    var count = maxi(10 + mini(wave_index, 6), roundi(int(wave["count"]) * enemy_count_scale))
    if not str(wave["boss"]).is_empty():
        count = maxi(4, count / 3)
        _spawn_enemy(wave["boss"], Vector2(384, 260), true)
        audio.play_music("inner_sanctum")
        audio.announce_sequence(["voice_good_luck.wav", "voice_youll_need_it.wav"], true, 20.0, true)
    else:
        audio.play_music("circuit_3" if wave_index >= 14 else "circuit_2" if wave_index >= 7 else "circuit_1")
    var formation_points: Array[Vector2] = []
    var formation_name := ""
    if str(wave["boss"]).is_empty() and count >= 6 and randf() < .72:
        formation_name = ["WEDGE", "PHALANX", "DIAMOND", "PINCER"][randi() % 4]
        formation_points = _formation_points(formation_name, mini(count, 10))
        _popup("%s FORMATION!" % formation_name, Vector2(384, 300), Color(1, .32, .18))
    for j in range(count):
        var point: Vector2 = doors[j % doors.size()] + Vector2(randf_range(-28, 28), randf_range(-28, 28))
        # Move a spawn to the opposite door if a live player is too close.
        var target = _nearest_player(point)
        if not target.is_empty() and point.distance_to(target["pos"]) < 125:
            point = doors[(j + 2) % doors.size()]
        _spawn_enemy(pool[randi() % pool.size()], point, false)
        if j < formation_points.size() and not enemies.is_empty():
            enemies[-1]["formation_target"] = formation_points[j]
            enemies[-1]["formation_until"] = game_time + 7.5
            enemies[-1]["timer"] = 1.0 + j * .08
    for j in range(int(wave["hazard_count"])):
        _spawn_hazard(["electric_floor", "flame_vent", "rotating_laser", "crusher"][j % 4], Vector2(225 + (j % 2) * 318, 390 + int(j / 2) * 300))
    if floor_in_room in [1, 3]:
        _spawn_blessing_rings()
    if str(wave["boss"]).is_empty() and floor_in_room in [2, 5, 8]:
        _spawn_weapon_choice()
    wave_spawned = true
    audio.play_sfx("door_open")

func _formation_points(kind: String, count: int) -> Array[Vector2]:
    var result: Array[Vector2] = []
    var center := Vector2(384, 450)
    for i in range(count):
        var point := center
        match kind:
            "WEDGE":
                var row := int(i / 2)
                point += Vector2((-1 if i % 2 == 0 else 1) * (34 + row * 34), row * 52)
            "PHALANX":
                point += Vector2((i % 5 - 2) * 72, int(i / 5) * 82)
            "DIAMOND":
                var ring := i % 8
                point += Vector2.from_angle(-PI / 2.0 + ring * TAU / 8.0) * (105.0 if i < 8 else 48.0)
            "PINCER":
                var side := -1 if i % 2 == 0 else 1
                point += Vector2(side * (155 - int(i / 2) * 18), int(i / 2) * 62 - 80)
        result.append(_clamp_room(point, 38.0))
    return result

func _spawn_weapon_choice() -> void:
    var candidates = weapon_ids.filter(func(id): return id != "pulse_pistol" and id != "orbit_drone")
    candidates.shuffle()
    var count = mini(2 if p2_enabled else 1, candidates.size())
    for i in range(count):
        drops.append({"kind": "weapon", "id": candidates[i],
            "pos": Vector2(300 + i * 168, 540), "life": 18.0})
    if floor_in_room in [5, 8] and randf() < .55:
        drops.append({"kind": "weapon", "id": "orbit_drone", "pos": Vector2(384, 650), "life": 18.0})

func _spawn_enemy(id: String, point: Vector2, is_boss: bool) -> void:
    if enemies.size() >= 120:
        return
    var definition: Dictionary = boss_defs[id] if is_boss else enemy_defs[id]
    var health = float(definition["health"]) * enemy_health_scale
    var speed = float(definition["speed"]) * enemy_speed_scale
    if is_boss and id == "enforcer":
        health *= 0.78
        speed *= 0.78
    enemies.append({"id": id, "uid": next_enemy_uid, "pos": _clamp_room(point, 28), "vel": Vector2.ZERO,
        "boss": is_boss, "hp": health, "max_hp": health,
        "speed": speed, "radius": float(definition["radius"]), "dir": "s",
        "timer": randf_range(1.0, 2.2), "flash": 0.0, "attack_flash": 0.0, "spawn": 0.7,
        "attack_index": 0, "boss_phase": 0, "boss_mode": "normal", "special_timer": 0.0,
        "invulnerable": false, "cloak": 0.0, "score": definition["score"], "anim_time": randf() * 2})
    next_enemy_uid += 1
    _effect("enemy_spawn", point, 0.65)

func _enemy_shot(enemy: Dictionary, direction: Vector2, kind: String = "enemy_bolt", speed: float = 230.0) -> void:
    if shots.size() > 420:
        return
    var origin: Vector2 = enemy["pos"] + Vector2(0, -15)
    shots.append({"pos": origin, "old": origin, "vel": direction * speed, "owner": -1,
        "kind": kind, "damage": (14.0 if not enemy["boss"] else 20.0) * enemy_damage_scale,
        "life": 5.0, "pierce": false, "splash": 0.0, "chain": 0, "hit_ids": []})

func _update_enemies(dt: float) -> void:
    # Newly spawned enemies are queued separately by boss logic to avoid iteration instability.
    var pending: Array = []
    for enemy in enemies:
        enemy["flash"] = maxf(0, enemy["flash"] - dt)
        enemy["attack_flash"] = maxf(0, enemy["attack_flash"] - dt)
        enemy["anim_time"] += dt
        enemy["spawn"] -= dt
        if enemy["spawn"] > 0 or enemy["hp"] <= 0:
            continue
        var target = _nearest_player(enemy["pos"])
        if target.is_empty():
            continue
        if enemy["boss"] and _update_boss_special(enemy, dt, target, pending):
            continue
        var distance: float = enemy["pos"].distance_to(target["pos"])
        var aim: Vector2 = (target["pos"] - enemy["pos"]).normalized()
        var direction = aim
        var speed = enemy["speed"] * (1.0 + int(enemy.get("boss_phase", 0)) * .12)
        if enemy["boss"] and int(enemy["boss_phase"]) >= 2:
            direction = aim.rotated(sin(game_time * (7.0 + int(enemy["boss_phase"]))) * (.28 + int(enemy["boss_phase"]) * .08))
        if enemy["id"] == "runner":
            direction = aim.rotated(sin(game_time * 5 + enemy["uid"]) * 0.55)
        elif enemy["id"] in ["drone", "bomber"]:
            direction = aim if distance > 280 else aim.rotated(PI / 2) if distance > 180 else -aim
        elif enemy["id"] == "turret":
            speed = 0
        if enemy.has("formation_target") and game_time < float(enemy["formation_until"]):
            var formation_delta: Vector2 = enemy["formation_target"] - enemy["pos"]
            if formation_delta.length() > 16.0:
                direction = formation_delta.normalized()
                speed *= 1.28
            else:
                direction = Vector2.ZERO
                speed = 0.0
        enemy["dir"] = _direction(aim)
        enemy["vel"] = direction * speed
        var previous_pos: Vector2 = enemy["pos"]
        enemy["pos"] = _clamp_room(enemy["pos"] + enemy["vel"] * dt, enemy["radius"])
        _confine_caged_enemy(enemy, previous_pos)
        if distance < enemy["radius"] + 20:
            var contact_damage = 22.0 if enemy["boss"] else 9.0 if enemy.has("minion_kind") else float(enemy_defs[enemy["id"]]["contact_damage"])
            _hurt_player(target, contact_damage, String(enemy.get("minion_kind", enemy["id"])))
        enemy["timer"] -= dt
        if enemy["timer"] > 0:
            continue
        enemy["attack_flash"] = 0.45
        if enemy["boss"]:
            var attack = enemy["attack_index"] % 3
            enemy["attack_index"] += 1
            enemy["timer"] = (1.7 if enemy["hp"] < enemy["max_hp"] * 0.4 else 2.6) * enemy_fire_scale
            if enemy["id"] == "enforcer":
                var enforcer_phase = int(enemy["boss_phase"])
                if enforcer_phase == 0 and attack == 0:
                    for j in range(7):
                        _enemy_shot(enemy, aim.rotated((j - 3) * 0.16), "enemy_bolt", 245)
                elif enforcer_phase == 1:
                    _spawn_hazard("crusher", target["pos"])
                    enemy["pos"] = _clamp_room(enemy["pos"] + aim * 135, 48)
                    for j in range(5): _enemy_shot(enemy, aim.rotated((j - 2) * .24), "enemy_bolt", 285)
                elif enforcer_phase == 2:
                    for j in range(12): _enemy_shot(enemy, Vector2.from_angle(j * TAU / 12 + game_time), "arc_bolt", 220)
                    _spawn_hazard("crusher", _clamp_room(target["pos"] + target["move"] * 90))
                elif enforcer_phase >= 3:
                    enemy["pos"] = _clamp_room(enemy["pos"] + aim * 175, 48)
                    for j in range(16): _enemy_shot(enemy, Vector2.from_angle(j * TAU / 16), "enemy_bolt", 250)
                    _spawn_hazard("electric_floor", target["pos"])
                elif attack == 1:
                    _spawn_hazard("crusher", target["pos"])
                    enemy["pos"] = _clamp_room(enemy["pos"] + aim * 65, 48)
                else:
                    for j in range(10):
                        _enemy_shot(enemy, Vector2.from_angle(j * TAU / 10), "enemy_bolt", 185)
            elif enemy["id"] == "prize_crusher":
                var crusher_phase = int(enemy["boss_phase"])
                var rocket_count = 8 + crusher_phase * 2
                for j in range(rocket_count):
                    _enemy_shot(enemy, Vector2.from_angle(j * TAU / rocket_count + game_time), "rocket", 175 + crusher_phase * 18)
                if attack == 2 or crusher_phase >= 2:
                    _spawn_hazard("mine", target["pos"])
                    _add_pickup("prize_box", _clamp_room(enemy["pos"] + Vector2(80, 80)))
            elif enemy["id"] == "neon_widow":
                var widow_phase = int(enemy["boss_phase"])
                var web_count = 7 + widow_phase * 2
                for j in range(web_count):
                    _enemy_shot(enemy, aim.rotated((j - (web_count - 1) / 2.0) * .15), "arc_bolt", 205 + widow_phase * 16)
                if attack == 2:
                    _spawn_hazard("electric_floor", target["pos"])
            else:
                var executive_phase = int(enemy["boss_phase"])
                if executive_phase == 0:
                    for j in range(14): _enemy_shot(enemy, Vector2.from_angle(j * TAU / 14 + game_time * .1), "plasma", 220)
                    _spawn_hazard("rotating_laser", target["pos"])
                elif executive_phase == 1:
                    for offset in [-130, 0, 130]: _spawn_hazard("electric_floor", _clamp_room(target["pos"] + Vector2(offset, 0)))
                    pending.append({"id": "turret", "pos": enemy["pos"] + Vector2(110, 0)})
                elif executive_phase == 2:
                    pending.append({"id": "heavy", "pos": enemy["pos"] + Vector2(-120, 0)})
                    pending.append({"id": "bomber", "pos": enemy["pos"] + Vector2(120, 0)})
                    for j in range(18): _enemy_shot(enemy, Vector2.from_angle(j * TAU / 18), "plasma", 245)
                else:
                    enemy["pos"] = _clamp_room(Vector2(768, 1100) - target["pos"], 90)
                    for j in range(24): _enemy_shot(enemy, Vector2.from_angle(j * TAU / 24 + game_time), "plasma", 275)
                    _spawn_hazard("rotating_laser", Vector2(384, 555))
            audio.play_sfx("laser_charge")
        elif enemy["id"] in ["drone", "turret", "heavy", "shield_guard"]:
            var count = 5 if enemy["id"] == "heavy" else 3 if enemy["id"] == "turret" else 1
            for j in range(count):
                _enemy_shot(enemy, aim.rotated((j - (count - 1) / 2.0) * .13))
            enemy["timer"] = 1.4 if enemy["id"] == "heavy" else 2.0
        elif enemy["id"] == "bomber":
            _spawn_hazard("mine", _clamp_room(target["pos"] + target["move"] * 60))
            enemy["timer"] = 2.8
            audio.play_sfx("bomber_throw")
        else:
            enemy["timer"] = 1.0
    for request in pending:
        if request["id"] == "widowling":
            _spawn_widowling(request["pos"])
        else:
            _spawn_enemy(request["id"], request["pos"], false)

func _begin_boss_phase(enemy: Dictionary, phase_index: int) -> void:
    enemy["boss_phase"] = phase_index
    enemy["timer"] = .45
    if enemy["id"] == "neon_widow":
        enemy["boss_mode"] = "widow_fade"
        enemy["special_timer"] = .9
        enemy["invulnerable"] = true
        enemy["cloak"] = 0.0
        _popup("NEON WIDOW BURROWS!", enemy["pos"] + Vector2(0, -100), Color(.35, 1, .8))
    elif enemy["id"] == "prize_crusher":
        enemy["boss_mode"] = "crusher_exit"
        enemy["special_timer"] = 1.0
        enemy["invulnerable"] = true
        _popup("PRIZE CRUSHER LEAVES THE SET!", Vector2(384, 300), Color(1, .45, .12))
    elif enemy["id"] == "enforcer":
        enemy["boss_mode"] = "enforcer_break"
        enemy["special_timer"] = 1.1
        enemy["invulnerable"] = true
        _popup(["CHARGE PROTOCOL", "CROSSFIRE PROTOCOL", "BERSERK PROTOCOL"][phase_index - 1], Vector2(384, 300), Color(1, .3, .18))
    else:
        enemy["boss_mode"] = "executive_shift"
        enemy["special_timer"] = 1.0
        enemy["invulnerable"] = true
        _popup(["LASER LOCKDOWN", "HOSTILE TAKEOVER", "TOTAL LIQUIDATION"][phase_index - 1], Vector2(384, 300), Color(.7, .35, 1))

func _update_boss_special(enemy: Dictionary, dt: float, target: Dictionary, pending: Array) -> bool:
    var mode = String(enemy.get("boss_mode", "normal"))
    if mode == "normal":
        return false
    enemy["special_timer"] = float(enemy.get("special_timer", 0.0)) - dt
    if mode == "widow_fade":
        enemy["cloak"] = clampf(1.0 - float(enemy["special_timer"]) / .9, 0.0, 1.0)
        if enemy["special_timer"] <= 0.0:
            enemy["pos"] = _clamp_room(Vector2(768, 1100) - target["pos"], 85)
            enemy["cloak"] = 1.0
            enemy["boss_mode"] = "widow_hatch"
            enemy["special_timer"] = .55
        return true
    if mode == "widow_hatch":
        if enemy["special_timer"] <= 0.0:
            var count = 4 + int(enemy["boss_phase"]) * 2
            for i in range(count):
                pending.append({"id": "widowling", "pos": _clamp_room(enemy["pos"] + Vector2.from_angle(i * TAU / count) * 75.0, 35)})
            enemy["boss_mode"] = "widow_wait"
            enemy["special_timer"] = 1.0
            _popup("SPIDER BABIES HATCH!", enemy["pos"] + Vector2(0, -105), Color(.4, 1, .65))
        return true
    if mode == "widow_wait":
        var babies_alive := false
        for other in enemies:
            if other.has("minion_kind") and other["minion_kind"] == "widowling" and other["hp"] > 0:
                babies_alive = true
                break
        if not babies_alive:
            enemy["boss_mode"] = "widow_return"
            enemy["special_timer"] = .9
        return true
    if mode == "widow_return":
        enemy["cloak"] = clampf(float(enemy["special_timer"]) / .9, 0.0, 1.0)
        if enemy["special_timer"] <= 0.0:
            enemy["cloak"] = 0.0
            enemy["invulnerable"] = false
            enemy["boss_mode"] = "normal"
            enemy["timer"] = .35
        return true
    if mode == "crusher_exit":
        var exit_direction = -1.0 if enemy["pos"].x < 384 else 1.0
        enemy["pos"].x += exit_direction * 620.0 * dt
        enemy["cloak"] = clampf(1.0 - float(enemy["special_timer"]), 0.0, 1.0)
        if enemy["special_timer"] <= 0.0:
            var squad = ["runner", "grunt"] if int(enemy["boss_phase"]) == 1 else ["bomber", "shield_guard"] if int(enemy["boss_phase"]) == 2 else ["heavy", "turret", "runner"]
            for i in range(3 + int(enemy["boss_phase"])):
                pending.append({"id": squad[i % squad.size()], "pos": Vector2(90 if i % 2 == 0 else 678, 300 + (i % 3) * 220)})
            enemy["boss_mode"] = "crusher_wait"
            enemy["special_timer"] = 1.0
        return true
    if mode == "crusher_wait":
        var squad_alive := false
        for other in enemies:
            if not other["boss"] and other["hp"] > 0:
                squad_alive = true
                break
        if not squad_alive:
            enemy["pos"] = Vector2(-90 if target["pos"].x > 384 else 858, target["pos"].y)
            enemy["boss_mode"] = "crusher_charge"
            enemy["special_timer"] = 2.2
            enemy["cloak"] = 0.0
            _popup("INCOMING!", target["pos"] + Vector2(0, -70), Color(1, .2, .12))
        return true
    if mode == "crusher_charge":
        var charge_dir = 1.0 if enemy["pos"].x < 0 else -1.0
        enemy["pos"].x += charge_dir * (620.0 + int(enemy["boss_phase"]) * 80.0) * dt
        enemy["pos"].y = move_toward(float(enemy["pos"].y), float(target["pos"].y), 90.0 * dt)
        if enemy["pos"].distance_to(target["pos"]) < 72:
            _hurt_player(target, 32.0, "prize_crusher")
        if (charge_dir > 0 and enemy["pos"].x >= 700) or (charge_dir < 0 and enemy["pos"].x <= 68) or enemy["special_timer"] <= 0.0:
            enemy["pos"] = _clamp_room(enemy["pos"], 70)
            enemy["boss_mode"] = "crusher_dizzy"
            enemy["special_timer"] = 2.8
            enemy["invulnerable"] = false
            shake = 9.0
            _effect("explosion_large", enemy["pos"], .9)
            _popup("DIZZY — OPEN FIRE!", enemy["pos"] + Vector2(0, -110), Color(1, .9, .2))
        return true
    if mode == "crusher_dizzy":
        enemy["vel"] = Vector2.ZERO
        enemy["attack_flash"] = abs(sin(game_time * 9.0)) * .35
        if enemy["special_timer"] <= 0.0:
            enemy["boss_mode"] = "normal"
            enemy["timer"] = .25
        return true
    if mode in ["enforcer_break", "executive_shift"]:
        enemy["cloak"] = .25 + abs(sin(game_time * 14.0)) * .25
        if mode == "executive_shift":
            enemy["pos"] = _clamp_room(Vector2(768, 1100) - target["pos"], 90)
        if enemy["special_timer"] <= 0.0:
            enemy["cloak"] = 0.0
            enemy["invulnerable"] = false
            enemy["boss_mode"] = "normal"
            enemy["timer"] = .2
        return true
    return false

func _spawn_widowling(point: Vector2) -> void:
    if enemies.size() >= 120:
        return
    var phase_health = 65.0 + wave_index * 4.0
    enemies.append({"id": "neon_widow", "minion_kind": "widowling", "uid": next_enemy_uid,
        "pos": _clamp_room(point, 22), "vel": Vector2.ZERO, "boss": false,
        "hp": phase_health, "max_hp": phase_health, "speed": 145.0 + wave_index * 2.0,
        "radius": 18.0, "dir": "s", "timer": .8, "flash": 0.0, "attack_flash": 0.0,
        "spawn": .45, "attack_index": 0, "boss_phase": 0, "score": 350,
        "anim_time": randf() * 2.0})
    next_enemy_uid += 1
    _effect("enemy_spawn", point, .45)

func _segment_hit(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
    var ab = b - a
    var fraction = clampf((center - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
    return (a + ab * fraction).distance_squared_to(center) <= radius * radius

func _update_shots(dt: float) -> void:
    for shot in shots:
        if shot["life"] <= 0:
            continue
        shot["old"] = shot["pos"]
        shot["pos"] += shot["vel"] * dt
        shot["life"] -= dt
        shot["shield_cooldown"] = maxf(0.0, float(shot.get("shield_cooldown", 0.0)) - dt)
        if float(shot["shield_cooldown"]) <= 0.0 and _ricochet_from_floor_shield(shot):
            continue
        if not ROOM.grow(25).has_point(shot["pos"]):
            shot["life"] = 0
            continue
        if shot["owner"] < 0:
            for p in _active_players():
                if _segment_hit(shot["old"], shot["pos"], p["pos"] + Vector2(0, -12), 20):
                    if p["buffs"].has("reflect_shield"):
                        shot["owner"] = p["id"]
                        shot["vel"] = -shot["vel"] * 1.18
                        shot["damage"] = maxf(28.0, float(shot["damage"]) * 1.35)
                        shot["old"] = shot["pos"]
                        shot["hit_ids"] = []
                        _effect("electric_arcs", shot["pos"], .35)
                        audio.play_sfx("shield_block")
                        break
                    _hurt_player(p, shot["damage"])
                    shot["life"] = 0
                    break
        else:
            for enemy in enemies:
                if enemy["hp"] <= 0 or shot["hit_ids"].has(enemy["uid"]) or enemy["spawn"] > 0:
                    continue
                if _segment_hit(shot["old"], shot["pos"], enemy["pos"] + Vector2(0, -12), enemy["radius"]):
                    var damage: float = shot["damage"]
                    if enemy["id"] == "shield_guard":
                        var facing = Vector2.from_angle(PI / 2 + DIRS.find(enemy["dir"]) * PI / 4)
                        if facing.dot(-shot["vel"].normalized()) > 0.6:
                            damage *= .25
                            audio.play_sfx("shield_block")
                    _hurt_enemy(enemy, damage, int(shot["owner"]))
                    shot["hit_ids"].append(enemy["uid"])
                    if shot["splash"] > 0:
                        for other in enemies:
                            if other["uid"] != enemy["uid"] and other["hp"] > 0 and other["pos"].distance_to(enemy["pos"]) < shot["splash"]:
                                _hurt_enemy(other, shot["damage"] * .7, int(shot["owner"]))
                        _effect("explosion_medium", enemy["pos"], .75)
                        audio.play_sfx("explosion_medium")
                        shake = 4.0
                    if shot["chain"] > 0:
                        var count = 0
                        for other in enemies:
                            if other["uid"] != enemy["uid"] and other["hp"] > 0 and other["pos"].distance_to(enemy["pos"]) < 150:
                                _hurt_enemy(other, shot["damage"] * .5, int(shot["owner"]))
                                _effect("electric_arcs", other["pos"], .45)
                                count += 1
                                if count >= shot["chain"]:
                                    break
                    if not shot["pierce"]:
                        shot["life"] = 0
                        break
    shots = shots.filter(func(s): return s["life"] > 0)
    enemies = enemies.filter(func(e): return e["hp"] > 0)

func _confine_caged_enemy(enemy: Dictionary, previous_pos: Vector2) -> void:
    var uid := int(enemy["uid"])
    for cage in floor_trail_bombs:
        if bool(cage["dead"]) or not cage["trapped_uids"].has(uid):
            continue
        var polygon: PackedVector2Array = cage["points"]
        if not Geometry2D.is_point_in_polygon(enemy["pos"], polygon):
            var crossed_wall := -1
            for i in range(polygon.size()):
                if Geometry2D.segment_intersects_segment(previous_pos, enemy["pos"], polygon[i], polygon[(i + 1) % polygon.size()]) != null:
                    crossed_wall = i
                    break
            if crossed_wall < 0 or float(cage["wall_hp"][crossed_wall]) > 0.0:
                enemy["pos"] = previous_pos
                enemy["vel"] = Vector2.ZERO
                # A contained enemy pauses at the wall, but keeps attacking it.
                enemy["timer"] = minf(float(enemy["timer"]), .3)
            else:
                cage["trapped_uids"].erase(uid)
        return

func _ricochet_from_floor_shield(shot: Dictionary) -> bool:
    # Friendly fire passes cleanly through containment walls.
    if int(shot["owner"]) >= 0:
        return false
    for bomb in floor_trail_bombs:
        if bool(bomb["dead"]):
            continue
        var points: PackedVector2Array = bomb["points"]
        for i in range(points.size()):
            if float(bomb["wall_hp"][i]) <= 0.0:
                continue
            var a = points[i]
            var b = points[(i + 1) % points.size()]
            var hit = Geometry2D.segment_intersects_segment(shot["old"], shot["pos"], a, b)
            if hit == null:
                continue
            # Enemy fire bounces back into the arena as weakened friendly fire,
            # while each impact chips away at that individual wall.
            shot["pos"] = hit
            var tangent: Vector2 = (b - a).normalized()
            var normal := Vector2(-tangent.y, tangent.x)
            shot["vel"] = shot["vel"] - 2.0 * shot["vel"].dot(normal) * normal
            shot["owner"] = int(bomb["owner"])
            shot["damage"] = maxf(10.0, float(shot["damage"]) * .72)
            shot["shield_cooldown"] = .12
            shot["old"] = hit
            shot["hit_ids"] = []
            bomb["wall_hp"][i] -= maxf(8.0, float(shot["damage"]) * .4)
            _effect("electric_arcs", hit, .2)
            audio.play_sfx("shield_block")
            if float(bomb["wall_hp"][i]) <= 0.0:
                _popup("BOMB WALL BREACHED", hit + Vector2(0, -28), Color(1, .35, .18))
                _effect("explosion_small", hit, .55)
            return true
    return false

func _hurt_enemy(enemy: Dictionary, amount: float, owner: int) -> void:
    if enemy["hp"] <= 0:
        return
    if bool(enemy.get("invulnerable", false)):
        enemy["flash"] = .05
        return
    enemy["hp"] -= amount
    enemy["flash"] = .09
    if enemy["boss"] and enemy["hp"] > 0:
        var next_phase = clampi(4 - int(ceil(float(enemy["hp"]) / float(enemy["max_hp"]) * 4.0)), 0, 3)
        if next_phase > int(enemy["boss_phase"]):
            _begin_boss_phase(enemy, next_phase)
            audio.play_sfx("boss_stagger")
            audio.announce_sequence(["voice_aaargh.wav" if next_phase == 3 else "voice_urk.wav"], true, 5.0, true)
            _popup("BOSS PHASE %d" % (next_phase + 1), enemy["pos"] + Vector2(0, -90), Color(1, .2, .15) if next_phase == 3 else Color(1, .62, .12))
    _effect("impact_plasma" if amount > 60 else "impact_enemy", enemy["pos"] + Vector2(0, -15), .25)
    if enemy["hp"] > 0:
        audio.play_sfx("bullet_hit_enemy")
        return
    if owner >= 0 and owner < players.size():
        var p: Dictionary = players[owner]
        p["score"] += int(enemy["score"]) * (2 if p["buffs"].has("score_multiplier") else 1)
        p["kills"] += 1
        if enemy["boss"]:
            p["boss_kills"] += 1
    _effect("explosion_large" if enemy["boss"] else "explosion_small", enemy["pos"], 1.0 if enemy["boss"] else .55)
    audio.play_sfx("explosion_large" if enemy["boss"] else "enemy_death")
    if enemy["boss"]:
        shake = 7.0
        _add_pickup("extra_life", enemy["pos"])
        audio.announce_sequence(["voice_aaargh.wav"], true, 2.0, true)
    elif not enemy.has("minion_kind") and randf() < enemy_defs[enemy["id"]]["drop_chance"]:
        _add_pickup(pickup_ids[randi() % pickup_ids.size()], enemy["pos"])
    if not enemy["boss"] and owner >= 0 and owner < players.size() and enemy_finisher_cooldown <= 0.0 and cinematic_finisher.is_empty() and randf() < .14:
        _start_cinematic_finisher(CINEMATIC_FINISHERS[randi() % CINEMATIC_FINISHERS.size()], "enemy", int(enemy["uid"]), String(enemy["id"]), owner, enemy["pos"])

func _start_cinematic_finisher(move: String, victim_kind: String, victim_id: int, victim_actor: String = "", attacker_player: int = -1, origin: Vector2 = Vector2(384, 545)) -> void:
    if not cinematic_finisher.is_empty():
        return
    # These are arena-floor death gags, not cutaway scenes. Keep them brief so
    # they match the regular death moves and never distract the other players.
    var duration = 2.8 if move == "LADDER PLANK" else 2.35 if move == "NEON TRAIN" else 2.2
    var attacker_enemy = victim_actor if victim_kind == "player" and enemy_defs.has(victim_actor) else "grunt"
    cinematic_finisher = {
        "move": move, "time": 0.0, "duration": duration,
        "victim_kind": victim_kind, "victim_id": victim_id,
        "victim_enemy": victim_actor if victim_kind == "enemy" else "",
        "victim_player": victim_id if victim_kind == "player" else -1,
        "attacker_player": attacker_player,
        "attacker_enemy": attacker_enemy,
        "direction": -1.0 if randf() < .5 else 1.0,
        "origin": _clamp_room(origin, 145.0),
    }
    enemy_finisher_cooldown = 13.0
    shake = 5.0
    _popup(move + "!", Vector2(384, 260), Color(1, .26, .56))
    audio.play_sfx("boss_stagger")

func _add_pickup(id: String, point: Vector2) -> void:
    drops.append({"kind": "pickup", "id": id, "pos": point, "life": 22.0})

func _spawn_blessing_rings() -> void:
    for player in _active_players():
        var owner = int(player["id"])
        var blessing = "full_health" if randf() < .28 else "random_weapon"
        var point = Vector2(220 + owner * 328, 765)
        drops.append({"kind": "blessing_ring", "id": blessing, "owner": owner,
            "pos": point, "life": 18.0})
        _popup("P%d BLESSING RING" % (owner + 1), point + Vector2(0, -48), Color(.2, .9, 1) if owner == 0 else Color(1, .25, .75))

func _update_drops(dt: float) -> void:
    for item in drops:
        item["life"] -= dt
        for p in _active_players():
            if item["life"] <= 0 or p["pos"].distance_to(item["pos"]) > 31:
                continue
            if item["kind"] == "blessing_ring":
                if int(p["id"]) != int(item["owner"]):
                    continue
                if item["id"] == "full_health":
                    p["health"] = 100.0
                    p["armor"] = maxf(float(p["armor"]), 50.0)
                    _popup("P%d BLESSED — FULL HEALTH" % (int(p["id"]) + 1), p["pos"] + Vector2(0, -58), Color(1, .92, .35))
                    audio.play_sfx("health_pickup")
                else:
                    p["weapon"] = weapon_ids[randi() % weapon_ids.size()]
                    _popup("P%d BLESSED — %s" % [int(p["id"]) + 1, weapons[p["weapon"]]["display_name"]], p["pos"] + Vector2(0, -58), Color(.35, .95, 1))
                    audio.play_sfx("weapon_pickup")
                p["buffs"]["invulnerability"] = 5.0
                p["buffs"]["blessing_stealth"] = 5.0
                _effect("enemy_spawn", p["pos"], 1.4)
                item["life"] = 0
                break
            if item["kind"] == "weapon":
                if item["id"] == "orbit_drone":
                    p["drone_level"] = mini(3, int(p["drone_level"]) + 1)
                    p["buffs"]["orbit_drone"] = 35.0
                    _popup("ORBIT DRONE LV.%d" % p["drone_level"], p["pos"] + Vector2(0, -50), Color(.35, 1, .9))
                else:
                    p["weapon"] = item["id"]
                    _popup(weapons[item["id"]]["display_name"], p["pos"] + Vector2(0, -50), Color(0.2, .85, 1))
                audio.play_sfx("weapon_pickup")
                audio.announce_sequence(["voice_yeah.wav"], false, 8.0)
            else:
                var id = item["id"]
                match id:
                    "health": p["health"] = minf(100.0, p["health"] + 40.0)
                    "armor": p["armor"] = minf(100.0, p["armor"] + 50.0)
                    "extra_life":
                        p["lives"] = mini(9, p["lives"] + 1)
                        audio.announce_sequence(["voice_whoo.wav"], false, 12.0)
                    "bomb": p["buffs"]["damage_boost"] = 8.0
                    "reflect_shield": p["buffs"]["reflect_shield"] = 10.0
                    "combat_clone": _spawn_combat_clone(p)
                    "lightning_bolt":
                        p["lightning_level"] = mini(5, int(p["lightning_level"]) + 1)
                        _popup("LIGHTNING LV.%d — SPEED + BOMB SIZE" % p["lightning_level"], p["pos"] + Vector2(0, -52), Color(.35, .9, 1))
                    "credits":
                        _collect_stage_prize(p, "cash_pile")
                    "prize_box":
                        _collect_stage_prize(p, _roll_game_show_prize())
                        audio.announce("pickup")
                    _: p["buffs"][id] = 12.0
                audio.play_sfx("extra_life" if id == "extra_life" else "health_pickup" if id == "health" else "credits_pickup")
                _popup(id.replace("_", " ").to_upper(), p["pos"] + Vector2(0, -48), Color(1, .75, .25))
            _effect("pickup_flash", item["pos"], .5)
            p["pickups"] += 1
            item["life"] = 0
            break
    drops = drops.filter(func(item): return item["life"] > 0)

func _roll_game_show_prize() -> String:
    var roll := randf()
    if roll < .23: return "toaster"
    if roll < .43: return "vcr"
    if roll < .59: return "microwave"
    if roll < .72: return "camcorder"
    if roll < .80: return "silver_bar"
    if roll < .87: return "gold_bar"
    if roll < .93: return "vacation"
    if roll < .98: return "luxury_car"
    return "key"

func _collect_stage_prize(player: Dictionary, prize_id: String) -> void:
    if not PRIZE_VALUES.has(prize_id):
        return
    player["stage_loot"][prize_id] = int(player["stage_loot"].get(prize_id, 0)) + 1
    player["loot_totals"][prize_id] = int(player["loot_totals"].get(prize_id, 0)) + 1
    player["cash"] += int(PRIZE_VALUES[prize_id]["cash"])
    player["score"] += int(PRIZE_VALUES[prize_id]["score"])
    if prize_id == "gold_bar":
        player["gold"] += 1
    elif prize_id == "key":
        player["keys"] += 1
    _popup(String(PRIZE_VALUES[prize_id]["label"]) + "!", player["pos"] + Vector2(0, -72), Color(1, .82, .18))

func _spawn_hazard(id: String, point: Vector2) -> void:
    if hazards.size() >= 24:
        return
    hazards.append({"id": id, "pos": _clamp_room(point, 48), "time": -1.4, "life": 9.0 if id != "mine" else 3.2})
    audio.play_sfx("hazard_warning")

func _update_hazards(dt: float) -> void:
    for hazard in hazards:
        var before: float = hazard["time"]
        hazard["time"] += dt
        hazard["life"] -= dt
        if before < 0 and hazard["time"] >= 0:
            audio.play_sfx("electric_floor" if hazard["id"] == "electric_floor" else "laser_charge")
        var active = hazard["time"] >= 0 and fmod(hazard["time"], 4.5) < 1.2
        if not active:
            continue
        for p in _active_players():
            var distance: float = p["pos"].distance_to(hazard["pos"])
            var hit = distance < (64.0 if hazard["id"] == "mine" else 38.0)
            if hazard["id"] == "rotating_laser":
                var ray = Vector2.from_angle(hazard["time"] * 1.9) * 135
                hit = _segment_hit(hazard["pos"] - ray, hazard["pos"] + ray, p["pos"], 18)
            if hit:
                _hurt_player(p, 35 if hazard["id"] == "mine" else 20)
    hazards = hazards.filter(func(h): return h["life"] > 0)

func _effect(id: String, point: Vector2, life: float, angle: float = 0.0) -> void:
    if effects.size() >= 160:
        return
    effects.append({"id": id, "pos": point, "life": life, "total": life, "angle": angle})

func _popup(label: String, point: Vector2, color: Color) -> void:
    popups.append({"text": label, "pos": point, "color": color, "life": 1.7})

func _update_visuals(dt: float) -> void:
    if not cinematic_finisher.is_empty():
        cinematic_finisher["time"] += dt
        if float(cinematic_finisher["time"]) >= float(cinematic_finisher["duration"]):
            cinematic_finisher.clear()
    for effect in effects:
        effect["life"] -= dt
    for popup in popups:
        popup["life"] -= dt
        popup["pos"].y -= 23 * dt
    effects = effects.filter(func(e): return e["life"] > 0)
    popups = popups.filter(func(e): return e["life"] > 0)

func _sprite(path: String, point: Vector2, index: int = 0, row: int = 0, pivot: Vector2 = Vector2(-1, -1), color: Color = Color.WHITE, sprite_scale: float = 1.0) -> void:
    var full_path = ART + path
    var metadata: Dictionary = library.record(full_path)
    if metadata.is_empty():
        return
    var tex = library.texture(full_path)
    if tex == null:
        return
    var size = Vector2(metadata["frame_size_px"][0], metadata["frame_size_px"][1])
    if pivot.x < 0:
        pivot = Vector2(metadata["pivot_px"][0], metadata["pivot_px"][1])
    index = clampi(index, 0, int(metadata["columns"]) - 1)
    row = clampi(row, 0, int(metadata["rows"]) - 1)
    draw_texture_rect_region(tex, Rect2(point - pivot * sprite_scale, size * sprite_scale), Rect2(Vector2(index, row) * size, size), color, false, true)

func _actor(enemy: Dictionary) -> void:
    var action: String
    var is_widowling = enemy.get("minion_kind", "") == "widowling"
    var category = "bosses" if enemy["boss"] or is_widowling else "enemies"
    var row = 0 if enemy["boss"] or is_widowling else DIRS.find(enemy["dir"])
    if enemy["boss"] or is_widowling:
        action = "attack" if enemy["attack_flash"] > 0 else "walk"
    else:
        action = enemy_defs[enemy["id"]]["move_animation"]
    var path = "sprites/" + category + "/" + enemy["id"] + "_" + action + ".png"
    var meta = library.record(ART + path)
    if meta.is_empty():
        return
    var frame = int(enemy["anim_time"] * 10) % int(meta["columns"])
    var tint = Color(1.8, 1.8, 1.8, 1) if enemy["flash"] > 0 else Color.WHITE
    if enemy["boss"] and enemy["flash"] <= 0:
        tint = [Color.WHITE, Color(1.15, .9, .55), Color(1.2, .5, .22), Color(1.35, .14, .12)][int(enemy.get("boss_phase", 0))]
    var cloak = float(enemy.get("cloak", 0.0))
    tint.a *= 1.0 - cloak
    if enemy["spawn"] > 0:
        tint.a = 0.45
    if tint.a <= .02:
        return
    _sprite("sprites/effects/ground_shadow.png", enemy["pos"] + Vector2(0, 9), 0, 0, Vector2(-1, -1), Color(1, 1, 1, tint.a))
    if is_widowling:
        draw_set_transform(enemy["pos"], 0.0, Vector2.ONE * .34)
        _sprite(path, Vector2.ZERO, frame, row, Vector2(-1, -1), tint)
        draw_set_transform(Vector2.ZERO)
    else:
        _sprite(path, enemy["pos"], frame, row, Vector2(-1, -1), tint)

func _draw_finisher_player(player_id: int, point: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2.ONE, defeated: bool = false) -> void:
    var safe_id = clampi(player_id, 0, players.size() - 1)
    var player_name = String(players[safe_id]["name"])
    draw_set_transform(point, rotation, scale)
    _sprite("sprites/players/" + player_name + ("_death.png" if defeated else "_idle.png"), Vector2.ZERO, int(game_time * 9.0) % (8 if defeated else 4), 0)
    draw_set_transform(Vector2.ZERO)

func _draw_finisher_enemy(enemy_id: String, point: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2.ONE) -> void:
    if not enemy_defs.has(enemy_id):
        enemy_id = "grunt"
    var action = String(enemy_defs[enemy_id]["move_animation"])
    var path = "sprites/enemies/" + enemy_id + "_" + action + ".png"
    var meta = library.record(ART + path)
    var frame = 0 if meta.is_empty() else int(game_time * 10.0) % int(meta["columns"])
    draw_set_transform(point, rotation, scale)
    _sprite(path, Vector2.ZERO, frame, 0)
    draw_set_transform(Vector2.ZERO)

func _draw_finisher_victim(point: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2.ONE) -> void:
    if String(cinematic_finisher["victim_kind"]) == "player":
        _draw_finisher_player(int(cinematic_finisher["victim_player"]), point, rotation, scale, true)
    else:
        _draw_finisher_enemy(String(cinematic_finisher["victim_enemy"]), point, rotation, scale)

func _draw_finisher_attacker(point: Vector2, rotation: float = 0.0, scale: Vector2 = Vector2.ONE) -> void:
    if String(cinematic_finisher["victim_kind"]) == "player":
        _draw_finisher_enemy(String(cinematic_finisher["attacker_enemy"]), point, rotation, scale)
    else:
        _draw_finisher_player(maxi(0, int(cinematic_finisher["attacker_player"])), point, rotation, scale)

func _draw_cinematic_finisher() -> void:
    if cinematic_finisher.is_empty():
        return
    var move = String(cinematic_finisher["move"])
    var time = float(cinematic_finisher["time"])
    var direction = float(cinematic_finisher["direction"])
    var center: Vector2 = cinematic_finisher["origin"]
    # Draw directly into the live arena at normal character scale. There is
    # deliberately no backdrop, border, title card, or progress bar.
    if move == "LADDER PLANK":
        var climb = smoothstep(0.0, 1.0, clampf(time / 1.05, 0.0, 1.0))
        var top_y = center.y - 34.0
        var actor_y = lerpf(center.y + 42.0, top_y, climb)
        draw_line(center + Vector2(-19, -45), center + Vector2(-19, 52), Color(.62, .72, .82), 3)
        draw_line(center + Vector2(19, -45), center + Vector2(19, 52), Color(.62, .72, .82), 3)
        for rung in range(-37, 48, 14):
            draw_line(center + Vector2(-19, rung), center + Vector2(19, rung), Color(.4, .52, .66), 2)
        draw_rect(Rect2(center + Vector2(-47, -49), Vector2(94, 7)), Color(.72, .4, .1))
        var fall = clampf((time - 1.2) / 1.25, 0.0, 1.0)
        var victim_pos = Vector2(center.x + 13 + direction * fall * 46.0, actor_y + fall * fall * 82.0)
        _draw_finisher_attacker(Vector2(center.x - 12, actor_y + 4), -direction * .08, Vector2.ONE * .34)
        _draw_finisher_victim(victim_pos, direction * fall * 5.0, Vector2.ONE * .34)
    elif move == "TRASH COMPACTOR":
        var crush = smoothstep(0.0, 1.0, clampf((time - .25) / 1.45, 0.0, 1.0))
        var gap = lerpf(51.0, 12.0, crush)
        draw_rect(Rect2(center.x - 62, center.y - 34, 62 - gap, 68), Color(.28, .34, .42))
        draw_rect(Rect2(center.x + gap, center.y - 34, 62 - gap, 68), Color(.28, .34, .42))
        _draw_finisher_victim(center + Vector2(0, 8), sin(time * 20.0) * crush * .08, Vector2(.36 - crush * .12, .36))
        _draw_finisher_attacker(center + Vector2(-54, 42), 0, Vector2.ONE * .32)
    elif move == "ROCKET CHAIR":
        var launch = smoothstep(0.0, 1.0, clampf((time - .3) / 1.55, 0.0, 1.0))
        var chair_pos = center + Vector2(direction * launch * 54.0, 20.0 - launch * launch * 76.0)
        for trail in range(3):
            draw_circle(chair_pos + Vector2(-direction * trail * 7.0, 15 + trail * 4.0), 6.0 - trail, Color(1, .3, .06, .7))
        draw_rect(Rect2(chair_pos + Vector2(-9, -3), Vector2(18, 22)), Color(.3, .42, .55))
        _draw_finisher_victim(chair_pos + Vector2(0, -6), direction * launch * 5.0, Vector2.ONE * .34)
        _draw_finisher_attacker(center + Vector2(-53, 43), 0, Vector2.ONE * .32)
    else:
        var train = smoothstep(0.0, 1.0, clampf((time - .3) / 1.65, 0.0, 1.0))
        var train_x = lerpf(center.x - 90.0, center.x + 90.0, train)
        draw_line(center + Vector2(-60, 29), center + Vector2(60, 29), Color(.4, .58, .72), 3)
        draw_line(center + Vector2(-60, 40), center + Vector2(60, 40), Color(.4, .58, .72), 3)
        _draw_finisher_victim(center + Vector2(0, 18), sin(time * 12.0) * .08, Vector2.ONE * .34)
        draw_rect(Rect2(train_x - 34, center.y - 12, 68, 43), Color(.04, .16, .25))
        draw_rect(Rect2(train_x - 34, center.y - 12, 68, 43), Color(.1, .9, 1), false, 2)
        _draw_finisher_attacker(center + Vector2(-54, 45), 0, Vector2.ONE * .31)

func _draw_cinematic_finisher_fullscreen_unused() -> void:
    if cinematic_finisher.is_empty():
        return
    var move = String(cinematic_finisher["move"])
    var time = float(cinematic_finisher["time"])
    var duration = float(cinematic_finisher["duration"])
    var direction = float(cinematic_finisher["direction"])
    draw_rect(Rect2(22, 142, 724, 824), Color(.008, .012, .028, .97))
    draw_rect(Rect2(31, 151, 706, 806), Color(.03, .045, .085), false, 5)
    for scanline in range(18):
        var scan_y = 168.0 + scanline * 43.0
        draw_line(Vector2(40, scan_y), Vector2(728, scan_y), Color(.08, .7, 1, .055), 2)
    _label("DREADWIRE DEATH CAM", Vector2(384, 194), 24, Color(.25, .92, 1), true)
    _label(move, Vector2(384, 232), 34, Color(1, .25, .62), true)

    if move == "LADDER PLANK":
        var climb = clampf(time / 2.35, 0.0, 1.0)
        climb = climb * climb * (3.0 - 2.0 * climb)
        var top_y = 330.0
        var actor_y = lerpf(864.0, top_y, climb)
        var ladder_left = 306.0
        var ladder_right = 462.0
        draw_line(Vector2(ladder_left, 300), Vector2(ladder_left, 895), Color(.72, .78, .86), 12)
        draw_line(Vector2(ladder_right, 300), Vector2(ladder_right, 895), Color(.72, .78, .86), 12)
        for rung_y in range(330, 890, 44):
            draw_line(Vector2(ladder_left, rung_y), Vector2(ladder_right, rung_y), Color(.48, .58, .7), 8)
        draw_rect(Rect2(180, 286, 408, 35), Color(.45, .24, .08))
        draw_rect(Rect2(180, 286, 408, 35), Color(1, .68, .18), false, 4)
        var victim_pos = Vector2(420, actor_y)
        var attacker_pos = Vector2(348, actor_y + 18)
        var victim_rotation = 0.0
        if time >= 2.65 and time < 3.65:
            victim_pos.x += direction * (24.0 + sin(time * 16.0) * 10.0)
            victim_rotation = direction * .24
            _label("SHOVE ONE!", Vector2(384, 410), 24, Color(1, .8, .2), true)
        elif time >= 3.65:
            var fall = clampf((time - 3.65) / 1.75, 0.0, 1.0)
            victim_pos.x += direction * (42.0 + fall * 185.0)
            victim_pos.y = top_y + fall * fall * 520.0
            victim_rotation = direction * fall * 8.0
            _label("SHOVE TWO!", Vector2(384, 410), 29, Color(1, .2, .22), true)
            if fall > .92:
                draw_set_transform(victim_pos + Vector2(0, 25), 0, Vector2(2.5, .32))
                draw_circle(Vector2.ZERO, 30, Color(1, .06, .13, .75))
                draw_set_transform(Vector2.ZERO)
                _label("SPLAT!", victim_pos + Vector2(0, -45), 38, Color(1, .12, .2), true)
        _draw_finisher_attacker(attacker_pos, -direction * .08)
        _draw_finisher_victim(victim_pos, victim_rotation, Vector2.ONE if time < 5.25 else Vector2(1.7, .35))
    elif move == "TRASH COMPACTOR":
        var crush = clampf((time - 1.0) / 2.8, 0.0, 1.0)
        var left_wall = lerpf(85.0, 322.0, crush)
        var right_wall = lerpf(683.0, 446.0, crush)
        draw_rect(Rect2(left_wall - 105, 315, 105, 470), Color(.2, .25, .31))
        draw_rect(Rect2(right_wall, 315, 105, 470), Color(.2, .25, .31))
        for hazard_y in range(350, 760, 58):
            _label("⚠", Vector2(left_wall - 50, hazard_y), 28, Color(1, .72, .08), true)
            _label("⚠", Vector2(right_wall + 50, hazard_y), 28, Color(1, .72, .08), true)
        _draw_finisher_attacker(Vector2(220, 790), 0, Vector2.ONE)
        _draw_finisher_victim(Vector2(384, 590), sin(time * 18.0) * crush * .12, Vector2(1.0 - crush * .45, 1.0 + crush * .15))
        if crush > .9: _label("COMPACTED!", Vector2(384, 845), 35, Color(1, .34, .12), true)
    elif move == "ROCKET CHAIR":
        var launch = clampf((time - 1.15) / 2.8, 0.0, 1.0)
        var chair_pos = Vector2(410 + direction * launch * 175.0, 710 - launch * launch * 520.0)
        for trail in range(9):
            var trail_pos = chair_pos + Vector2(-direction * trail * 19.0, 34 + trail * 8.0)
            draw_circle(trail_pos, 18.0 - trail, Color(1, .25 + trail * .05, .05, .7 - trail * .06))
        draw_rect(Rect2(chair_pos + Vector2(-28, -12), Vector2(56, 64)), Color(.28, .38, .5))
        _draw_finisher_victim(chair_pos + Vector2(0, -20), direction * launch * 7.0)
        _draw_finisher_attacker(Vector2(245, 800), 0, Vector2.ONE)
        _label("EJECT! EJECT!", Vector2(384, 860), 32, Color(1, .6, .12), true)
    else: # NEON TRAIN
        var train = clampf((time - 1.45) / 2.5, 0.0, 1.0)
        var train_x = lerpf(-270.0, 1030.0, train)
        draw_line(Vector2(70, 720), Vector2(698, 720), Color(.35, .55, .7), 9)
        draw_line(Vector2(70, 770), Vector2(698, 770), Color(.35, .55, .7), 9)
        for tie_x in range(80, 700, 52):
            draw_line(Vector2(tie_x, 700), Vector2(tie_x, 790), Color(.35, .18, .08), 12)
        _draw_finisher_victim(Vector2(384, 680), sin(time * 11.0) * .08)
        _draw_finisher_attacker(Vector2(250, 860), 0, Vector2.ONE)
        draw_rect(Rect2(train_x - 170, 500, 340, 230), Color(.04, .12, .2))
        draw_rect(Rect2(train_x - 170, 500, 340, 230), Color(.1, .9, 1), false, 7)
        draw_circle(Vector2(train_x - 105, 735), 42, Color(.9, .18, .55))
        draw_circle(Vector2(train_x + 105, 735), 42, Color(.9, .18, .55))
        _label("NEON EXPRESS", Vector2(train_x, 610), 25, Color(1, .28, .7), true)
        if train > .55: _label("NEXT STOP: OBLIVION", Vector2(384, 850), 28, Color(.35, 1, .85), true)
    var remaining = maxf(0.0, duration - time)
    draw_rect(Rect2(70, 925, 628 * (remaining / duration), 7), Color(1, .25, .68))

func _draw() -> void:
    if players.is_empty() or font == null:
        return
    if phase == "corridor":
        _draw_corridor_stage()
    else:
        _draw_arena_floor()
        var door_state = "warning" if phase == "warning" else "open" if phase == "route" or (phase == "combat" and door_open_timer > 0.0) else "closed"
        for point in [Vector2(384, 150), Vector2(384, 980), Vector2(38, 555), Vector2(730, 555)]:
            _sprite("tilesets/arena/door_" + door_state + ".png", point, int(game_time * 8) % (4 if door_state == "warning" else 1))
    if phase == "entrance":
        _draw_backstage_entrance()
    if phase == "route":
        var pulse = .65 + sin(game_time * 6.0) * .3
        var arrow_color = Color(1, .78, .12, pulse)
        _label("CHOOSE YOUR NEXT ROOM", Vector2(384, 230), 25, arrow_color, true)
        _label("▲", Vector2(384, 205), 38, arrow_color, true)
        _label("▼", Vector2(384, 920), 38, arrow_color, true)
        _label("◀", Vector2(82, 565), 38, arrow_color, true)
        _label("▶", Vector2(686, 565), 38, arrow_color, true)
        _draw_route_map()
    elif phase == "clear_hold":
        _label("ROUND CLEAR", Vector2(384, 420), 31, Color(.35, 1, .62), true)
        _label("NEXT ROUND IN %d" % maxi(1, ceili(phase_timer)), Vector2(384, 466), 22, Color(1, .82, .22), true)
    _draw_game_entities()
    _draw_cinematic_finisher()
    if phase == "turn":
        _draw_screen_turn()

func _draw_arena_floor() -> void:
    var tile = library.texture(ART + "tilesets/arena/arena_tiles.png")
    if tile == null: return
    var removed := 0
    if phase == "floor_drop": removed = int(floor_transition * floor_order.size())
    elif phase == "floor_build": removed = floor_order.size() - int(floor_transition * floor_order.size())
    for y in range(14):
        for x in range(12):
            var cell = Vector2i(x, y)
            var rank = int(floor_rank.get(cell, floor_order.size()))
            var index = 10 if y == 0 else 11 if y == 13 else 12 if x == 0 else 13 if x == 11 else 2 if (x + y) % 4 == 0 else 0
            var source = Rect2((index % 8) * 64, int(index / 8) * 64, 64, 64)
            var erosion_missing = erosion_cells.has(cell)
            if phase == "floor_restore" and erosion_missing:
                var erosion_rank = erosion_order.find(cell)
                var restored = int(floor_transition * erosion_index)
                erosion_missing = erosion_rank < erosion_index - restored
            if rank >= removed and not erosion_missing:
                var tile_rect = Rect2(x * 64, 128 + y * 64, 64, 64)
                draw_texture_rect_region(tile, tile_rect, source)
                if x > 0 and x < 11 and y > 0 and y < 13:
                    _draw_matrix_floor_tile(cell, tile_rect)
            elif phase == "floor_drop" and rank >= removed - 13:
                var age = clampf((float(removed - rank)) / 13.0, 0.0, 1.0)
                var center = Vector2(x * 64 + 32, 160 + y * 64 + age * age * 360)
                draw_set_transform(center, (x % 3 - 1) * age * .42, Vector2.ONE * (1.0 - age * .18))
                draw_texture_rect_region(tile, Rect2(-32, -32, 64, 64), source, Color(1, 1.0 - age * .35, 1.0 - age * .55, 1.0 - age * .35))
                draw_set_transform(Vector2.ZERO)
    if phase in ["floor_drop", "floor_build"]:
        var pct = int((floor_transition if phase == "floor_drop" else 1.0 - floor_transition) * 100.0)
        _label("TETRIS FLOOR SHIFT %03d%%" % pct, Vector2(384, 200), 18, Color(1, .7, .18), true)
    if phase == "floor_drop":
        var danger_y = 185.0 + floor_transition * 700.0
        var pulse = .65 + sin(game_time * 14.0) * .3
        draw_rect(Rect2(55, danger_y - 18, 658, 36), Color(1, .05, .35, .08 + pulse * .1))
        draw_line(Vector2(55, danger_y), Vector2(713, danger_y), Color(1, .1, .48, pulse), 7)
        draw_line(Vector2(55, danger_y + 7), Vector2(713, danger_y + 7), Color(.15, .9, 1, pulse), 2)
        draw_rect(Rect2(55, 875, 658, 70), Color(.1, 1, .55, .08 + pulse * .08))
        draw_rect(Rect2(55, 875, 658, 70), Color(.2, 1, .62, pulse), false, 3)
        _label("RUN TO EXTRACTION", Vector2(384, 920), 18, Color(.55, 1, .76), true)
    if erosion_active and phase == "combat":
        for lookahead in range(4):
            var next_index = erosion_index + lookahead
            if next_index >= erosion_order.size(): break
            var warning_cell = erosion_order[next_index]
            var warning_alpha = .62 - lookahead * .12 + sin(game_time * 10) * .14
            draw_rect(Rect2(warning_cell.x * 64 + 4, 128 + warning_cell.y * 64 + 4, 56, 56), Color(1, .04, .18, warning_alpha), false, 5)
        _label("FLOOR COLLAPSE — KEEP MOVING!", Vector2(384, 202), 19, Color(1, .2, .38), true)
    elif phase == "floor_restore":
        _label("STAGE REBUILDING", Vector2(384, 202), 19, Color(.35, 1, .72), true)
    _draw_floor_atmosphere()
    _draw_floor_trails()

func _draw_floor_atmosphere() -> void:
    var pulse = .5 + sin(game_time * 1.7) * .5
    match floor_in_room:
        2, 7:
            draw_rect(Rect2(55, 190, 658, 750), Color(.02, .01, .08, .10 + pulse * .10))
            _label("NIGHT SHOOT", Vector2(384, 236), 14, Color(.45, .5, 1, .6), true)
        4, 9:
            var scan_y = 220.0 + fmod(game_time * 115.0, 650.0)
            draw_rect(Rect2(55, scan_y - 28, 658, 56), Color(.05, 1, .72, .035))
            draw_line(Vector2(55, scan_y), Vector2(713, scan_y), Color(.15, 1, .8, .35), 2)
            _label("SCANNER FLOOR", Vector2(384, 236), 14, Color(.25, 1, .82, .6), true)
        6, 10:
            var strobe = .12 if int(game_time * 2.0) % 2 == 0 else .025
            draw_rect(Rect2(55, 190, 658, 750), Color(1, .04, .14, strobe))
            _label("RED ALERT", Vector2(384, 236), 14, Color(1, .25, .3, .75), true)

func _draw_floor_trails() -> void:
    for player in _active_players():
        var trail: Array = player["floor_trail"]
        if trail.size() < 2:
            continue
        var points := PackedVector2Array()
        for cell in trail:
            points.append(Vector2(cell.x * 64 + 32, 128 + cell.y * 64 + 32))
        var color = Color(.1, .95, 1) if int(player["id"]) == 0 else Color(1, .15, .76)
        var trail_life = 5.5 + float(player["lightning_level"])
        var life_alpha = clampf(1.0 - (game_time - float(player["trail_last_step"])) / trail_life, .18, 1.0)
        # A faint breadcrumb gesture replaces the old screen-filling cable.
        for point in points:
            draw_circle(point, 3.0, Color(color.r, color.g, color.b, life_alpha * .55))
        draw_polyline(points, Color(color.r, color.g, color.b, life_alpha * .28), 1.5, true)
        var segment = posmod(int(game_time * 8.0), points.size() - 1)
        var spark = points[segment].lerp(points[segment + 1], fmod(game_time * 8.0, 1.0))
        draw_circle(spark, 3, Color(1, 1, 1, .65))
    for bomb in floor_trail_bombs:
        var points: PackedVector2Array = bomb["points"]
        var owner = int(bomb["owner"])
        var color = Color(.1, .95, 1) if owner == 0 else Color(1, .15, .76)
        var remaining = maxf(0.0, float(bomb["fuse"]) - float(bomb["time"]))
        var total_hp := 0.0
        var total_max := 0.0
        for i in range(4):
            total_hp += maxf(0.0, float(bomb["wall_hp"][i]))
            total_max += float(bomb["wall_max_hp"][i])
        var health_ratio = clampf(total_hp / maxf(1.0, total_max), 0.0, 1.0)
        var flicker = health_ratio if health_ratio > .3 else health_ratio * (.35 + abs(sin(game_time * 18.0)) * .65)
        var pulse = .65 + abs(sin(game_time * 7.0)) * .35
        draw_colored_polygon(points, Color(color.r, color.g, color.b, .018 + flicker * .025))
        var scan_y = lerpf(points[0].y, points[2].y, fmod(game_time * .7, 1.0))
        draw_line(Vector2(points[0].x, scan_y), Vector2(points[1].x, scan_y), Color(color.r, color.g, color.b, .08 * health_ratio), 2)
        # Draw all four sides explicitly. PackedVector2Array polylines do not
        # close themselves, which was why the cage always looked three-sided.
        for i in range(4):
            var side_ratio = clampf(float(bomb["wall_hp"][i]) / float(bomb["wall_max_hp"][i]), 0.0, 1.0)
            if side_ratio > 0.0:
                for glow in range(4, 0, -1):
                    draw_line(points[i], points[(i + 1) % 4], Color(color.r, color.g, color.b, .025 * glow * side_ratio), 3.0 + glow * 2.2, true)
                draw_line(points[i], points[(i + 1) % 4], Color(color.r * pulse, color.g * pulse, color.b * pulse, .32 + side_ratio * .68), 2.5 + side_ratio, true)
            else:
                var middle := points[i].lerp(points[(i + 1) % 4], .5)
                draw_line(points[i], points[i].lerp(middle, .55), Color(color.r, color.g, color.b, .16), 2, true)
                draw_line(points[(i + 1) % 4], points[(i + 1) % 4].lerp(middle, .55), Color(color.r, color.g, color.b, .16), 2, true)
        for corner in points:
            draw_circle(corner, 8.0 + pulse * 2.0, Color(color.r, color.g, color.b, .12 * health_ratio))
            draw_circle(corner, 3.5, Color(1, 1, 1, .7 * health_ratio))
        var trapped_count: int = bomb["trapped_uids"].size()
        _label("RICOCHET %d%% • %d TRAPPED • %.1fs" % [roundi(health_ratio * 100.0), trapped_count, remaining], bomb["center"] + Vector2(0, 7), 12, Color(1, 1, 1, .82), true)

func _draw_matrix_floor_tile(cell: Vector2i, rect: Rect2) -> void:
    var room_palette = int(wave_index / 11) % 4
    var base_colors = [Color(.08, .88, 1), Color(.2, 1, .48), Color(1, .54, .08), Color(.5, .38, 1)]
    var accent_colors = [Color(1, .1, .72), Color(.12, .7, 1), Color(1, .12, .35), Color(.1, 1, .85)]
    var base: Color = base_colors[room_palette]
    var accent: Color = accent_colors[room_palette]
    var state = int(floor_tile_states.get(cell, 0))
    var paint = base if state == 0 else Color(.05, .9, 1) if state == 1 else Color(1, .14, .76)
    var age = game_time - float(floor_tile_changed_at.get(cell, -99.0))
    var impact = clampf(1.0 - age / .75, 0.0, 1.0)
    var inset = rect.grow(-4)
    # Keep the base pass to two cheap rectangles per tile. The previous version
    # used several wide translucent outlines and animated primitives on every
    # square, which saturated the Pi's GLES draw thread.
    draw_rect(inset, Color(paint.r, paint.g, paint.b, .045 if state == 0 else .15))
    draw_rect(inset, Color(paint.r, paint.g, paint.b, .14 if state == 0 else .72), false, 2)
    var center = rect.get_center()
    var pattern = posmod(cell.x * 3 + cell.y * 5 + wave_index, 6)
    var dim = Color(accent.r, accent.g, accent.b, .19)
    # Only one third of untouched cells carries detailed matrix glyphs. Painted
    # cells always show one, preserving the DWC look at a fraction of the draw
    # calls and making the Q*bert state much easier to read.
    if state == 0 and posmod(cell.x + cell.y * 2 + wave_index, 3) != 0:
        return
    if pattern in [0, 3]:
        draw_line(inset.position + Vector2(7, 7), inset.end - Vector2(7, 7), dim, 2)
        draw_circle(center, 4, Color(paint.r, paint.g, paint.b, .48))
    elif pattern in [1, 4]:
        var diamond = PackedVector2Array([center + Vector2(0, -15), center + Vector2(15, 0), center + Vector2(0, 15), center + Vector2(-15, 0), center + Vector2(0, -15)])
        draw_polyline(diamond, dim, 2)
    else:
        draw_line(center + Vector2(-18, 0), center + Vector2(18, 0), dim, 2)
        draw_line(center + Vector2(0, -18), center + Vector2(0, 18), dim, 2)
    if impact > 0:
        draw_rect(inset.grow(impact * 6.0), Color(paint.r, paint.g, paint.b, impact * .7), false, 3)

func _draw_corridor_stage() -> void:
    draw_rect(Rect2(0, 128, 768, 896), Color(.018, .025, .05))
    var scroll = fmod(corridor_progress, 128.0)
    for i in range(-1, 8):
        var x = i * 128.0 - scroll * corridor_direction
        draw_rect(Rect2(x, 200, 112, 700), Color(.035, .065, .095))
        draw_line(Vector2(x, 200), Vector2(x, 900), Color(.1, .42, .55), 3)
        draw_line(Vector2(x + 112, 200), Vector2(x + 112, 900), Color(.08, .22, .32), 2)
    draw_colored_polygon(PackedVector2Array([Vector2(0, 900), Vector2(768, 900), Vector2(768, 1024), Vector2(0, 1024)]), Color(.035, .04, .06))
    for hole in range(4):
        var hx = fmod(hole * 247.0 - corridor_progress * corridor_direction, 980.0) - 100.0
        draw_circle(Vector2(hx, 335 + (hole % 2) * 330), 54, Color(.005, .008, .012))
        draw_arc(Vector2(hx, 335 + (hole % 2) * 330), 56, 0, TAU, 32, Color(1, .22, .14), 5)
    var direction_text = "RIGHT" if corridor_direction > 0 else "LEFT"
    _label("CONNECTOR STAGE • PUSH " + direction_text, Vector2(384, 180), 22, Color(.25, .9, 1), true)
    draw_rect(Rect2(104, 214, 560, 10), Color(.04, .1, .16))
    draw_rect(Rect2(104, 214, 560 * corridor_progress / CORRIDOR_LENGTH, 10), Color(1, .32, .72))

func _draw_screen_turn() -> void:
    # A full-room cube roll: the current arena compresses into perspective,
    # exposes the illuminated outer wall, then the next top-down room opens.
    var t = smoothstep(0.0, 1.0, floor_transition)
    var fold = sin(t * PI)
    var from_left = corridor_direction < 0
    var hinge_x = 0.0 if from_left else 768.0
    var moving_edge = lerpf(768.0 if from_left else 0.0, hinge_x, t)
    var top_inset = fold * 118.0
    var bottom_inset = fold * 205.0
    var wall = PackedVector2Array([
        Vector2(moving_edge, 128 + top_inset), Vector2(hinge_x, 128),
        Vector2(hinge_x, 1024), Vector2(moving_edge, 1024 - bottom_inset)])
    draw_colored_polygon(wall, Color(.018, .035, .075, .96))
    # Perspective circuitry makes the revealed outer wall read as a physical
    # rotating set instead of a flat screen wipe.
    for stripe in range(9):
        var amount = stripe / 8.0
        var top = Vector2(lerpf(moving_edge, hinge_x, amount), lerpf(128 + top_inset, 128, amount))
        var bottom = Vector2(lerpf(moving_edge, hinge_x, amount), lerpf(1024 - bottom_inset, 1024, amount))
        draw_line(top, bottom, Color(.08, .7, 1, .2 + fold * .42), 2)
    for row in range(7):
        var amount = row / 6.0
        var a = Vector2(moving_edge, lerpf(128 + top_inset, 1024 - bottom_inset, amount))
        var b = Vector2(hinge_x, lerpf(128, 1024, amount))
        draw_line(a, b, Color(1, .12, .68, .12 + fold * .32), 2)
    draw_line(Vector2(moving_edge, 128 + top_inset), Vector2(moving_edge, 1024 - bottom_inset), Color(.25, .95, 1, .85), 8)
    draw_circle(Vector2(lerpf(moving_edge, hinge_x, .55), 555), 42 + fold * 30, Color(.05, .8, 1, .08))
    draw_arc(Vector2(lerpf(moving_edge, hinge_x, .55), 555), 42 + fold * 30, -PI * .75, PI * .75, 32, Color(1, .2, .72, fold), 5)
    var route_label = pending_route if not pending_route.is_empty() else ("EAST" if corridor_direction > 0 else "WEST")
    _label("ROUTE LOCKED: " + route_label, Vector2(384, 500), 29, Color(1, .75, .2, maxf(.25, fold)), true)
    _label("NEXT ARENA", Vector2(384, 548), 22, Color(.25, .92, 1, maxf(.25, fold)), true)

func _draw_backstage_entrance() -> void:
    # A warm television-studio backstage instead of abstract guide beams.
    draw_rect(Rect2(0, 128, 768, 896), Color(.018, .012, .028, .97))
    draw_rect(Rect2(0, 128, 768, 150), Color(.07, .025, .055))
    draw_rect(Rect2(0, 278, 768, 480), Color(.055, .045, .07))
    # Acoustic wall panels and brass trim.
    for column in range(8):
        var panel = Rect2(18 + column * 94, 305, 76, 390)
        draw_rect(panel, Color(.075, .06, .09))
        draw_rect(panel, Color(.25, .16, .23), false, 3)
    draw_line(Vector2(0, 282), Vector2(768, 282), Color(.88, .58, .18), 5)
    draw_line(Vector2(0, 704), Vector2(768, 704), Color(.88, .58, .18), 5)
    # Central stage portal with red velvet curtains.
    draw_rect(Rect2(262, 310, 244, 390), Color(.008, .01, .018))
    draw_rect(Rect2(252, 300, 264, 410), Color(.9, .62, .18), false, 7)
    for fold in range(6):
        var fold_x = 258.0 + fold * 20.0
        draw_colored_polygon(PackedVector2Array([
            Vector2(fold_x, 305), Vector2(fold_x + 22, 305),
            Vector2(fold_x + 13, 610), Vector2(fold_x - 3, 610)]),
            Color(.34 + (fold % 2) * .1, .015, .065))
        var right_x = 488.0 - fold * 20.0
        draw_colored_polygon(PackedVector2Array([
            Vector2(right_x, 305), Vector2(right_x + 22, 305),
            Vector2(right_x + 25, 610), Vector2(right_x + 9, 610)]),
            Color(.34 + (fold % 2) * .1, .015, .065))
    draw_colored_polygon(PackedVector2Array([
        Vector2(260, 305), Vector2(508, 305), Vector2(476, 388),
        Vector2(384, 350), Vector2(292, 388)]), Color(.48, .02, .09))
    # Dressing-room doors for each contestant.
    for side in range(2):
        var door_x = 48.0 if side == 0 else 590.0
        var accent = Color(.08, .75, 1) if side == 0 else Color(1, .55, .12)
        draw_rect(Rect2(door_x, 390, 130, 270), Color(.025, .03, .055))
        draw_rect(Rect2(door_x, 390, 130, 270), accent, false, 4)
        draw_circle(Vector2(door_x + (112 if side == 0 else 18), 530), 7, Color(1, .78, .22))
        _label("P%d" % (side + 1), Vector2(door_x + 65, 445), 28, accent, true)
        _label("READY", Vector2(door_x + 65, 480), 16, Color(.9, .88, .8), true)
    # Carpet and footlights lead naturally to the stage, without laser lines.
    draw_colored_polygon(PackedVector2Array([
        Vector2(190, 1024), Vector2(578, 1024), Vector2(468, 650), Vector2(300, 650)]),
        Color(.24, .018, .06))
    draw_colored_polygon(PackedVector2Array([
        Vector2(238, 1024), Vector2(530, 1024), Vector2(450, 650), Vector2(318, 650)]),
        Color(.38, .025, .075))
    for bulb in range(9):
        var bx = 96.0 + bulb * 72.0
        var glow = .72 + sin(entrance_elapsed * 5.0 + bulb) * .22
        draw_circle(Vector2(bx, 738), 10, Color(1, .64, .16, glow))
        draw_circle(Vector2(bx, 738), 4, Color(1, .96, .7))
    # Soft moving spotlights and studio sign.
    var sweep = sin(entrance_elapsed * .7) * 55.0
    draw_colored_polygon(PackedVector2Array([Vector2(120 + sweep, 278), Vector2(250 + sweep, 278), Vector2(415, 720), Vector2(330, 720)]), Color(1, .8, .45, .075))
    draw_colored_polygon(PackedVector2Array([Vector2(518 - sweep, 278), Vector2(648 - sweep, 278), Vector2(438, 720), Vector2(353, 720)]), Color(.35, .75, 1, .075))
    draw_rect(Rect2(152, 158, 464, 92), Color(.018, .02, .04))
    draw_rect(Rect2(152, 158, 464, 92), Color(1, .63, .16), false, 4)
    _label("DREADWIRE TV STUDIOS", Vector2(384, 202), 29, Color(1, .82, .3), true)
    _label("LIVE • ARENA BRAWL", Vector2(384, 232), 16, Color(.65, .88, 1), true)

func _draw_route_map() -> void:
    var panel = Rect2(218, 260, 332, 198)
    var center = panel.get_center() + Vector2(0, 10)
    var scale = Vector2(39, 31)
    draw_rect(panel, Color(.008, .015, .035, .94))
    draw_rect(panel, Color(.18, .72, .9), false, 2)
    _label("LIVE STUDIO MAP", Vector2(384, 286), 15, Color(.6, .9, 1), true)
    for gx in range(-3, 4):
        for gy in range(-2, 3):
            var dot = center + Vector2(gx * scale.x, gy * scale.y)
            draw_circle(dot, 2, Color(.13, .25, .35))
    for i in range(1, map_path.size()):
        var a = center + Vector2(map_path[i - 1] - map_position) * scale
        var b = center + Vector2(map_path[i] - map_position) * scale
        draw_line(a, b, Color(.3, .72, .92), 4)
    for key in map_visited:
        var parts = String(key).split(",")
        var room = Vector2i(int(parts[0]), int(parts[1]))
        var point = center + Vector2(room - map_position) * scale
        if panel.grow(-12).has_point(point):
            var hidden = map_hidden_found.has(key)
            draw_circle(point, 8 if hidden else 6, Color(1, .25, .75) if hidden else Color(1, .65, .14))
            if hidden: _label("★", point + Vector2(0, 5), 13, Color.WHITE, true)
    draw_circle(center, 11 + sin(game_time * 5) * 2, Color(.2, 1, .55), false, 3)
    _label("YOU", center + Vector2(0, -14), 11, Color(.4, 1, .65), true)
    _label("ROOM FLOOR %d/%d • BOSS IN %d" % [floor_in_room, FLOORS_PER_ROOM, maxi(1, 20 - wave_index)], Vector2(384, 444), 13, Color(1, .72, .2), true)

func _draw_game_entities() -> void:
    for hazard in hazards:
        var age: float = hazard["time"]
        var state = "warning" if age < 0 else "active" if fmod(age, 4.5) < 1.2 else "cooldown"
        _sprite("sprites/hazards/" + hazard["id"] + "_" + state + ".png", hazard["pos"], int(game_time * 8) % 4)
        if state == "warning":
            draw_arc(hazard["pos"], 45, 0, TAU, 28, Color(1, .65, .2, .65), 2)
        if state == "active" and hazard["id"] == "rotating_laser":
            var ray = Vector2.from_angle(age * 1.9) * 135
            draw_line(hazard["pos"] - ray, hazard["pos"] + ray, Color(.95, .2, .7), 5)
            draw_line(hazard["pos"] - ray, hazard["pos"] + ray, Color.WHITE, 1)
    for drop in drops:
        if drop["kind"] == "blessing_ring":
            var owner = int(drop["owner"])
            var ring_color = Color(.1, .9, 1) if owner == 0 else Color(1, .16, .72)
            var pulse = 1.0 + sin(game_time * 7.0) * .12
            for glow in range(4, 0, -1):
                var glow_color = ring_color
                glow_color.a = .05 * glow
                draw_arc(drop["pos"], (29 + glow * 4) * pulse, 0, TAU, 40, glow_color, 3 + glow)
            draw_arc(drop["pos"], 29 * pulse, 0, TAU, 40, ring_color, 5)
            draw_circle(drop["pos"], 18, Color(ring_color.r, ring_color.g, ring_color.b, .12))
            _label("P%d ONLY" % (owner + 1), drop["pos"] + Vector2(0, -42), 13, ring_color, true)
            _label("BLESSING", drop["pos"] + Vector2(0, 50), 11, Color.WHITE, true)
        elif drop["kind"] == "weapon":
            _sprite("sprites/pickups/weapon_" + drop["id"] + ".png", drop["pos"])
            var weapon_label = "ORBIT DRONE UPGRADE" if drop["id"] == "orbit_drone" else String(weapons[drop["id"]]["display_name"])
            _label(weapon_label, drop["pos"] + Vector2(0, -34), 12, Color(.35, .92, 1), true)
        else:
            if drop["id"] == "bomb":
                draw_circle(drop["pos"], 15 + sin(game_time * 7) * 2, Color(.08, .1, .14))
                draw_circle(drop["pos"] + Vector2(5, -12), 4, Color(1, .48, .12))
                _label("BOMB +1", drop["pos"] + Vector2(0, -30), 12, Color(1, .48, .15), true)
            elif drop["id"] == "reflect_shield":
                draw_arc(drop["pos"], 18 + sin(game_time * 6) * 3, 0, TAU, 32, Color(1, .18, .76), 5)
                draw_arc(drop["pos"], 11, 0, TAU, 24, Color(.5, .85, 1), 2)
                _label("REFLECT SHIELD", drop["pos"] + Vector2(0, -32), 12, Color(1, .28, .82), true)
            elif drop["id"] == "lightning_bolt":
                var pulse = .75 + sin(game_time * 11.0) * .25
                var bolt = PackedVector2Array([drop["pos"] + Vector2(5, -24), drop["pos"] + Vector2(-12, 2), drop["pos"] + Vector2(-2, 2), drop["pos"] + Vector2(-8, 25), drop["pos"] + Vector2(16, -7), drop["pos"] + Vector2(5, -7)])
                draw_colored_polygon(bolt, Color(1, .92, .18, pulse))
                draw_polyline(bolt, Color(.35, .92, 1, pulse), 4, true)
                _label("LIGHTNING UPGRADE", drop["pos"] + Vector2(0, -34), 12, Color(.45, .95, 1), true)
            elif drop["id"] == "combat_clone":
                var clone_color = Color(.25, 1, .92, .9)
                var clone_pulse = 16.0 + sin(game_time * 9.0) * 3.0
                draw_circle(drop["pos"], clone_pulse, Color(.12, .8, .75, .16))
                draw_arc(drop["pos"], clone_pulse + 5.0, 0, TAU, 28, clone_color, 3)
                _label("×2", drop["pos"] + Vector2(0, 6), 18, Color.WHITE, true)
                _label("COMBAT CLONE", drop["pos"] + Vector2(0, -34), 12, clone_color, true)
            else:
                _sprite("sprites/pickups/" + drop["id"] + ".png", drop["pos"], int(game_time * 10) % 8)
                _label(String(drop["id"]).replace("_", " ").to_upper(), drop["pos"] + Vector2(0, -32), 11, Color(1, .8, .3), true)
        if float(drop["life"]) < 5.0 and int(game_time * 8) % 2 == 0:
            draw_arc(drop["pos"], 25, 0, TAU, 24, Color(1, .2, .25, .7), 2)
    for bomb in player_bombs:
        var pulse = 1.0 + sin(float(bomb["time"]) * 28.0) * .18
        draw_circle(bomb["pos"], 18 * pulse, Color(.035, .04, .06))
        draw_arc(bomb["pos"], 22 * pulse, 0, TAU, 24, Color(1, .18, .08), 4)
        draw_circle(bomb["pos"] + Vector2(7, -14), 4 + pulse, Color(1, .8, .2))
    var sorted = enemies.duplicate()
    sorted.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
    for enemy in sorted:
        _actor(enemy)
    for clone in player_clones:
        var owner_id = int(clone["owner"])
        if owner_id < 0 or owner_id >= players.size():
            continue
        var owner: Dictionary = players[owner_id]
        var clone_color = Color(.2, 1, .92, .72) if owner_id == 0 else Color(1, .35, .82, .72)
        var clone_dir = _direction(clone["aim"])
        var frame = int(float(clone["anim_time"]) * 11.0) % 4
        _sprite("sprites/effects/ground_shadow.png", clone["pos"] + Vector2(0, 9), 0, 0, Vector2(-1, -1), Color(0.2, 1, .9, .45), .85)
        draw_arc(clone["pos"] + Vector2(0, 5), 25.0 + sin(game_time * 10.0) * 2.0, 0, TAU, 32, clone_color, 3)
        _sprite("sprites/players/" + String(owner["name"]) + "_fire.png", clone["pos"], frame, DIRS.find(clone_dir), Vector2(-1, -1), clone_color, .86)
        _label("CLONE %.1f" % float(clone["time"]), clone["pos"] + Vector2(0, -43), 11, clone_color, true)
    for p in players:
        if p["id"] == 1 and not p2_enabled:
            continue
        if p["lives"] <= 0:
            continue
        var dead = p["respawn"] > 0
        var action = "death" if dead else "run" if p["move"].length() > .05 else "fire" if p["fire_held"] else "idle"
        var frames = 8 if dead else 6 if action == "run" else 4
        var frame = mini(7, int((2.0 - p["respawn"]) * 10)) if dead else int(p["anim_time"] * (12 if action == "run" else 8 if action == "fire" else 6)) % frames
        var tint = Color.WHITE
        if p["invuln"] > 0 and int(game_time * 15) % 2 == 0:
            tint.a = .45
        _sprite("sprites/effects/ground_shadow.png", p["pos"] + Vector2(0, 9))
        var locator_color = Color(.08, .85, 1, .92) if p["id"] == 0 else Color(1, .72, .08, .92)
        var locator_radius = 30.0 + sin(game_time * 5.0 + p["id"] * 1.7) * 3.0
        for glow_step in range(4, 0, -1):
            var glow_color = locator_color
            glow_color.a = .055 * glow_step
            draw_arc(p["pos"] + Vector2(0, 5), locator_radius + glow_step * 2.8, game_time * .7, TAU + game_time * .7, 48, glow_color, 2.0 + glow_step)
        draw_arc(p["pos"] + Vector2(0, 5), locator_radius, game_time * 1.8, game_time * 1.8 + PI * 1.42, 40, locator_color, 3)
        draw_arc(p["pos"] + Vector2(0, 5), locator_radius, game_time * 1.8 + PI, game_time * 1.8 + PI * 1.58, 20, Color.WHITE, 2)
        _label("P%d" % (p["id"] + 1), p["pos"] + Vector2(0, -48), 17, locator_color, true)
        if p["buffs"].has("blessing_stealth"):
            var blessing_left = float(p["buffs"]["blessing_stealth"])
            var blessing_alpha = .35 + sin(game_time * 14.0) * .14
            draw_colored_polygon(PackedVector2Array([p["pos"] + Vector2(-38, -320), p["pos"] + Vector2(38, -320), p["pos"] + Vector2(58, 35), p["pos"] + Vector2(-58, 35)]), Color(locator_color.r, locator_color.g, locator_color.b, blessing_alpha * .22))
            draw_arc(p["pos"] + Vector2(0, 5), 42 + sin(game_time * 9.0) * 5, 0, TAU, 48, Color(1, 1, .7, .9), 4)
            _label("BLESSED %.1f" % blessing_left, p["pos"] + Vector2(0, -68), 14, Color(1, 1, .65), true)
        if dead:
            var death_scale = Vector2.ONE
            var death_rotation = 0.0
            var death_offset = Vector2.ZERO
            match String(p["death_move"]):
                "CRUSHED": death_scale = Vector2(1.45, maxf(.12, 1.0 - p["death_progress"] * .7))
                "SHRINK + STOMP": death_scale = Vector2.ONE * maxf(.12, 1.0 - p["death_progress"] * .48)
                "VAPORIZED": tint = Color(1.5, .35, 1.8, maxf(.08, 1.0 - p["death_progress"] * .5))
                "LAUNCHED":
                    death_offset.y = -p["death_progress"] * 150.0
                    death_rotation = p["death_progress"] * 7.0
                "FROZEN SHATTER": tint = Color(.35, .8, 1.8, maxf(.1, 1.0 - p["death_progress"] * .4))
                "FLATTENED": death_scale = Vector2(1.8, maxf(.08, 1.0 - p["death_progress"] * .85))
                "ELECTROCUTED":
                    death_offset = Vector2(randf_range(-5, 5), randf_range(-4, 4))
                    tint = Color(.6, .9, 1.7)
                "CAMERA SMASH":
                    var rush: float = minf(1.0, float(p["death_progress"]) * .62)
                    death_scale = Vector2.ONE * (1.0 + rush * rush * 7.5)
                    death_offset = (Vector2(384, 520) - p["pos"]) * rush
                    death_rotation = sin(p["death_progress"] * 13.0) * .18
                    tint.a = maxf(.05, 1.0 - maxf(0.0, rush - .72) * 3.5)
                "FIELD GOAL":
                    var flight: float = float(p["death_progress"])
                    death_offset.x = float(p["death_direction"]) * flight * 250.0
                    death_offset.y = -sin(minf(1.0, flight * .58) * PI) * 245.0 + flight * 35.0
                    death_rotation = float(p["death_direction"]) * flight * 9.0
                    death_scale = Vector2.ONE * maxf(.24, 1.0 - flight * .24)
                "UPPERCUT":
                    death_offset.y = -p["death_progress"] * p["death_progress"] * 245.0
                    death_rotation = p["death_progress"] * 5.5
                    death_scale = Vector2(1.0 - p["death_progress"] * .12, 1.0 + p["death_progress"] * .3)
                "SPUN OUT":
                    death_offset.x = sin(p["death_progress"] * 9.0) * 72.0
                    death_rotation = p["death_progress"] * 14.0
                    death_scale = Vector2.ONE * maxf(.12, 1.0 - p["death_progress"] * .38)
                "DISINTEGRATED":
                    death_scale = Vector2(1.0 + p["death_progress"] * .3, maxf(.04, 1.0 - p["death_progress"] * .55))
                    tint = Color(1.7, .25 + abs(sin(game_time * 22.0)), .1, maxf(.04, 1.0 - p["death_progress"] * .42))
                "FLOOR SWALLOWED":
                    death_offset.y = p["death_progress"] * p["death_progress"] * 210.0
                    death_scale = Vector2.ONE * maxf(.18, 1.0 - p["death_progress"] * .33)
            draw_set_transform(p["pos"] + death_offset, death_rotation, death_scale)
            _sprite("sprites/players/" + p["name"] + "_death.png", Vector2.ZERO, frame, DIRS.find(p["dir"]), Vector2(-1, -1), tint)
            draw_set_transform(Vector2.ZERO)
        else:
            _sprite("sprites/players/" + p["name"] + "_" + action + ".png", p["pos"], frame, DIRS.find(p["dir"]), Vector2(-1, -1), tint)
        if dead:
            continue
        # Weapon sheets are 64px frames; render them as compact hand-held
        # silhouettes instead of covering the contestant's entire torso.
        var origin: Vector2 = p["pos"] + Vector2(0, -17) + p["aim"] * 4.0
        draw_set_transform(origin, p["aim"].angle(), Vector2.ONE)
        _sprite("sprites/weapons/" + p["weapon"] + ".png", Vector2.ZERO, int(game_time * 10) % 4, 0, Vector2(18, 32), tint, .62)
        draw_set_transform(Vector2.ZERO)
        for drone_index in range(mini(3, int(p["drone_level"]))):
            var drone_angle = game_time * (3.0 + drone_index * .18) + drone_index * TAU / maxf(1.0, float(p["drone_level"]))
            var drone_pos = p["pos"] + Vector2.from_angle(drone_angle) * (42.0 + drone_index * 7.0)
            draw_circle(drone_pos, 12, Color(.05, .12, .18, .85))
            draw_arc(drone_pos, 14, 0, TAU, 20, locator_color, 3)
            draw_line(drone_pos, drone_pos + p["aim"] * 18, Color(.5, 1, .95), 3)
        if p["buffs"].has("invulnerability"):
            draw_arc(p["pos"] + Vector2(0, -12), 32, 0, TAU, 32, Color(.8, .65, 1, .6), 2)
        if p["buffs"].has("reflect_shield"):
            var shield_center = p["pos"] + Vector2(0, -12)
            for shield_glow in range(5, 0, -1):
                draw_arc(shield_center, 35 + shield_glow * 2, game_time * 2.4, game_time * 2.4 + TAU, 48, Color(1, .12, .72, .035 * shield_glow), 2 + shield_glow)
            draw_arc(shield_center, 36, game_time * 2.4, game_time * 2.4 + TAU, 48, Color(1, .3, .82, .9), 3)
            draw_arc(shield_center, 31, -game_time * 3.1, -game_time * 3.1 + PI * 1.45, 32, Color(.5, .9, 1, .85), 2)
        if p["id"] == 1:
            _sprite("ui/hud/crosshair_p2.png", p["pos"] + p["aim"] * 115)
    for shot in shots:
        draw_set_transform(shot["pos"], shot["vel"].angle(), Vector2.ONE)
        _sprite("sprites/projectiles/" + shot["kind"] + ".png", Vector2.ZERO, int(game_time * 16) % 4)
        draw_set_transform(Vector2.ZERO)
    for effect in effects:
        var path = "sprites/effects/" + effect["id"] + ".png"
        var meta = library.record(ART + path)
        if meta.is_empty():
            continue
        var frame = mini(int(meta["columns"]) - 1, int((1 - effect["life"] / effect["total"]) * meta["columns"]))
        draw_set_transform(effect["pos"], effect["angle"], Vector2.ONE)
        _sprite(path, Vector2.ZERO, frame)
        draw_set_transform(Vector2.ZERO)
    for popup in popups:
        var tint: Color = popup["color"]
        tint.a = minf(1.0, popup["life"] * 2)
        _label(popup["text"], popup["pos"], 21, tint, true)
    _sprite("ui/hud/crosshair_p1.png", get_global_mouse_position())
    _hud()

func _label(label: String, point: Vector2, font_size: int = 20, color: Color = Color.WHITE, centered: bool = false) -> void:
    var position = point
    if centered:
        position.x -= font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / 2
    draw_string(font, position + Vector2(2, 2), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, color.a))
    draw_string(font, position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _hud() -> void:
    draw_rect(Rect2(0, 0, 768, 128), Color(.018, .025, .065, .98))
    for i in range(2):
        var p: Dictionary = players[i]
        var x = 12 if i == 0 else 396
        var color = Color(.1, .8, 1) if i == 0 else Color(1, .76, .22)
        _label(("P1 VOLT" if i == 0 else "P2 NOVA") + (" [OFF]" if i == 1 and not p2_enabled else ""), Vector2(x, 24), 18, color)
        _label("%08d" % p["score"], Vector2(x + 200, 24), 17)
        draw_rect(Rect2(x, 34, 245, 12), Color(.09, .14, .21))
        draw_rect(Rect2(x, 34, 245 * maxf(0, p["health"]) / 100, 12), Color(.25, .9, .5))
        if p["armor"] > 0:
            draw_rect(Rect2(x, 48, 245 * p["armor"] / 100, 4), Color(.1, .6, 1))
        _label("LIVES %d  CONT %d" % [p["lives"], p["continues"]], Vector2(x, 70), 14, color)
        if p["lives"] <= 0 and p["continue_timer"] > 0:
            _label("CONTINUE? %d" % ceili(p["continue_timer"]), Vector2(x, 70), 16, Color(1, .35, .65))
            _label("START (%d LEFT)" % p["continues"], Vector2(x + 116, 70), 14, Color(1, .8, .2))
        _label("%s" % weapons[p["weapon"]]["display_name"], Vector2(x, 92), 13)
    _label("ARENA BRAWL", Vector2(384, 70), 22, Color(.5, .8, .95), true)
    _label("ROOM %02d  •  FLOOR %d/%d" % [int(wave_index / FLOORS_PER_ROOM) + 1, floor_in_room, FLOORS_PER_ROOM], Vector2(384, 104), 18, Color(1, .35, .85), true)
    for enemy in enemies:
        if enemy["boss"]:
            draw_rect(Rect2(139, 132, 490, 15), Color(.12, .09, .16))
            draw_rect(Rect2(141, 134, 486 * maxf(0, enemy["hp"]) / enemy["max_hp"], 11), Color(.95, .2, .6))
            _label(boss_defs[enemy["id"]]["display_name"], Vector2(384, 166), 18, Color.WHITE, true)
            break
    if phase == "warning":
        _label("GET READY - FLOOR %d/%d" % [floor_in_room, FLOORS_PER_ROOM], Vector2(384, 500), 30, Color(1, .76, .25), true)
    if show_help:
        draw_rect(Rect2(12, 950, 744, 62), Color(.02, .04, .08, .94))
        _label("LEFT STICK MOVE  RIGHT STICK AIM  A/X/TRIGGER FIRE", Vector2(28, 975), 15)
        _label("START PAUSE  F1 HELP  R RESTART  ESC EXIT", Vector2(28, 998), 14, Color(.55, .76, .87))
    if debug_info:
        _label("FPS %d | ENEMIES %d | SHOTS %d" % [Engine.get_frames_per_second(), enemies.size(), shots.size()], Vector2(16, 1015), 13, Color(1, .85, .3))
    if demo_paused or game_over or victory or phase == "boss_tally":
        draw_rect(Rect2(0, 128, 768, 896), Color(.015, .025, .05, .86))
        if phase == "boss_tally":
            _draw_boss_tally()
        elif demo_paused:
            _draw_pause_menu()
        elif victory:
            _draw_prize_tally()
        else:
            _label("GAME OVER", Vector2(384, 450), 52, Color(1, .76, .22), true)
            var game_over_winner = 0 if players[0]["score"] >= players[1]["score"] else 1
            _label("FINAL SCORE %08d" % players[game_over_winner]["score"], Vector2(384, 515), 22, Color.WHITE, true)
            if tally_time >= 3.0:
                if high_score_saved:
                    var over_message = "TOP TEN #%d SAVED" % high_score_rank if high_score_rank > 0 else "SCORE SAVED — OUTSIDE TOP TEN"
                    _label(over_message, Vector2(384, 574), 18, Color(.3, 1, .7), true)
                    _label("PRESS ANY BUTTON", Vector2(384, 610), 16, Color(.7, .82, 1), true)
                else:
                    var over_initials = ""
                    for index in name_entry_chars:
                        over_initials += NAME_CHARS[index]
                    _label("ENTER YOUR INITIALS", Vector2(384, 565), 18, Color(.65, .9, 1), true)
                    _label(over_initials, Vector2(384, 612), 34, Color(1, .78, .16), true)
                    var over_cursor_x = 357 + name_entry_cursor * 20
                    draw_line(Vector2(over_cursor_x, 624), Vector2(over_cursor_x + 17, 624), Color(1, .2, .62), 3)

func _draw_boss_tally() -> void:
    _label("STAGE %d COMPLETE" % (int(wave_index / (FLOORS_PER_ROOM + 1)) + 1), Vector2(384, 190), 36, Color(1, .76, .16), true)
    _label("DREADWIRE PRIZE SETTLEMENT", Vector2(384, 225), 17, Color(.35, .9, 1), true)
    for i in range(2 if p2_enabled else 1):
        var x = 24 + i * 372 if p2_enabled else 128
        var width = 348 if p2_enabled else 512
        var color = Color(.15, .85, 1) if i == 0 else Color(1, .3, .72)
        draw_rect(Rect2(x, 248, width, 650), Color(.018, .03, .085, .97))
        draw_rect(Rect2(x, 248, width, 650), color, false, 3)
        _label("PLAYER %d" % (i + 1), Vector2(x + width * .5, 286), 24, color, true)
        for row in range(PRIZE_ORDER.size()):
            var prize_id: String = PRIZE_ORDER[row]
            var y = 330 + row * 43
            if row == boss_tally_row and boss_tally_row < PRIZE_ORDER.size():
                draw_rect(Rect2(x + 10, y - 25, width - 20, 35), Color(color.r, color.g, color.b, .18))
            _label(String(PRIZE_VALUES[prize_id]["label"]), Vector2(x + 20, y), 14, Color(.76, .86, 1))
            _label("%03d" % int(boss_tally_counts[i].get(prize_id, 0)), Vector2(x + width - 64, y), 17, Color.WHITE)
        draw_line(Vector2(x + 18, 766), Vector2(x + width - 18, 766), color, 2)
        _label("TOTAL CASH", Vector2(x + 20, 805), 17, Color(.7, .85, 1))
        _label("$%09d" % boss_tally_cash[i], Vector2(x + width - 150, 805), 19, Color(1, .82, .2))
        _label("SECRET KEYS  %02d" % players[i]["keys"], Vector2(x + 20, 842), 16, Color(.7, 1, .72))
        if boss_tally_bonus_awarded:
            if i == boss_tally_winner:
                _label("★ WINNER +%d ★" % STAGE_WINNER_BONUS, Vector2(x + width * .5, 879), 20, Color(1, .78, .14), true)
            elif boss_tally_winner < 0:
                _label("TIE — NO BONUS", Vector2(x + width * .5, 879), 17, Color(.75, .82, .95), true)
    if boss_tally_bonus_awarded:
        _label("UPDATED SCORES  P1 %08d%s" % [players[0]["score"], "   P2 %08d" % players[1]["score"] if p2_enabled else ""], Vector2(384, 950), 19, Color.WHITE, true)
        var next_label = "NEXT: FINAL PRIZE TALLY" if wave_index + 1 >= waves.size() else "NEXT: CHOOSE YOUR PATH"
        _label(next_label, Vector2(384, 985), 16, Color(.35, 1, .72), true)

func _draw_prize_tally() -> void:
    _label("FINAL PRIZE TALLY", Vector2(384, 205), 38, Color(1, .76, .16), true)
    var winner = 0 if players[0]["score"] >= players[1]["score"] else 1
    for i in range(2 if p2_enabled else 1):
        var p: Dictionary = players[i]
        var x = 72 + i * 360
        var reveal = clampf(tally_time / 5.0, 0.0, 1.0)
        var bars = mini(18, int((p["cash"] / 1000.0 + p["gold"] * 2) * reveal))
        _label("PLAYER %d" % (i + 1), Vector2(x + 130, 290), 27, Color(.15, .85, 1) if i == 0 else Color(1, .72, .12), true)
        draw_rect(Rect2(x, 320, 260, 480), Color(.025, .04, .1, .95))
        for bar in range(bars):
            var col = bar % 4
            var row = int(bar / 4)
            var rect = Rect2(x + 18 + col * 58, 742 - row * 66, 48, 54)
            draw_rect(rect, Color(1, .65, .08))
            draw_rect(rect, Color(1, .92, .38), false, 3)
        _label("$%d + %d GOLD" % [p["cash"], p["gold"]], Vector2(x + 130, 835), 19, Color.WHITE, true)
        _label("SCORE %08d" % p["score"], Vector2(x + 130, 870), 19, Color.WHITE, true)
        if i == winner and tally_time > 5.0:
            _label("★ WINNER ★", Vector2(x + 130, 925), 24, Color(1, .8, .12), true)
    if tally_time >= 7.0:
        draw_rect(Rect2(164, 936, 440, 76), Color(.03, .01, .06, .96))
        draw_rect(Rect2(164, 936, 440, 76), Color(1, .18, .62), false, 3)
        if high_score_saved:
            var saved_message = "TOP TEN #%d SAVED" % high_score_rank if high_score_rank > 0 else "SCORE SAVED — OUTSIDE TOP TEN"
            _label(saved_message + " — PRESS ANY BUTTON", Vector2(384, 982), 17, Color(.3, 1, .7), true)
        else:
            var initials = ""
            for index in name_entry_chars:
                initials += NAME_CHARS[index]
            _label("ENTER CHAMPION NAME", Vector2(300, 965), 16, Color(.65, .9, 1), true)
            _label(initials, Vector2(493, 989), 29, Color(1, .78, .16), true)
            var cursor_x = 468 + name_entry_cursor * 18
            draw_line(Vector2(cursor_x, 997), Vector2(cursor_x + 15, 997), Color(1, .2, .62), 3)

func _draw_pause_menu() -> void:
    var panel = Rect2(104, 180, 560, 760)
    draw_rect(panel, Color(.008, .012, .04, .98))
    draw_rect(panel, Color(.1, .85, 1), false, 4)
    _label("ARENA BRAWL PAUSED", Vector2(384, 232), 32, Color(1, .78, .2), true)
    if control_wizard_open:
        _label("PLAYER %d CONTROLLER SETUP" % (control_wizard_player + 1), Vector2(384, 335), 28, Color(.2, .9, 1), true)
        _label("PRESS: " + CONTROL_ACTIONS[control_wizard_step], Vector2(384, 430), 30, Color.WHITE, true)
        _label("DEVICE: " + (control_wizard_name.to_upper() if not control_wizard_name.is_empty() else "WAITING..."), Vector2(384, 485), 17, Color(.6, .8, .95), true)
        _label("HOLD ANY ALREADY-MAPPED BUTTON", Vector2(384, 600), 17, Color(1, .82, .3), true)
        _label("FOR 1 SECOND TO SKIP THIS CONTROL", Vector2(384, 628), 17, Color(1, .82, .3), true)
        _label("Mappings are saved only for Arena Brawl", Vector2(384, 770), 16, Color(.65, .7, .82), true)
        return
    for i in range(PAUSE_ITEMS.size()):
        var row = Rect2(155, 248 + i * 52, 458, 42)
        var selected = i == pause_selection
        draw_rect(row, Color(.08, .48, .72, .5) if selected else Color(.025, .04, .1, .9))
        draw_rect(row, Color(1, .82, .18) if selected else Color(.12, .32, .48), false, 2)
        var label = PAUSE_ITEMS[i]
        if i == 5: label = "P1: " + (player_controllers[0] if not player_controllers[0].is_empty() else "UNASSIGNED")
        elif i == 6: label = "P2: " + (player_controllers[1] if not player_controllers[1].is_empty() else "UNASSIGNED")
        elif i == 7: label = "MUSIC VOLUME: %d%%" % music_volume
        elif i == 8: label = "SOUND EFFECTS: %d%%" % sfx_volume
        elif i == 9: label = "ANNOUNCER VOICE: %d%%" % voice_volume
        if label.length() > 36: label = label.substr(0, 33) + "..."
        _label(label, row.position + Vector2(row.size.x / 2, 29), 19, Color.WHITE, true)
    if controller_help_timer > 0:
        _label("MOVE + HOLD FIRE = LOCK SHOT DIRECTION", Vector2(384, 852), 16, Color(.4, 1, .75), true)
        _label("DUAL STICK: LEFT MOVES • RIGHT AIMS/FIRES", Vector2(384, 880), 16, Color(.4, 1, .75), true)
    else:
        _label("UP/DOWN: MOVE   LEFT/RIGHT: VOLUME   A: SELECT", Vector2(384, 885), 14, Color(.58, .75, .9), true)

func _make_crt() -> void:
    crt_layer = CanvasLayer.new()
    crt_layer.layer = 8
    crt_layer.visible = false
    add_child(crt_layer)
    crt_rect = ColorRect.new()
    crt_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    crt_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var material = ShaderMaterial.new()
    material.shader = load(BASE + "shaders/crt.gdshader")
    crt_rect.material = material
    crt_layer.add_child(crt_rect)

func _exit_tree() -> void:
    if is_instance_valid(audio):
        audio.stop_all()
