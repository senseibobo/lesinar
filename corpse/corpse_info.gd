class_name CorpseInfo
extends Resource


@export var value: int
@export var scene: PackedScene
@export var first_names: Array[String]
@export var last_names: Array[String]


func get_random_name():
	return first_names.pick_random() + " " + last_names.pick_random()


func get_random_name_formatted():
	return first_names.pick_random() + "\n" + last_names.pick_random()
