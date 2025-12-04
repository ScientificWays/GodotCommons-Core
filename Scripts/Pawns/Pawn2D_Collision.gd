extends CollisionShape2D
class_name Pawn2D_Collision

@export_category("Owner")
@export var OwnerPawn: Pawn2D

@export_category("Physics")
@export var Mass: float = 1.0
@export var ExplosionImpulseMul: float = 1.0

func _ready() -> void:
	
	assert(OwnerPawn)
	
	var size_scale := OwnerPawn.get_size_scale()
	#var size_scale := 1.0
	
	if shape.resource_local_to_scene:
		ResourceGlobals.util_scale_shape(shape, size_scale, 0.0)
	else:
		shape = ResourceGlobals.get_or_create_scaled_shape(shape, size_scale, 0.0)
	
	position *= size_scale
	
	var OwnerDamageReceiver := DamageReceiver.try_get_from(OwnerPawn)
	if OwnerDamageReceiver:
		OwnerDamageReceiver.set_meta(DamageReceiver.BoundsRadiusMeta, shape.get_rect().size.x * 0.5)
