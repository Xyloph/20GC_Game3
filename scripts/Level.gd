extends Node2D

@onready var area_shape: CollisionShape2D = $RestartOnExit/CollisionShape2D
@onready var frog: Frog = $Frog
@onready var start_position := frog.position

# emitted when the camera should focus the frog
signal focus_frog(frog:Frog)

# emitted when the camera should reset
signal reset_camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for floating_log : WaterThing in $Logs.get_children():
		floating_log.connect("player_attach", _player_attached)
		floating_log.connect("player_detach", _player_detached)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_restart_on_exit_area_exited(area: Area2D) -> void:
	if area.get_parent().has_method("restart"):
		area.get_parent().call("restart", area_shape)
		
func _player_attached(floating_log:WaterThing):
	frog.follow_log(floating_log)
	pass
	
func _player_detached(floating_log:WaterThing):
	frog.unfollow_log(floating_log)
	pass

func _on_drown_area_body_entered(body: Node2D) -> void:
	frog.enter_river()

func _on_drown_area_body_exited(body: Node2D) -> void:
	frog.leave_river()

func restart() -> void:
	reset_camera.emit()
	frog.position = start_position
	frog.reset()

func _on_frog_drowned() -> void:
	restart()

func _on_frog_focus() -> void:
	focus_frog.emit(frog)
