extends CanvasLayer

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var health_label: Label = $MarginContainer/TopBar/HealthLabel
@onready var score_label: Label = $MarginContainer/TopBar/ScoreLabel
@onready var stat_label: Label = $MarginContainer/TopBar/StatLabel


func _ready() -> void:
	_game_manager.health_changed.connect(_on_health_changed)
	_game_manager.score_changed.connect(_on_score_changed)
	_game_manager.stat_changed.connect(_on_stat_changed)
	_game_manager.apply_cached_hud(self)


func set_health(current: int, maximum: int) -> void:
	health_label.text = "HP: %d/%d" % [current, maximum]


func set_score(score: int) -> void:
	score_label.text = "Score: %d" % score


func set_stat(label: String, value: int) -> void:
	stat_label.text = "%s: %d" % [label, value]


func hide_stat() -> void:
	stat_label.text = ""


func _on_health_changed(current: int, maximum: int) -> void:
	set_health(current, maximum)


func _on_score_changed(score: int) -> void:
	set_score(score)


func _on_stat_changed(label: String, value: int) -> void:
	set_stat(label, value)
