extends Node2D
## Reusable animation prefab, not a second AI implementation. The demo logic is in twin_stick_game.gd.
@export var frames_id: String = "volt"
@export var animation_name: String = "idle_s"
@export var ground_pivot: Vector2 = Vector2(32, 48)
@export var frame_size: Vector2 = Vector2(64, 64)
@export var weapon_id: String = ""
var body: AnimatedSprite2D
var weapon_pivot: Node2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    body = AnimatedSprite2D.new()
    body.name = "BodySprite"
    body.position = frame_size * .5 - ground_pivot
    body.sprite_frames = load("res://arcade/twin_stick/resources/" + frames_id + "_frames.tres")
    add_child(body)
    if body.sprite_frames != null and body.sprite_frames.has_animation(animation_name):
        body.play(animation_name)
    weapon_pivot = Node2D.new()
    weapon_pivot.name = "WeaponPivot"
    weapon_pivot.position = Vector2(0, -18)
    add_child(weapon_pivot)
    if not weapon_id.is_empty():
        var weapon = Sprite2D.new()
        var atlas = AtlasTexture.new()
        atlas.atlas = load("res://arcade/twin_stick/assets/sprites/weapons/" + weapon_id + ".png")
        atlas.region = Rect2(0, 0, 64, 64)
        weapon.texture = atlas
        weapon.position = Vector2(8, 0)
        weapon_pivot.add_child(weapon)
        var muzzle = Marker2D.new()
        muzzle.name = "MuzzlePoint"
        muzzle.position = Vector2(34, 0)
        weapon_pivot.add_child(muzzle)

func aim_at(global_target: Vector2) -> void:
    if is_instance_valid(weapon_pivot):
        weapon_pivot.look_at(global_target)
