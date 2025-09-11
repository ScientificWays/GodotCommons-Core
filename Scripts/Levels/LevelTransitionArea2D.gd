extends Area2D
class_name LevelTransitionArea2D

@export_category("Transition")
@export var TransitionScene: PackedScene
@export var TransitionDelay: float = 1.0

var TransitionBegan: bool = false

func _ready() -> void:
	area_entered.connect(OnTargetEntered)
	body_entered.connect(OnTargetEntered)

func OnTargetEntered(InTarget: Node2D):
	BeginTransition.call_deferred()

func BeginTransition():
	
	assert(not TransitionBegan)
	
	TransitionBegan = true
	monitoring = false
	
	WorldGlobals.TransitionBegin.emit(self)
	GameGlobals.SpawnOneShotTimerFor(self, FinishTranstiion, TransitionDelay)

func FinishTranstiion() -> void:
	
	WorldGlobals.PreTransitionFinished.emit(self)
	get_tree().change_scene_to_packed(TransitionScene)
