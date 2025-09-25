extends CanvasLayer
class_name HUDUI

@export_category("Owner")
@export var OwnerPlayerController: PlayerController

@export_category("Transition")
@export var TransitionBackground: BackgroundUI

@export_category("Pause")
@export var pause_button: Button

func _ready() -> void:
	
	assert(OwnerPlayerController)
	assert(TransitionBackground)
	assert(pause_button)
	
	WorldGlobals.TransitionAreaEnterBegin.connect(OnWorldTransitionAreaEnterBegin)
	TransitionBackground.FadeOut()
	
	pause_button.pressed.connect(on_pause_button_pressed)

func OnWorldTransitionAreaEnterBegin(InTransitionArea: LevelTransitionArea2D) -> void:
	TransitionBackground.FadeIn(InTransitionArea.TransitionDelay)

func on_pause_button_pressed() -> void:
	UIGlobals.pause_menu_ui.toggle()
