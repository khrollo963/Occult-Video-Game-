extends Node

signal health_changed(current: int, maximum: int)
signal score_changed(score: int)
signal stat_changed(label: String, value: int)


func set_health(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)


func set_score(score: int) -> void:
	score_changed.emit(score)


func set_stat(label: String, value: int) -> void:
	stat_changed.emit(label, value)


func show_game_over() -> void:
	get_tree().paused = true


func hide_game_over() -> void:
	get_tree().paused = false
