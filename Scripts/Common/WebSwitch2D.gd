@tool
extends Node2D
class_name WebSwitch2D

@export var default_node: Node2D
@export var web_node: Node2D

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not default_node:
			default_node = find_child("*efault*")
		if not web_node:
			web_node = find_child("*eb*")
	else:
		assert(default_node)
		assert(web_node)
		
		if PlatformGlobals_Class.IsWeb():
			web_node.visible = true
			default_node.queue_free()
		else:
			web_node.queue_free()
			default_node.visible = true
