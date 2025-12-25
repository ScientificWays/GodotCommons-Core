@tool
extends BTAction

@export var move_target_var: StringName = &"patrol_position"
@export var override_desired_distance: float = -1.0

var owner_navigation: Pawn2D_Navigation
var prev_desired_distance: float = -1.0

func _enter() -> void:
	
	owner_navigation = Pawn2D_Navigation.try_get_from(agent)
	
	var move_target = blackboard.get_var(move_target_var)
	if move_target is Node2D:
		owner_navigation.target_node = move_target
	elif move_target is Vector2:
		owner_navigation.target_position = move_target
	else:
		assert(false)
	
	if override_desired_distance >= 0.0:
		prev_desired_distance = owner_navigation.target_desired_distance
		owner_navigation.target_desired_distance = override_desired_distance

func _exit() -> void:
	
	if prev_desired_distance >= 0.0:
		owner_navigation.target_desired_distance = prev_desired_distance
	
	owner_navigation.target_node = null
	owner_navigation = null

func _tick(in_delta: float) -> Status:
	
	if owner_navigation.is_navigation_finished():
		return Status.SUCCESS
	elif owner_navigation.is_target_reachable():
		return Status.RUNNING
	else:
		return Status.FAILURE
