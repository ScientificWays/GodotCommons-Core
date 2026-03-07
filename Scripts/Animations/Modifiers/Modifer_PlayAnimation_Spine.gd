extends AnimStateModifier
class_name AnimStateModifier_PlayAnimation_Spine

@export_category("Animation")
@export var animation_name: StringName
@export var track_id: int = 0
@export var mix_duration: float = 0.2

func _enter_state(in_state: AnimState) -> void:
	
	var spine := in_state.get_animated_target() as SpineSprite
	var animation_state := spine.get_animation_state()
	animation_state.enable_queue()
	var track_entry := animation_state.set_animation(animation_name, true, track_id)
	#assert(track_entry.was_applied())
	track_entry.set_mix_duration(mix_duration)

func _exit_state(in_state: AnimState) -> void:
	pass

func _tick_state(in_state: AnimState, in_delta: float) -> void:
	pass
