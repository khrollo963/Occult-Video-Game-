extends SceneTree

## Run: godot4.exe --headless --script tests/run_smoke.gd


func _init() -> void:
	var failures: PackedStringArray = []
	_test_initials_validation(failures)
	_test_score_manager_paths(failures)
	_test_leaderboard_config(failures)
	if failures.is_empty():
		print("SMOKE OK: all checks passed")
	else:
		for msg in failures:
			push_error(msg)
		quit(1)
		return
	quit()


const SettingsManager := preload("res://scripts/settings_manager.gd")


func _test_initials_validation(failures: PackedStringArray) -> void:
	var sm: Node = SettingsManager.new()
	if not sm.set_initials("ABC"):
		failures.append("valid initials ABC should pass")
	if sm.set_initials("AB"):
		failures.append("two-char initials should fail")
	if sm.set_initials("AB!"):
		failures.append("invalid char initials should fail")


func _test_score_manager_paths(failures: PackedStringArray) -> void:
	if not FileAccess.file_exists("res://scripts/score_manager.gd"):
		failures.append("score_manager.gd missing")
	if not FileAccess.file_exists("res://scenes/UI/leaderboard.tscn"):
		failures.append("leaderboard.tscn missing")


func _test_leaderboard_config(failures: PackedStringArray) -> void:
	if not FileAccess.file_exists("res://config/leaderboard.cfg.example"):
		failures.append("leaderboard.cfg.example missing")
	if not FileAccess.file_exists("res://supabase/migrations/001_leaderboard_entries.sql"):
		failures.append("leaderboard migration missing")
