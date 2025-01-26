class_name Kuka
extends StaticBody3D

@export var tool_scene: PackedScene

var tool: Tool

func _ready() -> void:
	if tool_scene != null: 
		tool = tool_scene.instantiate()
		add_child(tool)

func take_tool() -> PackedScene:
	if tool != null: tool.queue_free()
	var taken_tool_scene = tool_scene
	tool_scene = null
	return taken_tool_scene

func return_tool(new_tool: Tool, new_tool_scene: PackedScene):
	if new_tool_scene != null:
		new_tool.queue_free()
		tool_scene = new_tool_scene
		tool = tool_scene.instantiate()
		add_child(tool)
		tool.scale = Vector3(0.6, 0.6, 0.6)

func is_empty() -> bool:
	if tool != null: return false
	else: return true
