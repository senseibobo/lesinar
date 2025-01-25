class_name Player
extends CharacterBody3D

enum State {MOVE}

var state: State
var move_vector: Vector3
var mouse_move: float

@export var camera: Camera3D
@export var speed: float
@export var sensitivity: float

func _ready() -> void:
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

func move_input(delta: float):
	var input: Vector2 = Input.get_vector("left","right","up","down")
	move_vector = camera.global_basis.z * input.y + camera.global_basis.x * input.x
	move_vector.y = 0.0
	velocity = move_vector*speed;
	move_and_slide()
