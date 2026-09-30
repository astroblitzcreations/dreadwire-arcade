extends Control
## Real join data must come from your backend. No fabricated QR/room code is displayed.
signal start_requested
var qr: TextureRect
var status_label: Label
var code_label: Label
var player_list: VBoxContainer
var start_button: Button
var session_url: String = ""
var session_valid: bool = false

func _ready() -> void:
    custom_minimum_size = Vector2(512, 640)
    var frame = TextureRect.new()
    frame.texture = load("res://arcade/twin_stick/assets/ui/party_mode/party_join_frame.png")
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(frame)
    qr = TextureRect.new()
    qr.position = Vector2(128, 96)
    qr.size = Vector2(256, 256)
    qr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    qr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    qr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(qr)
    code_label = Label.new()
    code_label.position = Vector2(45, 389)
    add_child(code_label)
    status_label = Label.new()
    status_label.position = Vector2(45, 425)
    status_label.text = "No live session connected."
    add_child(status_label)
    player_list = VBoxContainer.new()
    player_list.position = Vector2(35, 520)
    add_child(player_list)
    start_button = Button.new()
    start_button.text = "START PARTY"
    start_button.position = Vector2(310, 525)
    start_button.disabled = true
    start_button.pressed.connect(func(): start_requested.emit())
    add_child(start_button)

func set_session(join_url: String, room_code: String, generated_qr: Texture2D) -> bool:
    # Only actual backend data is accepted. The encoded URL is not guessed from the room code.
    if not (join_url.begins_with("https://") or join_url.begins_with("http://")) or room_code.is_empty() or generated_qr == null:
        clear_session()
        return false
    session_url = join_url
    qr.texture = generated_qr
    code_label.text = "ROOM " + room_code
    status_label.text = "Scan to join the live session."
    session_valid = true
    return true

func update_players(players: Array) -> void:
    for node in player_list.get_children():
        node.queue_free()
    var all_ready = not players.is_empty()
    for player in players:
        var label = Label.new()
        var ready_state = bool(player.get("ready", false))
        label.text = str(player.get("name", "Contestant")) + (" - READY" if ready_state else " - WAITING")
        player_list.add_child(label)
        all_ready = all_ready and ready_state
    start_button.disabled = not (session_valid and all_ready)

func clear_session() -> void:
    session_valid = false
    session_url = ""
    if is_instance_valid(qr):
        qr.texture = null
        code_label.text = ""
        status_label.text = "No live session connected."
        start_button.disabled = true
