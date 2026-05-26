extends Node

@onready var apple_scene := preload("res://scenes/levels/Gabriel/apple.tscn")
@onready var obstacle_scene := preload("res://scenes/levels/Gabriel/obstacle.tscn")

@export var spawn_x := 900.0

var apple_timer := 0.0
var obstacle_timer := 0.0


func _process(delta):
	handle_apples(delta)
	handle_obstacles(delta)


# ---------------- APPLES (STEADY FLOW) ----------------
func handle_apples(delta):
	apple_timer -= delta

	if apple_timer <= 0:
		spawn_apple()
		apple_timer = 1.0  # steady rhythm


func spawn_apple():
	var apple = apple_scene.instantiate()

	apple.global_position = Vector2(
		spawn_x,
		randf_range(140, 360)
	)

	get_tree().current_scene.add_child(apple)


# ---------------- OBSTACLES (SPACED OUT) ----------------
func handle_obstacles(delta):
	obstacle_timer -= delta

	if obstacle_timer <= 0:
		spawn_obstacle()

		# slightly slower, more deliberate pressure
		obstacle_timer = randf_range(2.2, 3.5)


func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()

	obstacle.global_position = Vector2(
		spawn_x,
		randf_range(140, 360)
	)

	get_tree().current_scene.add_child(obstacle)
