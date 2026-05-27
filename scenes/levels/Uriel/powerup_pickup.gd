extends Area2D

@export var speed := 400.0

var _game: Node = null


func set_game(game: Node) -> void:
	_game = game


func _ready() -> void:
	monitoring = true


func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -120.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _game == null or not _game.has_method("collect_powerup"):
		return
	if body == _game.get("yuri"):
		_game.collect_powerup()
		queue_free()
