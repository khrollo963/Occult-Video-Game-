extends RefCounted

class_name SceneNav


static func go(path: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var tm: Node = tree.root.get_node_or_null("/root/TransitionManager")
	if tm and tm.has_method("change_scene"):
		tm.change_scene(path)
	else:
		tree.change_scene_to_file(path)
