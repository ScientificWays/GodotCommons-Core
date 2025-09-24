extends Control
class_name StartPromptUI

@export_category("Start")
@export var StartLabel: VHSLabel
@export var MusicLabel: VHSLabel

var StartEnableTicksMs: int = 0
var StartWasTriggered: bool = false

signal StartTrigger()

func _ready() -> void:
	
	StartEnableTicksMs = Time.get_ticks_msec() + 1000
	
	MusicLabel.SetInstantLerpVisible(false)
	GameGlobals.SpawnOneShotTimerFor(self, ShowMusicLabel, 0.5)
	
	StartLabel.SetInstantLerpVisible(false)
	GameGlobals.SpawnOneShotTimerFor(self, ShowStartLabel, 1.0)

func _input(InEvent: InputEvent) -> void:
	
	if Time.get_ticks_msec() < StartEnableTicksMs:
		return
	
	if InEvent.is_echo():
		return
	
	if GameGlobals.IsPC():
		if InEvent.is_action_pressed(&"Continue"):
			pass
		else:
			return
	elif InEvent is InputEventScreenTouch:
		pass
	else:
		return
	
	TriggerStart()

func UpdateAsStart() -> void:
	
	StartLabel.label_text = "START_PROMPT"
	StartLabel.label_text_mobile = "START_PROMPT_MOBILE"
	
	MusicLabel.visible = true

func UpdateAsContinue() -> void:
	
	StartLabel.label_text = "CONTINUE_PROMPT"
	StartLabel.label_text_mobile = "CONTINUE_PROMPT"
	
	MusicLabel.visible = false

func ShowMusicLabel() -> void:
	
	MusicLabel.label_text = AudioGlobals.GetCurrentMusicName()
	MusicLabel.lerp_visible = true

func ShowStartLabel() -> void:
	
	StartLabel.lerp_visible = true
	
	if YandexSDK.is_working():
		YandexSDK.game_ready()
	

func TriggerStart() -> void:
	
	assert(not StartWasTriggered)
	
	set_process_input(false)
	StartLabel.lerp_visible = false
	
	MusicLabel.lerp_visible_speed *= 2.0
	MusicLabel.lerp_visible = false
	
	StartTrigger.emit()
