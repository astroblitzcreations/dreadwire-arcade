extends Control
const BASE = "res://arcade/twin_stick/"
var actor: AnimatedSprite2D
var list: ItemList
var animation_picker: OptionButton
var title: Label
var ids: Array[String] = []
func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var back = ColorRect.new()
    back.color = Color(.028, .046, .085)
    back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    back.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(back)
    title = Label.new()
    title.position = Vector2(32, 22)
    title.text = "ARENA BRAWL - ANIMATION BROWSER"
    title.add_theme_font_size_override("font_size", 26)
    add_child(title)
    list = ItemList.new()
    list.position = Vector2(32, 80)
    list.size = Vector2(330, 730)
    add_child(list)
    var directory = DirAccess.open(BASE + "resources")
    if directory != null:
        for file in directory.get_files():
            if file.ends_with("_frames.tres"):
                ids.append(file.trim_suffix("_frames.tres"))
    ids.sort()
    for id in ids:
        list.add_item(id.replace("_", " "))
    animation_picker = OptionButton.new()
    animation_picker.position = Vector2(410, 90)
    animation_picker.size = Vector2(350, 40)
    add_child(animation_picker)
    actor = AnimatedSprite2D.new()
    actor.position = Vector2(810, 430)
    actor.scale = Vector2(3, 3)
    add_child(actor)
    list.item_selected.connect(_select_resource)
    animation_picker.item_selected.connect(_select_animation)
    var hint = Label.new()
    hint.position = Vector2(410, 770)
    hint.text = "Choose a resource and animation. Display: 3x nearest-neighbor. No reslicing required."
    add_child(hint)
    if not ids.is_empty():
        list.select(0)
        _select_resource(0)

func _select_resource(index: int) -> void:
    actor.sprite_frames = load(BASE + "resources/" + ids[index] + "_frames.tres")
    animation_picker.clear()
    if actor.sprite_frames == null:
        return
    for animation in actor.sprite_frames.get_animation_names():
        animation_picker.add_item(animation)
    if animation_picker.item_count > 0:
        _select_animation(0)

func _select_animation(index: int) -> void:
    actor.play(animation_picker.get_item_text(index))
    var first = actor.sprite_frames.get_frame_texture(animation_picker.get_item_text(index), 0)
    actor.scale = Vector2.ONE * (2.0 if first.get_width() >= 128 else 3.0)
