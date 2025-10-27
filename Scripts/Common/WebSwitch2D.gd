@tool
extends Node2D
class_name WebSwitch2D

@export var default_scene_path: String
@export var web_scene_path: String
@export var parent_override: Node

var instantiated_node: Node

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		var scene := ResourceLoader.load(web_scene_path if PlatformGlobals_Class.IsWeb() else default_scene_path, "PackedScene") as PackedScene
		instantiated_node = scene.instantiate()
		
		if parent_override:
			parent_override.add_child(instantiated_node)
		else:
			add_child(instantiated_node)
