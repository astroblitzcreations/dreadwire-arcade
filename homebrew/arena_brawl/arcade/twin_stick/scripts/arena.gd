extends Node2D
## TileMapLayer reference arena. The playable demo uses batched atlas drawing for compatibility.
func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var floor_layer = TileMapLayer.new()
    floor_layer.name = "Floor"
    floor_layer.tile_set = load("res://arcade/twin_stick/resources/arena_tileset.tres")
    floor_layer.position = Vector2(0, 80)
    add_child(floor_layer)
    for y in range(12):
        for x in range(20):
            var tile = 10 if y == 0 else 11 if y == 11 else 12 if x == 0 else 13 if x == 19 else 2 if (x + y) % 4 == 0 else 0
            floor_layer.set_cell(Vector2i(x, y), 0, Vector2i(tile % 8, tile / 8))
