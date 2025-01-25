class_name Shovel
extends Tool

@export var anim_player : AnimationPlayer

func use():
	anim_player.play("use")
