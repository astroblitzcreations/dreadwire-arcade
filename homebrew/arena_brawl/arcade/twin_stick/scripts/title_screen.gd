extends Control

const BASE = "res://arcade/twin_stick/"
var difficulty := "normal"
var two_players := true
var menu_buttons: Array[Button] = []
var stars: Array[Dictionary] = []
var card: Panel
var mode_button: Button
var players_button: Button
var music: AudioStreamPlayer
var elapsed := 0.0
var idle_elapsed := 0.0
var starting_game := false
var logo_left: Control
var leaderboard_panel: Panel
var leaderboard_entries: Array = []

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _load_settings()
    for i in range(70):
        stars.append({"p": Vector2(randf_range(0, 768), randf_range(0, 1024)), "z": randf_range(.25, 1.0)})
    _build_scene()
    _start_music()
    menu_buttons[0].grab_focus()

func _build_scene() -> void:
    var background = TextureRect.new()
    background.texture = load(BASE + "assets/ui/menus/title_background.png")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.modulate = Color(.28, .38, .7, .72)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var shade = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(.005, .008, .03, .48)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

    # Render the cabinet title as real text. The old split bitmap ignored its
    # crop bounds on GLES and drew both 1000px halves over one another.
    logo_left = _logo_title(Vector2(-680, 112))

    var tagline = Label.new()
    tagline.text = "FIGHT  •  SURVIVE  •  WIN BIG"
    tagline.position = Vector2(84, 218)
    tagline.size = Vector2(600, 30)
    tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tagline.add_theme_font_size_override("font_size", 16)
    tagline.add_theme_color_override("font_color", Color(1, .72, .18))
    tagline.add_theme_color_override("font_outline_color", Color(.03, .01, .08))
    tagline.add_theme_constant_override("outline_size", 5)
    add_child(tagline)

    var subtitle = Label.new()
    subtitle.text = "TWIN-STICK CARNAGE // CABINET EDITION"
    subtitle.position = Vector2(84, 248)
    subtitle.size = Vector2(600, 34)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 15)
    subtitle.add_theme_color_override("font_color", Color(.25, .92, 1))
    subtitle.add_theme_color_override("font_outline_color", Color(.02, .03, .1))
    subtitle.add_theme_constant_override("outline_size", 4)
    add_child(subtitle)
    var score_config = ConfigFile.new()
    if score_config.load("user://arena_brawl_scores.cfg") == OK:
        var champion = Label.new()
        champion.text = "HOUSE CHAMPION: %s  %08d" % [String(score_config.get_value("champion", "name", "---")), int(score_config.get_value("champion", "score", 0))]
        champion.position = Vector2(90, 279)
        champion.size = Vector2(588, 34)
        champion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        champion.add_theme_font_size_override("font_size", 16)
        champion.add_theme_color_override("font_color", Color(1, .72, .18))
        add_child(champion)

    card = Panel.new()
    card.position = Vector2(92, 322)
    card.size = Vector2(584, 540)
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(.018, .025, .085, .96)
    panel_style.border_color = Color(.15, .85, 1, .9)
    panel_style.set_border_width_all(3)
    panel_style.set_corner_radius_all(18)
    panel_style.shadow_color = Color(.8, .05, .75, .6)
    panel_style.shadow_size = 18
    panel_style.shadow_offset = Vector2(10, 14)
    card.add_theme_stylebox_override("panel", panel_style)
    add_child(card)
    var heading = Label.new()
    heading.text = "SELECT COMBAT PROTOCOL"
    heading.position = Vector2(22, 25)
    heading.size = Vector2(540, 44)
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 25)
    heading.add_theme_color_override("font_color", Color(1, .78, .18))
    card.add_child(heading)

    menu_buttons.append(_menu_button("START GAME", 92, _start_game))
    mode_button = _menu_button("", 176, _cycle_difficulty)
    menu_buttons.append(mode_button)
    players_button = _menu_button("", 260, _toggle_players)
    menu_buttons.append(players_button)
    menu_buttons.append(_menu_button("CONTROLS / AUDIO IN PAUSE", 344, _start_game))
    menu_buttons.append(_menu_button("EXIT TO ARCADE", 428, func(): get_tree().quit()))
    _refresh_labels()

    var footer = Label.new()
    footer.text = "JOYSTICK: SELECT   FIRE/A: CONFIRM   START: LAUNCH"
    footer.position = Vector2(44, 890)
    footer.size = Vector2(680, 44)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_font_size_override("font_size", 15)
    footer.add_theme_color_override("font_color", Color(.62, .75, .92))
    add_child(footer)
    _build_leaderboard()

func _build_leaderboard() -> void:
    var score_config = ConfigFile.new()
    score_config.load("user://arena_brawl_scores.cfg")
    leaderboard_entries = score_config.get_value("leaderboard", "entries", [])
    if leaderboard_entries.is_empty():
        var champion_score = int(score_config.get_value("champion", "score", 0))
        if champion_score > 0:
            leaderboard_entries.append({"name": String(score_config.get_value("champion", "name", "---")),
                "score": champion_score, "cash": int(score_config.get_value("champion", "cash", 0)),
                "gold": int(score_config.get_value("champion", "gold", 0)), "level": 1, "floor": 1,
                "kills": 0, "boss_kills": 0, "deaths": 0, "pickups": 0,
                "continues_used": 0, "play_time": 0, "stamp": 0})
            score_config.set_value("leaderboard", "entries", leaderboard_entries)
            score_config.save("user://arena_brawl_scores.cfg")
    _import_pending_run(score_config)
    leaderboard_panel = Panel.new()
    leaderboard_panel.position = Vector2(66, 302)
    leaderboard_panel.size = Vector2(636, 624)
    var style = StyleBoxFlat.new()
    style.bg_color = Color(.008, .016, .052, .985)
    style.border_color = Color(.15, .92, 1, .95)
    style.set_border_width_all(4)
    style.set_corner_radius_all(20)
    style.shadow_color = Color(1, .04, .62, .62)
    style.shadow_size = 18
    leaderboard_panel.add_theme_stylebox_override("panel", style)
    leaderboard_panel.visible = false
    add_child(leaderboard_panel)
    var heading = Label.new()
    heading.text = "ARENA BRAWL // TOP 10"
    heading.position = Vector2(24, 16)
    heading.size = Vector2(588, 52)
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 29)
    heading.add_theme_color_override("font_color", Color(1, .76, .16))
    leaderboard_panel.add_child(heading)
    var columns = Label.new()
    columns.text = "RANK  PLAYER    SCORE       LEVEL   KILLS"
    columns.position = Vector2(40, 72)
    columns.size = Vector2(556, 28)
    columns.add_theme_font_size_override("font_size", 15)
    columns.add_theme_color_override("font_color", Color(.35, .88, 1))
    leaderboard_panel.add_child(columns)
    for i in range(10):
        var row = Label.new()
        var entry: Dictionary = leaderboard_entries[i] if i < leaderboard_entries.size() else {}
        row.text = "%2d     %-3s    %08d      %2d      %4d" % [i + 1,
            String(entry.get("name", "---")).left(3), int(entry.get("score", 0)),
            int(entry.get("level", 1)), int(entry.get("kills", 0))]
        row.position = Vector2(40, 108 + i * 43)
        row.size = Vector2(556, 36)
        row.add_theme_font_size_override("font_size", 18)
        row.add_theme_color_override("font_color", Color(1, .82, .28) if i == 0 else Color(.84, .92, 1))
        leaderboard_panel.add_child(row)
    var footer = Label.new()
    var leader: Dictionary = leaderboard_entries[0] if not leaderboard_entries.is_empty() else {}
    var seconds = int(leader.get("play_time", 0))
    footer.text = "#1  CASH %d  GOLD %d  BOSSES %d  DEATHS %d  CONT %d  TIME %02d:%02d" % [
        int(leader.get("cash", 0)), int(leader.get("gold", 0)),
        int(leader.get("boss_kills", 0)), int(leader.get("deaths", 0)),
        int(leader.get("continues_used", 0)), int(seconds / 60), seconds % 60]
    footer.position = Vector2(24, 548)
    footer.size = Vector2(588, 42)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_font_size_override("font_size", 15)
    footer.add_theme_color_override("font_color", Color(1, .28, .72))
    leaderboard_panel.add_child(footer)

func _import_pending_run(score_config: ConfigFile) -> void:
    var pending = ConfigFile.new()
    if pending.load("user://arena_brawl_pending_run.cfg") != OK:
        return
    var stamp = int(pending.get_value("pending", "stamp", 0))
    var already_present = false
    for entry in leaderboard_entries:
        if int(entry.get("stamp", -1)) == stamp and stamp > 0:
            already_present = true
            break
    if not already_present and int(pending.get_value("pending", "score", 0)) > 0:
        leaderboard_entries.append({"name": String(pending.get_value("pending", "name", "P1")),
            "score": int(pending.get_value("pending", "score", 0)),
            "cash": int(pending.get_value("pending", "cash", 0)),
            "gold": int(pending.get_value("pending", "gold", 0)),
            "level": int(pending.get_value("pending", "level", 1)),
            "floor": int(pending.get_value("pending", "floor", 1)),
            "kills": int(pending.get_value("pending", "kills", 0)),
            "boss_kills": int(pending.get_value("pending", "boss_kills", 0)),
            "deaths": int(pending.get_value("pending", "deaths", 0)),
            "pickups": int(pending.get_value("pending", "pickups", 0)),
            "continues_used": int(pending.get_value("pending", "continues_used", 0)),
            "play_time": int(pending.get_value("pending", "play_time", 0)), "stamp": stamp})
        leaderboard_entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
        if leaderboard_entries.size() > 10:
            leaderboard_entries.resize(10)
        score_config.set_value("leaderboard", "entries", leaderboard_entries)
        if not leaderboard_entries.is_empty():
            score_config.set_value("champion", "name", leaderboard_entries[0]["name"])
            score_config.set_value("champion", "score", leaderboard_entries[0]["score"])
            score_config.set_value("champion", "cash", leaderboard_entries[0]["cash"])
            score_config.set_value("champion", "gold", leaderboard_entries[0]["gold"])
        score_config.save("user://arena_brawl_scores.cfg")
    var pending_path = ProjectSettings.globalize_path("user://arena_brawl_pending_run.cfg")
    if FileAccess.file_exists(pending_path):
        DirAccess.remove_absolute(pending_path)

func _menu_button(label: String, y: float, callback: Callable) -> Button:
    var button = Button.new()
    button.text = label
    button.position = Vector2(45, y)
    button.size = Vector2(494, 62)
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_font_size_override("font_size", 21)
    var normal = StyleBoxFlat.new()
    normal.bg_color = Color(.035, .055, .15, .96)
    normal.border_color = Color(.1, .35, .58)
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(8)
    normal.shadow_color = Color(0, 0, 0, .8)
    normal.shadow_size = 8
    normal.shadow_offset = Vector2(6, 8)
    var focus = normal.duplicate()
    focus.bg_color = Color(.12, .34, .58, 1)
    focus.border_color = Color(.25, 1, 1)
    focus.shadow_color = Color(.95, .08, .68, .8)
    focus.shadow_size = 14
    for state in ["normal", "disabled"]:
        button.add_theme_stylebox_override(state, normal)
    for state in ["focus", "hover", "pressed"]:
        button.add_theme_stylebox_override(state, focus)
    button.pressed.connect(callback)
    card.add_child(button)
    return button

func _logo_title(start: Vector2) -> Label:
    var title = Label.new()
    title.text = "ARENA BRAWL"
    title.position = start
    title.size = Vector2(640, 92)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 68)
    title.add_theme_color_override("font_color", Color(.91, .97, 1))
    title.add_theme_color_override("font_outline_color", Color(.04, .8, 1))
    title.add_theme_constant_override("outline_size", 5)
    add_child(title)
    return title

func _process(delta: float) -> void:
    elapsed += delta
    idle_elapsed += delta
    var slide = clampf(elapsed / 1.15, 0.0, 1.0)
    slide = 1.0 - pow(1.0 - slide, 3.0)
    logo_left.position.x = lerpf(-680.0, 64.0, slide)
    card.modulate.a = clampf((elapsed - .75) / .55, 0.0, 1.0)
    if card:
        card.rotation = sin(elapsed * .75) * .004
        card.position.y = 322 + sin(elapsed * 1.15) * 4
    var showing_scores = idle_elapsed >= 16.0 and idle_elapsed < 30.0 and not starting_game
    if is_instance_valid(leaderboard_panel):
        leaderboard_panel.visible = showing_scores
        leaderboard_panel.modulate.a = clampf((idle_elapsed - 16.0) / .55, 0.0, 1.0) if showing_scores else 1.0
    card.visible = not showing_scores
    if idle_elapsed >= 30.0 and not starting_game:
        _start_attract()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 768, 1024), Color(.005, .007, .03))
    for star in stars:
        var p: Vector2 = star["p"]
        var z: float = star["z"]
        p.y = fmod(p.y + elapsed * 18 * z, 1024.0)
        draw_circle(p, 1.0 + z * 1.7, Color(.2, .65 + z * .3, 1, .35 + z * .5))
    for i in range(11):
        var y = 690.0 + pow(float(i) / 10.0, 1.7) * 334.0
        draw_line(Vector2(0, y), Vector2(768, y), Color(.1, .45, .8, .22), 2)
    for i in range(-8, 9):
        draw_line(Vector2(384 + i * 42, 690), Vector2(384 + i * 130, 1024), Color(.75, .08, .65, .18), 2)

func _input(event: InputEvent) -> void:
    idle_elapsed = 0.0
    if is_instance_valid(leaderboard_panel):
        leaderboard_panel.visible = false
    if is_instance_valid(card):
        card.visible = true
    if event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode in [KEY_U, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
            _press_focused()
        elif event.physical_keycode == KEY_ESCAPE:
            get_tree().quit()
    elif event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_A, JOY_BUTTON_X, JOY_BUTTON_START]:
        _press_focused()

func _press_focused() -> void:
    var focused = get_viewport().gui_get_focus_owner()
    if focused is Button:
        focused.pressed.emit()
        get_viewport().set_input_as_handled()

func _cycle_difficulty() -> void:
    difficulty = {"normal": "easy", "easy": "afraid", "afraid": "normal"}[difficulty]
    _refresh_labels()

func _toggle_players() -> void:
    two_players = not two_players
    _refresh_labels()

func _refresh_labels() -> void:
    mode_button.text = "GAME MODE: " + difficulty.to_upper()
    players_button.text = "PLAYERS: " + ("2 PLAYER CO-OP" if two_players else "1 PLAYER")

func _load_settings() -> void:
    var config = ConfigFile.new()
    if config.load("user://arena_brawl_game.cfg") == OK:
        difficulty = String(config.get_value("game", "difficulty", difficulty))
        two_players = bool(config.get_value("game", "two_players", two_players))

func _save_settings() -> void:
    var config = ConfigFile.new()
    config.set_value("game", "difficulty", difficulty)
    config.set_value("game", "two_players", two_players)
    config.set_value("game", "attract_mode", false)
    config.save("user://arena_brawl_game.cfg")

func _start_attract() -> void:
    if starting_game:
        return
    var config = ConfigFile.new()
    config.set_value("game", "difficulty", "afraid")
    config.set_value("game", "two_players", true)
    config.set_value("game", "attract_mode", true)
    config.save("user://arena_brawl_game.cfg")
    _start_game(false)

func _start_game(clear_attract: bool = true) -> void:
    # A focused Button may receive ui_accept itself while this screen's raw
    # joypad handler also confirms it.  Do not allow those two callbacks to
    # replace the SceneTree twice in one frame (that crashes the ARM renderer).
    if starting_game:
        return
    starting_game = true
    for button in menu_buttons:
        button.disabled = true
    if clear_attract:
        _save_settings()
    if is_instance_valid(music):
        music.stop()
        music.stream = null
    call_deferred("_enter_arena")

func _enter_arena() -> void:
    await get_tree().process_frame
    var result = get_tree().change_scene_to_file(BASE + "scenes/TwinStickTest.tscn")
    if result != OK:
        starting_game = false
        for button in menu_buttons:
            button.disabled = false
        push_error("Arena scene failed to load: %s" % error_string(result))

func _start_music() -> void:
    music = AudioStreamPlayer.new()
    # The Pi's Godot 4.6 Vorbis decoder crashes when the full two-minute file
    # is loaded on the first frame, so use a cabinet-safe looping edit of the
    # supplied title theme here. The full soundtrack remains available later.
    var stream = load(BASE + "assets/audio/music/title_screen_short.ogg")
    if stream is AudioStreamOggVorbis:
        stream.loop = true
    music.stream = stream
    # Match gameplay loudness; the cabinet-wide mixer controls final output.
    music.volume_db = -3
    add_child(music)
    music.play()
