@tool
extends BTAction

@export var target_var: StringName = &"patrol_position"

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	var owner_navigation := Pawn2D_Navigation.try_get_from(agent)
	
	var target = blackboard.get_var(target_var)
	if target is Node2D:
		owner_navigation.target_node = target
		return Status.SUCCESS
	elif target is Vector2:
		owner_navigation.target_position = target
		return Status.SUCCESS
	else:
		return Status.FAILURE
