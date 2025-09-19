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
	
	var _GameState := WorldGlobals._GameState as MainGameState
	#_GameState.PlayerScoreChanged.connect(OnPlayerScoreChanged.bind(_GameState))
	#OnPlayerScoreChanged(_GameState)
	
	if not _GameState._GlobalTimer and _GameState.ShouldCreateGlobalTimer:
		
		await _GameState.GlobalTimerCreated
		
		var _GlobalTimer := _GameState._GlobalTimer
		_GlobalTimer.TimeSecondsChanged.connect(OnGlobalTimeSecondsChanged.bind(_GlobalTimer))
		OnGlobalTimeSecondsChanged(_GlobalTimer)
	else:
		TimeLabel.queue_free()

func OnGlobalTimeSecondsChanged(InGlobalTimer: GameState_GlobalTimer) -> void:
	TimeLabel.label_text = UIGlobals.FormatTimeString(InGlobalTimer.TimeSeconds)

#func OnPlayerScoreChanged(InGameState: MainGameState) -> void:
#	ScoreLabel.label_text = String.num_int64(InGameState.PlayerScore)
