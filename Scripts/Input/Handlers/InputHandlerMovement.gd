extends InputHandlerBase
class_name InputHandlerMovement

@export_category("Movement")
@export var input_actions: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down"
]
@export var block_input_tags: Array[StringName] = [
	CommonTags.input_block_movement
]

func get_action_name() -> StringName:
	return &""

func try_handle_process(in_input_component: InputComponent, in_delta: float) -> bool:
	
	var owner_pawn := in_input_component.get_parent() as Pawn2D
	assert(owner_pawn)
	
	var movement_input = Vector2.ZERO
	if not owner_pawn.asc.tags_container.has_any_tag(block_input_tags):
		movement_input = Input.get_vector(input_actions[0], input_actions[1], input_actions[2], input_actions[3])
	
	owner_pawn.character_movement.apply_movement_input(movement_input)
	return false
