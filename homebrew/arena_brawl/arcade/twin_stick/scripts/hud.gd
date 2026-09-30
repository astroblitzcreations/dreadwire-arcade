extends Control
var player_labels: Array[Label] = []
var health_bars: Array[ProgressBar] = []
var wave_label: Label
var boss_label: Label
var boss_bar: ProgressBar
func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    for i in range(2):
        var frame = TextureRect.new()
        frame.texture = load("res://arcade/twin_stick/assets/ui/hud/p1_panel.png" if i == 0 else "res://arcade/twin_stick/assets/ui/hud/p2_panel.png")
        frame.position = Vector2(12 if i == 0 else 908, 0)
        frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(frame)
        var label = Label.new()
        label.position = frame.position + Vector2(16, 10)
        label.add_theme_font_size_override("font_size", 20)
        add_child(label)
        player_labels.append(label)
        var health = ProgressBar.new()
        health.position = frame.position + Vector2(16, 50)
        health.size = Vector2(320, 12)
        health.show_percentage = false
        health.value = 100
        add_child(health)
        health_bars.append(health)
    wave_label = Label.new()
    wave_label.position = Vector2(410, 10)
    wave_label.size = Vector2(460, 60)
    wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    wave_label.add_theme_font_size_override("font_size", 24)
    add_child(wave_label)
    boss_bar = ProgressBar.new()
    boss_bar.position = Vector2(400, 86)
    boss_bar.size = Vector2(480, 16)
    boss_bar.show_percentage = false
    boss_bar.visible = false
    add_child(boss_bar)
    boss_label = Label.new()
    boss_label.position = Vector2(400, 104)
    boss_label.size = Vector2(480, 30)
    boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(boss_label)
    set_player_state(0, "VOLT", 100, 3, 0)
    set_player_state(1, "NOVA", 100, 3, 0)
    set_wave(1, "ARENA ALPHA")

func set_player_state(index: int, contestant: String, health: float, lives: int, score: int) -> void:
    if index < 0 or index >= player_labels.size():
        return
    player_labels[index].text = "%s   %08d   LIVES %d" % [contestant, score, lives]
    health_bars[index].value = clampf(health, 0, 100)

func set_wave(wave: int, arena_name: String) -> void:
    wave_label.text = "WAVE %02d\n%s" % [wave, arena_name]

func set_boss(label: String, current: float, maximum: float) -> void:
    boss_bar.visible = maximum > 0
    boss_label.text = label if maximum > 0 else ""
    boss_bar.value = clampf(current / maxf(maximum, 1.0) * 100.0, 0, 100)
