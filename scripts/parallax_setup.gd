extends ParallaxBackground

class_name ParallaxSetup

@export var layer_colors: Array[Color] = [
	Color(0.08, 0.05, 0.18, 0.9),
	Color(0.15, 0.08, 0.28, 0.75),
	Color(0.25, 0.12, 0.35, 0.55),
]
@export var scroll_speeds: Array[float] = [0.15, 0.35, 0.6]


static func create(colors: Array[Color], speeds: Array[float] = []) -> ParallaxSetup:
	var bg := ParallaxSetup.new()
	bg.layer_colors = colors
	if not speeds.is_empty():
		bg.scroll_speeds = speeds
	return bg


func _ready() -> void:
	var settings: Node = get_node("/root/SettingsManager")
	if not settings.parallax_enabled:
		visible = false
		return
	_build_layers()


func _build_layers() -> void:
	for child in get_children():
		child.queue_free()
	for i in layer_colors.size():
		var layer := ParallaxLayer.new()
		var sprite := ColorRect.new()
		sprite.color = layer_colors[i]
		sprite.custom_minimum_size = Vector2(1400, 900)
		sprite.size = Vector2(1400, 900)
		sprite.position = Vector2(-100, -200 + i * 40)
		layer.add_child(sprite)
		layer.motion_scale = Vector2(scroll_speeds[mini(i, scroll_speeds.size() - 1)], 0.2)
		add_child(layer)
