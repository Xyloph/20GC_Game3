extends Node2D
class_name HonkingComponent

@onready var honk_player: AudioStreamPlayer2D = $HonkPlayer

func play_sound() -> void:
	honk_player.play()
