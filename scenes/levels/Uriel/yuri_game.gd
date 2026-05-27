extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const OBSTACLE_SCENE := preload("res://scenes/levels/Uriel/obstacle.tscn")

@export var base_scroll_speed := 320.0
@export var speed_ramp := 8.0
@export var max_scroll_speed := 650.0

@onready var _game_manager: Node = get_node("/root/GameManager")

var distance := 0.0
var scroll_speed := base_scroll_speed
var obstacle_timer := 1.5


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_game_manager.set_score(0)
	_game_manager.set_stat("Distance", 0)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.18, 0.42, 0.22, 1.0)
	gradient.bottom_color = Color(0.05, 0.18, 0.1, 1.0)


func _process(delta: float) -> void:
	scroll_speed = minf(base_scroll_speed + distance * 0.02, max_scroll_speed)
	distance += scroll_speed * delta
	_game_manager.set_score(int(distance))
	_game_manager.set_stat("Distance", int(distance))
	handle_spawns(delta)


func handle_spawns(delta: float) -> void:
	obstacle_timer -= delta
	if obstacle_timer > 0.0:
		return

	spawn_obstacle()
	var interval := randf_range(1.4, 2.6) - minf(distance / 8000.0, 0.6)
	obstacle_timer = maxf(interval, 0.7)


func spawn_obstacle() -> void:
	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.position = Vector2(1350.0, 565.0)
	obstacle.speed = scroll_speed
	add_child(obstacle)


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
