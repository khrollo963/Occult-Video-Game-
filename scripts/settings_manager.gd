extends Node

signal background_style_changed(style: String)
signal game_options_changed

const SETTINGS_PATH := "user://settings.cfg"

const BACKGROUND_GRADIENT := "gradient"
const BACKGROUND_CLASSIC := "classic"

var background_style: String = BACKGROUND_GRADIENT
var mike_enemy_count: int = 3
var gabe_spawn_rate: float = 1.0
var yuri_scroll_speed: float = 1.0
var yuri_obstacle_rate: float = 1.0
var raph_platform_gap: float = 1.0


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	background_style = str(config.get_value("display", "background_style", BACKGROUND_GRADIENT))
	mike_enemy_count = int(config.get_value("games", "mike_enemy_count", 3))
	gabe_spawn_rate = float(config.get_value("games", "gabe_spawn_rate", 1.0))
	yuri_scroll_speed = float(config.get_value("games", "yuri_scroll_speed", 1.0))
	yuri_obstacle_rate = float(config.get_value("games", "yuri_obstacle_rate", 1.0))
	raph_platform_gap = float(config.get_value("games", "raph_platform_gap", 1.0))
	_clamp_all()


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "background_style", background_style)
	config.set_value("games", "mike_enemy_count", mike_enemy_count)
	config.set_value("games", "gabe_spawn_rate", gabe_spawn_rate)
	config.set_value("games", "yuri_scroll_speed", yuri_scroll_speed)
	config.set_value("games", "yuri_obstacle_rate", yuri_obstacle_rate)
	config.set_value("games", "raph_platform_gap", raph_platform_gap)
	config.save(SETTINGS_PATH)


func set_background_style(style: String) -> void:
	var next := BACKGROUND_CLASSIC if style == BACKGROUND_CLASSIC else BACKGROUND_GRADIENT
	if background_style == next:
		return
	background_style = next
	save_settings()
	background_style_changed.emit(background_style)


func set_mike_enemy_count(count: int) -> void:
	var next := clampi(count, 1, 5)
	if mike_enemy_count == next:
		return
	mike_enemy_count = next
	save_settings()
	game_options_changed.emit()


func set_gabe_spawn_rate(rate: float) -> void:
	var next := clampf(rate, 0.5, 2.0)
	if is_equal_approx(gabe_spawn_rate, next):
		return
	gabe_spawn_rate = next
	save_settings()
	game_options_changed.emit()


func set_yuri_scroll_speed(rate: float) -> void:
	var next := clampf(rate, 0.6, 1.4)
	if is_equal_approx(yuri_scroll_speed, next):
		return
	yuri_scroll_speed = next
	save_settings()
	game_options_changed.emit()


func set_yuri_obstacle_rate(rate: float) -> void:
	var next := clampf(rate, 0.5, 2.0)
	if is_equal_approx(yuri_obstacle_rate, next):
		return
	yuri_obstacle_rate = next
	save_settings()
	game_options_changed.emit()


func set_raph_platform_gap(gap: float) -> void:
	var next := clampf(gap, 0.7, 1.5)
	if is_equal_approx(raph_platform_gap, next):
		return
	raph_platform_gap = next
	save_settings()
	game_options_changed.emit()


func _clamp_all() -> void:
	mike_enemy_count = clampi(mike_enemy_count, 1, 5)
	gabe_spawn_rate = clampf(gabe_spawn_rate, 0.5, 2.0)
	yuri_scroll_speed = clampf(yuri_scroll_speed, 0.6, 1.4)
	yuri_obstacle_rate = clampf(yuri_obstacle_rate, 0.5, 2.0)
	raph_platform_gap = clampf(raph_platform_gap, 0.7, 1.5)
