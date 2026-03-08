extends AnimatedSprite2D
class_name Projectile2D_Sprite

@export_category("Owner")
@export var owner_projectile: Projectile2D

@export_category("Transform")
@export var random_angle: bool = false

@export_category("Animations")
@export var beep_scale_mul: float = 1.0:
	set(in_mul):
		
		beep_scale_mul = in_mul
		
		scale = initial_scale * beep_scale_mul

var initial_scale: Vector2

func _ready() -> void:
	
	var size_mul := owner_projectile.data.get_size_mul(owner_projectile)
	
	scale *= size_mul
	initial_scale = scale
	
	init_randomized()

func init_randomized() -> void:
	
	if random_angle:
		rotation = randf_range(0.0, TAU)
	
	var animations := sprite_frames.get_animation_names()
	var random_animation := randi_range(0, animations.size() - 1)
	play(animations[random_animation])
