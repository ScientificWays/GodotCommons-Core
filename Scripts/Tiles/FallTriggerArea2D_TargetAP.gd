extends AnimationPlayer
class_name FallTriggerTile_TargetAP

static func TryGetFrom(InNode: Node) -> FallTriggerTile_TargetAP:
	return ModularGlobals.TryGetFrom(InNode, FallTriggerTile_TargetAP)

@export var TargetDamageReceiver: DamageReceiver
@export var FallAnimationName: StringName = &"Fall"

signal FallTriggered(InSource: Node)
signal FallFinished(InSource: Node)

func _enter_tree():
	ModularGlobals.InitModularNode(self)

func _exit_tree():
	ModularGlobals.DeInitModularNode(self)

func TriggerFall(InSource: Node):
	play(FallAnimationName)
	FallTriggered.emit(InSource)

func FinishFall(InSource: Node):
	
	stop()
	
	if TargetDamageReceiver:
		TargetDamageReceiver.TryReceiveDamage(InSource, InSource, 1000.0, DamageReceiver.DamageType_Fall, true)
	else:
		assert(false)
	
	FallFinished.emit(InSource)
