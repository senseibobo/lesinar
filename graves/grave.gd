class_name Grave
extends Node3D


signal corpse_added
signal corpse_removed


@export var info: GraveInfo
@export var max_corpses: int = 1
@export var value_multiplier: float = 1.0

var corpses_inside: int = 0
var corpse_instances: Array[CorpseInstance]
@export var money_marker: Marker3D



func add_corpse(corpse_instance: CorpseInstance = null) -> bool:
	if corpses_inside >= max_corpses: return false
	corpses_inside += 1
	if corpse_instance:
		_add_corpse_instance(corpse_instance)
	corpse_instances.append(corpse_instance)
	corpse_added.emit()
	return true


func remove_corpse() -> bool:
	if corpses_inside <= 0: return false
	corpses_inside -= 1
	_remove_top_corpse_instance.call_deferred()
	corpse_removed.emit()
	return true


func get_top_corpse_instance() -> CorpseInstance:
	if corpse_instances.size() == 0: return null
	return corpse_instances[-1]


func get_top_corpse_info() -> CorpseInfo:
	if corpse_instances.size() == 0: return null
	return corpse_instances[-1].corpse_info


func _remove_top_corpse_instance():
	var corpse_instance: CorpseInstance = corpse_instances.pop_back()
	#_free_corpse_instance(corpse_instance)


func _free_corpse_instance(corpse_instance: CorpseInstance):
	corpse_instance.queue_free()


func _add_corpse_instance(corpse_instance: CorpseInstance):
	pass
