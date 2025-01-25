class_name Terrain
extends Node3D


@export var mesh_instance: MeshInstance3D
@export var preview_mesh: MeshInstance3D
var heightmap: Image
var grid: Array#[Array[int]]
var grid_size := Vector2(40,40)
var old_preview_pos: Vector2i
var preview_active: bool = false
var preview_size := Vector2i(1,2)


func _ready() -> void:
	generate_grid()
	heightmap = Image.create(grid_size.x,grid_size.y,false,Image.FORMAT_RGB8)
	update_heightmap()
	dig_grave(Vector2i(2,2), Vector2i(2,3), 3)
	dig_grave(Vector2i(5,2), Vector2i(2,3), 7)


func check_dig_available(origin: Vector2i, size: Vector2i):
	print("ORIGIN ", origin)
	if origin.x <= 0 or origin.x >= grid_size.x - 1: return false
	if origin.y <= 0 or origin.y >= grid_size.y - 1: return false
	var x_min: int = clamp(origin.x-1,0,grid_size.x-1)
	var x_max: int = clamp(origin.x+size.x+1,0,grid_size.x-1)
	var y_min: int = clamp(origin.y-1,0,grid_size.y-1)
	var y_max: int = clamp(origin.y+size.y+1,0,grid_size.y-1)
	for x in range(x_min, x_max):
		for y in range(y_min, y_max):
			if grid[x][y] != 0:
				return false
	print("testic 7")
	return true


func dig_grave(origin: Vector2i, size: Vector2i, depth: int):
	print("digging grave at ", origin, ", size: ", size)
	for i in range(origin.x, origin.x + size.x):
		for j in range(origin.y, origin.y + size.y):
			grid[i][j] = depth
			heightmap.set_pixelv(Vector2i(i,j), Color.BLACK.lerp(Color.WHITE, depth/16.0))
			print(depth/16.0)
			print(Color.BLACK.lerp(Color.WHITE, depth/16.0))
	update_heightmap()


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
		print("testic 1")
		if not preview_active: return
		print("testic 2")
		var grid_pos: Vector2i = get_grid_pos_from_position(old_preview_pos)
		if not check_dig_available(grid_pos, preview_size): return
		print("testic 3")
		dig_grave(grid_pos, preview_size, 5)


func _process_preview_place():
	var camera: Camera3D = get_viewport().get_camera_3d()
	var from: Vector3 = camera.global_position
	var dir: Vector3 = -camera.global_basis.z.normalized()
	var intersection = Plane(Vector3.UP).intersects_ray(from, dir)
	if intersection != null:
		preview_active = true
		var pos: Vector3 = intersection
		var snapped_pos: Vector2i = get_snapped_pos(pos)
		var rounded := Vector3(round(pos.x), global_position.y, round(pos.z))
		if snapped_pos != old_preview_pos:
			old_preview_pos = snapped_pos
			
			var size_offset := Vector3(preview_size.x/2.0, 0.0, preview_size.y/2.0)
			preview_mesh.global_position = rounded - Vector3(0.5, 0.0, 0.5) + size_offset
			
			var box_mesh: BoxMesh = preview_mesh.mesh
			box_mesh.size = Vector3(preview_size.x, 1.0, preview_size.y)
	else:
		preview_active = false
		

func get_grid_pos_from_position(pos):
	var snapped_pos = get_snapped_pos(pos)
	return Vector2i(Vector2(snapped_pos) + grid_size/2)


func get_snapped_pos(pos):
	if pos is Vector3 or pos is Vector3i:
		return Vector2i(round(pos.x), round(pos.z))
	elif pos is Vector2 or pos is Vector2i:
		return Vector2i(round(pos.x), round(pos.y))


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var plane := Plane(Vector3.UP)
			var camera: Camera3D = get_viewport().get_camera_3d()
			var from: Vector3 = camera.project_ray_origin(event.position)
			var dir: Vector3 = camera.project_ray_normal(event.position)
			var intersection = plane.intersects_ray(from, dir)
			if intersection != null:
				var intersection_point: Vector3 = intersection
				paint_hole(Vector2(intersection_point.x, intersection_point.z))


func paint_hole(hole_position: Vector2):
	var mesh: PlaneMesh = mesh_instance.mesh
	var heightmap_position: Vector2 = hole_position / mesh.size * grid_size + grid_size/2.0
	if Rect2(1,1,grid_size.x-2, grid_size.y-2).has_point(heightmap_position):
		var top_y: int = round(heightmap_position.y / 2.0) * 2
		var bottom_y: int = top_y + 1
		heightmap_position.x = round(heightmap_position.x)
		heightmap_position.y = top_y
		heightmap.set_pixelv(heightmap_position, Color.WHITE)
		heightmap_position.y = bottom_y
		heightmap.set_pixelv(heightmap_position, Color.WHITE)
		update_heightmap()
