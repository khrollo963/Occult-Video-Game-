extends CharacterBody2D

@export var max_health := 2
@export var contact_damage := 1
@export var enemy_type := "shade"
@export var move_speed := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox

var health := max_health


func _ready() -> void:
	health = max_health
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	if enemy_type == "runner":
		move_speed = 140.0
		modulate = Color(1.0, 0.7, 0.7)


func _physics_process(delta: float) -> void:
	if move_speed <= 0.0:
		return
	velocity.x = -move_speed
	move_and_slide()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)


func take_damage(amount := 1) -> void:
	health -= amount
	sprite.modulate = Color(1.0, 0.5, 0.5)
	get_node("/root/VfxManager").spawn("hit_spark", global_position)
	var killed := health <= 0
	if not killed:
		get_node("/root/AudioManager").play_sfx("hit")
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color.WHITE

	if killed:
		get_node("/root/EventBus").enemy_killed.emit()
		get_node("/root/VfxManager").spawn("death_poof", global_position)
		queue_free()
