extends Control
class_name StartPromptUI

@export_category("Start")
@export var TargetScene: PackedScene
@export var StartLabel: VHSFX

var StartEnableTicksMs: int = 0
var StartWasTriggered: bool = false

func _ready() -> void:
	
	assert(TargetScene)
	
	StartEnableTicksMs = Time.get_ticks_msec() + 1500
	
	StartLabel.SetInstantLerpVisible(false)
	GameGlobals.SpawnOneShotTimerFor(self, ShowStartLabel, 1.0)

func _input(InEvent: InputEvent) -> void:
	
	if Time.get_ticks_msec() > StartEnableTicksMs:
		if InEvent.is_pressed() and not InEvent.is_echo():
			TriggerStart()

func ShowStartLabel() -> void:
	
	StartLabel.lerp_visible = true
	
	if YandexSDK.is_working():
		YandexSDK.game_ready()
	

func TriggerStart() -> void:
	
	assert(not StartWasTriggered)
	
	set_process_input(false)
	StartLabel.lerp_visible = false
	
	GameGlobals.SpawnOneShotTimerFor(self, HandleStartPostDelay, 1.0)

func HandleStartPostDelay() -> void:
	WorldGlobals.LoadSceneByPacked(TargetScene)
