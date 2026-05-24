extends Area2D

const SPEED = 400

func _process(delta):
	position.x += SPEED * delta
	
	if position.x > 1500:
		queue_free()
