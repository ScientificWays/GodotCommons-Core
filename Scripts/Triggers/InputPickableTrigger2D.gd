@tool
extends Area2D
class_name InputPickableTrigger2D

func _ready() -> void:
	
	input_pickable = true
	

func _input_event(in_viewport: Viewport, in_event: InputEvent, in_shape_index: int) -> void:
	pass
