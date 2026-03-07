extends Node
class_name AnimStateMachine

@export var owner_body: CharacterBody2D
@export var owner_tags_container: TagsContainer

@export var owner_animated_target: Node2D
@export var montage_player: AnimMontagePlayer

var current_state: AnimState:
	set(in_state):
		if in_state != current_state:
			if current_state:
				current_state.exit_state()
			current_state = in_state
			if current_state:
				current_state.enter_state()

func _ready() -> void:
	
	assert(owner_body)
	assert(owner_tags_container)
	
	assert(owner_animated_target)
	assert(montage_player)
	
	init_state.call_deferred()

func init_state() -> void:
	
	for sample_child: Node in get_children():
		if sample_child is AnimState:
			current_state = sample_child
			break

func _process(in_delta: float) -> void:
	
	if montage_player.is_playing_montage:
		pass
	else:
		current_state = current_state.get_next_state()
		current_state.tick_state(in_delta)

func play_montage(in_name: StringName, in_custom_speed: float = 1.0, in_from_end: bool = false, in_should_reset_on_finish: bool = true) -> void:
	montage_player.play_montage(in_name, in_custom_speed, in_from_end, in_should_reset_on_finish)

func cancel_montage(in_specific_animation_name: StringName = &"") -> void:
	montage_player.cancel_montage(in_specific_animation_name)

func stop_for_duration(in_duration: float) -> void:
	
	if in_duration > 0.0:
		set_process(false)
		GameGlobals.spawn_one_shot_timer_for(self, resume_from_stop, in_duration)
	else:
		push_warning(self, " stop_for_duration() was called with non-positive duration! (", in_duration, ")")

func resume_from_stop() -> void:
	set_process(true)
