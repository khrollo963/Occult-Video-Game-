extends Node

signal health_changed(current: int, maximum: int)
signal score_changed(score: int)
signal stat_changed(label: String, value: int)

var _health_current := 0
var _health_maximum := 0
var _score := 0
var _stat_label := ""
var _stat_value := 0
var _has_health := false
var _has_score := false
var _has_stat := false


func set_health(current: int, maximum: int) -> void:
	_health_current = current
	_health_maximum = maximum
	_has_health = true
	health_changed.emit(current, maximum)


func set_score(score: int) -> void:
	_score = score
	_has_score = true
	score_changed.emit(score)


func set_stat(label: String, value: int) -> void:
	_stat_label = label
	_stat_value = value
	_has_stat = true
	stat_changed.emit(label, value)


func apply_cached_hud(hud: CanvasLayer) -> void:
	if _has_health and hud.has_method("set_health"):
		hud.set_health(_health_current, _health_maximum)
	if _has_score and hud.has_method("set_score"):
		hud.set_score(_score)
	if _has_stat and hud.has_method("set_stat"):
		hud.set_stat(_stat_label, _stat_value)


func show_game_over() -> void:
	get_tree().paused = true


func hide_game_over() -> void:
	get_tree().paused = false
