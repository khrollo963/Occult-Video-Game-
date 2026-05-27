extends RefCounted

const SHEEN_SHADER := preload("res://assets/ui/button_sheen.gdshader")


static func apply_to_button(button: Button) -> void:
	if OS.has_feature("web"):
		return
	if button.get_node_or_null("Sheen"):
		return

	button.clip_contents = true

	var sheen := ColorRect.new()
	sheen.name = "Sheen"
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheen.set_anchors_preset(Control.PRESET_FULL_RECT)

	var material := ShaderMaterial.new()
	material.shader = SHEEN_SHADER
	material.set_shader_parameter("speed", randf_range(0.45, 0.7))
	sheen.material = material

	button.add_child(sheen)
	button.move_child(sheen, 0)


static func apply_to_buttons(buttons: Array[Button]) -> void:
	for button in buttons:
		if button:
			apply_to_button(button)
