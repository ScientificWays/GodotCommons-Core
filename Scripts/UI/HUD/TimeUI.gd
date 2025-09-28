@tool
extends Control
class_name TimeUI

@export_category("Components")
@export var TimeLabel: VHSLabel
#@export var ScoreLabel: VHSLabel

func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	assert(TimeLabel)
	#assert(ScoreLabel)
	
	var _game_state := WorldGlobals._game_state as MainGameState
	#_game_state.PlayerScoreChanged.connect(OnPlayerScoreChanged.bind(_game_state))
	#OnPlayerScoreChanged(_game_state)
	
	if not _game_state._GlobalTimer and _game_state.ShouldCreateGlobalTimer:
		
		await _game_state.GlobalTimerCreated
		
		var _GlobalTimer := _game_state._GlobalTimer
		_GlobalTimer.TimeSecondsChanged.connect(OnGlobalTimeSecondsChanged.bind(_GlobalTimer))
		OnGlobalTimeSecondsChanged(_GlobalTimer)
	else:
		TimeLabel.queue_free()

func OnGlobalTimeSecondsChanged(InGlobalTimer: GameState_GlobalTimer) -> void:
	TimeLabel.label_text = UIGlobals.FormatTimeString(InGlobalTimer.TimeSeconds)

#func OnPlayerScoreChanged(InGameState: MainGameState) -> void:
#	ScoreLabel.label_text = String.num_int64(InGameState.PlayerScore)
