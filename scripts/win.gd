extends Control

func _on_yes_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_no_button_pressed() -> void:
	get_tree().quit()
