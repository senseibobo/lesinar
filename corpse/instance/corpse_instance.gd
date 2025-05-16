class_name CorpseInstance
extends Node3D


@export var breathing_sound_player: AudioStreamPlayer3D
@export var corpse_info: CorpseInfo
@export var corpse_mesh_instance: MeshInstance3D

@export var poor_corpse_mesh: ArrayMesh
@export var normal_corpse_mesh: ArrayMesh
@export var rich_corpse_mesh: ArrayMesh


func apply_corpse_info(corpse_info: CorpseInfo):
	self.corpse_info = corpse_info
	match corpse_info.value:
		25: corpse_mesh_instance.mesh = poor_corpse_mesh
		50: corpse_mesh_instance.mesh = normal_corpse_mesh
		100: corpse_mesh_instance.mesh = rich_corpse_mesh


func set_camera_layer(enabled: bool):
	corpse_mesh_instance.layers = 2 if enabled else 1
