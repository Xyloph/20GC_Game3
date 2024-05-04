extends Node2D

@onready var area_shape: CollisionShape2D = $RestartOnExit/CollisionShape2D
@onready var frog: Frog = $Frog
@onready var start_position := frog.position

var win_count := 0

# emitted when the camera should focus the frog
signal focus_frog(frog:Frog)

# emitted when the camera should reset
signal reset_camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floating_log : WaterThing in $Logs.get_children():
		# Object.connect()
		floating_log.connect("player_attach", _player_attached)
		floating_log.connect("player_detach", _player_detached)
	for vehicule : Vehicule in $Vehicules.get_children():
		# Signal.connect() - Recommended approach from doc
		vehicule.collision.connect(_car_crash)
	for pad : Lillypad in $Pads.get_children():
		pad.win.connect(_winning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# calls restart on logs and vehicules, which puts them back to the beginning of the zone
func _on_restart_on_exit_area_exited(area: Area2D) -> void:
	if area.get_parent().has_method("restart"):
		area.get_parent().call("restart", area_shape)

# a log dtected the frog entered, used for drowning check
func _player_attached(floating_log:WaterThing):
	frog.follow_log(floating_log)

# a log detected the frog left, used for drowning check
func _player_detached(floating_log:WaterThing):
	frog.unfollow_log(floating_log)

# a car detected a body
func _car_crash(vehicule:Vehicule, frog:Frog):
	frog.crash(vehicule.direction)

# enable drowning detection
func _on_drown_area_body_entered(body: Node2D) -> void:
	frog.enter_river()

# disable drowning detection
func _on_drown_area_body_exited(body: Node2D) -> void:
	frog.leave_river()

# restart the level
func restart() -> void:
	reset_camera.emit()
	frog.position = start_position
	frog.reset()

func _on_frog_focus() -> void:
	focus_frog.emit(frog)

func _on_frog_dead() -> void:
	restart()
	
func _winning() -> void:
	frog.winning = true
	win_count += 1
	
	if win_count == 5:
		# grats!
		# TODO
		pass

func _on_frog_won() -> void:
	restart()
