extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const SceneNav := preload("res://scripts/scene_nav.gd")
const ENEMY_SCENE := preload("res://scenes/levels/Michael/enemy.tscn")
const GOAL_SCENE := preload("res://scenes/levels/Michael/level_goal.tscn")

const LEVEL_NAMES := ["Malkuth", "Yesod", "Hod", "Netzach", "Tiphereth"]

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var _score_mgr: Node = get_node("/root/ScoreManager")
@onready var mike: CharacterBody2D = $Mike
@onready var status_label: Label = $StatusLabel
@onready var next_level_button: Button = $GameUI/NextLevelButton

var level_goal: Area2D
var _enemies: Array[Node] = []
var _goal_x := 1180.0


func _ready() -> void:
	if not _game_manager.mike_advance_level:
		_game_manager.mike_level = 1
	else:
		_game_manager.mike_advance_level = false

	add_child(HUD_SCENE.instantiate())
	_add_parallax()
	_configure_background()
	_apply_background()
	_apply_level_layout()
	_settings.background_style_changed.connect(_on_background_style_changed)
	_settings.game_options_changed.connect(_on_game_options_changed)
	_game_manager.set_score(0)
	var level_name: String = LEVEL_NAMES[mini(_game_manager.mike_level - 1, LEVEL_NAMES.size() - 1)]
	_game_manager.set_stat("Level", _game_manager.mike_level)
	status_label.text = level_name
	_score_mgr.set_mike_level(_game_manager.mike_level)
	_spawn_enemies()
	_spawn_goal()
	_game_manager.current_game_id = "mike"


func _apply_level_layout() -> void:
	var level: int = int(_game_manager.mike_level)
	_goal_x = 1180.0 + (level - 1) * 100.0
	if level_goal:
		level_goal.global_position.x = _goal_x


func _spawn_enemies() -> void:
	_clear_enemies()
	var count := mini(_settings.mike_enemy_count + (_game_manager.mike_level - 1), 8)
	var spawn_points := [
		Vector2(520, 560), Vector2(820, 560), Vector2(980, 430),
		Vector2(680, 430), Vector2(1100, 560), Vector2(400, 560),
		Vector2(900, 430), Vector2(1050, 430),
	]
	for i in count:
		var enemy := ENEMY_SCENE.instantiate()
		enemy.global_position = spawn_points[i % spawn_points.size()]
		if i % 3 == 1:
			enemy.enemy_type = "runner"
		add_child(enemy)
		_enemies.append(enemy)


func _clear_enemies() -> void:
	for enemy in _enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_enemies.clear()


func _spawn_goal() -> void:
	if level_goal:
		level_goal.queue_free()
	level_goal = GOAL_SCENE.instantiate()
	level_goal.global_position = Vector2(_goal_x, 560)
	add_child(level_goal)
	level_goal.level_completed.connect(_on_level_completed)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	var tint: float = 0.12 + float(_game_manager.mike_level) * 0.02
	gradient.top_color = Color(tint, 0.18 + tint, 0.42, 1.0)
	gradient.bottom_color = Color(0.04, 0.06, 0.18, 1.0)


func _apply_background() -> void:
	_settings.apply_background(self, _settings.LEGACY_MIKE)


func _on_background_style_changed(_style: String) -> void:
	_apply_background()


func _on_game_options_changed() -> void:
	_spawn_enemies()


func _on_level_completed() -> void:
	status_label.text = "Level Complete!"
	var score: int = 1000 * int(_game_manager.mike_level)
	_game_manager.set_score(score)
	mike.set_physics_process(false)
	mike.velocity = Vector2.ZERO
	next_level_button.visible = true
	get_node("/root/AudioManager").play_sfx("level_complete")


func _on_next_level_pressed() -> void:
	_game_manager.mike_level += 1
	_game_manager.mike_advance_level = true
	get_tree().reload_current_scene()


func _on_back_to_menu_pressed() -> void:
	_game_manager.mike_level = 1
	_game_manager.mike_advance_level = false
	SceneNav.go("res://scenes/UI/main_menu.tscn")


func get_player_position() -> Vector2:
	return mike.global_position


func _add_parallax() -> void:
	var bg := ParallaxBackground.new()
	bg.set_script(load("res://scripts/parallax_setup.gd"))
	bg.layer_colors = [
		Color(0.05, 0.08, 0.22, 0.8),
		Color(0.08, 0.12, 0.28, 0.6),
	]
	add_child(bg)
	move_child(bg, 1)
