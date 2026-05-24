extends CharacterBody2D

const GRAVITY = 800
const JUMP_FORCE = -400

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity.x = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_FORCE
	
	move_and_slide()
