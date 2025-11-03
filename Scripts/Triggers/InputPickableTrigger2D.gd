@tool
extends Area2D
class_name InputPickableTrigger2D

@export_category("Simpler")
@export var override_radius: float = -1.0

signal pick_event(in_event: InputEvent)

func _ready() -> void:
	
	if Engine.is_editor_hint():
		pass
	else:
		if override_radius > 0.0:
			set_process_input(true)
			input_pickable = false
		else:
			set_process_input(false)
			input_pickable = true

func _input(in_event: InputEvent) -> void:
	if (in_event is InputEventScreenTouch) and (in_event.is_pressed() or in_event.is_released()):
		var world_position := get_viewport().get_canvas_transform().affine_inverse() * in_event.position as Vector2
		if world_position.distance_squared_to(global_position) < (override_radius * override_radius):
			_handle_pick_input(get_viewport(), in_event)

func _input_event(in_viewport: Viewport, in_event: InputEvent, in_shape_idx: int) -> void:
	if (in_event is InputEventScreenTouch) and (in_event.is_pressed() or in_event.is_released()):
		_handle_pick_input(in_viewport, in_event)

func _handle_pick_input(in_viewport: Viewport, in_event: InputEvent) -> void:
	pick_event.emit(in_event)
	in_viewport.set_input_as_handled()
