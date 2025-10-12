extends AnimatedSprite2D
class_name Projectile2D_Sprite

@export_category("Owner")
@export var owner_projectile: Projectile2D

func _ready() -> void:
	
	var size_mul := owner_projectile.data.get_size_mul(owner_projectile._level)
	var scaled_size_mul := size_mul * owner_projectile._power
	
	scale *= scaled_size_mul
	
	play(animation)
