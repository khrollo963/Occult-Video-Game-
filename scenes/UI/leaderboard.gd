extends Control

const SceneNav := preload("res://scripts/scene_nav.gd")

const GAME_LABELS := {
	"all": "All Games",
	"mike": "Mike",
	"gabe": "Gabe",
	"yuri": "Yuri",
	"raph": "Raph",
}

@onready var _settings: Node = get_node("/root/SettingsManager")
@onready var _leaderboard: Node = get_node("/root/LeaderboardService")
@onready var filter_option: OptionButton = $MarginContainer/VBox/FilterRow/FilterOption
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var list_label: RichTextLabel = $MarginContainer/VBox/ScrollContainer/PanelContainer/ListLabel


func _ready() -> void:
	_configure_background()
	_settings.apply_background(self, _settings.LEGACY_MENU)
	_settings.background_style_changed.connect(_on_background_style_changed)
	filter_option.clear()
	filter_option.add_item("All Games", 0)
	filter_option.set_item_metadata(0, "all")
	filter_option.add_item("Mike", 1)
	filter_option.set_item_metadata(1, "mike")
	filter_option.add_item("Gabe", 2)
	filter_option.set_item_metadata(2, "gabe")
	filter_option.add_item("Yuri", 3)
	filter_option.set_item_metadata(3, "yuri")
	filter_option.add_item("Raph", 4)
	filter_option.set_item_metadata(4, "raph")
	_leaderboard.leaderboard_loaded.connect(_on_leaderboard_loaded)
	_leaderboard.leaderboard_failed.connect(_on_leaderboard_failed)
	_refresh()


func _configure_background() -> void:
	var gradient: ColorRect = $SimpleGradientBg.get_node("Gradient")
	gradient.top_color = Color(0.42, 0.24, 0.62, 1.0)
	gradient.bottom_color = Color(0.16, 0.08, 0.28, 1.0)


func _on_background_style_changed(_style: String) -> void:
	_settings.apply_background(self, _settings.LEGACY_MENU)


func _refresh() -> void:
	status_label.text = "Loading..."
	var game_id: String = str(filter_option.get_item_metadata(filter_option.selected))
	if game_id.is_empty():
		game_id = "all"
	_leaderboard.fetch_top(game_id, 15)


func _on_leaderboard_failed(message: String) -> void:
	status_label.text = "Could not load scores"
	list_label.text = "[center]%s[/center]" % message


func _on_leaderboard_loaded(_game_id: String, entries: Array) -> void:
	if entries.is_empty():
		status_label.text = "No scores yet — be the first!"
		list_label.text = "[center]Play a game to claim the board.[/center]"
		return
	status_label.text = "Top scores"
	var lines: PackedStringArray = []
	lines.append("[b]#  INIT  SCORE     GAME   DATE[/b]")
	var rank := 1
	var local_session: String = str(_settings.get_session_id())
	for entry in entries:
		if entry is Dictionary:
			var initials := str(entry.get("initials", "???"))
			var score := int(entry.get("score", 0))
			var game := str(entry.get("game_id", ""))
			var created := str(entry.get("created_at", "")).substr(0, 10)
			var marker := " *" if str(entry.get("session_id", "")) == local_session else ""
			lines.append("%2d  %s  %7d  %5s  %s%s" % [rank, initials, score, game, created, marker])
			rank += 1
	list_label.text = "\n".join(lines)


func _on_filter_option_item_selected(_index: int) -> void:
	_refresh()


func _on_refresh_pressed() -> void:
	get_node("/root/AudioManager").play_ui_click()
	_refresh()


func _on_back_pressed() -> void:
	get_node("/root/AudioManager").play_ui_click()
	SceneNav.go("res://scenes/UI/main_menu.tscn")
