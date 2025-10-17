@tool
extends BTAction

@export var move_target_var: StringName = &"patrol_position"

var owner_navigation: Pawn2D_Navigation

func _enter() -> void:
	
	owner_navigation = Pawn2D_Navigation.try_get_from(agent)
	
	var move_target = blackboard.get_var(move_target_var)
	if move_target is Node2D:
		owner_navigation.target_node = move_target
	elif move_target is Vector2:
		owner_navigation.target_position = move_target
	else:
		assert(false)

func _exit() -> void:
	owner_navigation.target_node = null
	owner_navigation = null

func _tick(in_delta: float) -> Status:
	
	if owner_navigation.is_navigation_finished():
		return Status.SUCCESS
	elif owner_navigation.is_target_reachable():
		return Status.RUNNING
	else:
		return Status.FAILURE
