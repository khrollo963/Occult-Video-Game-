extends Node

signal background_style_changed(style: String)
signal game_options_changed
signal player_identity_changed

const SETTINGS_PATH := "user://settings.cfg"

const BACKGROUND_GRADIENT := "gradient"
const BACKGROUND_CLASSIC := "classic"

const LEGACY_MENU := Color(0.37280384, 0.2171683, 0.5887938, 1.0)
const LEGACY_MIKE := Color(1.0, 0.0, 0.0, 1.0)
const LEGACY_GABE := Color(0.0, 0.023529412, 0.9098039, 1.0)
const LEGACY_YURI := Color(0.08, 0.25, 0.12, 1.0)
const LEGACY_RAPH := Color(1.0, 1.0, 0.2, 1.0)

var background_style: String = BACKGROUND_GRADIENT
var mike_enemy_count: int = 3
var gabe_spawn_rate: float = 1.0
var yuri_scroll_speed: float = 1.0
var yuri_obstacle_rate: float = 1.0
var raph_platform_gap: float = 1.0
var player_initials: String = ""
var session_id: String = ""
var visual_effects_enabled: bool = true
var parallax_enabled: bool = true


func _ready() -> void:
	load_settings()
	ensure_session_id()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		if OS.has_feature("web"):
			parallax_enabled = false
		return

	background_style = str(config.get_value("display", "background_style", BACKGROUND_GRADIENT))
	mike_enemy_count = int(config.get_value("games", "mike_enemy_count", 3))
	gabe_spawn_rate = float(config.get_value("games", "gabe_spawn_rate", 1.0))
	yuri_scroll_speed = float(config.get_value("games", "yuri_scroll_speed", 1.0))
	yuri_obstacle_rate = float(config.get_value("games", "yuri_obstacle_rate", 1.0))
	raph_platform_gap = float(config.get_value("games", "raph_platform_gap", 1.0))
	player_initials = str(config.get_value("player", "initials", "")).to_upper()
	session_id = str(config.get_value("player", "session_id", ""))
	visual_effects_enabled = bool(config.get_value("display", "visual_effects", true))
	parallax_enabled = bool(config.get_value("display", "parallax", true))
	_clamp_all()


func save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("display", "background_style", background_style)
	config.set_value("display", "visual_effects", visual_effects_enabled)
	config.set_value("display", "parallax", parallax_enabled)
	config.set_value("games", "mike_enemy_count", mike_enemy_count)
	config.set_value("games", "gabe_spawn_rate", gabe_spawn_rate)
	config.set_value("games", "yuri_scroll_speed", yuri_scroll_speed)
	config.set_value("games", "yuri_obstacle_rate", yuri_obstacle_rate)
	config.set_value("games", "raph_platform_gap", raph_platform_gap)
	config.set_value("player", "initials", player_initials)
	config.set_value("player", "session_id", session_id)
	config.save(SETTINGS_PATH)


func ensure_session_id() -> void:
	if session_id.is_empty():
		session_id = _generate_uuid()
		save_settings()


func get_session_id() -> String:
	ensure_session_id()
	return session_id


func get_initials() -> String:
	return player_initials


func set_initials(value: String) -> bool:
	var cleaned := value.strip_edges().to_upper()
	if cleaned.length() != 3:
		return false
	for i in 3:
		var ch: String = cleaned[i]
		if not ((ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9")):
			return false
	player_initials = cleaned
	save_settings()
	player_identity_changed.emit()
	return true


func needs_initials_prompt() -> bool:
	return player_initials.length() != 3


func set_visual_effects_enabled(enabled: bool) -> void:
	if visual_effects_enabled == enabled:
		return
	visual_effects_enabled = enabled
	save_settings()
	game_options_changed.emit()


func set_parallax_enabled(enabled: bool) -> void:
	if parallax_enabled == enabled:
		return
	parallax_enabled = enabled
	save_settings()
	game_options_changed.emit()


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


func apply_background(root: Node, legacy_color: Color) -> void:
	var use_classic := background_style == BACKGROUND_CLASSIC
	var gradient := root.get_node_or_null("SimpleGradientBg")
	var decor := root.get_node_or_null("SkyOverlay")
	var legacy := root.get_node_or_null("LegacyBackground")
	var parallax := root.get_node_or_null("ParallaxBackground")

	if gradient:
		gradient.visible = not use_classic
	if decor:
		decor.visible = not use_classic and parallax_enabled
	if parallax:
		parallax.visible = parallax_enabled and not use_classic
	if legacy:
		legacy.visible = use_classic
		var fill: ColorRect = legacy.get_node_or_null("Fill")
		if fill:
			fill.color = legacy_color


func _clamp_all() -> void:
	mike_enemy_count = clampi(mike_enemy_count, 1, 5)
	gabe_spawn_rate = clampf(gabe_spawn_rate, 0.5, 2.0)
	yuri_scroll_speed = clampf(yuri_scroll_speed, 0.6, 1.4)
	yuri_obstacle_rate = clampf(yuri_obstacle_rate, 0.5, 2.0)
	raph_platform_gap = clampf(raph_platform_gap, 0.7, 1.5)


func _generate_uuid() -> String:
	var bytes := PackedByteArray()
	bytes.resize(16)
	for i in 16:
		bytes[i] = randi() % 256
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5], bytes[6], bytes[7],
		bytes[8], bytes[9], bytes[10], bytes[11],
		bytes[12], bytes[13], bytes[14], bytes[15],
	]
