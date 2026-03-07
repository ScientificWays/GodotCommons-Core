extends AnimMontagePlayer
class_name AnimMontagePlayer_Sprite

@export var sprite: AnimatedSprite2D

func _ready() -> void:
	assert(sprite)

func play_montage(in_name: StringName, in_custom_speed: float = 1.0, in_from_end: bool = false, in_should_reset_on_finish: bool = true) -> void:
	
	assert(sprite.sprite_frames.has_animation(in_name))
	
	is_playing_montage = true
	sprite.play(in_name, in_custom_speed, in_from_end)
	
	if in_should_reset_on_finish:
		if not sprite.animation_finished.is_connected(_handle_montage_reset):
			sprite.animation_finished.connect(_handle_montage_reset, Object.CONNECT_ONE_SHOT)
	else:
		if sprite.animation_finished.is_connected(_handle_montage_reset):
			sprite.animation_finished.disconnect(_handle_montage_reset)

func cancel_montage(in_specific_animation_name: StringName = &"") -> void:
	
	assert(in_specific_animation_name.is_empty() or sprite.sprite_frames.has_animation(in_specific_animation_name))
	
	if sprite.animation == in_specific_animation_name or is_playing_montage:
		
		sprite.stop()
		
		if sprite.animation_finished.is_connected(_handle_montage_reset):
			sprite.animation_finished.disconnect(_handle_montage_reset)
			_handle_montage_reset()
