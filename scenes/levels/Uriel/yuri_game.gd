extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const SceneNav := preload("res://scripts/scene_nav.gd")
const ParallaxSetupScript := preload("res://scripts/parallax_setup.gd")
const OBSTACLE_SCENE := preload("res://scenes/levels/Uriel/obstacle.tscn")
const OVERHEAD_SCENE := preload("res://scenes/levels/Uriel/obstacle_overhead.tscn")
const POWERUP_SCENE := preload("res://scenes/levels/Uriel/powerup_pickup.tscn")

@export var base_scroll_speed := 320.0
@export var max_scroll_speed := 650.0

enum PowerUp { NONE, SHIELD, SLOW, MULTI }

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var yuri: CharacterBody2D = $Yuri

var distance := 0.0
var scroll_speed := base_scroll_speed
var obstacle_timer := 1.5
var powerup_timer := 8.0
var _speed_multiplier := 1.0
var _obstacle_multiplier := 1.0
var combo_streak := 0
var score_multiplier := 1.0
var active_powerup := PowerUp.NONE
var powerup_time_left := 0.0
var shield_hits := 0


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_add_parallax()
	_configure_background()
	_apply_background()
	_apply_game_options()
	_settings.background_style_changed.connect(_on_background_style_changed)
	_settings.game_options_changed.connect(_on_game_options_changed)
	_game_manager.set_score(0)
	_game_manager.set_stat("Distance", 0)
	_game_manager.current_game_id = "yuri"


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.18, 0.42, 0.22, 1.0)
	gradient.bottom_color = Color(0.05, 0.18, 0.1, 1.0)


func _apply_background() -> void:
	_settings.apply_background(self, _settings.LEGACY_YURI)


func _apply_game_options() -> void:
	_speed_multiplier = _settings.yuri_scroll_speed
	_obstacle_multiplier = _settings.yuri_obstacle_rate


func _process(delta: float) -> void:
	if yuri.is_dead:
		return

	var slow_factor := 0.65 if active_powerup == PowerUp.SLOW else 1.0
	var effective_base := base_scroll_speed * _speed_multiplier * slow_factor
	scroll_speed = minf(effective_base + distance * 0.02, max_scroll_speed * _speed_multiplier)
	var gained := scroll_speed * delta * score_multiplier
	distance += gained
	combo_streak += 1
	var display_score := int(distance)
	_game_manager.set_score(display_score)
	_game_manager.set_stat("Combo", combo_streak)
	handle_spawns(delta)
	handle_powerups(delta)


func handle_powerups(delta: float) -> void:
	if active_powerup != PowerUp.NONE:
		powerup_time_left -= delta
		if powerup_time_left <= 0.0:
			active_powerup = PowerUp.NONE
			score_multiplier = 1.0
			shield_hits = 0
	powerup_timer -= delta
	if powerup_timer <= 0.0:
		_spawn_powerup_pickup()
		powerup_timer = randf_range(10.0, 16.0)


func _spawn_powerup_pickup() -> void:
	var pickup := POWERUP_SCENE.instantiate()
	pickup.position = Vector2(1350.0, randf_range(420.0, 560.0))
	pickup.speed = scroll_speed
	if pickup.has_method("set_game"):
		pickup.set_game(self)
	add_child(pickup)


func collect_powerup() -> void:
	_apply_random_powerup()


func _apply_random_powerup() -> void:
	var roll := randi() % 3
	match roll:
		0:
			active_powerup = PowerUp.SHIELD
			shield_hits = 1
			powerup_time_left = 12.0
		1:
			active_powerup = PowerUp.SLOW
			powerup_time_left = 5.0
		2:
			active_powerup = PowerUp.MULTI
			score_multiplier = 2.0
			powerup_time_left = 8.0
	get_node("/root/AudioManager").play_sfx("pickup")


func register_hit() -> void:
	combo_streak = 0
	if active_powerup == PowerUp.SHIELD and shield_hits > 0:
		shield_hits -= 1
		if shield_hits <= 0:
			active_powerup = PowerUp.NONE
		return
	yuri.take_damage(1)


func handle_spawns(delta: float) -> void:
	obstacle_timer -= delta * _obstacle_multiplier
	if obstacle_timer > 0.0:
		return
	spawn_obstacle()
	var interval := randf_range(1.4, 2.6) - minf(distance / 8000.0, 0.6)
	obstacle_timer = maxf(interval / _obstacle_multiplier, 0.7)


func spawn_obstacle() -> void:
	if randf() < 0.45:
		spawn_overhead_obstacle()
	else:
		spawn_ground_obstacle()


func spawn_ground_obstacle() -> void:
	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.position = Vector2(1350.0, 565.0)
	obstacle.speed = scroll_speed
	if obstacle.has_method("set_game"):
		obstacle.set_game(self)
	add_child(obstacle)


func spawn_overhead_obstacle() -> void:
	var obstacle := OVERHEAD_SCENE.instantiate()
	obstacle.position = Vector2(1350.0, 488.0)
	obstacle.speed = scroll_speed
	if obstacle.has_method("set_game"):
		obstacle.set_game(self)
	add_child(obstacle)


func _on_background_style_changed(_style: String) -> void:
	_apply_background()


func _on_game_options_changed() -> void:
	_apply_game_options()


func _on_back_to_menu_pressed() -> void:
	SceneNav.go("res://scenes/UI/main_menu.tscn")


func get_player_position() -> Vector2:
	return yuri.global_position


func _add_parallax() -> void:
	var colors: Array[Color] = [
		Color(0.35, 0.12, 0.35, 0.5),
		Color(0.2, 0.45, 0.22, 0.45),
	]
	var bg: ParallaxBackground = ParallaxSetupScript.new()
	bg.layer_colors = colors
	add_child(bg)
	move_child(bg, 1)
