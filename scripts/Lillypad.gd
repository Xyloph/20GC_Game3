extends Node2D
class_name Lillypad

@onready var sprite: Sprite2D = $Sprite2D

signal win

var won := false

var win_sprite_res = preload("res://art/frog-done.png")

var move_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.rotation = randf_range(0.0, PI)
	move_tween = get_tree().create_tween().set_loops()
	move_tween.tween_property(sprite, "rotation", randf_range(0.0, PI),randf_range(2.,4.))
	move_tween.tween_property(sprite, "rotation", randf_range(0.0, PI), randf_range(2.,4.))

func _on_win_area_body_entered(body: Node2D) -> void:
	if not won:
		won = true
		move_tween.stop()
		sprite.rotation = 0
		sprite.texture = win_sprite_res
		win.emit()
