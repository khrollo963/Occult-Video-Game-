extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const ENEMY_SCENE := preload("res://scenes/levels/Michael/enemy.tscn")
const GOAL_SCENE := preload("res://scenes/levels/Michael/level_goal.tscn")

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var mike: CharacterBody2D = $Mike
@onready var status_label: Label = $StatusLabel

var level_goal: Area2D


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_game_manager.set_score(0)
	_game_manager.set_stat("Level", 1)
	_spawn_enemies()
	_spawn_goal()


func _spawn_enemies() -> void:
	var spawn_points := [Vector2(520, 560), Vector2(820, 560), Vector2(980, 430)]
	for point in spawn_points:
		var enemy := ENEMY_SCENE.instantiate()
		enemy.global_position = point
		add_child(enemy)


func _spawn_goal() -> void:
	level_goal = GOAL_SCENE.instantiate()
	level_goal.global_position = Vector2(1180, 560)
	add_child(level_goal)
	level_goal.level_completed.connect(_on_level_completed)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.12, 0.18, 0.42, 1.0)
	gradient.bottom_color = Color(0.04, 0.06, 0.18, 1.0)


func _on_level_completed() -> void:
	status_label.text = "Level Complete!"
	_game_manager.set_score(1000)
	mike.set_physics_process(false)
	mike.velocity = Vector2.ZERO


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
