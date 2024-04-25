extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.rotation = randf_range(0.0, PI)
	var tween := get_tree().create_tween().set_loops()	
	tween.tween_property(sprite, "rotation", randf_range(0.0, PI),randf_range(2.,4.))
	tween.tween_property(sprite, "rotation", randf_range(0.0, PI), randf_range(2.,4.))
