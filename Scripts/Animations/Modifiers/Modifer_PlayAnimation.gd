extends AnimStateModifier
class_name AnimStateModifier_PlayAnimation

@export_category("Animation")
@export var animation_name: StringName

func _modify(in_state: AnimState, in_delta: float) -> void:
	var sprite := in_state.get_sprite()
	sprite.play(animation_name)
