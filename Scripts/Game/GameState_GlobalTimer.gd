extends Timer
class_name GameState_GlobalTimer

var time_seconds: float = 0.0:
	set(InSeconds):
		time_seconds = InSeconds
		time_seconds_changed.emit()

signal time_seconds_changed()

var is_fractional: bool = false

func _ready():
	
	if WorldGlobals._game_state._game_args.get(CampaignData.challenge_time_arg, false):
		
		is_fractional = true
		
		stop()
	else:
		is_fractional = false
		
		timeout.connect(on_timeout)
		start(1.0)

func _process(in_delta: float) -> void:
	if is_fractional:
		time_seconds += in_delta

func on_timeout():
	time_seconds += 1.0
