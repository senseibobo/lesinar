class_name ScoreDisplay
extends Node3D


@export var score_label: Label3D
@export var disposed_label: Label3D
@export var graves_label: Label3D
@export var area_label: Label3D
@export var calories_label: Label3D


func _ready():
	ScoreManager.score_updated.connect(_on_score_updated)
	ScoreManager.corpses_disposed_updated.connect(_on_corpses_disposed_updated)
	ScoreManager.graves_dug_updated.connect(_on_graves_dug_updated)
	ScoreManager.area_updated.connect(_on_area_updated)
	ScoreManager.calories_burnt_updated.connect(_on_calories_burnt_updated)


func _on_score_updated(new_score: float):
	score_label.text = str("Profit: $", str(new_score).pad_decimals(1))
	
	
func _on_corpses_disposed_updated(new_corpses_disposed: int):
	disposed_label.text = str("Corpses disposed: ", new_corpses_disposed)
	
	
func _on_graves_dug_updated(new_graves_dug: int):
	graves_label.text = str("Graves dug:", new_graves_dug)
	
	
func _on_area_updated(new_area: float):
	area_label.text = str("Free space left: ", str(new_area).pad_decimals(1),"m²")
	
	
func _on_calories_burnt_updated(new_calories_burnt: float):
	calories_label.text = str("Calories burnt: ", str(new_calories_burnt).pad_decimals(0),"kcal")
	
	
