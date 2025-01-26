class_name Granice
extends Node3D

@export var wall_front: CharacterBody3D
@export var wall_left: CharacterBody3D
@export var wall_right: CharacterBody3D
@export var player: Player
@export var cena: int

func _on_timer_timeout() -> void:
	wall_front.velocity = wall_front.transform.basis.z*55.0
	wall_left.velocity = wall_left.transform.basis.z*55.0
	wall_right.velocity = -wall_right.transform.basis.z*55.0
	#player.move_to_start()
	wall_front.move_and_slide()
	wall_left.move_and_slide()
	wall_right.move_and_slide()
	if player.score > cena:
		player.score -= cena
		
	#else:
		#get_tree().reload_current_scene()
