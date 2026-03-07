extends AnimStateModifier
class_name AnimStateModifier_VelocityFlip_Sprite

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
		var pawn := in_state.get_pawn()
		var sprite := in_state.get_animated_target() as AnimatedSprite2D
		sprite.flip_h = ((real_velocity.x <= flip_threshold) != flip_reverse)
