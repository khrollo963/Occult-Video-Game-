extends Control

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/uriel/yuri_game.tscn")

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
