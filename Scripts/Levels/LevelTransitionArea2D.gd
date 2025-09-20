extends Area2D
class_name LevelTransitionArea2D

@export_category("Transition")
@export var TransitionScenePath: String
@export var TransitionDelay: float = 1.0
@export var OverrideBackgroundGradient: GradientTexture1D

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
	
	if is_instance_valid(OverrideBackgroundGradient):
		UIGlobals.BackgroundTextureOverride = OverrideBackgroundGradient
	
	WorldGlobals.TransitionAreaEnterBegin.emit(self)
	GameGlobals.SpawnOneShotTimerFor(self, FinishTranstiion, TransitionDelay)

func FinishTranstiion() -> void:
	
	WorldGlobals.TransitionAreaEnterFinished.emit(self)
	TransitionLevel2D.LoadWithTransition(TransitionScenePath)
