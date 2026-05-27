extends Area2D

@export var speed := 200.0


func _ready() -> void:
	if OS.has_feature("web"):
		var light := get_node_or_null("PickupLight") as PointLight2D
		if light:
			light.visible = false


func _process(delta):
	position.x -= speed * delta

	if position.x < -300:
		queue_free()


func _on_body_entered(body):
	if body.has_method("eat_apple"):
		body.eat_apple()
		queue_free()
