extends CanvasLayer
class_name HUDUI

@export_category("Owner")
@export var OwnerPlayerController: PlayerController

@export_category("Components")
@export var TransitionBackground: BackgroundUI

func _ready() -> void:
	
	assert(OwnerPlayerController)
	
	WorldGlobals.TransitionBegin.connect(OnWorldTransitionBegin)
	TransitionBackground.FadeOut()

func OnWorldTransitionBegin(InTransitionArea: LevelTransitionArea2D) -> void:
	TransitionBackground.FadeIn(InTransitionArea.TransitionDelay)
