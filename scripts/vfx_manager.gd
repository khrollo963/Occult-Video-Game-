extends Node

const EFFECTS := {
	"pickup_burst": preload("res://scenes/vfx/pickup_burst.tscn"),
	"hit_spark": preload("res://scenes/vfx/hit_spark.tscn"),
	"death_poof": preload("res://scenes/vfx/death_poof.tscn"),
	"landing_dust": preload("res://scenes/vfx/landing_dust.tscn"),
}


func _ready() -> void:
	get_node("/root/EventBus").vfx_requested.connect(_spawn_effect)
	get_node("/root/EventBus").collectible_picked.connect(func(_v): pass)
	get_node("/root/EventBus").enemy_killed.connect(func(): pass)


func spawn(effect_id: String, global_pos: Vector2) -> void:
	_spawn_effect(effect_id, global_pos)


func _spawn_effect(effect_id: String, global_pos: Vector2) -> void:
	if not get_node("/root/SettingsManager").visual_effects_enabled:
		return
	if not EFFECTS.has(effect_id):
		return
	var scene: PackedScene = EFFECTS[effect_id]
	var inst := scene.instantiate()
	var root := get_tree().current_scene
	if root == null:
		inst.queue_free()
		return
	root.add_child(inst)
	if inst is Node2D:
		if global_pos != Vector2.ZERO:
			inst.global_position = global_pos
		elif root.has_method("get_player_position"):
			inst.global_position = root.get_player_position()
	if inst is GPUParticles2D:
		inst.emitting = true
		inst.finished.connect(inst.queue_free)
	elif inst.has_node("Particles"):
		var particles: GPUParticles2D = inst.get_node("Particles")
		particles.emitting = true
		particles.finished.connect(inst.queue_free)
