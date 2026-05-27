extends Node

signal leaderboard_loaded(game_id: String, entries: Array)
signal leaderboard_failed(message: String)
signal submit_finished(game_id: String, score: int, success: bool)
signal submit_failed(game_id: String, score: int, message: String)

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

var _fetch_http: HTTPRequest
var _submit_http: HTTPRequest
var _pending_game_id := ""
var _pending_score := 0
var _fetch_mode: RequestMode = RequestMode.NONE
var _submit_mode: RequestMode = RequestMode.NONE
var _rank_check_game_id := ""
var _rank_check_score := 0


func _ready() -> void:
	_load_config()
	_fetch_http = _make_http_client()
	_submit_http = _make_http_client()
	add_child(_fetch_http)
	add_child(_submit_http)
	_fetch_http.request_completed.connect(_on_fetch_completed)
	_submit_http.request_completed.connect(_on_submit_completed)
	get_node("/root/EventBus").run_ended.connect(_on_run_ended)


func _make_http_client() -> HTTPRequest:
	var http := HTTPRequest.new()
	http.accept_gzip = false
	http.timeout = 15.0
	return http


func _load_config() -> void:
	for path in CONFIG_PATHS:
		if _try_load_config(path):
			break
	enabled = not supabase_url.is_empty() and not supabase_key.is_empty()


func _try_load_config(path: String) -> bool:
	var config := ConfigFile.new()
	var err := config.load(path)
	if err != OK:
		if not FileAccess.file_exists(path):
			return false
		var raw := FileAccess.get_file_as_string(path)
		if raw.is_empty():
			return false
		err = config.parse(raw)
		if err != OK:
			return false

	var url := _clean_config_value(str(config.get_value("supabase", "url", "")))
	var key := _clean_config_value(str(config.get_value("supabase", "anon_key", "")))
	if url.is_empty() or key.is_empty() or url.contains("YOUR_PROJECT") or key.contains("YOUR_ANON"):
		return false

	supabase_url = url
	supabase_key = key
	return true


func _clean_config_value(value: String) -> String:
	return value.strip_edges().trim_prefix("\"").trim_suffix("\"")


func fetch_top(game_id: String, limit: int = 10) -> void:
	_start_fetch(game_id, limit, RequestMode.FETCH)


func submit_score(game_id: String, score: int) -> void:
	if not enabled:
		submit_finished.emit(game_id, score, false)
		submit_failed.emit(game_id, score, "Leaderboard is not configured in this build.")
		return
	if score < MIN_SCORE:
		submit_finished.emit(game_id, score, false)
		submit_failed.emit(game_id, score, "Score must be at least %d to submit." % MIN_SCORE)
		return
	var settings = get_node("/root/SettingsManager")
	var initials: String = settings.get_initials()
	if initials.length() != 3:
		submit_finished.emit(game_id, score, false)
		submit_failed.emit(game_id, score, "Set 3-character initials in Settings first.")
		return
	if _submit_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		submit_failed.emit(game_id, score, "Leaderboard is busy. Try again from the menu.")
		return

	var body := {
		"initials": initials,
		"session_id": settings.get_session_id(),
		"game_id": game_id,
		"score": score,
	}
	var url := "%s/rest/v1/%s" % [supabase_url.trim_suffix("/"), TABLE]
	_submit_mode = RequestMode.SUBMIT
	_pending_game_id = game_id
	_pending_score = score
	_submit_http.request(url, _headers(true), HTTPClient.METHOD_POST, JSON.stringify(body))


func _headers(with_prefer := false) -> PackedStringArray:
	var headers := PackedStringArray([
		"apikey: %s" % supabase_key,
		"Authorization: Bearer %s" % supabase_key,
		"Content-Type: application/json",
		"Accept: application/json",
		"Accept-Encoding: identity",
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
		elif mode == RequestMode.FETCH:
			leaderboard_failed.emit("Leaderboard is not configured in this build.")
		else:
			leaderboard_loaded.emit(game_id, [])
		return
	if _fetch_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return

	var safe_game_id := game_id if not game_id.is_empty() else "all"
	_fetch_mode = mode
	var query := "?select=initials,score,game_id,created_at,session_id&order=score.desc&limit=%d" % limit
	if safe_game_id != "all":
		query += "&game_id=eq.%s" % safe_game_id
	var url := "%s/rest/v1/%s%s" % [supabase_url.trim_suffix("/"), TABLE, query]
	_pending_game_id = safe_game_id
	_fetch_http.request(url, _headers(), HTTPClient.METHOD_GET)


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


func _on_submit_completed(result: int, response_code: int, _response_headers: PackedStringArray, body: PackedByteArray) -> void:
	var mode := _submit_mode
	_submit_mode = RequestMode.NONE
	var game_id := _pending_game_id
	var score := _pending_score
	_pending_score = 0

	if mode != RequestMode.SUBMIT:
		return

	if result != HTTPRequest.RESULT_SUCCESS:
		var message := "Could not reach the leaderboard server (error %d)." % result
		submit_finished.emit(game_id, score, false)
		submit_failed.emit(game_id, score, message)
		get_node("/root/EventBus").score_submitted.emit(game_id, score, false)
		return

	var ok := response_code >= 200 and response_code < 300
	submit_finished.emit(game_id, score, ok)
	get_node("/root/EventBus").score_submitted.emit(game_id, score, ok)
	if ok:
		_begin_rank_check(game_id, score)
		return

	var detail := _response_detail(body, response_code)
	submit_failed.emit(game_id, score, detail)


func _on_fetch_completed(result: int, response_code: int, _response_headers: PackedStringArray, body: PackedByteArray) -> void:
	var mode := _fetch_mode
	_fetch_mode = RequestMode.NONE

	if result != HTTPRequest.RESULT_SUCCESS:
		if mode == RequestMode.RANK_CHECK:
			get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, 0)
		elif mode == RequestMode.FETCH:
			leaderboard_failed.emit("Could not reach the leaderboard server (error %d)." % result)
		else:
			leaderboard_loaded.emit(_pending_game_id, [])
		return

	if response_code != 200:
		if mode == RequestMode.RANK_CHECK:
			get_node("/root/EventBus").leaderboard_ranked.emit(_rank_check_game_id, _rank_check_score, 0)
		elif mode == RequestMode.FETCH:
			leaderboard_failed.emit(_response_detail(body, response_code))
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


func _response_detail(body: PackedByteArray, response_code: int) -> String:
	var detail := body.get_string_from_utf8().strip_edges()
	if detail.is_empty():
		return "Leaderboard request failed (%d)." % response_code
	return "Leaderboard request failed (%d): %s" % [response_code, detail]
