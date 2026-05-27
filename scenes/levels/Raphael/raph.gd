extends CharacterBody2D

const GRAVITY := 980.0
const MOVE_SPEED := 260.0
const JUMP_FORCE := -520.0

@export var max_health := 3

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var health := max_health
var is_dead := false

var gameover_scene := preload("res://scenes/UI/gameover.tscn")
var gameover_instance: CanvasLayer = null


func _ready() -> void:
	health = max_health
	_game_manager.set_health(health, max_health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += GRAVITY * delta
	velocity.x = Input.get_axis("move_left", "move_right") * MOVE_SPEED
	move_and_slide()

	if is_on_floor() and velocity.y >= 0.0:
		velocity.y = JUMP_FORCE

	update_animation()


func update_animation() -> void:
	if velocity.y < -40.0:
		anim.play("jump")
	elif velocity.y > 40.0:
		anim.play("fall")
	else:
		anim.play("idle")

	if absf(velocity.x) > 10.0:
		anim.flip_h = velocity.x < 0.0


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	_game_manager.show_game_over()
	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)
