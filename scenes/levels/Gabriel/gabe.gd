extends CharacterBody2D

@export var move_speed := 180.0
@export var gravity := 900.0
@export var flap_force := 350.0
@export var flap_cooldown := 0.12

@export var lunge_speed := 500.0
@export var lunge_duration := 0.15

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var health := 3
var score := 0
var apples := 0

var is_dead := false
var is_lunging := false
var is_flashing := false

var flap_timer := 0.0
var lunge_timer := 0.0

var gameover_scene = preload("res://scenes/UI/gameover.tscn")
var gameover_instance = null


func _physics_process(delta):
	if is_dead:
		return

	handle_input(delta)
	handle_lunge(delta)
	handle_gravity(delta)

	move_and_slide()
	update_animation()


# ---------------- INPUT ----------------
func handle_input(delta):
	if is_lunging:
		return

	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * move_speed

	flap_timer -= delta
	if Input.is_key_pressed(KEY_SPACE) and flap_timer <= 0:
		velocity.y = -flap_force
		flap_timer = flap_cooldown

	if Input.is_key_pressed(KEY_ENTER):
		start_lunge()


# ---------------- LUNGE ----------------
func start_lunge():
	if is_lunging:
		return

	is_lunging = true
	lunge_timer = lunge_duration
	velocity.x = lunge_speed
	anim.play("attack")


func handle_lunge(delta):
	if not is_lunging:
		return

	lunge_timer -= delta
	if lunge_timer <= 0:
		is_lunging = false


# ---------------- GRAVITY ----------------
func handle_gravity(delta):
	velocity.y += gravity * delta


# ---------------- 🍎 APPLE ----------------
func eat_apple():
	apples += 1
	score += 10


# ---------------- 🔴 DAMAGE ----------------
func take_damage(amount := 1):
	if is_dead:
		return

	health -= amount
	flash_red()

	if health <= 0:
		die()


func flash_red():
	if is_flashing:
		return

	is_flashing = true
	anim.modulate = Color(1, 0.3, 0.3)

	await get_tree().create_timer(0.15).timeout

	anim.modulate = Color(1, 1, 1)
	is_flashing = false


# ---------------- 💀 DEATH ----------------
func die():
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("idle")

	show_game_over()


func show_game_over():
	if gameover_instance != null:
		return

	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)


# ---------------- ANIMATION ----------------
func update_animation():
	if is_lunging:
		return

	if not is_on_floor():
		anim.play("fly")
	elif velocity.x != 0:
		anim.play("fly")
	else:
		anim.play("idle")
