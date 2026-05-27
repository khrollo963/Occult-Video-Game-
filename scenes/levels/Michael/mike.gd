extends CharacterBody2D

const SPEED := 220.0
const JUMP_FORCE := -520.0
const GRAVITY := 900.0
const ATTACK_LUNGE := 380.0
const ATTACK_DURATION := 0.25

@export var max_health := 5

const HitFlashHelper := preload("res://scripts/hit_flash.gd")

@onready var _game_manager: Node = get_node("/root/GameManager")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

const ATTACK_HITBOX_OFFSET_X := 36.0

var health := max_health
var attacking := false
var attack_timer := 0.0
var invincible := false
var invincible_timer := 0.0
var is_dead := false

var gameover_scene := preload("res://scenes/UI/gameover.tscn")
var gameover_instance: CanvasLayer = null


func _ready() -> void:
	health = max_health
	attack_hitbox.monitoring = false
	_game_manager.set_health(health, max_health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += GRAVITY * delta

	if not attacking:
		velocity.x = Input.get_axis("move_left", "move_right") * SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor() and not attacking:
		velocity.y = JUMP_FORCE
		get_node("/root/AudioManager").play_sfx("jump")
		get_node("/root/VfxManager").spawn("landing_dust", global_position)

	if Input.is_action_just_pressed("attack") and not attacking:
		start_attack()

	if attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			end_attack()

	move_and_slide()
	update_animation()
	handle_invincibility(delta)


func start_attack() -> void:
	attacking = true
	attack_timer = ATTACK_DURATION
	var attack_dir := 1.0 if anim.flip_h else -1.0
	velocity.x = attack_dir * ATTACK_LUNGE
	attack_hitbox_shape.position.x = ATTACK_HITBOX_OFFSET_X * attack_dir
	anim.play("attack")
	attack_hitbox.monitoring = true


func end_attack() -> void:
	attacking = false
	attack_hitbox.monitoring = false
	velocity.x = 0.0


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)


func take_damage(amount := 1) -> void:
	if is_dead or invincible:
		return

	health -= amount
	_game_manager.set_health(health, max_health)
	get_node("/root/EventBus").player_damaged.emit(amount)
	get_node("/root/VfxManager").spawn("hit_spark", global_position)
	HitFlashHelper.flash(anim)
	invincible = true
	invincible_timer = 1.0
	anim.modulate = Color(1.0, 0.35, 0.35)

	if health <= 0:
		die()


func handle_invincibility(delta: float) -> void:
	if not invincible:
		return

	invincible_timer -= delta
	if invincible_timer <= 0.0:
		invincible = false
		anim.modulate = Color.WHITE


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	get_node("/root/AudioManager").play_sfx("death")
	get_node("/root/VfxManager").spawn("death_poof", global_position)
	_game_manager.end_run("mike", _game_manager.get_score())
	_game_manager.show_game_over()
	gameover_instance = gameover_scene.instantiate()
	get_tree().current_scene.add_child(gameover_instance)


func update_animation() -> void:
	if attacking:
		return

	if not is_on_floor():
		anim.play("jump")
	elif absf(velocity.x) > 10.0:
		anim.play("walk")
		anim.flip_h = velocity.x > 0.0
	else:
		anim.play("idle")
