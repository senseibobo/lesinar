
class_name Granice
extends Node3D

@export var borders_csg: CSGBox3D

@export var border_speed: float = 0.011#*20.0
@export var border_start_distance: float = 15.0


func _ready():
	ScoreManager.score_acquired.connect(make_borders_closer.bind(1))
	borders_csg.size.x = border_start_distance*2.0
	borders_csg.size.z = border_start_distance*2.0
	borders_csg.position.x = 0.0
	borders_csg.position.z = 0.0

func _physics_process(delta):
	ScoreManager.on_area_change(calculate_area())


func make_borders_closer(distance: float):
	borders_csg.size.x -= distance*2.0
	borders_csg.size.z -= distance
	borders_csg.position.z += distance/2.0


func calculate_area():
	return borders_csg.size.x * borders_csg.size.z


func check_out_of_bounds(origin: Vector2, size: Vector2):
	var max_x = borders_csg.global_position.x + borders_csg.size.x/2.0
	var min_x = borders_csg.global_position.x - borders_csg.size.x/2.0
	var max_z = borders_csg.global_position.z + borders_csg.size.z/2.0
	var min_z = borders_csg.global_position.z - borders_csg.size.z/2.0
	if origin.x < min_x or origin.y < min_z or origin.x + size.x > max_x or origin.y + size.y > max_z:
		return false
	return true
