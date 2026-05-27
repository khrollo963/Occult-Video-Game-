extends CharacterBody2D

@export var move_speed := 180.0
@export var gravity := 900.0
@export var flap_force := 350.0
@export var flap_cooldown := 0.12
@export var lunge_speed := 500.0
@export var lunge_duration := 0.15
@export var max_health := 3

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var health := max_health
var score := 0
var collectibles := 0

var is_dead := false
var is_lunging := false
var is_flashing := false

var flap_timer := 0.0
var lunge_timer := 0.0

var gameover_scene := preload("res://scenes/UI/gameover.tscn")
var gameover_instance: CanvasLayer = null


func _ready() -> void:
	health = max_health
	_emit_hud()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	handle_input(delta)
	handle_lunge(delta)
	handle_gravity(delta)
	move_and_slide()
	update_animation()


func handle_input(delta: float) -> void:
	if is_lunging:
		return

	velocity.x = Input.get_axis("move_left", "move_right") * move_speed

	flap_timer -= delta
	if Input.is_action_just_pressed("jump") and flap_timer <= 0.0:
		velocity.y = -flap_force
		flap_timer = flap_cooldown

	if Input.is_action_just_pressed("attack"):
		start_lunge()


func start_lunge() -> void:
	if is_lunging:
		return

	is_lunging = true
	lunge_timer = lunge_duration
	velocity.x = lunge_speed
	anim.play("attack")


func handle_lunge(delta: float) -> void:
	if not is_lunging:
		return

	lunge_timer -= delta
	if lunge_timer <= 0.0:
		is_lunging = false


func handle_gravity(delta: float) -> void:
	velocity.y += gravity * delta


func eat_apple() -> void:
	collectibles += 1
	score += 10
	_emit_hud()


func take_damage(amount := 1) -> void:
	if is_dead or is_flashing:
		return

	health -= amount
	_emit_hud()
	flash_red()

	if health <= 0:
		die()


func flash_red() -> void:
	if is_flashing:
		return

	is_flashing = true
	anim.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.15).timeout
	anim.modulate = Color.WHITE
	is_flashing = false


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("idle")
	show_game_over()


func show_game_over() -> void:
	if gameover_instance != null:
		return

	_game_manager.show_game_over()
	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)


func update_animation() -> void:
	if is_lunging:
		return

	if absf(velocity.x) > 10.0:
		anim.flip_h = velocity.x > 0.0

	if not is_on_floor() or velocity.y < 0.0:
		anim.play("fly")
	elif absf(velocity.x) > 10.0:
		anim.play("fly")
	else:
		anim.play("idle")


func _emit_hud() -> void:
	_game_manager.set_health(health, max_health)
	_game_manager.set_score(score)
	_game_manager.set_stat("Collected", collectibles)
