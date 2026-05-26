extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	show()


func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
