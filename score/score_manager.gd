extends Node


signal score_updated(new_score: float)
signal score_goal_updated(new_score_goal: float)
signal score_acquired()
signal corpses_disposed_updated(new_corpses_disposed: int)
signal graves_dug_updated(new_graves_dug: int)
signal area_updated(new_area: float)
signal calories_burnt_updated(new_calories_burnt: float)
signal corpses_shredded_updated(new_corpses_shredded: float)


var score: float = 0.0
var score_goal: float = 500.0
var corpses_disposed: int = 0
var graves_dug: int = 0
var area_left: float = 0.0
var calories_burnt: float = 0.0
var corpses_shredded: int


const money_label_scene: PackedScene = preload("res://disposal/money_label/money_label.tscn")


func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	score_updated.emit(score)
	corpses_disposed_updated.emit(corpses_disposed)
	graves_dug_updated.emit(graves_dug)
	area_updated.emit(area_left)
	calories_burnt_updated.emit(calories_burnt)
	corpses_shredded_updated.emit(corpses_shredded)


func on_corpse_disposed(corpse_instance: CorpseInstance, grave: Grave):
	var corpse_info: CorpseInfo = corpse_instance.corpse_info
	if grave.money_marker:
		var money_label: MoneyLabel = money_label_scene.instantiate()
		get_tree().current_scene.add_child(money_label)
		money_label.global_position = grave.money_marker.global_position
		money_label.setup(corpse_info.value, grave.value_multiplier)
	score += corpse_info.value * grave.value_multiplier
	corpses_disposed += 1
	corpses_disposed_updated.emit(corpses_disposed)
	if score >= score_goal:
		QuestManager.complete_quest(QuestManager.Quest.FILL_QUOTA)
		score -= score_goal
		score_acquired.emit()
		score_goal += 500.0
	score_updated.emit(score)


func on_corpse_removed(corpse_instance: CorpseInstance, grave: Grave):
	var corpse_info: CorpseInfo = corpse_instance.corpse_info
	score -= corpse_info.value * grave.value_multiplier
	corpses_disposed -= 1
	corpses_disposed_updated.emit(corpses_disposed)
	score_updated.emit(score)


func on_grave_dug(grave: Grave):
	graves_dug += 1
	graves_dug_updated.emit(graves_dug)
	var calorie_cost: float
	if grave is JamaGrave: calorie_cost = 100
	elif grave is NormalGrave: calorie_cost = 50
	elif grave is ZiviKrec: calorie_cost = 150
	burn_calories(calorie_cost)


func on_area_change(new_area: float):
	area_left = new_area
	area_updated.emit(new_area)


func burn_calories(amount: float):
	calories_burnt += amount
	calories_burnt_updated.emit(calories_burnt)


func shred_corpse():
	corpses_shredded += 1
	corpses_shredded_updated.emit(corpses_shredded)
