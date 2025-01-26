class_name NormalGrave
extends Grave

@export var name_label: Label3D
@export var year_label: Label3D
@export var audio_player: AudioStreamPlayer3D
@export var marker: Marker3D
@export var dirt_mesh_instance: MeshInstance3D


func add_corpse(corpse_info: CorpseInfo = null) -> bool:
	print("batonga")
	var added: bool = super(corpse_info)
	if added:
		print("batonga2")
		name_label.text = corpse_info.formatted_name
		year_label.text = str(corpse_info.birth_year,"-",Time.get_date_dict_from_system().year)
		name_label.visible = true
		year_label.visible = true
	return added


func _add_corpse_instance(corpse_instance: Corpse):
	audio_player.play()
	marker.add_child(corpse_instance)
	corpse_instance.position.y += 2.0
	var tween = corpse_instance.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel()
	tween.tween_property(corpse_instance, "position:y", marker.position.y, 1.0)
	tween.tween_property(dirt_mesh_instance, "position:y", dirt_mesh_instance.position.y + 1.0, 2.5)
