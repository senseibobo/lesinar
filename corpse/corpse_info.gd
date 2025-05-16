class_name CorpseInfo
extends Resource


@export var value: int
@export var scene: PackedScene
@export var first_names: Array[String]
@export var last_names: Array[String]
@export var alive: bool = false

@export var name: String
@export var formatted_name: String
@export var birth_year: int


func get_random_name():
	return first_names.pick_random() + " " + last_names.pick_random()


func get_random_name_formatted():
	return first_names.pick_random() + "\n" + last_names.pick_random()


func generate_data() -> void:
	name = get_random_name()
	formatted_name = name.replace(" ", "\n")
	birth_year = 1920+randi()%70
	alive = randf() > 0.0
