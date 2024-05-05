extends Node2D
class_name Vehicule

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

enum going {right, left}
@export var direction: going
@export var speed := 250.0
@export var lower_right: Node2D
@onready var area: Area2D = $Area2D
@onready var honking_component: HonkingComponent = $HonkingComponent

signal collision(vehicule:Vehicule, frog:Frog)

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	if direction == going.left:
		scale.x *= -1

func _physics_process(delta: float) -> void:
	position.x = lerpf(position.x, position.x - speed if direction == going.left else position.x + speed, delta)

func restart(restart_area:CollisionShape2D) -> void:
	var rect : RectangleShape2D = restart_area.shape
	if direction == going.right:
		position.x = restart_area.position.x - (rect.size.x / 2.0) + (collision_shape_2d.shape.get_rect().size.x / 2.0)
	else:
		position.x = restart_area.position.x + (rect.size.x / 2.0)# - (collision_shape_2d.shape.get_rect().size.x / 2.0)

# collision!
func _on_area_2d_body_entered(body: Node2D) -> void:
	collision.emit(self, body as Frog)
	honking_component.play_sound()
