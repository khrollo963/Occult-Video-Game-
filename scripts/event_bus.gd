extends Node

signal player_damaged(amount: int)
signal enemy_killed
signal collectible_picked(value: int)
signal run_ended(game_id: String, score: int)
signal new_high_score(game_id: String, score: int)
signal score_submitted(game_id: String, score: int, success: bool)
signal medal_unlocked(medal_id: String)
signal leaderboard_ranked(game_id: String, score: int, rank: int)
signal vfx_requested(effect_id: String, position: Vector2)
signal camera_shake_requested(strength: float, duration: float)
