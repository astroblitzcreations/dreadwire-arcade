extends RefCounted
class_name WindingPatternRunner

var checkpoints: Array[float] = []
var reached_checkpoints: Array[float] = []
var next_checkpoint_index := 0


func configure(level_data: Dictionary) -> void:
	checkpoints.clear()
	reached_checkpoints.clear()
	next_checkpoint_index = 0
	var rows: Array = level_data.get("checkpoints", [])
	for row in rows:
		checkpoints.append(float(row))
	checkpoints.sort()


func poll_checkpoint(camera_z: float) -> float:
	if next_checkpoint_index >= checkpoints.size():
		return -1.0
	var checkpoint := checkpoints[next_checkpoint_index]
	if camera_z >= checkpoint:
		next_checkpoint_index += 1
		reached_checkpoints.append(checkpoint)
		return checkpoint
	return -1.0


func reset_to_checkpoint(checkpoint_z: float) -> void:
	next_checkpoint_index = 0
	reached_checkpoints.clear()
	for checkpoint in checkpoints:
		if checkpoint <= checkpoint_z:
			next_checkpoint_index += 1
			reached_checkpoints.append(checkpoint)
