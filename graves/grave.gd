class_name Grave
extends Node3D


signal corpse_added
signal corpse_removed


@export var info: GraveInfo
@export var max_corpses: int = 1

var corpses_inside: int = 0


func add_corpse():
	if corpses_inside >= max_corpses: return false
	corpses_inside += 1
	corpse_added.emit()
	return true


func remove_corpse():
	if corpses_inside <= 0: return false
	corpses_inside -= 1
	corpse_removed.emit()
	return false
