extends ColorRect

@export var top_color := Color(0.25, 0.12, 0.45, 1.0)
@export var bottom_color := Color(0.12, 0.06, 0.22, 1.0)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_right = 0.0
	offset_bottom = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = preload("res://assets/ui/gradient_bg.gdshader")
	shader_mat.set_shader_parameter("top_color", top_color)
	shader_mat.set_shader_parameter("bottom_color", bottom_color)
	material = shader_mat
