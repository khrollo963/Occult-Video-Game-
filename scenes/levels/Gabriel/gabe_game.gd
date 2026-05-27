extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_add_back_button()


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.45, 0.75, 0.98, 1.0)
	gradient.bottom_color = Color(0.05, 0.35, 0.85, 1.0)


func _add_back_button() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 2
	var button := Button.new()
	button.text = "Back to Menu"
	button.position = Vector2(16, 56)
	button.theme = preload("res://assets/ui/arcade_theme.tres")
	button.pressed.connect(_on_back_to_menu_pressed)
	ui.add_child(button)
	add_child(ui)


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
