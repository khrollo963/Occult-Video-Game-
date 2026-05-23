extends Control

func start_random_game():
	var games = [
		"res://scenes/levels/michael/mike_game.tscn",
		"res://scenes/levels/gabriel/gabe_game.tscn",
		"res://scenes/levels/uriel/yuri_game.tscn",
		"res://scenes/levels/raphael/raph_game.tscn"
	]
	var random_game = games[randi() % games.size()]
	get_tree().change_scene_to_file(random_game)

func _on_start_game_pressed():
	start_random_game()

func _on_start_button_pressed():
	start_random_game()

func _on_play_mike_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/michael/mike_game.tscn")

func _on_button_mike_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/michael/mike_game.tscn")

func _on_play_gabe_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/gabriel/gabe_game.tscn")

func _on_button_gabe_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/gabriel/gabe_game.tscn")

func _on_play_yuri_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/uriel/yuri_game.tscn")
func _on_button_yuri_pressed():
	print("Yuri button pressed!")
	get_tree().change_scene_to_file("res://scenes/levels/uriel/yuri_game.tscn")

func _on_play_raph_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/raphael/raph_game.tscn")

func _on_button_raph_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/raphael/raph_game.tscn")
