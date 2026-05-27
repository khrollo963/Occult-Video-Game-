extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
