extends CharacterBody2D

const GRAVITY := 1200.0
const JUMP_FORCE := -550.0

@export var max_health := 3

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var health := max_health
var invincible := false
var invincible_timer := 0.0
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

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()
	update_animation()
	handle_invincibility(delta)


func take_damage(amount := 1) -> void:
	if is_dead or invincible:
		return

	health -= amount
	_game_manager.set_health(health, max_health)
	invincible = true
	invincible_timer = 1.0
	anim.modulate = Color(1.0, 0.3, 0.3)

	if health <= 0:
		die()


func handle_invincibility(delta: float) -> void:
	if not invincible:
		return

	invincible_timer -= delta
	if invincible_timer <= 0.0:
		invincible = false
		anim.modulate = Color.WHITE


func update_animation() -> void:
	if not is_on_floor():
		anim.play("jump")
	else:
		anim.play("walk")


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	_game_manager.show_game_over()
	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)
