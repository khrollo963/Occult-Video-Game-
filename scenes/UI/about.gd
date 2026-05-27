extends Control

const SceneNav := preload("res://scripts/scene_nav.gd")

const ABOUT_TEXT := """[font_size=24][b]About[/b][/font_size]

[b]Uthman (KenThreeTimes) Ken[/b]
Uthman Ken is an aspiring author and mystic aiming to branch the world of metaphysics and reality into a wonderful user-friendly conglomerate.

[b]Jon (chron0) Marien[/b]
CTO @ D-Sports, security researcher, and Cybersecurity graduate. Jon builds at the intersection of sports, crypto, and code — from fan engagement platforms to CTF infrastructure and security research.

Portfolio and contact: [url=https://chron0.tech]chron0.tech[/url]"""

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var body_label: RichTextLabel = $MarginContainer/VBox/ScrollContainer/PanelContainer/BodyLabel


func _ready() -> void:
	_configure_background()
	_settings.apply_background(self, _settings.LEGACY_MENU)
	_settings.background_style_changed.connect(_on_background_style_changed)
	body_label.text = ABOUT_TEXT
	body_label.meta_clicked.connect(_on_meta_clicked)


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _on_back_pressed() -> void:
	SceneNav.go("res://scenes/UI/main_menu.tscn")
