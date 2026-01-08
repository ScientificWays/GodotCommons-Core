@tool
extends BTAction

@export var ability_tag: StringName = CommonTags.weapon_use_ability
@export var payload_var: StringName = &""

@export var wait_for_end: bool = true
@export var wait_timeout: float = 1.0

@export var end_ability_on_exit: bool = true

var wait_time_left: float = 0.0

func _enter() -> void:
	
	var agent_asc := AbilitySystemComponent.try_get_from(agent)
	assert(agent_asc)
	
	var payload := blackboard.get_var(payload_var, null, false)
	var activated := agent_asc.try_activate_abilities_by_tag(ability_tag, payload)
	
	if not activated:
		abort()
	else:
		agent_asc.ability_ended.connect(_on_agent_asc_ability_ended)
		wait_time_left = wait_timeout

func _exit() -> void:
	
	var agent_asc := AbilitySystemComponent.try_get_from(agent)
	assert(agent_asc)
	
	if agent_asc.ability_ended.is_connected(_on_agent_asc_ability_ended):
		agent_asc.ability_ended.disconnect(_on_agent_asc_ability_ended)
	
	if end_ability_on_exit:
		agent_asc.try_end_abilities_by_tag(ability_tag)

func _tick(in_delta: float) -> Status:
	
	if wait_for_end:
		if wait_time_left > in_delta:
			wait_time_left -= in_delta
			return Status.RUNNING
		else:
			return Status.SUCCESS
	else:
		return Status.RUNNING

func _on_agent_asc_ability_ended(in_ability: GameplayAbility, in_was_cancelled: bool) -> void:
	if in_ability.ability_tags.has(ability_tag):
		wait_time_left = 0.0
