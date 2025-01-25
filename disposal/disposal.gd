class_name Disposal
extends StaticBody3D

@export var max_bodies: int

var bodies: int

func _ready() -> void:
	bodies = 0

func put_body() -> bool:
	if bodies < max_bodies: 
		bodies += 1
		return true
	else:
		return false
