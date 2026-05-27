extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const OBSTACLE_SCENE := preload("res://scenes/levels/Uriel/obstacle.tscn")
const OVERHEAD_SCENE := preload("res://scenes/levels/Uriel/obstacle_overhead.tscn")

@export var base_scroll_speed := 320.0
@export var speed_ramp := 8.0
@export var max_scroll_speed := 650.0

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var _settings: Node = get_node("/root/SettingsManager")

var distance := 0.0
var scroll_speed := base_scroll_speed
var obstacle_timer := 1.5
var _speed_multiplier := 1.0
var _obstacle_multiplier := 1.0


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_apply_background()
	_apply_game_options()
	_settings.background_style_changed.connect(_on_background_style_changed)
	_settings.game_options_changed.connect(_on_game_options_changed)
	_game_manager.set_score(0)
	_game_manager.set_stat("Distance", 0)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.18, 0.42, 0.22, 1.0)
	gradient.bottom_color = Color(0.05, 0.18, 0.1, 1.0)


func _apply_background() -> void:
	BackgroundApplier.apply(self, BackgroundApplier.LEGACY_YURI)


func _apply_game_options() -> void:
	_speed_multiplier = _settings.yuri_scroll_speed
	_obstacle_multiplier = _settings.yuri_obstacle_rate


func _process(delta: float) -> void:
	var effective_base := base_scroll_speed * _speed_multiplier
	scroll_speed = minf(effective_base + distance * 0.02, max_scroll_speed * _speed_multiplier)
	distance += scroll_speed * delta
	_game_manager.set_score(int(distance))
	_game_manager.set_stat("Distance", int(distance))
	handle_spawns(delta)


func handle_spawns(delta: float) -> void:
	obstacle_timer -= delta * _obstacle_multiplier
	if obstacle_timer > 0.0:
		return

	spawn_obstacle()
	var interval := randf_range(1.4, 2.6) - minf(distance / 8000.0, 0.6)
	obstacle_timer = maxf(interval / _obstacle_multiplier, 0.7)


func spawn_obstacle() -> void:
	if randf() < 0.5:
		spawn_overhead_obstacle()
	else:
		spawn_ground_obstacle()


func spawn_ground_obstacle() -> void:
	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.position = Vector2(1350.0, 565.0)
	obstacle.speed = scroll_speed
	add_child(obstacle)


func spawn_overhead_obstacle() -> void:
	var obstacle := OVERHEAD_SCENE.instantiate()
	obstacle.position = Vector2(1350.0, 488.0)
	obstacle.speed = scroll_speed
	add_child(obstacle)


func _on_background_style_changed(_style: String) -> void:
	_apply_background()


func _on_game_options_changed() -> void:
	_apply_game_options()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
