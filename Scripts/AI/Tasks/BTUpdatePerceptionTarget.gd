@tool
extends BTDecorator

@export var out_target_var: StringName = &"chase_target"
@export var update_cooldown_time: float = 1.0

var owner_perception: Pawn2D_Perception
var update_cooldown_time_left: float = 0.0

func _enter() -> void:
	owner_perception = Pawn2D_Perception.try_get_from(agent)

func _exit() -> void:
	owner_perception = null

func _tick(in_delta: float) -> Status:
	
	var child_task := get_child(0)
	var child_status := child_task.execute(in_delta)
	
	assert(owner_perception)
	
	update_cooldown_time_left -= in_delta
	
	if update_cooldown_time_left > 0.0:
		return Status.RUNNING
	
	update_cooldown_time_left = update_cooldown_time
	
	var relevant_target := owner_perception.get_relevant_sight_target()
	blackboard.set_var(out_target_var, relevant_target)
	return Status.RUNNING
