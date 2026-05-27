extends CharacterBody2D

@export var max_health := 2
@export var contact_damage := 1

@onready var sprite: ColorRect = $ColorRect
@onready var hurtbox: Area2D = $Hurtbox

var health := max_health


func _ready() -> void:
	health = max_health
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)


func take_damage(amount := 1) -> void:
	health -= amount
	sprite.modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color.WHITE

	if health <= 0:
		queue_free()
