extends Timer
class_name GameState_GlobalTimer

var TimeSeconds: int = 0:
	set(InSeconds):
		TimeSeconds = InSeconds
		TimeSecondsChanged.emit()

signal TimeSecondsChanged()

func _ready():
	
	#if is_instance_valid(SaveGlobals._RunSaveData):
	#	TimeSeconds = SaveGlobals._RunSaveData.GetGlobalTimeSeconds()
	
	timeout.connect(OnTimeout)
	start(1.0)

func OnTimeout():
	TimeSeconds += 1
