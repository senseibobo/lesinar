class_name Crematory
extends Grave


@export var corpse_begin_marker: Marker3D
@export var conveyor_belt_material: StandardMaterial3D
@export var omni_light: OmniLight3D
@export var scream_sound_player: AudioStreamPlayer3D

@onready var light_start_position: Vector3 = omni_light.position

func _ready():
	ScoreManager.score_acquired.connect(func(): corpses_inside = 0)

func _process(delta):
	var time = Time.get_ticks_msec()/1000.0
	conveyor_belt_material.uv1_offset.y += delta
	omni_light.position = light_start_position + Vector3(sin(time*3.0),cos(time*2.0),sin(time*2.5+PI/3.0))/10.0


func _add_corpse_instance(corpse_instance: CorpseInstance):
	corpse_instance.reparent(self)
	ScoreManager.shred_corpse()
	corpse_instance.position = corpse_begin_marker.position
	corpse_instance.rotation = corpse_begin_marker.rotation
	var tween = corpse_instance.create_tween()
	tween.tween_property(corpse_instance, "position:x", corpse_instance.position.x - 5, 7.0)
	if corpse_instance.corpse_info.alive:
		tween.tween_callback(play_scream_sound)
	tween.tween_callback(corpse_instance.queue_free)


func play_scream_sound():
	scream_sound_player.play()
