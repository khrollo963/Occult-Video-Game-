extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_add_back_button()


func _add_back_button() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 2
	var button := Button.new()
	button.text = "Back to Menu"
	button.position = Vector2(16, 56)
	button.pressed.connect(_on_back_to_menu_pressed)
	ui.add_child(button)
	add_child(ui)


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
