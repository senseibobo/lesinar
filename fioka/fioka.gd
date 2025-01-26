class_name Fioka
extends StaticBody3D

@export var available_corpses: Array[CorpseInfo]
@export var anim_player: AnimationPlayer
@export var lampica: MeshInstance3D
 
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


func take_corpse() -> PackedScene:
	if current_corpse == null: return null
	anim_player.play("open")
	lampica.visible = false
	next_corpse_time_left = corpse_cooldown
	var scene: PackedScene = current_corpse.scene
	current_corpse = null
	return scene
