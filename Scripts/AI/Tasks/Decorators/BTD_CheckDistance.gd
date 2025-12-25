extends BTDecorator

enum DistanceType
{
	X_Y = 0,
	X = 1,
	Y = 2,
}

@export var from_var: StringName = &""
@export var to_var: StringName = &"chase_target"
@export var check_type: LimboUtility.CheckType = LimboUtility.CheckType.CHECK_LESS_THAN_OR_EQUAL
@export var check_distance_var: StringName = &"swing_distance"
@export var check_distance_type: DistanceType = DistanceType.X_Y
@export var check_fail_result: Status = Status.FAILURE

@export var check_cooldown_time: float = 0.2
@export var cooldown_time_status: Status = Status.RUNNING
var check_cooldown_time_left: float = 0.0

var prev_check_result: bool = false

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(in_delta: float) -> Status:
	
	if check_cooldown_time > 0.0:
		
		check_cooldown_time_left -= in_delta
		if check_cooldown_time_left > 0.0:
			if prev_check_result:
				var child_task := get_child(0)
				return child_task.execute(in_delta)
			else:
				return check_fail_result
		
		check_cooldown_time_left = check_cooldown_time
	
	var from = blackboard.get_var(from_var) if blackboard.has_var(from_var) else agent
	if from == null:
		abort()
		return Status.FAILURE
	
	if from is Node2D:
		from = from.global_position
	
	var to = blackboard.get_var(to_var)
	if to == null:
		abort()
		return Status.FAILURE
	
	if to is Node2D:
		to = to.global_position
	
	var current_distance_squared := get_distance_squared(from, to)
	var check_distance = blackboard.get_var(check_distance_var) as float
	
	if LimboUtility.perform_check(check_type, current_distance_squared, check_distance * check_distance):
		prev_check_result = true
		var child_task := get_child(0)
		return child_task.execute(in_delta)
	else:
		prev_check_result = false
		abort()
		return check_fail_result

func get_distance_squared(from: Vector2, to: Vector2) -> float:
	
	match check_distance_type:
		DistanceType.X_Y:
			return from.distance_squared_to(to)
		DistanceType.X:
			var distance_x := absf(from.x - to.x)
			return distance_x * distance_x
		DistanceType.Y:
			var distance_y := absf(from.y - to.y)
			return distance_y * distance_y
	assert(false)
	return -1.0
