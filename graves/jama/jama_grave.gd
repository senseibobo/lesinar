class_name JamaGrave
extends Grave


@export var corpse_containers_node: Node3D
var corpse_containers: Array[Node3D]


func _ready():
	for container in corpse_containers_node.get_children():
		corpse_containers.append(container)


func _add_corpse_instance(corpse_instance: Corpse):
	var container: Node3D = corpse_containers[corpses_inside-1]
	container.add_child(corpse_instance)
	corpse_instance.position.y += 2.0
	var tween = corpse_instance.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(corpse_instance, "position:y", 0.0, 1.0)
