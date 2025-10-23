@tool
extends Node2D
class_name WebSwitch2D

@export var web_node: Node2D:
	get():
		if not web_node:
			return find_child("*eb*")
		return web_node

@export var default_node: Node2D:
	get():
		if not default_node:
			return find_child("*efault*")
		return default_node

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		if PlatformGlobals_Class.IsWeb():
			web_node.visible = true
			default_node.queue_free()
		else:
			web_node.queue_free()
			default_node.visible = true
