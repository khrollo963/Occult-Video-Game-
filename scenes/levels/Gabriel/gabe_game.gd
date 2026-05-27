extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")
const SceneNav := preload("res://scripts/scene_nav.gd")

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var spawner: Node = $Spawner


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_add_parallax()
	_configure_background()
	_apply_background()
	_add_back_button()
	_settings.background_style_changed.connect(_on_background_style_changed)
	if spawner.has_method("apply_spawn_rate"):
		spawner.apply_spawn_rate(_settings.gabe_spawn_rate)
	_settings.game_options_changed.connect(_on_game_options_changed)
	_game_manager.set_score(0)
	_game_manager.set_stat("Wave", 1)
	_game_manager.current_game_id = "gabe"


func _process(delta: float) -> void:
	if spawner.has_method("handle_collectibles"):
		spawner.handle_collectibles(delta)
	if spawner.has_method("handle_hazards"):
		spawner.handle_hazards(delta)
	if spawner.has_method("get_wave"):
		_game_manager.set_stat("Wave", spawner.get_wave())


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.45, 0.75, 0.98, 1.0)
	gradient.bottom_color = Color(0.05, 0.35, 0.85, 1.0)


func _apply_background() -> void:
	_settings.apply_background(self, _settings.LEGACY_GABE)


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


func _on_game_options_changed() -> void:
	if spawner.has_method("apply_spawn_rate"):
		spawner.apply_spawn_rate(_settings.gabe_spawn_rate)


func _on_background_style_changed(_style: String) -> void:
	_apply_background()


func _on_back_to_menu_pressed() -> void:
	SceneNav.go("res://scenes/UI/main_menu.tscn")


func get_player_position() -> Vector2:
	var player := get_node_or_null("Gabe")
	if player:
		return player.global_position
	return Vector2.ZERO


func _add_parallax() -> void:
	var bg := ParallaxBackground.new()
	bg.set_script(load("res://scripts/parallax_setup.gd"))
	add_child(bg)
	move_child(bg, 1)
