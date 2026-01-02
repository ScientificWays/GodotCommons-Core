extends Node
class_name AnimStateTransitionCondition

@export_category("State")
@export var go_to_state: AnimState

@export_category("Condition")
@export var inverse_condition: bool = false

var owner_state: AnimState

func _ready() -> void:
	owner_state = get_parent()

func get_sprite() -> AnimatedSprite2D:
	return owner_state.get_sprite()

func get_body() -> CharacterBody2D:
	return owner_state.get_body()

func get_tags_container() -> TagsContainer:
	return owner_state.get_tags_container()

func check_condition() -> bool:
	return _condition() != inverse_condition

## Not abstract to allow set this class as base class for nodes
func _condition() -> bool:
	assert(false, "AnimStateTransitionCondition's check_condition() was not implemented!")
	return false
