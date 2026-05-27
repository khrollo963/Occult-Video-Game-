extends Node

@onready var collectible_scene := preload("res://scenes/levels/Gabriel/apple.tscn")
@onready var hazard_scene := preload("res://scenes/levels/Gabriel/obstacle.tscn")

@export var spawn_x := 1240.0

const WAVE_COUNT := 9

var collectible_timer := 0.0
var hazard_timer := 0.0
var spawn_rate := 1.0
var current_wave := 1
var wave_score := 0
var wave_threshold := 80


func _ready() -> void:
	get_node("/root/EventBus").collectible_picked.connect(_on_collectible_picked)


func _process(_delta: float) -> void:
	pass


func _on_collectible_picked(value: int) -> void:
	wave_score += value
	if wave_score >= wave_threshold and current_wave < WAVE_COUNT:
		current_wave += 1
		wave_score = 0
		wave_threshold += 40
		get_node("/root/ScoreManager").set_gabe_wave(current_wave)
		get_node("/root/GameManager").set_stat("Wave", current_wave)


func get_wave() -> int:
	return current_wave


func apply_spawn_rate(rate: float) -> void:
	spawn_rate = maxf(rate, 0.1)


func wave_hazard_bias() -> float:
	return clampf(0.25 + current_wave * 0.08, 0.25, 0.85)


func handle_collectibles(delta: float) -> void:
	collectible_timer -= delta * spawn_rate
	if collectible_timer <= 0.0:
		spawn_collectible()
		collectible_timer = maxf(0.55 / spawn_rate, 0.25)


func handle_hazards(delta: float) -> void:
	hazard_timer -= delta * spawn_rate
	if hazard_timer <= 0.0:
		if randf() < wave_hazard_bias():
			spawn_hazard()
		hazard_timer = randf_range(3.0, 6.0 - current_wave * 0.3) / spawn_rate


func spawn_collectible() -> void:
	var collectible := collectible_scene.instantiate()
	collectible.global_position = Vector2(spawn_x, randf_range(100.0, 620.0))
	get_tree().current_scene.add_child(collectible)


func spawn_hazard() -> void:
	var hazard := hazard_scene.instantiate()
	hazard.global_position = Vector2(spawn_x, randf_range(100.0, 620.0))
	get_tree().current_scene.add_child(hazard)
