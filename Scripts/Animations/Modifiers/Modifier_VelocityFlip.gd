extends AnimStateModifier
class_name AnimStateModifier_VelocityFlip

@export_category("Flip")
@export var flip_threshold: float = 4.0
@export var flip_reverse: bool = false

func _modify(in_state: AnimState, in_delta: float) -> void:
	
	var body := in_state.get_body()
	var real_velocity := body.get_real_velocity()
	
	if absf(real_velocity.x) < flip_threshold:
		pass
	else:
		var sprite := in_state.get_sprite()
		sprite.flip_h = ((real_velocity.x <= flip_threshold) != flip_reverse)
