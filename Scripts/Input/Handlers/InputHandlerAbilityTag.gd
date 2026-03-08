extends InputHandlerBase
class_name InputHandlerAbilityTag

@export_category("Ability")
@export var trigger_events: Shortcut
@export var ability_tag: StringName
@export var payload_mode: int = 0

@export_category("Triggers")
@export var activate_on_press: bool = true
@export var activate_on_hold: bool = false

@export_category("Repeats")
@export var press_repeats: int = 1
@export var repeats_reset_time: float = 0.4

func try_handle_event(in_owner: InputComponent, in_event: InputEvent) -> bool:
	
	if trigger_events.matches_event(in_event):
		
		if press_repeats > 1:
			var current_repeats := in_owner.push_repeat_for(self, repeats_reset_time)
			if current_repeats < press_repeats:
				return false
			else:
				in_owner.reset_repeat_for(self)
		
		var asc := AbilitySystemComponent.try_get_from(in_owner.get_parent())
		assert(asc)
		
		var just_pressed := in_event.is_pressed() and not in_event.is_echo()
		var holding := in_event.is_pressed() and in_event.is_echo()
		var released := in_event.is_released()
		
		if (just_pressed and activate_on_press) or (holding and activate_on_hold):
			#print("Activating %s" % ability_tag)
			asc.try_send_input_to_abilities_by_tag(ability_tag, GameplayAbility.AbilityInput.Press)
			return asc.try_activate_abilities_by_tag(ability_tag, payload_mode)
		elif released:
			return asc.try_send_input_to_abilities_by_tag(ability_tag, GameplayAbility.AbilityInput.Release)
	return false
