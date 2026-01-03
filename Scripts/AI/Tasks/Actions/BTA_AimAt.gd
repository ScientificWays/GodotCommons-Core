@tool
extends BTAction

@export var target_var: StringName = &"chase_target"

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	var pawn_agent := agent as Pawn2D
	if not is_instance_valid(pawn_agent):
		return Status.FAILURE
	
	var target = blackboard.get_var(target_var)
	if is_instance_valid(target) and target is Node2D:
		pawn_agent.aim_at_target(target)
		return Status.RUNNING
	else:
		return Status.FAILURE
