class_name Crematory
extends Grave


@export var corpse_begin_marker: Marker3D

func _add_corpse_instance(corpse_instance: Corpse):
	add_child(corpse_instance)
	corpse_instance.position = corpse_begin_marker.position
	corpse_instance.rotation = corpse_begin_marker.rotation
	var tween = corpse_instance.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(corpse_instance, "position:x", corpse_instance.position.x - 5, 4.0)
