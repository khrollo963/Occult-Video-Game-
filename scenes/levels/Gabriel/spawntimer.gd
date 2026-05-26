extends Node

@onready var apple_scene := preload("res://scenes/levels/Gabriel/apple.tscn")
@onready var obstacle_scene := preload("res://scenes/levels/Gabriel/obstacle.tscn")

func _ready():
	print("Spawner children:")
	for c in get_children():
		print("-", c.name)

@export var spawn_x := 900.0
@export var y_min := 120.0
@export var y_max := 380.0

var toggle := true  # alternates apple / obstacle


func _ready():
	spawn_timer.timeout.connect(_on_spawn)


func _on_spawn():
	if toggle:
		spawn_apple()
	else:
		spawn_obstacle()

	toggle = !toggle  # flip each time


func spawn_apple():
	var apple = apple_scene.instantiate()
	apple.global_position = Vector2(spawn_x, randf_range(y_min, y_max))
	get_tree().current_scene.add_child(apple)


func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	obstacle.global_position = Vector2(spawn_x, randf_range(y_min, y_max))
	get_tree().current_scene.add_child(obstacle)
