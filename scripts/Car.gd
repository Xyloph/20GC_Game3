extends Node2D
class_name Vehicule

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

enum going {right, left}
@export var direction: going
@export var speed := 250.0
@export var lower_right: Node2D

var orig_pos : Vector2

func _ready() -> void:
	orig_pos = position
	if direction == going.left:
		scale.x *= -1

func _process(delta: float) -> void:
	#print(position.x)
	position.x = lerpf(position.x, position.x - speed if direction == going.left else position.x + speed, delta)

func restart(area:CollisionShape2D) -> void:
	var rect : RectangleShape2D = area.shape
	if direction == going.right:
		position.x = area.position.x - (rect.size.x / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2.0)
		#print("restart on x " + str(position.x))
	else:
		position.x = area.position.x + (rect.size.x / 2.0) - (collision_shape_2d.shape.get_rect().size.x / 2.0)
