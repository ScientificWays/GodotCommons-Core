extends Area2D
class_name FallTriggerArea2D

const IsFallingMeta: StringName = &"FallTriggerArea2D_IsFalling"

@export var FallAP: AnimationPlayer

signal FallSequenceBegin(InTarget: Node2D)
signal FallSequenceFinished(InTarget: Node2D)

func _ready() -> void:
	area_entered.connect(OnTargetEntered)
	body_entered.connect(OnTargetEntered)

func OnTargetEntered(InTarget: Node2D) -> void:
	TryTriggerTargetFall(InTarget)

func TryTriggerTargetFall(InTarget: Node2D) -> bool:
	
	assert(InTarget)
	
	if InTarget.get_meta(IsFallingMeta, false):
		return false
	
	if CurrentTarget != null:
		await FallSequenceFinished
	
	CurrentTarget = InTarget
	
	FallSequenceBegin.emit(InTarget)
	
	var TargetAP := FallTriggerTile_TargetAP.TryGetFrom(CurrentTarget)
	if TargetAP:
		TargetAP.TriggerFall(self)
	FallAP.play(&"Fall")
	return true

var CurrentTarget: Node2D:
	set(InTarget):
		
		if CurrentTarget:
			CurrentTarget.remove_meta(IsFallingMeta)
			CurrentTarget.tree_exited.disconnect(OnCurrentTargetTreeExited)
		
		CurrentTarget = InTarget
		
		if CurrentTarget:
			CurrentTarget.set_meta(IsFallingMeta, true)
			CurrentTarget.tree_exited.connect(OnCurrentTargetTreeExited)

func OnCurrentTargetTreeExited():
	FallAP.stop()

@export var TargetFallAlpha: float = 0.0:
	set(InAlpha):
		TargetFallAlpha = InAlpha
		HandleFallAlphaChanged()

func HandleFallAlphaChanged():
	pass

func FinishFallSequence():
	
	var TargetAP := FallTriggerTile_TargetAP.TryGetFrom(CurrentTarget)
	if TargetAP:
		TargetAP.FinishFall(self)
	
	var PrevTarget = CurrentTarget
	
	FallAP.stop()
	CurrentTarget = null
	
	FallSequenceFinished.emit(PrevTarget)
