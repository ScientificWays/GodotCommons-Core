extends AnimStateModifier
class_name AnimStateModifier_PlayAnimation_Sprite

@export_category("Animation")
@export var animation_name: StringName

func _enter_state(in_state: AnimState) -> void:
	var sprite := in_state.get_animated_target() as AnimatedSprite2D
	sprite.play(animation_name)

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	pass
