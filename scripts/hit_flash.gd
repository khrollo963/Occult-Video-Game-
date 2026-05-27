extends RefCounted

class_name HitFlashHelper

const FLASH_SHADER := preload("res://assets/ui/hit_flash.gdshader")


static func bind(sprite: CanvasItem) -> ShaderMaterial:
	if sprite.material is ShaderMaterial:
		var existing: ShaderMaterial = sprite.material
		if existing.shader == FLASH_SHADER:
			return existing
	var mat := ShaderMaterial.new()
	mat.shader = FLASH_SHADER
	mat.set_shader_parameter("flash", 0.0)
	sprite.material = mat
	return mat


static func flash(sprite: CanvasItem, duration: float = 0.15) -> void:
	var mat: ShaderMaterial = bind(sprite)
	var tween := sprite.create_tween()
	tween.tween_method(
		func(value: float) -> void: mat.set_shader_parameter("flash", value),
		1.0,
		0.0,
		duration
	)
