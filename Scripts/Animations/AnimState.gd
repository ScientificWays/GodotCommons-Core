extends Node
class_name AnimState

@export_category("Modifiers")
@export var modifiers: Array[AnimStateModifier]

var owner_state_machine: AnimStateMachine
var self_index: int = -1

func _ready() -> void:
	owner_state_machine = get_parent()

func get_next_state() -> AnimState:
	for sample_condition: AnimStateTransitionCondition in get_children():
		if sample_condition.check_condition():
			return sample_condition.go_to_state
	return self

func get_animated_target() -> Node2D:
	return owner_state_machine.owner_animated_target

func get_body() -> CharacterBody2D:
	return owner_state_machine.owner_body

func get_pawn() -> Pawn2D:
	return owner_state_machine.owner_body as Node

func get_tags_container() -> TagsContainer:
	return owner_state_machine.owner_tags_container

## Not abstract to allow set this class as base class for nodes
func enter_state() -> void:
	for sample_modifier: AnimStateModifier in modifiers:
		if not sample_modifier.disabled:
			sample_modifier._enter_state(self)

func exit_state() -> void:
	for sample_modifier: AnimStateModifier in modifiers:
		if not sample_modifier.disabled:
			sample_modifier._exit_state(self)

func tick_state(in_delta: float) -> void:
	for sample_modifier: AnimStateModifier in modifiers:
		if not sample_modifier.disabled:
			sample_modifier._tick_state(self, in_delta)
