extends Node

const SAVE_PATH := "user://arcade_save.cfg"

const GAME_IDS := ["mike", "gabe", "yuri", "raph"]

const MEDAL_THRESHOLDS := {
	"first_run": 1,
	"yuri_1000": 1000,
	"gabe_wave_9": 9,
	"mike_level_5": 5,
	"raph_height_5000": 5000,
}

const MEDAL_LABELS := {
	"first_run": "First Run",
	"yuri_1000": "Yuri — 1000m",
	"gabe_wave_9": "Gabe — Wave 9",
	"mike_level_5": "Mike — Level 5",
	"raph_height_5000": "Raph — 5000 height",
}

var best_scores: Dictionary = {}
var last_scores: Dictionary = {}
var runs_played: Dictionary = {}
var medals: Dictionary = {}
var gabe_wave_reached: int = 0
var mike_level_reached: int = 0


func _ready() -> void:
	load_scores()
	for game_id in GAME_IDS:
		_ensure_game(game_id)


func _ensure_game(game_id: String) -> void:
	if not best_scores.has(game_id):
		best_scores[game_id] = 0
	if not last_scores.has(game_id):
		last_scores[game_id] = 0
	if not runs_played.has(game_id):
		runs_played[game_id] = 0


func load_scores() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for game_id in GAME_IDS:
		best_scores[game_id] = int(config.get_value("best", game_id, 0))
		last_scores[game_id] = int(config.get_value("last", game_id, 0))
		runs_played[game_id] = int(config.get_value("runs", game_id, 0))
	for medal_id in MEDAL_THRESHOLDS:
		medals[medal_id] = bool(config.get_value("medals", medal_id, false))
	gabe_wave_reached = int(config.get_value("meta", "gabe_wave", 0))
	mike_level_reached = int(config.get_value("meta", "mike_level", 0))


func save_scores() -> void:
	var config := ConfigFile.new()
	for game_id in GAME_IDS:
		config.set_value("best", game_id, best_scores.get(game_id, 0))
		config.set_value("last", game_id, last_scores.get(game_id, 0))
		config.set_value("runs", game_id, runs_played.get(game_id, 0))
	for medal_id in medals:
		config.set_value("medals", medal_id, medals[medal_id])
	config.set_value("meta", "gabe_wave", gabe_wave_reached)
	config.set_value("meta", "mike_level", mike_level_reached)
	config.save(SAVE_PATH)


func get_best(game_id: String) -> int:
	return int(best_scores.get(game_id, 0))


func record_run(game_id: String, score: int) -> bool:
	_ensure_game(game_id)
	last_scores[game_id] = score
	runs_played[game_id] = int(runs_played.get(game_id, 0)) + 1
	var is_new := score > int(best_scores.get(game_id, 0))
	if is_new:
		best_scores[game_id] = score
		get_node("/root/EventBus").new_high_score.emit(game_id, score)
	_check_medals(game_id, score)
	save_scores()
	return is_new


func _check_medals(game_id: String, score: int) -> void:
	var bus: Node = get_node("/root/EventBus")
	if not medals.get("first_run", false) and _total_runs() >= 1:
		_unlock_medal("first_run", bus)
	if game_id == "yuri" and score >= MEDAL_THRESHOLDS.yuri_1000:
		_unlock_medal("yuri_1000", bus)
	if game_id == "gabe" and gabe_wave_reached >= MEDAL_THRESHOLDS.gabe_wave_9:
		_unlock_medal("gabe_wave_9", bus)
	if game_id == "mike" and mike_level_reached >= MEDAL_THRESHOLDS.mike_level_5:
		_unlock_medal("mike_level_5", bus)
	if game_id == "raph" and score >= MEDAL_THRESHOLDS.raph_height_5000:
		_unlock_medal("raph_height_5000", bus)


func _unlock_medal(medal_id: String, bus: Node) -> void:
	if medals.get(medal_id, false):
		return
	medals[medal_id] = true
	bus.medal_unlocked.emit(medal_id)
	save_scores()


func _total_runs() -> int:
	var total := 0
	for game_id in GAME_IDS:
		total += int(runs_played.get(game_id, 0))
	return total


func set_gabe_wave(wave: int) -> void:
	gabe_wave_reached = maxi(gabe_wave_reached, wave)
	save_scores()


func set_mike_level(level: int) -> void:
	mike_level_reached = maxi(mike_level_reached, level)
	save_scores()


func has_medal(medal_id: String) -> bool:
	return bool(medals.get(medal_id, false))


func get_medal_lines() -> PackedStringArray:
	var lines: PackedStringArray = []
	for entry in get_medal_entries():
		var mark := "*" if entry.unlocked else "-"
		lines.append("%s %s" % [mark, entry.label])
	return lines


func get_medal_entries() -> Array:
	var entries: Array = []
	for medal_id in MEDAL_THRESHOLDS:
		entries.append({
			"id": medal_id,
			"label": str(MEDAL_LABELS.get(medal_id, medal_id)),
			"unlocked": has_medal(medal_id),
		})
	return entries
