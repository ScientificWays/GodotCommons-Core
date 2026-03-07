extends AnimStateModifier
class_name AnimStateModifier_SetSkeletonData

@export_category("Animation")
@export var skeleton_data: SpineSkeletonDataResource

func _enter_state(in_state: AnimState) -> void:
	var spine := in_state.get_animated_target() as SpineSprite
	spine.skeleton_data_res = skeleton_data

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	pass
