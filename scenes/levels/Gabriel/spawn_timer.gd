extends Node

func _ready():
	print("Spawner children:")
	for child in get_children():
		print("-", child.name)
