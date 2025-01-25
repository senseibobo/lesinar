class_name Fioka
extends StaticBody3D

@export var komunalni_les: PackedScene
@export var standardni_les: PackedScene
@export var bogati_les: PackedScene
@export var anim_player: AnimationPlayer
@export var lampica: MeshInstance3D
 
var can_take: bool
var trenutni: PackedScene
@onready var niz: Array = [komunalni_les, standardni_les, bogati_les]

func _ready() -> void:
	var broj = randi()%3
	print(niz[broj])
	trenutni = niz[broj]
	can_take = true

func _on_timer_timeout() -> void:
	lampica.visible = true
	if can_take: return
	var broj = randi()%3
	trenutni = niz[broj]
	can_take = true

func take_corpse() -> PackedScene:
	if can_take == false: return null
	anim_player.play("open")
	lampica.visible = false
	can_take = false
	return trenutni
