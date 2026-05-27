extends Control

const GAME_SCENES := {
	"mike": "res://scenes/levels/Michael/mike_game.tscn",
	"gabe": "res://scenes/levels/Gabriel/gabe_game.tscn",
	"yuri": "res://scenes/levels/Uriel/yuri_game.tscn",
	"raph": "res://scenes/levels/Raphael/raph_game.tscn",
}
const GAME_NAMES := {
	"mike": "Mike's Daunting Quest",
	"gabe": "Gabe's Spectacular Collector",
	"yuri": "Yuri's Crazy Endless Runner",
	"raph": "Raph's Funny Flight",
}
const ButtonSheen := preload("res://scenes/UI/button_sheen.gd")
const SceneNav := preload("res://scripts/scene_nav.gd")

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var _score_mgr: Node = get_node("/root/ScoreManager")
@onready var splash: ColorRect = $RandomSplash/Panel
@onready var splash_label: Label = $RandomSplash/Panel/Center/Label


func _ready() -> void:
	_configure_background()
	_apply_background()
	_settings.background_style_changed.connect(_on_background_style_changed)
	_apply_button_sheen()
	_update_best_scores()
	get_node("/root/AudioManager").play_music("menu")
	if _settings.needs_initials_prompt():
		_show_initials_prompt()
	splash.visible = false


func _apply_button_sheen() -> void:
	var buttons: Array[Button] = [
		$StartButton,
		$SettingsButton,
		$ScriptureButton,
		$LeaderboardButton,
		$LoreButton,
		$AboutButton,
		$CharacterRow/CardYuri/VBox/ButtonYuri,
		$CharacterRow/CardRaph/VBox/ButtonRaph,
		$CharacterRow/CardGabe/VBox/ButtonGabe,
		$CharacterRow/CardMike/VBox/ButtonMike,
	]
	ButtonSheen.apply_to_buttons(buttons)


func _update_best_scores() -> void:
	_set_card_best($CharacterRow/CardMike/VBox, "mike")
	_set_card_best($CharacterRow/CardGabe/VBox, "gabe")
	_set_card_best($CharacterRow/CardYuri/VBox, "yuri")
	_set_card_best($CharacterRow/CardRaph/VBox, "raph")


func _set_card_best(card_vbox: VBoxContainer, game_id: String) -> void:
	var label: Label = card_vbox.get_node_or_null("BestLabel")
	if label == null:
		label = Label.new()
		label.name = "BestLabel"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		card_vbox.add_child(label)
	var best: int = _score_mgr.get_best(game_id)
	label.text = "Best: %d" % best if best > 0 else "Best: —"


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _apply_background() -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _ui_click() -> void:
	get_node("/root/AudioManager").play_ui_click()


func start_random_game() -> void:
	var ids := GAME_SCENES.keys()
	var pick: String = ids.pick_random()
	_show_splash_then_go(pick)


func _show_splash_then_go(game_id: String) -> void:
	splash_label.text = GAME_NAMES.get(game_id, game_id.capitalize())
	splash.visible = true
	await get_tree().create_timer(1.1).timeout
	splash.visible = false
	_go_game(game_id)


func _go_game(game_id: String) -> void:
	_ui_click()
	SceneNav.go(GAME_SCENES[game_id])


func _show_initials_prompt() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Arcade Initials"
	dialog.dialog_text = "Enter 3 letters or numbers for the global leaderboard:"
	var edit := LineEdit.new()
	edit.max_length = 3
	edit.custom_minimum_size = Vector2(120, 0)
	dialog.add_child(edit)
	dialog.confirmed.connect(func():
		if not _settings.set_initials(edit.text):
			_settings.set_initials("GLQ")
	)
	add_child(dialog)
	dialog.popup_centered()


func _on_start_button_pressed() -> void:
	start_random_game()


func _on_settings_button_pressed() -> void:
	_ui_click()
	SceneNav.go("res://scenes/UI/settings.tscn")


func _on_leaderboard_button_pressed() -> void:
	_ui_click()
	SceneNav.go("res://scenes/UI/leaderboard.tscn")


func _on_scripture_button_pressed() -> void:
	_ui_click()
	SceneNav.go("res://scenes/UI/scripture.tscn")


func _on_lore_button_pressed() -> void:
	_ui_click()
	SceneNav.go("res://scenes/UI/lore.tscn")


func _on_about_button_pressed() -> void:
	_ui_click()
	SceneNav.go("res://scenes/UI/about.tscn")


func _on_button_mike_pressed() -> void:
	_go_game("mike")


func _on_button_gabe_pressed() -> void:
	_go_game("gabe")


func _on_button_yuri_pressed() -> void:
	_go_game("yuri")


func _on_button_raph_pressed() -> void:
	_go_game("raph")


func _on_background_style_changed(_style: String) -> void:
	_apply_background()
