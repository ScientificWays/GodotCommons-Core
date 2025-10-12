extends CollisionShape2D
class_name Projectile2D_Collision

@export_category("Owner")
@export var owner_projectile: Projectile2D

func _ready() -> void:
	
	assert(owner_projectile)
	
	var size_mul := owner_projectile.data.get_size_mul(owner_projectile._level)
	var scaled_size_mul := size_mul * owner_projectile._power
	
	shape = ResourceGlobals.GetOrCreateScaledShape(shape, scaled_size_mul, 0.0)
	position *= scaled_size_mul
	
