extends Control

const SceneNav := preload("res://scripts/scene_nav.gd")

const HOW_TO_PLAY_TEXT := """[font_size=22][b]How to Play[/b][/font_size]

[b]Global Controls[/b]
• Move: A / D or Left / Right arrows
• Jump: Space
• Attack: Enter
• Duck: S or Down arrow (Yuri overhead obstacles)
• Pause: Escape
• Confirm: Enter / Space

[b]Mike — Daunting Quest[/b]
Side-scrolling platformer. Reach the goal flag, attack enemies with Enter, and avoid contact damage.

[b]Gabe — Spectacular Collector[/b]
Fly with Space, move horizontally, collect green apples, and dodge red hazards. Survive 9 waves of increasing chaos.

[b]Yuri — Crazy Endless Runner[/b]
Auto-run forward. Jump over ground obstacles and duck under overhead beams. Grab power-ups when they appear.

[b]Raph — Funny Flight[/b]
Bounce upward on platforms. Move left and right. Avoid spikes and crumbling platforms — do not fall below the camera.

[b]Leaderboard[/b]
Set your 3-character arcade initials below. Scores submit automatically when a run ends."""

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var _score_mgr: Node = get_node("/root/ScoreManager")
@onready var background_option: OptionButton = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/BackgroundRow/BackgroundOption
@onready var mike_slider: HSlider = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/MikeRow/MikeSlider
@onready var mike_value: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/MikeRow/MikeValue
@onready var gabe_slider: HSlider = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/GabeRow/GabeSlider
@onready var gabe_value: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/GabeRow/GabeValue
@onready var yuri_speed_slider: HSlider = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/YuriSpeedRow/YuriSpeedSlider
@onready var yuri_speed_value: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/YuriSpeedRow/YuriSpeedValue
@onready var yuri_obstacle_slider: HSlider = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/YuriObstacleRow/YuriObstacleSlider
@onready var yuri_obstacle_value: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/YuriObstacleRow/YuriObstacleValue
@onready var raph_slider: HSlider = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/RaphRow/RaphSlider
@onready var raph_value: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/RaphRow/RaphValue
@onready var initials_edit: LineEdit = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/InitialsRow/InitialsEdit
@onready var initials_status: Label = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/InitialsRow/InitialsStatus
@onready var vfx_check: CheckBox = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/VfxRow/VfxCheck
@onready var parallax_check: CheckBox = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/ParallaxRow/ParallaxCheck
@onready var how_to_play_label: RichTextLabel = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/HowToPlayLabel
@onready var medals_list: VBoxContainer = $MarginContainer/VBox/ScrollContainer/PanelContainer/VBox/MedalsList


func _ready() -> void:
	_configure_background()
	_settings.apply_background(self, _settings.LEGACY_MENU)
	_settings.background_style_changed.connect(_on_background_style_changed)

	background_option.clear()
	background_option.add_item("Gradient", 0)
	background_option.add_item("Classic", 1)
	background_option.selected = 1 if _settings.background_style == "classic" else 0

	mike_slider.value = _settings.mike_enemy_count
	gabe_slider.value = _settings.gabe_spawn_rate
	yuri_speed_slider.value = _settings.yuri_scroll_speed
	yuri_obstacle_slider.value = _settings.yuri_obstacle_rate
	raph_slider.value = _settings.raph_platform_gap
	initials_edit.text = _settings.get_initials()
	vfx_check.button_pressed = _settings.visual_effects_enabled
	parallax_check.button_pressed = _settings.parallax_enabled
	how_to_play_label.text = HOW_TO_PLAY_TEXT
	_refresh_medals()
	_refresh_labels()
	get_node("/root/EventBus").medal_unlocked.connect(func(_id): _refresh_medals())


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _refresh_labels() -> void:
	mike_value.text = str(int(mike_slider.value))
	gabe_value.text = "%.1fx" % gabe_slider.value
	yuri_speed_value.text = "%.1fx" % yuri_speed_slider.value
	yuri_obstacle_value.text = "%.1fx" % yuri_obstacle_slider.value
	raph_value.text = "%.1fx" % raph_slider.value


func _refresh_medals() -> void:
	for child in medals_list.get_children():
		child.queue_free()
	for entry in _score_mgr.get_medal_entries():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(18, 18)
		icon.color = Color(1.0, 0.82, 0.2, 1.0) if entry["unlocked"] else Color(0.45, 0.42, 0.55, 1.0)
		row.add_child(icon)
		var label := Label.new()
		label.text = entry["label"]
		label.modulate = Color(1.0, 0.95, 0.7) if entry["unlocked"] else Color(0.75, 0.72, 0.82)
		row.add_child(label)
		medals_list.add_child(row)


func _on_background_option_item_selected(index: int) -> void:
	_settings.set_background_style("classic" if index == 1 else "gradient")


func _on_mike_slider_value_changed(value: float) -> void:
	_settings.set_mike_enemy_count(int(value))
	_refresh_labels()


func _on_gabe_slider_value_changed(value: float) -> void:
	_settings.set_gabe_spawn_rate(value)
	_refresh_labels()


func _on_yuri_speed_slider_value_changed(value: float) -> void:
	_settings.set_yuri_scroll_speed(value)
	_refresh_labels()


func _on_yuri_obstacle_slider_value_changed(value: float) -> void:
	_settings.set_yuri_obstacle_rate(value)
	_refresh_labels()


func _on_raph_slider_value_changed(value: float) -> void:
	_settings.set_raph_platform_gap(value)
	_refresh_labels()


func _on_initials_edit_text_submitted(new_text: String) -> void:
	_save_initials(new_text)


func _on_initials_edit_focus_exited() -> void:
	_save_initials(initials_edit.text)


func _save_initials(text: String) -> void:
	if _settings.set_initials(text):
		initials_status.text = "Saved: %s" % _settings.get_initials()
		initials_status.modulate = Color(0.6, 1.0, 0.6)
	else:
		initials_status.text = "Use exactly 3 letters or numbers"
		initials_status.modulate = Color(1.0, 0.5, 0.5)


func _on_vfx_check_toggled(pressed: bool) -> void:
	_settings.set_visual_effects_enabled(pressed)


func _on_parallax_check_toggled(pressed: bool) -> void:
	_settings.set_parallax_enabled(pressed)


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _on_back_pressed() -> void:
	get_node("/root/AudioManager").play_ui_click()
	SceneNav.go("res://scenes/UI/main_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
