extends AnimatedSprite2D
class_name Projectile2D_Sprite

@export_category("Owner")
@export var OwnerProjectile: Projectile2D

func _ready() -> void:
	
	var SizeMul := OwnerProjectile.GetSizeMul()
	var ScaledSizeMul := SizeMul * OwnerProjectile._Power
	
	scale *= ScaledSizeMul
	
	play(animation)
