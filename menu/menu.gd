extends Node3D


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world/world.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
