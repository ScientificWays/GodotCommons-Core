extends AnimStateTransitionCondition

@export_category("Velocity")
@export var velocity_threshold: Vector2 = Vector2(4.0, 4.0)
@export var velocity_mask: Vector2 = Vector2(1.0, 0.0)

func _condition() -> bool:
	
	var body := get_body()
	var abs_masked := (body.get_real_velocity() * velocity_mask).abs()
	return (abs_masked.x > velocity_threshold.x) or (abs_masked.y > velocity_threshold.y)
