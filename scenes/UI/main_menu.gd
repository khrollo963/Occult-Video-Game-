extends Control

const GAME_SCENES := [
	"res://scenes/levels/Michael/mike_game.tscn",
	"res://scenes/levels/Gabriel/gabe_game.tscn",
	"res://scenes/levels/Uriel/yuri_game.tscn",
	"res://scenes/levels/Raphael/raph_game.tscn",
]


func _ready() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func start_random_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENES.pick_random())


func _on_start_button_pressed() -> void:
	start_random_game()


func _on_button_mike_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[0])


func _on_button_gabe_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[1])


func _on_button_yuri_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[2])


func _on_button_raph_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[3])
