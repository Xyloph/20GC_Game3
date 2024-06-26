extends CharacterBody2D
class_name Frog

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var frog_idle: Sprite2D = $"Frog-idle"
@onready var frog_jump: Sprite2D = $"Frog-jump"
@onready var frog: Frog = $"."
@onready var frogsplosion: Frogsplosion
@onready var jump_sound: AudioStreamPlayer = $JumpPlayer

# easier to reload that one than reuse it
@onready var frogsplosion_scene = preload("res://scenes/Frogsplosion.tscn")
@onready var death_sound: AudioStreamPlayer = $DeathPlayer

const travel_distance := 85.0 # this is equally abstract as the hand-drawn level
var moving := false
var log_velocity := Vector2(0.,0.)
var attached_log : WaterThing
var in_river := false
var drowning := false
var exploding := false
var winning := false
var move_tween : Tween # to be able to stop it when dying
var crash_sound := preload("res://sounds/crash.wav")
var drown_sound := preload("res://sounds/drown.wav")

# emitted once the frog is done drowning
signal dead

# emitted when the camera should focus the frog
signal focus

# emitted when the frog is on a lillypad after the drown check
signal won

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frog_jump.hide()
	frog_idle.show()
	anim.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not moving and not drowning and not exploding:
		position = position.lerp(position+ log_velocity, delta)
		
		# Drown check
		if log_velocity == Vector2.ZERO and in_river and not winning:
			drown()
		elif winning:
			won.emit()
	
func _input(event: InputEvent) -> void:
	if not moving and not drowning and not exploding:
		var target_position = Vector2(position)
		
		# flags for mouse/touch based movements
		var move_left := false
		var move_up := false
		var move_down := false
		var move_right := false

		# set movement from click position
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos = get_global_mouse_position() - position
			if abs(mouse_pos.x) > abs(mouse_pos.y):
				# left/right
				if mouse_pos.x > 70.:
					move_right = true
				elif mouse_pos.x < -70.:
					move_left = true
			else:
				# up/down
				if mouse_pos.y > 70.:
					move_down = true
				elif mouse_pos.y < -70.:
					move_up = true
		else:
			var input_mov_vec := Input.get_vector("left", "right", "up", "down")
			if abs(input_mov_vec.x) > abs(input_mov_vec.y):
				# left/right
				if input_mov_vec.x > 0.:
					move_right = true
				elif input_mov_vec.x < 0.:
					move_left = true
			else:
				# up/down
				if input_mov_vec.y > 0.:
					move_down = true
				elif input_mov_vec.y < 0.:
					move_up = true
		
		if move_left:
			# move left
			moving = true
			rotation = 3*PI/2
			target_position.x -= travel_distance
			pass
		elif move_right:
			# move right
			moving = true
			rotation = PI / 2
			target_position.x += travel_distance
			pass
		elif move_up:
			# move up
			moving = true
			rotation = 0
			target_position.y -= travel_distance
			pass
		elif move_down:
			# move down
			moving = true
			rotation = PI
			target_position.y += travel_distance
			pass
		get_viewport().set_input_as_handled()
		if moving:
			anim.play("jump")
			move_tween = get_tree().create_tween()
			move_tween.tween_property(frog, "position", target_position, 0.5)
			move_tween.tween_callback(_done_moving)
			jump_sound.play()
	
func _done_moving() -> void:
	moving = false
	if not exploding:
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
	# call dead signal after playing the animation
	tw.tween_callback(func():dead.emit())
	death_sound.stream = drown_sound
	death_sound.play()

# Reset the frog vars, used after death
func reset() -> void:
	frog.material.set_shader_parameter("drowning",0.0)
	exploding = false
	in_river = false
	drowning = false
	moving = false
	attached_log = null
	winning = false
	log_velocity = Vector2(0.,0.)
	anim.play("idle")

# blow up froggy
func crash(direction: Vehicule.going):
	# first, hide the full frog
	# spawn frog parts
	# find target points in the direction further away
	# tween frog parts movement to those locations
	# tween rotation to the parts in parallel
	# once done, call signal for restart
	if not exploding:
		exploding = true
		move_tween.stop()
		frogsplosion = frogsplosion_scene.instantiate()
		frogsplosion.done.connect(_done_exploding)
		add_child(frogsplosion)
		focus.emit()
		anim.stop(true)
		
		# hide our alive sprites
		frog_idle.hide()
		frog_jump.hide()
		
		# the fun part
		# reset the frog direction so it blows up the correct way
		rotation = 0
		frogsplosion.play(direction)
		death_sound.stream = crash_sound
		death_sound.play()
		
		
func _done_exploding() -> void:
	dead.emit()
