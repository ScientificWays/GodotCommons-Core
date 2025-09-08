extends Area2D
class_name LevelTransitionArea2D

@export var TransitionScene: PackedScene

func _ready() -> void:
	area_entered.connect(OnTargetEntered)
	body_entered.connect(OnTargetEntered)

func OnTargetEntered(InTarget: Node2D):
	TriggerTransition.call_deferred()

func TriggerTransition():
	get_tree().change_scene_to_packed(TransitionScene)
