extends CharacterBody2D
class_name Frog

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var frog_idle: Sprite2D = $"Frog-idle"
@onready var frog_jump: Sprite2D = $"Frog-jump"
@onready var frog: Frog = $"."


const travel_distance := 85.0 # this is equally abstract as the hand-drawn level
var moving := false
var log_velocity := Vector2(0.,0.)
var attached_log : WaterThing

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frog_jump.hide()
	frog_idle.show()
	anim.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not moving:
		position = position.lerp(position+ log_velocity, delta)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if not moving:
		var target_position = Vector2(position)
		if event.is_action("ui_left"):
			# move left
			moving = true
			rotation = 3*PI/2
			target_position.x -= travel_distance
			pass
		elif event.is_action("ui_right"):
			# move right
			moving = true
			rotation = PI / 2
			target_position.x += travel_distance
			pass
		elif event.is_action("ui_up"):
			# move up
			moving = true
			rotation = 0
			target_position.y -= travel_distance
			pass
		elif event.is_action("ui_down"):
			# move down
			moving = true
			rotation = PI
			target_position.y += travel_distance
			pass
		get_viewport().set_input_as_handled()
		if moving:
			anim.play("jump")
			var move_tween = get_tree().create_tween()
			move_tween.tween_property(frog, "position", target_position, 0.5)
			move_tween.tween_callback(_done_moving)
	
func _done_moving() -> void:
	moving = false
	frog_idle.show()
	frog_jump.hide()
	anim.play("idle")
	
func follow_log(floating_log:WaterThing):
	attached_log = floating_log
	log_velocity = floating_log.get_velocity()
	pass
	
func unfollow_log(floating_log:WaterThing):
	if attached_log == floating_log:
		log_velocity = Vector2.ZERO
	pass
