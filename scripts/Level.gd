extends Node2D

@onready var area_shape: CollisionShape2D = $RestartOnExit/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_restart_on_exit_area_exited(area: Area2D) -> void:
	if area.get_parent() is Vehicule:
		var vehicule := area.get_parent() as Vehicule
		vehicule.restart(area_shape)
