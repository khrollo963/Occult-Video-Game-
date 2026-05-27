extends Control

const SCRIPTURE_TEXT := """[font_size=24][b]Scripture[/b][/font_size]

[b]Ezekiel 1:10[/b]

As for the form of their faces, each had a human face; the four had the face of a lion on the right side; the four had the face of an ox on the left side; and the four had the face of an eagle.

[b]Revelation 4:7[/b]

The first living creature was like a lion,

the second living creature was like an ox,

the third living creature had a face like a man,

and the fourth living creature was like a flying eagle."""

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var body_label: RichTextLabel = $MarginContainer/VBox/ScrollContainer/PanelContainer/BodyLabel


func _ready() -> void:
	_configure_background()
	_settings.apply_background(self, _settings.LEGACY_MENU)
	_settings.background_style_changed.connect(_on_background_style_changed)
	body_label.text = SCRIPTURE_TEXT


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
