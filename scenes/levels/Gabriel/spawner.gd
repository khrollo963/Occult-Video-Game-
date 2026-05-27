extends Node

@onready var collectible_scene := preload("res://scenes/levels/Gabriel/apple.tscn")
@onready var hazard_scene := preload("res://scenes/levels/Gabriel/obstacle.tscn")

@export var spawn_x := 1240.0

var collectible_timer := 0.0
var hazard_timer := 0.0


func _process(delta: float) -> void:
	handle_collectibles(delta)
	handle_hazards(delta)


func handle_collectibles(delta: float) -> void:
	collectible_timer -= delta
	if collectible_timer <= 0.0:
		spawn_collectible()
		collectible_timer = 0.75


func handle_hazards(delta: float) -> void:
	hazard_timer -= delta
	if hazard_timer <= 0.0:
		spawn_hazard()
		hazard_timer = randf_range(4.5, 7.0)


func spawn_collectible() -> void:
	var collectible := collectible_scene.instantiate()
	collectible.global_position = Vector2(spawn_x, randf_range(100.0, 620.0))
	get_tree().current_scene.add_child(collectible)


func spawn_hazard() -> void:
	var hazard := hazard_scene.instantiate()
	hazard.global_position = Vector2(spawn_x, randf_range(100.0, 620.0))
	get_tree().current_scene.add_child(hazard)
