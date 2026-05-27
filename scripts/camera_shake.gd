extends RefCounted

class_name CameraShakeHelper


static func shake(camera: Camera2D, strength := 8.0, duration := 0.2) -> void:
	if camera == null:
		return
	var original := camera.offset
	var tween := camera.create_tween()
	var steps := int(duration / 0.04)
	for i in steps:
		var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(camera, "offset", offset, 0.04)
	tween.tween_property(camera, "offset", original, 0.04)
