extends CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _game_manager() -> Node:
	return get_node("/root/GameManager")


func _on_retry_pressed() -> void:
	_game_manager().hide_game_over()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	_game_manager().hide_game_over()
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_back_button_pressed() -> void:
	_on_menu_pressed()
