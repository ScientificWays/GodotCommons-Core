extends AnimStateModifier
class_name AnimStateModifier_PlayAnimationUpDown

@export_category("Animations")
@export var animation_forward_name: StringName = &"idle"
@export var animation_up_name: StringName = &"idle_up"
@export var animation_down_name: StringName = &"idle_down"

func _enter_state(in_state: AnimState) -> void:
	pass

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	
	var pawn := in_state.get_pawn()
	var sprite := in_state.get_animated_target() as AnimatedSprite2D
	
	if pawn.aim_direction.y < 0.0:
		sprite.play(animation_up_name)
	elif pawn.aim_direction.y > 0.0:
		sprite.play(animation_down_name)
	else:
		sprite.play(animation_forward_name)
