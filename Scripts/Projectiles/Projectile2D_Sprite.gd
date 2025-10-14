extends AnimatedSprite2D
class_name Projectile2D_Sprite

@export_category("Owner")
@export var owner_projectile: Projectile2D

@export_category("Animations")
@export var beep_scale_mul: float = 1.0:
	set(in_mul):
		
		beep_scale_mul = in_mul
		
		scale = initial_scale * beep_scale_mul

var initial_scale: Vector2

func _ready() -> void:
	
	var size_mul := owner_projectile.data.get_size_mul(owner_projectile._level)
	var scaled_size_mul := size_mul * owner_projectile._power
	
	scale *= scaled_size_mul
	initial_scale = scale
	
	play(animation)
