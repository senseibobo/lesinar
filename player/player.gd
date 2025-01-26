class_name Player
extends CharacterBody3D


signal tool_changed(new_tool: Tool)


enum State {MOVE}

var state: State
var move_vector: Vector3
var mouse_move: float
var held_tool: Tool
var held_tool_scene: PackedScene
var held_corpse: Les
var start_pos: Vector3

var score: int

@export var camera: Camera3D
@export var view_camera: Camera3D
@export var hand: Node3D
@export var left_hand: Node3D
@export var right_hand_anim: AnimationPlayer
@export var left_hand_anim: AnimationPlayer
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
			#use_input()
			use_body()
			interact_input()
			anim_input()
		

func _process(delta):
	camera_input()

func move_input(delta: float):
	var input: Vector2 = Input.get_vector("left","right","up","down")
	move_vector = camera.global_basis.z * input.y + camera.global_basis.x * input.x
	move_vector.y = 0.0
	velocity = move_vector*speed;
	move_and_slide()

#func use_input():
	#if Input.is_action_just_pressed("use") and held_tool != null:
		#choose_anim_tool()
		#held_tool.use()

func use_body():
	if Input.is_action_just_pressed("use_corpse") and held_corpse != null:
		if raycast.get_collider() is Disposal:
			if raycast.get_collider().put_body():
				dispose_corpse()


func dispose_corpse():
	left_hand_anim.stop()
	left_hand_anim.play("GRAB")
	score += held_corpse.price
	print(score)
	held_corpse.queue_free()
	held_corpse = null


func interact_input():
	if Input.is_action_just_pressed("interact") and raycast.is_colliding():
		if raycast.get_collider() is Kuka:
			right_hand_anim.stop()
			right_hand_anim.play("GRAB")
			if raycast.get_collider().is_empty():
				raycast.get_collider().return_tool(held_tool, held_tool_scene)
				if held_tool != null: held_tool.queue_free()
				held_tool = null
				held_tool_scene = null
				tool_changed.emit(null)
			elif held_tool == null:
				var taken_tool_scene = raycast.get_collider().take_tool()
				take_tool(taken_tool_scene)
		elif raycast.get_collider() is Fioka and held_corpse == null:
			left_hand_anim.stop()
			left_hand_anim.play("GRAB")
			take_corpse(raycast.get_collider())
		elif raycast.get_collider() is Grave and held_corpse != null:
			if (raycast.get_collider() as Grave).add_corpse():
				dispose_corpse()
			

func anim_input():
	if !right_hand_anim.is_playing() and held_tool: right_hand_anim.play("HOLD")
	if !left_hand_anim.is_playing() and held_corpse != null: left_hand_anim.play("HOLDLESH")
	if !left_hand_anim.is_playing(): left_hand_anim.play("IDLE")
	if !right_hand_anim.is_playing(): right_hand_anim.play("IDLE")


func take_tool(tool_scene: PackedScene):
	if tool_scene == null: return
	held_tool = tool_scene.instantiate()
	held_tool_scene = tool_scene
	hand.add_child(held_tool)
	tool_changed.emit(held_tool)

func choose_anim_tool():
	right_hand_anim.stop()
	if held_tool is Shovel:
		right_hand_anim.play("SHOWEL")
	if held_tool is Pijuk:
		right_hand_anim.play("PIKAC")
	if held_tool is Krec:
		right_hand_anim.play("KREC")

func take_corpse(fioka: Fioka):
	var taken_corpse = fioka.take_corpse()
	if taken_corpse != null:
		held_corpse = taken_corpse.instantiate()
		left_hand.add_child(held_corpse)

func move_to_start():
	global_position = start_pos

func camera_input():
	view_camera.global_transform = camera.global_transform


func _on_grave_dug():
	choose_anim_tool()
