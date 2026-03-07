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
	CommonTags.block_input_movement
]

func get_action_name() -> StringName:
	return &""

func try_handle_process(in_input_component: InputComponent, in_delta: float) -> bool:
	
	var owner := in_input_component.get_parent()
	
	var asc := AbilitySystemComponent.try_get_from(owner)
	assert(asc)
	
	var movement_component := Pawn2D_CharacterMovement.try_get_from(owner)
	assert(movement_component)
	
	var movement_input = Vector2.ZERO
	
	if not asc.tags_container.has_any_tag(block_input_tags):
		movement_input = Input.get_vector(input_actions[0], input_actions[1], input_actions[2], input_actions[3])
	
	movement_component.apply_movement_input(movement_input)
	return false
