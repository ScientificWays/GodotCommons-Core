extends AnimStateModifier
class_name AnimStateModifier_PlayAnimation_Spine

@export_category("Animation")
@export var animation_name: StringName
@export var track_id: int = 0

func _enter_state(in_state: AnimState) -> void:
	
	var spine := in_state.get_animated_target() as SpineSprite
	var animation_state := spine.get_animation_state()
	
	var track_entry := animation_state.set_animation(animation_name, true, track_id)
	#assert(track_entry.was_applied())

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	pass
