@tool
extends BTAction

@export var ability_tag: StringName = CommonTags.weapon_use_ability
@export var payload_var: StringName = &""

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	var agent_asc := AbilitySystemComponent.try_get_from(agent)
	assert(agent_asc)
	
	var payload := blackboard.get_var(payload_var, null, false)
	if agent_asc.try_activate_abilities_by_tag(ability_tag, payload):
		return Status.SUCCESS
	else:
		return Status.FAILURE
