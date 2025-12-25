@tool
extends BTAction

@export var in_center_var: StringName = &""
@export var in_radius_var: StringName = &"patrol_radius"

@export var out_position_var: StringName = &"patrol_position"

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	var center = blackboard.get_var(in_center_var) if blackboard.has_var(in_center_var) else agent
	if center is Node2D:
		center = center.global_position
	
	var radius := blackboard.get_var(in_radius_var) as float
	
	var random_nav_pos := WorldGlobals._level.get_random_nav_pos_in_radius(center, radius)
	if random_nav_pos == Vector2.INF:
		return Status.FAILURE
	
	blackboard.set_var(out_position_var, random_nav_pos)
	return Status.SUCCESS
