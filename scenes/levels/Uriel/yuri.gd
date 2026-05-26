extends CharacterBody2D

const GRAVITY := 800.0
const JUMP_FORCE := -500.0
const FLOOR_Y := 570.0

var health := 3
var invincible := false
var invincible_timer := 0.0

func _ready():
	await get_tree().physics_frame

func _physics_process(delta):
	handle_input()
	handle_gravity(delta)
	handle_damage()
	handle_invincibility(delta)
	move_and_slide()
	update_animation()

func handle_input():
	if Input.is_key_pressed(KEY_SPACE):
		if position.y >= FLOOR_Y - 5:
			velocity.y = JUMP_FORCE

func handle_gravity(delta):
	velocity.y += GRAVITY * delta

	if position.y > FLOOR_Y:
		position.y = FLOOR_Y
		velocity.y = 0

func handle_damage():
	if invincible:
		return

	for area in $Hitbox.get_overlapping_areas():
		apply_damage(1)
		break

func apply_damage(amount := 1):
	health -= amount
	print("HIT! Health:", health)

	invincible = true
	invincible_timer = 1.0

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.modulate = Color(1, 0, 0)

	if health <= 0:
		die()

func handle_invincibility(delta):
	if not invincible:
		return

	invincible_timer -= delta

	if invincible_timer <= 0:
		invincible = false

		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(1, 1, 1)

func update_animation():
	if not has_node("AnimatedSprite2D"):
		return

	if position.y >= FLOOR_Y - 5:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")

func die():
	print("YURI DEAD")
	get_tree().change_scene_to_file("res://scenes/UI/gameover.tscn")
