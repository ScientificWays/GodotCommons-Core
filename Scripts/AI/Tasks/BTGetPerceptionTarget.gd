@tool
extends BTAction

@export var out_target_var: StringName = &"chase_target"

var owner_perception: Pawn2D_Perception

func _enter() -> void:
	owner_perception = Pawn2D_Perception.try_get_from(agent)

func _exit() -> void:
	owner_perception = null

func _tick(in_delta: float) -> Status:
	
	if not is_instance_valid(owner_perception):
		return Status.FAILURE
	
	var relevant_target := owner_perception.get_relevant_sight_target()
	
	if not is_instance_valid(relevant_target):
		return Status.FAILURE
	
	blackboard.set_var(out_target_var, relevant_target)
	return Status.SUCCESS
