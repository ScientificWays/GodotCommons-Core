extends InputHandlerBase
class_name InputHandlerAbilityTag

@export_category("Ability")
@export var action_name: StringName
@export var ability_tag: StringName
@export var payload_mode: int = 0

@export_category("Triggers")
@export var activate_on_press: bool = true
@export var activate_on_hold: bool = false
@export var end_on_release: bool = true

func get_action_name() -> StringName:
	return action_name

func try_handle_event(in_owner: InputComponent, in_event: InputEvent) -> bool:
	
	if in_event.is_action(action_name):
		
		var asc := AbilitySystemComponent.try_get_from(in_owner.get_parent())
		assert(asc)
		
		var just_pressed := in_event.is_pressed() and not in_event.is_echo()
		var holding := in_event.is_pressed() and in_event.is_echo()
		var released := in_event.is_released()
		
		if (just_pressed and activate_on_press) or (holding and activate_on_hold):
			return asc.try_activate_abilities_by_tag(ability_tag, payload_mode)
		elif released and end_on_release:
			return asc.try_end_abilities_by_tag(ability_tag)
	return false
