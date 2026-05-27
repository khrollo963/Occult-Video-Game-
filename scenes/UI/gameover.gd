extends CanvasLayer

const SceneNav := preload("res://scripts/scene_nav.gd")

@onready var score_banner: Label = $CenterContainer/VBoxContainer/ScoreBanner


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var gm: Node = _game_manager()
	if gm.last_run_score > 0:
		var text := "Score: %d" % gm.last_run_score
		if gm.last_run_new_best:
			text += "\nNEW PERSONAL BEST!"
		score_banner.text = text
	else:
		score_banner.text = ""
	var bus: Node = get_node("/root/EventBus")
	bus.score_submitted.connect(_on_score_submitted)
	bus.leaderboard_ranked.connect(_on_leaderboard_ranked)


func _append_banner(line: String) -> void:
	if score_banner.text.is_empty():
		score_banner.text = line
	else:
		score_banner.text += "\n" + line


func _on_score_submitted(game_id: String, _score: int, success: bool) -> void:
	if not success or game_id != _game_manager().current_game_id:
		return
	_append_banner("Submitted to leaderboard!")


func _on_leaderboard_ranked(game_id: String, _score: int, rank: int) -> void:
	if game_id != _game_manager().current_game_id or rank <= 0 or rank > 10:
		return
	_append_banner("GLOBAL TOP 10 — #%d!" % rank)
	get_node("/root/AudioManager").play_sfx("new_high_score")


func _game_manager() -> Node:
	return get_node("/root/GameManager")


func _on_retry_pressed() -> void:
	get_node("/root/AudioManager").play_ui_click()
	_game_manager().hide_game_over()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	get_node("/root/AudioManager").play_ui_click()
	_game_manager().hide_game_over()
	SceneNav.go("res://scenes/UI/main_menu.tscn")
