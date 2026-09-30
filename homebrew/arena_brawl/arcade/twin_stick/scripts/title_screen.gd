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

    var shadow = TextureRect.new()
    shadow.texture = load(BASE + "assets/ui/menus/arena_brawl_logo.png")
    shadow.position = Vector2(96, 99)
    shadow.size = Vector2(576, 185)
    shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    shadow.modulate = Color(0, 0, 0, .75)
    add_child(shadow)
    var logo = TextureRect.new()
    logo.texture = shadow.texture
    logo.position = Vector2(87, 87)
    logo.size = shadow.size
    logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(logo)

    var subtitle = Label.new()
    subtitle.text = "TWIN-STICK CARNAGE // CABINET EDITION"
    subtitle.position = Vector2(90, 260)
    subtitle.size = Vector2(588, 40)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 18)
    subtitle.add_theme_color_override("font_color", Color(.25, .92, 1))
    add_child(subtitle)

    card = Panel.new()
    card.position = Vector2(92, 340)
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
    footer.position = Vector2(44, 915)
    footer.size = Vector2(680, 44)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_font_size_override("font_size", 15)
    footer.add_theme_color_override("font_color", Color(.62, .75, .92))
    add_child(footer)

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

func _process(delta: float) -> void:
    elapsed += delta
    if card:
        card.rotation = sin(elapsed * .75) * .004
        card.position.y = 340 + sin(elapsed * 1.15) * 4
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
    config.save("user://arena_brawl_game.cfg")

func _start_game() -> void:
    _save_settings()
    get_tree().change_scene_to_file(BASE + "scenes/TwinStickTest.tscn")

func _start_music() -> void:
    music = AudioStreamPlayer.new()
    var stream = load(BASE + "assets/audio/music/arcade_title.ogg")
    if stream is AudioStreamOggVorbis:
        stream.loop = true
    music.stream = stream
    music.volume_db = -14
    add_child(music)
    music.play()
