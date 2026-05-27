extends Control

const GAME_SCENES := [
	"res://scenes/levels/Michael/mike_game.tscn",
	"res://scenes/levels/Gabriel/gabe_game.tscn",
	"res://scenes/levels/Uriel/yuri_game.tscn",
	"res://scenes/levels/Raphael/raph_game.tscn",
]

@onready var _settings: Node = get_node("/root/SettingsManager")


func _ready() -> void:
	_configure_background()
	_apply_background()
	_settings.background_style_changed.connect(_on_background_style_changed)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _apply_background() -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func start_random_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENES.pick_random())


func _on_start_button_pressed() -> void:
	start_random_game()


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/settings.tscn")


func _on_scripture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/scripture.tscn")


func _on_button_mike_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[0])


func _on_button_gabe_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[1])


func _on_button_yuri_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[2])


func _on_button_raph_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENES[3])


func _on_background_style_changed(_style: String) -> void:
	_apply_background()
