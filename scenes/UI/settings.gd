extends Control

@onready var _settings: Node = get_node("/root/SettingsManager")

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
	_refresh_labels()


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


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
