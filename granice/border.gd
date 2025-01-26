class_name Border
extends AnimatableBody3D


@onready var granice: Granice = get_parent()

func _ready():
	position = -global_basis.z*granice.border_start_distance
	position.y = 5


func _physics_process(delta: float) -> void:
	global_position += granice.border_speed*global_basis.z*delta
