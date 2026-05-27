extends Control

@export var drift_speed := 28.0


func _process(delta: float) -> void:
	position.x = wrapf(position.x - drift_speed * delta, -1280.0, 0.0)
