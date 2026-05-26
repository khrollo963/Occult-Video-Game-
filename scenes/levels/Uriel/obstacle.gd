extends Area2D

const SPEED = 555

func _ready():
	monitoring = true
	monitorable = true

func _process(delta):
	position.x += SPEED * delta
	if position.x > 1800:
		queue_free()

func _on_area_entered(area):
	print("Hit: ", area.name)
