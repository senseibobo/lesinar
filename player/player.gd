class_name Player
extends CharacterBody3D


signal tool_changed(new_tool: Tool)


enum State {MOVE}

var state: State
var move_vector: Vector3
var mouse_move: float
var held_tool: Tool
var held_tool_scene: PackedScene
var held_corpse_instance: Corpse
var held_corpse_info: CorpseInfo
var holding_corpse: bool = false
var start_pos: Vector3

var score: int

@export var camera: Camera3D
@export var view_camera: Camera3D
@export var hand: Node3D
@export var left_hand: Node3D
@export var right_hand_anim: AnimationPlayer
@export var left_hand_anim: AnimationPlayer
@export var left_hand_model: Node3D
@export var right_hand_model: Node3D
@export var raycast: RayCast3D
@export var audio_player: AudioStreamPlayer
@export var audio_player_hod: AudioStreamPlayer
@export var dirt_sound: AudioStream
@export var pick_sound: AudioStream
@export var krec_sound: AudioStream
@export var grab_sound: AudioStream
@export var katch_sound: AudioStream
@export var speed: float
@export var sensitivity: float
@export var label: Label

func _ready() -> void:
	score = 0
	state = State.MOVE
	label.visible = false
	move_vector = Vector3()
	ScoreManager.score_acquired.connect(play_catching)
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
			interact_input()
			anim_input()
			exit_input()
		

func exit_input():
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func _process(delta):
	camera_input()
	sway()

func move_input(delta: float):
	var input: Vector2 = Input.get_vector("left","right","up","down")
	move_vector = camera.global_basis.z * input.y + camera.global_basis.x * input.x
	move_vector.y = 0.0
	if move_vector != Vector3(0.0, 0.0, 0.0): 
		if !audio_player_hod.playing:
			audio_player_hod.play()
	else:
		audio_player_hod.stop()
	velocity = move_vector*speed;
	ScoreManager.burn_calories(move_vector.length()*delta * (2 if holding_corpse else 1))
	move_and_slide()

#func use_input():
	#if Input.is_action_just_pressed("use") and held_tool != null:
		#choose_anim_tool()
		#held_tool.use()

func play_catching():
	audio_player.stream = katch_sound
	audio_player.play()

func dispose_corpse():
	left_hand_anim.stop()
	left_hand_anim.play("GRAB")
	score += held_corpse_info.value
	held_corpse_instance.queue_free()
	held_corpse_instance = null
	held_corpse_info = null
	holding_corpse = false


func interact_input():
	check_label()
	if Input.is_action_just_pressed("interact") and raycast.is_colliding():
		if raycast.get_collider() is Kuka:
			label.visible = true
			right_hand_anim.stop()
			right_hand_anim.play("GRAB")
			audio_player.stream = grab_sound
			audio_player.play()
			if raycast.get_collider().is_empty():
				raycast.get_collider().return_tool(held_tool, held_tool_scene)
				if held_tool != null: held_tool.queue_free()
				held_tool = null
				held_tool_scene = null
				tool_changed.emit(null)
			elif held_tool == null:
				var taken_tool_scene = raycast.get_collider().take_tool()
				take_tool(taken_tool_scene)
		elif raycast.get_collider() is Fioka and not holding_corpse:
			label.visible = true
			left_hand_anim.stop()
			left_hand_anim.play("GRAB")
			audio_player.stream = grab_sound
			audio_player.play()
			take_corpse(raycast.get_collider())
		elif raycast.get_collider() is Grave:
			label.visible = true
			var grave: Grave = raycast.get_collider() 
			if holding_corpse:
				if grave.add_corpse(held_corpse_info):
					ScoreManager.on_corpse_disposed(held_corpse_info, grave)
					dispose_corpse()
			else:
				if grave.remove_corpse():
					var corpse_info: CorpseInfo = grave.get_top_corpse_info()
					take_corpse_info(corpse_info)
					left_hand_anim.stop()
					left_hand_anim.play("GRAB")
					ScoreManager.on_corpse_removed(corpse_info, grave)
			

func check_label():
	if raycast.is_colliding():
		if raycast.get_collider() is Kuka:
			label.visible = true
		elif raycast.get_collider() is Fioka and !holding_corpse:
			label.visible = true
		elif raycast.get_collider() is Grave:
			var grave: Grave = raycast.get_collider() as Grave
			if grave.corpses_inside >= grave.max_corpses and holding_corpse:
				label.visible = false
			if grave.corpses_inside > 0 and not holding_corpse:
				label.visible = true
		else:
			label.visible = false
	else:
		label.visible = false

func anim_input():
	if !right_hand_anim.is_playing() and held_tool: right_hand_anim.play("HOLD")
	if !left_hand_anim.is_playing() and holding_corpse: left_hand_anim.play("HOLDLESH")
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
		audio_player.stream = dirt_sound
		audio_player.play()
	if held_tool is Pijuk:
		right_hand_anim.play("PIKAC")
		audio_player.stream = pick_sound
		audio_player.play()
	if held_tool is Krec:
		right_hand_anim.play("KREC")
		audio_player.stream = krec_sound
		audio_player.play()

func take_corpse(fioka: Fioka):
	var corpse_info = fioka.take_corpse()
	if corpse_info != null:
		take_corpse_info(corpse_info)


func take_corpse_info(corpse_info: CorpseInfo):
	holding_corpse = true
	held_corpse_instance = corpse_info.scene.instantiate()
	held_corpse_info = corpse_info
	left_hand.add_child(held_corpse_instance)


func move_to_start():
	global_position = start_pos

func camera_input():
	view_camera.global_transform = camera.global_transform

func sway():
	if mouse_move > 2:
		left_hand_model.position = left_hand_model.position.lerp(Vector3(-0.175, -1.718, -0.455), 5*get_process_delta_time())
		right_hand_model.position = right_hand_model.position.lerp(Vector3(-0.175, -1.718, -0.455), 5*get_process_delta_time())
	elif mouse_move < -2:
		left_hand_model.position = left_hand_model.position.lerp(Vector3(0.1, -1.718, -0.455), 5*get_process_delta_time())
		right_hand_model.position = right_hand_model.position.lerp(Vector3(0.1, -1.718, -0.455), 5*get_process_delta_time())
	else:
		left_hand_model.position = left_hand_model.position.lerp(Vector3(-0.05, -1.718, -0.455), 5*get_process_delta_time())
		right_hand_model.position = right_hand_model.position.lerp(Vector3(-0.05, -1.718, -0.455), 5*get_process_delta_time())

func _on_grave_dug():
	choose_anim_tool()
