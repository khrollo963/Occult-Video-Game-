extends CharacterBody2D

const GRAVITY = 800
const JUMP_FORCE = -400
var health = 3
var invincible = false
var invincible_timer = 0

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity.x = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_FORCE
	
	move_and_slide()
	
	if is_on_floor():
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")
	
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			$AnimatedSprite2D.modulate = Color(1, 1, 1)

func _on_hitbox_area_entered(_area: Area2D):
	if not invincible:
		health -= 1
		print("Hit! Health: ", health)
		invincible = true
		invincible_timer = 1.0
		$AnimatedSprite2D.modulate = Color(1, 0, 0)
		if health <= 0:
			get_tree().change_scene_to_file("res://scenes/UI/gameover.tscn")
