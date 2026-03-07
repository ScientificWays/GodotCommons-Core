@abstract
extends Resource
class_name InputHandlerBase

@export_category("Input")
@export var consume_on_handled: bool = false

@abstract func get_action_name() -> StringName

func try_handle_event(in_owner: InputComponent, in_event: InputEvent) -> bool:
	return false

func try_handle_process(in_owner: InputComponent, in_delta: float) -> bool:
	return false
