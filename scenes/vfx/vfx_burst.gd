extends Node2D

@export var color := Color(1.0, 0.9, 0.4, 1.0)
@export var amount := 12
@export var spread := 180.0
@export var initial_velocity := 120.0


func _ready() -> void:
	var particles := GPUParticles2D.new()
	particles.amount = amount
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.45
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

	var tex := _make_dot_texture()
	particles.texture = tex
	add_child(particles)


func _make_dot_texture() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)
