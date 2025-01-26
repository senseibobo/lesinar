class_name Shovel
extends Tool

@export var anim_player : AnimationPlayer
@export var audio_player: AudioStreamPlayer

func use():
	anim_player.play("use")
