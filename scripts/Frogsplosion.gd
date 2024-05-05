extends Node2D
class_name Frogsplosion

# when animation is done
signal done
var parts:Array[Sprite2D] = []

# animation speed in seconds
@export var animation_speed : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parts.append($Head)
	parts.append($Leg1)
	parts.append($Leg2)
	parts.append($Leg3)
	parts.append($Leg4)

# set visible and start animation
func play(direction: Vehicule.going) -> void:
	# show ourselves
	show()
	
	# animate
	var tw := get_tree().create_tween().set_parallel().set_ease(Tween.EASE_IN)
	for i in range(5):
		# pick a random point in the direction we were hit and move to it
		tw.tween_property(parts[i], "position", 
			Vector2(1 if direction == Vehicule.going.right else -1, randf_range(-0.5,0.5))*randfn(400.0,100.0), 
			animation_speed)
		tw.tween_property(parts[i], "rotation", randf_range(0.0, 3.0*TAU), animation_speed)
	
	# call the second part of the animation on another tween
	tw.finished.connect(self._fade_out)

# fade out the parts before done signal
func _fade_out() -> void:
	var tw := get_tree().create_tween().set_ease(Tween.EASE_IN)
	tw.tween_interval(1.0)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func():done.emit())
