extends Node2D

@export var color := Color(1.0, 0.9, 0.4, 1.0)
@export var amount := 12
@export var spread := 180.0
@export var initial_velocity := 120.0

static var _dot_texture: ImageTexture


func _ready() -> void:
	var particles := GPUParticles2D.new()
	var particle_amount := maxi(4, int(amount * _particle_scale()))
	particles.amount = particle_amount
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.35 if _is_web() else 0.45
	particles.emitting = true
	particles.finished.connect(queue_free)

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = spread
	mat.initial_velocity_min = initial_velocity * 0.6
	mat.initial_velocity_max = initial_velocity
	mat.gravity = Vector3(0, 280, 0)
	mat.scale_min = 2.0
	mat.scale_max = 5.0
	mat.color = color
	particles.process_material = mat
	particles.texture = _get_dot_texture()
	add_child(particles)


static func _get_dot_texture() -> ImageTexture:
	if _dot_texture == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_dot_texture = ImageTexture.create_from_image(img)
	return _dot_texture


static func _is_web() -> bool:
	return OS.has_feature("web")


static func _particle_scale() -> float:
	return 0.45 if _is_web() else 1.0
