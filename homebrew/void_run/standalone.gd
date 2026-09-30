extends Node

@export var game_scene: PackedScene

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	for device in Input.get_connected_joypads():
		print("CABINET_INPUT device=", device, " name=", Input.get_joy_name(device), " guid=", Input.get_joy_guid(device))
	var game := game_scene.instantiate()
	game.finished.connect(_on_game_finished)
	add_child(game)

func _on_game_finished(_payout: int, summary: String) -> void:
	print(summary)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
