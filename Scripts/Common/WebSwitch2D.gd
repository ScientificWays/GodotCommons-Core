@tool
extends Node2D
class_name WebSwitch2D

@export var default_scene_path: String
@export var web_scene_path: String
@export var parent_override: Node
@export var editor_preview: bool = true:
	set(in_preview):
		editor_preview = in_preview
		instantiate_node()

var instantiated_node: Node

func _ready() -> void:
	
	if Engine.is_editor_hint():
		
		if editor_preview:
			instantiate_node()
		
	else:
		instantiate_node()

func instantiate_node() -> void:
	
	if not is_node_ready():
		return
	
	if is_instance_valid(instantiated_node):
		instantiated_node.queue_free()
	
	if Engine.is_editor_hint() and not editor_preview:
		return
	
	var scene := ResourceLoader.load(web_scene_path if PlatformGlobals_Class.is_web() else default_scene_path, "PackedScene") as PackedScene
	instantiated_node = scene.instantiate()
	
	if parent_override:
		parent_override.add_child.call_deferred(instantiated_node)
	else:
		add_child.call_deferred(instantiated_node)
