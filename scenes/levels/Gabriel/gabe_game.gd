extends Node2D

const HUD_SCENE := preload("res://scenes/UI/hud.tscn")

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var spawner: Node = $Spawner


func _ready() -> void:
	add_child(HUD_SCENE.instantiate())
	_configure_background()
	_apply_background()
	_add_back_button()
	_settings.background_style_changed.connect(_on_background_style_changed)
	if spawner.has_method("apply_spawn_rate"):
		spawner.apply_spawn_rate(_settings.gabe_spawn_rate)
	_settings.game_options_changed.connect(_on_game_options_changed)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.45, 0.75, 0.98, 1.0)
	gradient.bottom_color = Color(0.05, 0.35, 0.85, 1.0)


func _apply_background() -> void:
	BackgroundApplier.apply(self, BackgroundApplier.LEGACY_GABE)


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
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
