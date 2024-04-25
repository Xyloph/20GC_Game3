extends Node2D
class_name WaterThing

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

enum going {right, left}
@export var direction: going
@export var speed := 250.0
@export var lower_right: Node2D

signal player_attach(log:WaterThing)
signal player_detach(log:WaterThing)

func _ready() -> void:
	if direction == going.left:
		scale.x *= -1

func _process(delta: float) -> void:
	#print(position.x)
	position.x = lerpf(position.x, position.x - speed if direction == going.left else position.x + speed, delta)

func restart(area:CollisionShape2D) -> void:
	var rect : RectangleShape2D = area.shape
	if direction == going.right:
		position.x = area.position.x - (rect.size.x / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2.0)
	else:
		position.x = area.position.x + (rect.size.x / 2.0) - (collision_shape_2d.shape.get_rect().size.x / 2.0)

# When the frog enters this object, to move the frog along
func _on_area_2d_body_entered(_body: Node2D) -> void:
	player_attach.emit(self)

# When the frog leaves this object, to stop moving the frog along
func _on_area_2d_body_exited(_body: Node2D) -> void:
	player_detach.emit(self)
	
func get_velocity() -> Vector2:
	return Vector2(speed if direction == going.right else -speed, 0.)
