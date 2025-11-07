extends Node
class_name ChangeLevel

@export_category("Level")
@export var level_scene_path: String
@export var mark_current_level_completed: bool = true

@export_category("Transition")
@export var transtioin_delay: float = 1.0
@export var transtioin_override_background_gradient: GradientTexture1D

var is_transitioning: bool = false

func _ready() -> void:
	pass

func trigger_transition():
	
	assert(not is_transitioning)
	
	is_transitioning = true
	
	if is_instance_valid(transtioin_override_background_gradient):
		UIGlobals.BackgroundTextureOverride = transtioin_override_background_gradient
	
	WorldGlobals.change_level_transition_begin.emit(self)
	GameGlobals.spawn_one_shot_timer_for(self, change_level_immediately, transtioin_delay)

func change_level_immediately() -> void:
	
	if mark_current_level_completed:
		WorldGlobals._level.was_completed = true
	
	if is_transitioning:
		is_transitioning = false
		WorldGlobals.change_level_transition_finished.emit(self)
	
	TransitionLevel2D.LoadWithTransition(level_scene_path)
