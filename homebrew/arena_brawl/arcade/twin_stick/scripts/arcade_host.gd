extends CanvasLayer
## Integration helper. Add outside the world subtree that you pass to open_arcade().
## Exact process modes/audio pause flags/tree pause state are snapshotted and restored.
const GAME = preload("res://arcade/twin_stick/scenes/TwinStickGame.tscn")
var active: bool = false
var previous_tree_pause: bool = false
var previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE
var process_snapshot: Array = []
var audio_snapshot: Array = []
var game
var blocker: Control

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 100

func open_arcade(world_root: Node, external_consumers: Array[Node] = []) -> void:
    if active or world_root == null:
        return
    if world_root == self or world_root.is_ancestor_of(self):
        push_error("ArcadeHost must live OUTSIDE the world subtree being disabled.")
        return
    active = true
    previous_tree_pause = get_tree().paused
    previous_mouse_mode = Input.mouse_mode
    process_snapshot.clear()
    audio_snapshot.clear()
    _snapshot_branch(world_root)
    for consumer in external_consumers:
        if is_instance_valid(consumer) and consumer != self:
            _snapshot_branch(consumer)
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    blocker = Control.new()
    blocker.name = "InputBlocker"
    blocker.mouse_filter = Control.MOUSE_FILTER_STOP
    blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    blocker.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(blocker)
    game = GAME.instantiate()
    game.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(game)
    game.close_requested.connect(close_arcade)
    # The demo uses manual simulation; it does NOT reactivate global physics while the world is paused.

func _snapshot_branch(node: Node) -> void:
    if node == self or is_ancestor_of(node):
        return
    for entry in process_snapshot:
        if entry["node"] == node:
            return
    process_snapshot.append({"node": node, "mode": node.process_mode})
    node.process_mode = Node.PROCESS_MODE_DISABLED
    if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
        audio_snapshot.append({"node": node, "paused": node.stream_paused})
        node.stream_paused = true
    for child in node.get_children():
        _snapshot_branch(child)

func _unhandled_input(_event: InputEvent) -> void:
    if active:
        get_viewport().set_input_as_handled()

func close_arcade() -> void:
    if not active:
        return
    if is_instance_valid(game):
        var director = game.get("audio")
        if is_instance_valid(director):
            director.stop_all()
        game.queue_free()
    if is_instance_valid(blocker):
        blocker.queue_free()
    _restore_state()

func _restore_state() -> void:
    for entry in audio_snapshot:
        if is_instance_valid(entry["node"]):
            entry["node"].stream_paused = entry["paused"]
    for entry in process_snapshot:
        if is_instance_valid(entry["node"]):
            entry["node"].process_mode = entry["mode"]
    if is_inside_tree():
        get_tree().paused = previous_tree_pause
    Input.mouse_mode = previous_mouse_mode
    audio_snapshot.clear()
    process_snapshot.clear()
    active = false

func _exit_tree() -> void:
    if active:
        _restore_state()
