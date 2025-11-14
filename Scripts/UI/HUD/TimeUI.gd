@tool
extends Control
class_name TimeUI

@export_category("Components")
@export var ChallengeLabel: VHSLabel
@export var TimeLabel: VHSLabel

func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	assert(ChallengeLabel)
	assert(TimeLabel)
	
	var _game_state := WorldGlobals._game_state
	
	if not _game_state._global_timer and _game_state.ShouldCreateGlobalTimer:
		
		await _game_state.GlobalTimerCreated
		
		var _global_timer := _game_state._global_timer
		_global_timer.time_seconds_changed.connect(OnGlobalTimeSecondsChanged.bind(_global_timer))
		OnGlobalTimeSecondsChanged(_global_timer)
	else:
		TimeLabel.queue_free()
		TimeLabel = null
	
	if _game_state._game_args.get(CampaignData.challenge_time_arg, false):
		pass
	else:
		ChallengeLabel.queue_free()
		ChallengeLabel = null

func OnGlobalTimeSecondsChanged(in_global_timer: GameState_GlobalTimer) -> void:
	
	if in_global_timer.is_fractional:
		TimeLabel.label_text = UIGlobals.format_time_milliseconds(in_global_timer.time_seconds)
	else:
		TimeLabel.label_text = UIGlobals.format_time_seconds(roundi(in_global_timer.time_seconds))
