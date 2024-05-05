extends Node2D
class_name Wave

const WAVE_1 = preload("res://art/wave1.png")
const WAVE_2 = preload("res://art/wave2.png")
const WAVE_3 = preload("res://art/wave3.png")
const WAVE_4 = preload("res://art/wave4.png")
@onready var sprite: Sprite2D = $Path2D/PathFollow2D/Sprite2D
@onready var path: PathFollow2D = $Path2D/PathFollow2D
@onready var path_2d: Path2D = $Path2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal done

var duration := 1.0 # duration in seconds, randomized

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# randomize duration
	duration = randf_range(0.7, 1.3)
	
	# randomize sprite
	match randi_range(0,4):
		0: sprite.texture = WAVE_1
		1: sprite.texture = WAVE_2
		2: sprite.texture = WAVE_3
		3: sprite.texture = WAVE_4
		
	# randomize points in path2d
	var points : PackedVector2Array = path_2d.curve.get_baked_points()
	for point in points:
		point.x += randf_range(-5,5)
		point.y += randf_range(-5,5)
		
	# tween opacity
	var alpha_tw = get_tree().create_tween()
	sprite.modulate.a = 0.0
	alpha_tw.tween_property(sprite, "modulate:a", 1.0, duration / 4)
	alpha_tw.tween_interval(duration)
	alpha_tw.tween_property(sprite, "modulate:a", 0, duration / 4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress := path.progress_ratio
	if progress >= 0.5: progress -= 0.5
	var speed :float = 0.5*sin((progress/0.5)*PI) + 0.2
	path.progress_ratio = path.progress_ratio + delta * speed / duration
	if path.progress_ratio >= 1.0:
		done.emit()
		path.progress_ratio = 0.0
		_ready()
		audio_stream_player_2d.play()
