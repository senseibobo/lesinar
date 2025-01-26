class_name Fioka
extends StaticBody3D

@export var available_corpses: Array[CorpseInfo]
@export var anim_player: AnimationPlayer
@export var lampica: MeshInstance3D

@export var name_label: Label3D
@export var value_label: Label3D
@export var screen: Node3D
 
var current_corpse: CorpseInfo
var corpse_cooldown: float = 10.0
var next_corpse_time_left: float = 0.0
#@onready var niz: Array = [komunalni_les, standardni_les, bogati_les]

func _ready() -> void:
	fill_with_corpse()


func _process(delta) -> void:
	if current_corpse == null and next_corpse_time_left > 0:
		next_corpse_time_left -= delta
		if next_corpse_time_left <= 0.0:
			fill_with_corpse()


func fill_with_corpse():
	current_corpse = available_corpses.pick_random()
	lampica.visible = true
	if current_corpse == null: return
	current_corpse = available_corpses.pick_random()
	screen.visible = true
	value_label.text = str("$",current_corpse.value)
	name_label.text = current_corpse.get_random_name_formatted()


func take_corpse() -> CorpseInfo:
	if current_corpse == null: return null
	anim_player.play("open")
	lampica.visible = false
	screen.visible = false
	next_corpse_time_left = corpse_cooldown
	corpse_cooldown = random_corpse_time()
	var corpse_info: CorpseInfo = current_corpse
	current_corpse = null
	return corpse_info

func random_corpse_time() -> float:
	return 40.0+randf()*30.0
