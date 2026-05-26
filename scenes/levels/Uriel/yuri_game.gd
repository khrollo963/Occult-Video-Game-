extends Node2D

var obstacle_scene = preload("res://scenes/levels/uriel/obstacle.tscn")

func _on_obstacle_spawner_timeout():
   var obstacle = obstacle_scene.instantiate()
   obstacle.position = Vector2(640, 300)
   add_child(obstacle)

func _on_back_to_menu_pressed():
   get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
