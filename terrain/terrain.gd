class_name Terrain
extends Node3D


signal grave_dug


@export var mesh_instance: MeshInstance3D
@export var preview_mesh: MeshInstance3D
@export var granice: Granice

@export var selected_grave_info: GraveInfo = preload("res://graves/normal/normal_grave_info.tres")

var heightmap: Image
var grid: Array#[Array[int]]
var grid_size := Vector2(30,30)
var old_preview_pos: Vector2
var preview_active: bool = false
var dig_range: float = 5.0


func _ready() -> void:
	generate_grid()
	heightmap = Image.create(grid_size.x,grid_size.y,false,Image.FORMAT_RGB8)
	update_heightmap()
	update_terrain_mode(null)


func update_terrain_mode(held_tool: Tool):
	preview_mesh.visible = true
	preview_active = true
	if held_tool is Pijuk:
		selected_grave_info = preload("res://graves/jama/jama_grave_info.tres")
	elif held_tool is Shovel:
		selected_grave_info = preload("res://graves/normal/normal_grave_info.tres")
	elif held_tool is Krec:
		selected_grave_info = preload("res://graves/zivi_krec/zivi_krec_info.tres")
	else:
		selected_grave_info = null
		print("batonga")
		preview_mesh.visible = false
		preview_active = false

func check_dig_available(origin: Vector2i, size: Vector2i):
	if origin.x <= 0 or origin.x >= grid_size.x - 1: return false
	if origin.y <= 0 or origin.y >= grid_size.y - 1: return false
	var min_distance: int = 1
	var x_min: int = clamp(origin.x-min_distance,			0,	grid_size.x-min_distance)
	var x_max: int = clamp(origin.x+min_distance+size.x,	0,	grid_size.x-min_distance)
	var y_min: int = clamp(origin.y-min_distance,			0,	grid_size.y-min_distance)
	var y_max: int = clamp(origin.y+min_distance+size.y,	0,	grid_size.y-min_distance)
	
	if granice and not granice.check_out_of_bounds(origin,size):
		return false
	
	for x in range(x_min, x_max):
		for y in range(y_min, y_max):
			if grid[x][y] != 0:
				return false
	return true


func dig_grave(origin: Vector2i, size: Vector2i, depth: int):
	for x in range(origin.x, origin.x + size.x):
		for y in range(origin.y, origin.y + size.y):
			grid[x][y] = depth
			heightmap.set_pixelv(Vector2i(x,y), Color.BLACK.lerp(Color.WHITE, depth/16.0))
	var grave: Grave = selected_grave_info.grave_scene.instantiate()
	QuestManager.complete_quest(QuestManager.Quest.DIG_GRAVE)
	ScoreManager.on_grave_dug(grave)
	add_child(grave)
	var pos := Vector2(origin) * get_aspect()
	grave.global_position = Vector3(pos.x+0.5, 0.0, pos.y+0.5)
	update_heightmap()


func get_aspect() -> Vector2:
	var mesh: PlaneMesh = mesh_instance.mesh
	return mesh.size/grid_size


func update_heightmap():
	mesh_instance.material_override.set("shader_parameter/heightmap", ImageTexture.create_from_image(heightmap))


func generate_grid():
	grid = []
	for i in grid_size.x:
		grid.append([])
		for j in grid_size.y:
			grid[i].append(0)
			

func _process(delta):
	if selected_grave_info != null:
		_process_preview_place()
		_process_attempt_place()


func _process_attempt_place():
	if Input.is_action_just_pressed("use"):
		if not preview_active: return
		if not check_dig_available(get_dig_pos(), selected_grave_info.size): return
		dig_grave(get_dig_pos(), selected_grave_info.size, selected_grave_info.depth)
		grave_dug.emit()
		update_preview_color()


func _process_preview_place():
	var camera: Camera3D = get_viewport().get_camera_3d()
	var from: Vector3 = camera.global_position
	var dir: Vector3 = -camera.global_basis.z.normalized()
	var intersection = Plane(Vector3.UP, Vector3(0.0,-0.5,0.0)).intersects_ray(from, dir)
	if intersection != null and intersection.distance_to(camera.global_position) < dig_range:
		preview_mesh.visible = true
		preview_active = true
		var pos: Vector3 = intersection
		var grid_pos: Vector2 = get_grid_pos(pos)
		var rounded := Vector3(round(pos.x), global_position.y, round(pos.z))
		if grid_pos != old_preview_pos:
			old_preview_pos = grid_pos
			
			var mesh_size: Vector2 = mesh_instance.mesh.size
			var aspect: Vector2 = mesh_size/grid_size
			var preview_pos: Vector2 = grid_pos*aspect
			var grave_size: Vector2 = selected_grave_info.size
			
			var dig_pos = get_dig_pos()
			var local_pos: Vector2 = (Vector2(dig_pos.x+grave_size.x/2.0, dig_pos.y+grave_size.y/2.0))*aspect
			preview_mesh.global_position = Vector3(local_pos.x, 0.0, local_pos.y)
			
			#var s = Vector3(int((selected_grave_info.size.x) / 2.0), 0.4, (selected_grave_info.size.y)/2.0)
			
			var box_mesh: BoxMesh = preview_mesh.mesh
			box_mesh.size = Vector3(selected_grave_info.size.x*aspect.x, 1.0, selected_grave_info.size.y*aspect.y)
			#box_mesh.size += Vector3(0.15,0.0,0.15)
			update_preview_color()
	else:
		preview_mesh.visible = false
		preview_active = false


func update_preview_color():
	var color := Color.AQUA
	if not check_dig_available(get_dig_pos(), selected_grave_info.size):
		color = Color.RED
	color.a = 0.3
	preview_mesh.material_override.albedo_color = color


func get_dig_pos():
	return Vector2i(old_preview_pos - Vector2(selected_grave_info.size/2))


func get_grid_pos(pos) -> Vector2i:
	var uv_pos: Vector2 = get_uv_pos(pos)
	return Vector2i(uv_pos*grid_size)


func get_uv_pos(pos) -> Vector2: # returns 0-1
	var mesh: PlaneMesh = mesh_instance.mesh
	if pos is Vector3 or pos is Vector3i:
		pos = Vector2(pos.x, pos.z)
	return pos/mesh.size
