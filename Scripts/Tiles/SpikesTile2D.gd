extends Area2D

@export_category("Damage")
@export var target_damage: float = 100.0

func _ready() -> void:
	area_entered.connect(OnTargetEntered)
	body_entered.connect(OnTargetEntered)

func OnTargetEntered(in_target: Node2D) -> void:
	TryApplyDamageToTarget(in_target)

func TryApplyDamageToTarget(in_target: Node2D) -> bool:
	
	var TargetDamageReceiver := DamageReceiver.try_get_from(in_target)
	if not TargetDamageReceiver:
		return false
	
	return TargetDamageReceiver.TryReceiveDamage(self, self, target_damage, DamageReceiver.DamageType_MeleeHit, false)
