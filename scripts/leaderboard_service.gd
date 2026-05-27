extends Node

signal leaderboard_loaded(game_id: String, entries: Array)
signal submit_finished(game_id: String, score: int, success: bool)

const CONFIG_PATHS := [
	"res://config/leaderboard.cfg",
	"user://leaderboard.cfg",
]

const TABLE := "leaderboard_entries"
const MIN_SCORE := 1

enum RequestMode { NONE, FETCH, SUBMIT, RANK_CHECK }

var supabase_url := ""
var supabase_key := ""
var enabled := false

var _http: HTTPRequest
var _pending_game_id := ""
var _pending_score := 0
var _request_mode: RequestMode = RequestMode.NONE
var _rank_check_game_id := ""
var _rank_check_score := 0


func _ready() -> void:
	_load_config()
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	get_node("/root/EventBus").run_ended.connect(_on_run_ended)


func _load_config() -> void:
	for path in CONFIG_PATHS:
		var config := ConfigFile.new()
		if config.load(path) != OK:
			continue
		supabase_url = str(config.get_value("supabase", "url", "")).strip_edges()
		supabase_key = str(config.get_value("supabase", "anon_key", "")).strip_edges()
		if supabase_url.contains("YOUR_PROJECT") or supabase_key.contains("YOUR_ANON"):
			continue
		break
	enabled = not supabase_url.is_empty() and not supabase_key.is_empty()


func fetch_top(game_id: String, limit: int = 10) -> void:
	_start_fetch(game_id, limit, RequestMode.FETCH)


func submit_score(game_id: String, score: int) -> void:
	if not enabled or score < MIN_SCORE:
		submit_finished.emit(game_id, score, false)
		return
	var settings = get_node("/root/SettingsManager")
	var initials: String = settings.get_initials()
	if initials.length() != 3:
		submit_finished.emit(game_id, score, false)
		return
	var body := {
		"initials": initials,
		"session_id": settings.get_session_id(),
		"game_id": game_id,
		"score": score,
	}
	var url := "%s/rest/v1/%s" % [supabase_url.trim_suffix("/"), TABLE]
	_request_mode = RequestMode.SUBMIT
	_pending_game_id = game_id
	_pending_score = score
	_http.request(url, _headers(true), HTTPClient.METHOD_POST, JSON.stringify(body))


func _headers(with_prefer := false) -> PackedStringArray:
	var headers := PackedStringArray([
		"apikey: %s" % supabase_key,
		"Authorization: Bearer %s" % supabase_key,
		"Content-Type: application/json",
	])
	if with_prefer:
		headers.append("Prefer: return=minimal")
	return headers


func _on_run_ended(game_id: String, score: int) -> void:
	submit_score(game_id, score)


func _begin_rank_check(game_id: String, score: int) -> void:
	_rank_check_game_id = game_id
	_rank_check_score = score
	_start_fetch(game_id, 10, RequestMode.RANK_CHECK)


func _start_fetch(game_id: String, limit: int, mode: RequestMode) -> void:
	if not enabled:
		if mode == RequestMode.RANK_CHECK:
			get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, 0)
		else:
			leaderboard_loaded.emit(game_id, [])
		return
	_request_mode = mode
	var query := "?select=initials,score,game_id,created_at,session_id&order=score.desc&limit=%d" % limit
	if game_id != "all":
		query += "&game_id=eq.%s" % game_id
	var url := "%s/rest/v1/%s%s" % [supabase_url.trim_suffix("/"), TABLE, query]
	_pending_game_id = game_id
	_http.request(url, _headers(), HTTPClient.METHOD_GET)


func _emit_rank(entries: Array) -> void:
	var settings = get_node("/root/SettingsManager")
	var local_session: String = str(settings.get_session_id())
	var rank := 0
	var index := 1
	for entry in entries:
		if entry is Dictionary:
			var session_id: String = str(entry.get("session_id", ""))
			var entry_score: int = int(entry.get("score", 0))
			if session_id == local_session and entry_score == _rank_check_score:
				rank = index
				break
			index += 1
	get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, rank)


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var mode := _request_mode
	_request_mode = RequestMode.NONE

	if result != HTTPRequest.RESULT_SUCCESS:
		if mode == RequestMode.SUBMIT:
			submit_finished.emit(_pending_game_id, _pending_score, false)
			_pending_score = 0
		elif mode == RequestMode.RANK_CHECK:
			get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, 0)
		else:
			leaderboard_loaded.emit(_pending_game_id, [])
		return

	if mode == RequestMode.SUBMIT:
		var ok := response_code >= 200 and response_code < 300
		var game_id := _pending_game_id
		var score := _pending_score
		_pending_score = 0
		submit_finished.emit(game_id, score, ok)
		get_node("/root/EventBus").score_submitted.emit(game_id, score, ok)
		if ok:
			_begin_rank_check(game_id, score)
		return

	if response_code != 200:
		if mode == RequestMode.RANK_CHECK:
			get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, 0)
		else:
			leaderboard_loaded.emit(_pending_game_id, [])
		return

	var text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	var entries: Array = parsed if parsed is Array else []

	if mode == RequestMode.RANK_CHECK:
		_emit_rank(entries)
		return

	leaderboard_loaded.emit(_pending_game_id, entries)
