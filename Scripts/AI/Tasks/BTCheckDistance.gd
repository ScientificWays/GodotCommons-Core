extends BTDecorator

@export var from_var: StringName = &""
@export var to_var: StringName = &"chase_target"
@export var check_type: LimboUtility.CheckType = LimboUtility.CheckType.CHECK_LESS_THAN_OR_EQUAL
@export var check_distance_var: StringName = &"swing_distance"
@export var check_fail_result: Status = Status.FAILURE

@export var check_cooldown_time: float = 0.2
@export var cooldown_time_status: Status = Status.RUNNING
var check_cooldown_time_left: float = 0.0

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	if check_cooldown_time > 0.0:
		
		check_cooldown_time_left -= in_delta
		if check_cooldown_time_left > 0.0:
			return cooldown_time_status
		
		check_cooldown_time_left = check_cooldown_time
	
	var from = blackboard.get_var(from_var) if blackboard.has_var(from_var) else agent
	if not is_instance_valid(from):
		abort()
		return Status.FAILURE
	
	if from is Node2D:
		from = from.global_position
	
	var to = blackboard.get_var(to_var)
	if not is_instance_valid(to):
		abort()
		return Status.FAILURE
	
	if to is Node2D:
		to = to.global_position
	
	var check_distance = blackboard.get_var(check_distance_var) as float
	var current_distance := (from as Vector2).distance_to(to)
	
	if LimboUtility.perform_check(check_type, current_distance, check_distance):
		var child_task := get_child(0)
		return child_task.execute(in_delta)
	else:
		abort()
		return check_fail_result
