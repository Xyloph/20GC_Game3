extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var lower_right: Marker2D = $LowerRight


var camera_default_position : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_default_position = camera.position
	camera.make_current()
	camera.limit_right = int(lower_right.position.x)
	camera.limit_bottom = int(lower_right.position.y)

func _on_level_focus_frog(frog: Frog) -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel()
	tw.tween_property(camera, "zoom", Vector2(1.2,1.2),1.)
	tw.tween_property(camera, "position", frog.position, 0.5)

func _on_level_reset_camera() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel()
	tw.tween_property(camera, "zoom", Vector2(1.,1.),0.5)
	tw.tween_property(camera, "position", camera_default_position, 0.5)
