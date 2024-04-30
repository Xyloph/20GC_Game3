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
var in_river := false
var drowning := false

# emitted once the frog is done drowning
signal drowned

# emitted when the camera should focus the frog
signal focus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frog_jump.hide()
	frog_idle.show()
	anim.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not moving and not drowning:
		position = position.lerp(position+ log_velocity, delta)
		
		# Drown check
		if log_velocity == Vector2.ZERO and in_river:
			drown()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if not moving and not drowning:
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
	
# driftin away!
func follow_log(floating_log:WaterThing):
	attached_log = floating_log
	log_velocity = floating_log.get_velocity()
	pass

# leap of faith
func unfollow_log(floating_log:WaterThing):
	if attached_log == floating_log:
		log_velocity = Vector2.ZERO
	pass

# careful, frog can't swim
func enter_river() -> void:
	in_river = true

# can't drown anymore!
func leave_river() -> void:
	in_river = false

# Drown animation then emit signal
func drown() -> void:
	rotation = 0 # it looks better drowning down, so head up
	drowning = true
	focus.emit()
	var tw := get_tree().create_tween()
	# look, a wild gdscript lambda!
	tw.tween_method(func(value:float) : frog.material.set_shader_parameter("drowning",value), 0.0, 1.4, 1.8)
	# call drowned signal after playing the animation
	tw.tween_callback(func():drowned.emit())

# Reset the frog vars, used after death
func reset() -> void:
	frog.material.set_shader_parameter("drowning",0.0)
	in_river = false
	drowning = false
	moving = false
	attached_log = null
	log_velocity = Vector2(0.,0.)
