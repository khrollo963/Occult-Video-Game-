extends StaticBody2D

@onready var visual: ColorRect = $Visual
@onready var spike: Area2D = $SpikeArea

var platform_kind := "normal"
var move_dir := 1.0
var move_speed := 80.0
var _goal_light: PointLight2D


func setup(kind: String) -> void:
	platform_kind = kind
	match kind:
		"spike":
			visual.color = Color(0.7, 0.2, 0.2, 1.0)
			if spike:
				spike.monitoring = true
		"crumble":
			visual.color = Color(0.45, 0.3, 0.12, 1.0)
		"moving":
			visual.color = Color(0.35, 0.55, 0.85, 1.0)
			move_dir = 1.0 if randf() > 0.5 else -1.0
		"golden":
			visual.color = Color(1.0, 0.85, 0.2, 1.0)
			_add_glow_light(Color(1.0, 0.9, 0.45, 1.0), 0.7)
		_:
			visual.color = Color(0.55, 0.35, 0.15, 1.0)


func _add_glow_light(color: Color, energy: float) -> void:
	if _goal_light != null:
		return
	_goal_light = PointLight2D.new()
	_goal_light.color = color
	_goal_light.energy = energy
	_goal_light.texture_scale = 0.45
	_goal_light.shadow_enabled = false
	add_child(_goal_light)


func _physics_process(delta: float) -> void:
	if platform_kind == "moving":
		position.x += move_dir * move_speed * delta
		if position.x < 100.0 or position.x > 1180.0:
			move_dir *= -1.0


func _on_body_entered(body: Node2D) -> void:
	if platform_kind == "crumble" and body is CharacterBody2D:
		await get_tree().create_timer(0.35).timeout
		queue_free()


func _on_spike_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
