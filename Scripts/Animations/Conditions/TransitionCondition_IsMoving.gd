extends AnimStateTransitionCondition

@export_category("Velocity")
@export var velocity_threshold: float = 4.0

func _condition() -> bool:
	var body := get_body()
	return absf(body.get_real_velocity().x) > velocity_threshold
