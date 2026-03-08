extends BTDecorator
class_name BTD_CheckValid

@export var variable: StringName = &"chase_target"
@export var check_valid: bool = true

@export var check_cooldown_time: float = 1.0
var check_cooldown_time_left: float = 0.0

func get_current_result() -> bool:
	var variable_value := blackboard.get_var(variable, null, false)
	return is_instance_valid(variable_value) == check_valid

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	if check_cooldown_time > 0.0:
		
		check_cooldown_time_left -= in_delta
		if check_cooldown_time_left > 0.0:
			var child_task := get_child(0)
			return child_task.execute(in_delta)
		
		check_cooldown_time_left = check_cooldown_time
	
	#print(variable, " check ", check_type, " for ", variable_value, " and ", value, " result ", LimboUtility.perform_check(check_type, variable_value, value))
	if get_current_result():
		var child_task := get_child(0)
		return child_task.execute(in_delta)
	else:
		abort()
		return Status.FAILURE
