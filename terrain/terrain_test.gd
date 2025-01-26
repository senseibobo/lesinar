extends Node3D



func _process(delta):
	$DirectionalLight3D.rotation.y += delta/2.0
