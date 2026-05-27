extends CharacterBody2D

const GRAVITY := 1200.0
const JUMP_FORCE := -550.0
const STAND_SIZE := Vector2(70, 50)
const DUCK_SIZE := Vector2(70, 28)
const STAND_OFFSET := Vector2(0, -10)
const DUCK_OFFSET := Vector2(0, 8)

@export var max_health := 3

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var health := max_health
var invincible := false
var invincible_timer := 0.0
var is_dead := false
var is_ducking := false

var gameover_scene := preload("res://scenes/UI/gameover.tscn")
var gameover_instance: CanvasLayer = null


func _ready() -> void:
	health = max_health
	anim.flip_h = true
	_game_manager.set_health(health, max_health)
	_set_hitbox(false)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += GRAVITY * delta

	var wants_duck := Input.is_action_pressed("duck") and is_on_floor()
	if wants_duck:
		is_ducking = true
	elif is_ducking and is_on_floor():
		is_ducking = false

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_ducking:
		velocity.y = JUMP_FORCE
		is_ducking = false

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
	_set_hitbox(is_ducking and is_on_floor())

	if is_ducking and is_on_floor():
		anim.play("duck")
	elif not is_on_floor():
		anim.play("jump")
	else:
		anim.play("run")


func _set_hitbox(ducking: bool) -> void:
	var rect := collision_shape.shape as RectangleShape2D
	if ducking:
		rect.size = DUCK_SIZE
		collision_shape.position = DUCK_OFFSET
	else:
		rect.size = STAND_SIZE
		collision_shape.position = STAND_OFFSET


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	_game_manager.show_game_over()
	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)
