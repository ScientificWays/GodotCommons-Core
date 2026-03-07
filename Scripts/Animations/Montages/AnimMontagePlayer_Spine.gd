extends AnimMontagePlayer
class_name AnimMontagePlayer_Spine

@export var spine: SpineSprite
@export var track_id: int = 0

func _ready() -> void:
	assert(spine)

func play_montage(in_name: StringName, in_custom_speed: float = 1.0, in_from_end: bool = false, in_should_reset_on_finish: bool = true) -> void:
	
	var animation_state := spine.get_animation_state()
	var track_entry := animation_state.set_animation(in_name, false, track_id)
	
	assert(track_entry.was_applied())
	track_entry.set_time_scale(in_custom_speed)
	
	is_playing_montage = true
	
	#spine.play(in_name, in_custom_speed, in_from_end)
	
	if in_should_reset_on_finish:
		if not spine.animation_completed.is_connected(_handle_montage_reset):
			spine.animation_completed.connect(_handle_montage_reset, Object.CONNECT_ONE_SHOT)
	else:
		if spine.animation_completed.is_connected(_handle_montage_reset):
			spine.animation_completed.disconnect(_handle_montage_reset)

func cancel_montage(in_specific_animation_name: StringName = &"") -> void:
	
	assert(in_specific_animation_name.is_empty() or spine.sprite_frames.has_animation(in_specific_animation_name))
	
	var animation_state := spine.get_animation_state()
	var track_entry := animation_state.get_current(track_id)
	var current_animation := track_entry.get_animation()
	
	if (current_animation and current_animation.get_name() == in_specific_animation_name) or is_playing_montage:
		
		animation_state.set_empty_animation(track_id, 0.2)
		
		if spine.animation_completed.is_connected(_handle_montage_reset):
			spine.animation_completed.disconnect(_handle_montage_reset)
			_handle_montage_reset()
