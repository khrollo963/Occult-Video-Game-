extends CanvasLayer

var _overlay: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.05, 0.02, 0.12, 0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)


func change_scene(path: String, fade_duration := 0.35) -> void:
	if _busy:
		return
	_busy = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, fade_duration * 0.5)
	await tween.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var fade_in := create_tween()
	fade_in.tween_property(_overlay, "color:a", 0.0, fade_duration * 0.5)
	await fade_in.finished
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
