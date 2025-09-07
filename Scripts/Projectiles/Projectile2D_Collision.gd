extends CollisionShape2D
class_name Projectile2D_Collision

@export_category("Owner")
@export var OwnerProjectile: Projectile2D

func _ready() -> void:
	
	assert(OwnerProjectile)
	
	var SizeMul := OwnerProjectile.GetSizeMul()
	var ScaledSizeMul := SizeMul * OwnerProjectile._Power
	
	shape = ResourceGlobals.GetOrCreateScaledShape(shape, ScaledSizeMul, 0.0)
	position *= ScaledSizeMul
	
