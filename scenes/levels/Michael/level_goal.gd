extends Area2D

signal level_completed


func _ready() -> void:
	if OS.has_feature("web"):
		var light := get_node_or_null("GoalLight") as PointLight2D
		if light:
			light.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Mike":
		level_completed.emit()
