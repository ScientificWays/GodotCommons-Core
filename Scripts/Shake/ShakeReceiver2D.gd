@tool
extends Area2D
class_name ShakeReceiver2D

@export var _camera: PlayerCamera2D

func _ready() -> void:
	
	if Engine.is_editor_hint():
		if not _camera:
			_camera = find_parent("*amera*")
