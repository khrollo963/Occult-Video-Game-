extends Area2D

@export var speed := 400.0


func _ready() -> void:
	monitoring = true


func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -120.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
