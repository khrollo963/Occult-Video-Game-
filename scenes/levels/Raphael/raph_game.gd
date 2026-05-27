extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const PLATFORM_SCENE := preload("res://scenes/levels/Raphael/raph_platform.tscn")

@export var platform_count := 18
@export var min_platform_gap := 70.0
@export var max_platform_gap := 130.0

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var platforms: Node2D = $Platforms

var highest_y := 0.0
var spawn_cursor_y := 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	camera.make_current()
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_game_manager.set_score(0)
	_game_manager.set_stat("Height", 0)
	_spawn_starting_platforms()


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.98, 0.92, 0.72, 1.0)
	gradient.bottom_color = Color(0.92, 0.78, 0.55, 1.0)


func _spawn_starting_platforms() -> void:
	spawn_cursor_y = 620.0
	_spawn_platform(Vector2(640.0, 620.0))
	for i in platform_count:
		_spawn_platform_above()


func _spawn_platform_above() -> void:
	spawn_cursor_y -= rng.randf_range(min_platform_gap, max_platform_gap)
	var x := rng.randf_range(120.0, 1160.0)
	_spawn_platform(Vector2(x, spawn_cursor_y))


func _spawn_platform(pos: Vector2) -> void:
	var platform := PLATFORM_SCENE.instantiate()
	platform.position = pos
	platforms.add_child(platform)


func _process(_delta: float) -> void:
	if player.is_dead:
		return

	if player.global_position.y < camera.global_position.y:
		camera.global_position.y = player.global_position.y

	if player.global_position.y > camera.global_position.y + 420.0:
		player.die()
		return

	var player_height := int(maxf(0.0, 620.0 - player.global_position.y))
	_game_manager.set_score(player_height)
	_game_manager.set_stat("Height", player_height)

	if player.global_position.y < highest_y:
		highest_y = player.global_position.y

	while spawn_cursor_y > player.global_position.y - 720.0:
		_spawn_platform_above()

	_cleanup_platforms()


func _cleanup_platforms() -> void:
	var cutoff := player.global_position.y + 820.0
	for child in platforms.get_children():
		if child.global_position.y > cutoff:
			child.queue_free()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
