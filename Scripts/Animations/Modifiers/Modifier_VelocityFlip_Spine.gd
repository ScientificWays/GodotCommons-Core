extends AnimStateModifier
class_name AnimStateModifier_VelocityFlip_Spine

@export_category("Flip")
@export var flip_threshold: float = 4.0
@export var flip_reverse: bool = false

func _enter_state(in_state: AnimState) -> void:
	pass

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	
	var body := in_state.get_body()
	var real_velocity := body.get_real_velocity()
	
	if absf(real_velocity.x) < flip_threshold:
		pass
	else:
		var spine := in_state.get_animated_target() as SpineSprite
		var sign := -1.0 if ((real_velocity.x <= flip_threshold) != flip_reverse) else 1.0
		
		spine.scale.x = absf(spine.scale.x) * sign
		assert(spine.scale.x != 0.0)
