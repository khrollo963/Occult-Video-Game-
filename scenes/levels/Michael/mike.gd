extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -500.0
const GRAVITY = 800.0
const ATTACK_LUNGE = -300.0
var attacking = false
var attack_timer = 0.0

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if not attacking:
		var dir = Input.get_axis("ui_left", "ui_right")
		velocity.x = dir * SPEED
	
	if Input.is_key_pressed(KEY_SPACE):
		if is_on_floor():
			velocity.y = JUMP_FORCE
	
	if Input.is_key_pressed(KEY_ENTER):
		if not attacking:
			attacking = true
			attack_timer = 0.3
			velocity.x = ATTACK_LUNGE
			$AnimatedSprite2D.play("attack")
	
	if attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			attacking = false
			velocity.x = 0
	
	move_and_slide()
	
	if not attacking:
		if is_on_floor():
			if velocity.x != 0:
				$AnimatedSprite2D.play("walk")
			else:
				$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("jump")
