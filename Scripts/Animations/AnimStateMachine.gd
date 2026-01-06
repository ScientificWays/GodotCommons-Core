extends Node
class_name AnimStateMachine

@export var owner_sprite: AnimatedSprite2D
@export var owner_body: CharacterBody2D
@export var owner_tags_container: TagsContainer

var current_state: AnimState

func _ready() -> void:
	
	assert(owner_sprite)
	assert(owner_body)
	assert(owner_tags_container)
	
	current_state = get_child(0)

func _process(in_delta: float) -> void:
	
	if is_playing_override_animation:
		pass
	else:
		current_state = current_state.get_next_state()
		current_state.process_state(in_delta)

func stop_for_duration(in_duration: float) -> void:
	
	if in_duration > 0.0:
		set_process(false)
		GameGlobals.spawn_one_shot_timer_for(self, resume_from_stop, in_duration)
	else:
		push_warning(self, " stop_for_duration() was called with non-positive duration! (", in_duration, ")")

func resume_from_stop() -> void:
	set_process(true)

@export_category("Override Animations")
var is_playing_override_animation: bool = false

func play_override_animation(in_name: StringName, in_custom_speed: float = 1.0, in_from_end: bool = false, in_should_reset_on_finish: bool = true) -> void:
	
	assert(owner_sprite.sprite_frames.has_animation(in_name))
	
	is_playing_override_animation = true
	owner_sprite.play(in_name, in_custom_speed, in_from_end)
	
	if in_should_reset_on_finish:
		if not owner_sprite.animation_finished.is_connected(_handle_override_animation_reset):
			owner_sprite.animation_finished.connect(_handle_override_animation_reset, Object.CONNECT_ONE_SHOT)
	else:
		if owner_sprite.animation_finished.is_connected(_handle_override_animation_reset):
			owner_sprite.animation_finished.disconnect(_handle_override_animation_reset)

func cancel_override_animation(in_specific_animation_name: StringName = &""):
	
	assert(in_specific_animation_name.is_empty() or owner_sprite.sprite_frames.has_animation(in_specific_animation_name))
	
	if owner_sprite.animation == in_specific_animation_name or is_playing_override_animation:
		
		owner_sprite.stop()
		
		if owner_sprite.animation_finished.is_connected(_handle_override_animation_reset):
			owner_sprite.animation_finished.disconnect(_handle_override_animation_reset)
			_handle_override_animation_reset()

func _handle_override_animation_reset():
	is_playing_override_animation = false
