class_name Terrain
extends Node3D


@export var mesh_instance: MeshInstance3D
@export var preview_mesh: MeshInstance3D

@export var selected_grave_info: GraveInfo = preload("res://graves/normal/normal_grave_info.tres")

var heightmap: Image
var grid: Array#[Array[int]]
var grid_size := Vector2(40,40)
var old_preview_pos: Vector2
var preview_active: bool = false


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
		preview_mesh.visible = false
		preview_active = false

func check_dig_available(origin: Vector2i, size: Vector2i):
	if origin.x <= 0 or origin.x >= grid_size.x - 1: return false
	if origin.y <= 0 or origin.y >= grid_size.y - 1: return false
	var min_distance: int = 2
	var x_min: int = clamp(origin.x-min_distance,			0,	grid_size.x-min_distance)
	var x_max: int = clamp(origin.x+min_distance+size.x,	0,	grid_size.x-min_distance)
	var y_min: int = clamp(origin.y-min_distance,			0,	grid_size.y-min_distance)
	var y_max: int = clamp(origin.y+min_distance+size.y,	0,	grid_size.y-min_distance)
	for x in range(x_min, x_max):
		for y in range(y_min, y_max):
			if grid[x][y] != 0:
				return false
	return true


func dig_grave(origin: Vector2i, size: Vector2i, depth: int):
	print(origin)
	for x in range(origin.x, origin.x + size.x):
		for y in range(origin.y, origin.y + size.y):
			grid[x][y] = depth
			heightmap.set_pixelv(Vector2i(x,y), Color.BLACK.lerp(Color.WHITE, depth/16.0))
	var grave: Grave = selected_grave_info.grave_scene.instantiate()
	add_child(grave)
	var pos := Vector2(origin) * get_aspect()
	grave.global_position = Vector3(pos.x+0.37, 0.0, pos.y+0.25)
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
	_process_preview_place()
	_process_attempt_place()


func _process_attempt_place():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if not preview_active: return
		if not check_dig_available(get_dig_pos(), selected_grave_info.size): return
		dig_grave(get_dig_pos(), selected_grave_info.size, selected_grave_info.depth)
		update_preview_color()


func _process_preview_place():
	var camera: Camera3D = get_viewport().get_camera_3d()
	var from: Vector3 = camera.global_position
	var dir: Vector3 = -camera.global_basis.z.normalized()
	var intersection = Plane(Vector3.UP, Vector3(0.0,-0.5,0.0)).intersects_ray(from, dir)
	if intersection != null:
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
			
			var local_pos: Vector2 = (Vector2(grid_pos.x, grid_pos.y))*aspect
			
			var size_offset = Vector3(
				(grave_size.x-2)*aspect.x, 
				0.0, 
				(grave_size.y-2)*aspect.y
			)/2.0
			preview_mesh.global_position = Vector3(local_pos.x, 0.0, local_pos.y) + size_offset
			#var s = Vector3(int((selected_grave_info.size.x) / 2.0), 0.4, (selected_grave_info.size.y)/2.0)
			
			var box_mesh: BoxMesh = preview_mesh.mesh
			box_mesh.size = Vector3(selected_grave_info.size.x*aspect.x, 1.0, selected_grave_info.size.y*aspect.y)
			update_preview_color()
	else:
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


#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#selected_grave_info = preload("res://graves/jama/jama_grave_info.tres")
	#elif event.is_action_released("ui_accept"):
		#selected_grave_info = preload("res://graves/zivi_krec/zivi_krec_info.tres")
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#var plane := Plane(Vector3.UP)
			#var camera: Camera3D = get_viewport().get_camera_3d()
			#var from: Vector3 = camera.project_ray_origin(event.position)
			#var dir: Vector3 = camera.project_ray_normal(event.position)
			#var intersection = plane.intersects_ray(from, dir)
			#if intersection != null:
				#var intersection_point: Vector3 = intersection
				#paint_hole(Vector2(intersection_point.x, intersection_point.z))
