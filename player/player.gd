class_name Player
extends CharacterBody3D

enum State {MOVE}

var state: State
var move_vector: Vector3
var mouse_move: float
var held_tool: Tool
var held_tool_scene: PackedScene
var held_corpse: Les

var score: int

@export var camera: Camera3D
@export var hand: Node3D
@export var left_hand: Node3D
@export var raycast: RayCast3D
@export var speed: float
@export var sensitivity: float

func _ready() -> void:
	held_corpse = null
	score = 0
	state = State.MOVE
	move_vector = Vector3()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move = event.relative.x*sensitivity*-1
		camera.rotate_x(deg_to_rad(clamp(event.relative.y*-1*sensitivity, -75.0, 75.0)))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -75.0, 75.0)
		rotate_y(deg_to_rad(event.relative.x*-1*sensitivity))

func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			move_input(delta)
			use_input()
			use_body()
			interact_input()

func move_input(delta: float):
	var input: Vector2 = Input.get_vector("left","right","up","down")
	move_vector = camera.global_basis.z * input.y + camera.global_basis.x * input.x
	move_vector.y = 0.0
	velocity = move_vector*speed;
	move_and_slide()

func use_input():
	if Input.is_action_pressed("use") and held_tool != null:
		held_tool.use()

func use_body():
	if Input.is_action_pressed("use_corpse") and held_corpse != null:
		if raycast.get_collider() is Disposal:
			if raycast.get_collider().put_body():
				score += held_corpse.price
				print(score)
				held_corpse.queue_free()
				held_corpse = null

func interact_input():
	if Input.is_action_just_pressed("interact") and raycast.is_colliding():
		if raycast.get_collider() is Kuka:
			if raycast.get_collider().is_empty():
				raycast.get_collider().return_tool(held_tool, held_tool_scene)
				if held_tool != null: held_tool.queue_free()
				held_tool = null
				held_tool_scene = null
			elif held_tool == null:
				var taken_tool_scene = raycast.get_collider().take_tool()
				take_tool(taken_tool_scene)
		if raycast.get_collider() is Fioka and held_corpse == null:
			take_corpse(raycast.get_collider())

func take_tool(tool_scene: PackedScene):
	if tool_scene == null: return
	held_tool = tool_scene.instantiate()
	held_tool_scene = tool_scene
	hand.add_child(held_tool)

func take_corpse(fioka: Fioka):
	var taken_corpse = fioka.take_corpse()
	if taken_corpse != null:
		held_corpse = taken_corpse.instantiate()
		left_hand.add_child(held_corpse)
