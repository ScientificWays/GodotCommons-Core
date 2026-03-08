@tool
extends Area2D
class_name InputTrigger2D

@export_category("Simpler")
@export var input_radius: float = 32.0

signal pick_event(in_event: InputEvent)

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		if input_radius > 0.0:
			set_process_input(true)
			input_pickable = false
		else:
			set_process_input(false)
			input_pickable = true

func _input(in_event: InputEvent) -> void:
	if (in_event is InputEventScreenTouch) and (in_event.is_pressed() or in_event.is_released()):
		var world_position := get_viewport().get_canvas_transform().affine_inverse() * in_event.position as Vector2
		if world_position.distance_squared_to(global_position) < (input_radius * input_radius):
			_handle_pick_input(get_viewport(), in_event)

func _handle_pick_input(in_viewport: Viewport, in_event: InputEvent) -> void:
	pick_event.emit(in_event)
	in_viewport.set_input_as_handled()
