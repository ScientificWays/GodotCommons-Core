extends CollisionShape2D
class_name Pawn2D_Collision

@export_category("Owner")
@export var OwnerPawn: Pawn2D

@export_category("Physics")
@export var Mass: float = 1.0
@export var ExplosionImpulseMul: float = 1.0

func _ready() -> void:
	
	assert(OwnerPawn)
	
	var SizeScale := OwnerPawn.GetSizeScale()
	#var SizeScale := 1.0
	
	shape = ResourceGlobals.GetOrCreateScaledShape(shape, SizeScale, 0.0)
	position *= SizeScale
	
	var OwnerDamageReceiver := DamageReceiver.TryGetFrom(OwnerPawn)
	if OwnerDamageReceiver:
		OwnerDamageReceiver.set_meta(DamageReceiver.BoundsRadiusMeta, shape.get_rect().size.x * 0.5)
