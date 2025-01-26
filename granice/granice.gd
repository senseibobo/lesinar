class_name Granice
extends Node3D

@export var north_border: Border
@export var east_border: Border
@export var west_border: Border
@export var south_border: StaticBody3D

@export var border_speed: float = 0.011#*20.0
@export var border_start_distance: float = 15.0


func _physics_process(delta):
	ScoreManager.on_area_change(calculate_area())


func calculate_area():
	var max_x = east_border.global_position.x
	var min_x = west_border.global_position.x
	var max_z = south_border.global_position.z
	var min_z = north_border.global_position.z
	return abs(max_x-min_x)*abs(max_z-min_z)


func check_out_of_bounds(origin: Vector2, size: Vector2):
	var max_x = east_border.global_position.x
	var min_x = west_border.global_position.x
	var max_z = south_border.global_position.z
	var min_z = north_border.global_position.z
	if origin.x < min_x or origin.y < min_z or origin.x + size.x > max_x or origin.y + size.y > max_z:
		return false
	return true
