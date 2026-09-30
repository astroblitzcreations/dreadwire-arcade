extends Control
const BASE = "res://arcade/twin_stick/"
var music: AudioStreamPlayer
func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var background = TextureRect.new()
    background.texture = load(BASE + "assets/ui/menus/title_background.png")
    background.position = Vector2(0, 70)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var logo = TextureRect.new()
    logo.texture = load(BASE + "assets/ui/menus/arena_brawl_logo.png")
    logo.position = Vector2(120, 170)
    logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(logo)
    var modes = ["NORMAL MODE", "EASY MODE", "AFRAID MODE", "QUIT"]
    for i in range(modes.size()):
        var button = Button.new()
        button.text = modes[i]
        button.position = Vector2(465, 365 + i * 68)
        button.size = Vector2(350, 56)
        button.add_theme_font_size_override("font_size", 22)
        add_child(button)
        if i < 3:
            var selected_mode: String = ["normal", "easy", "afraid"][i]
            button.pressed.connect(func(): _start_mode(selected_mode))
        else:
            button.pressed.connect(func(): get_tree().quit())
    music = AudioStreamPlayer.new()
    var stream = load(BASE + "assets/audio/music/arcade_title.ogg")
    if stream is AudioStreamOggVorbis:
        stream.loop = true
    music.stream = stream
    music.volume_db = -16
    add_child(music)
    music.play()

func _start_mode(mode: String) -> void:
    var config = ConfigFile.new()
    config.set_value("game", "difficulty", mode)
    config.save("user://arena_brawl_game.cfg")
    get_tree().change_scene_to_file(BASE + "scenes/TwinStickTest.tscn")
