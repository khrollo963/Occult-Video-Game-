extends Control

const LORE_TEXT := """[font_size=24][b]Glory Quest Arcade[/b][/font_size]

Enter the Retroactive world of Glory Quest Arcade — an interactive enigma!

Join our four main characters, Yuri, Raph, Gabe, and Mike, as they journey through their individual arcade adventures.

[b]The Games[/b]
• Yuri's Crazy Endless Runner
• Gabe's Spectacular Collector
• Raph's Funny Flight
• Mike's Daunting Quest

[b]Lore Behind the Game[/b]
The imagery behind the game is heavily religiously and mystically inspired.

Each character is one of the four main archangels of praise, symbolized by a zodiac sign:

[b]Raphael[/b] — Aquarius
[b]Uriel (Yuri)[/b] — Taurus
[b]Gabriel (Gabe)[/b] — Ancient Scorpio
[b]Michael (Mike)[/b] — Leo

These are known as the Fixed Signs of the zodiac. They are also known as the Kerubic Signs. The Kerubim are Glory Beings in Hebrew — angelic forces that guard specific spiritual nodes.

In Ezekiel 1:10 and Revelation 4:7, imagery in heavy similitude to the fixed signs of the zodiac are used for the Kerubim on the throne.

See Scripture on the main menu for the full passages.

[b]Purpose[/b]
This is the purpose of the game: to have these archetypes and personalities experienced in an interactive and fun way."""

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var body_label: RichTextLabel = $MarginContainer/VBox/ScrollContainer/PanelContainer/BodyLabel


func _ready() -> void:
	_configure_background()
	_settings.apply_background(self, _settings.LEGACY_MENU)
	_settings.background_style_changed.connect(_on_background_style_changed)
	body_label.text = LORE_TEXT


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/settings.tscn")
